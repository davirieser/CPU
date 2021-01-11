library work;
    use work.CPU_pkg.all;

library     IEEE;
	use 	IEEE.std_logic_1164.all;
	use 	IEEE.numeric_std.all;
	use 	IEEE.math_real.all;

package INT_pkg is

    constant INT_RESET_INDEX    : integer   := 0;
    constant INT_RESET_PRIO     : std_logic_vector(INT_PRIO_BITS - 1 downto 0)   := (others => '0');

    type INTERRUPT_T is record
        enable      : std_logic;
        latch       : std_logic;
        priority    : std_logic_vector(INT_PRIO_BITS - 1 downto 0);
        address     : std_logic_vector(addr_bus_width - 1 downto 0);
    end record INTERRUPT_T;

    type INTERRUPT_TABLE_T is array(NUM_INTERRUPTS - 1 downto 0) of INTERRUPT_T;

    constant INTERRUPT_TABLE : INTERRUPT_TABLE_T := (
        INT_RESET_INDEX => (
            enable          => '1',
            latch           => '0',
            priority        => INT_RESET_PRIO,
            address         => (others => '0')
        ),
        others => (
            enable      => '0',
            latch       => '0',
            priority    => (others => '0'),
            address     => (others => '0')
        )
    );

end package INT_pkg;

package body INT_pkg is

end package body INT_pkg;
