library     IEEE;
	use 	IEEE.std_logic_1164.all;
	use 	IEEE.numeric_std.all;
	use 	IEEE.math_real.all;

package CPU_pkg is

    constant clockFrequency : integer   := 2048 * 10E3;
    constant base_clock     : time      := 1.0 sec / clockFrequency;
	constant output_delay	: time 		:= base_clock / 10;

	-- Transmits data from one CPU-Component to another
	constant data_bus_width	: integer	:= 8;
	-- Controls all the internal devices and receives external signals
	constant ctrl_bus_width	: integer	:= 19;
	-- Tells the components which Address should be fetched/written
	constant addr_bus_width	: integer	:= 16;

	----------------------------------------
	-- CONTROL WORDS OVER THE CONTROL-BUS
	----------------------------------------
	-- Bit 0 => Reset
	-- Bit 1 => Clock
	-- Bit 2 => Interrupt Request
	-- Bit 3 => Program Counter Override
	-- Bit 4 => Program Counter Increment
	-- Bit 5 => Program Counter In
	-- Bit 6 => Program Counter Out
	-- Bit 7 => Memory Read
	-- Bit 8 => Memory Write
	-- Bit 9 => Memory Address Register In
	-- Bit 10 => ALU Result OUT
	-- Bit 11 => ALU Flags OUT
	-- Bit 12 => Swap Register A and B
	-- Bit 13 => Status Flags In
	-- Bit 14 => Clear Status Flags
	-- Bit 15 => Register A In
	-- Bit 16 => Register A Out
	-- Bit 17 => Register B In
	-- Bit 18 => Register B Out
	constant RESET_CTL	:	integer	:= 0;
	constant CLOCK_CTL	:	integer := 1;
	constant INT_REQ_B	: 	integer	:= 2;
	constant PRC_OVR_B	: 	integer := 3;
	constant PRC_INCR_B	: 	integer := 4;
	constant PRC_IN_B	: 	integer := 5;
	constant PRC_OUT_B	: 	integer := 6;
	constant MEM_RD_B	: 	integer := 7;
	constant MEM_WRI_B	: 	integer := 8;
	constant MEM_ARI_B	: 	integer := 9;
	constant ALU_RSO_B	: 	integer := 10;
	constant ALU_FLAG_B	: 	integer	:= 11;
	constant SWP_REG_B	: 	integer := 12;
	constant STF_IN_B	: 	integer := 13;
	constant CLR_STF_B	: 	integer := 14;
	constant REG_AIN_B	: 	integer := 15;
	constant REG_AOU_B	: 	integer := 16;
	constant REG_BIN_B	: 	integer := 17;
	constant REG_BOU_B	: 	integer := 18;
	----------------------------------------

	--------------------------------------------------------------------------------------------------
	constant RESET_F	: 	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (RESET_CTL => '1',others => 'Z');
	constant CLOCK_F	: 	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (CLOCK_CTL => '1',others => 'Z');
	constant INT_REQ	: 	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (INT_REQ_B => '1',others => 'Z');
	constant PRC_OVR	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (PRC_OVR_B => '1',others => 'Z');
	constant PRC_INCR	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (PRC_INCR_B => '1',others => 'Z');
	constant PRC_IN		:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (PRC_IN_B => '1',others => 'Z');
	constant PRC_OUT	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (PRC_OUT_B => '1',others => 'Z');
	constant MEM_RD	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (MEM_RD_B => '1',others => 'Z');
	constant MEM_WRI	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (MEM_WRI_B => '1',others => 'Z');
	constant MEM_ARI	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (MEM_ARI_B => '1',others => 'Z');
	constant ALU_RSO	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (ALU_RSO_B => '1',others => 'Z');
	constant ALU_FLAGS	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (ALU_FLAG_B => '1',others => 'Z');
	constant SWP_REG	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (SWP_REG_B => '1',others => 'Z');
	constant STF_IN	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (STF_IN_B => '1',others => 'Z');
	constant CLR_STF	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (CLR_STF_B => '1',others => 'Z');
	constant REG_AIN	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (REG_AIN_B => '1',others => 'Z');
	constant REG_AOU	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (REG_AOU_B => '1',others => 'Z');
	constant REG_BIN	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (REG_BIN_B => '1',others => 'Z');
	constant REG_BOU	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (REG_BOU_B => '1',others => 'Z');
	--------------------------------------------------------------------------------------------------

    constant REG_WIDTH		: integer   := data_bus_width;
    constant NUM_REG		: integer   := 8;

	-- ROM_SIZE and RAM_SIZE will be multiplied by data_bus_width
	constant ROM_ADDR_BITS	: integer 	:= 14;
	constant ROM_SIZE		: integer 	:= 2 ** ROM_ADDR_BITS;
	constant RAM_ADDR_BITS	: integer 	:= 15;
    constant RAM_SIZE       : integer   := 2 ** RAM_ADDR_BITS;

	constant EXT_MEM_BITS	: integer	:= 14;
	constant EXT_MEM_SIZE	: integer 	:= 2 ** EXT_MEM_BITS;

	-- Number of Bits for an OPCODE
	constant OPCODE_BITS	: integer	:= 8;
	-- Number of OPCODES
	constant NUM_OPCODES	: integer	:= 2 ** OPCODE_BITS;

	-- Number of Bits in a Command for the Operators
	constant OPER_BITS		: integer 	:= 2 * data_bus_width;
	-- Actual Length of the Command including OPCODE and Operators
	constant CMD_LENGTH		: integer	:= OPCODE_BITS + OPER_BITS;

	constant NUM_MICRO_CYC	: integer	:= 3;
	constant NUM_MICRO_CMD	: integer	:= 2 ** NUM_MICRO_CYC;

	constant NUM_INTERRUPTS	: integer 	:= 6;

	constant INT_PRIO_BITS	: integer	:= 3;
	constant INT_PRIORITIES	: integer	:= 2 ** INT_PRIO_BITS;

	-- Needs to be set to log2(data_bus_width)
	constant PROG_COU_INC	: integer := 3;
	constant PROG_COU_START_DISTANCE	: integer := 4;
	-- Start Address of the Program => Start Value of Instruction Register
	-- Program Start
	constant PROG_START	:
		std_logic_vector(addr_bus_width - 1 downto 0) :=
		(
			addr_bus_width - (PROG_COU_INC + PROG_COU_START_DISTANCE) => '0',
			others => '1'
		)
	;

	-- ----------------------------------------
	constant NUM_ALU_OPER	: integer	:= 9;
	constant ALU_CTRL_WIDTH	: integer	:= 4;-- log2(NUM_ALU_OPER)
	-- ----------------------------------------
	constant AND_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (0 => '1',others => '0');
	constant OR_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (1 => '1',others => '0');
	constant XOR_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (0 | 1 => '1',others => '0');
	constant NOT_A_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (2 => '1',others => '0');
	constant NOT_B_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (2 | 0 => '1',others => '0');
	constant ADD_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (2 downto 0 => '1',others => '0');
	constant SUB_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (3 => '1',others => '0');
	constant SHIFT_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (3 | 0 => '1',others => '0');
	constant PARITY_CODE	: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (3 | 1 | 0 => '1',others => '0');
	-- ----------------------------------------

	-- ---------------------------------------
	constant NUM_OPER_FLAGS	: integer	:= 1;
	-- ---------------------------------------
	-- flags[0] = Cyclic Buffer Enable
	constant CYC_BUFFER_ENA	: integer	:= 0;
	-- ---------------------------------------

	-- ---------------------------------------
	constant NUM_FLAGS		: integer	:= 6;
	-- ---------------------------------------
	-- status[0] = Carry out
	-- status[1] = Result is Zero
	-- status[2] = Overflow
	-- status[3] = Even Parity
	-- status[4] = Odd Parity
	-- status[5] = Sign (0 if positive)
	constant CARRY_FLAG		: integer	:= 0;
	constant ZERO_FLAG		: integer	:= 1;
	constant OVERF_FLAG		: integer	:= 2;
	constant EVEN_FLAG		: integer	:= 3;
	constant ODD_FLAG		: integer	:= 4;
	constant SIGN_FLAG		: integer	:= 5;
	-- ---------------------------------------

	function to_index(vec : std_logic_vector) return integer;

end package CPU_pkg;

package body CPU_pkg is

	function to_index(vec : std_logic_vector) return integer is

		begin

			return to_integer(unsigned(vec));

	end function to_index;

end package body CPU_pkg;
