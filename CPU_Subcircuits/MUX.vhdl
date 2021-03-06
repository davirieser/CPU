library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;

entity MUX is
    generic(
        ctrl_width      : integer := 3
    );
    port(
        ctrl    : in std_logic_vector(ctrl_width - 1 downto 0);
        inp     : in std_logic_vector(((2**ctrl_width) - 1) downto 0);
        outp    : out std_logic
    );
end MUX;

architecture behaviour of MUX is

    begin

        outp <= inp(to_integer(unsigned(ctrl)));

end behaviour;

-- -----------------------------------------------------------------------------

library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;

entity MUX_VAR is
    generic(
        ctrl_width      : integer := 3;
		input_width		: integer := 7
    );
    port(
        ctrl    : in std_logic_vector(ctrl_width - 1 downto 0);
        inp     : in std_logic_vector(input_width - 1 downto 0);
        outp    : out std_logic
    );
end MUX_VAR;

architecture behaviour of MUX_VAR is

	begin

		MUX : process(ctrl,inp)

			begin

				if (input_width > unsigned(ctrl)) then
			        outp <= inp(to_integer(unsigned(ctrl)));
				else
					outp <= '0';
				end if;

		end process MUX;

end behaviour;
