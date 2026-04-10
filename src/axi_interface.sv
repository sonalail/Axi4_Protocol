import AxiGlobalPackage::*;
 
interface axi_interface(input aclk,input areset);
	logic [ADDR_WIDTH - 1:0] awaddr;
	logic awvalid;
	logic awready;
	logic [1:0]awburst;
	logic [1:0]awsize;

	logic [DATA_WIDTH - 1:0] wdata;
	logic [STROBE - 1:0] wstrb;
	logic wvalid;
	logic wready;

	logic bvalid;
	logic bready;
	logic [1:0]bresp;

	logic [ADDR_WIDTH - 1:0] araddr;
	logic arvalid;
	logic arready;
	logic [1:0]arburst;
	logic [1:0]arsize;

	logic [DATA_WIDTH - 1:0] rdata;
	logic rvalid;
	logic rready;
	logic [1:0]rresp;

	clocking cb_driver @(posedge aclk);
		default input #1ns output #1ns;
		output awaddr;
		output awvalid;
		output awburst;
		output awsize;
		input  awready;

		output wdata;
		output wvalid;
		output wstrb;
		input wready;

		input  bvalid;
		input  bresp;
		output bready;

		output araddr;
		output arvalid;
		input  arready;
		output arburst;
		output arsize;

		input  rdata;
		input  rvalid;
		output rready;
		input  rresp;
	endclocking

	clocking cb_in_mon @(posedge aclk);
		default input #1ns output #1ns;
		input awaddr;
		input awvalid;
		input awready;
		input awburst;
		input awsize;

		input wdata;
		input wvalid;
		input wstrb;
		input wready;

		input  bvalid;
		input  bresp;
		input bready;

		input araddr;
		input arvalid;
		input  arready;
		input arburst;
		input arsize;

		input  rdata;
		input  rvalid;
		input  rready;
		input  rresp;
	endclocking

	clocking cb_out_mon @(posedge aclk);
		default input #1ns output #1ns;
		input awaddr;
		input awvalid;
		input awready;
		input awburst;
		input awsize;

		input wdata;
		input wvalid;
		input wstrb;
		input wready;

		input  bvalid;
		input  bresp;
		input  bready;

		input araddr;
		input arvalid;
		input arready;
		input arburst;
		input arsize;

		input  rdata;
		input  rvalid;
		input  rready;
		input  rresp;
	endclocking


	modport driver_mod(clocking cb_driver ,input areset);
	modport in_mon_mod(clocking cb_in_mon ,input areset);
	modport out_mon_mod(clocking cb_out_mon ,input areset);

endinterface
