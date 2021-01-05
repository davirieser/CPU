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

	-- Move from Memory to Register A
	constant MOVA_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (0 => '1',others => '0');
	constant MOVA_CODES	: CODE_TYPE
		:= (0 => PRC_INCR,
			1 => (MEM_RD_B => '1',REG_AIN_B => '1',others => 'Z'),
			others => (others => 'Z')
		);

	-- Move from Memory to Register A
	constant MOVB_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (0 => '1',others => '0');
	constant MOVB_CODES	: CODE_TYPE
		:= (0 => PRC_INCR,
			1 => (MEM_RD_B => '1',REG_BIN_B => '1',others => 'Z'),
			others => (others => 'Z')
		);

	-- Store Value from Register A in Memory
	constant STOA_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (0 => '1',others => '0');
	constant STOA_CODES	: CODE_TYPE
		:= (0 => PRC_INCR,
			1 => (MEM_WRI_B => '1',REG_AOU_B => '1',others => 'Z'),
			others => (others => 'Z')
		);

	-- Store Value from Register B in Memory
	constant STOB_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (0 => '1',others => '0');
	constant STOB_CODES	: CODE_TYPE
		:= (0 => PRC_INCR,
			1 => (MEM_WRI_B => '1',REG_BOU_B => '1',others => 'Z'),
			others => (others => 'Z')
		);

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
		:= (2 | 0 => '1',others => '0');
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
		:= (3 | 0 => '1',others => '0');
	constant SHR_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Two's Complement
	constant TWC_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 | 1 => '1',others => '0');
	constant TWC_CODES	: CODE_TYPE := (0 => PRC_INCR,others => (others => 'Z'));

	-- Wait For Interrupt => Do Nothing (not even advance Program Counter)
	constant WFI_INST	: std_logic_vector(OPCODE_BITS - 1 downto 0)
		:= (3 => '1',1 downto 0 => '1',others => '0');
	constant WFI_CODES	: CODE_TYPE := (others => (others => 'Z'));

end package INST_DEC_pkg;

package body INST_DEC_pkg is

end package body INST_DEC_pkg;
