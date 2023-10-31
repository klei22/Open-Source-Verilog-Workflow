# Definitions
PROJECT_NAME = test_name
ARTIFACTS = intermediates
SOURCES = src/$(PROJECT_NAME).v
STATS_DIR = stats
ICEBREAKER_DEV = up5k
ICEBREAKER_PCF = pinconfig/icebreaker.pcf
LOGS=logs
OUT=build
OUT_SIM=sim_build
ICEBREAKER_PKG = sg48
SEED = 1
ARCHIVE=oss-cad-suite.tgz
OSS_CAD_SUITE = oss-cad-suite
VINC := $(OSS_CAD_SUITE)/share/verilator/include
OSS_CAD_SUITE_URL=https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2023-10-31/oss-cad-suite-linux-x64-20231031.tgz

# List of all Directories (useful for initalization)
DIRS = $(OUT) $(OUT_SIM) $(ARTIFACTS) $(LOGS) $(STATS_DIR)

# Default target
all: $(OUT)/$(PROJECT_NAME).bin

# Directories to create
DIRS = $(OUT) $(OUT_SIM) $(ARTIFACTS) $(LOGS) $(STATS_DIR)

init: $(DIRS) $(OSS_CAD_SUITE)

$(DIRS):
	@mkdir -p $@

$(OSS_CAD_SUITE):
	curl -L $(OSS_CAD_SUITE_URL) -o $(ARCHIVE)
	tar -xvzf $(ARCHIVE)
	rm $(ARCHIVE)

$(ARCHIVE):
	curl -L $(OSS_CAD_SUITE_URL) -o $@

# %.json: src/%.v
$(ARTIFACTS)/yosys.json: $(SOURCES)
	yosys -l $(LOGS)/yosys.log -p 'synth_ice40 -top $(PROJECT_NAME) -json $(ARTIFACTS)/yosys.json' $(SOURCES)

$(ARTIFACTS)/nextpnr.asc: $(ARTIFACTS)/yosys.json $(ICEBREAKER_PCF)
	nextpnr-ice40 -l $(LOGS)/nextpnr.log --seed $(SEED) --freq 20 --package $(ICEBREAKER_PKG) --$(ICEBREAKER_DEV) --asc $@ --pcf $(ICEBREAKER_PCF) --json $<

$(OUT)/$(PROJECT_NAME).bin: $(ARTIFACTS)/nextpnr.asc
	icepack $< $@

prog: $(OUT)/$(PROJECT_NAME).bin
	iceprog $<

obj_dir/V$(PROJECT_NAME).cpp: src/$(PROJECT_NAME).v
	verilator --trace -Wall -cc src/$(PROJECT_NAME).v

obj_dir/V$(PROJECT_NAME)__ALL.a: obj_dir/V$(PROJECT_NAME).cpp
	make -C obj_dir -f V$(PROJECT_NAME).mk

$(OUT_SIM)/$(PROJECT_NAME): sim/$(PROJECT_NAME).cpp obj_dir/V$(PROJECT_NAME)__ALL.a
	g++ -I$(VINC) -I obj_dir \
		$(VINC)/verilated.cpp \
		$(VINC)/verilated_vcd_c.cpp \
		$(VINC)/verilated_threads.cpp \
		sim/$(PROJECT_NAME).cpp -lpthread obj_dir/V$(PROJECT_NAME)__ALL.a \
		-o $(OUT_SIM)/$(PROJECT_NAME)

$(OUT_SIM)/$(PROJECT_NAME).vcd: $(OUT_SIM)/$(PROJECT_NAME)
	./$(OUT_SIM)/$(PROJECT_NAME)
	mv $(PROJECT_NAME).vcd $(OUT_SIM)/$(PROJECT_NAME).vcd

vcd_file: $(OUT_SIM)/$(PROJECT_NAME).vcd

view_trace: vcd_file
	gtkwave $(OUT_SIM)/$(PROJECT_NAME).vcd

buildsim: $(OUT_SIM)/$(PROJECT_NAME) vcd_file

show_synth: src/test_name.v
	yosys -p "read_verilog $^; proc; opt; show -colors 2 -width -signed"

resources:
	yosys -p "synth_ice40 -top $(PROJECT_NAME)" $(SOURCES) > $(STATS_DIR)/$(shell date +%F_%T)

clean:
	rm -f $(ARTIFACTS)/*.json
	rm -f $(ARTIFACTS)/*.asc
	rm -f $(OUT)/*
	rm -f $(OUT_SIM)/*
	rm -f $(PROJECT_NAME)
	find obj_dir -type f -delete
	find $(LOGS) -type f -delete

.PHONY: all clean prog buildsim vcd_file init
