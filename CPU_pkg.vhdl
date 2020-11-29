library     ieee;
	use 	ieee.std_logic_1164.all;
	use 	ieee.numeric_std.all;
	use 	ieee.math_real.all;

package CPU_pkg is

    constant clockFrequency : integer   := 2048 * 10E3;
    constant base_clock     : time      := 1.0 sec / clockFrequency;
    constant regWidth       : integer   := 16;
	constant oper_width		: integer	:= 8;
    constant numReg         : integer   := 8;
    constant numRam         : integer   := 4096;

	constant numStatReg		: integer	:= 8;
	-- status[0] = Carry out
	-- status[1] = Result is Zero
	-- status[2] = Overflow
	-- status[3] = Even Parity
	-- status[4] = Odd Parity

    -- Deklarierung des Register-Typ ( in dem Fall 8 Bit)
    -- TODO Werte-Bereich ist der Architectur-Breite noch nicht modular angepasst
    -- Muss man im PAckage nochmal machen
    type Reg is array of std_logic_vector(oper_width - 1 downto 0) range 0 to 255;

end CPU_pkg;

package body CPU_pkg is
end CPU_pkg;
