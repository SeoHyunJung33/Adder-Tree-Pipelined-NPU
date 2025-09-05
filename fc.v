/*------------------------------------------------------------------------
 *
 *  Copyright (c) 2021 by Bo Young Kang, All rights reserved.
 *
 *  File name  : fully_connected.v
 *  Written by : Kang, Bo Young
 *  Written on : Oct 13, 2021
 *  Version    : 21.2
 *  Design     : Fully Connected Layer for CNN
 *
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------
 *  Module: fully_connected
 *------------------------------------------------------------------*/
`timescale 1ps/1ps

 module fully_connected #(parameter INPUT_NUM = 48, OUTPUT_NUM = 10, DATA_BITS = 8) (
   input clk,
   input rst_n,
   input valid_in,
   input signed [11:0] data_in_1, data_in_2, data_in_3,
   output reg [11:0] data_out,
   output reg valid_out_fc,
   input [0:3839] w_fc,
   input [0:79] b_fc
 );

 localparam INPUT_WIDTH = 16;
 localparam INPUT_NUM_DATA_BITS = 5;

 reg state;
 reg [INPUT_WIDTH - 1:0] buf_idx;
 reg [3:0] out_idx;
 reg signed [13:0] buffer [0:INPUT_NUM - 1];
 reg signed [DATA_BITS - 1:0] weight [0:INPUT_NUM * OUTPUT_NUM - 1];
 reg signed [DATA_BITS - 1:0] bias [0:OUTPUT_NUM - 1];
   
 wire signed [19:0] calc_out;

integer i;
 always @(*) begin
    for(i=0;i<INPUT_NUM*OUTPUT_NUM;i=i+1) begin
        weight[i]=w_fc[(8*i)+:8];
    end
    for(i=0;i<OUTPUT_NUM;i=i+1) begin
        bias[i]=b_fc[(8*i)+:8];
    end
end
 
 
 wire signed [13:0] data1 = (data_in_1[11] == 1) ? {2'b11, data_in_1} : {2'b00, data_in_1};
 wire signed [13:0] data2 = (data_in_2[11] == 1) ? {2'b11, data_in_2} : {2'b00, data_in_2};
 wire signed [13:0] data3 = (data_in_3[11] == 1) ? {2'b11, data_in_3} : {2'b00, data_in_3};
 
// ---------- ?  ?  ?  ?  ?  : 48 MAC -> (24+24) adder tree -> bias ----------
  localparam PROD_W = 22;      // 14b * 8b
  localparam SUM_W  = PROD_W + 5;   // 25?   ?  ?   ?  ?   ?  ?  
  localparam AT_LAT = 5;            // adder_tree25_pipe ?   ? ?  
  localparam LAT    = 2 + AT_LAT + 1; //  ? ?   ??  ?   + ?   ? + ìµœì¢…  ??  

  reg [3:0] out_idx_q, out_idx_qA, out_idx_qB;
  reg       fire_calc_q;

  wire fire_calc = valid_in & state;

  always @(posedge clk) begin
    if (!rst_n) begin
      fire_calc_q <= 1'b0;
      out_idx_q   <= 4'd0;
      out_idx_qA  <= 4'd0;
      out_idx_qB  <= 4'd0;
    end else begin
      fire_calc_q <= fire_calc;     // ?•œ ?‚¬?´?´ ì§??—°?œ fire
      if (fire_calc) begin
        out_idx_q  <= out_idx;      // ?„ ?ž˜ì¹?(ë¡œì»¬ ?”Œë¡??œ¼ë¡? ?Šê¸?)
        out_idx_qA <= out_idx;      // ë³µì œ A
        out_idx_qB <= out_idx;      // ë³µì œ B
      end
    end
  end

  // ---------- ê³? ? ˆì§??Š¤?„°(24+24, 25ë²ˆì§¸?Š” 0 ?Œ¨?”©) ----------
  reg signed [PROD_W-1:0] prodA [0:24];
  reg signed [PROD_W-1:0] prodB [0:24];
  integer k;
  always @(posedge clk) begin
    if (!rst_n) begin
      for (k=0;k<25;k=k+1) begin
        prodA[k] <= {PROD_W{1'b0}};
        prodB[k] <= {PROD_W{1'b0}};
      end
    end else if (fire_calc_q) begin
      // out_idx_qA/B ?‚¬?š© ?†’ out_idx?˜ ê±°ë??•œ MUX/?Œ¬?•„?›ƒ?„ ?„ ?ž˜ì¹? ?Š¤?…Œ?´ì§?ë¡? ë¶„ë¦¬
      for (k=0;k<24;k=k+1) begin
        prodA[k] <= $signed(weight[out_idx_qA*INPUT_NUM + k])        * $signed(buffer[k]);
        prodB[k] <= $signed(weight[out_idx_qB*INPUT_NUM + 24 + k])   * $signed(buffer[24+k]);
      end
      prodA[24] <= {PROD_W{1'b0}};
      prodB[24] <= {PROD_W{1'b0}};
    end
  end

  // ---------- 25?ž…? ¥ ?•©?‚° ?Š¸ë¦? x2 ----------
  wire signed [SUM_W-1:0] sumA, sumB;
  adder_tree25_pipe #(.IN_W(PROD_W), .SUM_W(SUM_W)) AT_A (
    .clk(clk), .rst_n(rst_n),
    .in0(prodA[0]),  .in1(prodA[1]),  .in2(prodA[2]),  .in3(prodA[3]),  .in4(prodA[4]),
    .in5(prodA[5]),  .in6(prodA[6]),  .in7(prodA[7]),  .in8(prodA[8]),  .in9(prodA[9]),
    .in10(prodA[10]),.in11(prodA[11]),.in12(prodA[12]),.in13(prodA[13]),.in14(prodA[14]),
    .in15(prodA[15]),.in16(prodA[16]),.in17(prodA[17]),.in18(prodA[18]),.in19(prodA[19]),
    .in20(prodA[20]),.in21(prodA[21]),.in22(prodA[22]),.in23(prodA[23]),.in24(prodA[24]),
    .sum(sumA)
  );
  adder_tree25_pipe #(.IN_W(PROD_W), .SUM_W(SUM_W)) AT_B (
    .clk(clk), .rst_n(rst_n),
    .in0(prodB[0]),  .in1(prodB[1]),  .in2(prodB[2]),  .in3(prodB[3]),  .in4(prodB[4]),
    .in5(prodB[5]),  .in6(prodB[6]),  .in7(prodB[7]),  .in8(prodB[8]),  .in9(prodB[9]),
    .in10(prodB[10]),.in11(prodB[11]),.in12(prodB[12]),.in13(prodB[13]),.in14(prodB[14]),
    .in15(prodB[15]),.in16(prodB[16]),.in17(prodB[17]),.in18(prodB[18]),.in19(prodB[19]),
    .in20(prodB[20]),.in21(prodB[21]),.in22(prodB[22]),.in23(prodB[23]),.in24(prodB[24]),
    .sum(sumB)
  );

  // out_idx ?ŒŒ?´?”„: ?„ ?ž˜ì¹? + ?Š¸ë¦? ì§??—° ë§Œí¼
  reg [3:0] out_idx_pipe [0:AT_LAT+1];
  integer p;
  always @(posedge clk) begin
    if (!rst_n) begin
      for (p=0;p<=AT_LAT+1;p=p+1) out_idx_pipe[p] <= 4'd0;
    end else begin
      out_idx_pipe[0] <= out_idx_q;
      for (p=1;p<=AT_LAT+1;p=p+1) out_idx_pipe[p] <= out_idx_pipe[p-1];
    end
  end

  // bias/ìµœì¢… ê°??‚° (ë¸”ë¡ ë°? ?„ ?–¸ ?†’ Verilog-2001 ?˜¸?™˜)
  reg signed [DATA_BITS-1:0] bias_sel;
  reg signed [SUM_W:0]       bias_ext;
  reg signed [SUM_W:0]       sum_final;

  always @(posedge clk) begin
    if (!rst_n) begin
      bias_sel  <= {DATA_BITS{1'b0}};
      bias_ext  <= {SUM_W+1{1'b0}};
      sum_final <= {SUM_W+1{1'b0}};
    end else begin
      bias_sel  <= bias[out_idx_pipe[AT_LAT+1]];
      bias_ext  <= {{(SUM_W+1-DATA_BITS){bias_sel[DATA_BITS-1]}}, bias_sel};
      sum_final <= $signed(sumA) + $signed(sumB) + bias_ext;
    end
  end

  // valid ?ŒŒ?´?”„ (ì´? LAT)
  reg [LAT-1:0] vpipe;
  always @(posedge clk) begin
    if (!rst_n) begin
      vpipe        <= {LAT{1'b0}};
      data_out     <= 12'd0;
      valid_out_fc <= 1'b0;
    end else begin
      vpipe        <= {vpipe[LAT-2:0], fire_calc_q}; // ?„ ?ž˜ì¹? ë°˜ì˜
      data_out     <= sum_final[18:7];               // ê¸°ì¡´ê³? ?™?¼?•œ ?Š¬?¼?´?Š¤
      valid_out_fc <= vpipe[LAT-1];
    end
  end

  // -------- ?ž…? ¥ ?ˆ˜ì§? FSM (?›?™?ž‘ ?œ ì§?) --------
  always @(posedge clk) begin
    if (!rst_n) begin
      buf_idx <= 0; out_idx <= 0; state <= 1'b0;
    end else if (valid_in) begin
      if (!state) begin
        buffer[buf_idx]                 <= data1;
        buffer[INPUT_WIDTH + buf_idx]   <= data2;
        buffer[INPUT_WIDTH*2 + buf_idx] <= data3;
        buf_idx <= buf_idx + 1'b1;
        if (buf_idx == INPUT_WIDTH-1) begin
          buf_idx <= 0; state <= 1'b1; out_idx <= 4'd0;
        end
      end else begin
        if (out_idx == OUTPUT_NUM-1) begin
          out_idx <= 4'd0; state <= 1'b0;
        end else begin
          out_idx <= out_idx + 1'b1;
        end
      end
    end
  end
endmodule