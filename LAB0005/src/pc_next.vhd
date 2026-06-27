-- pc_next.vhd
-- PC next-address logic
-- Inputs:
--   pc_cur   : current PC (16-bit)
--   ext_imm  : sign/zero-extended immediate (16-bit)
--   target12 : jump target from instruction (12-bit)
--   alu_zf   : ALU zero flag
--   alu_sf   : ALU sign flag (not used in current design, reserved)
--   Branch   : branch enable (from controller)
--   BrNeg    : branch negate (0=beq, 1=bne)
--   Jump     : jump enable
-- Output:
--   next_pc  : next PC value

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc_next is
    port (
        pc_cur   : in  std_logic_vector(15 downto 0);
        ext_imm  : in  std_logic_vector(15 downto 0);
        target12 : in  std_logic_vector(11 downto 0);
        alu_zf   : in  std_logic;
        Branch   : in  std_logic;
        BrNeg    : in  std_logic;
        Jump     : in  std_logic;
        next_pc  : out std_logic_vector(15 downto 0)
    );
end entity pc_next;

architecture rtl of pc_next is
    signal pc_plus1     : std_logic_vector(15 downto 0);
    signal branch_target: std_logic_vector(15 downto 0);
    signal jump_target  : std_logic_vector(15 downto 0);
    signal branch_taken : std_logic;
begin
    -- PC + 1
    pc_plus1 <= std_logic_vector(unsigned(pc_cur) + 1);

    -- Branch target: PC+1 + sign_ext(imm)
    branch_target <= std_logic_vector(unsigned(pc_plus1) + unsigned(ext_imm));

    -- Jump target: {PC+1[15:12], target12}
    jump_target <= pc_plus1(15 downto 12) & target12;

    -- Branch taken: Branch AND (ZF XNOR BrNeg)
    -- beq: BrNeg=0, taken when ZF=1
    -- bne: BrNeg=1, taken when ZF=0
    branch_taken <= Branch and (alu_zf xnor BrNeg);

    -- Next PC: jump > branch > sequential
    next_pc <= jump_target   when Jump = '1'         else
               branch_target when branch_taken = '1' else
               pc_plus1;
end architecture rtl;
