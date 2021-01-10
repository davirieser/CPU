library     IEEE;
	use 	IEEE.std_logic_1164.all;
	use 	IEEE.numeric_std.all;
	use 	IEEE.math_real.all;

package CPU_pkg is

	-- Timing ------------------------------------------------------------------
    constant clockFrequency : integer   := 10E3;
    constant base_clock     : time      := 1.0 sec / clockFrequency;
	constant output_delay	: time 		:= base_clock / 10;
	----------------------------------------------------------------------------

	-- Bus Sizes ---------------------------------------------------------------
	-- Word Size in Bits
	constant WORD_SIZE		: integer	:= 8;
	-- Word Alignment on the Address Bus = log2(WORD_SIZE)
	constant WORD_ADDR_DIST	: integer	:= 3;
	-- Transmits data from one CPU-Component to another
	constant data_bus_width	: integer	:= WORD_SIZE;
    constant REG_WIDTH		: integer   := data_bus_width;
	constant NUM_REG		: integer	:= 2;
	-- Tells the components which Address should be fetched/written
	constant addr_bus_width	: integer	:= data_bus_width + WORD_ADDR_DIST;
	-- Controls all the internal devices and receives external signals
	constant ctrl_bus_width	: integer	:= 28;
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- CONTROL WORDS OVER THE CONTROL-BUS
	----------------------------------------------------------------------------
	-- External Signals --------------------
	-- Bit 0 => Reset
	-- Bit 1 => Clock
	-- Bit 2 => Interrupt Request // TODO
	-- Internal Signals --------------------
	-- Bit 3 => Instruction Over
	-- Bit 4 => Program Counter Increment
	-- Bit 5 => Program Counter In
	-- Bit 6 => Program Counter Out
	-- Bit 7 => Instruction Register In
	-- Bit 8 => Instruction Register Out
	-- Bit 10 => Stack Pointer Increment
	-- Bit 11 => Stack Pointer Decrement
	-- Bit 12 => Stack Pointer Out
	-- Bit 13 => Memory Read // TODO
	-- Bit 14 => Memory Write // TODO
	-- Bit 15 => Memory Address Register In
	-- Bit 16 => Memory Address Register Out
	-- Bit 17 => ALU Result Out // TODO
	-- Bit 18 => ALU Flags Out // TODO
	-- Bit 19 => ALU Flags Clear // TODO
	-- Bit 20 => Swap Register A and B
	-- Bit 21 => Status Flags In
	-- Bit 22 => Status Flags Out
	-- Bit 23 => Status Flags Clears
	-- Bit 24 => Register A In
	-- Bit 25 => Register A Out
	-- Bit 26 => Register B In
	-- Bit 27 => Register B Out
	----------------------------------------------------------------------------
	constant RESET_CTL	:	integer	:= 0;
	constant CLOCK_CTL	:	integer := 1;
	constant INT_REQ_B	: 	integer	:= 2;
	----------------------------------------------------------------------------
	constant INST_OVER	:	integer	:= 3;
	constant PRC_INCR_B	: 	integer := 4;
	constant PRC_IN_B	: 	integer := 5;
	constant PRC_OUT_B	: 	integer := 6;
	constant INST_R_IN	: 	integer	:= 7;
	constant INST_R_OUT	: 	integer	:= 8;
	constant SP_INC		: 	integer	:= 10;
	constant SP_DEC		: 	integer	:= 11;
	constant SP_OUT		:	integer := 12;
	constant MEM_RD_B	: 	integer := 13;
	constant MEM_WRI_B	: 	integer := 14;
	constant MEM_ARI_B	: 	integer := 15;
	constant MEM_ARO_B	: 	integer := 16;
	constant ALU_RSO_B	: 	integer := 17;
	constant ALU_FLAG_B	: 	integer	:= 18;
	constant ALU_F_CLR	: 	integer	:= 19;
	constant SWP_REG_B	: 	integer := 20;
	constant STF_IN_B	: 	integer := 21;
	constant STF_OUT_B	: 	integer := 22;
	constant CLR_STF_B	: 	integer := 23;
	constant REG_AIN_B	: 	integer := 24;
	constant REG_AOU_B	: 	integer := 25;
	constant REG_BIN_B	: 	integer := 26;
	constant REG_BOU_B	: 	integer := 27;
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	constant RESET_F	: 	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (RESET_CTL => '1',others => 'Z');
	constant INT_REQ	: 	std_logic_vector(ctrl_bus_width - 1 downto 0)
		:= (INT_REQ_B => '1',others => 'Z');
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Address Distribution
	constant NUM_MEMORY_DEVICES	: integer	:= 3;

	-- Type Declarations -------------------------------------------------------
	type MEMORY is record
		SIZE		: integer;
		ADDR_BITS	: integer;
		MEM_START	: std_logic_vector(addr_bus_width - 1 downto 0);
		MEM_END		: std_logic_vector(addr_bus_width - 1 downto 0);
	end record MEMORY;
	type MEMORIES is array(NUM_MEMORY_DEVICES - 1 downto 0) of MEMORY;
	----------------------------------------------------------------------------

	-- ROM_SIZE and RAM_SIZE will be multiplied by data_bus_width
	constant ROM_ADDR_BITS	: integer 	:= 8;
	constant ROM_SIZE		: integer 	:= 2 ** ROM_ADDR_BITS;
	constant ROM_MEM_INDEX	: integer	:= 0;
	constant ROM_MEMORY		: MEMORY	:= (
		SIZE => ROM_SIZE,
		ADDR_BITS => ROM_ADDR_BITS,
		MEM_START => (others => '0'),
		MEM_END	=> (
			ROM_ADDR_BITS - 1 downto 0 => '1',
			others => '0'
		)
	);

	constant RAM_ADDR_BITS	: integer 	:= 8;
    constant RAM_SIZE       : integer   := 2 ** RAM_ADDR_BITS;
	constant RAM_MEM_INDEX	: integer	:= 1;
	constant RAM_MEMORY		: MEMORY	:= (
		SIZE => RAM_SIZE,
		ADDR_BITS => RAM_ADDR_BITS,
		MEM_START => (
			RAM_ADDR_BITS => '1',
			others => '0'
		),
		MEM_END	=> (
			RAM_ADDR_BITS => '1',
			RAM_ADDR_BITS - 1 downto 0 => '1',
			others => '0'
		)
	);

	constant EXT_MEM_BITS	: integer	:= 10;
	constant EXT_MEM_SIZE	: integer 	:= 2 ** EXT_MEM_BITS;
	constant EXT_MEM_INDEX	: integer	:= 2;
	constant EXT_MEMORY		: MEMORY	:= (
		SIZE => EXT_MEM_SIZE,
		ADDR_BITS => EXT_MEM_BITS,
		MEM_START => (
			RAM_ADDR_BITS + 1 => '1',
			others => '0'
		),
		MEM_END	=> (
			EXT_MEM_BITS - 1 downto 0 => '1',
			others => '0'
			)
	);

	constant MEMORY_MAP	: MEMORIES	:= (
		ROM_MEM_INDEX => ROM_MEMORY,
		RAM_MEM_INDEX => RAM_MEMORY,
		EXT_MEM_INDEX => EXT_MEMORY
	);
	-- ----------------------------------------------------------------------

	-- ----------------------------------------------------------------------
	-- Number of Bits for an OPCODE
	constant OPCODE_BITS	: integer	:= 6;
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
	-- ----------------------------------------------------------------------

	-- ----------------------------------------------------------------------
	-- Needs to be set to log2(data_bus_width)
	constant PROG_COU_INC				: integer := WORD_ADDR_DIST;
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
	-- Value of the Stack-Pointer on Reset
	constant STACK_POINTER_START	: std_logic_vector(addr_bus_width - 1 downto 0)
		:= (others => '0');
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	constant NUM_ALU_OPER	: integer	:= 9;
	constant ALU_CTRL_WIDTH	: integer	:= 4; -- log2(NUM_ALU_OPER)
	----------------------------------------------------------------------------
	-- There is no "(others => '0')"-Code
	-- (others => '0') as ALU_CTRL => (others => '0') as ALU_RESULT
	----------------------------------------------------------------------------
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
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	constant NUM_OPER_FLAGS	: integer	:= 2;
	----------------------------------------------------------------------------
	-- flags[0] = Cyclic Buffer Enable
	-- flags[1] = Relative Jumps / Absolute Jumps
	-- flags[2] = Carry In Flag
	constant CYC_BUFFER_ENA	: integer	:= 0;
	constant REL_JUMPS		: integer	:= 1;
	constant CARRY_IN		: integer	:= 2;
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	constant NUM_FLAGS		: integer	:= 6;
	----------------------------------------------------------------------------
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
	----------------------------------------------------------------------------

	function to_index(vec : std_logic_vector) return integer;

end package CPU_pkg;

package body CPU_pkg is

	function to_index(vec : std_logic_vector) return integer is

		begin

			return to_integer(unsigned(vec));

	end function to_index;

end package body CPU_pkg;
