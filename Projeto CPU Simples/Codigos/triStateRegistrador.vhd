library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity triStateRegistrador is
	port (entradaTR: in std_logic_vector(0 to 7);
	
			clock: in std_logic;
			
			-- Verifica a entrada e saida do auxiliar
			enablein: in std_logic; 
			enableout: in std_logic;
			
			reset: in std_logic;
			
			saidaTR: out std_logic_vector(0 to 7));
			
end triStateRegistrador;

architecture aux of triStateRegistrador is

	component registrador_8 
	
		port (entradaReg: in std_logic_vector(0 to 7);
			clock: in std_logic;
			enableReg: in std_logic;
			resetReg: in std_logic;
			saidaReg: out std_logic_vector(0 to 7));
			
	end component;
	
	component triStateBuffer
	
		port (entradaTriState: in std_logic_vector(0 to 7);
			controleTriState: in std_logic;
			saidaTriState: out std_logic_vector(0 to 7));
			
	end component;
	
	signal med: std_logic_vector(0 to 7);
	
begin
	reg: registrador_8 port map (entradaTR, clock, enablein, reset, med);
	
	tri: triStateBuffer port map (med, enableout, saidaTR);
	
end aux;