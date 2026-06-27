LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ALU_8b IS
    PORT (
        S  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0 );
        A  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        B  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		  F  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		  CN  : IN  STD_LOGIC;
		  M  : IN  STD_LOGIC;
		  Z : OUT STD_LOGIC   );
END ALU_8b;

ARCHITECTURE behav OF ALU_8b IS

BEGIN

  PROCESS(S,A,B,M,CN)
   BEGIN
    CASE S  IS
		  WHEN "0000" =>  IF M='0' THEN F<=A                      ; ELSE  F<=NOT A;                END IF;
        WHEN "0001" =>  IF M='0' THEN F<=(A or B)               ; ELSE  F<=NOT(A OR B);         END IF;
        WHEN "0010" =>  IF M='0' THEN F<=(A or (NOT B))         ; ELSE  F<=(NOT A) AND B;       END IF;
        WHEN "0011" =>  IF M='0' THEN F<= "00000000" - CN          ; ELSE  F<="00000000";           END IF;
        WHEN "0100" =>  IF M='0' THEN F<=A+(A AND NOT B)     ; ELSE  F<=NOT (A AND B);       END IF;
        WHEN "0101" =>  IF M='0' THEN F<=(A or B)+(A AND NOT B)  ; ELSE  F<=NOT B;            END IF;
        WHEN "0110" =>  IF M='0' THEN F<=(A - B)- CN                 ; ELSE  F<=A XOR B;           END IF;
        WHEN "0111" =>  IF M='0' THEN F<=(A AND (NOT B)) - CN         ; ELSE  F<=A and (NOT B);       END IF;
        WHEN "1000" =>  IF M='0' THEN F<=A + (A AND B)          ; ELSE  F<=(NOT A)and B;      END IF;
        WHEN "1001" =>  IF M='0' THEN F<=A + B                    ; ELSE  F<=NOT(A XOR B);     END IF;
        WHEN "1010" =>  IF M='0' THEN F<=(A or(NOT B))+(A AND B) ; ELSE  F<=B;                 END IF;
        WHEN "1011" =>  IF M='0' THEN F<=(A AND B) - CN               ; ELSE  F<=A AND B;          END IF;
        WHEN "1100" =>  IF M='0' THEN F<=(A + A)                 ; ELSE  F<= "00000001";          END IF;
        WHEN "1101" =>  IF M='0' THEN F<=(A or B) + A           ; ELSE  F<=A OR (NOT B);        END IF;
        WHEN "1110" =>  IF M='0' THEN F<=((A or (NOT B)) +A)    ; ELSE  F<=A OR B;              END IF;
        WHEN "1111" =>  IF M='0' THEN F<=A - CN                       ; ELSE  F<=A ;                   END IF;
        WHEN OTHERS  => F<= "00000000" ; 
    END CASE;
	 IF A = B THEN Z <= '1';  END IF;
  END PROCESS;

END behav;
