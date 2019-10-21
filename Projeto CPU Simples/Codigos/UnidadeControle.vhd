library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


-- Declaração das variaveis que serão usadas para o funcionamento da Unidade de Controle
entity UnidadeControle is


	port (instrucao: in std_logic_vector(0 to 15); -- Vetor que vai receber o valor da instrução
	-- 4 bits - OPCode
	-- 2 bits - Primeiro Operador
	-- 2 bits - Segundo Operador
	-- 8 bits - Valor Imediato
	
		clock: in std_logic; -- Controle da subida do clock
		
		entradaReg0, saidaReg0: out std_logic; -- Registrador 1
		entradaReg1, saidaReg1: out std_logic; -- Registrador 2
		entradaReg2, saidaReg2: out std_logic; -- Registrador 3
		entradaReg3, saidaReg3: out std_logic; -- Registrador 4
		
		aux1: out std_logic; -- Registrador auxiliar 2, usado para entrada da ULA
		
		entradaAux0, saidaAux0: out std_logic; -- Registrador auxiliar 1, usado para fazer o XCHG
		
		entradaAux2, saidaAux2: out std_logic; -- Registrador auxiliar 3, usado para saida da ULA
		
		imediato: out std_logic; -- Variavel que vai receber o valor imediato
		
		ALUOp:  out std_logic_vector(0 to 1)); -- Responsavel pelo nosso OPCode
		
end UnidadeControle;

-- Declaração do funcionamento da unidade de controle
architecture controle of UnidadeControle is

	type estadosUC is (esperandoOperacao, mov, movi, xchg, xchg1, xchg2, op0, op1, op2); -- Verifica os estados da unidade de controle para poder fazer a operação
	
	signal estado: estadosUC := esperandoOperacao; -- Define o estado inicial da variavel
	
	signal opcode: std_logic_vector(0 to 3); -- Vetor que vai receber os valores do nosso OPCode
	
	signal r1, r2, r3: std_logic_vector(0 to 1); -- 
	
