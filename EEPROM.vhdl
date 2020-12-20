library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity EEPROM is
    port(
        -- Clock Input
        clk         : in std_logic;
        -- Enable Input -> wheter Read-Action should occur or not
        ena         : in std_logic;
        -- Address Input -> The Address which is to be read
        addr_in     : in std_logic_vector(ROM_ADDR_BITS - 1 downto 0);
        -- Data Output -> Connected to Data-Bus
        data_out    : out std_logic_vector(data_bus_width - 1 downto 0)
    );
end EEPROM;

architecture behaviour of EEPROM is

    type MEMORY is array(0 to ROM_SIZE) of std_logic_vector(data_bus_width - 1 downto 0);

    signal mem : MEMORY := (others => (others => '0'));

    begin

        -- TODO Sollte des Ding ueberhaupt geclockt sein?
        -- TODO Sollt des aud ena-Input gecheckt werden?
        READ : process(clk)

            begin

                if ena = '1' then
                    data_out <= mem(to_integer(unsigned(addr_in)));
                else
                    data_out <= (others => 'Z');
                end if;

        end process READ;

end behaviour;
