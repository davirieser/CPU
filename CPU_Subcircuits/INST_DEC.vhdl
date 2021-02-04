library work;
    use work.INST_DEC_pkg.all;
    use work.CPU_pkg.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_Std.all;

entity INST_DEC is
    port(
        -- This is basically a Lookup-Table so it needs neither a
        -- Reset nor a Clock
        inst        : in std_logic_vector(OPCODE_BITS + NUM_FLAGS - 1 downto 0);
        flags_in    : in std_logic_vector(NUM_FLAGS - 1 downto 0);
        micro_cyc   : in std_logic_vector(NUM_MICRO_CYC - 1 downto 0);
        alu_ctrl    : out std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0);
        ctrl_bus    : inout std_logic_vector(ctrl_bus_width - 1 downto 0);
        ext_bus     : inout std_logic_vector(ext_bus_width - 1 downto 0)
    );
end INST_DEC;

architecture behaviour of INST_DEC is

    signal ctrl_bus_intern  : std_logic_vector(ctrl_bus_width - 1 downto 0)
        := NOP_CTRL_CODE;
    signal alu_ctrl_intern  : std_logic_vector(ALU_CTRL_WIDTH - 1 downto 0)
        := NOP_ALU_CODE;
    signal ext_bus_intern  : std_logic_vector(ext_bus_width - 1 downto 0)
        := NOP_EXT_CODE;

    begin

        ctrl_bus <= ctrl_bus_intern;
        alu_ctrl <= alu_ctrl_intern;
        ext_bus <= ext_bus_intern;

        p_decoding : process(micro_cyc)

            variable index  : integer := 0;

            begin

                -- TODO Zum Multiplexer umschreiben
                index := to_index(micro_cyc);

                Decoders : for i in NUM_OPCODES - 1 downto 0 loop

                    if (compare_dont_care(INST_SET(i).INST_ID,inst)) then

                        ctrl_bus_intern <= INST_SET(i).INST_CODES(index);
                        alu_ctrl_intern <= INST_SET(i).ALU_CODES(index);
                        ext_bus_intern <= INST_SET(i).EXT_CODES(index);

                    end if;

                end loop Decoders;

        end process p_decoding;

        debug : process (micro_cyc)

            begin

                if (INST_DEC_DEBUG) then

                    for i in NUM_OPCODES - 1 downto 0 loop

                        if (compare_dont_care(INST_SET(i).INST_ID,inst)) then

                            report "Instruction : " & INST_NAMES(to_index(inst));

                        end if;

                    end loop;

                end if;

        end process debug;

end behaviour;

                -- if (inst = NOP_INST) then
                --     -- report "NOP Instruction";
                --     ctrl_bus_intern <= NOP_CODES(index);
                --     alu_ctrl <= NO_ALU_OPERATION(index);
                -- elsif (inst = MOVA_INST) then
                --     -- report "MOVA Instruction";
                --     ctrl_bus_intern <= MOVA_CODES(index);
                --     alu_ctrl <= NO_ALU_OPERATION(index);
                -- elsif (inst = JEZ_INST) then
                --     -- report "JEZ Instruction";
                --     if (flags_in(ZERO_FLAG) = '1') then
                --         ctrl_bus_intern <= JEZ_CODES_S(index);
                --     else
                --         ctrl_bus_intern <= JEZ_CODES_NS(index);
                --     end if;
                --     alu_ctrl <= NO_ALU_OPERATION(index);
                -- elsif (inst = JCO_INST) then
                --     -- report "JCO Instruction";
                --     if (flags_in(CARRY_FLAG) = '1') then
                --         ctrl_bus_intern <= JCO_CODES_S(index);
                --     else
                --         ctrl_bus_intern <= JCO_CODES_NS(index);
                --     end if;
                --     alu_ctrl <= NO_ALU_OPERATION(index);
                -- elsif (inst = JSN_INST) then
                --     -- report "JSN Instruction";
                --     if (flags_in(SIGN_FLAG) = '1') then
                --         ctrl_bus_intern <= JSN_CODES_S(index);
                --     else
                --         ctrl_bus_intern <= JSN_CODES_NS(index);
                --     end if;
                --     alu_ctrl <= NO_ALU_OPERATION(index);
                -- elsif (inst = ADD_INST) then
                --     -- report "ADD Instruction";
                --     ctrl_bus_intern <= ADD_CODES(index);
                --     alu_ctrl <= ADD_ALU_CTRL(index);
                -- elsif (inst = SUB_INST) then
                --     -- report "SUB Instruction";
                --     ctrl_bus_intern <= SUB_CODES(index);
                --     alu_ctrl <= SUB_ALU_CTRL(index);
                -- elsif (inst = SHL_INST) then
                --     -- report "SHL Instruction";
                --     ctrl_bus_intern <= SHL_CODES(index);
                --     alu_ctrl <= SHL_ALU_CTRL(index);
                -- elsif (inst = SHR_INST) then
                --     -- report "SHR Instruction";
                --     ctrl_bus_intern <= SHR_CODES(index);
                --     alu_ctrl <= SHR_ALU_CTRL(index);
                -- elsif (inst = TWC_INST) then
                --     -- report "TWC Instruction";
                --     ctrl_bus_intern <= TWC_CODES(index);
                --     alu_ctrl <= TWC_ALU_CTRL(index);
                -- elsif (inst = WFI_INST) then
                --     -- report "WFI Instruction";
                --     ctrl_bus_intern <= WFI_CODES(index);
                --     alu_ctrl <= NO_ALU_OPERATION(index);
                -- else
                --     -- report "Not Found => NOP Instruction";
                --     -- Default to NOP if Instruction is not recognized
                --     ctrl_bus_intern <= NOP_CODES(index);
                --     alu_ctrl <= NO_ALU_OPERATION(index);
                -- end if;

                -- case inst is
                --     -- TODO Irgendwie muss des lokal statisch sein
                --     when NOP_INST =>
                --         ctrl_bus <= NOP_CODES(index);
                --     when MOV_INST =>
                --         ctrl_bus <= MOV_CODES(index);
                --     when JEZ_INST =>
                --         ctrl_bus <= JEZ_CODES(index);
                --         if flags_in(ZERO_FLAG) = '1' then
                --             ctrl_bus <= ctrl_bus or PRC_IN;
                --         end if;
                --     when JCO_INST =>
                --         ctrl_bus <= JCO_CODES(index);
                --         if flags_in(OVERF_FLAG) = '1' then
                --             ctrl_bus <= ctrl_bus or PRC_IN;
                --         end if;
                --     when JSN_INST =>
                --         ctrl_bus <= JSN_CODES(index);
                --         if flags_in(SIGN_FLAG) = '1' then
                --             ctrl_bus <= ctrl_bus or PRC_IN;
                --         end if;
                --     when ADD_INST =>
                --         ctrl_bus <= ADD_CODES(index);
                --     when SUB_INST =>
                --         ctrl_bus <= SUB_CODES(index);
                --     when SHL_INST =>
                --         ctrl_bus <= SHL_CODES(index);
                --     when SHR_INST =>
                --         ctrl_bus <= SHR_CODES(index);
                --     when TWC_INST =>
                --         ctrl_bus <= TWC_CODES(index);
                --     when WFI_INST =>
                --         ctrl_bus <= WFI_CODES(index);
                --     -- Default to NOP if Instruction is not recognized
                --     when others =>
                --         ctrl_bus <= NOP_CODES(index);
                -- end case;
