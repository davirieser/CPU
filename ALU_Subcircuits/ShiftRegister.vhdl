
library ieee;
	use ieee.std_logic_1164.all;

use work.CPU_pkg.all;

entity ShiftRegister is
	generic(
		regWidth 		: integer := 2
	);
    port(
        inputA  		: in  std_logic_vector(regWidth - 1 downto 0);
        inputB  		: in  std_logic_vector(regWidth - 1 downto 0);
        cyclicBuffer    : in  std_logic;
        aOutput   		: out std_logic_vector(regWidth - 1 downto 0)
    );
end ShiftRegister;

architecture behaviour of ShiftRegister is

    type SHIFT_TYPE is array(0 to regWidth - 1) of std_logic_vector(regWidth - 1 downto 0);

    signal temp : SHIFT_TYPE := (others => (others => '0'));

    begin

        Shifts : for i in 0 to regWidth - 1 generate

            signal temp_compare : std_logic_vector(i - 1 downto 0);

            begin

                temp_compare <= (others => cyclicBuffer);
                temp(i) <= ((inputA(regWidth - i - 1 downto 0))) &
                    (inputA(regWidth - 1 downto regWidth - i) and temp_compare);
                    -- Die unten stehen Variante zum VerUNDen is schoener
                    -- and (regWidth - i => cyclicBuffer));

        end generate Shifts;

        aOutput <= temp(0);

end behaviour;
