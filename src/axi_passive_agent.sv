class axi_passive_agent extends uvm_agent;
	`uvm_component_utils(axi_passive_agent)
	
	axi_out_mon out_mon;

	extern function new(string name = "axi_passive_agent",uvm_component parent);	
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function axi_passive_agent::new(string name = "axi_passive_agent",uvm_component parent);
	super.new(name,parent);
endfunction

function void axi_passive_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	out_mon = axi_out_mon::type_id::create("out_mon",this);
endfunction

function void axi_passive_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
endfunction

