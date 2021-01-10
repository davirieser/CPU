library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity CPU is
    port(
        -- Reset Input
        reset       : in std_logic;
        -- Clock Input
        clk         : in std_logic;
        -- In/Outputs for Busses
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0);
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
    signal clk_divs     : std_logic_vector(NUM_MICRO_CYC downto 0) := (others => '0');
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
    signal prog_cnt_ovf_reg : std_logic := '0';

    signal memory_address_r : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    signal instruction_reg  : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');

    signal REGS             : REGISTERS := (others => (others => '0'));
    signal ALU_CTRL_REG     : std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0) := (others => '0');
    signal ALU_IN_FLAGS     : std_logic_vector(NUM_OPER_FLAGS - 1 downto 0) := (others => '0');
    signal ALU_OUT_FLAGS    : std_logic_vector(NUM_FLAGS - 1 downto 0) := (others => '0');

    -- Component Declarations

    component ALU is
        port(
            -- Input for OPCODE -> tells the ALU which command to execute
            ctrl        : in  std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0);
            -- ALU Operation Flags => See CPU_pkg
            flags       : in std_logic_vector(NUM_OPER_FLAGS - 1 downto 0);
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
            clk         : in std_logic;
            ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
            data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
            -- Program Counter Overflow
            cnt_overf   : out std_logic
        );
    end component ProgCounter;

    component INST_DEC is
        port(
            inst        : in std_logic_vector(OPCODE_BITS - 1 downto 0);
            flags_in    : in std_logic_vector(NUM_FLAGS - 1 downto 0);
            micro_cyc   : in std_logic_vector(NUM_MICRO_CYC - 1 downto 0);
            alu_ctrl    : out std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0);
            ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0)
        );
    end component INST_DEC;

    component CLK_DIVIDER is
        port(
            reset   : in std_logic;
            clk     : in std_logic;
            outp    : out std_logic_vector(NUM_MICRO_CYC - 1 downto 0)
        );
    end component CLK_DIVIDER;

    begin

        -- Clock Instantiation

        -- Connnect Reset and Clock to CTRL_BUS

        master_clk                  <= clk;
        ctrl_bus_intern(RESET_CTL)  <= reset;
        ctrl_bus_intern(CLOCK_CTL)  <= inst_clk;

        clk_divs(0) <= clk;
        inst_clk    <= clk_divs(NUM_MICRO_CYC);

        -- Component Instantiation

        alu_ent : entity work.ALU port map(
            ctrl        => ALU_CTRL_REG,
            flags       => ALU_IN_FLAGS,
            operand1    => REGS(0),
            operand2    => REGS(1),
            ctrl_bus    => ctrl_bus_intern,
            data_bus    => data_bus_intern,
            status_out  => status_registers
        );

        inst_dec_ins : entity work.INST_DEC port map(
            inst        => instruction_reg(data_bus_width - 1 downto data_bus_width - OPCODE_BITS),
            flags_in    => ALU_OUT_FLAGS,
            micro_cyc   => clk_divs(NUM_MICRO_CYC downto 1),
            alu_ctrl    => ALU_CTRL_REG,
            ctrl_bus    => ctrl_bus_intern
        );

        clk_div_ins : entity work.CLK_DIVIDER port map(
            reset   => ctrl_bus_intern(INST_OVER),
            -- reset => '0',
            clk     => clk,
            outp    => clk_divs(NUM_MICRO_CYC downto 1)
        );

        prog_count_ins : entity work.ProgCounter port map(
            clk      => master_clk,
            ctrl_bus => ctrl_bus_intern,
            data_bus => data_bus_intern,
            -- Program Counter Overflow
            cnt_overf => prog_cnt_ovf_reg
        );

        -- mmu : entity work.MemoryManager port map(
        --     ena         => '0',
        --     rd_wr       => '0',
        --     address     => addr_bus_intern,
        --     data_out    => data_bus_intern
        -- );

        -- Helper Processes ----------------------------------

        -- Control Register Output Process
        p_ctrl : process(master_clk)

            variable temp : std_logic_vector(data_bus_width - 1 downto 0);

            begin

                -- Register Control
                if (ctrl_bus_intern(REG_AOU_B) = '1') then
                    data_bus_intern <= REGS(0);
                end if;
                if (ctrl_bus_intern(REG_AIN_B) = '1') then
                    REGS(0) <= data_bus_intern;
                end if;
                if (ctrl_bus_intern(REG_BOU_B) = '1') then
                    data_bus_intern <= REGS(1);
                end if;
                if (ctrl_bus_intern(REG_BIN_B) = '1') then
                    REGS(1) <= data_bus_intern;
                end if;
                -- Memory Register Control
                if (ctrl_bus_intern(MEM_ARO_B) = '1') then
                    data_bus_intern <= memory_address_r(data_bus_width - 1 downto 0);
                end if;
                if (ctrl_bus_intern(MEM_ARI_B) = '1') then
                    memory_address_r(data_bus_width - 1 downto 0) <= data_bus_intern;
                end if;

                -- Instruction Register Control
                if (ctrl_bus_intern(INST_R_OUT) = '1') then
                    data_bus <= instruction_reg;
                end if;
                if (ctrl_bus_intern(INST_R_IN) = '1') then
                    instruction_reg <= data_bus;
                end if;

                -- Register Swap Control
                if (ctrl_bus_intern(SWP_REG_B) = '1') then
                    temp := REGS(0);
                    REGS(0) <= REGS(1);
                    REGS(1) <= temp;
                end if;

                -- Status Flag Control
                if (ctrl_bus_intern(STF_OUT_B) = '1') then
                    data_bus_intern <= (data_bus_width - 1 downto NUM_FLAGS + 1 => '0') & status_registers;
                end if;
                if (ctrl_bus_intern(STF_IN_B) = '1') then
                    status_registers <= data_bus_intern(NUM_FLAGS - 1 downto 0);
                end if;
                if (ctrl_bus_intern(CLR_STF_B) = '1') then
                    status_registers <= (others => '0');
                end if;

        end process p_ctrl;

        -- Stack Pointer Control Process
        p_sp_control : process(ctrl_bus)

            variable sp_temp : std_logic_vector(addr_bus_width - 1 downto 0) := stack_pointer;

            begin

                -- TODO Addierer und Subtrahierer implementieren
                if (ctrl_bus_intern(SP_INC) = '1') then
                    sp_temp := std_logic_vector(unsigned(sp_temp) + 1);
                end if;
                if (ctrl_bus_intern(SP_DEC) = '1') then
                    sp_temp := std_logic_vector(unsigned(sp_temp) - 1);
                end if;

                -- Stack Pointer Control
                if (ctrl_bus_intern(SP_OUT) = '1') then
                    data_bus_intern <= sp_temp(data_bus_width - 1 downto 0);
                end if;

        end process p_sp_control;

        -- Bus Output Process
        -- p_bus : process(master_clk)
        --
        --     begin
        --
        --         hold_a <= '0';
        --
        --         if (hold = '0') then
        --
        --             if (bus_enable = '1') then
        --
        --                 data_bus <= data_bus_intern;
        --                 ctrl_bus <= ctrl_bus_intern;
        --                 addr_bus <= addr_bus_intern;
        --
        --             else
        --
        --                 data_bus <= (others => 'Z');
        --                 ctrl_bus <= (others => 'Z');
        --                 addr_bus <= (others => 'Z');
        --
        --             end if;
        --
        --         else
        --
        --             data_bus <= (others => 'Z');
        --             ctrl_bus <= (others => 'Z');
        --             addr_bus <= (others => 'Z');
        --
        --             hold_a <= '1';
        --
        --         end if;
        --
        -- end process p_bus;

        -- (Asynchronoous) Reset Process
        p_reset : process(ctrl_bus)

            begin

                if rising_edge(ctrl_bus(RESET_CTL)) then

                    stack_pointer       <= STACK_POINTER_START;
                    program_counter     <= PROG_START;
                    status_registers    <= (others => '0');

                    memory_address_r    <= (others => '0');

                    instruction_reg     <= (others => '0');

                    REGS                <= (others => (others => '0'));
                    ALU_CTRL_REG        <= (others => '0');
                    ALU_IN_FLAGS        <= (others => '0');

                end if;

        end process p_reset;

end structure;
