-- controller.vhd
-- Main Decoder + R-type Decoder
--
-- Instruction encoding (opcode 4-bit):
--   0000 = R-type  (func selects operation)
--   0001 = DISP
--   0010 = lui
--   0011 = ori
--   0101 = addi
--   0110 = lw
--   0111 = sw
--   1000 = beq
--   1001 = bne
--   1011 = jump
--   1100 = halt
--
-- R-type func[2:0] (bits [5:3] of instruction):
--   000 = or    -> S=0011
--   001 = and   -> S=0010
--   010 = add   -> S=0000
--   011 = sub   -> S=0001
--   100 = sllv  -> S=0110
--   101 = srlv  -> S=0111
--   110 = srav  -> S=1000
--   111 = slt   -> S=0001 (sub, then use SF)
--
-- Control signals:
--   RegWr  : write to register file
--   RegDst : rd=1 (R-type), rt=0 (I-type)
--   ALUSrc : ALU Y from regfile(0) or extender(1)
--   Exop   : 0=zero-ext, 1=sign-ext
--   MemWr  : RAM write enable
--   MemRd  : RAM read enable
--   Mem2Reg: write back from ALU(0) or RAM(1)
--   Branch : branch enable (beq/bne)
--   BrNeg  : branch condition invert (bne=1, beq=0)
--   Jump   : unconditional jump
--   Halt   : stop clock
--   Slt    : slt mode (write SF to rd)
--   Lui    : lui mode (write imm<<8 to rt)
--   Disp   : display enable
--   S      : ALU operation select [3:0]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is
    port (
        opcode : in  std_logic_vector(3 downto 0);
        func   : in  std_logic_vector(2 downto 0);
        -- Control outputs
        RegWr  : out std_logic;
        RegDst : out std_logic;
        ALUSrc : out std_logic;
        Exop   : out std_logic;
        MemWr  : out std_logic;
        MemRd  : out std_logic;
        Mem2Reg: out std_logic;
        Branch : out std_logic;
        BrNeg  : out std_logic;
        Jump   : out std_logic;
        Halt   : out std_logic;
        Slt    : out std_logic;
        Lui    : out std_logic;
        Disp   : out std_logic;
        S      : out std_logic_vector(3 downto 0)
    );
end entity controller;

architecture rtl of controller is
    signal S_rtype : std_logic_vector(3 downto 0);
    signal S_main  : std_logic_vector(3 downto 0);
    signal is_rtype: std_logic;
begin

    -- R-type func decoder
    process(func)
    begin
        case func is
            when "000" => S_rtype <= "0011";  -- or
            when "001" => S_rtype <= "0010";  -- and
            when "010" => S_rtype <= "0000";  -- add
            when "011" => S_rtype <= "0001";  -- sub
            when "100" => S_rtype <= "0110";  -- sllv
            when "101" => S_rtype <= "0111";  -- srlv
            when "110" => S_rtype <= "1000";  -- srav
            when "111" => S_rtype <= "0001";  -- slt (sub to get SF)
            when others => S_rtype <= "0000";
        end case;
    end process;

    -- Main decoder
    process(opcode)
    begin
        -- defaults (NOP-like)
        RegWr   <= '0';
        RegDst  <= '0';
        ALUSrc  <= '0';
        Exop    <= '0';
        MemWr   <= '0';
        MemRd   <= '0';
        Mem2Reg <= '0';
        Branch  <= '0';
        BrNeg   <= '0';
        Jump    <= '0';
        Halt    <= '0';
        Slt     <= '0';
        Lui     <= '0';
        Disp    <= '0';
        S_main  <= "0000";
        is_rtype <= '0';

        case opcode is
            when "0000" =>  -- R-type
                RegWr   <= '1';
                RegDst  <= '1';  -- write to rd
                ALUSrc  <= '0';  -- Y = busB
                is_rtype <= '1';
                -- Slt special case handled below via func
                if func = "111" then
                    Slt <= '1';
                end if;

            when "0001" =>  -- DISP
                Disp    <= '1';

            when "0010" =>  -- lui: $rt = imm << 8
                RegWr   <= '1';
                RegDst  <= '0';  -- write to rt
                Lui     <= '1';  -- bypass ALU, write (imm8 & 00000000)

            when "0011" =>  -- ori: $rt = $rs | zero_ext(imm)
                RegWr   <= '1';
                RegDst  <= '0';
                ALUSrc  <= '1';
                Exop    <= '0';  -- zero-extend
                S_main  <= "0011";  -- OR

            when "0101" =>  -- addi: $rt = $rs + sign_ext(imm)
                RegWr   <= '1';
                RegDst  <= '0';
                ALUSrc  <= '1';
                Exop    <= '1';  -- sign-extend
                S_main  <= "0000";  -- ADD

            when "0110" =>  -- lw: $rt = MEM[$rs + sign_ext(imm)]
                RegWr   <= '1';
                RegDst  <= '0';
                ALUSrc  <= '1';
                Exop    <= '1';
                MemRd   <= '1';
                Mem2Reg <= '1';
                S_main  <= "0000";  -- ADD (address calc)

            when "0111" =>  -- sw: MEM[$rs + sign_ext(imm)] = $rt
                RegWr   <= '0';
                ALUSrc  <= '1';
                Exop    <= '1';
                MemWr   <= '1';
                S_main  <= "0000";

            when "1000" =>  -- beq
                Branch  <= '1';
                BrNeg   <= '0';  -- branch if ZF=1
                ALUSrc  <= '0';
                Exop    <= '1';
                S_main  <= "0001";  -- SUB to compare

            when "1001" =>  -- bne
                Branch  <= '1';
                BrNeg   <= '1';  -- branch if ZF=0
                ALUSrc  <= '0';
                Exop    <= '1';
                S_main  <= "0001";

            when "1011" =>  -- jump
                Jump    <= '1';

            when "1100" =>  -- halt
                Halt    <= '1';

            when others =>
                null;
        end case;
    end process;

    -- Select ALU S: R-type uses S_rtype, others use S_main
    S <= S_rtype when is_rtype = '1' else S_main;

end architecture rtl;
