-- cpu_top.vhd
-- Single-Cycle CPU Top Level
--
-- Instruction format (16-bit):
--   [15:12] opcode
--   [11:10] rs
--   [ 9: 8] rt
--   [ 7: 6] rd       (R-type) / imm[7:6] (I-type)
--   [ 5: 3] func     (R-type) / imm[5:3] (I-type)
--   [ 2: 0] func/imm (R-type) / imm[2:0] (I-type)
--   => I-type imm8 = instr[7:0]
--   J-type: instr[11:0] = target address
--
-- PC semantics: after fetch, PC already points to NEXT instruction (PC+1)
-- Branch: next_pc = PC_plus1 + sign_ext(imm8)  when condition met
-- Jump:   next_pc = {PC_plus1[15:12], target12}
--
-- Display: 6 seven-segment displays (HEX0~HEX5)
--   HEX0-HEX1: PC value (low 8 bits)
--   HEX2-HEX3: busA value (rs register, low 8 bits)
--   HEX4-HEX5: ALU result (low 8 bits)
-- Ports:
--   clk      : system clock
--   rst      : synchronous reset
--   HEX0~HEX5: 7-seg outputs (6 groups, each 7 bits active-low)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu_top is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        -- Seven-segment display outputs (active-low, 7 bits per digit)
        HEX0 : out std_logic_vector(6 downto 0);  -- PC low nibble
        HEX1 : out std_logic_vector(6 downto 0);  -- PC high nibble
        HEX2 : out std_logic_vector(6 downto 0);  -- busA low nibble
        HEX3 : out std_logic_vector(6 downto 0);  -- busA high nibble
        HEX4 : out std_logic_vector(6 downto 0);  -- ALU_F low nibble
        HEX5 : out std_logic_vector(6 downto 0)   -- ALU_F high nibble
    );
end entity cpu_top;

architecture rtl of cpu_top is

    -- ---- Component declarations ----
    component pc_reg is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            wpc     : in  std_logic;
            next_pc : in  std_logic_vector(15 downto 0);
            pc      : out std_logic_vector(15 downto 0)
        );
    end component;

    component regfile is
        port (
            clk  : in  std_logic;
            WE   : in  std_logic;
            RA   : in  std_logic_vector(1 downto 0);
            RB   : in  std_logic_vector(1 downto 0);
            RW   : in  std_logic_vector(1 downto 0);
            busW : in  std_logic_vector(15 downto 0);
            busA : out std_logic_vector(15 downto 0);
            busB : out std_logic_vector(15 downto 0)
        );
    end component;

    component alu_16b is
        port (
            X  : in  std_logic_vector(15 downto 0);
            Y  : in  std_logic_vector(15 downto 0);
            S  : in  std_logic_vector(3 downto 0);
            F  : out std_logic_vector(15 downto 0);
            ZF : out std_logic;
            SF : out std_logic
        );
    end component;

    component extender is
        port (
            imm8 : in  std_logic_vector(7 downto 0);
            Exop : in  std_logic;
            ext  : out std_logic_vector(15 downto 0)
        );
    end component;

    component controller is
        port (
            opcode  : in  std_logic_vector(3 downto 0);
            func    : in  std_logic_vector(2 downto 0);
            RegWr   : out std_logic;
            RegDst  : out std_logic;
            ALUSrc  : out std_logic;
            Exop    : out std_logic;
            MemWr   : out std_logic;
            MemRd   : out std_logic;
            Mem2Reg : out std_logic;
            Branch  : out std_logic;
            BrNeg   : out std_logic;
            Jump    : out std_logic;
            Halt    : out std_logic;
            Slt     : out std_logic;
            Lui     : out std_logic;
            Disp    : out std_logic;
            S       : out std_logic_vector(3 downto 0)
        );
    end component;

    -- ---- Instruction ROM (256 x 16) ----
    -- Uses Quartus lpm_rom or altsyncram, initialized from rom_init.mif
    component rom_256x16 is
        port (
            address : in  std_logic_vector(7 downto 0);
            clock   : in  std_logic;
            q       : out std_logic_vector(15 downto 0)
        );
    end component;

    -- ---- Data RAM (256 x 16) ----
    component ram_256x16 is
        port (
            address : in  std_logic_vector(7 downto 0);
            clock   : in  std_logic;
            data    : in  std_logic_vector(15 downto 0);
            wren    : in  std_logic;
            q       : out std_logic_vector(15 downto 0)
        );
    end component;

    -- ---- Seven-segment decoder ----
    component seg7_16b is
        port (
            Blank : in  std_logic;
            Test  : in  std_logic;
            Data  : in  std_logic_vector(7 downto 0);
            RQ1   : out std_logic_vector(6 downto 0);  -- low nibble
            RQ2   : out std_logic_vector(6 downto 0)   -- high nibble
        );
    end component;

    -- ---- Internal signals ----
    signal pc_cur    : std_logic_vector(15 downto 0);
    signal pc_plus1  : std_logic_vector(15 downto 0);
    signal next_pc   : std_logic_vector(15 downto 0);
    signal wpc_en    : std_logic;

    signal instr     : std_logic_vector(15 downto 0);
    signal opcode    : std_logic_vector(3 downto 0);
    signal rs, rt, rd: std_logic_vector(1 downto 0);
    signal func      : std_logic_vector(2 downto 0);
    signal imm8      : std_logic_vector(7 downto 0);
    signal target12  : std_logic_vector(11 downto 0);

    -- Control signals
    signal RegWr, RegDst, ALUSrc, Exop_ctrl : std_logic;
    signal MemWr, MemRd, Mem2Reg            : std_logic;
    signal Branch, BrNeg, Jump, Halt        : std_logic;
    signal Slt, Lui, Disp_en               : std_logic;
    signal S_ctrl    : std_logic_vector(3 downto 0);

    -- Datapath signals
    signal busA, busB     : std_logic_vector(15 downto 0);
    signal busW           : std_logic_vector(15 downto 0);
    signal RW_addr        : std_logic_vector(1 downto 0);
    signal alu_Y          : std_logic_vector(15 downto 0);
    signal alu_F          : std_logic_vector(15 downto 0);
    signal alu_ZF, alu_SF : std_logic;
    signal ext_imm        : std_logic_vector(15 downto 0);
    signal ram_out        : std_logic_vector(15 downto 0);
    signal ram_addr       : std_logic_vector(7 downto 0);

    -- Branch/Jump next-PC signals
    signal branch_target  : std_logic_vector(15 downto 0);
    signal jump_target    : std_logic_vector(15 downto 0);
    signal branch_taken   : std_logic;

