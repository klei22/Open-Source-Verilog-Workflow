#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vtest_name.h"

void tick(int time, Vtest_name* dut, VerilatedVcdC* trace) {

  // Evaluate combinational logic
  dut->eval();

  if (trace) {

    int t = time * 10;

    // Dump trace after eval but before clock edge
    int t_pre_edge = t - 2;
    trace->dump(t_pre_edge);

    // Positive clock edge
    dut->clk = 1;
    dut->eval();

    // Dump trace at positive edge
    int t_pos_edge = t;
    trace->dump(t_pos_edge);

    // Negative clock edge
    dut->clk = 0;
    dut->eval();

    // Dump trace after negative edge
    int t_post_edge = t + 5;
    trace->dump(t_post_edge);
    trace->flush();
  }
}

int main(int argc, char** argv) {

  // Handle arguments
  Verilated::commandArgs(argc, argv);

  // Create testbench
  Vtest_name* dut = new Vtest_name;

  // Tracing
  Verilated::traceEverOn(true);
  VerilatedVcdC* trace = new VerilatedVcdC();
  dut->trace(trace, 99);
  trace->open("test_name.vcd");

  // Simulation
  dut->P1A1 = 0;
  for (int i = 0; i < 257; i++) {

    if ( (i % 16)  < 8) {
      dut->P1A1 = 1;
    } else {
      dut->P1A1 = 0;
    }

    tick(i+1, dut, trace);

    printf("i = %2d, P1A1 = %3x, LED1 = %3x\n",
           i, dut->P1A1, dut->LED1);
  }

  // Cleanup
  trace->close();
  delete dut;
  delete trace;

  return 0;
}
