library work;
    use work.INST_DEC_pkg.all;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.Numeric_Std.all;

entity INST_DEC is
    port(
        clk         : in std_logic;
        inst        : in std_logic_vector(OPCODE_BITS - 1 downto 0);
        micro_cyc   : in std_logic_vector(NUM_MICRO_CYC - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0)
    );
end INST_DEC;

architecture behaviour of INST_DEC is

    begin

        dec : process

            begin

                case inst is
                    when NOP_INST =>
                        ctrl_bus <= NOP_CODES(to_index(micro_cyc));
                    when MOV_INST =>
                        ctrl_bus <= MOV_CODES(to_index(micro_cyc));
                    when JEZ_INST =>
                        ctrl_bus <= JEZ_CODES(to_index(micro_cyc));
                    when JCO_INST =>
                        ctrl_bus <= JCO_CODES(to_index(micro_cyc));
                    when JSN_INST =>
                        ctrl_bus <= JSN_CODES(to_index(micro_cyc));
                    when ADD_INST =>
                        ctrl_bus <= ADD_CODES(to_index(micro_cyc));
                    when SUB_INST =>
                        ctrl_bus <= SUB_CODES(to_index(micro_cyc));
                    when SHL_INST =>
                        ctrl_bus <= SHL_CODES(to_index(micro_cyc));
                    when SHR_INST =>
                        ctrl_bus <= SHR_CODES(to_index(micro_cyc));
                    when TWC_INST =>
                        ctrl_bus <= TWC_CODES(to_index(micro_cyc));
                    when WFI_INST =>
                        ctrl_bus <= WFI_CODES(to_index(micro_cyc));
                    -- Default to NOP if Instruction is not recognized
                    when others =>
                        ctrl_bus <= NOP_CODES(to_index(micro_cyc));
                end case;

        end process dec;

end behaviour;
