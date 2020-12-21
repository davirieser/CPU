library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;
	use 	ieee.math_real.all;

package CPU_pkg is

    constant clockFrequency : integer   := 2048 * 10E3;
    constant base_clock     : time      := 1.0 sec / clockFrequency;
	constant output_delay	: time 		:= base_clock / 10;

	constant data_bus_width	: integer	:= 8;
	constant ctrl_bus_width	: integer	:= 8;
	constant addr_bus_width	: integer	:= 8;

    constant regWidth       : integer   := data_bus_width;
    constant numReg         : integer   := 8;

	-- ROM_SIZE and RAM_SIZE will be multiplied by data_bus_width
	constant ROM_ADDR_BITS	: integer 	:= 10;
	constant ROM_SIZE		: integer 	:= 2 ** ROM_ADDR_BITS;
	constant RAM_ADDR_BITS	: integer 	:= 12;
    constant RAM_SIZE       : integer   := 2 ** RAM_ADDR_BITS;

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
	constant PROG_START		: std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    -- Deklarierung des Register-Typ ( in dem Fall 8 Bit)
    -- type Reg is array of std_logic_vector(OPER_LEN - 1 downto 0) range 0 to ((2 ** OPER_LEN) - 1);

	constant numStatReg		: integer	:= 6;
	-- status[0] = Carry out
	-- status[1] = Result is Zero
	-- status[2] = Overflow
	-- status[3] = Even Parity
	-- status[4] = Odd Parity
	-- status[5] = Sign (0 if positive)

end CPU_pkg;

package body CPU_pkg is
end CPU_pkg;
