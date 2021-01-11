
library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity MemoryManager is
    port (
        mem_addr_r  : in std_logic_vector(addr_bus_width - 1 downto 0);
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0)
    );
end MemoryManager;

architecture behaviour of MemoryManager is

    constant READ_BIT   : std_logic := '0';
    constant WRITE_BIT  : std_logic := '1';

    type ENABLE_SIG_T is array(NUM_MEMORY_DEVICES - 1 downto 0) of std_logic;
    signal ena_intern   : ENABLE_SIG_T := (others => '0');
    signal rd_wr_s      : std_logic := READ_BIT;

    -- Memory Output Bus
    signal mem_out_bus  : std_logic_vector(data_bus_width - 1 downto 0) := (others => 'Z');
    signal addr_bus_cor : std_logic_vector(addr_bus_width - 1 downto 0) := (others => 'Z');

    component EEPROM is
        port(
            -- Clock Input
            clk         : in std_logic;
            -- Enable Input -> wheter Read-Action should occur or not
            ena         : in std_logic;
            -- Address Input -> The Address which is to be read
            addr_in     : in std_logic_vector(addr_bus_width - 1 downto 0);
            -- Data Output -> Connected to Data-Bus
            data        : out std_logic_vector(data_bus_width - 1 downto 0)
        );
    end component EEPROM;

    component RAM is
        port(
            -- Clock Input
            clk         : in std_logic;
            -- Enable Input -> Wheter the RAM should act or not
            ena         : in std_logic;
            -- Read/Write Input -> '0' => Read , '1' => Write
            rd_wr_in    : in std_logic;
            -- Address Input -> The Address which is to be read
            addr_in     : in std_logic_vector(addr_bus_width - 1 downto 0);
            -- Data In/Output -> Connected to Data-Bus
            data        : inout std_logic_vector(data_bus_width - 1 downto 0)
        );
    end component RAM;

    begin

        eeprom_inst : entity work.EEPROM port map(
            clk => ctrl_bus(CLOCK_CTL),
            ena => ena_intern(ROM_MEM_INDEX),
            addr_in => addr_bus_cor,
            data => mem_out_bus
        );

        ram_inst : entity work.RAM port map(
            clk => ctrl_bus(CLOCK_CTL),
            ena => ena_intern(RAM_MEM_INDEX),
            rd_wr_in => rd_wr_s,
            addr_in => addr_bus_cor,
            data => mem_out_bus
        );

        p_ena : process(ctrl_bus)

            begin

                -- report "Memory Operation";

                -- if (rising_edge(ctrl_bus(CLOCK_CTL)) or
                --     falling_edge(ctrl_bus(CLOCK_CTL))) then

                    -- Set Read- / Write-Bit

                    if (ctrl_bus(MEM_RD_B) = '1') then

                        -- report "Memory Read";
                        rd_wr_s <= READ_BIT;

                    elsif (ctrl_bus(MEM_WRI_B) = '1') then

                        -- report "Memory Write";
                        rd_wr_s <= WRITE_BIT;

                    else

                        ena_intern <= (others => '0');
                        data_bus <= (others => 'Z');

                    end if;

                    -- Set Enable Bits

                    if ((ctrl_bus(MEM_RD_B) = '1') or (ctrl_bus(MEM_WRI_B) = '1')) then

                        for i in NUM_MEMORY_DEVICES - 1 downto 0 loop

                            -- report "Memory Check " & integer'image(i) &
                            -- " : " & integer'image(to_integer(unsigned(mem_addr_r)));

                            -- TODO Funktioniert glab i nit
                            if ((unsigned(mem_addr_r) >= unsigned(MEMORY_MAP(0).MEM_START))
                               and (unsigned(mem_addr_r) < unsigned(MEMORY_MAP(0).MEM_END))) then

                                -- report "Memory Enable " & integer'image(i);

                                ena_intern(0) <= '1';
                                addr_bus_cor <= std_logic_vector(unsigned(mem_addr_r) - unsigned(MEMORY_MAP(0).MEM_START));

                            else

                                ena_intern(0) <= '0';

                            end if;

                        end loop;

                    else

                        ena_intern <= (others => '0');

                    end if;

        end process p_ena;

        data_bus <= mem_out_bus;

end behaviour;