begin

	opcode <= instrucao(0 to 3); -- OPCode se encontra nos 4 primeiros numeros da instrucao
	r1 <= instrucao(4 to 5); -- Valor do r* se encontra nos 2 seguintes numeros da instrucao
	r2 <= instrucao(6 to 7); -- Valor do r* se encontra nos 2 seguintes numeros da instrucao
	r3 <= instrucao(8 to 9); -- Valor do r* se encontra nos 2 seguintes numeros da instrucao
	
	process(clock)
	
	begin
	
		if (clock'event and clock = '0') then -- Se ocorrer um evento do clock, na descida do clock
		
			case estado is
			
				when esperandoOperacao => -- Limpa todo o conteudo dos componentes para evitar erros inesperados
				
					entradaReg0 <= '0';
					saidaReg0 <= '0';
					entradaReg1 <= '0';
					saidaReg1 <= '0';
					entradaReg2 <= '0';
					saidaReg2 <= '0';
					entradaReg3 <= '0';
					saidaReg3 <= '0';
					aux1 <= '0';
					entradaAux2 <= '0';
					saidaAux2 <= '0';
					entradaAux0 <= '0';
					saidaAux0 <= '0';
					imediato <= '0';
					
					case opcode is -- Se o OPCode for correspondente com algum valor abaixo, efetua a operação
					
						when "0000" => estado <= mov;
						when "0001" => estado <= movi;
						when "0010" => estado <= xchg;
						when "0011" => estado <= op0; -- ADDI
						when "0100" => estado <= op0; -- SUBI
						when "0101" => estado <= op0; -- ANDI
						when "0110" => estado <= op0; -- ORI
						when "0111" => estado <= op0; -- ADD
						when "1000" => estado <= op0; -- SUB
						when "1001" => estado <= op0; -- AND
						when "1010" => estado <= op0; -- OR
						
						when others => estado <= esperandoOperacao; -- Se não for nenhum deles, apenas espera uma entrada valida
						
					end case;
					
				when mov => --  -------------- MOV Ri, Rj --------------
				
					case r2 is -- Libera o conteudo do Rj, jogando no barramento
					
						when "00" => saidaReg0 <= '1';
						when "01" => saidaReg1 <= '1';
						when "10" => saidaReg2 <= '1';
						when "11" => saidaReg3 <= '1';
						when others => estado <= esperandoOperacao;
						
					end case;
					
					case r1 is -- Permite que o Ri receba o conteudo que está no barramento
					
						when "00" => entradaReg0 <= '1';
						when "01" => entradaReg1 <= '1';
						when "10" => entradaReg2 <= '1';
						when "11" => entradaReg3 <= '1';
						
						when others => estado <= esperandoOperacao;
						
					end case;
					
					estado <= esperandoOperacao;
					
				when movi => --  -------------- MOVi Ri, Rj --------------
				
					imediato <= '1'; -- Coloca o valor do imediato no barramento
					
					case r1 is -- Permite que os registradores recebam o valor que está no barramento
					
						when "00" => entradaReg0 <= '1';
						when "01" => entradaReg1 <= '1';
						when "10" => entradaReg2 <= '1';
						when "11" => entradaReg3 <= '1';
						when others => estado <= esperandoOperacao;
						
					end case;
					
					estado <= esperandoOperacao;
					
				when xchg => --  -------------- XCHG Ri, Rj --------------
				
					entradaAux0 <= '1'; -- Abre a entrada do registrador auxiliar
					
					case r1 is -- Joga o valor dos registradores no barramento, pemitindo que ele entre no auxiliar
					
						when "00" => saidaReg0 <= '1'; 
						when "01" => saidaReg1 <= '1';
						when "10" => saidaReg2 <= '1';
						when "11" => saidaReg3 <= '1';
						
						when others => estado <= esperandoOperacao;
						
					end case;
					
					estado <= xchg1; -- Prepara o programa para a segunda etapa do XCHG
					
				when xchg1 => -- Fecha a saida dos registradores, evitando que o conteudo não passe direto (vá direto para o barramento)
				-- E evita que a entrada do auxiliar receba o conteudo que esta no barramento
				
					entradaAux0 <= '0';
					saidaReg0 <= '0';
					saidaReg1 <= '0';
					saidaReg2 <= '0';
					saidaReg3 <= '0';
					
					case r1 is -- Ri recebe o conteudo que estava no barramento (saida do auxiliar 0)
					
						when "00" => entradaReg0 <= '1';
						when "01" => entradaReg1 <= '1';
						when "10" => entradaReg2 <= '1';
						when "11" => entradaReg3 <= '1';
						
						when others => estado <= esperandoOperacao;
						
					end case;
					
					case r2 is  -- Rj libera seu conteudo no barramento
					
						when "00" => saidaReg0 <= '1';
						when "01" => saidaReg1 <= '1';
						when "10" => saidaReg2 <= '1';
						when "11" => saidaReg3 <= '1';
						when others => estado <= esperandoOperacao;
						
					end case;
					
					estado <= xchg2; -- Prepara o programa para a ultima etapa do XCHG
					
				when xchg2 =>
				
					saidaAux0 <= '1'; -- Abre a saida do auxiliar
					
					case r1 is -- Ri fecha as entradas do registrador, evitando que ele recebe o conteudo que está no registrador
					
						when "00" => entradaReg0 <= '0';
						when "01" => entradaReg1 <= '0';
						when "10" => entradaReg2 <= '0';
						when "11" => entradaReg3 <= '0';
						
						when others => estado <= esperandoOperacao;
						
					end case;
					
					
					-- Fecha todas as saidas para que nenhum conteudo "vaze" para o barramento
					saidaReg0 <= '0';
					saidaReg1 <= '0';
					saidaReg2 <= '0';
					saidaReg3 <= '0';
					
					case r2 is -- Rj abre novamente a entrada dos registradores para que ele possa receber o resultado desejado
					
						when "00" => entradaReg0 <= '1';
						when "01" => entradaReg1 <= '1';
						when "10" => entradaReg2 <= '1';
						when "11" => entradaReg3 <= '1';
						
						when others => estado <= esperandoOperacao;
						
					end case;
					
					estado <= esperandoOperacao;
					
					-- ------------ Parte Aritimetica --------------
					
				when op0 => 
				
					aux1 <= '1'; -- Abre a entrada do registrador auxiliar da entrada da ULA
					
					case r2 is -- Abre a saida dos registradores, permitindo que o resultado va para a ULA
					
						when "00" => saidaReg0 <= '1';
						when "01" => saidaReg1 <= '1';
						when "10" => saidaReg2 <= '1';
						when "11" => saidaReg3 <= '1';
						when others => estado <= esperandoOperacao;
						
					end case;
					
					estado <= op1; -- Estado recebe o segundo operador para saber qual é
					
				when op1 => 
				
					aux1 <= '0'; -- Fecha a entrada do registrador da ULA
					-- Fecha a saida dos registradores para que a ULA não recebe nada indesejado
					saidaReg0 <= '0';
					saidaReg1 <= '0';
					saidaReg2 <= '0';
					saidaReg3 <= '0';
					
					if (opcode > "0110") then -- Se for um codigo maior que os OPCode definidos, significa que vai ser uma operação basica
					
						case r3 is  -- Conteudo dos registradores irão para o barramento
						
							when "00" => saidaReg0 <= '1';
							when "01" => saidaReg1 <= '1';
							when "10" => saidaReg2 <= '1';
							when "11" => saidaReg3 <= '1';
							when others => estado <= esperandoOperacao;
							
						end case;
						
					else 
					
						-- Caso contrario será uma conta com valor imediato
						imediato <= '1'; -- Abre a saida imediata
						
					end if;
					
					case opcode is 
						-- ADD e ADDI
						when "0011" => ALUOp <= "00"; -- ADDI
						when "0111" => ALUOp <= "00"; -- ADD
						
						-- SUB e SUBI
						when "0100" => ALUOp <= "01"; -- SUBI
						when "1000" => ALUOp <= "01"; -- SUB
						
						-- AND e ANDI
						when "0101" => ALUOp <= "10"; -- ANDI
						when "1001" => ALUOp <= "10"; -- AND
						
						-- OR e ORI
						when "0110" => ALUOp <= "11"; -- ORI
						when "1010" => ALUOp <= "11"; -- OR
						
						when others => ALUOp <= "ZZ";
						
					end case;
					
					entradaAux2 <= '1'; -- Após efetuar a conta, a entrada do registrador auxiliar para saida da ULA é aberto
					estado <= op2;
					
				when op2 => -- Fecha a saida dos registradores para evitar erros
				
					saidaReg0 <= '0';
					saidaReg1 <= '0';
					saidaReg2 <= '0';
					saidaReg3 <= '0';
					entradaAux2 <= '0';
					imediato <= '0';
					
					case r1 is -- Abre a entrada dos registradores para que ele receba o conteudo da operação feita
					
						when "00" => entradaReg0 <= '1';
						when "01" => entradaReg1 <= '1';
						when "10" => entradaReg2 <= '1';
						when "11" => entradaReg3 <= '1';
						when others => estado <= esperandoOperacao;
						
					end case;
					
					saidaAux2 <= '1'; -- Libera o conteudo da conta no barramento
					
					estado <= esperandoOperacao;
					
				when others =>
				
					estado <= esperandoOperacao; -- Efetuando a conta
					
			end case;
			
		end if;
		
	end process;
	
end controle;