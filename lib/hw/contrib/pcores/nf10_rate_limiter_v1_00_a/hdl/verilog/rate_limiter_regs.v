module rate_limiter_regs
  #(
    // Master AXI Lite Data Width
    parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=32
    )
   (
    output reg [31:0] throughput_shift,
    output reg rate_limiter_enable,
    output reg host_reset,

    input                        ACLK,
    input                        ARESETN,
    
    input [ADDR_WIDTH-1: 0]      AWADDR,
    input                        AWVALID,
    output reg                   AWREADY,
    
    input [DATA_WIDTH-1: 0]      WDATA,
    input [DATA_WIDTH/8-1: 0]    WSTRB,
    input                        WVALID,
    output reg                   WREADY,
    
    output reg [1:0]             BRESP,
    output reg                   BVALID,
    input                        BREADY,
    
    input [ADDR_WIDTH-1: 0]      ARADDR,
    input                        ARVALID,
    output reg                   ARREADY,
    
    output reg [DATA_WIDTH-1: 0] RDATA, 
    output reg [1:0]             RRESP,
    output reg                   RVALID,
    input                        RREADY
    );

   localparam AXI_RESP_OK = 2'b00;
   localparam AXI_RESP_SLVERR = 2'b10;
   
   localparam WRITE_IDLE = 0;
   localparam WRITE_RESPONSE = 1;
   localparam WRITE_DATA = 2;

   localparam READ_IDLE = 0;
   localparam READ_RESPONSE = 1;

   localparam THROUGHPUT_SHIFT = 8'h00;
   localparam RATE_LIMITER_ENABLE = 8'h01;
   localparam HOST_RESET = 8'h02;

   reg [1:0]                     write_state, write_state_next;
   reg [1:0]                     read_state, read_state_next;
   reg [ADDR_WIDTH-1:0]          read_addr, read_addr_next;
   reg [ADDR_WIDTH-1:0]          write_addr, write_addr_next;
   reg [1:0]                     BRESP_next;

   reg [31:0]                    throughput_shift_next;
   reg                           rate_limiter_enable_next;
   reg                           host_reset_next;
   
   always @(*) begin
      read_state_next = read_state;   
      ARREADY = 1'b1;
      read_addr_next = read_addr;
      RDATA = 0; 
      RRESP = AXI_RESP_OK;
      RVALID = 1'b0;
      
      case(read_state)
        READ_IDLE: begin
           if(ARVALID) begin
              read_addr_next = ARADDR;
              read_state_next = READ_RESPONSE;
           end
        end        
        
        READ_RESPONSE: begin
           RVALID = 1'b1;
           ARREADY = 1'b0;

           if(read_addr[7:0] == THROUGHPUT_SHIFT) begin
              RDATA = throughput_shift;
           end
           else if(read_addr[7:0] == RATE_LIMITER_ENABLE) begin
              RDATA[0] = rate_limiter_enable;
              RDATA[31:1] = 0;
           end
           else if(read_addr[7:0] == HOST_RESET) begin
              RDATA[0] = host_reset;
              RDATA[31:1] = 0;
           end
           else begin
              RRESP = AXI_RESP_SLVERR;
           end

           if(RREADY) begin
              read_state_next = READ_IDLE;
           end
        end
      endcase
   end
   
   always @(*) begin
      write_state_next = write_state;
      write_addr_next = write_addr;

      AWREADY = 1'b1;
      WREADY = 1'b0;
      BVALID = 1'b0;  
      BRESP_next = BRESP;

      throughput_shift_next = throughput_shift;
      rate_limiter_enable_next = rate_limiter_enable;
      host_reset_next = host_reset;

      case(write_state)
        WRITE_IDLE: begin
           write_addr_next = AWADDR;
           if(AWVALID) begin
              write_state_next = WRITE_DATA;
           end
        end
        WRITE_DATA: begin
           AWREADY = 1'b0;
           WREADY = 1'b1;
           if(WVALID) begin
              if(write_addr[7:0] == THROUGHPUT_SHIFT) begin
                 throughput_shift_next = WDATA;
                 BRESP_next = AXI_RESP_OK;
              end
              else if(write_addr[7:0] == RATE_LIMITER_ENABLE) begin
                 rate_limiter_enable_next = WDATA[0];
                 BRESP_next = AXI_RESP_OK;
              end
              else if(write_addr[7:0] == HOST_RESET) begin
                 host_reset_next = WDATA[0];
                 BRESP_next = AXI_RESP_OK;
              end
              else begin
                 BRESP_next = AXI_RESP_SLVERR;
              end
              write_state_next = WRITE_RESPONSE;
           end
        end
        WRITE_RESPONSE: begin
           AWREADY = 1'b0;
           BVALID = 1'b1;
           if(BREADY) begin                    
              write_state_next = WRITE_IDLE;
           end
        end
      endcase
   end

   always @(posedge ACLK) begin
      if(~ARESETN) begin
         write_state <= WRITE_IDLE;
         read_state <= READ_IDLE;
         read_addr <= 0;
         write_addr <= 0;
         BRESP <= AXI_RESP_OK;

         throughput_shift <= 0;
         rate_limiter_enable <= 0;
         host_reset <= 0;

      end
      else begin
         write_state <= write_state_next;
         read_state <= read_state_next;
         read_addr <= read_addr_next;
         write_addr <= write_addr_next;
         BRESP <= BRESP_next;

         throughput_shift <= throughput_shift_next;
         rate_limiter_enable <= rate_limiter_enable_next;
         host_reset <= host_reset_next;

      end
   end

endmodule
