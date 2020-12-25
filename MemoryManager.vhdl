
library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;


entity MemoryManager is
    port (
        ena         : in std_logic;
        rd_wr       : in std_logic;
        address     : in std_logic_vector(addr_bus_width - 1 downto 0);
        data        : inout std_logic_vector(data_bus_width - 1 downto 0)
    );
end MemoryManager;

architecture behaviour of MemoryManager is

    begin

        mem : process(ena,rd_wr,address)

            begin

                if (ena = '1') then

                    if (rd_wr = '0') then

                        -- TODO Implement EEPROM, RAM and EXT_MEM

                        data <= mem(to_index(address))

                    else

                        -- TODO Implement EEPROM, RAM and EXT_MEM

                        mem(to_index(address)) <= data;

                    end if;

                else

                    data <= (others => 'Z');

                end if;

        end process mem;

end behaviour;
