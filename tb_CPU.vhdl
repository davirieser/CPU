use work.CPU_pkg.all;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_CPU is
end tb_CPU;

architecture behaviour of tb_CPU is

	signal reset    : std_logic		:= '0';
    signal cpu_clk	: std_logic		:= '0';
    signal ext_clk	: std_logic		:= '0';

	signal hold_a_s	: std_logic		:= '0';
	signal wait_s	: std_logic		:= '0';

	signal data_ready 	: std_logic := '0';

    signal data_bus_intern  : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal ext_bus_intern  	: std_logic_vector(ext_bus_width - 1 downto 0) 	:= (others => '0');
    signal addr_bus_intern  : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

	component CPU is
	    port(
	        -- In/Outputs for Busses
	        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
	        ext_bus     : inout std_logic_vector(ext_bus_width  - 1 downto 0);
	        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0)
	    );
	end component CPU;

	component MEMORY is
	    generic(
	        WRITABLE : std_logic := WRITE_ENABLE;
	        MEM_START   : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '1');
	        MEM_END : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '1')
	    );
	    port(
	        -- Clock Input
	        clk         : in std_logic;
	        -- Enable Input -> Tells the Memory if it should take Action
	        ena         : in std_logic;
	        -- Read/Write Input : Only for Writable Memories
	        rd_wr       : in std_logic;
	        -- Address Input -> The Address which is to be read
	        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0);
	        -- Data In/Output -> Connected to Data-Bus
	        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
	        -- Data ready
	        data_ready  : out std_logic
	    );
	end component MEMORY;

    begin

        uut : entity work.CPU port map(
            data_bus    => data_bus_intern,
            ext_bus     => ext_bus_intern,
            addr_bus    => addr_bus_intern
        );

		addr_bus_intern <= (others => 'Z');
		data_bus_intern <= (others => 'Z');
		ext_bus_intern <= (I_CLOCK => cpu_clk, others => 'Z');

		-- TODO Throws Error
		MEM : for i in NUM_MEMORY_DEVICES - 1 downto 0 generate

			begin

				MEMORIES : entity work.MEMORY
				generic map(
					WRITABLE => MEMORY_MAP(0).WRITABLE,
					MEM_START => MEMORY_MAP(0).MEM_START,
					MEM_END => MEMORY_MAP(0).MEM_END
				)
				port map(
					clk => ext_clk,
					ena => ext_bus(I_MEM_RD) or ext_bus(I_MEM_WRI),
					rd_wr => checkRDWR( ext_bus(I_MEM_RD),ext_bus(I_MEM_WRI)),
					addr_bus => addr_bus_intern,
					data_bus => data_bus_intern,
					data_ready => data_ready
				);

		end generate MEM;

        SCK : process
		begin
			wait for base_clock / 2;
			for clk_cnt_s in 0 to (2 ** OPCODE_BITS) loop
				cpu_clk 	<= not cpu_clk;
				wait for base_clock / 4;
				ext_clk 	<= not ext_clk;
				wait for base_clock / 4;
			end loop;
			wait;
		end process SCK;

end behaviour;
