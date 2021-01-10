
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

    signal carry    : std_logic_vector(regWidth - 1 downto 0);
    signal intern_add 	: std_logic_vector(regWidth - 1 downto 1);
    signal twosComplement : std_logic_vector(regWidth - 1 downto 0);

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
        carry(0)    <= (not(inputA(0) xor twosComplement(0)) and inputA(0)) or
						((inputA(0) xor twosComplement(0)) and carryIn);

        Adders : for i in 1 to regWidth - 1 generate

            begin

                intern_add(i)	<= inputA(i) xor twosComplement(i);
                carry(i)    	<= (not(intern_add(i)) and inputA(i)) or (intern_add(i) and carry(i - 1));
                aOutput(i) 		<= intern_add(i) xor carry(i - 1);

        end generate Adders;

		aCarry			<= not carry(regWidth - 1);
		aOutput(0)  	<= (inputA(0) xor inputB(0)) xor carryIn;

end behaviour;
