class axi_out_mon extends uvm_monitor;
	`uvm_component_utils(axi_out_mon)
	
	virtual axi_interface.out_mon_mod vif;

	axi_transaction packet;
	
	uvm_analysis_port#(axi_transaction) out_mon_port;

	extern function new(string name = "axi_out_mon",uvm_component parent);

	extern function void build_phase(uvm_phase phase);

	extern task run_phase(uvm_phase phase);

endclass

function axi_out_mon :: new(string name = "axi_out_mon",uvm_component parent);
	super.new(name,parent);
endfunction

function void axi_out_mon :: build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(virtual axi_interface.out_mon_mod)::get(this,"","vif",vif))
		`uvm_error("ERROR","CONFIG DB GET NOT HAPPENED IN INPUT MONITOR") 		
	
	out_mon_port = new("out_mon_port",this);
endfunction

task axi_out_mon::run_phase(uvm_phase phase);

  wait (!vif.areset);

  forever begin
    @(vif.cb_out_mon);

    // ---------------- WRITE RESPONSE ----------------
    if (vif.cb_out_mon.bvalid && vif.cb_out_mon.bready) begin
      packet = axi_transaction::type_id::create("packet", this);
      packet.bresp = axi_resp'(vif.cb_out_mon.bresp);
      packet.wr_rd = WRITE;

      out_mon_port.write(packet);

      `uvm_info("OUT_MON", $sformatf("B captured resp=%0h", packet.bresp), UVM_LOW)
    end

    // ---------------- READ DATA ----------------
    if (vif.cb_out_mon.rvalid && vif.cb_out_mon.rready) begin
      packet = axi_transaction::type_id::create("packet", this);
      packet.rdata = vif.cb_out_mon.rdata;
      packet.rresp = axi_resp'(vif.cb_out_mon.rresp);
      packet.wr_rd = READ;

      out_mon_port.write(packet);

      `uvm_info("OUT_MON", $sformatf("R captured data=%0h resp=%0h",
                     packet.rdata, packet.rresp), UVM_LOW)
    end

  end

endtask
