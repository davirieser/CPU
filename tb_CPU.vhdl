use work.CPU_pkg.all;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_CPU is
end tb_CPU;

architecture behaviour of tb_CPU is

    signal clk_s    : std_logic         := '0';
    signal reset    : std_logic         := '0';

	signal hold_a_s	: std_logic;
	signal wait_s	: std_logic;

    signal data_bus_intern  : std_logic_vector(data_bus_width - 1 downto 0);
    signal ctrl_bus_intern  : std_logic_vector(ctrl_bus_width - 1 downto 0);
    signal addr_bus_intern  : std_logic_vector(addr_bus_width - 1 downto 0);

	component CPU is
	    port(
	        reset       : in std_logic;
	        -- Clock Input
	        clk         : in    std_logic;
	        -- In/Outputs for Busses
	        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0) := (others => 'Z');
	        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0) := (others => 'Z');
	        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0) := (others => 'Z');
	        -- Interrupt-Request Pin -> Indicates that Interrupt has occured
	        int_req     : in std_logic;
	        -- Wait indicates that the CPU is not working
	        wait_o      : out std_logic;
	        -- Turn on or off if the CPU is able to access the bus
	        bus_enable  : in    std_logic;
	        -- Request that the DMA needs the Bus
	        hold        : in std_logic;
	        -- Confirmation that the CPU gave the Bus free
	        hold_a      : out std_logic
	    );
	end component CPU;

    begin

        uut : entity work.CPU port map(
                                    reset       => reset,
                                    clk	    	=> clk_s,
                                    data_bus    => data_bus_intern,
                                    ctrl_bus    => ctrl_bus_intern,
                                    addr_bus    => addr_bus_intern,
                                    int_req     => '0',
									wait_o		=> wait_s,
                                    bus_enable  => '0',
									hold		=> '0',
									hold_a		=> hold_a_s
                                );

		INST_GEN : process

			variable INST	: integer := 0;

			begin

				for i in 0 to ((2 ** OPCODE_BITS) - 1) loop

					INST := INST + 4;

					ctrl_bus_intern <= std_logic_vector(to_unsigned(INST,ctrl_bus_width));

					wait for base_clock;

				end loop;

				wait;

		end process INST_GEN;

        SCK : process
		begin
			clk_s <= '1';
			for clk_cnt_s in 0 to (2 ** OPCODE_BITS) loop
				clk_s 		<= not clk_s;
				wait for base_clock / 2;
				clk_s 		<= not clk_s;
				wait for base_clock / 2;
			end loop;
			wait;
		end process SCK;

end behaviour;
