library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.Numeric_Std.all;

entity ProgCounter is
    generic(
        address_bus_width : integer
    );
    port(
        clk         : in  std_logic;
        ovr         : in  std_logic;
        ovr_count   : in  std_logic_vector(addr_bus_width - 1 downto 0);
        prog_count  : out std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0')
    );
end ProgCounter;

architecture structure of ProgCounter is

    begin

        Counter : process(clk)

            variable prog_count_v : std_logic_vector(address_bus_width - 1 downto 0) := X"FFEEFFFF";

            begin
                if (ovr = '1') then
                    prog_count_v := ovr_count;
                else
                    -- TODO Zu am Addierer umschreiben
                    prog_count_v := std_logic_vector(unsigned(prog_count_v) + 1);
                end if;

                prog_count <= prog_count_v;

        end process;

end structure;
