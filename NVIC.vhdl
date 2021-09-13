
library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity NVIC is
    port (
        clk         : in std_logic;
        int_in      : in std_logic_vector(NUM_INTERRUPTS - 1 downto 0);
        int_clear   : in std_logic_vector(NUM_INTERRUPTS - 1 downto 0);
        int_addr_o  : out std_logic_vector(addr_bus_width - 1 downto 0);
        int_num_out : out std_logic_vector(addr_bus_width - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0)
    );
end NVIC;

architecture behaviour of NVIC is

    -- TODO Priority Encoder sollten des einfacher machen : https://en.wikipedia.org/wiki/Priority_encoder

    -- Flag Register keeping Track of which Interrupt is currently executing
    signal ACTIVE_INTERRUPT : std_logic_vector(NUM_INTERRUPTS - 1 downto 0);

    signal int_flipflops    : std_logic_vector(NUM_INTERRUPTS - 1 downto 0);

    begin

        -- Process to set Interupt-Flags
        -- Not clocked
        INTERRUPT_IN : process(int_in)

            begin

                -- Check if the incoming Interrupts aren't overlapping
                -- with the Interrupt which are currently trying to be cleared
                if ((int_clear and int_in) = (NUM_INTERRUPTS => '0')) then

                    -- Or the Latched Interrupts and the incoming Interrupts
                    int_flipflops <= int_flipflops or int_in;

                end if;

        end process INTERRUPT_IN;

        -- Process to clear Interupt-Flags
        -- Not clocked
        INTERRUPT_CLR : process(int_clear)

            begin

                int_flipflops <= int_flipflops and not int_clear;

        end process INTERRUPT_CLR;

        -- Check which requested Interrupt has the highest Priority
        -- Clocked on rising Edge
        INTERRUPT_OUT : process(clk)

            variable interrupt_change : std_logic;

            begin

                if ((clk = '1') and clk'event) then

                    -- TODO Check if Interrupt has higher Priority

                    -- if interrupt has higher priority than ACTIVE_INTERRUPT then
                    --     interrupt_change <= '1';
                    --     ACTIVE_INTERRUPT <= NEW_INTERRUPT
                    -- end if;

                    -- TODO Then load Address of ISR into Program Counter

                    if (interrupt_change = '1') then

                        ctrl_bus(I_INT_REQ) <= '1';

                    else

                        ctrl_bus(I_INT_REQ) <= '0';

                    end if;

                end if;

        end process INTERRUPT_OUT;

end behaviour;
