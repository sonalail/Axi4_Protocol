class axi_active_agent extends uvm_agent;
	`uvm_component_utils(axi_active_agent)
	
	axi_sequencer sequencer;
	axi_driver driver;
	axi_in_mon in_mon;

	extern function new(string name = "axi_active_agent",uvm_component parent);	
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function axi_active_agent::new(string name = "axi_active_agent",uvm_component parent);
	super.new(name,parent);
endfunction

function void axi_active_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	sequencer = axi_sequencer::type_id::create("sequencer",this);
	driver = axi_driver::type_id::create("driver",this);
	in_mon = axi_in_mon::type_id::create("in_mon",this);
endfunction

function void axi_active_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	driver.seq_item_port.connect(sequencer.seq_item_export);
endfunction

