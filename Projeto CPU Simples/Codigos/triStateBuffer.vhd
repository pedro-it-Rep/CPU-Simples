library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Declaração das variaveis que serão usadas para o bom funcionamento do componente
entity triStateBuffer is

	port (entradaTriState: in std_logic_vector(0 to 7); -- Declaração do vetor de entrada
			controleTriState: in std_logic; -- Declaração do controle de entrada/saida do registrador
			saidaTriState: out std_logic_vector(0 to 7)); -- Declaração do vetor de saida do vetor
			
end triStateBuffer;


-- Declaração do funcionamento do TriState
architecture TSB of triStateBuffer is

begin

	process(controleTriState, entradaTriState)
	
	begin
	
		if (controleTriState = '1') then -- Se o controle for 1, oque foi recebido pode sair do componente
		
			saidaTriState <= entradaTriState; 
			
		else
		
			saidaTriState <= "ZZZZZZZZ"; -- Caso contrario a gente zera a saida para não ocorrer erros
			
		end if;
		
	end process;
	
end TSB;