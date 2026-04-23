module axi_lite_slave #( parameter DATA_WIDTH = 32,
                 parameter ADDRESS_WIDTH = 32 )(
             
        input clk,    // Clock
        input rst_n,  // Asynchronous reset active low
    
        // Address write channel
           output reg awready,
           input  awvalid,
           input  [ADDRESS_WIDTH-1:0]awaddr,

        // Data write channel
           output reg wready,
           input  wvalid,
           input  [(DATA_WIDTH/8)-1:0]wstrb,
           input  [DATA_WIDTH-1:0]wdata,

        // Write response channel
           output reg [1:0] bresp,
           output reg bvalid,
           input  bready,

        // Read address channel
           output reg arready,
           input  [ADDRESS_WIDTH-1:0]araddr,
           input  arvalid,

        // read data channel
           output reg [DATA_WIDTH-1:0]rdata,
           output reg [1:0]rresp,
           output reg rvalid,
           input  rready
    );
        
//***********************memory***********************
    (*ram_style="block"*) reg [31:0] slave_mem[7:0];
    reg [ADDRESS_WIDTH-1:0] awaddr_reg;
    reg [ADDRESS_WIDTH-1:0] araddr_reg;
    reg wr_success;
    reg rd_success;

//**************write address channel*****************
    localparam WA_IDLE_S = 2'b00, WA_START_S = 2'b01, WA_READY_S = 2'b10;
    reg [1:0] WA_PRESENT_STATE_S;
    reg [1:0] WA_NEXT_STATE_S;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) WA_PRESENT_STATE_S <= WA_IDLE_S;
        else WA_PRESENT_STATE_S <= WA_NEXT_STATE_S;
    end

    always@* begin
        case (WA_PRESENT_STATE_S)
            WA_IDLE_S : if (awvalid) WA_NEXT_STATE_S = WA_START_S;
                        else WA_NEXT_STATE_S = WA_IDLE_S;
            WA_START_S: WA_NEXT_STATE_S = WA_READY_S;
            WA_READY_S: WA_NEXT_STATE_S = WA_IDLE_S;
            default   : WA_NEXT_STATE_S = WA_IDLE_S;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            awready <= 1'b0;
            awaddr_reg <= 'b0; 
        end else begin
            case (WA_PRESENT_STATE_S)
                WA_IDLE_S : awready <= 1'b0;
                WA_START_S: begin 
                             awready <= 1'b1;
                             awaddr_reg <= awaddr; 
                            end
                WA_READY_S: awready <= 1'b0;
                default   : awready <= 1'b0;
            endcase
        end
    end

//**************************Write data channel*******************************
    localparam W_IDLE_S = 2'b00, W_READY_S = 2'b01, W_TRAN_S = 2'b10;
    reg [1:0] W_PRESENT_STATE_S;
    reg [1:0] W_NEXT_STATE_S;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) W_PRESENT_STATE_S <= W_IDLE_S;
        else W_PRESENT_STATE_S <= W_NEXT_STATE_S;
    end

    always @* begin
        case(W_PRESENT_STATE_S)
            W_IDLE_S : if(awready && awvalid) W_NEXT_STATE_S = W_READY_S;
                       else W_NEXT_STATE_S = W_IDLE_S;
            W_READY_S: if(wvalid) W_NEXT_STATE_S = W_TRAN_S;
                       else W_NEXT_STATE_S = W_READY_S;
            W_TRAN_S : W_NEXT_STATE_S = W_IDLE_S;
            default  : W_NEXT_STATE_S = W_IDLE_S;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            wready <= 1'b0;
            // FIXED: loop only 8 times (size of slave_mem)
            for (int i = 0; i < 8 ; i++) begin
                slave_mem[i] <= 32'h0;
            end
        end else begin
            case (W_PRESENT_STATE_S)
                W_IDLE_S : wready <= 1'b0;
                W_READY_S: wready <= 1'b1;
                W_TRAN_S : begin 
                                wready <= 1'b0;
                                for (int i = 0; i < 4 ; i++) begin
                                    if(wstrb[i])
                                        // FIXED: Mask address bits [4:2] to index 0-7
                                        slave_mem[awaddr_reg[4:2]][(i*8)+:8] <= wdata[i*8+:8];  
                                end
                           end
                default : wready <= 1'b0;
            endcase 
        end
    end

