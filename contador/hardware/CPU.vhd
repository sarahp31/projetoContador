library ieee;
use ieee.std_logic_1164.all;

entity CPU is
  -- Total de bits das entradas e saidas
  generic ( larguraDados : natural := 8;
		  larguraEnderecoROM : natural := 9
        --simulacao : boolean := TRUE -- para gravar na placa, altere de TRUE para FALSE
  );
  port   (
	 Instrucao_IN : in std_logic_vector(12 downto 0);
	 Endereco_Dados : out std_logic_vector(8 downto 0);
	 Escrita_Dados : out std_logic_vector(7 downto 0);
	 Leitura_Dados : in std_logic_vector(7 downto 0);
	 Endereco_ROM : out std_logic_vector(8 downto 0);
	 Wr : out std_logic;
	 Rd : out std_logic;
	 Clock : in std_logic
  );
end entity;


architecture arquitetura of CPU is

  signal sainda_MUX : std_logic_vector (larguraDados-1 downto 0);
  signal Dado_Memoria : std_logic_vector (larguraDados-1 downto 0);
  signal REGA_Saida : std_logic_vector (larguraDados-1 downto 0);
  signal Saida_ULA : std_logic_vector (larguraDados-1 downto 0);
  signal Sinais_Controle : std_logic_vector (12 downto 0);
  signal Endereco : std_logic_vector (larguraEnderecoROM - 1 downto 0);
  signal proxPC : std_logic_vector (larguraEnderecoROM -1 downto 0);
  signal Chave_Operacao_ULA : std_logic;
  signal CLK : std_logic;
  signal SelMUX : std_logic_vector(1 downto 0);
  signal SelMUX_PC : std_logic_vector (1 downto 0);
  signal Habilita_A : std_logic;
  signal Reset_A : std_logic;
  signal Operacao_ULA : std_logic_vector (1 downto 0);
  signal Hab_LeituraMemoria : std_logic;
  signal Hab_EscritaMemoria : std_logic;
  signal Saida_MemoriaInst : std_logic_vector (12 downto 0);
  signal saida_MUX_PC : std_logic_vector (larguraEnderecoROM-1 downto 0);
  signal Ender_Retorno : std_logic_vector (larguraEnderecoROM-1 downto 0);
  signal Flag : std_logic;
  signal Flag_Result : std_logic;
  signal HabEcrita_Retorno : std_logic;

begin

-- Instanciando os componentes:

-- os IN da CPU
CLK <=  Clock;
Saida_MemoriaInst <= Instrucao_IN;
Dado_Memoria <= Leitura_Dados;
-- os out do CPU:
Endereco_Dados <= Saida_MemoriaInst(8 downto 0);
Escrita_Dados <= REGA_Saida;
Endereco_ROM <= Endereco;
Wr <= Sinais_Controle(0);
Rd <= Sinais_Controle(1);

-- BUSCA DE INSTRUCAO
-- Program Counter.
PC : entity work.registradorGenerico   generic map (larguraDados => larguraEnderecoROM)
          port map (DIN => saida_MUX_PC, DOUT => Endereco, ENABLE => '1', CLK => CLK, RST => '0');

-- Incrementa a linha da memoria ROM			 
incrementaPC :  entity work.somaConstante  generic map (larguraDados => larguraEnderecoROM, constante => 1)
        port map( entrada => Endereco, saida => proxPC);
		  

--  MUX de selecao de endereco memoria.
MUXProxPC :  entity work.muxGenerico4x1  generic map (larguraDados => larguraEnderecoROM)
        port map( entradaA_MUX => proxPC,
                 entradaB_MUX =>  Saida_MemoriaInst(8 downto 0),
					  entradaC_MUX => Ender_Retorno,
					  entradaD_MUX =>  "000000000",
                 seletor_MUX => SelMUX_PC,
                 saida_MUX => saida_MUX_PC);
					  
-- Endereco Retorno.
ENDRetorno: entity work.registradorGenerico   generic map (larguraDados => larguraEnderecoROM)
          port map (DIN => proxPC, DOUT => Ender_Retorno, ENABLE => HabEcrita_Retorno, CLK => CLK, RST => '0');
			 

-- Logica de Desvio
LOGICDESVIO : entity work.logicaDesvio
          port map (flag => Flag_Result, jeq => Sinais_Controle(8), jsr => Sinais_Controle(9), ret => Sinais_Controle(10), jmp => Sinais_Controle(11), selmux=> SelMUX_PC);			 

			 
-- DECODIFICACAO


-- Decotificador de instrucao
DECODER : entity work.decoderInstru
          port map (opcode => Saida_MemoriaInst(12 downto 9), saida => Sinais_Controle);
			 

-- Mux de valor imediato, endereco RAM e destino JMP.
--MUX1 :  entity work.muxGenerico2x1  generic map (larguraDados => larguraDados)
--        port map( entradaA_MUX => Dado_Memoria,
--                 entradaB_MUX =>  Saida_MemoriaInst(7 downto 0),
--                 seletor_MUX => SelMUX,
--                 saida_MUX => sainda_MUX);
--					  
MUX1 :  entity work.muxGenerico4x1  generic map (larguraDados => larguraDados)
        port map( entradaA_MUX => Dado_Memoria,
                 entradaB_MUX =>  Saida_MemoriaInst(7 downto 0),
					  entradaC_MUX => x"01",
					  entradaD_MUX =>  x"00",
                 seletor_MUX => SelMUX,
                 saida_MUX => sainda_MUX);
					  					  
-- EXECUCAO 

-- ULA:
ULA1 : entity work.ULASomaSub  generic map(larguraDados => larguraDados)
          port map (entradaA => REGA_Saida, entradaB => sainda_MUX, saida => Saida_ULA, flag => Flag, seletor => Operacao_ULA);
			 

-- Acumulador.
REGA : entity work.registradorGenerico   generic map (larguraDados => larguraDados)
          port map (DIN => Saida_ULA, DOUT => REGA_Saida, ENABLE => Habilita_A, CLK => CLK, RST => '0');


			 
-- ESCRITA E LEITURA MEMORIA		 

-- O port map completo do Acumulador de comparação.
FLAG1 : entity work.FlipFlop
          port map (DIN => Flag, DOUT => Flag_Result, ENABLE => Sinais_Controle(2), CLK => CLK, RST => '0');



			 

HabEcrita_Retorno <= Sinais_Controle(12);
SelMUX <= Sinais_Controle(7 downto 6);
Habilita_A <= Sinais_Controle(5);
Operacao_ULA <= Sinais_Controle(4 downto 3);


-- A ligacao dos LEDs:
--LEDR (9) <= SelMUX;
--LEDR (8) <= Habilita_A;
--LEDR (7) <= Reset_A;
--LEDR (6) <= Operacao_ULA(1);
--LEDR (5) <= Operacao_ULA(0);
--LEDR (4) <= '0';    -- Apagado.
--LEDR (7 downto 0) <= REGA_Saida;

--PC_OUT <= Endereco;

--TestSaida_ROM <= Saida_MemoriaInst;

--Palavra_controle <= Sinais_Controle;

end architecture;