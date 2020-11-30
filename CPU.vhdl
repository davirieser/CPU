use library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity CPU is
    port(
        clk         : in    std_logic;
        OPCODE      : in    std_logic_vector(NUM_OPCODES);
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0);
        -- Turn on or off if the CPU is able to access the bus
        bus_enable  : in    std_logic
    );
end CPU;

architecture structure of CPU is

    signal data_bus_intern : std_logic_vector(data_bus_width - 1 downto 0) := (others => '0');
    signal ctrl_bus_intern : std_logic_vector(ctrl_bus_width - 1 downto 0) := (others => '0');
    signal addr_bus_intern : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    begin

        if bus_enable = '1' then

            data_bus <= data_bus_intern;
            ctrl_bus <= ctrl_bus_intern;
            addr_bus <= addr_bus_intern;

        else

            data_bus <= (others => 'Z');
            ctrl_bus <= (others => 'Z');
            addr_bus <= (others => 'Z');

        end if;

end structure;
