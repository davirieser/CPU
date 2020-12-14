
VHDL_COMPILER=ghdl
ANALYSIS_OPTIONS=-a
ELABORATION_OPTIONS=-e
RUN_OPTIONS=-r

SOURCE_FILE_EXT=vhdl
SIM_FILE_EXT=vcd

PACKAGE_SUFFIX=_pkg
TESTBENCH_PREFIX=tb_

WORK_LIBRARY=work-obj93.cf

SUB_DIRS=ALU_Subcircuits CPU_Subcircuits

SOURCE_FILES=CPU_pkg \
ALU \
CPU \
EEPROM \
MemoryManager \
ProgCounter \
Ram \
tb_CPU

CPU_FILES=$(filter-out tb_% %_pkg,$(SOURCE_FILES))
PKG_FILES=$(filter %_pkg,$(SOURCE_FILES))
TB_FILES=$(filter tb_%,$(SOURCE_FILES))

DEST_FOLDER=sim

ifeq ($(SIM_FILE_EXT),ghw)
	SIM_OPTION:=--wave
else
SIM_OPTION:=--vcd
endif

# Assign SIM_OPTION lazily in case the If-Conditional above doesn't work
SIM_OPTION?=--wave

all:  $(patsubst %, %.$(SIM_FILE_EXT), $(SOURCE_FILES))
# all: $(SOURCE_FILES)

tb_%.$(SIM_FILE_EXT) : tb_%.$(SOURCE_FILE_EXT)
	@$(MAKE) -s check_work
	# @if [ -f $(WORK_LIBRARY) ]; then\
	# 	echo "Please create Work-Library"\
	# fi;
	$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $(TESTBENCH_PREFIX)$*.$(SOURCE_FILE_EXT)
	$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $(TESTBENCH_PREFIX)$*
	$(VHDL_COMPILER) $(RUN_OPTIONS) $(TESTBENCH_PREFIX)$* $(SIM_OPTION)=$(DEST_FOLDER)/$@

%$(PACKAGE_SUFFIX).$(SIM_FILE_EXT) : %$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)
	$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)
	# $(VHDL_COMPILER) $(ELABORATION_OPTIONS) $*$(PACKAGE_SUFFIX)

%.$(SIM_FILE_EXT) : %.vhdl
	@$(MAKE) -s check_dir
	$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*.$(SOURCE_FILE_EXT)
	$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $*
	# $(VHDL_COMPILER) $(RUN_OPTIONS) $* $(SIM_OPTION)=$(DEST_FOLDER)/$@

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
