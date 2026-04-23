class axi_transaction extends uvm_sequence_item;

    rand bit [ADDR_WIDTH - 1:0] awaddr;
	rand axi_trans_type awburst;
	rand axi_size awsize;

	rand bit [DATA_WIDTH - 1:0] wdata;
	rand bit [STROBE - 1:0] wstrb;

	axi_resp bresp;

	rand bit [ADDR_WIDTH - 1:0] araddr;
	rand axi_trans_type arburst;
	rand axi_size arsize;

	bit [DATA_WIDTH - 1:0] rdata;
	axi_resp rresp;
	
	rand axi_write_read wr_rd;

	`uvm_object_utils_begin(axi_transaction)
		`uvm_field_int(awaddr,UVM_ALL_ON)
		`uvm_field_int(wdata,UVM_ALL_ON)
		`uvm_field_int(wstrb,UVM_ALL_ON)
		`uvm_field_enum(axi_trans_type,awburst,UVM_ALL_ON)
		`uvm_field_enum(axi_size,awsize,UVM_ALL_ON)
		`uvm_field_enum(axi_trans_type,arburst,UVM_ALL_ON)
		`uvm_field_enum(axi_size,arsize,UVM_ALL_ON)
		`uvm_field_enum(axi_resp,bresp,UVM_ALL_ON)
		`uvm_field_int(araddr,UVM_ALL_ON)
		`uvm_field_int(rdata,UVM_ALL_ON)
		`uvm_field_enum(axi_resp,rresp,UVM_ALL_ON)
		`uvm_field_enum(axi_write_read,wr_rd,UVM_ALL_ON)
	`uvm_object_utils_end

	constraint awaddr_byte_addressable{soft awaddr[1:0] == 0;}

	constraint araddr_byte_addressable{soft araddr[1:0] == 0;}

	constraint wstrb_value{soft wstrb == 4'b1111;}

	constraint awburst_value{soft awburst == 2'b00;}
	constraint arburst_value{soft arburst == 2'b00;}

	constraint awsize_c{soft awsize == 2'b10;}
	constraint arsize_c{soft arsize == 2'b10;}

	extern function new(string name = "axi_transaction");

endclass

function axi_transaction::new(string name = "axi_transaction");
	super.new(name);
endfunction

