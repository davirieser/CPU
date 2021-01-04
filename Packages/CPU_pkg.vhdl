library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;
	use 	ieee.math_real.all;

package CPU_pkg is

    constant clockFrequency : integer   := 2048 * 10E3;
    constant base_clock     : time      := 1.0 sec / clockFrequency;
	constant output_delay	: time 		:= base_clock / 10;

	-- Transmits data from one CPU-Component to another
	constant data_bus_width	: integer	:= 8;
	-- Controls all the internal devices and receives external signals
	constant ctrl_bus_width	: integer	:= 18;
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
	-- Bit 11 => Swap Register A and B
	-- Bit 12 => Status Flags In
	-- Bit 13 => Clear Status Flags
	-- Bit 14 => Register A In
	-- Bit 15 => Register A Out
	-- Bit 16 => Register B In
	-- Bit 17 => Register B Out
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
	constant SWP_REG_B	: 	integer := 11;
	constant STF_IN_B	: 	integer := 12;
	constant CLR_STF_B	: 	integer := 13;
	constant REG_AIN_B	: 	integer := 14;
	constant REG_AOU_B	: 	integer := 15;
	constant REG_BIN_B	: 	integer := 16;
	constant REG_BOU_B	: 	integer := 17;
	----------------------------------------

	--------------------------------------------------------------------------------------------------
	-- Bit 0 => Reset
	constant RESET_F	: 	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (RESET_CTL => '1',others => '0');
	-- Bit 1 => Interrupt Request
	constant CLOCK_F	: 	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (CLOCK_CTL => '1',others => '0');
	-- Bit 2 => Interrupt Request
	constant INT_REQ	: 	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (INT_REQ_B => '1',others => '0');
	-- Bit 3 => Program Counter Override
	constant PRC_OVR	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (PRC_OVR_B => '1',others => '0');
	-- Bit 4 => Program Counter In
	constant PRC_INCR	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (PRC_INCR_B => '1',others => '0');
	-- Bit 4 => Program Counter In
	constant PRC_IN		:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (PRC_IN_B => '1',others => '0');
	-- Bit 5 => Program Counter Out
	constant PRC_OUT	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (PRC_OUT_B => '1',others => '0');
	-- Bit 6 => Memory Read
	constant MEM_RD	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (MEM_RD_B => '1',others => '0');
	-- Bit 7 => Memory Write
	constant MEM_WRI	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (MEM_WRI_B => '1',others => '0');
	-- Bit 8 => Memory Address Register In
	constant MEM_ARI	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (MEM_ARI_B => '1',others => '0');
	-- Bit 9 => ALU Result OUT
	constant ALU_RSO	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (ALU_RSO_B => '1',others => '0');
	-- Bit 10 => Swap Register A and B
	constant SWP_REG	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (SWP_REG_B => '1',others => '0');
	-- Bit 11 => Status Flags In
	constant STF_IN	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (STF_IN_B => '1',others => '0');
	-- Bit 12 => Clear Status Flags
	constant CLR_STF	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (CLR_STF_B => '1',others => '0');
	-- Bit 13 => Register A In
	constant REG_AIN	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (REG_AIN_B => '1',others => '0');
	-- Bit 14 => Register A Out
	constant REG_AOU	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (REG_AOU_B => '1',others => '0');
	-- Bit 15 => Register B In
	constant REG_BIN	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (REG_BIN_B => '1',others => '0');
	-- Bit 16 => Register B Out
	constant REG_BOU	:	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (REG_BOU_B => '1',others => '0');
	--------------------------------------------------------------------------------------------------

    constant regWidth       : integer   := data_bus_width;
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

	constant NUM_ALU_OPER	: integer	:= 9;
	constant ALU_CTRL_WIDTH	: integer	:= 4;-- log2(NUM_ALU_OPER)

	constant oper_flag_num	: integer	:= 1;
	-- flags[0] = Cyclic Buffer Enable

	constant numStatReg		: integer	:= 7;
	-- status[0] = Carry out
	-- status[1] = Result is Zero
	-- status[2] = Overflow
	-- status[3] = Even Parity
	-- status[4] = Odd Parity
	-- status[5] = Sign (0 if positive)

	function to_index(vec : std_logic_vector) return integer;

end package CPU_pkg;

package body CPU_pkg is

	function to_index(vec : std_logic_vector) return integer is

		begin

			return to_integer(unsigned(vec));

	end function to_index;

end package body CPU_pkg;
