library ieee;
    use ieee.std_logic_1164.all;

entity T_FF is
    port(
        clk     : in std_logic;
        T       : in std_logic;
        outp    : out std_logic
    );
end T_FF;

architecture structure of T_FF is

    signal int_out  : std_logic := '0';

    begin

        FF : process(clk)

            begin

                if rising_edge(clk) then

                    int_out <= (not T) and int_out;

                end if;

        end process FF;

    outp <= int_out;

end structure;
