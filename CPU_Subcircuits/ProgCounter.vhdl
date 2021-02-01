library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.Numeric_Std.all;

entity ProgCounter is
    port(
        clk         : in std_logic;
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
        -- Program Counter Overflow
        cnt_overf   : out std_logic
    );
end ProgCounter;

architecture structure of ProgCounter is

    signal prog_count_s     : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
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

        Counter : process(ctrl_bus)

            variable prog_count_v   : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

            begin

                cnt_overf <= '0';

                if (ctrl_bus(I_RESET) = '1') then
                    prog_count_v := (others => '0');
                else
                    if (ctrl_bus(I_PRC_IN) = '1') then
                        prog_count_v := addr_bus;
                    elsif (ctrl_bus(I_PRC_INCR) = '1') then
                        prog_count_v := aOutput;
                        cnt_overf <= carries(addr_bus_width - 1);
                    end if;
                end if;

                -- Output Program Counter
                if ctrl_bus(I_PRC_OUT) = '1' then
                    addr_bus <= prog_count_v(addr_bus_width - 1 downto 0);
                else
                    addr_bus <= (others => 'Z');
                end if;

                prog_count_s <= prog_count_v;

        end process Counter;

        debug : process(ctrl_bus)

            begin

                if (PROG_CNT_DEBUG) then

                    if (ctrl_bus(I_RESET) = '1') then
                        report "Program Counter Reset";
                    else
                        if (ctrl_bus(I_PRC_IN) = '1') then
                            report "Program Counter Override";
                        elsif (ctrl_bus(I_PRC_INCR) = '1') then
                            report "Program Counter Increment";
                        end if;
                    end if;

                    -- Output Program Counter
                    if ctrl_bus(I_PRC_OUT) = '1' then
                        report "Program Counter Out : " & integer'image(to_index(prog_count_s));
                    end if;

                end if;

        end process debug;

end structure;
