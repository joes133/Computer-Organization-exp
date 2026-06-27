-- pc_reg.vhd
-- 16-bit Program Counter
-- wpc  : write enable (active high); when Halt='1' wpc is forced '0'
-- next_pc: next address to load
-- pc   : current PC output

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pc_reg is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;  -- synchronous reset, active high
        wpc     : in  std_logic;  -- write enable
        next_pc : in  std_logic_vector(15 downto 0);
        pc      : out std_logic_vector(15 downto 0)
    );
end entity pc_reg;

architecture rtl of pc_reg is
    signal pc_reg_s : std_logic_vector(15 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_reg_s <= (others => '0');
            elsif wpc = '1' then
                pc_reg_s <= next_pc;
            end if;
        end if;
    end process;

    pc <= pc_reg_s;
end architecture rtl;
