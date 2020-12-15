use work.CPU_pkg.all;

library ieee;
	use ieee.std_logic_1164.all;

entity tb_ALU is
end tb_ALU;

architecture behaviour of tb_ALU is

    signal clk_s    : std_logic         := '0';
    signal reset    : std_logic         := '0';

    signal result_int   : std_logic_vector(data_bus_width - 1 downto 0);
    signal stat_out_int : std_logic_vector(numStatReg - 1 downto 0);

    component ALU is
        port(
            -- Clock Input
            clk         : in  std_logic;
            -- Input for OPCODE -> tells the ALU which command to execute
            ctrl        : in  std_logic_vector(OPCODE_LEN - 1 downto 0);
            -- Inputs for both Operands
            operand1    : in  std_logic_vector(data_bus_width - 1 downto 0);
            operand2    : in  std_logic_vector(data_bus_width - 1 downto 0);
            -- Status Input Flags -> See CPU_pkg
            -- Should the result work as a cyclic buffer
            cycle_flag  : in std_logic;
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
                                    operand1    => (others => '0'),
                                    operand2    => (others => '0'),
                                    cycle_flag  => '0',
                                    result      => result_int,
                                    status_out  => stat_out_int
                                );

        SCK : process
		begin
			clk_s <= '1';
			for clk_cnt_s in 0 to 10 loop
				clk_s 		<= not clk_s;
				wait for base_clock / 2;
				clk_s 		<= not clk_s;
				wait for base_clock / 2;
			end loop;
			wait;
		end process SCK;


end behaviour;
