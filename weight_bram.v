`timescale 1ps/1ps

module weight_bram #(
  parameter integer DATA_WIDTH = 384,  // 48 * 8
  parameter integer DEPTH      = 10,
  parameter integer ADDR_WIDTH = 4     // clog2(DEPTH)
)(
  input  wire                     clk,
  input  wire                     rst_n,

  // Write port (A)
  input  wire                     w_en,
  input  wire [ADDR_WIDTH-1:0]    w_addr,
  input  wire [DATA_WIDTH-1:0]    w_data,

  // Read port (B) - sync read, 1clk latency
  input  wire [ADDR_WIDTH-1:0]    r_addr,
  output reg  [DATA_WIDTH-1:0]    r_data
);
  // Xilinx À¯µµ¿ë ÈùÆ®
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // write
  always @(posedge clk) begin
    if (w_en) mem[w_addr] <= w_data;
  end

  // read (sync, 1clk)
  reg [ADDR_WIDTH-1:0] r_addr_q;
  always @(posedge clk) begin
    r_addr_q <= r_addr;
    r_data   <= mem[r_addr_q];
  end
endmodule
