library ieee;
use ieee.std_logic_1164.all;

entity Contador is
  -- Total de bits das entradas e saidas
  generic ( larguraDados : natural := 8;
		  larguraEnderecoRAM : natural := 6;
		  larguraEnderecoROM : natural := 9;
        simulacao : boolean := FALSE -- para gravar na placa, altere de TRUE para FALSE
  );
  port   (
    CLOCK_50 : in std_logic;
    KEY: in std_logic_vector(3 downto 0);
	 SW : in std_logic_vector(9 downto 0);
	 FPGA_RESET_N : in std_logic;
    LEDR  : out std_logic_vector(9 downto 0);
	 HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
  );
end entity;


architecture arquitetura of Contador is

  signal CLK : std_logic;
  signal HabEcrita_Retorno : std_logic;
  signal Dado_MemoriaROM : std_logic_vector(12 downto 0);
  signal Endereco : std_logic_vector(8 downto 0);
  signal Dado_Escrito : std_logic_vector(7 downto 0);
  signal Dado_Lido : std_logic_vector(7 downto 0);
  signal EnderecoROM : std_logic_vector(8 downto 0);
  signal Hab_Bloco0, Hab_Bloco1, Hab_Bloco2, Hab_Bloco3, Hab_Bloco4, Hab_Bloco5, Hab_Bloco6, Hab_Bloco7 : std_logic;
  signal Leitura : std_logic;
  signal Escrita : std_logic;
  signal Hab_Ende0, Hab_Ende1, Hab_Ende2, Hab_Ende3, Hab_Ende4, Hab_Ende5, Hab_Ende6 , Hab_Ende7 : std_logic;
  signal LED8_unico : std_logic;
  signal LED9_unico : std_logic;
  signal LED_conjunto : std_logic_vector(7 downto 0);
  signal HEX0_Decod, HEX1_Decod, HEX2_Decod, HEX3_Decod, HEX4_Decod, HEX5_Decod : std_logic_vector(3 downto 0);
  signal HEX0_Saida, HEX1_Saida, HEX2_Saida, HEX3_Saida, HEX4_Saida, HEX5_Saida : std_logic_vector(6 downto 0);
  signal FF_Botao0_Saida, FF_Botao1_Saida, FF_Botao2_Saida, FF_Botao3_Saida : std_logic;
  signal Detector_FF0_Saida, Detector_FF1_Saida, Detector_FF2_Saida, Detector_FF3_Saida : std_logic;
  signal Hab_Key0, Hab_Key1, Hab_Key2, Hab_Key3 : std_logic;
  
begin

-- Instanciando os componentes:

-- Para simular, fica mais simples tirar o edgeDetector
--gravar:  if simulacao generate
--CLK <= KEY(0);
--else generate
--detectorSub0: work.edgeDetector(bordaSubida)
--        port map (clk => CLOCK_50, entrada => (not KEY(0)), saida => CLK);
--end generate;
CLK <= CLOCK_50;
			 
-- BUSCA DE INSTRUCAO

--CPU

CPU : entity work.CPU  generic map (larguraDados => larguraDados,larguraEnderecoROM => larguraEnderecoROM)
			port map (Instrucao_IN => Dado_MemoriaROM,
	 Endereco_Dados => Endereco,
	 Escrita_Dados => Dado_Escrito,
	 Leitura_Dados => Dado_Lido,
	 Endereco_ROM => EnderecoROM,
	 Wr => Escrita,
	 Rd => Leitura,
	 Clock => CLK);

-- Memoria Instrucao
ROM1 : entity work.memoriaROM   generic map (dataWidth => 13, addrWidth => larguraEnderecoROM)
          port map (Endereco => EnderecoROM, Dado => Dado_MemoriaROM);



-- Memoria RAM		 
RAM : entity work.memoriaRAM   generic map (dataWidth => larguraDados, addrWidth => larguraEnderecoRAM)
          port map (addr => Endereco(5 downto 0), we => Escrita, re => Leitura, habilita  => Hab_Bloco0, dado_in => Dado_Escrito, dado_out => Dado_Lido, clk => CLK);		 

			 
-- Docodificacao de Blocos
DECODER_Bloco : entity work.decoder3x8
          port map (entrada => Endereco(8 downto 6), S0 => Hab_Bloco0, S1 => Hab_Bloco1, S2 => Hab_Bloco2, S3 => Hab_Bloco3, S4 => Hab_Bloco4, S5 => Hab_Bloco5, S6 => Hab_Bloco6, S7 => Hab_Bloco7);	


