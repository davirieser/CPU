
library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;


entity MemoryManager is
    port (
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0)
    );
end MemoryManager;

architecture behaviour of MemoryManager is

    begin

        mem : process(ctrl_bus,addr_bus,data_bus)

            variable temp   : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');

            begin

                if (ctrl_bus(MEM_RD_B) = '1') then

                    -- TODO Implement EEPROM, RAM and EXT_MEM

                    -- data_bus <= mem(to_index(addr_bus));

                    data_bus <= temp;

                elsif (ctrl_bus(MEM_WRI_B) = '1') then

                    -- TODO Implement EEPROM, RAM and EXT_MEM

                    -- mem(to_index(addr_bus)) <= data_bus;

                    temp := data_bus;

                else

                    data_bus <= (others => 'Z');

                end if;

        end process mem;

end behaviour;
