
VHDL_COMPILER=ghdl
ANALYSIS_OPTIONS=-a
ELABORATION_OPTIONS=-e
RUN_OPTIONS=-r

SOURCE_FILE_EXT=vhdl
SIM_FILE_EXT=vcd
PACKAGE_SUFFIX=_pkg
TESTBENCH_PREFIX=tb_
DEST_FOLDER=sim
WORK_LIBRARY=work-obj93.cf

ifeq ($(SIM_FILE_EXT),ghw)
	SIM_OPTION:=--wave
else
	SIM_OPTION:=--vcd
endif

# Assign SIM_OPTION lazily in case the If-Conditional above doesn't work
SIM_OPTION?=--wave

CPU_FILES=$(filter-out tb_% %_pkg,$(SOURCE_FILES))
PKG_FILES=$(filter %_pkg,$(SOURCE_FILES))
TB_FILES=$(filter tb_%,$(SOURCE_FILES))

SUB_DIRS=ALU_Subcircuits CPU_Subcircuits

SOURCE_FILES=CPU_pkg \
ALU \
CPU \
EEPROM \
MemoryManager \
ProgCounter \
Ram \
tb_CPU \
tb_ALU

all: $(sort $(patsubst %.vhdl, %.$(SIM_FILE_EXT), $(wildcard *.vhdl)))

$(TESTBENCH_PREFIX)%.$(SIM_FILE_EXT) : $(TESTBENCH_PREFIX)%.$(SOURCE_FILE_EXT)
ifneq ("$(wildcard $(WORK_LIBRARY))","")
	$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $(TESTBENCH_PREFIX)$*.$(SOURCE_FILE_EXT)
	$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $(TESTBENCH_PREFIX)$*
	$(VHDL_COMPILER) $(RUN_OPTIONS) $(TESTBENCH_PREFIX)$* $(SIM_OPTION)=$(DEST_FOLDER)/$@
else
	@echo "Work File Missing"
endif

%$(PACKAGE_SUFFIX).$(SIM_FILE_EXT) : %$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)
ifneq ("$(wildcard $(WORK_LIBRARY))","")
	@echo "Work File exists"
else
	$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)
endif

%.$(SIM_FILE_EXT) : %.vhdl
ifneq ("$(wildcard $(WORK_LIBRARY))","")
	$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*.$(SOURCE_FILE_EXT)
	@$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $*
else
	@echo "Work File Missing"
endif

# Check if the Simulation Directory is created, otherwise create it
.PHONY: check_dir
check_sim_dir:
	@[ -d $(DEST_FOLDER) ] || mkdir $(DEST_FOLDER)

# Check if the Work-Library exists
.PHONY: check_work
check_work:
	@[ -f $(WORK_LIBRARY) ] || false

.PHONY: clean
clean:
	-rm -f *.$(SIM_FILE_EXT)
	-rm -f $(DEST_FOLDER)/*.$(SIM_FILE_EXT)
	-rm -f $(WORK_LIBRARY)
