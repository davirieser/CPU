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
        prog_count  : out std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0')
    );
end ProgCounter;

architecture structure of ProgCounter is

    begin

        Counter : process(clk)

            variable prog_count_v : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

            begin
                if (ovr = '1') then
                    prog_count_v := ovr_count;
                elsif (inc = '1') then
                    -- TODO Zu am Addierer umschreiben
                    prog_count_v := std_logic_vector(unsigned(prog_count_v) + addr_bus_width);
                end if;

                prog_count <= prog_count_v;

        end process Counter;

end structure;
