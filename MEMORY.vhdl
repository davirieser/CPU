library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity MEMORY is
    generic(
        WRITABLE    : std_logic := WRITE_ENABLE;
        MEM_BITS    : integer;
        MEM_START   : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '1');
        MEM_END     : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '1')
    );
    port(
        -- Clock Input
        clk         : in std_logic;
        -- Control Bus
        ext_bus     : inout std_logic_vector(ext_bus_width - 1 downto 0);
        -- Address Input -> The Address which is to be read
        addr_bus    : inout std_logic_vector(addr_bus_width - 1 downto 0);
        -- Data In/Output -> Connected to Data-Bus
        data_bus    : inout std_logic_vector(data_bus_width - 1 downto 0);
        -- Data ready
        data_ready  : out std_logic
    );
end MEMORY;

architecture behaviour of MEMORY is

    type MEMORY_T is array(((2 ** MEM_BITS) - 1) downto 0) of
        std_logic_vector(data_bus_width - 1 downto 0);

    signal internal_memory : MEMORY_T := (others => (
        data_bus_width - 1 downto data_bus_width - 3 => '1',
        others => '0')
    );

    signal addr_corr    : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');
    signal sub2_out     : std_logic_vector(addr_bus_width - 1 downto 0) := (others => '0');

    signal mem_active   : std_logic := '0';
    signal under_addr   : std_logic := '0';
    signal over_addr    : std_logic := '0';

    signal ena          : std_logic := '0';
    signal rd_wr        : std_logic := '0';

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

        -- TODO Sollt checken ob da Bus High Impedance is
        --      damit die Subtrahierer nit an Scheiss zam rechnen

        p_RD_WR_CTRL : process(clk)

            begin

                if (checkHighImp(addr_bus)) then

                    -- TODO First Write doesn't work

                    report "Memory Read at Address " & integer'image(to_index(addr_bus));

                    mem_active <= (over_addr and (not under_addr));

                    if ((ext_bus(I_MEM_WRI) = '1') and
                        (not (ext_bus(I_MEM_RD) = '1'))) then
                        rd_wr <= WRITE_BIT;
                        ena <= '1';
                    elsif (ext_bus(I_MEM_RD) = '1') then
                        ena <= '1';
                        rd_wr <= READ_BIT;
                    else
                        ena <= '0';
                        rd_wr <= READ_BIT;
                    end if;

                    if ((ena = '1') and (mem_active = '1')) then
                        if (rd_wr = READ_BIT) then
                            if (to_index(addr_corr) <= (2 ** MEM_BITS)) then
                                report "Memory Out at Address";
                                data_bus <= internal_memory(to_index(addr_corr));
                                data_ready <= '1';
                            else
                                report "Memory out of range during Read";
                            end if;
                        elsif ((rd_wr = WRITE_BIT) and (WRITABLE = WRITE_ENABLE)) then
                            if (to_index(addr_corr) <= (2 ** MEM_BITS)) then
                                report "Memory Write at Address";
                                data_ready <= 'Z';
                                internal_memory(to_index(addr_corr)) <= data_bus;
                            else
                                report "Memory out of range during Write";
                            end if;
                        end if;
                    else
                        data_bus <= (others => 'Z');
                        data_ready <= 'Z';
                    end if;

                else
                    ena <= '0';
                    mem_active <= '0';
                    data_bus <= (others => 'Z');
                    data_ready <= 'Z';
                end if;

        end process p_RD_WR_CTRL;

        UNDER_CHECKER : entity work.Subtractor
        generic map(
            regWidth    => addr_bus_width
        )
        port map(
            carryIn     => '0',
            inputA      => addr_bus,
            inputB      => MEM_START,
            aOutput     => addr_corr,
            aCarry      => under_addr
        );

        OVER_CHECKER : entity work.Subtractor
        generic map(
            regWidth    => addr_bus_width
        )
        port map(
            -- TODO I glab des sollt auf 1 gsetzt sein
            --      Damit die letzte Addresse nit miteini geht
            carryIn     => '0',
            inputA      => MEM_END,
            inputB      => addr_bus,
            aOutput     => sub2_out,
            aCarry      => over_addr
        );

end behaviour;
