use work.CPU_pkg.all;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_MEMORY is
end tb_MEMORY;

architecture behaviour of tb_MEMORY is

    constant MEMORY_ADDR_BITS   : integer := 5;

	constant MEM_END : std_logic_vector(addr_bus_width - 1 downto 0) := (MEMORY_ADDR_BITS => '1',others => '0');

    signal clk          : std_logic := '0';
    signal ext_bus      : std_logic_vector(ext_bus_width - 1 downto 0) := (others => 'Z');
    signal addr_bus     : std_logic_vector(addr_bus_width - 1 downto 0) := (others => 'Z');
    signal data_bus1    : std_logic_vector(data_bus_width - 1 downto 0) := (others => 'Z');
    signal data_bus2    : std_logic_vector(data_bus_width - 1 downto 0) := (others => 'Z');
    signal data_ready1  : std_logic := '0';
    signal data_ready2  : std_logic := '0';

    component MEMORY is
        generic(
            WRITABLE    : std_logic := WRITE_ENABLE;
            MEM_BITS    : integer;
            MEM_START   : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '1');
            MEM_END     : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '1')
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

        ROM : entity work.MEMORY
        generic map(
            WRITABLE => READ_BIT,
            MEM_BITS => MEMORY_ADDR_BITS,
            MEM_START => (others => '0'),
            MEM_END => MEM_END
        )
        port map(
            clk => clk,
            ext_bus => ext_bus,
            addr_bus => addr_bus,
            data_bus => data_bus1,
            data_ready => data_ready1
        );

        RAM : entity work.MEMORY
        generic map(
            WRITABLE => WRITE_BIT,
            MEM_BITS => MEMORY_ADDR_BITS,
            MEM_START => (others => '0'),
            MEM_END => MEM_END
        )
        port map(
            clk => clk,
            ext_bus => ext_bus,
            addr_bus => addr_bus,
            data_bus => data_bus2,
            data_ready => data_ready2
        );

        WRITE_TEST : process

            begin

				ext_bus <= (others => 'Z');

                addr_bus <= (others => 'Z');
                data_bus1 <= (others => 'Z');
                data_bus2 <= (others => 'Z');

				wait for base_clock/2;

	            addr_bus <= (3 => '1',others => '0');
	            data_bus1 <= (others => '0');
	            data_bus2 <= (others => '0');

                ext_bus(I_MEM_WRI) <= '1';

				wait for base_clock;

                for clk_cnt_s in (2 ** (MEMORY_ADDR_BITS - 1)) downto 0 loop
                    data_bus1 <= std_logic_vector(unsigned(data_bus1) + 1);
					data_bus2 <= std_logic_vector(unsigned(data_bus2) + 1);
                    addr_bus <= std_logic_vector(unsigned(addr_bus) + 1);
					wait for base_clock;
                end loop;

                addr_bus <= (others => 'Z');
                data_bus1 <= (others => 'Z');
                data_bus2 <= (others => 'Z');
                ext_bus(I_MEM_WRI) <= 'Z';

                wait;

        end process WRITE_TEST;

		READ_TEST : process

			begin

	            addr_bus <= (others => 'Z');
	            data_bus1 <= (others => 'Z');
	            data_bus2 <= (others => 'Z');

				wait for base_clock/2;

				wait for ((2 ** (MEMORY_ADDR_BITS - 1)) + 5) * base_clock;

                addr_bus <= (2 => '1',others => '0');
                ext_bus(I_MEM_RD) <= '1';

				wait for base_clock;

                for clk_cnt_s in (2 ** MEMORY_ADDR_BITS) downto 0 loop
                    addr_bus <= std_logic_vector(unsigned(addr_bus) + 1);
                    wait for base_clock;
                end loop;

				wait;

		end process READ_TEST;

        SCK : process
        begin
            wait for base_clock;
            for clk_cnt_s in 0 to (2 ** MEMORY_ADDR_BITS) loop
                clk 	<= not clk;
                wait for base_clock;
            end loop;
            wait;
        end process SCK;

end behaviour;
