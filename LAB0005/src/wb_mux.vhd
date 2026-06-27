-- wb_mux.vhd
-- Write-back data multiplexer (4-way priority)
-- Priority: Mem2Reg > Slt > Lui > ALU
--   Mem2Reg=1 -> ram_out (lw result)
--   Slt=1     -> {000...0, SF} (slt result)
--   Lui=1     -> {imm8, 00000000} (lui result)
--   default   -> alu_F (ALU result)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity wb_mux is
    port (
        alu_F   : in  std_logic_vector(15 downto 0);
        ram_out : in  std_logic_vector(15 downto 0);
        sf      : in  std_logic;
        imm8    : in  std_logic_vector(7 downto 0);
        Mem2Reg : in  std_logic;
        Slt     : in  std_logic;
        Lui     : in  std_logic;
        busW    : out std_logic_vector(15 downto 0)
    );
end entity wb_mux;

architecture rtl of wb_mux is
begin
    busW <= ram_out              when Mem2Reg = '1' else
            x"000" & "000" & sf  when Slt = '1'     else
            imm8 & x"00"         when Lui = '1'     else
            alu_F;
end architecture rtl;
