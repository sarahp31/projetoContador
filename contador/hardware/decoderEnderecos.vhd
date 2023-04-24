library ieee;
use ieee.std_logic_1164.all;

entity decoderEnderecos is
  port ( entrada : in std_logic_vector(2 downto 0);
			bloco0 : out std_logic;
			bloco1 : out std_logic;
			bloco2 : out std_logic;
			bloco3 : out std_logic;
			bloco4 : out std_logic;
			bloco5 : out std_logic;
			bloco6 : out std_logic;
			bloco7 : out std_logic
  );
end entity;

architecture comportamento of decoderEnderecos is

	
  begin
	bloco0 <= '1' when (entrada = "000") else '0';
	bloco1 <= '1' when (entrada = "001") else '0';
	bloco2 <= '1' when (entrada = "010") else '0';
	bloco3 <= '1' when (entrada = "011") else '0';
	bloco4 <= '1' when (entrada = "100") else '0';
	bloco5 <= '1' when (entrada = "101") else '0';
	bloco6 <= '1' when (entrada = "110") else '0';
	bloco7 <= '1' when (entrada = "111") else '0';
	--bloco0 <= '1' when (E0 = '0' and E1 = '0' and E2 ='0') else '0';
	--bloco1 <= '1' when (E0 = '1' and E1 = '0' and E2 ='0') else '0';
	--bloco2 <= '1' when (E0 = '0' and E1 = '1' and E2 ='0') else '0';
	--bloco3 <= '1' when (E0 = '1' and E1 = '1' and E2 ='0') else '0';
	--bloco4 <= '1' when (E0 = '0' and E1 = '0' and E2 ='1') else '0';
	--bloco5 <= '1' when (E0 = '1' and E1 = '0' and E2 ='1') else '0';
	--bloco6 <= '1' when (E0 = '0' and E1 = '1' and E2 ='1') else '0';
	--bloco7 <= '1' when (E0 = '1' and E1 = '1' and E2 ='1') else '0';

end architecture;