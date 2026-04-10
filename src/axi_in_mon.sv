class axi_in_mon extends uvm_monitor;
	`uvm_component_utils(axi_in_mon)
	
	virtual axi_interface.in_mon_mod vif;

	axi_transaction packet;
	
	uvm_analysis_port#(axi_transaction) in_mon_port;

	extern function new(string name = "axi_in_mon",uvm_component parent);

	extern function void build_phase(uvm_phase phase);

	extern task run_phase(uvm_phase phase);

endclass

function axi_in_mon :: new(string name = "axi_in_mon",uvm_component parent);
	super.new(name,parent);
endfunction

function void axi_in_mon :: build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(virtual axi_interface.in_mon_mod)::get(this,"","vif",vif))
		`uvm_error("ERROR","CONFIG DB GET NOT HAPPENED IN INPUT MONITOR") 		
	
	in_mon_port = new("in_mon_port",this);
endfunction

task axi_in_mon::run_phase(uvm_phase phase);

  axi_transaction aw_pkt;
  
	wait (!vif.areset);

    // ---------------- WRITE ADDRESS CHANNEL ----------------

forever begin
  @(vif.cb_in_mon);

  // Capture AW
  if (vif.cb_in_mon.awvalid && vif.cb_in_mon.awready) begin
    aw_pkt = axi_transaction::type_id::create("aw_pkt", this);
    aw_pkt.awaddr  = vif.cb_in_mon.awaddr;
    aw_pkt.awburst = axi_trans_type'(vif.cb_in_mon.awburst);
    aw_pkt.awsize  = axi_size'(vif.cb_in_mon.awsize);
    aw_pkt.wr_rd   = WRITE;
  end

  // Capture W and COMPLETE transaction
  if (vif.cb_in_mon.wvalid && vif.cb_in_mon.wready) begin
    if (aw_pkt == null) begin
      `uvm_error("IN_MON", "W arrived before AW!")
    end else begin
      aw_pkt.wdata = vif.cb_in_mon.wdata;
      aw_pkt.wstrb = vif.cb_in_mon.wstrb;

      in_mon_port.write(aw_pkt);

      `uvm_info("IN_MON", 
        $sformatf("WRITE txn addr=%0h data=%0h", aw_pkt.awaddr, aw_pkt.wdata),
        UVM_LOW)

      aw_pkt = null; // reset
    end
  end

  // READ ADDRESS (independent)
  if (vif.cb_in_mon.arvalid && vif.cb_in_mon.arready) begin
    packet = axi_transaction::type_id::create("packet", this);
    packet.araddr = vif.cb_in_mon.araddr;
    packet.wr_rd  = READ;

    in_mon_port.write(packet);

    `uvm_info("IN_MON", $sformatf("READ addr=%0h", packet.araddr), UVM_LOW)
  end


  end

endtask
