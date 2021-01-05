library ieee;
    use ieee.std_logic_1164.all;
    use ieee.Numeric_Std.all;

entity std_logic_test is
    port(
        outp    : out std_logic_vector(6 - 1 downto 0)
    );
end std_logic_test;

architecture behaviour of std_logic_test is

    constant NUM_VALUES     : integer   := 5;
    constant NUM_OPERATORS  : integer   := 6;

    signal values       : std_logic_vector(NUM_VALUES - 1 downto 0) := "UXZ01";

    signal operand1     : std_logic;
    signal operand2     : std_logic;

    signal and_result   : std_logic;
    signal or_result    : std_logic;
    signal nand_result  : std_logic;
    signal xor_result   : std_logic;
    signal xnor_result  : std_logic;
    signal not_result   : std_logic;

    signal int_outp     : std_logic_vector(NUM_OPERATORS - 1 downto 0);

    begin

        a : process

            begin

                x : for i in 0 to ((NUM_VALUES ** 2) - 1) loop

                    operand1 <= values(i rem NUM_VALUES);
                    operand2 <= values(i / NUM_VALUES);

                    wait for 10 ns;

                end loop x;

                wait;

        end process a;

        and_result  <= operand1 and operand2;
        or_result   <= operand1 or operand2;
        nand_result <= operand1 nand operand2;
        xor_result  <= operand1 xor operand2;
        xnor_result <= operand1 xnor operand2;
        not_result  <= not operand1;

        int_outp <= and_result & or_result &
                    nand_result & xor_result &
                    xnor_result & not_result;

        outp <= int_outp;

end behaviour;
