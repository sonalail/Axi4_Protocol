class axi_environment extends uvm_env;
	`uvm_component_utils(axi_environment)
	
	axi_active_agent active_agent;
	axi_passive_agent passive_agent;
	axi_scoreboard scoreboard;
	axi_coverage coverage;

	extern function new(string name = "axi_environment",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function axi_environment::new(string name = "axi_environment",uvm_component parent);
	super.new(name,parent);
endfunction

function void axi_environment::build_phase(uvm_phase phase);
	super.build_phase(phase);
	active_agent = axi_active_agent::type_id::create("active_agent",this);
	passive_agent = axi_passive_agent::type_id::create("passive_agent",this);
	scoreboard = axi_scoreboard::type_id::create("scoreboard",this);
	coverage = axi_coverage::type_id::create("coverage",this);
endfunction

function void axi_environment::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	active_agent.in_mon.in_mon_port.connect(scoreboard.in_mon);
	passive_agent.out_mon.out_mon_port.connect(scoreboard.out_mon);
	//coverage connections
endfunction
