library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_ShiftRegister is
end tb_ShiftRegister;

architecture behaviour of tb_ShiftRegister is

	constant regWidth 	: integer := 5;

	signal sInputA 		: std_logic_vector(regWidth - 1 downto 0) := (others => '0');
	signal sInputB 		: std_logic_vector(regWidth - 1 downto 0) := (others => '0');
	signal sOutput 		: std_logic_vector(regWidth - 1 downto 0);
    signal s_cyc        : std_logic := '0';

    component ShiftRegister is
    	generic(
    		regWidth 		: integer := 2
    	);
        port(
            inputA  		: in  std_logic_vector(regWidth - 1 downto 0);
            inputB  		: in  std_logic_vector(regWidth - 1 downto 0);
            cyclicBuffer    : in  std_logic;
            aOutput   		: out std_logic_vector(regWidth - 1 downto 0)
        );
    end component ShiftRegister;

    begin

		uut : entity work.ShiftRegister
		generic map(
			regWidth  => regWidth
		)
		port map(
			inputA => sInputA,
			inputB => sInputB,
            cyclicBuffer => s_cyc,
			aOutput => sOutput
		);

		Signal_gen : process

			variable sTemp 		: std_logic_vector(2 * regWidth downto 0) := (others => '0');

			begin

				wait for 10 ns;

				sInputA <= sTemp(regWidth - 1 downto 0);
				sInputB <= sTemp((2 * regWidth) - 1 downto regWidth);
                s_cyc   <= sTemp(2 * regWidth);

				wait for 10 ns;

                for sCount in 0 to ((2 ** (2 * regWidth)) - 1) loop

					sTemp := std_logic_vector( unsigned(sTemp) + 1 );

					sInputA <= sTemp(regWidth - 1 downto 0);
					sInputB <= sTemp((2 * regWidth) - 1 downto regWidth);
                    s_cyc   <= sTemp(2 * regWidth);

                    wait for 10 ns;

                end loop;

				wait;

		end process Signal_gen;

end behaviour;
