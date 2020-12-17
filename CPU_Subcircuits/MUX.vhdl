library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;

entity MUX is
    generic(
        input_width     : integer := 8;
        ctrl_width      : integer := 3
    );
    port(
        ctrl    : in std_logic_vector(ctrl_width downto 0);
        inp     : in std_logic_vector(input_width downto 0);
        outp    : out std_logic
    );
end MUX;

architecture behaviour of MUX is

    begin

        outp <= inp(to_integer(unsigned(ctrl)));

end behaviour;
