library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;
	use 	ieee.math_real.all;

package Schieberegister_pkg is

    constant clockFrequency : integer := 100;
    constant base_clock     : time := 1.0 sec / clockFrequency;
	constant CNT_MAX		: natural := 200;
    constant regWidth       : integer := 16;

	type intState is(ST_INIT,ST_SHIFT_UP,ST_SHIFT_DOWN,ST_PRELOAD,ST_DO_NOTHING);

end Schieberegister_pkg;

package body Schieberegister_pkg is
end Schieberegister_pkg;
