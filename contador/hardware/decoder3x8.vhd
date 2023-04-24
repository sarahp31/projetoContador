library ieee;
use ieee.std_logic_1164.all;

entity decoder3x8 is
  port ( entrada : in std_logic_vector(2 downto 0);
			S0 : out std_logic;
			S1 : out std_logic;
			S2 : out std_logic;
			S3 : out std_logic;
			S4 : out std_logic;
			S5 : out std_logic;
			S6 : out std_logic;
			S7 : out std_logic
  );
end entity;

architecture comportamento of decoder3x8 is

	
  begin
	S0 <= '1' when (entrada = "000") else '0';
	S1 <= '1' when (entrada = "001") else '0';
	S2 <= '1' when (entrada = "010") else '0';
	S3 <= '1' when (entrada = "011") else '0';
	S4 <= '1' when (entrada = "100") else '0';
	S5 <= '1' when (entrada = "101") else '0';
	S6 <= '1' when (entrada = "110") else '0';
	S7 <= '1' when (entrada = "111") else '0';

end architecture;