begin

    -- ---- Instruction decode ----
    opcode   <= instr(15 downto 12);
    rs       <= instr(11 downto 10);
    rt       <= instr(9  downto  8);
    rd       <= instr(7  downto  6);
    func     <= instr(5  downto  3);
    imm8     <= instr(7  downto  0);
    target12 <= instr(11 downto  0);

    -- ---- PC logic ----
    pc_plus1 <= std_logic_vector(unsigned(pc_cur) + 1);

    -- Branch target: PC+1 + sign_ext(imm8)
    branch_target <= std_logic_vector(unsigned(pc_plus1) + unsigned(ext_imm));

    -- Jump target: {PC_plus1[15:12], target12}
    jump_target <= pc_plus1(15 downto 12) & target12;

    -- Branch taken condition
    branch_taken <= Branch and (alu_ZF xnor BrNeg);
    -- beq: BrNeg=0, taken when ZF=1  -> ZF xnor 0 = ZF
    -- bne: BrNeg=1, taken when ZF=0  -> ZF xnor 1 = not ZF

    -- Next PC mux: jump > branch > sequential
    next_pc <= jump_target   when Jump = '1'         else
               branch_target when branch_taken = '1' else
               pc_plus1;

    -- Halt stops PC update
    wpc_en <= '0' when Halt = '1' else '1';

    -- ---- Register file write-back mux ----
    -- RegDst: '1'=rd (R-type), '0'=rt (I-type)
    RW_addr <= rd when RegDst = '1' else rt;

    -- Write-back data mux
    busW <= ram_out                                   when Mem2Reg = '1'     else
            x"000" & "000" & alu_SF                  when Slt = '1'         else
            imm8 & x"00"                              when Lui = '1'         else
            alu_F;

    -- ---- ALU input Y mux ----
    alu_Y <= ext_imm when ALUSrc = '1' else busB;

    -- ---- RAM address (lower 8 bits of ALU result) ----
    ram_addr <= alu_F(7 downto 0);

    -- ---- Display outputs via seven-segment decoders ----
    U_SEG_PC: seg7_16b
        port map (
            Blank => '0',
            Test  => '1',
            Data  => pc_cur(7 downto 0),
            RQ1   => HEX0,
            RQ2   => HEX1
        );

    U_SEG_REGA: seg7_16b
        port map (
            Blank => '0',
            Test  => '1',
            Data  => busA(7 downto 0),
            RQ1   => HEX2,
            RQ2   => HEX3
        );

    U_SEG_ALU: seg7_16b
        port map (
            Blank => '0',
            Test  => '1',
            Data  => alu_F(7 downto 0),
            RQ1   => HEX4,
            RQ2   => HEX5
        );

    -- ---- Module instantiations ----
    U_PC: pc_reg
        port map (
            clk     => clk,
            rst     => rst,
            wpc     => wpc_en,
            next_pc => next_pc,
            pc      => pc_cur
        );

    U_ROM: rom_256x16
        port map (
            address => pc_cur(7 downto 0),
            clock   => clk,
            q       => instr
        );

    U_CTRL: controller
        port map (
            opcode  => opcode,
            func    => func,
            RegWr   => RegWr,
            RegDst  => RegDst,
            ALUSrc  => ALUSrc,
            Exop    => Exop_ctrl,
            MemWr   => MemWr,
            MemRd   => MemRd,
            Mem2Reg => Mem2Reg,
            Branch  => Branch,
            BrNeg   => BrNeg,
            Jump    => Jump,
            Halt    => Halt,
            Slt     => Slt,
            Lui     => Lui,
            Disp    => Disp_en,
            S       => S_ctrl
        );

    U_REG: regfile
        port map (
            clk  => clk,
            WE   => RegWr,
            RA   => rs,
            RB   => rt,
            RW   => RW_addr,
            busW => busW,
            busA => busA,
            busB => busB
        );

    U_EXT: extender
        port map (
            imm8 => imm8,
            Exop => Exop_ctrl,
            ext  => ext_imm
        );

    U_ALU: alu_16b
        port map (
            X  => busA,
            Y  => alu_Y,
            S  => S_ctrl,
            F  => alu_F,
            ZF => alu_ZF,
            SF => alu_SF
        );

    U_RAM: ram_256x16
        port map (
            address => ram_addr,
            clock   => clk,
            data    => busB,
            wren    => MemWr,
            q       => ram_out
        );

end architecture rtl;
