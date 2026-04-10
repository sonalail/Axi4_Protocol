`include "axi_package.sv"

module axi_top;
bit aclk;
bit areset;

initial
  begin
    aclk <= 0;
      forever #5 aclk = ~aclk;  
  end

 initial
    begin
      areset = 1;
    	#10 areset = 0;
    end

axi_lite_slave #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH)) axi_slave(
  .aclk    (aclk),
  .areset  (areset),

  .awaddr  (intf_inst.awaddr),
  .awvalid (intf_inst.awvalid),
  .awready (intf_inst.awready),

  .wdata   (intf_inst.wdata),
  .wstrb   (intf_inst.wstrb),
  .wvalid  (intf_inst.wvalid),
  .wready  (intf_inst.wready),

  .bresp   (intf_inst.bresp),
  .bvalid  (intf_inst.bvalid),
  .bready  (intf_inst.bready),

  .araddr  (intf_inst.araddr),
  .arvalid (intf_inst.arvalid),
  .arready (intf_inst.arready),

  .rdata   (intf_inst.rdata),
  .rresp   (intf_inst.rresp),
  .rvalid  (intf_inst.rvalid),
  .rready  (intf_inst.rready)
);

axi_interface intf_inst(
  .aclk(aclk),
  .areset(areset));

  //defining config db to access variables inside testbench components
  initial
    begin
      uvm_config_db#(virtual axi_interface.driver_mod)::set(null, "*", "vif", intf_inst.driver_mod);
      uvm_config_db#(virtual axi_interface.in_mon_mod)::set(null, "*", "vif", intf_inst.in_mon_mod);
      uvm_config_db#(virtual axi_interface.out_mon_mod)::set(null, "*", "vif", intf_inst.out_mon_mod);
	
      //initiating the simulation
      run_test("axi_test");
    end

  //defining waveform file
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars();
    end

endmodule
