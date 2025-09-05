/*------------------------------------------------------------------------
 *
 *  Copyright (c) 2021 by Bo Young Kang, All rights reserved.
 *
 *  File name  : conv1_layer.v
 *  Written by : Kang, Bo Young
 *  Written on : Sep 30, 2021
 *  Version    : 21.2
 *  Design     : 1st Convolution Layer for CNN MNIST dataset
 *
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------
 *  Module: conv1_layer
 *------------------------------------------------------------------*/
 `timescale 1ps/1ps
 
 module conv1_layer (
   input clk,
   input rst_n,
   input [7:0] data_in,
   output [11:0] conv_out_1, conv_out_2, conv_out_3,
   output valid_out_conv,
   input [0:199] w_11,
   input [0:199] w_12,
   input [0:199] w_13,
   input [0:23] b_1
 );

 wire [7:0] data_out_0, data_out_1, data_out_2, data_out_3, data_out_4,
  data_out_5, data_out_6, data_out_7, data_out_8, data_out_9,
  data_out_10, data_out_11, data_out_12, data_out_13, data_out_14,
  data_out_15, data_out_16, data_out_17, data_out_18, data_out_19,
  data_out_20, data_out_21, data_out_22, data_out_23, data_out_24;
 wire valid_out_buf;

 conv1_buf #(.WIDTH(28), .HEIGHT(28), .DATA_BITS(8)) conv1_buf(
   .clk(clk),
   .rst_n(rst_n),
   .data_in(data_in),
   .data_out_0(data_out_0),
   .data_out_1(data_out_1),
   .data_out_2(data_out_2),
   .data_out_3(data_out_3),
   .data_out_4(data_out_4),
   .data_out_5(data_out_5),
   .data_out_6(data_out_6),
   .data_out_7(data_out_7),
   .data_out_8(data_out_8),
   .data_out_9(data_out_9),
   .data_out_10(data_out_10),
   .data_out_11(data_out_11),
   .data_out_12(data_out_12),
   .data_out_13(data_out_13),
   .data_out_14(data_out_14),
   .data_out_15(data_out_15),
   .data_out_16(data_out_16),
   .data_out_17(data_out_17),
   .data_out_18(data_out_18),
   .data_out_19(data_out_19),
   .data_out_20(data_out_20),
   .data_out_21(data_out_21),
   .data_out_22(data_out_22),
   .data_out_23(data_out_23),
   .data_out_24(data_out_24),
   .valid_out_buf(valid_out_buf)
 );

 conv1_calc #(.DATA_BITS(8), .MUL_LAT(1)) conv1_calc (
  .clk(clk),
  .rst_n(rst_n),

  .valid_out_buf(valid_out_buf),
  .data_out_0(data_out_0),  .data_out_1(data_out_1),
  .data_out_2(data_out_2),  .data_out_3(data_out_3),
  .data_out_4(data_out_4),  .data_out_5(data_out_5),
  .data_out_6(data_out_6),  .data_out_7(data_out_7),
  .data_out_8(data_out_8),  .data_out_9(data_out_9),
  .data_out_10(data_out_10),.data_out_11(data_out_11),
  .data_out_12(data_out_12),.data_out_13(data_out_13),
  .data_out_14(data_out_14),.data_out_15(data_out_15),
  .data_out_16(data_out_16),.data_out_17(data_out_17),
  .data_out_18(data_out_18),.data_out_19(data_out_19),
  .data_out_20(data_out_20),.data_out_21(data_out_21),
  .data_out_22(data_out_22),.data_out_23(data_out_23),
  .data_out_24(data_out_24),

  .w_11(w_11), .w_12(w_12), .w_13(w_13), .b_1(b_1),

  .conv_out_1(conv_out_1),
  .conv_out_2(conv_out_2),
  .conv_out_3(conv_out_3),
  .valid_out_calc(valid_out_conv)
 );
 endmodule

/*------------------------------------------------------------------------
 *
 *  Copyright (c) 2021 by Bo Young Kang, All rights reserved.
 *
 *  File name  : conv1_buf.v
 *  Written by : Kang, Bo Young
 *  Written on : Sep 30, 2021
 *  Version    : 21.2
 *  Design     : 1st Convolution Layer for CNN MNIST dataset
 *               Input Buffer
 *
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------
 *  Module: conv1_buf
 *------------------------------------------------------------------*/
 
 module conv1_buf #(parameter WIDTH = 28, HEIGHT = 28, DATA_BITS = 8)(
   input clk,
   input rst_n,
   input [DATA_BITS - 1:0] data_in,
   output reg [DATA_BITS - 1:0] data_out_0, data_out_1, data_out_2, data_out_3, data_out_4,
   data_out_5, data_out_6, data_out_7, data_out_8, data_out_9,
   data_out_10, data_out_11, data_out_12, data_out_13, data_out_14,
   data_out_15, data_out_16, data_out_17, data_out_18, data_out_19,
   data_out_20, data_out_21, data_out_22, data_out_23, data_out_24,
   output reg valid_out_buf
 );

 localparam FILTER_SIZE = 5;

 reg [DATA_BITS - 1:0] buffer [0:WIDTH * FILTER_SIZE - 1];
 reg [DATA_BITS - 1:0] buf_idx;
 reg [4:0] w_idx, h_idx;
 reg [2:0] buf_flag;  // 0 ~ 4
 reg state;

 always @(posedge clk) begin
   if(~rst_n) begin
     buf_idx <= -1;
     w_idx <= 0;
     h_idx <= 0;
     buf_flag <= 0;
     state <= 0;
     valid_out_buf <= 0;
     data_out_0 <= 12'bx;
     data_out_1 <= 12'bx;
     data_out_2 <= 12'bx;
     data_out_3 <= 12'bx;
     data_out_4 <= 12'bx;
     data_out_5 <= 12'bx;
     data_out_6 <= 12'bx;
     data_out_7 <= 12'bx;
     data_out_8 <= 12'bx;
     data_out_9 <= 12'bx;
     data_out_10 <= 12'bx;
     data_out_11 <= 12'bx;
     data_out_12 <= 12'bx;
     data_out_13 <= 12'bx;
     data_out_14 <= 12'bx;
     data_out_15 <= 12'bx;
     data_out_16 <= 12'bx;
     data_out_17 <= 12'bx;
     data_out_18 <= 12'bx;
     data_out_19 <= 12'bx;
     data_out_20 <= 12'bx;
     data_out_21 <= 12'bx;
     data_out_22 <= 12'bx;
     data_out_23 <= 12'bx;
     data_out_24 <= 12'bx;
   end else begin
   buf_idx <= buf_idx + 1;
   if(buf_idx == WIDTH * FILTER_SIZE - 1) begin // buffer size = 140 = 28(w) * 5(h)
     buf_idx <= 0;
   end
   
   buffer[buf_idx] <= data_in;  // data input
   
   // Wait until first 140 input data filled in buffer
   if(!state) begin
     if(buf_idx == WIDTH * FILTER_SIZE - 1) begin
       state <= 1'b1;
     end
   end else begin // valid state
     w_idx <= w_idx + 1'b1; // move right

     if(w_idx == WIDTH - FILTER_SIZE + 1) begin
       valid_out_buf <= 1'b0; // unvalid area
     end else if(w_idx == WIDTH - 1) begin
       buf_flag <= buf_flag + 1'b1;
       if(buf_flag == FILTER_SIZE - 1) begin
         buf_flag <= 0;
       end
       w_idx <= 0;

       if(h_idx == HEIGHT - FILTER_SIZE) begin  // done 1 input read -> 28 * 28
         h_idx <= 0;
         state <= 1'b0;
       end 
       
       h_idx <= h_idx + 1'b1;

     end else if(w_idx == 0) begin
       valid_out_buf <= 1'b1; // start valid area
     end

     // Buffer Selection -> 5 * 5
     if(buf_flag == 3'd0) begin
       data_out_0 <= buffer[w_idx];
       data_out_1 <= buffer[w_idx + 1];
       data_out_2 <= buffer[w_idx + 2];
       data_out_3 <= buffer[w_idx + 3];
       data_out_4 <= buffer[w_idx + 4];

       data_out_5 <= buffer[w_idx + WIDTH];
       data_out_6 <= buffer[w_idx + 1 + WIDTH];
       data_out_7 <= buffer[w_idx + 2 + WIDTH];
       data_out_8 <= buffer[w_idx + 3 + WIDTH];
       data_out_9 <= buffer[w_idx + 4 + WIDTH];

       data_out_10 <= buffer[w_idx + WIDTH * 2];
       data_out_11 <= buffer[w_idx + 1 + WIDTH * 2];
       data_out_12 <= buffer[w_idx + 2 + WIDTH * 2];
       data_out_13 <= buffer[w_idx + 3 + WIDTH * 2];
       data_out_14 <= buffer[w_idx + 4 + WIDTH * 2];

       data_out_15 <= buffer[w_idx + WIDTH * 3];
       data_out_16 <= buffer[w_idx + 1 + WIDTH * 3];
       data_out_17 <= buffer[w_idx + 2 + WIDTH * 3];
       data_out_18 <= buffer[w_idx + 3 + WIDTH * 3];
       data_out_19 <= buffer[w_idx + 4 + WIDTH * 3];

       data_out_20 <= buffer[w_idx + WIDTH * 4];
       data_out_21 <= buffer[w_idx + 1 + WIDTH * 4];
       data_out_22 <= buffer[w_idx + 2 + WIDTH * 4];
       data_out_23 <= buffer[w_idx + 3 + WIDTH * 4];
       data_out_24 <= buffer[w_idx + 4 + WIDTH * 4];
     end else if(buf_flag == 3'd1) begin
       data_out_0 <= buffer[w_idx + WIDTH];
       data_out_1 <= buffer[w_idx + 1 + WIDTH];
       data_out_2 <= buffer[w_idx + 2 + WIDTH];
       data_out_3 <= buffer[w_idx + 3 + WIDTH];
       data_out_4 <= buffer[w_idx + 4 + WIDTH];

       data_out_5 <= buffer[w_idx + WIDTH * 2];
       data_out_6 <= buffer[w_idx + 1 + WIDTH * 2];
       data_out_7 <= buffer[w_idx + 2 + WIDTH * 2];
       data_out_8 <= buffer[w_idx + 3 + WIDTH * 2];
       data_out_9 <= buffer[w_idx + 4 + WIDTH * 2];

       data_out_10 <= buffer[w_idx + WIDTH * 3];
       data_out_11 <= buffer[w_idx + 1 + WIDTH * 3];
       data_out_12 <= buffer[w_idx + 2 + WIDTH * 3];
       data_out_13 <= buffer[w_idx + 3 + WIDTH * 3];
       data_out_14 <= buffer[w_idx + 4 + WIDTH * 3];

       data_out_15 <= buffer[w_idx + WIDTH * 4];
       data_out_16 <= buffer[w_idx + 1 + WIDTH * 4];
       data_out_17 <= buffer[w_idx + 2 + WIDTH * 4];
       data_out_18 <= buffer[w_idx + 3 + WIDTH * 4];
       data_out_19 <= buffer[w_idx + 4 + WIDTH * 4];

       data_out_20 <= buffer[w_idx];
       data_out_21 <= buffer[w_idx + 1];
       data_out_22 <= buffer[w_idx + 2];
       data_out_23 <= buffer[w_idx + 3];
       data_out_24 <= buffer[w_idx + 4];
     end else if(buf_flag == 3'd2) begin
       data_out_0 <= buffer[w_idx + WIDTH * 2];
       data_out_1 <= buffer[w_idx + 1 + WIDTH * 2];
       data_out_2 <= buffer[w_idx + 2 + WIDTH * 2];
       data_out_3 <= buffer[w_idx + 3 + WIDTH * 2];
       data_out_4 <= buffer[w_idx + 4 + WIDTH * 2];

       data_out_5 <= buffer[w_idx + WIDTH * 3];
       data_out_6 <= buffer[w_idx + 1 + WIDTH * 3];
       data_out_7 <= buffer[w_idx + 2 + WIDTH * 3];
       data_out_8 <= buffer[w_idx + 3 + WIDTH * 3];
       data_out_9 <= buffer[w_idx + 4 + WIDTH * 3];

       data_out_10 <= buffer[w_idx + WIDTH * 4];
       data_out_11 <= buffer[w_idx + 1 + WIDTH * 4];
       data_out_12 <= buffer[w_idx + 2 + WIDTH * 4];
       data_out_13 <= buffer[w_idx + 3 + WIDTH * 4];
       data_out_14 <= buffer[w_idx + 4 + WIDTH * 4];

       data_out_15 <= buffer[w_idx];
       data_out_16 <= buffer[w_idx + 1];
       data_out_17 <= buffer[w_idx + 2];
       data_out_18 <= buffer[w_idx + 3];
       data_out_19 <= buffer[w_idx + 4];

       data_out_20 <= buffer[w_idx + WIDTH];
       data_out_21 <= buffer[w_idx + 1 + WIDTH];
       data_out_22 <= buffer[w_idx + 2 + WIDTH];
       data_out_23 <= buffer[w_idx + 3 + WIDTH];
       data_out_24 <= buffer[w_idx + 4 + WIDTH];
     end else if(buf_flag == 3'd3) begin
       data_out_0 <= buffer[w_idx + WIDTH * 3];
       data_out_1 <= buffer[w_idx + 1 + WIDTH * 3];
       data_out_2 <= buffer[w_idx + 2 + WIDTH * 3];
       data_out_3 <= buffer[w_idx + 3 + WIDTH * 3];
       data_out_4 <= buffer[w_idx + 4 + WIDTH * 3];

       data_out_5 <= buffer[w_idx + WIDTH * 4];
       data_out_6 <= buffer[w_idx + 1 + WIDTH * 4];
       data_out_7 <= buffer[w_idx + 2 + WIDTH * 4];
       data_out_8 <= buffer[w_idx + 3 + WIDTH * 4];
       data_out_9 <= buffer[w_idx + 4 + WIDTH * 4];

       data_out_10 <= buffer[w_idx];
       data_out_11 <= buffer[w_idx + 1];
       data_out_12 <= buffer[w_idx + 2];
       data_out_13 <= buffer[w_idx + 3];
       data_out_14 <= buffer[w_idx + 4];

       data_out_15 <= buffer[w_idx + WIDTH];
       data_out_16 <= buffer[w_idx + 1 + WIDTH];
       data_out_17 <= buffer[w_idx + 2 + WIDTH];
       data_out_18 <= buffer[w_idx + 3 + WIDTH];
       data_out_19 <= buffer[w_idx + 4 + WIDTH];

       data_out_20 <= buffer[w_idx + WIDTH * 2];
       data_out_21 <= buffer[w_idx + 1 + WIDTH * 2];
       data_out_22 <= buffer[w_idx + 2 + WIDTH * 2];
       data_out_23 <= buffer[w_idx + 3 + WIDTH * 2];
       data_out_24 <= buffer[w_idx + 4 + WIDTH * 2];      
     end else if(buf_flag == 3'd4) begin
       data_out_0 <= buffer[w_idx + WIDTH * 4];
       data_out_1 <= buffer[w_idx + 1 + WIDTH * 4];
       data_out_2 <= buffer[w_idx + 2 + WIDTH * 4];
       data_out_3 <= buffer[w_idx + 3 + WIDTH * 4];
       data_out_4 <= buffer[w_idx + 4 + WIDTH * 4];

       data_out_5 <= buffer[w_idx];
       data_out_6 <= buffer[w_idx + 1];
       data_out_7 <= buffer[w_idx + 2];
       data_out_8 <= buffer[w_idx + 3];
       data_out_9 <= buffer[w_idx + 4];

       data_out_10 <= buffer[w_idx + WIDTH];
       data_out_11 <= buffer[w_idx + 1 + WIDTH];
       data_out_12 <= buffer[w_idx + 2 + WIDTH];
       data_out_13 <= buffer[w_idx + 3 + WIDTH];
       data_out_14 <= buffer[w_idx + 4 + WIDTH];

       data_out_15 <= buffer[w_idx + WIDTH * 2];
       data_out_16 <= buffer[w_idx + 1 + WIDTH * 2];
       data_out_17 <= buffer[w_idx + 2 + WIDTH * 2];
       data_out_18 <= buffer[w_idx + 3 + WIDTH * 2];
       data_out_19 <= buffer[w_idx + 4 + WIDTH * 2];

       data_out_20 <= buffer[w_idx + WIDTH * 3];
       data_out_21 <= buffer[w_idx + 1 + WIDTH * 3];
       data_out_22 <= buffer[w_idx + 2 + WIDTH * 3];
       data_out_23 <= buffer[w_idx + 3 + WIDTH * 3];
       data_out_24 <= buffer[w_idx + 4 + WIDTH * 3];   
     end
   end
   end
 end
endmodule

/*------------------------------------------------------------------------
 *
 *  Copyright (c) 2021 by Bo Young Kang, All rights reserved.
 *
 *  File name  : conv1_calc.v
 *  Written by : Kang, Bo Young
 *  Written on : Oct 1, 2021
 *  Version    : 21.2
 *  Design     : 1st Convolution Layer for CNN MNIST dataset
 *               Convolution Sum Calculation
 *
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------
 *  Module: conv1_calc
 *------------------------------------------------------------------*/
 
// 25ê³? Ã— 3ì±„ë„ ?™?‹œ, ?Š¸ë¦? 5?‹¨ + ì¶œë ¥? ˆì§??Š¤?„°
module conv1_calc #(
  parameter DATA_BITS = 8,
  parameter MUL_LAT   = 1         // ê³? ê²°ê³¼ë¥? 1?‹¨ ? ˆì§??Š¤?„°ë¡? ?ŒŒ?´?”„(ê¶Œì¥ 1~2)
)(
  input  clk,
  input  rst_n,

  input  valid_out_buf,             // conv1_buf?—?„œ?˜ ?œˆ?„?š° ?œ ?š¨
  input  [DATA_BITS-1:0] data_out_0,  input [DATA_BITS-1:0] data_out_1,
  input  [DATA_BITS-1:0] data_out_2,  input [DATA_BITS-1:0] data_out_3,
  input  [DATA_BITS-1:0] data_out_4,  input [DATA_BITS-1:0] data_out_5,
  input  [DATA_BITS-1:0] data_out_6,  input [DATA_BITS-1:0] data_out_7,
  input  [DATA_BITS-1:0] data_out_8,  input [DATA_BITS-1:0] data_out_9,
  input  [DATA_BITS-1:0] data_out_10, input [DATA_BITS-1:0] data_out_11,
  input  [DATA_BITS-1:0] data_out_12, input [DATA_BITS-1:0] data_out_13,
  input  [DATA_BITS-1:0] data_out_14, input [DATA_BITS-1:0] data_out_15,
  input  [DATA_BITS-1:0] data_out_16, input [DATA_BITS-1:0] data_out_17,
  input  [DATA_BITS-1:0] data_out_18, input [DATA_BITS-1:0] data_out_19,
  input  [DATA_BITS-1:0] data_out_20, input [DATA_BITS-1:0] data_out_21,
  input  [DATA_BITS-1:0] data_out_22, input [DATA_BITS-1:0] data_out_23,
  input  [DATA_BITS-1:0] data_out_24,

  input  [0:199] w_11, input [0:199] w_12, input [0:199] w_13,
  input  [0:23]  b_1,

  output reg signed [11:0] conv_out_1,
  output reg signed [11:0] conv_out_2,
  output reg signed [11:0] conv_out_3,
  output                  valid_out_calc
);
  localparam K       = 5;
  localparam N_TAPS  = K*K;                // 25
  localparam A_W     = DATA_BITS + 1;      // 9 (px: unsigned->signed ?™•?¥)
  localparam B_W     = DATA_BITS;          // 8 (weight)
  localparam MUL_W   = A_W + B_W;          // 17 (ê³?)
  localparam SUM_W   = 22;                 // 17 + ceil(log2(25)) = 22
  localparam LAT_TREE= 5;                  // ?Š¸ë¦? ?ŒŒ?´?”„ ?‹¨ê³?
  localparam LAT_OUT = 1;                  // ì¶œë ¥ ? ˆì§??Š¤?„°
  localparam LAT_TOT = MUL_LAT + LAT_TREE + LAT_OUT;

  // ?…? ¥ ?”½?? sign-extend
  wire signed [A_W-1:0] x [0:N_TAPS-1];
  assign x[0] = data_out_0,   x[1] = data_out_1,   x[2] = data_out_2,   x[3] = data_out_3,   x[4] = data_out_4;
  assign x[5] = data_out_5,   x[6] = data_out_6,   x[7] = data_out_7,   x[8] = data_out_8,   x[9] = data_out_9;
  assign x[10] = data_out_10, x[11] = data_out_11, x[12] = data_out_12, x[13] = data_out_13, x[14] = data_out_14;
  assign x[15] = data_out_15, x[16] = data_out_16, x[17] = data_out_17, x[18] = data_out_18, x[19] = data_out_19;
  assign x[20] = data_out_20, x[21] = data_out_21, x[22] = data_out_22, x[23] = data_out_23, x[24] = data_out_24;

  // ê°?ì¤‘ì¹˜ ?–¸?Œ©
  reg signed [B_W-1:0] w1 [0:N_TAPS-1], w2 [0:N_TAPS-1], w3 [0:N_TAPS-1];
  reg signed [7:0]     b  [0:2];
  integer i;
  always @* begin
    for (i=0;i<N_TAPS;i=i+1) begin
      w1[i]=w_11[(8*i)+:8];
      w2[i]=w_12[(8*i)+:8];
      w3[i]=w_13[(8*i)+:8];
    end
    b[0]=b_1[ 0+:8]; b[1]=b_1[8+:8]; b[2]=b_1[16+:8];
  end
  wire signed [11:0] bias1 = b[0][7]? {4'hF,b[0]} : {4'h0,b[0]};
  wire signed [11:0] bias2 = b[1][7]? {4'hF,b[1]} : {4'h0,b[1]};
  wire signed [11:0] bias3 = b[2][7]? {4'hF,b[2]} : {4'h0,b[2]};

  // 25Ã—3 ?™?‹œ ê³? (DSP ?Œ?Š¸) + MUL_LAT?‹¨ ?ŒŒ?´?”„
  (* use_dsp="yes" *) wire signed [MUL_W-1:0] p1_w [0:N_TAPS-1];
  (* use_dsp="yes" *) wire signed [MUL_W-1:0] p2_w [0:N_TAPS-1];
  (* use_dsp="yes" *) wire signed [MUL_W-1:0] p3_w [0:N_TAPS-1];
  genvar gi;
  generate
    for (gi=0; gi<N_TAPS; gi=gi+1) begin: MULS
      assign p1_w[gi] = x[gi]*w1[gi];
      assign p2_w[gi] = x[gi]*w2[gi];
      assign p3_w[gi] = x[gi]*w3[gi];
    end
  endgenerate

  // ê³? ?ŒŒ?´?”„ ? ˆì§??Š¤?„° (ê¹Šì´ MUL_LAT)
  reg signed [MUL_W-1:0] p1 [0:MUL_LAT-1][0:N_TAPS-1];
  reg signed [MUL_W-1:0] p2 [0:MUL_LAT-1][0:N_TAPS-1];
  reg signed [MUL_W-1:0] p3 [0:MUL_LAT-1][0:N_TAPS-1];
  integer m,n;
  always @(posedge clk) begin
    if (!rst_n) begin
      for (m=0;m<MUL_LAT;m=m+1) begin
        for (n=0;n<N_TAPS;n=n+1) begin
          p1[m][n] <= 0; p2[m][n] <= 0; p3[m][n] <= 0;
        end
      end
    end else begin
      // shift
      for (m=MUL_LAT-1; m>0; m=m-1)
        for (n=0;n<N_TAPS;n=n+1) begin
          p1[m][n] <= p1[m-1][n];
          p2[m][n] <= p2[m-1][n];
          p3[m][n] <= p3[m-1][n];
        end
      // insert
     for (n=0;n<N_TAPS;n=n+1) begin
        p1[0][n] <= valid_out_buf ? p1_w[n] : {MUL_W{1'b0}};
        p2[0][n] <= valid_out_buf ? p2_w[n] : {MUL_W{1'b0}};
        p3[0][n] <= valid_out_buf ? p3_w[n] : {MUL_W{1'b0}};
      end
    end
  end

  // ì±„ë„ë³? ?Š¸ë¦?
  wire [SUM_W-1:0] sum1, sum2, sum3;
  adder_tree25_pipe #(.IN_W(MUL_W), .SUM_W(SUM_W)) AT1 (
    .clk(clk), .rst_n(rst_n),
    .in0(p1[MUL_LAT-1][0]),  .in1(p1[MUL_LAT-1][1]),
    .in2(p1[MUL_LAT-1][2]),  .in3(p1[MUL_LAT-1][3]),
    .in4(p1[MUL_LAT-1][4]),  .in5(p1[MUL_LAT-1][5]),
    .in6(p1[MUL_LAT-1][6]),  .in7(p1[MUL_LAT-1][7]),
    .in8(p1[MUL_LAT-1][8]),  .in9(p1[MUL_LAT-1][9]),
    .in10(p1[MUL_LAT-1][10]),.in11(p1[MUL_LAT-1][11]),
    .in12(p1[MUL_LAT-1][12]),.in13(p1[MUL_LAT-1][13]),
    .in14(p1[MUL_LAT-1][14]),.in15(p1[MUL_LAT-1][15]),
    .in16(p1[MUL_LAT-1][16]),.in17(p1[MUL_LAT-1][17]),
    .in18(p1[MUL_LAT-1][18]),.in19(p1[MUL_LAT-1][19]),
    .in20(p1[MUL_LAT-1][20]),.in21(p1[MUL_LAT-1][21]),
    .in22(p1[MUL_LAT-1][22]),.in23(p1[MUL_LAT-1][23]),
    .in24(p1[MUL_LAT-1][24]),
    .sum(sum1)
  );
  adder_tree25_pipe #(.IN_W(MUL_W), .SUM_W(SUM_W)) AT2 (
    .clk(clk), .rst_n(rst_n),
    .in0(p2[MUL_LAT-1][0]),  .in1(p2[MUL_LAT-1][1]),
    .in2(p2[MUL_LAT-1][2]),  .in3(p2[MUL_LAT-1][3]),
    .in4(p2[MUL_LAT-1][4]),  .in5(p2[MUL_LAT-1][5]),
    .in6(p2[MUL_LAT-1][6]),  .in7(p2[MUL_LAT-1][7]),
    .in8(p2[MUL_LAT-1][8]),  .in9(p2[MUL_LAT-1][9]),
    .in10(p2[MUL_LAT-1][10]),.in11(p2[MUL_LAT-1][11]),
    .in12(p2[MUL_LAT-1][12]),.in13(p2[MUL_LAT-1][13]),
    .in14(p2[MUL_LAT-1][14]),.in15(p2[MUL_LAT-1][15]),
    .in16(p2[MUL_LAT-1][16]),.in17(p2[MUL_LAT-1][17]),
    .in18(p2[MUL_LAT-1][18]),.in19(p2[MUL_LAT-1][19]),
    .in20(p2[MUL_LAT-1][20]),.in21(p2[MUL_LAT-1][21]),
    .in22(p2[MUL_LAT-1][22]),.in23(p2[MUL_LAT-1][23]),
    .in24(p2[MUL_LAT-1][24]),
    .sum(sum2)
  );
  adder_tree25_pipe #(.IN_W(MUL_W), .SUM_W(SUM_W)) AT3 (
    .clk(clk), .rst_n(rst_n),
    .in0(p3[MUL_LAT-1][0]),  .in1(p3[MUL_LAT-1][1]),
    .in2(p3[MUL_LAT-1][2]),  .in3(p3[MUL_LAT-1][3]),
    .in4(p3[MUL_LAT-1][4]),  .in5(p3[MUL_LAT-1][5]),
    .in6(p3[MUL_LAT-1][6]),  .in7(p3[MUL_LAT-1][7]),
    .in8(p3[MUL_LAT-1][8]),  .in9(p3[MUL_LAT-1][9]),
    .in10(p3[MUL_LAT-1][10]),.in11(p3[MUL_LAT-1][11]),
    .in12(p3[MUL_LAT-1][12]),.in13(p3[MUL_LAT-1][13]),
    .in14(p3[MUL_LAT-1][14]),.in15(p3[MUL_LAT-1][15]),
    .in16(p3[MUL_LAT-1][16]),.in17(p3[MUL_LAT-1][17]),
    .in18(p3[MUL_LAT-1][18]),.in19(p3[MUL_LAT-1][19]),
    .in20(p3[MUL_LAT-1][20]),.in21(p3[MUL_LAT-1][21]),
    .in22(p3[MUL_LAT-1][22]),.in23(p3[MUL_LAT-1][23]),
    .in24(p3[MUL_LAT-1][24]),
    .sum(sum3)
  );

  // ê²°ê³¼ ?Š¤ì¼??¼+ë°”ì´?–´?Š¤(?› ì½”ë“œ ?™?¼: [19:8]) + ì¶œë ¥ ? ˆì§??Š¤?„°
  wire signed [19:0] calc1 = sum1[19:0];
  wire signed [19:0] calc2 = sum2[19:0];
  wire signed [19:0] calc3 = sum3[19:0];
  always @(posedge clk) begin
    if (!rst_n) begin
      conv_out_1 <= 12'sd0; conv_out_2 <= 12'sd0; conv_out_3 <= 12'sd0;
    end else begin
      conv_out_1 <= calc1[19:8] + bias1;
      conv_out_2 <= calc2[19:8] + bias2;
      conv_out_3 <= calc3[19:8] + bias3;
    end
  end

  // valid ? •? ¬: valid_out_bufë¥? LAT_TOTë§Œí¼ ì§??—°
  reg [LAT_TOT-1:0] vpipe;
  integer vv;
  always @(posedge clk) begin
    if (!rst_n) vpipe <= {LAT_TOT{1'b0}};
    else        vpipe <= {vpipe[LAT_TOT-2:0], valid_out_buf};
  end
  assign valid_out_calc = vpipe[LAT_TOT-1];

endmodule
