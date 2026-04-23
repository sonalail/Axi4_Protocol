class axi_test extends uvm_test;
	`uvm_component_utils(axi_test)

	axi_environment env;

	extern function new(string name = "axi_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration();
	extern task run_phase(uvm_phase phase);
endclass

	function axi_test::new(string name = "axi_test", uvm_component parent);
		super.new(name, parent);
	endfunction	

	//defining build phase
	function void axi_test::build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = axi_environment::type_id::create("env", this);
	endfunction

	//defining end of elaboration phase
	function void axi_test::end_of_elaboration();
		super.end_of_elaboration();
		`uvm_info(get_type_name(), $sformatf("Inside END of Elaboration phase in Base test"), UVM_LOW);
		print();
	endfunction

	//defining run phase
	task axi_test::run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		`uvm_info(get_type_name(), $sformatf("Inside AXI_TEST"), UVM_LOW);
  		`uvm_info(get_type_name(), $sformatf("Done AXI_TEST"), UVM_LOW);	
		phase.drop_objection(this);
	endtask


class axi_write_test extends axi_test;
	`uvm_component_utils(axi_write_test)

	axi_write_seq write_seq;


	extern function new(string name = "axi_write_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration();
	extern task run_phase(uvm_phase phase);
endclass

	function axi_write_test::new(string name = "axi_write_test", uvm_component parent);
		super.new(name, parent);
	endfunction	

	//defining build phase
	function void axi_write_test::build_phase(uvm_phase phase);
		super.build_phase(phase);
		write_seq = axi_write_seq::type_id::create("write_seq", this);
	endfunction

	//defining end of elaboration phase
	function void axi_write_test::end_of_elaboration();
		super.end_of_elaboration();
		`uvm_info(get_type_name(), $sformatf("Inside END of Elaboration phase in write test"), UVM_LOW);
		print();
	endfunction

	//defining run phase
	task axi_write_test::run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		`uvm_info(get_type_name(), $sformatf("Inside AXI_WRITE_TEST"), UVM_LOW);
		write_seq.start(env.active_agent.sequencer);
  		`uvm_info(get_type_name(), $sformatf("Done AXI_WRITE_TEST"), UVM_LOW);	
		phase.drop_objection(this);
	endtask


class axi_write_read_test extends axi_test;
	`uvm_component_utils(axi_write_read_test)

	axi_write_seq write_seq;
	axi_read_seq read_seq;

	extern function new(string name = "axi_write_read_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration();
	extern task run_phase(uvm_phase phase);
endclass

	function axi_write_read_test::new(string name = "axi_write_read_test", uvm_component parent);
		super.new(name, parent);
	endfunction	

	//defining build phase
	function void axi_write_read_test::build_phase(uvm_phase phase);
		super.build_phase(phase);
		write_seq = axi_write_seq::type_id::create("write_seq", this);
		read_seq = axi_read_seq::type_id::create("read_seq", this);
	endfunction

	//defining end of elaboration phase
	function void axi_write_read_test::end_of_elaboration();
		super.end_of_elaboration();
		`uvm_info(get_type_name(), $sformatf("Inside END of Elaboration phase in write read test"), UVM_LOW);
		print();
	endfunction

	//defining run phase
	task axi_write_read_test::run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		`uvm_info(get_type_name(), $sformatf("Inside AXI_WRITE_READ_TEST"), UVM_LOW);
		write_seq.start(env.active_agent.sequencer);
		#100;
		read_seq.start(env.active_agent.sequencer);
  		`uvm_info(get_type_name(), $sformatf("Done AXI_WRITE_READ_TEST"), UVM_LOW);
		#100;	
		phase.drop_objection(this);
	endtask
