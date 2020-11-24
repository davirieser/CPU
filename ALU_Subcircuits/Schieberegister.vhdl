library ieee;
	use ieee.std_logic_1164.all;

library work;
    use work.Schieberegister_pkg.all;

entity Schieberegister is
    port(
        res,clk     	: in std_logic; -- Reset and Clock
        ena,uOd		  	: in std_logic; -- Shift-Enable and Up-or-Down
		plc				: in std_logic; -- Parrallel Load Control (Asyncronous)
        inputs  		: in std_logic_vector(regWidth - 1 downto 0);
        outputs 		: out std_logic_vector(regWidth - 1 downto 0)
    );
end Schieberegister;

architecture smartBehaviour of Schieberegister is
    signal intReg : std_logic_vector(regWidth - 1 downto 0); -- Shift Register
    begin
        outputs <= intReg;
        main : process(res,clk,plc)
            begin
                if res = '1' then
                    for iLauf in 0 to regWidth - 1 loop
                        intReg(iLauf) <= '0';
                    end loop;
                elsif plc = '1' then
                    intReg <= inputs;
                elsif clk'event and clk = '1' and ena = '1' then
                    if uOd = '0' then
						intReg <= intReg(regWidth - 2 downto 0) & inputs(0);
                    elsif uOd = '1' then
						intReg <= inputs(0) & intReg(regWidth - 1 downto 1);
                    end if;
                end if;
        end process main;

end smartBehaviour;

architecture ControlData of Schieberegister is

	signal state_s : intState := ST_INIT;
	signal intReg : std_logic_vector(regWidth - 1 downto 0);

	begin
		outputs <= intReg;
		ControlPath : process(res,clk,plc)
			begin
                if res = '1' then
					state_s <= ST_INIT;
				elsif plc = '1' then
					state_s <= ST_PRELOAD;
				elsif ena = '1' then
					if uOd = '0' then
						state_s <= ST_SHIFT_UP;
					elsif uOd = '1' then
						state_s <= ST_SHIFT_DOWN;
					end if;
				else
					state_s <= ST_DO_NOTHING;
				end if;
		end process ControlPath;

		DataPath : process(state_s,clk)
			begin
				if clk'event and clk = '1' then
					case state_s is
						when ST_INIT =>
		                    for iLauf in 0 to regWidth - 1 loop
		                        intReg(iLauf) <= '0';
		                    end loop;
						when ST_PRELOAD =>
		                    intReg <= inputs;
						when ST_SHIFT_UP =>
							intReg <= intReg(regWidth - 2 downto 0) & inputs(0);
						when ST_SHIFT_DOWN =>
							intReg <= inputs(0) & intReg(regWidth - 1 downto 1);
						when ST_DO_NOTHING =>
							null;
					end case;
				end if;
		end process DataPath;

end ControlData;