-- Docodificacao de Enderecos
DECODER_Ender : entity work.decoder3x8
          port map (entrada => Endereco(2 downto 0), S0 => Hab_Ende0, S1 => Hab_Ende1, S2 => Hab_Ende2, S3 => Hab_Ende3, S4 => Hab_Ende4, S5 => Hab_Ende5, S6 => Hab_Ende6, S7 => Hab_Ende7);

			 
-- FlipFlop para LEDs
LEDR8 : entity work.FlipFlop
          port map (DIN => Dado_Escrito(0), DOUT => LED8_unico, ENABLE => (Escrita and Hab_Bloco4 and Hab_Ende1 and (not Endereco(5))), CLK => CLK, RST => '0');
			 
LEDR9 : entity work.FlipFlop
          port map (DIN => Dado_Escrito(0), DOUT => LED9_unico, ENABLE => (Escrita and Hab_Bloco4 and Hab_Ende2 and (not Endereco(5))), CLK => CLK, RST => '0');

			 
-- Registrados para conjuto de 9 LEDs .
LEDs : entity work.registradorGenerico   generic map (larguraDados => larguraDados)
          port map (DIN => Dado_Escrito, DOUT => LED_conjunto, ENABLE => (Escrita and Hab_Bloco4 and Hab_Ende0 and (not Endereco(5))), CLK => CLK, RST => '0');

			 
-- Registradores Displays 7 Segmentos
REG_HEX0: entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => Dado_Escrito(3 downto 0), DOUT => HEX0_Decod, ENABLE => (Escrita and Hab_Bloco4 and Hab_Ende0 and Endereco(5)), CLK => CLK, RST => '0');
			 
REG_HEX1: entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => Dado_Escrito(3 downto 0), DOUT => HEX1_Decod, ENABLE => (Escrita and Hab_Bloco4 and Hab_Ende1 and Endereco(5)), CLK => CLK, RST => '0');
			 
REG_HEX2: entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => Dado_Escrito(3 downto 0), DOUT => HEX2_Decod, ENABLE => (Escrita and Hab_Bloco4 and Hab_Ende2 and Endereco(5)), CLK => CLK, RST => '0');
			 
REG_HEX3: entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => Dado_Escrito(3 downto 0), DOUT => HEX3_Decod, ENABLE => (Escrita and Hab_Bloco4 and Hab_Ende3 and Endereco(5)), CLK => CLK, RST => '0');
			 
REG_HEX4: entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => Dado_Escrito(3 downto 0), DOUT => HEX4_Decod, ENABLE => (Escrita and Hab_Bloco4 and Hab_Ende4 and Endereco(5)), CLK => CLK, RST => '0');
			 
REG_HEX5: entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => Dado_Escrito(3 downto 0), DOUT => HEX5_Decod, ENABLE => (Escrita and Hab_Bloco4 and Hab_Ende5 and Endereco(5)), CLK => CLK, RST => '0');


-- Conversor Display de 7 Segmentos 
ConversorHEX0 :  entity work.conversorHex7Seg
        port map(dadoHex => HEX0_Decod, apaga =>  '0', negativo => '0', overFlow => '0', saida7seg => HEX0_Saida);

ConversorHEX1 :  entity work.conversorHex7Seg
        port map(dadoHex => HEX1_Decod, apaga =>  '0', negativo => '0', overFlow => '0', saida7seg => HEX1_Saida);
					  
ConversorHEX2 :  entity work.conversorHex7Seg
        port map(dadoHex => HEX2_Decod, apaga =>  '0', negativo => '0', overFlow => '0', saida7seg => HEX2_Saida);
		  
ConversorHEX3 :  entity work.conversorHex7Seg
        port map(dadoHex => HEX3_Decod, apaga =>  '0', negativo => '0', overFlow => '0', saida7seg => HEX3_Saida);

ConversorHEX4 :  entity work.conversorHex7Seg
        port map(dadoHex => HEX4_Decod, apaga =>  '0', negativo => '0', overFlow => '0', saida7seg => HEX4_Saida);

ConversorHEX5 :  entity work.conversorHex7Seg
        port map(dadoHex => HEX5_Decod, apaga =>  '0', negativo => '0', overFlow => '0', saida7seg => HEX5_Saida);

		  
-- Buffer Chaves
Buffer_Conjunto :  entity work.buffer_3_state_8portas
        port map(entrada => SW(7 downto 0), habilita => (Leitura and Hab_Bloco5 and Hab_Ende0 and (not Endereco(5))) , saida => Dado_Lido);
		  

SW8 :  entity work.buffer_3_state_1porta
        port map(entrada => SW(8), habilita => (Leitura and Hab_Bloco5 and Hab_Ende1 and (not Endereco(5))) , saida => Dado_Lido(0));	


