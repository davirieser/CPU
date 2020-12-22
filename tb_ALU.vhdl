use work.CPU_pkg.all;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_ALU is
end tb_ALU;

architecture behaviour of tb_ALU is

    signal clk_s    : std_logic         := '0';
    signal reset    : std_logic         := '0';

    signal result_int   : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal stat_out_int : std_logic_vector(numStatReg - 1 downto 0) := (others => '0');

	signal sOperand1	: std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
	signal sOperand2	: std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');

    component ALU is
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
    end component ALU;

    begin

        uut : entity work.ALU port map(
                                    clk	    	=> clk_s,
                                    ctrl        => (others => '0'),
                                    operand1    => sOperand1,
                                    operand2    => sOperand2,
									oper_flags	=> (others => '0'),
                                    result      => result_int,
                                    status_out  => stat_out_int
                                );

		Signal_gen : process

			variable sTemp 		: std_logic_vector((2 * data_bus_width) - 1 downto 0) := (others => '0');

			begin

				sOperand1 <= sTemp(data_bus_width - 1 downto 0);
				sOperand2 <= sTemp((2 * data_bus_width) - 1 downto data_bus_width);

				wait for base_clock;

                for sCount in 0 to ((2 ** (2 * data_bus_width)) - 1) loop

					sTemp := std_logic_vector( unsigned(sTemp) + 1 );

					sOperand1 <= sTemp(data_bus_width - 1 downto 0);
					sOperand2 <= sTemp((2 * data_bus_width) - 1 downto data_bus_width);

                    wait for base_clock;

                end loop;

				wait;

		end process Signal_gen;

end behaviour;
