library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.Numeric_Std.all;

entity ProgCounter is
    port(
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
        -- Program Counter Overflow
        -- TODO Put on CTRL_BUS
        cnt_overf   : out std_logic
    );
end ProgCounter;

architecture structure of ProgCounter is

    signal prog_count_s     : std_logic_vector(addr_bus_width - 1 downto 0) := PROG_START;
    signal carries          : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal aOutput          : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    constant OVR_FILLER     : std_logic_vector(addr_bus_width - 1 downto data_bus_width)
        := (others => '0');

    begin

        -- Adder ---------------------------------------------

        aOutput(PROG_COU_INC)  <= prog_count_s(PROG_COU_INC) xor '1';
        carries(PROG_COU_INC)  <= prog_count_s(PROG_COU_INC) and '1';

        Adders : for i in (1 + PROG_COU_INC) to (addr_bus_width - 1) generate

            begin

                aOutput(i) <= prog_count_s(i) xor carries(i - 1);
                carries(i) <= prog_count_s(i) and carries(i - 1);

        end generate Adders;

        -- Multiplexer Output -----------------------------------

        Counter : process(ctrl_bus)

            begin

                if (ctrl_bus(RESET_CTL) = '1') then
                    prog_count_s <= PROG_START;
                else
                    if (ctrl_bus(PRC_OVR_B) = '1') then
                        -- TODO Andersch machen => Addressen werden nit gscheid auf
                        -- en Daten-Bus gschrieben => Stack Pointer geht nit
                        prog_count_s <= OVR_FILLER & data_bus;
                    elsif (ctrl_bus(PRC_INCR_B) = '1') then
                        prog_count_s <= aOutput;
                    end if;
                end if;

        end process Counter;

        -- Outputs ---------------------------------------------

        PRC_Output : process(ctrl_bus(PRC_OUT_B))
            begin
                if ctrl_bus(PRC_OUT_B) = '1' then
                    -- TODO Andersch machen => Addressen werden nit gscheid auf
                    -- en Daten-Bus gschrieben => Stack Pointer geht nit
                    data_bus <= prog_count_s(data_bus_width - 1 downto 0);
                end if;
        end process PRC_Output;

        -- TODO ctrl_bus(PRC_INCR_B) can be 'Z' => Problem => Result = 'U'?
        cnt_overf   <= carries(addr_bus_width - 1) and ctrl_bus(PRC_INCR_B);

end structure;
