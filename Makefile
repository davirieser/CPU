
VHDL_COMPILER=ghdl
WAVE_VIEWER=gtkwave
CC=gcc
ANALYSIS_OPTIONS=-a
# --std=93
ELABORATION_OPTIONS=-e
# --std=93
RUN_OPTIONS=-r

SIM_EXT1=ghw
SIM_EXT2=vcd

SOURCE_FILE_EXT=vhdl
SIM_EXT=$(SIM_EXT1)
PACKAGE_SUFFIX=_pkg
TESTBENCH_PREFIX=tb_
DEST_FOLDER=$(abspath sim)
WORKING_FOLDER=$(abspath .)
WORK_LIBRARY=work-obj93.cf
GHWDUMP_FOLDER=ghwdump

# Include Subdirectories for VHDL-Files
VPATH=ALU_Subcircuits:CPU_Subcircuits:Packages

ifeq ($(SIM_EXT),$(SIM_EXT1))
SIM_OPTION:=--wave
else ifeq ($(SIM_EXT),$(SIM_EXT2))
SIM_OPTION:=--vcd
else
SIM_OPTION:=--wave
SIM_EXT:=ghw
endif

ifdef SIM
SIMULATE:=1
else
SIMULATE:=0
endif

# ------------------------------------------------------------------------------
# First analyze all Packages then all the other files in all directories

all: \
	$(patsubst %.vhdl, %, $(wildcard */*_pkg.vhdl) $(wildcard *_pkg.vhdl)) \
	$(patsubst %.vhdl, %, $(filter-out %_pkg tb_%,$(wildcard */*.vhdl) $(wildcard *.vhdl)))

# ------------------------------------------------------------------------------
# Analyze all Packages
.PHONY: pkg
pkg: $(patsubst %.vhdl, %, $(wildcard */*_pkg.vhdl) $(wildcard *_pkg.vhdl))


# ------------------------------------------------------------------------------
# Analyze Package
%$(PACKAGE_SUFFIX) : %$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)
	@echo "Analyzing Package-File $*$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)"
	@-$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*$(PACKAGE_SUFFIX).$(SOURCE_FILE_EXT)

# ------------------------------------------------------------------------------
# Ignore Testbenches => Will be called by their respective Test-File
$(TESTBENCH_PREFIX)% : $(TESTBENCH_PREFIX)%.$(SOURCE_FILE_EXT)
	@echo "Ignoring Testbench $*"

# ------------------------------------------------------------------------------
# Rule for VHDL-Files which also have a Testbench
% : %.$(SOURCE_FILE_EXT) $(TESTBENCH_PREFIX)%.$(SOURCE_FILE_EXT)
	@echo "Analyzing and elobarating $*"
	-$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*.$(SOURCE_FILE_EXT)
	-$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $(notdir $*)
	@echo "Running Simulation for $*"
	-$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) \
		$(dir $*)$(TESTBENCH_PREFIX)$(notdir $*).$(SOURCE_FILE_EXT)
	-$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $(TESTBENCH_PREFIX)$(notdir $*)
	@[ -d $(DEST_FOLDER) ] || false
	-$(VHDL_COMPILER) $(RUN_OPTIONS) $(TESTBENCH_PREFIX)$(notdir $*) \
		$(SIM_OPTION)=$(subst $(WORKING_FOLDER)/,,$(DEST_FOLDER)/$(notdir $*).$(SIM_EXT))
ifeq ($(SIMULATE),1)
	-$(WAVE_VIEWER) $(subst $(WORKING_FOLDER)/,,$(DEST_FOLDER)/$(notdir $*).$(SIM_EXT))
endif

# ------------------------------------------------------------------------------
# General Rule for all VHDL-Files

% : %.$(SOURCE_FILE_EXT)
	@echo "Analyzing and elobarating $*"
	@-$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*.$(SOURCE_FILE_EXT)
	@-$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $(notdir $*)

# ------------------------------------------------------------------------------
# Compile GHW-File-Dumper

ghwdump: $(GHWDUMP_FOLDER)/ghwdump

$(GHWDUMP_FOLDER)/ghwdump: $(GHWDUMP_FOLDER)/ghwdump.o $(GHWDUMP_FOLDER)/ghwlib.o
	$(CC) -g -O -Wall -o $@ $(GHWDUMP_FOLDER)/ghwdump.o $(GHWDUMP_FOLDER)/ghwlib.o

$(GHWDUMP_FOLDER)/ghwlib.o: $(GHWDUMP_FOLDER)/ghwlib.c $(GHWDUMP_FOLDER)/ghwlib.h
	$(CC) -c -g -O -Wall -o $@ $<
$(GHWDUMP_FOLDER)/ghwdump.o: $(GHWDUMP_FOLDER)/ghwdump.c $(GHWDUMP_FOLDER)/ghwlib.h
	$(CC) -c -g -O -Wall -o $@ $<

# ------------------------------------------------------------------------------
# Clean Command

.PHONY: clean
clean:
	-rm -f $(WORK_LIBRARY)
	-rm -f $(DEST_FOLDER)/*.$(SIM_EXT1)
	-rm -f $(DEST_FOLDER)/*.$(SIM_EXT2)
	-rm -f $(GHWDUMP_FOLDER)/*.o $(GHWDUMP_FOLDER)/ghwdump

# ------------------------------------------------------------------------------
