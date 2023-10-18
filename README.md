# Open Source Verilog Workflow

This is a template for Verilog projects using open source EDA tools. It provides
a quickstart workflow for synthesizing, simulating, and viewing traces for rtl.

## Prerequisites

- Ubuntu Linux
- GNU Make
- [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) - installed via `make init`

## Quickstart

After cloning the repo, run:

```bash
make init
source oss-cad-suite/environment
```

This will download and install the OSS CAD Suite tools and setup the
environment.

Note: run the `source oss-cad-suite/environment` if starting a new terminal.

## Synthesis

To run synthesis simply run make:
```bash
make
```

This will synthesize the design to JSON.

## Simulation

To run verilator simulation run the build simulation command:
```bash
make buildsim
```

## View Trace

To view the trace with gtkwave, first run synthesis and simulation then run:
```bash
make view_trace
```

## Additional Commands

- `make show_synth` - Show diagram of design
- `make resources` - Report resource usage
- `make clean` - Delete generated files

See the Makefile for additional targets.

## Customizing

- Edit `src/test_name.v` to add your Verilog design.
- Edit the `PROJECT_NAME` variable to change the module name.
- Edit the board target, seed, etc. by modifying the Makefile variables.
- edit the `sim/test_name.cpp` tile to reflect the new name of the top module.

## License

This repo is under the Apache-2.0 license.

