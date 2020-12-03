use library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity CPU is
    port(
        reset       : in std_logic;
        -- Clock Input
        clk         : in    std_logic;
        -- Input for OPCODE
        OPCODE      : in    std_logic_vector(NUM_OPCODES);
        -- In/Outputs for Busses
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0);
        -- Ready tells the CPU if it should work
        ready       : in std_logic;
        -- Interrupt-Request Pin -> Indicates that Interrupt has occured
        int_req     : in std_logic;
        -- Turn on or off if the CPU is able to access the bus
        bus_enable  : in    std_logic
    );
end CPU;

architecture structure of CPU is

    signal data_bus_intern  : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal ctrl_bus_intern  : std_logic_vector(ctrl_bus_width - 1 downto 0) := (others => '0');
    signal addr_bus_intern  : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    signal stack_pointer    : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal program_counter  : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal status_registers : std_logic_vector(numStatReg - 1 downto 0) := (others => '0');

    component ALU is
        port(
            -- Clock Input
            clk         : in  std_logic;
            -- Input for OPCODE -> tells the ALU which command to execute
            ctrl        : in  std_logic;
            -- Inputs for both Operands
            operand1    : in  std_logic_vector(oper_width - 1 downto 0);
            operand2    : in  std_logic_vector(oper_width - 1 downto 0);
            -- Status Input Flags -> See CPU_pkg
            -- Should the result work as a cyclic buffer
            cycle_flag  : in std_logic;
            -- Result of the Operation
            result      : out std_logic_vector(oper_width - 1 downto 0);
            -- Status Output Flags -> See CPU_pkg
            status_out  : out std_logic_vector(numStatReg - 1 downto 0)
        );
    end component ALU;

    begin

        if work = 1 then

            if bus_enable = '1' then

                data_bus <= data_bus_intern after output_delay;
                ctrl_bus <= ctrl_bus_intern after output_delay;
                addr_bus <= addr_bus_intern after output_delay;

            else

                data_bus <= (others => 'Z') after output_delay;
                ctrl_bus <= (others => 'Z') after output_delay;
                addr_bus <= (others => 'Z') after output_delay;

            end if;

        else

            data_bus <= (others => 'Z') after output_delay;
            ctrl_bus <= (others => 'Z') after output_delay;
            addr_bus <= (others => 'Z') after output_delay;

        end if;

end structure;
