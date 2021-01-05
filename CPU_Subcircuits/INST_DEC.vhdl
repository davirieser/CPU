library work;
    use work.INST_DEC_pkg.all;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.Numeric_Std.all;

entity INST_DEC is
    port(
        -- This is basically a Lookup-Table so it neither needs a
        -- Reset nor a Clock
        inst        : in std_logic_vector(OPCODE_BITS - 1 downto 0);
        flags_in    : in std_logic_vector(NUM_FLAGS - 1 downto 0);
        micro_cyc   : in std_logic_vector(NUM_MICRO_CYC - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0)
    );
end INST_DEC;

architecture behaviour of INST_DEC is

    begin

        dec : process(micro_cyc)

            begin

                if (inst = NOP_INST) then
                    ctrl_bus <= NOP_CODES(to_index(micro_cyc));
                elsif (inst = MOVA_INST) then
                    ctrl_bus <= MOVA_CODES(to_index(micro_cyc));
                elsif (inst = JEZ_INST) then
                    ctrl_bus <= JEZ_CODES(to_index(micro_cyc));
                elsif (inst = JCO_INST) then
                    ctrl_bus <= JCO_CODES(to_index(micro_cyc));
                elsif (inst = JSN_INST) then
                    ctrl_bus <= JSN_CODES(to_index(micro_cyc));
                elsif (inst = ADD_INST) then
                    ctrl_bus <= ADD_CODES(to_index(micro_cyc));
                elsif (inst = SUB_INST) then
                    ctrl_bus <= SUB_CODES(to_index(micro_cyc));
                elsif (inst = SHL_INST) then
                    ctrl_bus <= SHL_CODES(to_index(micro_cyc));
                elsif (inst = SHR_INST) then
                    ctrl_bus <= SHR_CODES(to_index(micro_cyc));
                elsif (inst = TWC_INST) then
                    ctrl_bus <= TWC_CODES(to_index(micro_cyc));
                elsif (inst = WFI_INST) then
                    ctrl_bus <= WFI_CODES(to_index(micro_cyc));
                else
                    -- Default to NOP if Instruction is not recognized
                    ctrl_bus <= NOP_CODES(to_index(micro_cyc));
                end if;

                -- case inst is
                --     -- TODO Irgendwie muss des lokal statisch sein
                --     when NOP_INST =>
                --         ctrl_bus <= NOP_CODES(to_index(micro_cyc));
                --     when MOV_INST =>
                --         ctrl_bus <= MOV_CODES(to_index(micro_cyc));
                --     when JEZ_INST =>
                --         ctrl_bus <= JEZ_CODES(to_index(micro_cyc));
                --         if flags_in(ZERO_FLAG) = '1' then
                --             ctrl_bus <= ctrl_bus or PRC_IN;
                --         end if;
                --     when JCO_INST =>
                --         ctrl_bus <= JCO_CODES(to_index(micro_cyc));
                --         if flags_in(OVERF_FLAG) = '1' then
                --             ctrl_bus <= ctrl_bus or PRC_IN;
                --         end if;
                --     when JSN_INST =>
                --         ctrl_bus <= JSN_CODES(to_index(micro_cyc));
                --         if flags_in(SIGN_FLAG) = '1' then
                --             ctrl_bus <= ctrl_bus or PRC_IN;
                --         end if;
                --     when ADD_INST =>
                --         ctrl_bus <= ADD_CODES(to_index(micro_cyc));
                --     when SUB_INST =>
                --         ctrl_bus <= SUB_CODES(to_index(micro_cyc));
                --     when SHL_INST =>
                --         ctrl_bus <= SHL_CODES(to_index(micro_cyc));
                --     when SHR_INST =>
                --         ctrl_bus <= SHR_CODES(to_index(micro_cyc));
                --     when TWC_INST =>
                --         ctrl_bus <= TWC_CODES(to_index(micro_cyc));
                --     when WFI_INST =>
                --         ctrl_bus <= WFI_CODES(to_index(micro_cyc));
                --     -- Default to NOP if Instruction is not recognized
                --     when others =>
                --         ctrl_bus <= NOP_CODES(to_index(micro_cyc));
                -- end case;

        end process dec;

end behaviour;
