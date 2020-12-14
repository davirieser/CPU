
VHDL_COMPILER = ghdl
ANALYSIS_OPTIONS = --warn-error -a
ELABORATION_OPTIONS = -e
RUN_OPTIONS = -r

SOURCE_FILE_EXT = vhdl
SIM_FILE_EXT = vwd

WORK_LIBRARY = work-obj93.cf

SOURCE_FILES = ALU \
Bus \
CPU_pkg \
EEPROM \
MemoryManager \
ProgCounter \
Ram \
tb_CPU

CPU_FILES = $(filter-out tb_% %_pkg,$(SOURCE_FILES))
PKG_FILES = $(filter %_pkg,$(SOURCE_FILES))
TB_FILES = $(filter tb_%,$(SOURCE_FILES))

DEST_FOLDER = sim

ifeq ($(SIM_FILE_EXT),ghw)
SIM_OPTION := --wave=
else
SIM_OPTION := --vwd=
endif

# Assign SIM_OPTION lazily in case the If-Conditional above doesn't work
SIM_OPTION ?= --wave=

all:  $(patsubst %.vhdl, %.$(SIM_FILE_EXT), $(wildcard *.vhdl))

%.$(SIM_FILE_EXT) : %.vhdl
	$(MAKE) check_sim_dir
	$(VHDL_COMPILER) $(ANALYSIS_OPTIONS) $*.$(SOURCE_FILE_EXT)
	$(VHDL_COMPILER) $(ELABORATION_OPTIONS) $*
	$(VHDL_COMPILER) $(RUN_OPTIONS) $(SIM_OPTION)=$@.$(SIM_FILE_EXT) $*

# Check if the Simulation Directory is creater
.PHONY: check_sim_dir
check_sim_dir:
	@[ -d $(DEST_FOLDER) ] || mkdir $(DEST_FOLDER)

.PHONY: clean
clean:
	-rm -f *.$(SIM_FILE_EXT)
	-rm -f $(DEST_FOLDER)/*.$(SIM_FILE_EXT)
	-rm -f $(WORK_LIBRARY)
