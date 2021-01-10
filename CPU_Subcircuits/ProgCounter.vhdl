library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.Numeric_Std.all;

entity ProgCounter is
    port(
        clk         : in std_logic;
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
        -- Program Counter Overflow
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

        Adders : for i in (PROG_COU_INC + 1) to (addr_bus_width - 1) generate

            begin

                aOutput(i) <= prog_count_s(i) xor carries(i - 1);
                carries(i) <= prog_count_s(i) and carries(i - 1);

        end generate Adders;

        -- Multiplexer Output -----------------------------------

        Counter : process(clk)

            variable prog_count_v   : std_logic_vector(addr_bus_width - 1 downto 0) := PROG_START;

            begin

                cnt_overf <= '0';
                -- prog_count_v := std_logic_vector(unsigned(prog_count_s) + 1);

                if (ctrl_bus(RESET_CTL) = '1') then
                    -- report "Program Counter Reset";
                    prog_count_v := PROG_START;
                else
                    if (ctrl_bus(PRC_IN_B) = '1') then
                        -- report "Program Counter Override";
                        -- TODO Andersch machen => Addressen werden nit gscheid auf
                        -- en Daten-Bus gschrieben => Stack Pointer geht nit
                        prog_count_v := OVR_FILLER & data_bus;
                    elsif (ctrl_bus(PRC_INCR_B) = '1') then
                        -- report "Program Counter Increment";
                        prog_count_v := aOutput;
                        cnt_overf <= carries(addr_bus_width - 1);
                    end if;
                end if;

                -- Output Program Counter
                if ctrl_bus(PRC_OUT_B) = '1' then
                    -- report "Program Counter Out";
                    -- TODO Andersch machen => Addressen werden nit gscheid auf
                    -- en Daten-Bus gschrieben => Stack Pointer geht nit
                    data_bus <= prog_count_v(addr_bus_width - 1 downto addr_bus_width - data_bus_width );
                else
                    data_bus <= (others => 'Z');
                end if;

                prog_count_s <= prog_count_v;

        end process Counter;

end structure;
