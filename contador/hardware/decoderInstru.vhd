library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port ( opcode : in std_logic_vector(3 downto 0);
         saida : out std_logic_vector(12 downto 0)
  );
end entity;

architecture comportamento of decoderInstru is

  constant NOP  : std_logic_vector(3 downto 0) := "0000";  -- OpCode (mnemonico) 
  constant LDA  : std_logic_vector(3 downto 0) := "0001";
  constant SOMA : std_logic_vector(3 downto 0) := "0010";
  constant SUB  : std_logic_vector(3 downto 0) := "0011";
  constant LDI : std_logic_vector(3 downto 0) := "0100";
  constant STA : std_logic_vector(3 downto 0) := "0101";
  constant JMP : std_logic_vector(3 downto 0) := "0110";
  constant JEQ : std_logic_vector(3 downto 0) := "0111";
  constant CEQ : std_logic_vector(3 downto 0) := "1000";
  constant JSR : std_logic_vector(3 downto 0) := "1001";
  constant RET : std_logic_vector(3 downto 0) := "1010";
  constant ANDI : std_logic_vector(3 downto 0) := "1011"; --Instrucao
  constant INC : std_logic_vector(3 downto 0) := "1100";    -- Instrucao extra
  
  alias Hab_WR : std_logic is saida(0);
  alias Hab_RD : std_logic is saida(1);
  alias Hab_Flag : std_logic is saida(2);
  alias Op : std_logic_vector(1 downto 0) is saida(4 downto 3);
  alias Hab_A : std_logic is saida(5);
  alias SelMux : std_logic_vector(1 downto 0) is saida(7 downto 6);
  alias Hab_JEQ : std_logic is saida(8);
  alias Hab_JSR : std_logic is saida(9);
  alias Hab_RET : std_logic is saida(10);
  alias Hab_JMP : std_logic is saida(11);
  alias Hab_EscritaRet : std_logic is saida(12);
  

  begin
 
Hab_WR <= '1' when (opcode = STA) else '0';
Hab_RD <= '1' when (opcode = LDA or opcode = SOMA or opcode = SUB or opcode = CEQ) else '0';
Hab_Flag <= '1' when (opcode = CEQ) else '0';
Op <= "01" when (opcode = SOMA or opcode = INC) else 
		"00" when (opcode = SUB or opcode = CEQ) else
		"10" when (opcode = LDA or opcode = LDI) else
		"11" when (opcode = ANDI) else
		"00";
Hab_A <= '1' when (opcode = LDA or opcode = SOMA or opcode = SUB or opcode = LDI or opcode = ANDI or opcode = INC) else '0';
SelMUx <= "01" when (opcode = LDI or opcode = ANDI) else
			 "10" when (opcode = INC) else "00"; -- na duvida vai para entrada B
Hab_JEQ <= '1' when (opcode = JEQ) else '0';
Hab_JSR <= '1' when (opcode = JSR) else '0';
Hab_RET <= '1' when (opcode = RET) else '0';
Hab_JMP <= '1' when (opcode = JMP) else '0';
Hab_EscritaRet <= '1' when (opcode = JSR) else '0';

end architecture;