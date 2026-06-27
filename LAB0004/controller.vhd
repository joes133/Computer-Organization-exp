-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.1.0 Build 162 10/23/2013 SJ Full Version"
-- CREATED		"Thu Jan 09 13:36:26 2020"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY controller IS 
	PORT
	(
		B_T :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		clock :  IN  STD_LOGIC;
		ACOUT1 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		ACOUT2 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		ALUOUT1 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		ALUOUT2 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		MDROUT1 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		MDROUT2 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		S :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END controller;

ARCHITECTURE bdf_type OF controller IS 

COMPONENT alu_8b
	PORT(CN : IN STD_LOGIC;
		 M : IN STD_LOGIC;
		 A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 B : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 S : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 Z : OUT STD_LOGIC;
		 F : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc
	PORT(clk : IN STD_LOGIC;
		 Reset : IN STD_LOGIC;
		 LOAD_PC : IN STD_LOGIC;
		 INCR_PC : IN STD_LOGIC;
		 Addr_Val_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 PC_out : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT lpm_mux0
	PORT(sel : IN STD_LOGIC;
		 data0x : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 data1x : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT decoder
	PORT(OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 CN : OUT STD_LOGIC;
		 M : OUT STD_LOGIC;
		 PC_INCR : OUT STD_LOGIC;
		 PC_WR : OUT STD_LOGIC;
		 RAM_LOAD : OUT STD_LOGIC;
		 RAM_STR : OUT STD_LOGIC;
		 AC_LOAD : OUT STD_LOGIC;
		 Mux_Sel : OUT STD_LOGIC;
		 S : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT seg7_16b
	PORT(Blank : IN STD_LOGIC;
		 Test : IN STD_LOGIC;
		 Data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 RQ1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 RQ2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT rom
	PORT(clock : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram1
	PORT(wren : IN STD_LOGIC;
		 rden : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ac
	PORT(LOAD_AC : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 Data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 Data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	AC1 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	F :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	INCR_PC :  STD_LOGIC;
SIGNAL	instruction :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	LOAD_AC :  STD_LOGIC;
SIGNAL	LOAD_PC :  STD_LOGIC;
SIGNAL	LOAD_RAM :  STD_LOGIC;
SIGNAL	MDR :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	PC_out :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	R_out :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	sel :  STD_LOGIC;
SIGNAL	STR_RAM :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;


BEGIN 
S <= SYNTHESIZED_WIRE_2;



b2v_inst : alu_8b
PORT MAP(CN => SYNTHESIZED_WIRE_0,
		 M => SYNTHESIZED_WIRE_1,
		 A => AC1,
		 B => MDR,
		 S => SYNTHESIZED_WIRE_2,
		 F => F);


b2v_inst10 : pc
PORT MAP(clk => clock,
		 Reset => reset,
		 LOAD_PC => LOAD_PC,
		 INCR_PC => INCR_PC,
		 Addr_Val_in => instruction(7 DOWNTO 0),
		 PC_out => PC_out);


b2v_inst11 : lpm_mux0
PORT MAP(sel => sel,
		 data0x => MDR,
		 data1x => F,
		 result => R_out);


b2v_inst12 : decoder
PORT MAP(OP => instruction(31 DOWNTO 28),
		 CN => SYNTHESIZED_WIRE_0,
		 M => SYNTHESIZED_WIRE_1,
		 PC_INCR => INCR_PC,
		 PC_WR => LOAD_PC,
		 RAM_LOAD => LOAD_RAM,
		 RAM_STR => STR_RAM,
		 AC_LOAD => LOAD_AC,
		 Mux_Sel => sel,
		 S => SYNTHESIZED_WIRE_2);


b2v_inst14 : seg7_16b
PORT MAP(Blank => SYNTHESIZED_WIRE_7,
		 Test => B_T,
		 Data => F,
		 RQ1 => ALUOUT1,
		 RQ2 => ALUOUT2);


SYNTHESIZED_WIRE_7 <= NOT(B_T);



b2v_inst16 : seg7_16b
PORT MAP(Blank => SYNTHESIZED_WIRE_7,
		 Test => B_T,
		 Data => AC1,
		 RQ1 => ACOUT1,
		 RQ2 => ACOUT2);


b2v_inst17 : seg7_16b
PORT MAP(Blank => SYNTHESIZED_WIRE_7,
		 Test => B_T,
		 Data => MDR,
		 RQ1 => MDROUT1,
		 RQ2 => MDROUT2);


b2v_inst2 : rom
PORT MAP(clock => SYNTHESIZED_WIRE_6,
		 address => PC_out,
		 q => instruction);


b2v_inst3 : ram1
PORT MAP(wren => STR_RAM,
		 rden => LOAD_RAM,
		 clock => clock,
		 address => instruction(7 DOWNTO 0),
		 data => AC1,
		 q => MDR);


SYNTHESIZED_WIRE_6 <= NOT(clock);



b2v_inst8 : ac
PORT MAP(LOAD_AC => LOAD_AC,
		 clk => clock,
		 Data_in => R_out,
		 Data_out => AC1);


END bdf_type;