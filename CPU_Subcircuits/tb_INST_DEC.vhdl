library work;
    use work.INST_DEC_pkg.all;
    use work.CPU_pkg.all;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity tb_INST_DEC is
end tb_INST_DEC;

architecture behaviour of tb_INST_DEC is

    component INST_DEC is
        port(
            -- This is basically a Lookup-Table so it neither needs a
            -- Reset nor a Clock
            inst        : in std_logic_vector(OPCODE_BITS + NUM_FLAGS - 1 downto 0);
            flags_in    : in std_logic_vector(NUM_FLAGS - 1 downto 0);
            micro_cyc   : in std_logic_vector(NUM_MICRO_CYC - 1 downto 0);
            ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0)
        );
    end component INST_DEC;

    constant size       : integer := OPCODE_BITS + NUM_MICRO_CYC + NUM_FLAGS;

    signal sTemp 		: std_logic_vector(size - 1 downto 0) := (others => '0');
    signal sCtrl        : std_logic_vector(ctrl_bus_width - 1 downto 0) := (others => 'Z');

    signal sInst        : std_logic_vector(size - 1 downto NUM_MICRO_CYC) := (others => '0');
    signal sMicro_cyc   : std_logic_vector(NUM_MICRO_CYC - 1 downto 0) := (others => '0');

    begin

        sInst      <= sTemp(size - 1 downto NUM_MICRO_CYC);
        sMicro_cyc <= sTemp(NUM_MICRO_CYC - 1 downto 0);

        uut : entity work.INST_DEC port map(
                                    inst        => sInst,
                                    flags_in    => (others => '0'),
                                    micro_cyc   => sMicro_cyc,
                                    ctrl_bus    => sCtrl
                                );

		Signal_gen : process

			begin

                wait for base_clock;

                for sCount in 0 to ((2 ** size) - 1) loop

					sTemp <= std_logic_vector(unsigned(sTemp) + 1);

                    wait for base_clock;

                end loop;

				wait;

		end process Signal_gen;

end behaviour;
