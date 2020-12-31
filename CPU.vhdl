library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity CPU is
    port(
        reset       : in std_logic;
        -- Clock Input
        clk         : in    std_logic;
        -- In/Outputs for Busses
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0) := (others => 'Z');
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0) := (others => 'Z');
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0) := (others => 'Z');
        -- Ready tells the CPU if it should work
        ready       : in std_logic;
        -- Wait indicates that the CPU is not working
        wait_o      : out std_logic;
        -- Interrupt-Request Pin -> Indicates that Interrupt has occured
        int_req     : in std_logic;
        -- Turn on or off if the CPU is able to access the bus
        bus_enable  : in    std_logic;
        -- Request that the DMA needs the Bus
        hold        : in std_logic;
        -- Confirmation that the CPU gave the Bus free
        hold_a      : out std_logic
    );
end CPU;

architecture structure of CPU is

    type REGISTERS is array(0 to (NUM_REG to 0) of std_logic_vector(regWidth - 1 downto 0));

    signal data_bus_intern  : std_logic_vector(data_bus_width - 1 downto 0) := (others => 'Z');
    signal ctrl_bus_intern  : std_logic_vector(ctrl_bus_width - 1 downto 0) := (others => 'Z');
    signal addr_bus_intern  : std_logic_vector(addr_bus_width - 1 downto 0) := (others => 'Z');

    signal stack_pointer    : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal program_counter  : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal status_registers : std_logic_vector(numStatReg - 1 downto 0) := (others => '0');

    signal memory_address_r : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal memory_data_reg  : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');

    signal REGS             : REGISTERS;
    signal ALU_CTRL_REG     : std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0);

    signal OPCODE_intern    : std_logic_vector(OPCODE_BITS - 1 downto 0);

    component ALU is
        port(
            -- Input for OPCODE -> tells the ALU which command to execute
            ctrl        : in std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0);
            -- Inputs for both Operands
            operand1    : in  std_logic_vector(data_bus_width - 1 downto 0);
            operand2    : in  std_logic_vector(data_bus_width - 1 downto 0);
            -- Result of the Operation
            result      : out std_logic_vector(data_bus_width - 1 downto 0);
            -- Status Output Flags -> See CPU_pkg
            status_out  : out std_logic_vector(numStatReg - 1 downto 0)
        );
    end component ALU;

    component ProgCounter is
        port(
            clk         : in  std_logic;
            -- Increment Program-Counter-Flag
            inc         : in std_logic;
            -- Override Program-Counter-Signal
            ovr         : in  std_logic;
            -- Override Value
            ovr_count   : in  std_logic_vector(addr_bus_width - 1 downto 0);
            -- Program-Counter Out
            prog_count  : out std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
            -- Program Counter Overflow
            cnt_overf   : out std_logic
        );
    end component ProgCounter;

    begin

        alu_ent : entity work.ALU port map(
            ctrl        => ALU_CTRL_REG,
            operand1    => REGS(0),
            operand2    => REGS(1),
            result      => data_bus_intern,
            status_out  => status_registers
        );

        -- mmu : entity work.MemoryManager port map(
        --     ena         => '0',
        --     rd_wr       => '0',
        --     address     => addr_bus_intern,
        --     data_out    => data_bus_intern
        -- )

        p_bus : process(clk)

            begin

                if (ready = '1') then

                    if (bus_enable = '1') then

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

        end process p_bus;

end structure;
