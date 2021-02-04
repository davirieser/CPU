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
		INST_ID		: std_logic_vector(OPCODE_BITS + NUM_FLAGS - 1 downto 0);
		INST_CODES	: CTRL_CODE_T;
		EXT_CODES	: EXT_CODE_T;
		ALU_CODES	: ALU_CTRL_T;
	end record INSTRUCTION_T;

	type INSTRUCTION_SET_T is array(NUM_OPCODES - 1 downto 0) of INSTRUCTION_T;
	----------------------------------------------------------------------------
	type INSTRUCTION_SET_NAMES is array(NUM_OPCODES - 1 downto 0) of string(1 to 5);
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
	-- Ignores Status-Flags
	constant NOP_ID		: std_logic_vector(OPCODE_BITS + NUM_FLAGS - 1 downto 0)
		:= (NUM_FLAGS - 1 downto 0 => 'X',others => '0');
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

	-- Ignore Instruction => doesn't change anything
	constant IGN_INST	: INSTRUCTION_T := (
		INST_ID => (others => 'U'),
		INST_CODES => (others => (others => 'Z')),
		EXT_CODES => (others => (others => 'Z')),
		ALU_CODES => (others => (others => '0'))
	);

	-- Create Instruction Set
	-- Order of Instruction doesn't matter
	-- Unimplemented Instruction have to be set to NO_INST
	-- Instruction ID's cannot overlap
	constant INST_SET : INSTRUCTION_SET_T := (
		0 => NOP_INSTRUCTION,
		others => IGN_INST
	);
	constant INST_NAMES : INSTRUCTION_SET_NAMES := (
		0 => "NOP  ",
		others => "Undef"
	);

end package INST_DEC_pkg;

package body INST_DEC_pkg is

end package body INST_DEC_pkg;
