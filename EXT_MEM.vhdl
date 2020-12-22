library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity EXT_MEM is
    port(
        -- Clock Input
        clk         : in std_logic;
        -- CPU-Side ------------------------------------------------------
        -- CPU-side Enable Input -> Wheter the RAM should act or not
        c_ena       : in std_logic;
        -- CPU-side Read/Write Input -> '0' => Read , '1' => Write
        c_rd_wr_in  : in std_logic;
        -- CPU-side Address Input -> The Address which is to be read
        c_addr_in   : in std_logic_vector(EXT_MEM_BITS - 1 downto 0);
        -- CPU-side Data Input -> Connected to Data-Bus
        c_data_in   : in std_logic_vector(data_bus_width - 1 downto 0);
        -- CPU-side Data Output -> Connected to Data-Bus
        c_data_out  : out std_logic_vector(data_bus_width - 1 downto 0);
        -- EXT-Side ------------------------------------------------------
        -- EXT-side Enable Input -> Wheter the RAM should act or not
        e_ena       : in std_logic;
        -- EXT-side Read/Write Input -> '0' => Read , '1' => Write
        e_rd_wr_in  : in std_logic;
        -- EXT-side Address Input -> The Address which is to be read
        e_addr_in   : in std_logic_vector(EXT_MEM_BITS - 1 downto 0);
        -- EXT-side Data Input -> Connected to Data-Bus
        e_data_in   : in std_logic_vector(data_bus_width - 1 downto 0);
        -- EXT-side Data Output -> Connected to Data-Bus
        e_data_out  : out std_logic_vector(data_bus_width - 1 downto 0)
    );
end EXT_MEM;

architecture behaviour of EXT_MEM is

    type MEMORY_TYPE is array(0 to EXT_MEM_SIZE) of std_logic_vector(data_bus_width - 1 downto 0);

    signal memory : MEMORY_TYPE := (others => (others => '0'));

    begin

        -- TODO Sollte des Ding ueberhaupt geclockt sein?
        -- TODO Sollt des aud ena-Input gecheckt werden?
        PRO : process(clk)

            begin

                if ena = '1' then
                    if rd_wr_in = '1' then
                        data_out <= memory(to_index(addr_in));
                    else
                        memory(to_index(addr_in)) <= data_in;
                    end if;
                else
                    data_out <= (others => 'Z');
                end if;

        end process PRO;

end behaviour;
