
use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity ALU is
    port(
        -- Clock Input
        clk         : in  std_logic;
        -- Input for OPCODE -> tells the ALU which command to execute
        ctrl        : in  std_logic_vector(ctrl_bus_width - 1 downto 0);
        -- Inputs for both Operands
        operand1    : in  std_logic_vector(data_bus_width - 1 downto 0);
        operand2    : in  std_logic_vector(data_bus_width - 1 downto 0);
        -- Flags for the Arithmetic Operations
        oper_flags  : in  std_logic_vector(oper_flag_num - 1 downto 0);
        -- result of the Operation
        result      : out std_logic_vector(data_bus_width - 1 downto 0);
        -- Status Output Flags -> See CPU_pkg
        status_out  : out std_logic_vector(numStatReg - 1 downto 0)
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

    signal status_out_int   : std_logic_vector(numStatReg - 1 downto 0) := (others => '0');

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

        TEMP_PARITY(0) <= int_result(0);

        Parity : for i in 1 to data_bus_width - 1 generate
            TEMP_PARITY(i) <= int_result(i) xor TEMP_PARITY(i-1);
        end generate Parity;

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
                aCarry      => status_out(4)
            )
        ;

        int_shift   : entity work.ShiftRegister
            generic map(
                regWidth    => data_bus_width,
                -- TODO Wo anders ausrechenen
                crtl_bits   => 3
            )
            port map(
                inputA      => operand1,
                inputB      => operand2,
                -- TODO cyclic Buffer Flag
                cyclicBuffer=> '0',
                aOutput     => SHIFT_OUT
            )
        ;

        parity_gen : process(clk)

            begin

                if(int_result(0) = 'Z') then
                    RES_EVEN_PARITY <= '1';
                    RES_ODD_PARITY <= '0';
                else
                    RES_EVEN_PARITY <= TEMP_PARITY(data_bus_width - 1);
                    RES_ODD_PARITY <= not RES_EVEN_PARITY;
                end if;

        end process parity_gen;

        output_gen : process(clk)

            begin

                -- TODO Mit Multiplexer synthetisieren?
                -- Is halt um einiges Code aufwendiger und bringt am Ende auch nix
                case ctrl(7 downto 4) is
                    WHEN "0000" => int_result <= RES_AND;
                    WHEN "0001" => int_result <= RES_OR;
                    WHEN "0010" => int_result <= RES_XOR;
                    WHEN "0011" => int_result <= RES_NOT_A;
                    WHEN "0100" => int_result <= RES_NOT_B;
                    WHEN "0101" => int_result <= ADD_OUT;
                    WHEN "0110" => int_result <= SUB_OUT;
                    WHEN "0111" => int_result <= SHIFT_OUT;
                    WHEN "1000" => int_result <= (data_bus_width - 1 downto 2 => '0') & RES_ODD_PARITY & RES_EVEN_PARITY;
                    -- Auf 'Z' gesetzt damit die CPU den Datenbus nicht durchgehend besetzt
                    WHEN others => int_result <= (others => 'Z');
                end case;

        end process output_gen;

        status_out <= status_out_int;
        result <= int_result;

end behaviour;
