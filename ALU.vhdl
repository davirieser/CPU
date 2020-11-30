
use library work;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;

entity ALU is
    port(
        clk         : in  std_logic;
        ctrl        : in  std_logic;
        operand1    : in  std_logic_vector(oper_width - 1 downto 0);
        operand2    : in  std_logic_vector(oper_width - 1 downto 0);
        status_in   : in  std_logic_vector(numStatReg - 1 downto 0);
        result      : out std_logic_vector(oper_width - 1 downto 0);
        status_out  : out std_logic_vector(numStatReg - 1 downto 0)
    );
end ALU;

architecture behaviour of ALU is

    constant all_zeros  : std_logic_vector(oper_width - 1 downto 0) := (others => '0');
    constant all_ones   : std_logic_vector(oper_width - 1 downto 0) := (others => '1');

    -- Ergebnisleitung fuer logische Verknuepfungen der Register
    signal RES_AND          : std_logic_vector(oper_width - 1 downto 0);
    signal RES_OR           : std_logic_vector(oper_width - 1 downto 0);
    signal RES_XOR          : std_logic_vector(oper_width - 1 downto 0);
    signal RES_NOT_A        : std_logic_vector(oper_width - 1 downto 0);
    signal RES_NOT_B        : std_logic_vector(oper_width - 1 downto 0);

    -- Pseudo-Code : Addierer funktioniert noch nicht weil ich in noch nicht testen konnte
	component Adder is
		generic(
			regWidth 		: integer
		);
	    port(
	        ena             : in  std_logic;
	        inputA  		: in  std_logic_vector(oper_width - 1 downto 0);
	        inputB  		: in  std_logic_vector(oper_width - 1 downto 0);
			carryIn			: in  std_logic;
	        aOutput 		: out std_logic_vector(oper_width - 1 downto 0);
	        aCarry          : out std_logic_vector(oper_width - 1 downto 0)
	    );
	end component Adder;

    -- TODO Subtrahierer funktioniert noch nicht annaehernd
    component Subtractor is
        generic(
            regWidth 		: integer
        );
        port(
            ena             : in  std_logic;
            inputA  		: in  std_logic_vector(oper_width - 1 downto 0);
            inputB  		: in  std_logic_vector(oper_width - 1 downto 0);
            carryIn			: in  std_logic;
            aOutput 		: out std_logic_vector(oper_width - 1 downto 0);
            aCarry          : out std_logic_vector(oper_width - 1 downto 0)
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

        RES_AND     <= operand1 and operand2;
        RES_OR      <= operand1 or operand2;
        RES_XOR     <= operand1 xor operand2;
        RES_NOT_A   <= not operand1;
        RES_NOT_B   <= not operand2;

        adder : entity work.Adder
    		generic map(
    			regWidth 	=> oper_width
    		)
    		port map(
                -- Theoretisch nicht noetig da der Addierer durchgehend arbeitet
    			ena 		=> '1',
    			inputA 		=> operand1,
    			inputB 		=> operand2,
                -- Theoretisch in diesem Fall nicht notwendig
    			carryIn		=> '0',
    			aOutput 	=> ADD_OUT,
    			aCarry 	    => FLAG_OVERFLOW
            )
    	;

        subtr : entity work.Adder
            generic map(
                regWidth 	=> oper_width
            )
            port map(
                -- Theoretisch nicht noetig da der Addierer durchgehend arbeitet
                ena 		=> '1',
                inputA 		=> operand1,
                inputB 		=> operand2,
                -- Theoretisch in diesem Fall nicht notwendig
                carryIn		=> '0',
                aOutput 	=> SUB_OUT,
                aCarry 	    => FLAG_UNDERFLOW
            )
        ;

        shift : entity work.Schieberegister
            generic map(
                regWidth 	=> oper_width
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
            WHEN "0000" => result <= RES_AND;
            WHEN "0000" => result <= RES_OR;
            WHEN "0000" => result <= RES_XOR;
            WHEN "0000" => result <= RES_NOT_A;
            WHEN "0000" => result <= RES_NOT_B;
            WHEN "0000" => result <= ADD_OUT;
            WHEN "0000" => result <= SUB_OUT;
            WHEN "0000" => result <= SHIFT_OUT;
            WHEN "0000" => result <= XOR_out;
            -- Auf 'Z' gesetzt damit die CPU den Datenbus nicht durchgehend besetzt
            WHEN others => result <= (others => 'Z');
        end;

end behaviour;
