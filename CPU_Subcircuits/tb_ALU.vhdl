use work.CPU_pkg.all;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_ALU is
end tb_ALU;

architecture behaviour of tb_ALU is

    signal result_int   	: std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal stat_out_int 	: std_logic_vector(NUM_FLAGS - 1 downto 0) := (others => '0');
	signal ctrl_bus_intern	: std_logic_vector(ctrl_bus_width - 1 downto 0) := (others => '0');
	signal flags			: std_logic_vector(NUM_OPER_FLAGS - 1 downto 0) := (others => '0');

	signal sOperand1		: std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
	signal sOperand2		: std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');

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

    begin

        uut : entity work.ALU port map(
                                    ctrl        => (others => '0'),
									flags		=> flags,
                                    operand1    => sOperand1,
                                    operand2    => sOperand2,
									ctrl_bus	=> ctrl_bus_intern,
                                    data_bus    => result_int,
                                    status_out  => stat_out_int
                                );

		Signal_gen : process

			variable sTemp 		: std_logic_vector((2 * data_bus_width) - 1 downto 0) := (others => '0');

			begin

				sOperand1 <= sTemp(data_bus_width - 1 downto 0);
				sOperand2 <= sTemp((2 * data_bus_width) - 1 downto data_bus_width);

				wait for base_clock;

				for sCount in 0 to ((2 ** (2 * data_bus_width)) - 1) loop
				-- for sCount in 0 to (2 ** (2 * data_bus_width) - 1) loop

					sTemp := std_logic_vector(unsigned(sTemp) + 1);

					sOperand1 <= sTemp(data_bus_width - 1 downto 0);
					sOperand2 <= sTemp((2 * data_bus_width) - 1 downto data_bus_width);

                    wait for base_clock;

                end loop;

				wait;

		end process Signal_gen;

end behaviour;
