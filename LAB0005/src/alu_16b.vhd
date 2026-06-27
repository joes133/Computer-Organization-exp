-- alu_16b.vhd
-- 16-bit ALU
-- S[3:0] selects operation:
--   0000 = Add
--   0001 = Sub
--   0010 = AND
--   0011 = OR
--   0100 = NOT (of X)
--   0101 = XOR
--   0110 = SLL (X shift left by Y[3:0])
--   0111 = SRL (logical right shift)
--   1000 = SRA (arithmetic right shift)
-- Outputs: F (result), ZF (zero flag), SF (sign flag = F[15])

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_16b is
    port (
        X  : in  std_logic_vector(15 downto 0);
        Y  : in  std_logic_vector(15 downto 0);
        S  : in  std_logic_vector(3 downto 0);
        F  : out std_logic_vector(15 downto 0);
        ZF : out std_logic;
        SF : out std_logic
    );
end entity alu_16b;

architecture rtl of alu_16b is
    signal result : std_logic_vector(15 downto 0);
    signal shamt  : integer range 0 to 15;
begin

    shamt <= to_integer(unsigned(Y(3 downto 0)));

    process(X, Y, S, shamt)
    begin
        case S is
            when "0000" =>   -- Add
                result <= std_logic_vector(unsigned(X) + unsigned(Y));
            when "0001" =>   -- Sub
                result <= std_logic_vector(unsigned(X) - unsigned(Y));
            when "0010" =>   -- AND
                result <= X and Y;
            when "0011" =>   -- OR
                result <= X or Y;
            when "0100" =>   -- NOT X
                result <= not X;
            when "0101" =>   -- XOR
                result <= X xor Y;
            when "0110" =>   -- SLL: X << shamt
                result <= std_logic_vector(shift_left(unsigned(X), shamt));
            when "0111" =>   -- SRL: X >> shamt (logical)
                result <= std_logic_vector(shift_right(unsigned(X), shamt));
            when "1000" =>   -- SRA: X >> shamt (arithmetic)
                result <= std_logic_vector(shift_right(signed(X), shamt));
            when others =>
                result <= (others => '0');
        end case;
    end process;

    F  <= result;
    ZF <= '1' when result = x"0000" else '0';
    SF <= result(15);

end architecture rtl;
