library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity CPU is
    port(
        -- Reset Input
        reset       : in std_logic;
        -- Clock Input
        clk         : in std_logic;
        -- In/Outputs for Busses
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0) := (others => 'Z');
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0) := (others => 'Z');
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0) := (others => 'Z');
        -- Interrupt-Request Pin -> Indicates that Interrupt has occured
        int_req     : in std_logic;
        -- Wait indicates that the CPU should delay/stop working
        wait_o      : out std_logic;
        -- Tells the CPU if it is able to access the bus
        bus_enable  : in std_logic;
        -- Request for DMA
        hold        : in std_logic;
        -- Confirmation that the CPU gave the Bus free
        hold_a      : out std_logic
    );
end CPU;

architecture structure of CPU is

    -- Clock Declarations

    signal master_clk   : std_logic;
    signal clk_divs     : std_logic_vector(NUM_MICRO_CYC downto 0);
    signal inst_clk     : std_logic;

    -- Bus Declarations

    signal data_bus_intern  : std_logic_vector(data_bus_width - 1 downto 0) := (others => 'Z');
    signal ctrl_bus_intern  : std_logic_vector(ctrl_bus_width - 1 downto 0) := (others => 'Z');
    signal addr_bus_intern  : std_logic_vector(addr_bus_width - 1 downto 0) := (others => 'Z');

    -- Register Declarations

    type REGISTERS is array(NUM_REG downto 0) of std_logic_vector(data_bus_width - 1 downto 0);

    signal stack_pointer    : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal program_counter  : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal status_registers : std_logic_vector(NUM_FLAGS - 1 downto 0) := (others => '0');

    signal memory_address_r : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal memory_data_reg  : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');

    signal REGS             : REGISTERS := (others => (others => '0'));
    signal ALU_CTRL_REG     : std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0) := (others => '0');

    signal OPCODE_intern    : std_logic_vector(OPCODE_BITS - 1 downto 0) := (others => '0');

    -- Component Declarations

    component ALU is
        port(
            -- Input for OPCODE -> tells the ALU which command to execute
            ctrl        : in  std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0);
            -- Inputs for both Operands => A-, and B-Register
            operand1    : in  std_logic_vector(data_bus_width - 1 downto 0);
            operand2    : in  std_logic_vector(data_bus_width - 1 downto 0);
            -- Busses
            ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
            data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
            -- Status Output Flags -> See CPU_pkg
            status_out  : out std_logic_vector(NUM_FLAGS - 1 downto 0)
        );
    end component ALU;

    component ProgCounter is
        port(
            ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
            data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
            -- Program Counter Overflow
            -- TODO Put on CTRL_BUS
            cnt_overf   : out std_logic
        );
    end component ProgCounter;

    component T_FF is
        port(
            T       : in std_logic;
            outp    : out std_logic
        );
    end component T_FF;

    begin

        -- Clock Instantiation

        -- Connnect Reset and Clock to CTRL_BUS

        master_clk          <= clk;
        ctrl_bus(RESET_CTL) <= reset;
        ctrl_bus(CLOCK_CTL) <= inst_clk;

        clk_divs(0)     <= master_clk;
        inst_clk        <= clk_divs(NUM_MICRO_CYC);

        -- Clock Process
        p_clk : for i in 0 to NUM_MICRO_CYC - 1 generate

            begin

                clk_div : entity work.T_FF port map(
                    T       => clk_divs(i),
                    outp    => clk_divs(i + 1)
                );

        end generate p_clk;

        -- Component Instantiation

        alu_ent : entity work.ALU port map(
            ctrl        => ALU_CTRL_REG,
            operand1    => REGS(0),
            operand2    => REGS(1),
            ctrl_bus    => ctrl_bus_intern,
            data_bus    => data_bus_intern,
            status_out  => status_registers
        );

        -- mmu : entity work.MemoryManager port map(
        --     ena         => '0',
        --     rd_wr       => '0',
        --     address     => addr_bus_intern,
        --     data_out    => data_bus_intern
        -- );

        -- Helper Processes ----------------------------------

        -- Bus Output Process
        p_bus : process(master_clk)

            begin

                hold_a <= '0';

                if (hold = '1') then

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

                    hold_a <= '1';

                end if;

        end process p_bus;

        -- Reset Process
        p_reset : process(ctrl_bus(RESET_CTL))

            begin

                if rising_edge(ctrl_bus(RESET_CTL)) then

                    stack_pointer       <= (others => '0');
                    program_counter     <= (others => '0');
                    status_registers    <= (others => '0');

                    memory_address_r    <= (others => '0');
                    memory_data_reg     <= (others => '0');

                    REGS                <= (others => (others => '0'));
                    ALU_CTRL_REG        <= (others => '0');

                    OPCODE_intern       <= (others => '0');

                end if;

        end process p_reset;

end structure;
