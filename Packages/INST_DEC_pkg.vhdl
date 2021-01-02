library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;
	use 	ieee.math_real.all;

use work.CPU_pkg.all;

package INST_DEC_pkg is

	type CODE_TYPE is array(NUM_MICRO_CYC downto 0) of std_logic_vector(ctrl_bus_width - 1 downto 0);

	-- NO Operation => Advances Program Counter and waits for the Rest of the Command Cycle
    constant NOP_INST   : std_logic_vector(OPCODE_BITS - 1 downto 0) := (others => '0');
	constant NOP_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Move
	constant MOV_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (0 => '1',others => '0');
	constant MOV_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Jump Equals Zero => Check if Zero Flag is set and jump to Address
	constant JEZ_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (1 => '1',others => '0');
	constant JEZ_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Jump Carry Overflow=> Check if Carry Flag is set and jump to Address
	constant JCO_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (1 downto 0 => '1',others => '0');
	constant JCO_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Jump Sign Negative=> Check if Negative Flag is set and jump to Address
	constant JSN_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 => '1',others => '0');
	constant JSN_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Add
	constant ADD_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 or 0 => '1',others => '0');
	constant ADD_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Subtract
	constant SUB_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (2 downto 0 => '1',others => '0');
	constant SUB_CODES	: CODE_TYPE := (others => (others => 'Z'));

	-- Shift Left
	constant SHL_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 => '1',others => '0');
	constant SHL_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Shift Right
	constant SHR_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 or 0 => '1',others => '0');
	constant SHR_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Two's Complement
	constant TWC_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 or 1 => '1',others => '0');
	constant TWC_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Wait For Interrupt => Do Nothing (not even advance Program Counter)
	constant WFI_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 => '1',1 downto 0 => '1',others => '0');
	constant WFI_CODES	: CODE_TYPE := (others => (others => 'Z'));

end package INST_DEC_pkg;

package body INST_DEC_pkg is

end package body INST_DEC_pkg;
