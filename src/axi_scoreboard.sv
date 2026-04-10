class axi_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(axi_scoreboard)

	uvm_analysis_imp_input_mon #(axi_transaction,axi_scoreboard) in_mon;
	uvm_analysis_imp_output_mon #(axi_transaction,axi_scoreboard) out_mon;
	
	axi_transaction aw_q[$];
	axi_transaction w_q[$];

	axi_transaction exp_q[$];
	axi_transaction act_q[$];

	bit [31:0] mem [bit[31:0]];

  extern function new(string name = "axi_scoreboard", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void write(axi_transaction t);
  extern function void write_input_mon(axi_transaction t);
  extern function void write_output_mon(axi_transaction t);
  extern task run_phase(uvm_phase phase);

endclass

function axi_scoreboard::new(string name = "axi_scoreboard",uvm_component parent);
	super.new(name,parent);
endfunction

function void axi_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	in_mon = new("in_mon",this);
	out_mon = new("out_mon",this);
endfunction

function void axi_scoreboard::write(axi_transaction t);
endfunction

function void axi_scoreboard::write_input_mon(axi_transaction t);
// ---------------- WRITE PATH ----------------
  if (t.wr_rd == WRITE) begin

    // AW captured
    if (t.awaddr !== 'x) begin
      aw_q.push_back(t);
    end

    // W captured
    if (t.wdata !== 'x) begin
      w_q.push_back(t);
    end

    // Combine AW + W
    if (aw_q.size() && w_q.size()) begin
      axi_transaction tx;
      tx = axi_transaction::type_id::create("tx");

      tx.wr_rd = WRITE;
      tx.awaddr = aw_q.pop_front().awaddr;
      tx.wdata  = w_q.pop_front().wdata;

      // Update memory model
      mem[tx.awaddr] = tx.wdata;

      exp_q.push_back(tx);

      `uvm_info("SCB", $sformatf("EXP WRITE addr=%0h data=%0h",
                   tx.awaddr, tx.wdata), UVM_LOW)
    end
  end

  // ---------------- READ PATH ----------------
  if (t.wr_rd == READ) begin
    if (t.araddr !== 'x) begin
      axi_transaction tx;
      tx = axi_transaction::type_id::create("tx");

      tx.wr_rd = READ;
      tx.araddr = t.araddr;

      // Expected data from memory
      if (mem.exists(t.araddr))
        tx.rdata = mem[t.araddr];
      else
        tx.rdata = '0;

      exp_q.push_back(tx);

      `uvm_info("SCB", $sformatf("EXP READ addr=%0h data=%0h",
                   tx.araddr, tx.rdata), UVM_LOW)
    end
  end

endfunction

function void axi_scoreboard::write_output_mon(axi_transaction t);

  // WRITE RESPONSE
  if (t.wr_rd == WRITE && t.bresp !== 'x) begin
    act_q.push_back(t);

    `uvm_info("SCB", $sformatf("ACT WRITE RESP=%0h", t.bresp), UVM_LOW)
  end

  // READ DATA
  if (t.wr_rd == READ && t.rdata !== 'x) begin
    act_q.push_back(t);

    `uvm_info("SCB", $sformatf("ACT READ data=%0h", t.rdata), UVM_LOW)
  end

endfunction

task axi_scoreboard::run_phase(uvm_phase phase);

  forever begin
    axi_transaction exp, act;
    wait(exp_q.size() && act_q.size());

    exp = exp_q.pop_front();
    act = act_q.pop_front();

    // ---------------- WRITE CHECK ----------------
    if (exp.wr_rd == WRITE) begin
      if (act.bresp != 0) begin
        `uvm_error("SCB", "WRITE FAILED: BRESP != OKAY")
      end
      else begin
        `uvm_info("SCB", "WRITE PASSED", UVM_LOW)
      end
    end

    // ---------------- READ CHECK ----------------
    if (exp.wr_rd == READ) begin
      if (exp.rdata !== act.rdata) begin
        `uvm_error("SCB",$sformatf("READ MISMATCH exp=%0h act=%0h",exp.rdata, act.rdata))
      end
      else begin
        `uvm_info("SCB", "READ PASSED", UVM_LOW)
      end
    end

  end

endtask
