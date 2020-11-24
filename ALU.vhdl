
library ieee;
    use ieee.std_logic_1164.all;

entity ALU is
    port(
        clk         : in std_logic;
        -- TODO Busbreite ist nicht das gleiche wie die Anzhal der Befehle
        -- Muss man nochmal seperat definieren
        OPCODE      : in    std_logic_vector(NUM_OPCODES);
        -- TODO Busse sollten nicht gleich breit sein
        data_bus    : inout std_logic_vector(bus_width - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(bus_width - 1 downto 0);
        addr_bus    : inout std_logic_vector(bus_width - 1 downto 0);
        -- Turn on or off if the CPU is able to access the bus
        bus_enable : in std_logic
    );
end ALU;

architecture structure of ALU is

    -- Deklarierung des Register-Typ ( in dem Fall 8 Bit)
    -- TODO Werte-Bereich ist der Architectur-Breite noch nicht modular angepasst
    -- Muss man im PAckage nochmal machen
    type Reg is array of std_logic_vector(arch_width - 1 downto 0) range 0 to 255;

    signal ALU_OUT          : std_logic_vector(arch_width - 1 downto 0);

    -- Register der ALU
    signal RegA, RegB       : Reg;

    -- Ergebnisleitung fuer logische Verknuepfungen der Register
    signal REG_AND          : std_logic_vector(arch_width - 1 downto 0);
    signal REG_OR           : std_logic_vector(arch_width - 1 downto 0);
    signal REG_XOR          : std_logic_vector(arch_width - 1 downto 0);
    signal REG_NOT_A        : std_logic_vector(arch_width - 1 downto 0);
    signal REG_NOT_B        : std_logic_vector(arch_width - 1 downto 0);

    -- Ergbnisleitung und Flagge bei Overflow fuer den Addierer
    signal ADD_OUT          : Reg;
    -- Flaggen springen in jetzigen Design auch an wenn das Ergbnis der Addition nicht verwendet wird
    signal FLAG_OVERFLOW    : std_logic;

    -- Ergbnisleitung und Flagge bei Underflow fuer den Addierer
    signal SUB_OUT          : Reg;
    -- Flaggen springen in jetzigen Design auch an wenn das Ergbnis der Subtraktion nicht verwendet wird
    signal FLAG_UNDERFLOW   : std_logic;

    -- Zwischenleitungen und Flaggen fuer das Schieberegister
    signal SHIFT_IN         : std_logic_vector(arch_width - 1 downto 0);
    signal SHIFT_OUT        : std_logic_vector(arch_width - 1 downto 0);
    -- Flagge um dem Schieberegister zu sagen das es den Input in seine Register laden soll
    signal FLAG_SHIFT_REG_LOAD  : std_logic;
    -- Flagge welches dem Schieberegister sagt ob es nach oben oder unten shiften soll (Multiplizieren oder Dividieren)
    signal FLAG_SHIFT_UP_DOWN   : std_logic;

    component MUX is
        generic(
            regWidth        : integer
        );
        port(
            ctrl            : in  std_logic_vector(??? downto 0);
            inpt            : in  std_logic_vector(??? downto 0); -- Muss man noch irgendwie ausrechnen
            outp            : out std_logic
        );
    end component MUX;

    -- Pseudo-Code : Addierer funktioniert noch nicht weil ich in noch nicht testen konnte
	component Adder is
		generic(
			regWidth 		: integer
		);
	    port(
	        ena             : in  std_logic;
	        inputA  		: in  std_logic_vector(arch_width - 1 downto 0);
	        inputB  		: in  std_logic_vector(arch_width - 1 downto 0);
			carryIn			: in  std_logic;
	        aOutput 		: out std_logic_vector(arch_width - 1 downto 0);
	        aCarry          : out std_logic_vector(arch_width - 1 downto 0)
	    );
	end component Adder;

    -- TODO Subtrahierer funktioniert noch nicht annaehernd
    component Subtractor is
        generic(
            regWidth 		: integer
        );
        port(
            ena             : in  std_logic;
            inputA  		: in  std_logic_vector(arch_width - 1 downto 0);
            inputB  		: in  std_logic_vector(arch_width - 1 downto 0);
            carryIn			: in  std_logic;
            aOutput 		: out std_logic_vector(arch_width - 1 downto 0);
            aCarry          : out std_logic_vector(arch_width - 1 downto 0)
        );
    end component Subtractor;

    -- Zur Multiplikation und Division mit 2 => Barrel Shifter
    -- Habe ich schon geschrieben (2 mal um genau zu sein) und funktioniert
    -- Sie sind jedoch nicht hardware-syntetisierbar und braucht mehrere Clock-Zyklen
    -- TODO Eher umstaendliches Design da zuerst der Wert geladen muss und dann
    -- erst nach und nach geschoben wird.
    component Schieberegister is
        generic(
            regWidth 		: integer
        );
        port(
            clk     	    : in  std_logic;
            ena,uOd  		: in  std_logic;
            plc 			: in  std_logic;
            inputs  		: in  std_logic_vector(regWidth - 1 downto 0);
            outputs 		: out std_logic_vector(regWidth - 1 downto 0)
        );
    end component Schieberegister;

    begin

        REG_AND     <= RegA and RegB;
        REG_OR      <= RegA or RegB;
        REG_XOR     <= RegA xor RegB;
        REG_NOT_A   <= not RegA;
        REG_NOT_B   <= not RegB;

        adder : entity work.Adder
    		generic map(
    			regWidth 	=> arch_width
    		)
    		port map(
                -- Theoretisch nicht noetig da der Addierer durchgehend arbeitet
    			ena 		=> '1',
    			inputA 		=> RegA,
    			inputB 		=> RegB,
                -- Theoretisch in diesem Fall nicht notwendig
    			carryIn		=> '0',
    			aOutput 	=> ADD_OUT,
    			aCarry 	    => FLAG_OVERFLOW
            )
    	;

        subtr : entity work.Adder
            generic map(
                regWidth 	=> arch_width
            )
            port map(
                -- Theoretisch nicht noetig da der Addierer durchgehend arbeitet
                ena 		=> '1',
                inputA 		=> RegA,
                inputB 		=> RegB,
                -- Theoretisch in diesem Fall nicht notwendig
                carryIn		=> '0',
                aOutput 	=> SUB_OUT,
                aCarry 	    => FLAG_UNDERFLOW
            )
        ;

        shift : entity work.Schieberegister
            generic map(
                regWidth 	=> arch_width
            )
            port map(
                clk		=> clk,
                ena		=> '1',
                plc		=> FLAG_SHIFT_REG_LOAD,
                uOd		=> FLAG_UP_DOWN,
                inputs	=> SHIFT_IN,
                outputs	=> SHIFT_OUT
            )
        ;

        -- TODO Mit Multiplexer synthetisieren?
        -- Is halt um einiges Code aufwendiger und bringt am Ende auch nix
        case OPCODE(7 downto 4) is
            WHEN "0000" => ALU_OUT <= REG_AND;
            WHEN "0000" => ALU_OUT <= REG_OR;
            WHEN "0000" => ALU_OUT <= REG_XOR;
            WHEN "0000" => ALU_OUT <= REG_NOT_A;
            WHEN "0000" => ALU_OUT <= REG_NOT_B;
            WHEN "0000" => ALU_OUT <= ADD_OUT;
            WHEN "0000" => ALU_OUT <= SUB_OUT;
            WHEN "0000" => ALU_OUT <= SHIFT_OUT;
            WHEN "0000" => ALU_OUT <= XOR_out;
            -- Auf 'Z' gesetzt damit die ALU den Datenbus nicht durchgehend besetzt
            WHEN others => ALU_OUT <= (others => 'Z');
        end;

        -- => Bus ist bidirektional und sollte nit durchgehend von der ALU besetzt sein
        if bus_enable = 1 then
            data_bus <= ALU_OUT;
        else
            data_bus <= (others => 'Z');
        end if;

end structure;
