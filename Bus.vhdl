library ieee;
    use ieee.std_logic_1164.all;

entity bus is
    port(
        clk      : in std_logic;
        ctrl     : inout std_logic_vector(regWidth - 1 downto 0);
        data     : inout std_logic_vector(regWidth - 1 downto 0);
        addr     : inout std_logic_vector(regWidth - 1 downto 0)
    );
end bus;