SW9 :  entity work.buffer_3_state_1porta
        port map(entrada => SW(9), habilita => (Leitura and Hab_Bloco5 and Hab_Ende2 and (not Endereco(5))) , saida => Dado_Lido(0));


-- Debounce Botões
detector_KEY0: work.edgeDetector(bordaSubida) 
			port map (clk => CLOCK_50, entrada => (not KEY(0)), saida => Detector_FF0_Saida);
			
detector_KEY1: work.edgeDetector(bordaSubida) 
			port map (clk => CLOCK_50, entrada => (not KEY(1)), saida => Detector_FF1_Saida);
			
detector_KEY2: work.edgeDetector(bordaSubida) 
			port map (clk => CLOCK_50, entrada => (not KEY(2)), saida => Detector_FF2_Saida);
			
detector_KEY3: work.edgeDetector(bordaSubida) 
			port map (clk => CLOCK_50, entrada => (not KEY(3)), saida => Detector_FF3_Saida);


-- FlipFlop dos Botoes
FF_Botao0 : entity work.FlipFlop
          port map (DIN => '1', DOUT => FF_Botao0_Saida, ENABLE => '1', CLK => Detector_FF0_Saida, RST => (Endereco(0) and Endereco(1) and Endereco(2) and Endereco(3) and Endereco(4) and Endereco(5) and Endereco(6) and Endereco(7) and Endereco(8) and Escrita));

FF_Botao1 : entity work.FlipFlop
          port map (DIN => '1', DOUT => FF_Botao1_Saida, ENABLE => '1', CLK => Detector_FF1_Saida, RST => ((not Endereco(0)) and Endereco(1) and Endereco(2) and Endereco(3) and Endereco(4) and Endereco(5) and Endereco(6) and Endereco(7) and Endereco(8) and Escrita));

FF_Botao2 : entity work.FlipFlop
          port map (DIN => '1', DOUT => FF_Botao2_Saida, ENABLE => '1', CLK => Detector_FF2_Saida, RST => (Endereco(0) and (not Endereco(1)) and Endereco(2) and Endereco(3) and Endereco(4) and Endereco(5) and Endereco(6) and Endereco(7) and Endereco(8) and Escrita));
			 
FF_Botao3 : entity work.FlipFlop
          port map (DIN => '1', DOUT => FF_Botao3_Saida, ENABLE => '1', CLK => Detector_FF3_Saida, RST => (( not Endereco(0)) and (not Endereco(1)) and Endereco(2) and Endereco(3) and Endereco(4) and Endereco(5) and Endereco(6) and Endereco(7) and Endereco(8) and Escrita));
			 

-- Buffer Botoes
Botao0 :  entity work.buffer_3_state_1porta
        port map(entrada => FF_Botao0_Saida, habilita => Hab_Key0, saida => Dado_Lido(0));	


Botao1 :  entity work.buffer_3_state_1porta
        port map(entrada => FF_Botao1_Saida, habilita => Hab_Key1, saida => Dado_Lido(0));
		  
Botao2 :  entity work.buffer_3_state_1porta
        port map(entrada => FF_Botao2_Saida, habilita => Hab_Key2, saida => Dado_Lido(0));	


Botao3 :  entity work.buffer_3_state_1porta
        port map(entrada => FF_Botao3_Saida, habilita => Hab_Key3, saida => Dado_Lido(0));

BotaoReset :  entity work.buffer_3_state_1porta
        port map(entrada => FPGA_RESET_N, habilita => (Leitura and Hab_Bloco5 and Hab_Ende4 and Endereco(5)) , saida => Dado_Lido(0));
		 
		
-- Habilitando leitura botoes
Hab_Key0 <= (Leitura and Hab_Bloco5 and Hab_Ende0 and Endereco(5));
Hab_Key1 <= (Leitura and Hab_Bloco5 and Hab_Ende1 and Endereco(5));
Hab_Key2 <= (Leitura and Hab_Bloco5 and Hab_Ende2 and Endereco(5));
Hab_Key3 <= (Leitura and Hab_Bloco5 and Hab_Ende3 and Endereco(5));
		
-- A ligacao dos LEDs:
LEDR (8) <= LED8_unico;
LEDR (9) <= LED9_unico;
LEDR (7 downto 0) <= LED_conjunto;

-- TESTE
--LEDR (8) <= FF_Botao0_Saida;

-- Escrevendo no Display 7 segmentos
HEX0 <= HEX0_Saida;
HEX1 <= HEX1_Saida;
HEX2 <= HEX2_Saida;
HEX3 <= HEX3_Saida;
HEX4 <= HEX4_Saida;
HEX5 <= HEX5_Saida;

end architecture;