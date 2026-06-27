LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IR is
port (
		clk : IN STD_LOGIC;
		Reset : IN STD_LOGIC;
		LOAD_iru_in : IN STD_LOGIC;
		LOAD_irl_in : IN STD_LOGIC;
		OPcode_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		Addr_Val_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
end IR;

ARCHITECTURE accu OF IR IS

SIGNAL Data_in : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"7658";
BEGIN

  PROCESS(clk,Reset,LOAD_irl_in,LOAD_iru_in)
   BEGIN
	IF Reset = '0' THEN 
		OPcode_out <= X"03";
		Addr_Val_out <= X"04";
		ELSIF clk'event AND clk = '1' THEN
			IF LOAD_iru_in = '1' AND LOAD_irl_in = '0' THEN
				OPcode_out <= Data_in(15 DOWNTO 8);
				ELSIF LOAD_iru_in = '0' AND LOAD_irl_in = '1' THEN
				Addr_Val_out <= Data_in(7 DOWNTO 0);
				ELSE 
				OPcode_out <= X"01";
				Addr_Val_out <= X"02";
			END IF;

	END IF;
	
  END PROCESS;

END accu;