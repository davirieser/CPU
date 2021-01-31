-- variable Length Full-Adder using Generic and simple Full-Adder Circuits used in Series.
--
--			/-------------------\
--	a ------|					|
--			|		Full		|------ s
--	b ------|					|
--			|		Adder		|------ cOut
--	cIn ----|					|
--			\-------------------/
--
--			/-----------------------\
--			|						|
--	a ------|-- X					|
--			|	O --------- z		|
--	b ------|-- R			|		|
--			|				|		|
--			|				|		|
--			|				|		|
--	b ------|-------------- M		|
--			|				U ------|--- cOut
--	cIn ----|-------------- X		|
--			|						|
--	z ------|-------------- X		|
--			|				O ------|--- s
--	cIn ----|-------------- R		|
--			|						|
--			\-----------------------/
--


library ieee;
	use ieee.std_logic_1164.all;

entity Adder is
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
end Adder;

architecture behaviour of Adder is

    signal iCarry    	: std_logic_vector(regWidth - 1 downto 0);
	signal iOut			: std_logic_vector(regWidth - 1 downto 0);

	begin

        -- First Full-Adder has to be created outside of Generate-Statement
        iOut(0)  <= inputA(0) xor inputB(0) xor carryIn;
		iCarry(0)	<= ((inputA(0) xor inputB(0)) and carryIn) or
						(inputA(0) and inputB(0));

        Adders : for i in 1 to regWidth - 1 generate

            begin

                iCarry(i)    	<= ((inputA(i) xor inputB(i)) and iCarry(i - 1)) or
								(inputA(i) and inputB(i));
                iOut(i)  		<= inputA(i) xor inputB(i) xor iCarry(i - 1);

        end generate Adders;

		aCarry		<= iCarry(regWidth - 1);
		aOutput		<= iOut;

end behaviour;
