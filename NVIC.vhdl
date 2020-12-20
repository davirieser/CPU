
library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity NVIC is
    port (
        clock       : in std_logic;
        int_in      : in std_logic_vector(NUM_INTERRUPTS - 1 downto 0);
        int_request : out std_logic
    );
end NVIC;

architecture behaviour of NVIC is

    -- Enable Reset and NMI while disabling all other Interrupts by default
    signal int_enable   : std_logic_vector(NUM_INTERRUPTS - 1 downto 0) := "11" & (NUM_INTERRUPTS - 3 => '0');
    -- Keep Track of all the Interrupts that were triggered
    signal int_latches  : std_logic_vector(NUM_INTERRUPTS - 1 downto 0) := (others => '0');

    type INT_PRIOR is array (0 to NUM_INTERRUPTS) of std_logic_vector(INT_PRIO_BITS - 1 downto 0);
    signal int_prio     : INT_PRIOR := (others => (others => '1'));

    begin

end behaviour;
