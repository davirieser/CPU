library     ieee;
	use 	ieee.std_logic_1164.all;

entity MUX is
    generic(
        input_width     : integer := 8,
        ctrl_width      : integer := 3
    );
    port(
        ctrl    : in std_logic_vector(ctrl_width downto 0);
        inp     : in std_logic_vector(input_width downto 0);
        outp    : out std_logic
    );
end MUX;

-- architecture structure of MUX is
--
--     -- MUX could be more effective but would have to be hard-coded
--
--     signal conn : std_logic_vector(input_width - 1 downto 0);
--
--     begin
--
--         conn(0) <= (ctrl and inp(0)) or (not(ctrl) and inp(1))
--
--         gen : for i in 1 to (input_width - 1) generate
--
--             conn(i) <=
--
--         end generate gen;
--
-- end structure;

architecture behaviour of MUX is

    begin

        outp <= inp(to_unsigned(ctrl));

end behaviour;
