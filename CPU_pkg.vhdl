library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;
	use 	ieee.math_real.all;

package CPU_pkg is

    constant clockFrequency : integer   := 2048 * 10E3;
    constant base_clock     : time      := 1.0 sec / clockFrequency;
    constant regWidth       : integer   := 16;
    constant numReg         : integer   := 30;
    constant numRam         : integer   := 4096 * 10E3;

end CPU_pkg;

package body CPU_pkg is
end CPU_pkg;
