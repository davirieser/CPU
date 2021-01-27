library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;
	use 	ieee.math_real.all;

use work.CPU_pkg.all;

package INST_DEC_pkg is

	-- Assembly Commands --------------------------------------------------
	-- Result are always stored in Register A if not otherwise specified.
	-- --------------------------------------------------------------------
	-- ADC - ADD but with "Carry In Flag" set
	-- ADD - ADD Registers A and B
	-- AND - Logical AND of Registers A and B
	-- CALL - Subroutine => Push Return Address on Stack and
	-- 		  Override Program Counter
	-- CLI - Clear Interrupt Enable Flag
	-- CMP - SUB Register A and B but ignore Result and set Flags
	-- DEC - Decrement Memory-, or Register-Value
	-- INC - Increment Memory-, or Register-Value
	-- INT - Call Interrupt
	-- IRET - Interrupt Return
	--          => Program Counter = POP and clear INT-Flag
	-- JMP - Unconditional Jump
	-- LDA - Load Memory Address into Register A
	-- LDB - Load Memory Address into Register B
	-- MOV - Move Values in Memory
	-- NEG - Negate Register A (Two's Complement)
	-- NOP - No Operation
	-- OR - Logical OR of Registers A and B
	-- POP - Get Top Value from Stack
	-- PUSH - Store Value on the Stack
	-- RET - Return from Subroutine => Program Counter = POP
	-- ROTL - Rotate Register A to the left by Register B
	-- ROTR - Rotate Register A to the right by Register B
	-- SHL - Rotate Register A to the left by Register B
	-- SHR - Rotate Register A to the right by Register B
	-- SBB - Subtract with Borrow Flag active
	-- SUB - Subtract Register B from Register A
	-- STI - Set Interrupt Enable Flag
	-- STO - Store Register A to Memory
	-- TEST - AND but ignore Result and set Flags
	-- XCHG - Swap Values of two operands
	-- XOR - Logical XOR of Registers A and B
	-- --------------------------------------------------------------------

	----------------------------------------------------------------------------
	type CTRL_CODE_T 	is array(NUM_MICRO_CMD - 1 downto 0) of
		std_logic_vector(ctrl_bus_width - 1 downto 0);
	type EXT_CODE_T 	is array(NUM_MICRO_CMD - 1 downto 0) of
		std_logic_vector(ext_bus_width - 1 downto 0);
	type ALU_CTRL_T is array(NUM_MICRO_CMD - 1 downto 0) of
		std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0);
	----------------------------------------------------------------------------
	type INSTRUCTION_T is record
		INST_ID		: std_logic_vector(OPCODE_BITS - 1 downto 0);
		INST_CODES	: CTRL_CODE_T;
		EXT_CODES	: EXT_CODE_T;
		ALU_CODES	: ALU_CTRL_T;
	end record INSTRUCTION_T;

	type INSTRUCTION_SET_T is array(NUM_OPCODES - 1 downto 0) of INSTRUCTION_T;
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- No Operation Vectors
	constant NOP_CTRL_CODE	: std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (others => 'Z');
	constant NOP_ALU_CODE	: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (others => '0');
	constant NOP_EXT_CODE	: std_logic_vector(ext_bus_width - 1 downto 0)
		:= (others => 'Z');
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- NO Operation => Advances Program Counter and fetches next Instruction
	-- Takes two (Master-) Clk Cycles and doesn't modify any Registers
	constant NOP_ID		: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (others => '0');
	constant NOP_CTRL_C	: CTRL_CODE_T := (
		-- Increment Program Counter and fetch next instruction
		0 => (I_PRC_INCR | I_PRC_OUT | I_WF_MEM_RD => '1',others => 'Z'),
		-- Store next Instruction in Instruction Register + Instruction Over
		1 => (I_INST_R_IN | I_INST_OVER => '1',others => 'Z'),
		-- This should theoretically never run but is defined for Safety
		others => NOP_CTRL_CODE
	);
	constant NOP_EXT_C	: EXT_CODE_T := (
		0 => (I_MEM_RD => '1', others => 'Z'),
		others => NOP_EXT_CODE
	);
	constant NOP_ALU_C	: ALU_CTRL_T := (
		others => NOP_ALU_CODE
	);
	----------------------------------------------------------------------------
	constant NOP_INSTRUCTION	: INSTRUCTION_T := (
		INST_ID => NOP_ID,
		INST_CODES => NOP_CTRL_C,
		EXT_CODES => NOP_EXT_C,
		ALU_CODES => NOP_ALU_C
	);
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Move from Memory to Register A
	-- Takes four (Master-)Clk Cycles and modifies Register A
	constant MOVA_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (0 => '1',others => '0');
	constant MOVA_CTRL_C	: CTRL_CODE_T := (
		-- TODO Fetch Operand von Memory
		-- Increment Program Counter and fetch Operand
		0 => (I_PRC_INCR | I_MEM_ARI_L => '1',others => 'Z'),
		-- Store Operand Value in Register A
		1 => (I_MEM_RD | I_REG_AIN => '1',others => 'Z'),
		-- Fetch next Instruction
		2 => (I_PRC_OUT | I_MEM_ARI_L => '1',others => 'Z'),
		-- Store next Instruction in Instruction Register + Instruction Over
		3 => (I_MEM_RD | I_INST_R_IN | I_INST_OVER => '1',others => 'Z'),
		-- This should theoretically never run but is defined for Safety
		others => NOP_CTRL_CODE
	);
	constant NOP_EXT_C	: EXT_CODE_T := (
		0 => (I_MEM_RD => '1', others => 'Z'),
		others => NOP_EXT_CODE
	);
	constant NOP_ALU_C	: ALU_CTRL_T := (
		others => NOP_ALU_CODE
	);
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Move from Memory to Register B
	-- Takes four (Master-)Clk Cycles and modifies Register B
	constant MOVB_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (1 => '1',others => '0');
	constant MOVB_CODES	: CTRL_CODE_T := (
		-- TODO Fetch Operand von Memory
		-- Increment Program Counter and fetch Operand
		0 => (I_PRC_INCR | I_MEM_ARI_L => '1',others => 'Z'),
		-- Store Operand Value in Register A
		1 => (I_MEM_RD | I_REG_BIN => '1',others => 'Z'),
		-- Fetch next Instruction
		2 => (I_PRC_OUT | I_MEM_ARI_L => '1',others => 'Z'),
		-- Store next Instruction in Instruction Register + Instruction Over
		3 => (I_MEM_RD | I_INST_R_IN | I_INST_OVER => '1',others => 'Z'),
		-- This should theoretically never run but is defined for Safety
		others => NOP_CTRL_CODE
	);
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Store Value from Register A in Memory
	constant STOA_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (0 | 1 => '1',others => '0');
	constant STOA_CODES	: CTRL_CODE_T := (
		0 => (I_PRC_INCR => '1',others => 'Z'),
		1 => (I_MEM_WRI => '1',I_REG_AOU => '1',others => 'Z'),
		others => NOP_CTRL_CODE
	);
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Store Value from Register B in Memory
	constant STOB_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 => '1',others => '0');
	constant STOB_CODES	: CTRL_CODE_T := (
		0 => (I_PRC_INCR => '1',others => 'Z'),
		1 => (I_REG_BOU => '1',others => 'Z'),
		others => NOP_CTRL_CODE
	);
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Jump Equals Zero => Check if Zero Flag is set and jump to Address
	constant JEZ_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 | 0 => '1',others => '0');
	constant JEZ_CODES_S	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	constant JEZ_CODES_NS	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Jump Carry Overflow=> Check if Carry Flag is set and jump to Address
	constant JCO_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 | 1 downto 0 => '1',others => '0');
	constant JCO_CODES_S	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	constant JCO_CODES_NS	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Jump Sign Negative=> Check if Negative Flag is set and jump to Address
	constant JSN_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 downto 0 => '1',others => '0');
	constant JSN_CODES_S	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	constant JSN_CODES_NS	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	----------------------------------------------------------------------------

	-- Add
	----------------------------------------------------------------------------
	constant ADD_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 => '1',others => '0');
	constant ADD_CODES	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	constant ADD_ALU_CTRL	: ALU_CTRL_T	:= (others => (others => '0'));
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Subtract
	constant SUB_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 1 => '1',others => '0');
	constant SUB_CODES	: CTRL_CODE_T := (others => NOP_CTRL_CODE);
	constant SUB_ALU_CTRL	: ALU_CTRL_T	:= (others => (others => '0'));
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Shift Left
	constant SHL_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 1 | 0 => '1',others => '0');
	constant SHL_CODES	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	constant SHL_ALU_CTRL	: ALU_CTRL_T	:= (others => (others => '0'));
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Shift Right
	constant SHR_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 2 => '1',others => '0');
	constant SHR_CODES	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	constant SHR_ALU_CTRL	: ALU_CTRL_T	:= (others => (others => '0'));
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Two's Complement
	constant TWC_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 2 | 0 => '1',others => '0');
	constant TWC_CODES	: CTRL_CODE_T := (0 => (I_PRC_INCR => '1',others => 'Z'),others => NOP_CTRL_CODE);
	constant TWC_ALU_CTRL	: ALU_CTRL_T	:= (others => (others => '0'));
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Wait For Interrupt => Do Nothing
	-- 		(not even advance Program Counter / fetch Instruction)
	constant WFI_ID	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 2 | 1 => '1',others => '0');
	constant WFI_CODES	: CTRL_CODE_T := (
		-- No Action in any Micro Cycle
		others => NOP_CTRL_CODE
	);
	----------------------------------------------------------------------------

	constant INST_SET : INSTRUCTION_SET_T := (
		0 => NOP_INSTRUCTION,
		others => NOP_INSTRUCTION
	);

end package INST_DEC_pkg;

package body INST_DEC_pkg is

end package body INST_DEC_pkg;
