library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cpu is 
	port(instruction: in std_logic_vector(0 to 15); -- Vetor que vai receber o valor da instrução
	-- 4 bits - OPCode
	-- 2 bits - Primeiro Operador
	-- 2 bits - Segundo Operador
	-- 8 bits - Valor Imediato
	
	 clock: in std_logic;

	 busview: out std_logic_vector(0 to 7);
	 reg0view: out std_logic_vector(0 to 7);
	 reg1view: out std_logic_vector(0 to 7);
	 reg2view: out std_logic_vector(0 to 7);
	 rg3view: out std_logic_vector(0 to 7));
end cpu;

architecture behavior of cpu is
	signal mbus: std_logic_vector(0 to 7);
	
	signal reg0in, reg0out: std_logic;
	signal reg1in, reg1out: std_logic;
	signal reg2in, reg2out: std_logic;
	signal reg3in, reg3out: std_logic;
	signal regAin: std_logic;
	signal regGin, regGout: std_logic;
	signal regTin, regTout: std_logic;
	
	signal imedIn: std_logic;
	signal immedi: std_logic_vector(0 to 7);
	
	signal r0insid: std_logic_vector(0 to 7);
	signal r1insid: std_logic_vector(0 to 7);
	signal r2insid: std_logic_vector(0 to 7);
	signal r3insid: std_logic_vector(0 to 7);
	 
	signal regAtoULA: std_logic_vector(0 to 7);
	signal ULAtoRegG: std_logic_vector(0 to 7);
	signal ALUOp: std_logic_vector(0 to 1);
	signal master_reset: std_logic;
	
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
	
	component triStateRegistrador
	
		port (entradaTR: in std_logic_vector(0 to 7);
			clock: in std_logic;
			enablein: in std_logic;
			enableout: in std_logic;
			reset: in std_logic;
			saidaTR
			: out std_logic_vector(0 to 7));
	end component;
	
	component ULA
	
		port (registrador1: in std_logic_vector(0 to 7);
		
			registrador2: in std_logic_vector(0 to 7);
			operacao:	in std_logic_vector(0 to 1);
			
			saidaULA: out std_logic_vector(0 to 7));
			
	end component;
	
	component UnidadeControle
	
		port (instrucao: in std_logic_vector(0 to 15);
			clock: in std_logic;
			entradaReg0, saidaReg0: out std_logic; -- Registrador 1
			entradaReg1, saidaReg1: out std_logic; -- Registrador 2
			entradaReg2, saidaReg2: out std_logic; -- Registrador 3
			entradaReg3, saidaReg3: out std_logic; -- Registrador 4
			aux1: out std_logic;
			entradaAux0, saidaAux0: out std_logic; -- Registrador auxiliar 1, usado para fazer o XCHG
			entradaAux2, saidaAux2: out std_logic; -- Registrador auxiliar 3, usado para saida da ULA
			imediato: out std_logic;
			ALUOp:  out std_logic_vector(0 to 1));
			
	end component;
begin
	busview <= mbus;
	reg0view <= r0insid;
	reg1view <= r1insid;
	reg2view <= r2insid;
	rg3view <= r3insid;
	
	process (instruction)
	begin
		if (instruction(8) = '0') then 
			immedi <=  instruction(8 to 15);
		else 
			immedi <=  instruction(8 to 15);
		end if;
	end process;
	
	imed: triStateBuffer port map (immedi, imedIn, mbus);
	
	reg0: registrador_8 port map (mbus, clock, reg0in, master_reset, r0insid);
	tri0: triStateBuffer port map (r0insid, reg0out, mbus);
	reg1: registrador_8 port map (mbus, clock, reg1in, master_reset, r1insid);
	tri1: triStateBuffer port map (r1insid, reg1out, mbus);
	reg2: registrador_8 port map (mbus, clock, reg2in, master_reset, r2insid);
	tri2: triStateBuffer port map (r2insid, reg2out, mbus);
	reg3: registrador_8 port map (mbus, clock, reg3in, master_reset, r3insid);
	tri3: triStateBuffer port map (r3insid, reg3out, mbus);
	
--	reg0: triregister port map (mbus, clock, reg0in, reg0out, master_reset, mbus);
--	reg1: triregister port map (mbus, clock, reg1in, reg1out, master_reset, mbus);
--	reg2: triregister port map (mbus, clock, reg2in, reg2out, master_reset, mbus);
--	reg3: triregister port map (mbus, clock, reg3in, reg3out, master_reset, mbus);

	regA: registrador_8 port map (mbus, clock, regAin, master_reset, regAtoULA);
	regG: triStateRegistrador port map (ULAtoRegG, clock, regGin, regGout, master_reset, mbus);
	regT: triStateRegistrador port map (mbus, clock, regTin, regTout, master_reset, mbus);
	alu: ULA port map (regAtoULA, mbus, ALUOp, ULAtoRegG);
	
	unit: UnidadeControle port map (instruction, clock, reg0in, reg0out, reg1in, reg1out, reg2in, reg2out, reg3in, reg3out, regAin, regGin, regGout, regTin, regTout, imedIn, ALUOp);
end behavior;