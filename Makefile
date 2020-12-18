
VHDL_COMPILER=ghdl
ANALYSIS_OPTIONS=-a
ELABORATION_OPTIONS=-e
RUN_OPTIONS=-r

SIM_FILE_EXT1=ghw
SIM_FILE_EXT2=vcd

SOURCE_FILE_EXT=vhdl
SIM_FILE_EXT=$(SIM_FILE_EXT1)
PACKAGE_SUFFIX=_pkg
TESTBENCH_PREFIX=tb_
DEST_FOLDER=$(abspath sim)
WORKING_FOLDER=$(abspath .)
WORK_LIBRARY=work-obj93.cf

ifeq ($(SIM_FILE_EXT),$(SIM_FILE_EXT1))
SIM_OPTION:=--wave
else ifeq ($(SIM_FILE_EXT),$(SIM_FILE_EXT2))
SIM_OPTION:=--vcd
else
SIM_OPTION:=--vcd
SIM_FILE_EXT:=vcd
endif

SUB_DIRS=ALU_Subcircuits CPU_Subcircuits

VPATH=ALU_Subcircuits:CPU_Subcircuits

# ------------------------------------------------------------------------------
# First analyze all Packages then all the other files in all directories

all: \
	$(patsubst %.vhdl, %, $(wildcard */*_pkg.vhdl) $(wildcard *_pkg.vhdl)) \
	$(patsubst %.vhdl, %, $(filter-out tb_% %_pkg,$(wildcard */*.vhdl) $(wildcard *.vhdl)))
	@echo "Working in $(WORKING_FOLDER)"

$(SIM_FILE_EXT1):
	$(eval SIM_FILE_EXT=$(SIM_FILE_EXT1))
	$(eval SIM_OPTION:=--wave)
	$(MAKE) all

$(SIM_FILE_EXT2):
	$(eval SIM_FILE_EXT=$(SIM_FILE_EXT2))
	$(eval SIM_OPTION:=--vcd)
	$(MAKE) all

# ------------------------------------------------------------------------------
# Analyze Packages

%$(PACKAGE_SUFFIX) : %$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)
ifneq ("$(wildcard $(WORK_LIBRARY))","")
	@echo "Work File already exists"
else
	@echo "Analyzing Package-File $*$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)"
	@$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)
endif

# ------------------------------------------------------------------------------
# Ignore Testbenches => Will be called by their respective Test-File

$(TESTBENCH_PREFIX)% : $(TESTBENCH_PREFIX)%.$(SOURCE_FILE_EXT)
	@echo "Ignoring Testbench $*"

# ------------------------------------------------------------------------------
# Rule for VHDL-Files which also have a Testbench

% : %.$(SOURCE_FILE_EXT) $(TESTBENCH_PREFIX)%.$(SOURCE_FILE_EXT)
	@echo "Analyzing and elobarating $*"
	$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*.$(SOURCE_FILE_EXT)
	$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $(notdir $*)
	@$(eval TESTBENCH_NAME=$(dir $*)$(TESTBENCH_PREFIX)$(notdir $*))
	@echo "Running Simulation for $*"
	$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $(TESTBENCH_NAME).$(SOURCE_FILE_EXT)
	$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $(notdir $(TESTBENCH_NAME))
	@[ -d $(DEST_FOLDER) ] || false
	$(VHDL_COMPILER) $(RUN_OPTIONS) $(notdir $(TESTBENCH_NAME)) \
		$(SIM_OPTION)=$(subst $(WORKING_FOLDER)/,,$(DEST_FOLDER)/$(notdir $*).$(SIM_FILE_EXT))

# ------------------------------------------------------------------------------
# General Rule for all VHDL-Files

% : %.$(SOURCE_FILE_EXT)
	@echo "Analyzing and elobarating $*"
	@$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*.$(SOURCE_FILE_EXT)
	@$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $(notdir $*)

# ------------------------------------------------------------------------------
# Clean Command

.PHONY: clean
clean:
	-rm -f $(WORK_LIBRARY)
	-rm -f $(DEST_FOLDER)/*.$(SIM_FILE_EXT)
