import uvm_pkg::*;
`include "uvm_macros.svh"

`include "global_pkg.sv"
import AxiGlobalPackage::*;

`include "../rtl/axi_lite_slave.v"

`include "axi_transaction.sv"
`include "axi_sequence.sv"

`include "axi_interface.sv"
`include "axi_sequencer.sv"
`include "axi_driver.sv"
`include "axi_in_mon.sv"
`include "axi_active_agent.sv"
`include "axi_out_mon.sv"
`include "axi_passive_agent.sv"
`include "axi_coverage.sv"
`include "axi_scoreboard.sv"
`include "axi_environment.sv"

`include "axi_test.sv"
