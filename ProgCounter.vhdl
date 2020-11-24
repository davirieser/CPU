library ieee;
    use ieee.std_logic_1164.all;

entity Prog_Counter is
    generic(
        address_bus_width : integer
    );
    port(
        clk         : in std_logic;
        ovr         : in std_logic;
        ovr_count   : in std_logic_vector(address_bus_width - 1 downto 0);
        prog_count  : out std_logic := "FFEEFFFF"
    );
end Prog_Counter;

architecture structure of ALU is

    variable prog_count_v : std_logic_vector(address_bus_width - 1 downto 0) := "FFEEFFFF";

    begin

        Counter : process(clk)
            begin
                if ovr = 1 then
                    prog_count_v := ovr_count;
                else
                    -- TODO Zu am Addierer umschreiben
                    prog_count_v := prog_count + 1;
                end if;
        end process;

        prog_count <= prog_count_v

end structure;
