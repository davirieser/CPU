
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
	signal temp_out : std_logic_vector(regWidth - 1 downto 0);
    signal twosComplement : std_logic_vector(regWidth - 1 downto 0);

	signal negative : std_logic;
	signal zero		: std_logic;
	signal zero_temp: std_logic_vector(regWidth - 1 downto 0);

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
		zero_temp(0)<= temp_out(0);

        Adders : for i in 1 to regWidth - 1 generate

            signal z : std_logic;

            begin

                z          	<= inputA(i) xor twosComplement(i);
                carry(i)    <= (not(z) and inputA(i)) or (z and carry(i - 1));
                temp_out(i) <= z xor carry(i-1);
				zero_temp(i)<= temp_out(i) or zero_temp(i - 1);

        end generate Adders;

		zero 			<= not zero_temp(regWidth - 1);
		negative		<= carry(regWidth - 1) and zero_temp(regWidth - 1);
		aCarry			<= negative;
        temp_out(0)  	<= (inputA(0) xor inputB(0)) xor carryIn;
		aOutput			<= temp_out;

end behaviour;
