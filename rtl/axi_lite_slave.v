module axi_lite_slave #(
  parameter ADDR_WIDTH = 8,
  parameter DATA_WIDTH = 32,
  parameter DEPTH = 256
)(
  input  logic                  aclk,
  input  logic                  areset,

  // WRITE ADDRESS CHANNEL
  input  logic [ADDR_WIDTH-1:0] awaddr,
  input  logic                  awvalid,
  output logic                  awready,

  // WRITE DATA CHANNEL
  input  logic [DATA_WIDTH-1:0] wdata,
  input  logic [(DATA_WIDTH/8)-1:0] wstrb,
  input  logic                  wvalid,
  output logic                  wready,

  // WRITE RESPONSE CHANNEL
  output logic [1:0]            bresp,
  output logic                  bvalid,
  input  logic                  bready,

  // READ ADDRESS CHANNEL
  input  logic [ADDR_WIDTH-1:0] araddr,
  input  logic                  arvalid,
  output logic                  arready,

  // READ DATA CHANNEL
  output logic [DATA_WIDTH-1:0] rdata,
  output logic [1:0]            rresp,
  output logic                  rvalid,
  input  logic                  rready
);

  // ---------------- MEMORY ----------------
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // ---------------- INTERNAL REGS ----------------
  logic [ADDR_WIDTH-1:0] awaddr_reg;
  logic [ADDR_WIDTH-1:0] araddr_reg;

  logic aw_hs, w_hs, ar_hs;

  assign aw_hs = awvalid && awready;
  assign w_hs  = wvalid  && wready;
  assign ar_hs = arvalid && arready;

  // ---------------- WRITE ADDRESS ----------------
  always_ff @(posedge aclk) begin
    if (areset) begin
      awready <= 0;
    end else begin
      awready <= !awready && awvalid; // accept when valid
      if (aw_hs)
        awaddr_reg <= awaddr;
    end
  end

  // ---------------- WRITE DATA ----------------
  always_ff @(posedge aclk) begin
    if (areset) begin
      wready <= 0;
    end else begin
      wready <= !wready && wvalid;
    end
  end

  // ---------------- WRITE LOGIC ----------------
  always_ff @(posedge aclk) begin
    if (!areset) begin
      if (aw_hs && w_hs) begin
        mem[awaddr_reg] <= wdata;
      end
    end
  end

  // ---------------- WRITE RESPONSE ----------------
  always_ff @(posedge aclk) begin
    if (areset) begin
      bvalid <= 0;
      bresp  <= 0;
    end else begin
      if (aw_hs && w_hs) begin
        bvalid <= 1;
        bresp  <= 2'b00; // OKAY
      end else if (bvalid && bready) begin
        bvalid <= 0;
      end
    end
  end

  // ---------------- READ ADDRESS ----------------
  always_ff @(posedge aclk) begin
    if (areset) begin
      arready <= 0;
    end else begin
      arready <= !arready && arvalid;
      if (ar_hs)
        araddr_reg <= araddr;
    end
  end

  // ---------------- READ DATA ----------------
  always_ff @(posedge aclk) begin
    if (areset) begin
      rvalid <= 0;
      rresp  <= 0;
    end else begin
      if (ar_hs) begin
        rvalid <= 1;
        rdata  <= mem[araddr_reg];
        rresp  <= 2'b00; // OKAY
      end else if (rvalid && rready) begin
        rvalid <= 0;
      end
    end
  end

endmodule
