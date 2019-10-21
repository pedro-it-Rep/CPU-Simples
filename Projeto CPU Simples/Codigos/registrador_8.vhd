library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Declaração das variaveis que serão usadas para o bom funcionamento do componente
entity registrador_8 is

	port (entradaReg: in std_logic_vector(0 to 7); -- Declaração do vetor de entrada
	
			clock: in std_logic; -- Clock de controle
			enableReg: in std_logic; -- Permite o funcionamento do registrador
			resetReg: in std_logic; -- Reset do registrador se necessario
			saidaReg: out std_logic_vector(0 to 7)); -- Declaração do vetor de saida do vetor
			
end registrador_8;

architecture registrador8B of registrador_8 is

begin

	process(clock, resetReg)
	
	begin
		if (clock'event and clock = '1' and enableReg = '1') then -- Se for a subida do clock e o controle do registrador for 1, o conteudo sai do registrador
		
			saidaReg <= entradaReg;
			
		end if;
		
		if (resetReg = '1') then -- Se o reset do registrador for 1, todo o conteudo do registrador é apagado
		
			saidaReg <= "00000000";
			
		end if;
		
	end process;
	
end registrador8B; 