use work.CPU_pkg.all;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_CLK_DIVIDER is
end tb_CLK_DIVIDER;

architecture behaviour of tb_CLK_DIVIDER is

    signal clk_s    : std_logic		:= '0';
    signal outp_s   : std_logic_vector(NUM_MICRO_CYC - 1 downto 0);

    component CLK_DIVIDER is
        port(
            reset   : in std_logic;
            clk     : in std_logic;
	        hold    : in std_logic;
            outp    : out std_logic_vector(NUM_MICRO_CYC - 1 downto 0)
        );
    end component CLK_DIVIDER;

    begin

        uut : entity work.CLK_DIVIDER port map(
            reset => '0',
            clk => clk_s,
			hold => '0',
            outp => outp_s
        );

        SCK : process
        begin
            clk_s <= '0';
            wait for base_clock / 2;
            for clk_cnt_s in 0 to (2 ** (NUM_MICRO_CYC + 3)) loop
                clk_s 		<= not clk_s;
                wait for base_clock / 2;
                clk_s 		<= not clk_s;
                wait for base_clock / 2;
            end loop;
            wait;
        end process SCK;

end behaviour;
