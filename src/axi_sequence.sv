class axi_sequence extends uvm_sequence#(axi_transaction);
	`uvm_object_utils(axi_sequence)

	function new(string name = "axi_sequence");
		super.new(name);
	endfunction

	task body();
		`uvm_info("BASE SEQUENCE","INSIDE BASE SEQUENCE",UVM_LOW);
	endtask
endclass


class axi_write_seq extends axi_sequence;
	`uvm_object_utils(axi_write_seq)
	
	function new(string name = "axi_write_seq");
		super.new(name);
	endfunction

	task body();
		axi_transaction packet = axi_transaction::type_id::create("packet");
		
		repeat(1)
			begin
				`uvm_do_with(packet,{packet.wr_rd == 1;packet.awaddr == 'h10;})
			end
	endtask
endclass

class axi_read_seq extends axi_sequence;
	`uvm_object_utils(axi_read_seq)
	
	function new(string name = "axi_write_seq");
		super.new(name);
	endfunction

	task body();
		axi_transaction packet = axi_transaction::type_id::create("packet");
		
		repeat(1)
			begin
				`uvm_do_with(packet,{packet.wr_rd == 0;packet.araddr == 'h10;})
			end
	endtask
endclass

