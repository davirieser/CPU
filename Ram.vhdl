library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity RAM is
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
end RAM;

architecture behaviour of RAM is

    type MEMORY_TYPE is array(0 to RAM_SIZE) of std_logic_vector(data_bus_width - 1 downto 0);

    signal memory : MEMORY_TYPE := (others => (7 => '1',others => '0'));

    begin

        -- TODO Sollte des Ding ueberhaupt geclockt sein?
        -- TODO Sollt des aud ena-Input gecheckt werden?
        PRO : process(clk)

            begin

                if ena = '1' then
                    if rd_wr_in = '1' then
                        report "RAM Out";
                        data <= memory(to_index(addr_in));
                    else
                        report "RAM In";
                        memory(to_index(addr_in)) <= data;
                    end if;
                else
                    data <= (others => 'Z');
                end if;

        end process PRO;

end behaviour;
