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
	-- LD - Load Memory Address into Register
	-- MOV - Move Value from Memory to Register
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

	type CODE_TYPE is array(NUM_MICRO_CMD - 1 downto 0) of std_logic_vector(ctrl_bus_width - 1 downto 0);

	type ALU_CTRL_TYPE is array(NUM_MICRO_CMD - 1 downto 0) of std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0);

	type INSTRUCTION is record
		INST_ID		: std_logic_vector(OPCODE_BITS - 1 downto 0);
		INST_CODES	: CODE_TYPE;
		ALU_CODES	: ALU_CTRL_TYPE;
	end record INSTRUCTION;

	type INST_VECTOR is array(NUM_OPCODES - 1 downto 0) of INSTRUCTION;

	-- TODO
	-- constant INSTRUCTIONS_LUT	: INST_VECTOR;

	constant NOP_CODE			: std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (others => 'Z');
	constant NO_ALU_OPERATION	: ALU_CTRL_TYPE	:= (others => (others => '0'));

	-- NO Operation => Advances Program Counter and waits for the Rest of the Command Cycle
	-- Takes two (Master-)Clk Cycles and doesn't modify any Registers
	constant NOP_INST   : std_logic_vector(OPCODE_BITS - 1 downto 0) := (others => '0');
	constant NOP_CODES	: CODE_TYPE := (
		-- Increment Program Counter and fetch next instruction
		0 => (PRC_INCR_B | PRC_OUT_B | MEM_ARI_B => '1',others => 'Z'),
		-- Store next Instruction in Instruction Register + Instruction Over
		1 => (MEM_RD_B | INST_OVER | INST_R_IN => '1',others => 'Z'),
		-- This should theoretically never run but is defined for Safety
		others => NOP_CODE
	);

	-- Move from Memory to Register A
	-- Takes four (Master-)Clk Cycles and modifies Register A
	constant MOVA_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (0 => '1',others => '0');
	constant MOVA_CODES	: CODE_TYPE := (
		-- TODO Fetch Operand von Memory
		-- Increment Program Counter and fetch Operand
		0 => (PRC_INCR_B | MEM_ARI_B => '1',others => 'Z'),
		-- Store Operand Value in Register A
		1 => (MEM_RD_B | REG_AIN_B => '1',others => 'Z'),
		-- Fetch next Instruction
		2 => (PRC_OUT_B | MEM_ARI_B => '1',others => 'Z'),
		-- Store next Instruction in Instruction Register + Instruction Over
		3 => (MEM_RD_B | INST_R_IN | INST_OVER => '1',others => 'Z'),
		-- This should theoretically never run but is defined for Safety
		others => NOP_CODE
	);

	-- Move from Memory to Register B
	-- Takes four (Master-)Clk Cycles and modifies Register B
	constant MOVB_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (1 => '1',others => '0');
	constant MOVB_CODES	: CODE_TYPE := (
		-- TODO Fetch Operand von Memory
		-- Increment Program Counter and fetch Operand
		0 => (PRC_INCR_B | MEM_ARI_B => '1',others => 'Z'),
		-- Store Operand Value in Register A
		1 => (MEM_RD_B | REG_BIN_B => '1',others => 'Z'),
		-- Fetch next Instruction
		2 => (PRC_OUT_B | MEM_ARI_B => '1',others => 'Z'),
		-- Store next Instruction in Instruction Register + Instruction Over
		3 => (MEM_RD_B | INST_R_IN | INST_OVER => '1',others => 'Z'),
		-- This should theoretically never run but is defined for Safety
		others => NOP_CODE
	);

	-- Store Value from Register A in Memory
	constant STOA_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (0 | 1 => '1',others => '0');
	constant STOA_CODES	: CODE_TYPE := (
		0 => (PRC_INCR_B => '1',others => 'Z'),
		1 => (MEM_WRI_B => '1',REG_AOU_B => '1',others => 'Z'),
		others => NOP_CODE
	);

	-- Store Value from Register B in Memory
	constant STOB_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 => '1',others => '0');
	constant STOB_CODES	: CODE_TYPE := (
		0 => (PRC_INCR_B => '1',others => 'Z'),
		1 => (MEM_WRI_B => '1',REG_BOU_B => '1',others => 'Z'),
		others => NOP_CODE
	);

	-- Jump Equals Zero => Check if Zero Flag is set and jump to Address
	constant JEZ_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 | 0 => '1',others => '0');
	constant JEZ_CODES_S	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);
	constant JEZ_CODES_NS	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);

	-- Jump Carry Overflow=> Check if Carry Flag is set and jump to Address
	constant JCO_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 | 1 downto 0 => '1',others => '0');
	constant JCO_CODES_S	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);
	constant JCO_CODES_NS	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);


	-- Jump Sign Negative=> Check if Negative Flag is set and jump to Address
	constant JSN_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 downto 0 => '1',others => '0');
	constant JSN_CODES_S	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);
	constant JSN_CODES_NS	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);

	-- Add
	constant ADD_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 => '1',others => '0');
	constant ADD_CODES	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);
	constant ADD_ALU_CTRL	: ALU_CTRL_TYPE	:= (others => (others => '0'));

	-- Subtract
	constant SUB_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 1 => '1',others => '0');
	constant SUB_CODES	: CODE_TYPE := (others => NOP_CODE);
	constant SUB_ALU_CTRL	: ALU_CTRL_TYPE	:= (others => (others => '0'));

	-- Shift Left
	constant SHL_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 1 | 0 => '1',others => '0');
	constant SHL_CODES	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);
	constant SHL_ALU_CTRL	: ALU_CTRL_TYPE	:= (others => (others => '0'));

	-- Shift Right
	constant SHR_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 2 => '1',others => '0');
	constant SHR_CODES	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);
	constant SHR_ALU_CTRL	: ALU_CTRL_TYPE	:= (others => (others => '0'));

	-- Two's Complement
	constant TWC_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 2 | 0 => '1',others => '0');
	constant TWC_CODES	: CODE_TYPE := (0 => (PRC_INCR_B => '1',others => 'Z'),others => NOP_CODE);
	constant TWC_ALU_CTRL	: ALU_CTRL_TYPE	:= (others => (others => '0'));

	-- Wait For Interrupt => Do Nothing
	-- 		(not even advance Program Counter / fetch Instruction)
	constant WFI_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 2 | 1 => '1',others => '0');
	constant WFI_CODES	: CODE_TYPE := (
		-- No Action in any Micro Cycle
		others => NOP_CODE
	);

end package INST_DEC_pkg;

package body INST_DEC_pkg is

end package body INST_DEC_pkg;