//*********************Write response channel***********************
    localparam B_IDLE_S = 2'b00, B_START_S = 2'b01, B_READY_S = 2'b10;
    reg [1:0] B_PRESENT_STATE_S;
    reg [1:0] B_NEXT_STATE_S;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) B_PRESENT_STATE_S <= B_IDLE_S;
        else B_PRESENT_STATE_S <= B_NEXT_STATE_S;
    end

    always @* begin
        case (B_PRESENT_STATE_S)
            B_IDLE_S : if(wready) B_NEXT_STATE_S = B_START_S;
                       else B_NEXT_STATE_S = B_IDLE_S;
            B_START_S: B_NEXT_STATE_S = B_READY_S;
            B_READY_S: B_NEXT_STATE_S = B_IDLE_S;
            default  : B_NEXT_STATE_S = B_IDLE_S;
        endcase
    end

    always@(posedge clk or negedge rst_n) begin
       if (~rst_n) begin
            bvalid <= 1'b0;
            bresp  <= 2'b00;
            wr_success <= 'b0;
       end else
        case (B_PRESENT_STATE_S)
            B_IDLE_S : bvalid <= 1'b0;
            B_START_S: bvalid <= 1'b1;
            B_READY_S: begin
                         bvalid <= 1'b0;
                         if(bready) wr_success <= 1'b1;
                         bresp <= 2'b00; // Simplified for memory
                       end 
            default  : bvalid <= 1'b0;
        endcase
    end

//***************************Read address channel*******************************
    localparam AR_IDLE_S = 1'b0, AR_READY_S = 1'b1;
    reg AR_PRESENT_STATE_S, AR_NEXT_STATE_S;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) AR_PRESENT_STATE_S <= AR_IDLE_S;
        else AR_PRESENT_STATE_S <= AR_NEXT_STATE_S;
    end

    always@* begin
        case (AR_PRESENT_STATE_S)
            AR_IDLE_S : if(arvalid) AR_NEXT_STATE_S = AR_READY_S;
                        else AR_NEXT_STATE_S = AR_IDLE_S;
            AR_READY_S: AR_NEXT_STATE_S = AR_IDLE_S;
            default   : AR_NEXT_STATE_S = AR_IDLE_S;
        endcase
    end

    always@(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            arready <= 1'b0;
            araddr_reg <= 0;
        end else begin
            case (AR_PRESENT_STATE_S)
                AR_IDLE_S : arready <= 1'b0;
                AR_READY_S: begin
                                arready <= 1'b1;
                                araddr_reg <= araddr;
                            end
            endcase
        end
    end

//**************************Read data channel******************************
    localparam R_IDLE_S = 2'b00, R_READY_S = 2'b01, R_TRAN_S = 2'b10;
    reg [1:0] R_PRESENT_STATE_S, R_NEXT_STATE_S;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) R_PRESENT_STATE_S <= R_IDLE_S;
        else R_PRESENT_STATE_S <= R_NEXT_STATE_S;
    end

    always@* begin
        case(R_PRESENT_STATE_S)
            R_IDLE_S : if(arready) R_NEXT_STATE_S = R_READY_S;
                       else R_NEXT_STATE_S = R_IDLE_S;
            R_READY_S: if(rready) R_NEXT_STATE_S = R_TRAN_S;
                       else R_NEXT_STATE_S = R_READY_S;
            R_TRAN_S : R_NEXT_STATE_S = R_IDLE_S;
            default  : R_NEXT_STATE_S = R_IDLE_S;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
       if (~rst_n) begin
            rvalid <= 1'b0;
            rdata <= 'b0;
            rd_success <= 1'b0;
            rresp <= 2'b00;
       end else begin
        case (R_PRESENT_STATE_S)
            R_IDLE_S : rvalid <= 1'b0;
            R_READY_S: begin 
                         rvalid <= 1'b1;
                         rd_success <= 1'b1;
                         rresp <= 2'b00;
                         // FIXED: Indexing with bits [4:2] to fetch word 0-7
                         rdata <= slave_mem[araddr_reg[4:2]]; 
                       end
            R_TRAN_S : rvalid <= 1'b0;
            default  : rvalid <= 1'b0;
        endcase
       end
    end

endmodule
