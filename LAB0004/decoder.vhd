LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY decoder IS
    PORT (
        OP  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
--        OP1  : IN  STD_LOGIC;
--        OP2  : IN  STD_LOGIC;
--		  OP3  : IN  STD_LOGIC;
--		  S0  : OUT  STD_LOGIC;
--        S1  : OUT  STD_LOGIC;
--        S2  : OUT  STD_LOGIC;
--		  S3  : OUT  STD_LOGIC;
		  S  : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0);
		  CN  : OUT  STD_LOGIC;
		  M  : OUT  STD_LOGIC;
		  PC_INCR  : OUT  STD_LOGIC;
		  PC_WR  : OUT  STD_LOGIC;
		  RAM_LOAD  : OUT  STD_LOGIC;
		  RAM_STR  : OUT  STD_LOGIC;
		  AC_LOAD  : OUT  STD_LOGIC;
		  Mux_Sel  : OUT  STD_LOGIC
);
END decoder;

ARCHITECTURE behav OF decoder IS

--SIGNAL OP : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
--  OP <= OP3&OP2&OP1&OP0;
  PROCESS(OP)
   BEGIN
    CASE OP  IS
--		  WHEN "0000" =>  S3 <= '0';  S2 <= '0';  S1 <= '0';  S0 <= '0';  CN <= '0';  M <= '0';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '0';  RAM_STR <= '0';  AC_LOAD <= '0';  Mux_Sel <= '0'; --NOP
--        WHEN "0001" =>  S3 <= '0';  S2 <= '0';  S1 <= '0';  S0 <= '0';  CN <= '0';  M <= '0';  PC_INCR <= '0';  PC_WR <= '1';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '0';  Mux_Sel <= '0'; --JMP        
--        WHEN "0010" =>  S3 <= '0';  S2 <= '1';  S1 <= '1';  S0 <= '0';  CN <= '1';  M <= '0';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '1'; --SUB       
--        WHEN "0011" =>  S3 <= '0';  S2 <= '0';  S1 <= '0';  S0 <= '0';  CN <= '0';  M <= '0';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '0'; --LAD
--        WHEN "0100" =>  S3 <= '1';  S2 <= '0';  S1 <= '1';  S0 <= '1';  CN <= '0';  M <= '1';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '1'; --AND
--        WHEN "0101" =>  S3 <= '0';  S2 <= '1';  S1 <= '1';  S0 <= '1';  CN <= '0';  M <= '1';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '1'; --OR
--        WHEN "0110" =>  S3 <= '1';  S2 <= '0';  S1 <= '0';  S0 <= '1';  CN <= '1';  M <= '0';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '1'; --ADD
--        WHEN "0111" =>  S3 <= '0';  S2 <= '0';  S1 <= '0';  S0 <= '0';  CN <= '0';  M <= '0';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '0';  RAM_STR <= '1';  AC_LOAD <= '0';  Mux_Sel <= '0'; --STD
--        WHEN OTHERS  => S3 <= '0';  S2 <= '0';  S1 <= '0';  S0 <= '0';  CN <= '0';  M <= '0';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '0';  RAM_STR <= '0';  AC_LOAD <= '0';  Mux_Sel <= '0'; --NOP 
		  WHEN "0000" =>  S <= (others => 'Z'); CN <= 'Z';  M <= 'Z';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '0';  RAM_STR <= '0';  AC_LOAD <= '0';  Mux_Sel <= '0'; --NOP
        WHEN "0001" =>  S <= (others => 'Z'); CN <= 'Z';  M <= 'Z';  PC_INCR <= '0';  PC_WR <= '1';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '0';  Mux_Sel <= 'Z'; --JMP        
        WHEN "0010" =>  S <= "0110"; CN <= '0';  M <= '0';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '1'; --SUB       
        WHEN "0011" =>  S <= (others => 'Z'); CN <= 'Z';  M <= 'Z';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '0'; --LAD
        WHEN "0100" =>  S <= "1011"; CN <= '0';  M <= '1';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '1'; --AND
        WHEN "0101" =>  S <= "1110"; CN <= '0';  M <= '1';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '1'; --OR
        WHEN "0110" =>  S <= "1001"; CN <= '1';  M <= '0';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '1';  RAM_STR <= '0';  AC_LOAD <= '1';  Mux_Sel <= '1'; --ADD
        WHEN "0111" =>  S <= (others => 'Z'); CN <= 'Z';  M <= 'Z';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '0';  RAM_STR <= '1';  AC_LOAD <= '0';  Mux_Sel <= 'Z'; --STD
        WHEN OTHERS  => S <= (others => 'Z'); CN <= 'Z';  M <= 'Z';  PC_INCR <= '1';  PC_WR <= '0';  RAM_LOAD <= '0';  RAM_STR <= '0';  AC_LOAD <= '0';  Mux_Sel <= '0'; --NOP 
    END CASE;
  END PROCESS;

END behav;
