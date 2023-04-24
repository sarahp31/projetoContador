library ieee;
use ieee.std_logic_1164.all;

entity logicaDesvio is
  port ( flag : in std_logic;
         jeq : in std_logic;
			jsr : in std_logic;
			ret : in std_logic;
			jmp : in std_logic;
			selmux : out std_logic_vector(1 downto 0)
  );
end entity;

architecture comportamento of logicaDesvio is

	
  begin
	selmux(0) <= jmp or (jeq and flag) or jsr;
	selmux(1) <= ret;

end architecture;