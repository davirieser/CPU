library work;
    use work.CPU_pkg.all;

library     IEEE;
	use 	IEEE.std_logic_1164.all;
	use 	IEEE.numeric_std.all;
	use 	IEEE.math_real.all;

package INT_pkg is

    type INTERRUPT_T is record
        enable      : std_logic;
        latch       : std_logic;
        priority    : std_logic_vector(INT_PRIO_BITS - 1 downto 0);
        address     : std_logic_vector(addr_bus_width - 1 downto 0);
    end record INTERRUPT_T;

    type INTERRUPT_TABLE_T is array(NUM_INTERRUPTS - 1 downto 0) of INTERRUPT_T;


    constant RESET_INT_INDEX    : integer   := 0;
    constant RESET_INT_PRIO     : std_logic_vector(INT_PRIO_BITS - 1 downto 0)   := (others => '0');
    constant RESET_INT  : INTERRUPT_T := (
        enable          => '1',
        latch           => '0',
        priority        => RESET_INT_PRIO,
        address         => (others => '0')
    );

    constant NMI_INT_INDEX    : integer   := 1;
    constant NMI_INT_PRIO     : std_logic_vector(INT_PRIO_BITS - 1 downto 0)   := (0 => '1',others => '0');
    constant NMI_INT    : INTERRUPT_T := (
        enable          => '1',
        latch           => '0',
        priority        => NMI_INT_PRIO,
        address         => (1 => '1',others => '0')
    );

    constant UNIMPL_INT : INTERRUPT_T := (
        enable      => '0',
        latch       => '0',
        priority    => (others => '1'),
        address     => (others => '0')
    );

    constant INTERRUPT_TABLE : INTERRUPT_TABLE_T := (
        RESET_INT_INDEX => RESET_INT,
        NMI_INT_INDEX => NMI_INT,
        others => UNIMPL_INT
    );

end package INT_pkg;

package body INT_pkg is

end package body INT_pkg;
