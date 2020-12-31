
library ieee;
	use ieee.std_logic_1164.all;

entity TwosComplement is
	generic(
		regWidth 		: integer := 2
	);
    port(
        aInput     		: in  std_logic_vector(regWidth - 1 downto 0);
        aOutput   		: out std_logic_vector(regWidth - 1 downto 0)
    );
end TwosComplement;

architecture behaviour of TwosComplement is

    signal tempInput    : std_logic_vector(regWidth - 1 downto 0);

    signal carries      : std_logic_vector(regWidth - 1 downto 0) := (others => '0');

    begin

        tempInput <= not aInput;

        aOutput(0)  <= tempInput(0) xor '1';
        carries(0)  <= tempInput(0) and '1';

        Adders : for i in 1 to regWidth - 1 generate

            begin

                aOutput(i) <= tempInput(i) xor carries(i - 1);
                carries(i) <= tempInput(i) and carries(i - 1);

        end generate Adders;

end behaviour;
