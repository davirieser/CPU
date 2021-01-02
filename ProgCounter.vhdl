library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.Numeric_Std.all;

entity ProgCounter is
    port(
        clk         : in  std_logic;
        -- Increment Program-Counter-Flag
        inc         : in std_logic;
        -- Override Program-Counter-Signal
        ovr         : in  std_logic;
        -- Override Value
        ovr_count   : in  std_logic_vector(addr_bus_width - 1 downto 0);
        -- Program-Counter Out
        prog_count  : out std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
        -- Program Counter Overflow
        cnt_overf   : out std_logic
    );
end ProgCounter;

architecture structure of ProgCounter is

    signal prog_count_s     : std_logic_vector(addr_bus_width - 1 downto 0) := PROG_START;

    signal carries          : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    signal aOutput          : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    begin

        -- Adder ---------------------------------------------

        aOutput(0)  <= prog_count_s(0) xor '1';
        carries(0)  <= prog_count_s(0) and '1';

        Adders : for i in 1 to addr_bus_width - 1 generate

            begin

                aOutput(i) <= prog_count_s(i) xor carries(i - 1);
                carries(i) <= prog_count_s(i) and carries(i - 1);

        end generate Adders;

        -- Multiplexer Output -----------------------------------

        Counter : process(clk)

            begin
                if (ovr = '1') then
                    prog_count_s <= ovr_count;
                elsif (inc = '1') then
                    prog_count_s <= aOutput;
                end if;

        end process Counter;

        -- Outputs ---------------------------------------------

        prog_count  <= prog_count_s;
        cnt_overf   <= carries(addr_bus_width - 1) and inc;

end structure;
