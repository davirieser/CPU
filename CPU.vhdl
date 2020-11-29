
use library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity CPU is
    port(
        clk         : in std_logic;
        -- TODO Busbreite ist nicht das gleiche wie die Anzhal der Befehle
        -- Muss man nochmal seperat definieren
        OPCODE      : in    std_logic_vector(NUM_OPCODES);
        -- TODO Busse sollten nicht gleich breit sein
        data_bus    : inout std_logic_vector(bus_width - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(bus_width - 1 downto 0);
        addr_bus    : inout std_logic_vector(bus_width - 1 downto 0);
        -- Turn on or off if the CPU is able to access the bus
        bus_enable : in std_logic
    );
end CPU;

architecture structure of CPU is



end structure;
