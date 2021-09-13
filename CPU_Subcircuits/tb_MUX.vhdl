library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_MUX is
end tb_MUX;

architecture behaviour of tb_MUX is

    constant ctrl_width_s   : integer := 3;
    constant input_width_s  : integer := 8;
    constant input_width_v  : integer := 5;

    signal int_ctrl     : std_logic_vector(ctrl_width_s - 1 downto 0) := (others => '0');
    signal int_input    : std_logic_vector(input_width_s - 1 downto 0) := (others => '0');
    signal int_out1     : std_logic;
    signal int_out2     : std_logic;

    component MUX is
        generic(
            ctrl_width      : integer
        );
        port(
            ctrl    : in std_logic_vector(ctrl_width downto 0);
            inp     : in std_logic_vector(((2**ctrl_width) - 1) downto 0);
            outp    : out std_logic
        );
    end component MUX;

    component MUX_VAR is
        generic(
            ctrl_width      : integer := 3;
    		input_width		: integer := 7
        );
        port(
            ctrl    : in std_logic_vector(ctrl_width - 1 downto 0);
            inp     : in std_logic_vector(input_width - 1 downto 0);
            outp    : out std_logic
        );
    end component MUX_VAR;

    begin

        uut : entity work.MUX generic map(
            ctrl_width  => ctrl_width_s
        )
        port map(
            ctrl => int_ctrl,
            inp => int_input,
            outp => int_out1
        );

        uut2 : entity work.MUX_VAR generic map(
            ctrl_width => ctrl_width_s,
            input_width => input_width_v
        )
        port map(
            ctrl => int_ctrl,
            inp => int_input(input_width_v - 1 downto 0),
            outp => int_out2
        );

        Signal_gen : process

			variable sTemp : std_logic_vector(ctrl_width_s + input_width_s - 1 downto 0) := (others => '0');

			begin

                for sCount in 0 to ((2**(input_width_s+ctrl_width_s))-1) loop

                    int_input <= sTemp(input_width_s - 1 downto 0);
    				int_ctrl <= sTemp(input_width_s + ctrl_width_s - 1 downto input_width_s);

					sTemp := std_logic_vector(unsigned(sTemp) + 1);

                    wait for 1 ns;

                end loop;

				wait;

		end process Signal_gen;

end behaviour;
