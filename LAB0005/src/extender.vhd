-- extender.vhd
-- 8-bit immediate to 16-bit extension
-- Exop = '0': zero extension
-- Exop = '1': sign extension

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity extender is
    port (
        imm8 : in  std_logic_vector(7 downto 0);
        Exop : in  std_logic;
        ext  : out std_logic_vector(15 downto 0)
    );
end entity extender;

architecture rtl of extender is
begin
    process(imm8, Exop)
    begin
        if Exop = '0' then
            -- Zero extension
            ext <= "00000000" & imm8;
        else
            -- Sign extension: replicate bit 7
            ext <= (15 downto 8 => imm8(7)) & imm8;
        end if;
    end process;
end architecture rtl;
