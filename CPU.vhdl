library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity CPU is
    port(
        -- In/Outputs for Busses
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
        ext_bus     : inout std_logic_vector(ext_bus_width  - 1 downto 0);
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0)
    );
end CPU;

architecture structure of CPU is

    -- Clock Declarations

    signal master_clk   : std_logic := '0';
    signal clk_divs     : std_logic_vector(NUM_MICRO_CYC downto 0) := (others => '0');
    signal inst_clk     : std_logic := '0';

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
    signal internal_hold    : std_logic := '0';

    signal memory_address_r : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    signal instruction_reg  : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal inst_dec_reg     : std_logic_vector(OPCODE_BITS + NUM_FLAGS - 1 downto 0) := (others => '0');

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
            addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0);
            ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
            -- Program Counter Overflow
            cnt_overf   : out std_logic
        );
    end component ProgCounter;

    component INST_DEC is
        port(
            inst        : in std_logic_vector(OPCODE_BITS + NUM_FLAGS - 1 downto 0);
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
            hold    : in std_logic;
            outp    : out std_logic_vector(NUM_MICRO_CYC - 1 downto 0)
        );
    end component CLK_DIVIDER;

    begin

        -- Clock Instantiation

        -- Connnect Reset and Clock to CTRL_BUS

        master_clk  <= ext_bus(I_CLOCK);
        clk_divs(0) <= ext_bus(I_CLOCK);
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

        inst_dec_reg <=
            instruction_reg(data_bus_width - 1 downto data_bus_width - OPCODE_BITS)
            & status_registers;

        inst_dec_ins : entity work.INST_DEC port map(
            inst        => inst_dec_reg,
            flags_in    => ALU_OUT_FLAGS,
            micro_cyc   => clk_divs(NUM_MICRO_CYC downto 1),
            alu_ctrl    => ALU_CTRL_REG,
            ctrl_bus    => ctrl_bus_intern
        );

        clk_div_ins : entity work.CLK_DIVIDER port map(
            reset   => ctrl_bus_intern(I_INST_OVER),
            clk     => master_clk,
            hold    => internal_hold,
            outp    => clk_divs(NUM_MICRO_CYC downto 1)
        );

        prog_count_ins : entity work.ProgCounter port map(
            clk      => master_clk,
            addr_bus => addr_bus_intern,
            ctrl_bus => ctrl_bus_intern,
            -- Program Counter Overflow
            cnt_overf => prog_cnt_ovf_reg
        );

        -- Helper Processes ----------------------------------

        -- Control Register Output Process
        p_ctrl : process(ctrl_bus_intern,data_bus_intern)

            variable temp : std_logic_vector(data_bus_width - 1 downto 0);

            begin

                -- Register Control
                if (ctrl_bus_intern(I_REG_AOU) = '1') then
                    data_bus_intern <= REGS(0);
                else
                    data_bus_intern <= (others => 'Z');
                end if;
                if (ctrl_bus_intern(I_REG_AIN) = '1') then
                    REGS(0) <= data_bus_intern;
                else
                    REGS(0) <= REGS(0);
                end if;
                if (ctrl_bus_intern(I_REG_BOU) = '1') then
                    data_bus_intern <= REGS(1);
                else
                    data_bus_intern <= (others => 'Z');
                end if;
                if (ctrl_bus_intern(I_REG_BIN) = '1') then
                    REGS(1) <= data_bus_intern;
                else
                    REGS(1) <= REGS(1);
                end if;
                -- Memory Register Control
                if (ctrl_bus_intern(I_MEM_ARO) = '1') then
                    addr_bus_intern <= memory_address_r;
                else
                    addr_bus_intern <= (others => 'Z');
                end if;
                -- TODO Memory Address Register In
                if (ctrl_bus_intern(I_MEM_ARI_L) = '1') then
                    memory_address_r <= addr_bus_intern;
                elsif (ctrl_bus_intern(I_MEM_ARI_H) = '1') then
                    memory_address_r <= addr_bus_intern;
                else
                    memory_address_r <= memory_address_r;
                end if;

                -- Instruction Register Control
                if (ctrl_bus_intern(I_INST_R_OUT) = '1') then
                    data_bus_intern <= instruction_reg;
                else
                    data_bus_intern <= (others => 'Z');
                end if;
                if (ctrl_bus_intern(I_INST_R_IN) = '1') then
                    instruction_reg <= data_bus_intern;
                else
                    instruction_reg <= instruction_reg;
                end if;

                -- Register Swap Control
                if (ctrl_bus_intern(I_SWP_REG) = '1') then
                    temp := REGS(0);
                    REGS(0) <= REGS(1);
                    REGS(1) <= temp;
                end if;

                -- Status Flag Control
                if (ctrl_bus_intern(I_STF_OUT) = '1') then
                    data_bus_intern <= (data_bus_width - 1 downto NUM_FLAGS + 1 => '0') & status_registers;
                elsif (ctrl_bus_intern(I_STF_IN) = '1') then
                    status_registers <= data_bus_intern(NUM_FLAGS - 1 downto 0);
                elsif (ctrl_bus_intern(I_CLR_STF) = '1') then
                    status_registers <= (others => '0');
                end if;

        end process p_ctrl;

        -- Stack Pointer Control Process
        p_sp_control : process(ctrl_bus_intern)

            variable sp_temp : std_logic_vector(addr_bus_width - 1 downto 0) := stack_pointer;

            begin

                -- TODO Addierer und Subtrahierer implementieren
                if (ctrl_bus_intern(I_SP_INC) = '1') then
                    sp_temp := std_logic_vector(unsigned(sp_temp) + 1);
                end if;
                if (ctrl_bus_intern(I_SP_DEC) = '1') then
                    sp_temp := std_logic_vector(unsigned(sp_temp) - 1);
                end if;

                -- Stack Pointer Control
                if (ctrl_bus_intern(I_SP_OUT) = '1') then
                    data_bus_intern <= sp_temp(data_bus_width - 1 downto 0);
                end if;

        end process p_sp_control;

        -- Hold-Signal Generation
        p_hold_gen : process(ext_bus,ctrl_bus_intern)

            begin

                if (ext_bus(I_WAIT) = '1') then
                    internal_hold <= '1';
                elsif (
                    (ctrl_bus_intern(I_WF_MEM_RD) = '1') and
                    (not (ext_bus(I_MEM_RD_READY) = '1'))
                ) then
                    internal_hold <= '1';
                elsif (ext_bus(I_DMA_HOLD) = '1') then
                    internal_hold <= '1';
                else
                    internal_hold <= '0';
                end if;

        end process p_hold_gen;

        -- ---------------------------------------------------------------------
        -- Debug-Process -------------------------------------------------------
        -- ---------------------------------------------------------------------

        p_debug : process(ext_bus)

            begin

                if (CPU_DEBUG) then

                    if (ext_bus(I_WAIT) = '1') then
                        report "Waiting";
                        internal_hold <= '1';
                    elsif (
                        (ctrl_bus_intern(I_WF_MEM_RD) = '1') and
                        (not (ext_bus(I_MEM_RD_READY) = '1'))
                    ) then
                        report "Waiting for Extern Memory";
                    elsif (ext_bus(I_DMA_HOLD) = '1') then
                        report "Waiting for DMA";
                        internal_hold <= '1';
                    else
                        internal_hold <= '0';
                    end if;

                    -- Stack Pointer Control
                    if (ctrl_bus_intern(I_SP_INC) = '1') then
                        report "Overriding Stack Pointer";
                    end if;
                    if (ctrl_bus_intern(I_SP_DEC) = '1') then
                        report "Decreasing Stack Pointer";
                    end if;
                    if (ctrl_bus_intern(I_SP_OUT) = '1') then
                        report "Outputting Stack Pointer";
                    end if;

                    -- Register Control
                    if (ctrl_bus_intern(I_REG_AOU) = '1') then
                        report "Outputting Register A";
                    end if;
                    if (ctrl_bus_intern(I_REG_AIN) = '1') then
                        report "Overriding Register A";
                    end if;
                    if (ctrl_bus_intern(I_REG_BOU) = '1') then
                        report "Outputting Register B";
                    end if;
                    if (ctrl_bus_intern(I_REG_BIN) = '1') then
                        report "Overriding Register B";
                    end if;
                    -- Memory Register Control
                    if (ctrl_bus_intern(I_MEM_ARO) = '1') then
                        report "Outputting Memory-Address-Register";
                    end if;
                    if (ctrl_bus_intern(I_MEM_ARI_L) = '1') then
                        report "Overriding Low Memory Register Bits";
                    end if;
                    if (ctrl_bus_intern(I_MEM_ARI_H) = '1') then
                        report "Overriding High Memory Register Bits";
                    end if;

                    -- Instruction Register Control
                    if (ctrl_bus_intern(I_INST_R_OUT) = '1') then
                        report "Outputting Instruction-Register";
                    end if;
                    if (ctrl_bus_intern(I_INST_R_IN) = '1') then
                        report "Overriding Instruction-Register";
                    end if;

                    -- Register Swap Control
                    if (ctrl_bus_intern(I_SWP_REG) = '1') then
                        report "Swapping Registers";
                    end if;

                    -- Status Flag Control
                    if (ctrl_bus_intern(I_STF_OUT) = '1') then
                        report "Outputting Status Registers";
                    elsif (ctrl_bus_intern(I_STF_IN) = '1') then
                        report "Overriding Status Registers";
                    elsif (ctrl_bus_intern(I_CLR_STF) = '1') then
                        report "Clearing Status Registers";
                    end if;

                end if;

        end process p_debug;

end structure;
