
library ieee;
	use ieee.std_logic_1164.all;

use work.CPU_pkg.all;

entity ShiftRegister is
	generic(
		regWidth 		: integer := 2;
        -- Control-Bits has to be log2(regWidth) rounded down
        crtl_bits       : integer := 1
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

	signal temp_compare : std_logic_vector(regWidth downto 0) := (others => cyclicBuffer);

    begin

        Shifts : for i in 0 to regWidth - 1 generate

            begin

                temp_compare <= (others => cyclicBuffer);
                temp(i) <= ((inputA(regWidth - i - 1 downto 0))) &
                    (inputA(regWidth - 1 downto regWidth - i) and
					temp_compare(regWidth - 1 downto regWidth - i));
                    -- Die unten stehen Variante zum VerUNDen is schoener
                    -- and (i => cyclicBuffer));

        end generate Shifts;

        -- TODO Buffer still theoretically is cyclic if a bit above
        --      the control-Bits is set
        --      => Return all zeroes if a Bit above ctrl-Bits is set
        aOutput <= temp(to_index(inputB(crtl_bits - 1 downto 0)));

end behaviour;
