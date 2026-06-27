-- mux2_16.vhd
-- 2-to-1 multiplexer, 16-bit data width
-- sel=0 -> output = d0;  sel=1 -> output = d1

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2_16 is
    port (
        d0  : in  std_logic_vector(15 downto 0);
        d1  : in  std_logic_vector(15 downto 0);
        sel : in  std_logic;
        y   : out std_logic_vector(15 downto 0)
    );
end entity mux2_16;

architecture rtl of mux2_16 is
begin
    y <= d1 when sel = '1' else d0;
end architecture rtl;
