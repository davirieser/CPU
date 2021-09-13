
use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity ALU is
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
        status_out  : out std_logic_vector(NUM_FLAGS - 1 downto 0) := (others => '0')
    );
end ALU;

architecture behaviour of ALU is

    constant all_zeros  : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    constant all_ones   : std_logic_vector(data_bus_width - 1 downto 0) := (others => '1');

    -- Ergebnisleitung fuer logische Verknuepfungen der Register
    signal RES_AND          : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal RES_NAND         : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal RES_OR           : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal RES_XOR          : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal RES_NOR          : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal RES_XNOR         : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal RES_NOT_A        : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal RES_NOT_B        : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');

    signal RES_EQ           : std_logic     := '0';
    signal RES_EVEN_PARITY  : std_logic     := '0';
    signal RES_ODD_PARITY   : std_logic     := '0';

    signal ADD_OUT          : std_logic_vector(data_bus_width - 1 downto 0);
    signal SUB_OUT          : std_logic_vector(data_bus_width - 1 downto 0);
    signal SHIFT_OUT        : std_logic_vector(data_bus_width - 1 downto 0);

    signal TEMP_PARITY      : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');

    signal int_result       : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');

    signal status_out_int   : std_logic_vector(NUM_FLAGS - 1 downto 0) := (others => '0');

    component Adder is
		generic(
			regWidth 		: integer
		);
	    port(
	        inputA  		: in  std_logic_vector(data_bus_width - 1 downto 0);
	        inputB  		: in  std_logic_vector(data_bus_width - 1 downto 0);
			carryIn			: in  std_logic;
	        aOutput 		: out std_logic_vector(data_bus_width - 1 downto 0);
	        aCarry          : out std_logic_vector(data_bus_width - 1 downto 0)
	    );
	end component Adder;

    component Subtractor is
    	generic(
    		regWidth 		: integer
    	);
        port(
            carryIn         : in  std_logic;
            inputA  		: in  std_logic_vector(regWidth - 1 downto 0);
            inputB  		: in  std_logic_vector(regWidth - 1 downto 0);
            aOutput   		: out std_logic_vector(regWidth - 1 downto 0);
            aCarry          : out std_logic
        );
    end component Subtractor;

    component ShiftRegister is
    	generic(
    		regWidth 		: integer;
            crtl_bits       : integer
    	);
        port(
            inputA  		: in  std_logic_vector(regWidth - 1 downto 0);
            inputB  		: in  std_logic_vector(regWidth - 1 downto 0);
            cyclicBuffer    : in  std_logic;
            aOutput   		: out std_logic_vector(regWidth - 1 downto 0)
        );
    end component ShiftRegister;

    begin

        RES_AND     <= operand1 and operand2;
        RES_NAND    <= operand1 nand operand2;
        RES_OR      <= operand1 or operand2;
        RES_XOR     <= operand1 xor operand2;
        RES_NOR     <= operand1 nor operand2;
        RES_XNOR    <= operand1 xnor operand2;
        RES_NOT_A   <= not operand1;
        RES_NOT_B   <= not operand2;

        int_adder : entity work.Adder
    		generic map(
    			regWidth 	=> data_bus_width
    		)
    		port map(
    			inputA 		=> operand1,
    			inputB 		=> operand2,
                -- Theoretisch in diesem Fall nicht notwendig
    			carryIn		=> '0',
    			aOutput 	=> ADD_OUT,
    			aCarry 	    => status_out_int(0)
            )
    	;

        int_sub : entity work.Subtractor
            generic map(
                regWidth    => data_bus_width
            )
            port map(
                carryIn     => '0',
                inputA      => operand1,
                inputB      => operand2,
                aOutput     => SUB_OUT,
                -- Negative Flag
                aCarry      => status_out_int(4)
            )
        ;

        int_shift   : entity work.ShiftRegister
            generic map(
                regWidth    => data_bus_width,
                crtl_bits   => WORD_ADDR_DIST
            )
            port map(
                inputA      => operand1,
                inputB      => operand2,
                -- TODO cyclic Buffer Flag
                cyclicBuffer=> flags(CYC_BUFFER_ENA),
                aOutput     => SHIFT_OUT
            )
        ;

        TEMP_PARITY(0) <= int_result(0);

        Parity : for i in 1 to data_bus_width - 1 generate
            TEMP_PARITY(i) <= int_result(i) xor TEMP_PARITY(i-1);
        end generate Parity;

        parity_gen : process(TEMP_PARITY)

            begin

                if(int_result(0) = 'Z') then
                    RES_EVEN_PARITY <= '1';
                    RES_ODD_PARITY <= '0';
                else
                    RES_EVEN_PARITY <= TEMP_PARITY(data_bus_width - 1);
                    RES_ODD_PARITY <= not RES_EVEN_PARITY;
                end if;

        end process parity_gen;

        output_gen : process(ctrl_bus)

            begin

                if (ctrl_bus(I_ALU_RSO) = '1') then

                    if (ctrl = AND_CODE) then
                        int_result <= RES_AND;
                    elsif (ctrl = OR_CODE) then
                        int_result <= RES_OR;
                    elsif (ctrl = XOR_CODE) then
                        int_result <= RES_XOR;
                    elsif (ctrl = NOT_A_CODE) then
                        int_result <= RES_NOT_A;
                    elsif (ctrl = NOT_B_CODE) then
                        int_result <= RES_NOT_B;
                    elsif (ctrl = ADD_CODE) then
                        int_result <= ADD_OUT;
                    elsif (ctrl = SUB_CODE) then
                        int_result <= SUB_OUT;
                    elsif (ctrl = SHIFT_CODE) then
                        int_result <= SHIFT_OUT;
                    elsif (ctrl = PARITY_CODE) then
                        int_result <= (data_bus_width - 1 downto 2 => '0') & RES_ODD_PARITY & RES_EVEN_PARITY;
                    else
                        int_result <= (others => 'Z');
                    end if;

                    -- case ctrl is
                    --     WHEN AND_CODE       => int_result <= RES_AND;
                    --     WHEN OR_CODE        => int_result <= RES_OR;
                    --     WHEN XOR_CODE       => int_result <= RES_XOR;
                    --     WHEN NOT_A_CODE     => int_result <= RES_NOT_A;
                    --     WHEN NOT_B_CODE     => int_result <= RES_NOT_B;
                    --     WHEN ADD_CODE       => int_result <= ADD_OUT;
                    --     WHEN SUB_CODE       => int_result <= SUB_OUT;
                    --     WHEN SHIFT_CODE     => int_result <= SHIFT_OUT;
                    --     WHEN PARITY_CODE    => int_result <= (data_bus_width - 1 downto 2 => '0') & RES_ODD_PARITY & RES_EVEN_PARITY;
                    --     -- Auf 'Z' gesetzt damit die CPU den Datenbus nicht durchgehend besetzt
                    --     WHEN others         => int_result <= (others => 'Z');
                    -- end case;

                else
                    int_result <= (others => 'Z');
                end if;

                if (ctrl_bus(I_ALU_FLAG) = '1') then
                    status_out <= status_out_int;
                elsif (ctrl_bus(I_ALU_F_CLR) = '1') then
                    status_out <= (others => '0');
                end if;

        end process output_gen;

        data_bus <= int_result;

        debug : process(ctrl_bus)

            begin

                if (ALU_DEBUG) then

                    if (ctrl_bus(I_ALU_RSO) = '1') then

                        if (ctrl = AND_CODE) then
                            report "ALU outputting AND-Result";
                        elsif (ctrl = OR_CODE) then
                            report "ALU outputting OR-Result";
                        elsif (ctrl = XOR_CODE) then
                            report "ALU outputting XOR-Result";
                        elsif (ctrl = NOT_A_CODE) then
                            report "ALU outputting NOT-A-Result";
                        elsif (ctrl = NOT_B_CODE) then
                            report "ALU outputting NOT-B-Result";
                        elsif (ctrl = ADD_CODE) then
                            report "ALU outputting Addition-Result";
                        elsif (ctrl = SUB_CODE) then
                            report "ALU outputting Subtraction-Result";
                        elsif (ctrl = SHIFT_CODE) then
                            report "ALU outputting Shift-Result";
                        elsif (ctrl = PARITY_CODE) then
                            report "ALU outputting Parity-Result";
                        else
                            report "Unknown ALU-Operation";
                        end if;
                    else
                        report "ALU in IDLE-State";
                    end if;

                    if (ctrl_bus(I_ALU_FLAG) = '1') then
                        report "Outputting ALU-Flags";
                    elsif (ctrl_bus(I_ALU_F_CLR) = '1') then
                        report "Clearing ALU-Flags";
                    end if;

                end if;

        end process debug;

end behaviour;
