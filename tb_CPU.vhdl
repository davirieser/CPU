use work.CPU_pkg.all;

library ieee;
	use ieee.std_logic_1164.all;

entity tb_CPU is
end tb_CPU;

architecture behaviour of tb_CPU is

    signal clk_s    : std_logic         := '0';
    signal reset    : std_logic         := '0';

    signal data_bus_intern  : std_logic_vector(data_bus_width - 1 downto 0);
    signal ctrl_bus_intern  : std_logic_vector(ctrl_bus_width - 1 downto 0);
    signal addr_bus_intern  : std_logic_vector(addr_bus_width - 1 downto 0);

    component CPU is
        port(
            reset       : in std_logic;
            -- Clock Input
            clk         : in    std_logic;
            -- Input for OPCODE
            OPCODE      : in    std_logic_vector(ctrl_bus_width - 1 downto 0);
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
    end component CPU;

    begin

        uut : entity work.CPU port map(
                                    reset       => reset,
                                    clk	    	=> clk_s,
                                    OPCODE      => (others => '0'),
                                    data_bus    => data_bus_intern,
                                    ctrl_bus    => ctrl_bus_intern,
                                    addr_bus    => addr_bus_intern,
                                    ready       => '0',
                                    int_req     => '0',
                                    bus_enable  => '0'
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
