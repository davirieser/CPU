
library ieee;
	use ieee.std_logic_1164.all;

entity Subtractor is
	generic(
		regWidth 		: integer := 2
	);
    port(
        carryIn         : in  std_logic;
        inputA  		: in  std_logic_vector(regWidth - 1 downto 0);
        inputB  		: in  std_logic_vector(regWidth - 1 downto 0);
        aOutput   		: out std_logic_vector(regWidth - 1 downto 0);
        aCarry          : out std_logic
    );
end Subtractor;

architecture behaviour of Subtractor is

    signal iCarry    		: std_logic_vector(regWidth - 1 downto 0);
    signal twosComplement 	: std_logic_vector(regWidth - 1 downto 0);
	signal iOut				: std_logic_vector(regWidth - 1 downto 0);

	begin

        tc : entity work.TwosComplement
        generic map(
            regWidth => regWidth
        )
        port map(
            aInput => inputB,
            aOutput => twosComplement
        );

		-- First Full-Adder has to be created outside of Generate-Statement
        iOut(0)  <= inputA(0) xor twosComplement(0) xor carryIn;
		iCarry(0)	<= ((inputA(0) xor twosComplement(0)) and carryIn) or
						(inputA(0) and twosComplement(0));

        Adders : for i in 1 to regWidth - 1 generate

            begin

                iCarry(i)    	<= ((inputA(i) xor twosComplement(i)) and iCarry(i - 1)) or
								(inputA(i) and twosComplement(i));
                iOut(i)  		<= inputA(i) xor twosComplement(i) xor iCarry(i - 1);

        end generate Adders;

		aCarry			<= iCarry(regWidth - 1);
		aOutput		  	<= iOut;

end behaviour;
