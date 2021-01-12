library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity MEMORY is
    generic(
        WRITABLE : std_logic := WRITE_ENABLE,
        MEM_START   : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '1'),
        MEM_END : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '1')
    );
    port(
        -- Clock Input
        clk         : in std_logic;
        -- Enable Input -> Tells the Memory if it should take Action
        ena         : in std_logic;
        -- Read/Write Input : Only for Writable Memories
        rd_wr       : in std_logic;
        -- Address Input -> The Address which is to be read
        addr        : in std_logic_vector(addr_bus_width - 1 downto 0);
        -- Data In/Output -> Connected to Data-Bus
        data        : inout std_logic_vector(data_bus_width - 1 downto 0)
    );
end MEMORY;

architecture behaviour of MEMORY is

    signal memory : MEMORY_T := (others => (
        data_bus_width - 1 downto data_bus_width - 3 => '1',
        others => '0')
    );

    signal addr_corr    : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal sub2_out     : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    signal mem_active   : std_logic := '0';
    signal under_addr   : std_logic := '0';
    signal over_addr    : std_logic := '0';

    component Subtractor is
    	generic(
    		regWidth 		: integer := 2
    	);
        port(
            carryIn         : in  std_logic;
            inputA  		: in  std_logic_vector(regWidth - 1 downto 0);
            inputB  		: in  std_logic_vector(regWidth - 1 downto 0);
            aOutput   		: out std_logic_vector(regWidth - 1 downto 0);
            aCarry          : out std_logic
        );
    end component Subtractor;

    begin

        MEMORY : process(clk,mem_addressed)

            begin

                if ((ena = '1') and (mem_active = '1')) then
                    if (rd_wr = READ_BIT) then
                        -- report "Memory Out";
                        data <= memory(to_index(addr_corr));
                    elsif ((rd_wr = WRITE_BIT) and (WRITABLE = WRITE_ENABLE)) then
                        -- report "Memory Write";
                        memory(to_index(addr_corr)) <= data;
                    end if;
                else
                    data <= (others => 'Z');
                end if;

        end process MEMORY;

        UNDER_CHECKER : entity work.Subtractor
            generic map(
                regWidth    => addr_bus_width
            )
            port map(
                carryIn     => '0',
                inputA      => addr,
                inputB      => MEM_START,
                aOutput     => addr_corr,
                aCarry      => under_addr
            )
        ;

        OVER_CHECKER : entity work.Subtractor
            generic map(
                regWidth    => addr_bus_width
            )
            port map(
                -- TODO I glab des sollt auf 1 gsetzt sein
                --      Damit die letzte Addresse nit miteini geht
                carryIn     => '0',
                inputA      => MEM_END,
                inputB      => addr,
                aOutput     => sub2_out,
                aCarry      => over_addr
            )
        ;

        ENA_GENERATION : process(addr)

            begin

                mem_active <= (over_addr and under_addr);

        end process ENA_GENERATION;

end behaviour;
