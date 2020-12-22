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
	-- Controls the Data=Flow over the Data-Bus
	constant ctrl_bus_width	: integer	:= 8;
	-- Tells the components which Address should be fetched/written
	constant addr_bus_width	: integer	:= 16;

	----------------------------------------
	-- CONTROL WORDS OVER THE CONTROL-BUS
	----------------------------------------
	-- Bit 0 => Interrupt Request
	-- Bit 1 => Program Counter Override
	-- Bit 2 => Program Counter In
	-- Bit 3 => Program Counter Out
	-- Bit 4 => Memory Read
	-- Bit 5 => Memory Write
	-- Bit 6 => Memory Address Register In
	-- Bit 7 => ALU Result OUT
	-- Bit 8 => Swap Register A and B
	-- Bit 9 => Status Flags In
	-- Bit 10 => Clear Status Flags
	-- Bit 11 => Register A In
	-- Bit 12 => Register A Out
	-- Bit 13 => Register B In
	-- Bit 14 => Register B Out
	----------------------------------------

    constant regWidth       : integer   := data_bus_width;
    constant numReg         : integer   := 8;

	-- ROM_SIZE and RAM_SIZE will be multiplied by data_bus_width
	constant ROM_ADDR_BITS	: integer 	:= 14;
	constant ROM_SIZE		: integer 	:= 2 ** ROM_ADDR_BITS;
	constant RAM_ADDR_BITS	: integer 	:= 15;
    constant RAM_SIZE       : integer   := 2 ** RAM_ADDR_BITS;

	constant EXT_MEM_BITS	: integer	:= 14;
	constant EXT_MEM_SIZE	: integer 	:= 2 ** EXT_MEM_BITS;

	-- Number of Bits for an OPCODE
	constant OPCODE_BITS	: integer	:= 8;
	-- Number of Bits in a Command for the Operators
	constant OPER_BITS		: integer 	:= 2 * data_bus_width;
	-- Number of OPCODES
	constant NUM_OPCODES	: integer	:= 2 ** OPCODE_BITS;
	-- Actual Length of the Command including OPCODE and Operators
	constant CMD_LENGTH		: integer	:= data_bus_width + OPER_BITS;

	constant NUM_MICRO_CYC	: integer	:= 3;
	constant NUM_MICRO_CMD	: integer	:= 2 ** NUM_MICRO_CYC;

	constant NUM_INTERRUPTS	: integer 	:= 6;

	constant INT_PRIO_BITS	: integer	:= 3;
	constant INT_PRIORITIES	: integer	:= 2 ** INT_PRIO_BITS;

	-- Start Address of the Program => Start Value of Instruction Register
	constant PROG_START		: std_logic_vector(addr_bus_width - 1 downto 0) := ((addr_bus_width - data_bus_width) - 2 => '1') & '0' & (data_bus_width => '1');

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
