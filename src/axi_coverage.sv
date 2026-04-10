`uvm_analysis_imp_decl(_input_mon)
`uvm_analysis_imp_decl(_output_mon)

class axi_coverage extends uvm_subscriber;
	`uvm_component_utils(axi_coverage)
	
	uvm_analysis_imp_input_mon #(axi_transaction,axi_coverage) in_mon;
    uvm_analysis_imp_output_mon #(axi_transaction,axi_coverage) out_mon;

function new(string name, uvm_component parent);
    super.new(name, parent);
    in_mon  = new("in_mon", this);
    out_mon = new("out_mon", this);
  endfunction

function void write(T t);
endfunction

  // Input monitor callback
  function void write_input_mon(axi_transaction t);
    // coverage logic
  endfunction

  // Output monitor callback
  function void write_output_mon(axi_transaction t);
    // coverage logic
  endfunction

	
endclass
	
	
