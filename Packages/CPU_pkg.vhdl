library     IEEE;
	use 	IEEE.std_logic_1164.all;
	use 	IEEE.numeric_std.all;
	use 	IEEE.math_real.all;

package CPU_pkg is

	function to_index(vec : std_logic_vector) return integer;
	function calc_bits(len : integer) return integer;
	function compare_dont_care(
		arr1, arr2 : std_logic_vector
	) return boolean;
	function checkRDWR(
		rd,wr : std_logic
	) return std_logic;
	function checkHighImp(
		x : std_logic_vector
	) return boolean;

	-- Timing ------------------------------------------------------------------
    constant clockFrequency : integer   := 10E3;
    constant base_clock     : time      := 1.0 sec / clockFrequency;
	constant output_delay	: time 		:= base_clock / 10;
	----------------------------------------------------------------------------

	-- Word Size in Bits -------------------------------------------------------
	constant WORD_SIZE		: integer	:= 8;
	-- Word Alignment on the Address Bus = log2(WORD_SIZE)
	constant WORD_ADDR_DIST	: integer	:= calc_bits(WORD_SIZE);
    constant REG_WIDTH		: integer   := WORD_SIZE;
	constant NUM_REG		: integer	:= 2;
	----------------------------------------------------------------------------

	-- Bus Sizes ---------------------------------------------------------------
	-- Transmits data from one CPU-Component to another
	constant data_bus_width	: integer	:= WORD_SIZE;
	-- Tells the components which Address should be fetched/written
	constant addr_bus_width	: integer	:= 2 * data_bus_width;
	-- Controls all the internal devices
	constant ctrl_bus_width	: integer	:= 25;
	-- Controls external devices and receives external signals
	constant ext_bus_width	: integer	:= 8;
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- CONTROL WORDS OVER THE CONTROL-BUS
	----------------------------------------------------------------------------
	-- External Signals --------------------
	-- TODO De ganzen Signal muessen in da CPU jetzt mitm Externen Bus laffen
	-- Bit 0 => Reset
	-- Bit 1 => Clock
	-- Bit 2 => Interrupt Request // TODO
	-- Bit 3 => Memory Read // TODO
	-- Bit 4 => Memory Read Finished
	-- Bit 5 => Memory Write // TODO
	-- Bit 6 => Wait-Bit => Stop CPU
	-- Bit 7 => Hold for DMA
	-- Internal Signals --------------------
	-- Bit 0 => Instruction Over
	-- Bit 1 => Program Counter Increment
	-- Bit 2 => Program Counter In
	-- Bit 3 => Program Counter Out
	-- Bit 4 => Instruction Register In
	-- Bit 5 => Instruction Register Out
	-- Bit 6 => Stack Pointer Increment
	-- Bit 7 => Stack Pointer Decrement
	-- Bit 8 => Stack Pointer Initialize
	-- Bit 9 => Stack Pointer Out
	-- Bit 10 => Memory Address Register Low-Bits In
	-- Bit 11 => Memory Address Register High-Bits In
	-- Bit 12 => Memory Address Register Out
	-- Bit 13 => ALU Result Out // TODO
	-- Bit 14 => ALU Flags Out // TODO
	-- Bit 15 => ALU Flags Clear // TODO
	-- Bit 16 => Swap Register A and B
	-- Bit 17 => Status Flags In
	-- Bit 18 => Status Flags Out
	-- Bit 19 => Status Flags Clear
	-- Bit 20 => Wait for Memory Read
	-- Bit 21 => Register A In
	-- Bit 22 => Register A Out
	-- Bit 23 => Register B In
	-- Bit 24 => Register B Out
	----------------------------------------------------------------------------
	constant I_RESET		:	integer	:= 0;
	constant I_CLOCK		:	integer := 1;
	constant I_INT_REQ		: 	integer	:= 2;
	constant I_MEM_RD		: 	integer := 3;
	constant I_MEM_RD_READY	:	integer := 4;
	constant I_MEM_WRI		: 	integer := 5;
	constant I_WAIT			: 	integer := 6;
	constant I_DMA_HOLD		:	integer := 7;
	----------------------------------------------------------------------------
	constant I_INST_OVER	:	integer	:= 0;
	constant I_PRC_INCR		: 	integer := 1;
	constant I_PRC_IN		: 	integer := 2;
	constant I_PRC_OUT		: 	integer := 3;
	constant I_INST_R_IN	: 	integer	:= 4;
	constant I_INST_R_OUT	: 	integer	:= 5;
	constant I_SP_INC		: 	integer	:= 6;
	constant I_SP_DEC		: 	integer	:= 7;
	constant I_SP_INIT		:	integer := 8;
	constant I_SP_OUT		:	integer := 9;
	constant I_MEM_ARI_L	: 	integer := 10;
	constant I_MEM_ARI_H	: 	integer := 11;
	constant I_MEM_ARO		: 	integer := 12;
	constant I_ALU_RSO		: 	integer := 13;
	constant I_ALU_FLAG		: 	integer	:= 14;
	constant I_ALU_F_CLR	: 	integer	:= 15;
	constant I_SWP_REG		: 	integer := 16;
	constant I_STF_IN		: 	integer := 17;
	constant I_STF_OUT		: 	integer := 18;
	constant I_CLR_STF		: 	integer := 19;
	constant I_WF_MEM_RD	: 	integer := 20;
	constant I_REG_AIN		: 	integer := 21;
	constant I_REG_AOU		: 	integer := 22;
	constant I_REG_BIN		: 	integer := 23;
	constant I_REG_BOU		: 	integer := 24;
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	constant RESET_F	: 	std_logic_vector(ext_bus_width - 1 downto 0)
		:= (I_RESET => '1',others => 'Z');
	constant INT_REQ	: 	std_logic_vector(ext_bus_width - 1 downto 0)
		:= (I_INT_REQ => '1',others => 'Z');
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	-- Address Distribution
	constant NUM_MEMORY_DEVICES	: integer	:= 3;

	-- Read/Write Logic
	constant READ_BIT		: std_logic := '0';
	constant READ_ENABLE	: std_logic	:= READ_BIT;
	constant WRITE_BIT		: std_logic := not READ_BIT;
	constant WRITE_ENABLE	: std_logic	:= WRITE_BIT;

	-- Type Declarations -------------------------------------------------------
	type MEMORY_SPEC_T is record
		WRITABLE	: std_logic;
		MEM_BITS	: integer;
		MEM_START	: std_logic_vector(addr_bus_width - 1 downto 0);
		MEM_END		: std_logic_vector(addr_bus_width - 1 downto 0);
	end record MEMORY_SPEC_T;
	type MEMORY_MAP_T is array(NUM_MEMORY_DEVICES - 1 downto 0) of MEMORY_SPEC_T;
	----------------------------------------------------------------------------

	-- ROM_SIZE and RAM_SIZE will be multiplied by data_bus_width
	constant ROM_ADDR_BITS	: integer 	:= 8;
	constant ROM_SIZE		: integer 	:= 2 ** ROM_ADDR_BITS;
	constant ROM_MEM_INDEX	: integer	:= 0;
	constant ROM_MEMORY		: MEMORY_SPEC_T	:= (
		WRITABLE	=> READ_ENABLE,
		MEM_BITS	=> ROM_ADDR_BITS,
		MEM_START 	=> (
			others => '0'
		),
		MEM_END	=> (
			ROM_ADDR_BITS downto 0 => '1',
			others => '0'
		)
	);

	constant RAM_ADDR_BITS	: integer 	:= 8;
    constant RAM_SIZE       : integer   := 2 ** RAM_ADDR_BITS;
	constant RAM_MEM_INDEX	: integer	:= 1;
	constant RAM_MEMORY		: MEMORY_SPEC_T	:= (
		WRITABLE	=> WRITE_ENABLE,
		MEM_BITS	=> RAM_ADDR_BITS,
		MEM_START 	=> (
			ROM_ADDR_BITS => '1',
			others => '0'
		),
		MEM_END	=> (
			RAM_ADDR_BITS + 1 => '1',
			others => '0'
		)
	);

	constant EXT_MEM_BITS	: integer	:= 10;
	constant EXT_MEM_SIZE	: integer 	:= 2 ** EXT_MEM_BITS;
	constant EXT_MEM_INDEX	: integer	:= 2;
	constant EXT_MEMORY		: MEMORY_SPEC_T	:= (
		WRITABLE	=> WRITE_ENABLE,
		MEM_BITS	=> EXT_MEM_BITS,
		MEM_START 	=> (
			RAM_ADDR_BITS + 1 => '1',
			others => '0'
		),
		MEM_END	=> (
			EXT_MEM_BITS => '1',
			RAM_ADDR_BITS + 1 => '1',
			others => '0'
			)
	);

	constant MEMORY_MAP	: MEMORY_MAP_T	:= (
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
	constant PROG_COU_INC				: integer := calc_bits(data_bus_width);
	-- constant PROG_COU_START_DISTANCE	: integer := 6;
	-- -- Start Address of the Program => Start Value of Instruction Register
	-- -- Program Start
	-- constant PROG_START	:
	-- 	std_logic_vector(addr_bus_width - 1 downto 0) :=
	-- 	(
	-- 		(PROG_COU_INC + PROG_COU_START_DISTANCE - 1) => '0',
	-- 		(PROG_COU_INC - 1) downto 0 => '0',
	-- 		others => '1'
	-- 	)
	-- ;
	----------------------------------------------------------------------------

	----------------------------------------------------------------------------
	constant NUM_ALU_OPER	: integer	:= 9;
	constant ALU_CTRL_WIDTH	: integer	:= calc_bits(NUM_ALU_OPER); -- log2(NUM_ALU_OPER)
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
		:= (2 | 1 => '1',others => '0');
	constant SUB_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (2 downto 0 => '1',others => '0');
	constant SHIFT_CODE		: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (3 => '1',others => '0');
	constant PARITY_CODE	: std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
		:= (3 | 0 => '1',others => '0');
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
	-- Debug Flags -------------------------------------------------------------
	----------------------------------------------------------------------------
	constant ALU_DEBUG		: boolean	:= false;
	constant CLK_DIV_DEBUG	: boolean	:= false;
	constant CPU_DEBUG		: boolean	:= false;
	constant INST_DEC_DEBUG	: boolean	:= false;
	constant MEMORY_DEBUG	: boolean	:= false;
	constant NVIC_DEBUG		: boolean	:= false;
	constant PROG_CNT_DEBUG	: boolean	:= false;
	----------------------------------------------------------------------------

end package CPU_pkg;

package body CPU_pkg is

	function to_index(vec : std_logic_vector) return integer is

		begin

			return to_integer(unsigned(vec));

	end function to_index;

	function calc_bits(len : integer) return integer is

		begin

			case len is
				when 1 | 2 							=> return 1;
				when 4 | 3 							=> return 2;
				when 8 downto 5 					=> return 3;
				when 16 downto 9 					=> return 4;
				when 32 downto 17 					=> return 5;
				when 64 downto 33 					=> return 6;
				when 128 downto 65 					=> return 7;
				when 256 downto 129 				=> return 8;
				when 512 downto 257 				=> return 9;
				when 1024 downto 513 				=> return 10;
				when 2048 downto 1025 				=> return 11;
				when 4096 downto 2049 				=> return 12;
				when 8192 downto 4097 				=> return 13;
				when 16384 downto 8193 				=> return 14;
				when 32768 downto 16385 			=> return 15;
				when 65536 downto 32769 			=> return 16;
				when 131072 downto 65537 			=> return 17;
				when 262144 downto 131073 			=> return 18;
				when 524288 downto 262145 			=> return 19;
				when 1048576 downto 524289 			=> return 20;
				when 2097152 downto 1048577 		=> return 21;
				when 4194304 downto 2097153 		=> return 22;
				when 8388608 downto 4194305 		=> return 23;
				when 16777216 downto 8388609 		=> return 24;
				when 33554432 downto 16777217 		=> return 25;
				when 67108864 downto 33554433 		=> return 26;
				when 134217728 downto 67108865 		=> return 27;
				when 268435456 downto 134217729 	=> return 28;
				when 536870912 downto 268435457 	=> return 29;
				when 1073741824 downto 536870913 	=> return 30;
				when 2147483647 downto 1073741825 	=> return 31;
				when others		=> report "Invalid Len";
			end case;

	end function calc_bits;

	function compare_dont_care(
		arr1, arr2 : std_logic_vector
	)return boolean is

        variable flag : boolean := true;

		begin

	        if ( arr1'length /= arr2'length ) then
	            ASSERT FALSE
	            REPORT "Arguments of compare_dont_care are not of the same Length"
	            SEVERITY FAILURE;
	        else
				for i in arr1'range loop
					flag := flag and
							((arr1(i)='X') or
							(arr2(i)='X') or
							(arr1(i) = arr2(i)));
				end loop;

			end if;

			return flag;

	end function compare_dont_care;

	function checkRDWR(
		rd,wr : std_logic
	) return std_logic is

		begin

			if ((wr = '1') and (rd ='Z')) then
				return WRITE_BIT;
			else
				return READ_BIT;
			end if;

	end function checkRDWR;

	function checkHighImp(
		x : std_logic_vector
	) return boolean is

        variable flag : boolean := true;

		begin

			for i in x'range loop
				flag := flag and ((x(i) = '1') or (x(i) = '0'));
			end loop;

			return flag;

	end function checkHighImp;

end package body CPU_pkg;
