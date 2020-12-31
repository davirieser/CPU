library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.Numeric_Std.all;

entity INST_DEC is
    port(
        clk         : in std_logic;
        inst        : in std_logic_vector(OPCODE_BITS - 1 downto 0);
        micro_cyc   : in std_logic_vector(NUM_MICRO_CYC - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0)
    );
end INST_DEC;

architecture behaviour of INST_DEC is

    begin

        ctrl_bus <= (others => 'Z');

end behaviour;
