-- regfile.vhd
-- 4x16-bit Register File (R0~R3)
-- RA, RB: read port address (2-bit)
-- RW:     write port address (2-bit)
-- WE:     write enable (active high)
-- busW:   write data (16-bit)
-- busA, busB: read data (16-bit, combinational)
-- Clock: rising edge write

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity regfile is
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
end entity regfile;

architecture rtl of regfile is
    type reg_array is array (0 to 3) of std_logic_vector(15 downto 0);
    signal regs : reg_array := (others => (others => '0'));
begin

    -- Write: rising edge, WE=1
    process(clk)
    begin
        if rising_edge(clk) then
            if WE = '1' then
                regs(to_integer(unsigned(RW))) <= busW;
            end if;
        end if;
    end process;

    -- Read: combinational
    busA <= regs(to_integer(unsigned(RA)));
    busB <= regs(to_integer(unsigned(RB)));

end architecture rtl;
