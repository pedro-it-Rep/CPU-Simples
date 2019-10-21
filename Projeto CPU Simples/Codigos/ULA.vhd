library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Declaração das variaveis que serão usadas
entity ULA is 

	port (registrador1: in std_logic_vector(0 to 7); -- Entrada 1 da ULA
	
			registrador2: in std_logic_vector(0 to 7); -- Entrada 2 da ULA
			operacao:	in std_logic_vector(0 to 1); -- Responsavel por verificar qual a operacao desejada
			saidaULA: out std_logic_vector(0 to 7)); -- Saida da ULA
			
end ULA;

architecture ALU of ULA is 

begin

	process(registrador1, registrador2, operacao)
	
	begin
	
		case operacao is -- Switch Case para verificar qual vai ser a operacao a ser feita
		
			when "00" => saidaULA <= registrador1 + registrador2; -- Se for 00, soma
			
			when "01" => saidaULA <= registrador1 - registrador2; -- Se for 01, subtrai
			 
			when "10" => saidaULA <= registrador1 and registrador2; -- Se for 10, faz o AND
			
			when "11" => saidaULA <= registrador1 or registrador2; -- Se for 11, faz o OR
			
			when others => saidaULA <= "00000000";
			
		end case;
		
	end process;
	
end ALU;