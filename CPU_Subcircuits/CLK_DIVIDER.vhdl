library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.CPU_pkg.all;

entity CLK_DIVIDER is
    port(
        reset   : in std_logic;
        clk     : in std_logic;
        hold    : in std_logic;
        outp    : out std_logic_vector(NUM_MICRO_CYC - 1 downto 0)
    );
end CLK_DIVIDER;

architecture structure of CLK_DIVIDER is

    signal vector       : std_logic_vector(NUM_MICRO_CYC - 1 downto 0) := (others => '0');
    signal next_vector  : std_logic_vector(NUM_MICRO_CYC - 1 downto 0) := (others => '0');
    signal reset_cycle  : std_logic := '0';

    signal carry    	: std_logic_vector(NUM_MICRO_CYC - 1 downto 0) := (others => '0');

    begin

        carry(0)        <= vector(0) and '1';
        next_vector(0)  <= vector(0) xor '1';
        outp <= vector;

        Adders : for i in 1 to NUM_MICRO_CYC - 1 generate

            begin

                carry(i)    	<= vector(i) and carry(i - 1);
                next_vector(i)  <= vector(i) xor carry(i - 1);

        end generate Adders;

        counter : process(clk)

            begin

                if ((falling_edge(clk) or rising_edge(clk))) then

                    if (not (hold = '1')) then

                        -- TODO I versteh nit warum des funktioniert
                        if ((reset = '1') and (reset_cycle = '0')) then
                        --     reset_cycle <= '1';
                        --     vector <= next_vector;
                        -- elsif (reset_cycle = '1') then
                            vector <= (others => '0');
                            reset_cycle <= '0';
                        else
                            vector <= next_vector;
                        end if;

                    end if;

                end if;

        end process counter;

        debug : process(clk)

            begin

                if (CLK_DIV_DEBUG) then

                    if ((falling_edge(clk) or rising_edge(clk))) then

                        if (not (hold = '1')) then

                            if ((reset = '1') and (reset_cycle = '0')) then
                                report "Program Counter resetting";
                            else
                                report "Program Counter next Cycle : " & integer'image(to_index(next_vector));
                            end if;

                        else
                            report "Program Counter holding";
                        end if;

                    end if;

                end if;

        end process debug;

end structure;
