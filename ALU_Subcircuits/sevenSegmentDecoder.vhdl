-- Decoder from four Bit binay to BCD Seven-Segemnt-LCD-Display
-- Needs to be enabled
-- Everything over 9 is displayed as 0
--
-- HEX LAYOUT
--
-- 	  000
-- 5       1
-- 5       1
-- 5       1
-- 	  666
-- 4       2
-- 4       2
-- 4       2
--    333

library ieee;
	use ieee.std_logic_1164.all;

entity sevenSegmentDecoder is
    port(
		ena					: in  std_logic;
        z                   : in  std_logic_vector(3 downto 0);
		hex                 : out std_logic_vector(6 downto 0)
    );
end sevenSegmentDecoder;

architecture behaviour of sevenSegmentDecoder is

    begin

        hex(0) <= ena and (z(3) or z(1) or (z(0) and z(2)) or (not(z(0)) and not(z(2))));
        hex(1) <= ena and (z(3) or (not(z(1)) and not(z(0))) or (not(z(2)) and not(z(3))) or (z(0) and z(1)));
        hex(2) <= ena and (z(0) or not(z(1)) or z(2) or z(3));
        hex(3) <= ena and (z(3) or (not(z(1)) and z(2) and z(0)) or (not(z(0)) and not(z(2))) or (not(z(2)) and z(1)) or (not(z(0)) and z(1)));
        hex(4) <= ena and ((z(1) and z(3)) or (z(3) and z(2)) or (not(z(0)) and not(z(2))) or (z(1) and not(z(0))));
        hex(5) <= ena and (z(3) or (not(z(1)) and z(2)) or (not(z(1)) and not(z(0))) or (z(2) and not(z(0))));
        hex(6) <= ena and ((not(z(2)) and z(3) and not(z(1))) or
							(z(2) and not(z(3)) and not(z(1))) or
							(not(z(3)) and z(2) and not(z(0))) or
							(not(z(0)) and not(z(3)) and z(1)) or
							(not(z(2)) and not(z(3)) and z(1)));

end behaviour;
