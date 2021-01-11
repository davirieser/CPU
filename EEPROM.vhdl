library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity EEPROM is
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
end EEPROM;

architecture behaviour of EEPROM is

    type MEMORY_T is array(0 to ROM_SIZE) of std_logic_vector(data_bus_width - 1 downto 0);

    signal memory : MEMORY_T := (others => (
        data_bus_width -1 downto data_bus_width -3 => '1',
        others => '0')
    );

    begin

        -- TODO Sollte des Ding ueberhaupt geclockt sein?
        -- TODO Sollt des auf ena-Input gecheckt werden?
        READ : process(ena)

            begin

                if (ena = '1') then
                    -- report "EEPROM Out";
                    data <= memory(to_index(addr_in));
                else
                    data <= (others => 'Z');
                end if;

        end process READ;

end behaviour;
