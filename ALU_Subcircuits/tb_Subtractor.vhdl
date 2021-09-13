library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_Subtractor is
end tb_Subtractor;

architecture behaviour of tb_Subtractor is

	constant regWidth 	: integer := 5;

	signal sCarryIn 	: std_logic := '0';
	signal sInputA 		: std_logic_vector(regWidth - 1 downto 0) := (others => '0');
	signal sInputB 		: std_logic_vector(regWidth - 1 downto 0) := (others => '0');
	signal sOutput 		: std_logic_vector(regWidth - 1 downto 0);
	signal sCarry 		: std_logic;

	component Subtractor is
		generic(
			regWidth 		: integer
		);
	    port(
	        carryIn         : in  std_logic;
	        inputA  		: in  std_logic_vector(regWidth - 1 downto 0);
	        inputB  		: in  std_logic_vector(regWidth - 1 downto 0);
	        aOutput   		: out std_logic_vector(regWidth - 1 downto 0);
	        aCarry          : out std_logic
	    );
	end component Subtractor;

    begin

		uut : entity work.Subtractor
		generic map(
			regWidth  => regWidth
		)
		port map(
			carryIn => sCarryIn,
			inputA => sInputA,
			inputB => sInputB,
			aOutput => sOutput,
			aCarry => sCarry
		);

		Signal_gen : process

			variable sTemp 		: std_logic_vector((2 * regWidth) - 1 downto 0) := (others => '0');

			begin

				wait for 10 ns;

				sInputA <= sTemp(regWidth - 1 downto 0);
				sInputB <= sTemp((2 * regWidth) - 1 downto regWidth);

				wait for 10 ns;

                for sCount in 0 to ((2 ** (2 * regWidth)) - 1) loop

					sTemp := std_logic_vector( unsigned(sTemp) + 1 );

					sInputA <= sTemp(regWidth - 1 downto 0);
					sInputB <= sTemp((2 * regWidth) - 1 downto regWidth);

                    wait for 10 ns;

                end loop;

				wait;

		end process Signal_gen;

end behaviour;
