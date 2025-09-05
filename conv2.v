/*-------------------------------------------------------------------
 *  Module: conv2_layer
 *------------------------------------------------------------------*/
 `timescale 1ps/1ps
 
module conv2_layer (
   input clk,
   input rst_n,
   input valid_in,
   input [11:0] max_value_1, max_value_2, max_value_3,
   output signed [11:0] conv2_out_1, conv2_out_2, conv2_out_3,
   output  valid_out_conv2,
   input [0:199] w_211, w_212, w_213,
   input [0:199] w_221, w_222, w_223,
   input [0:199] w_231, w_232, w_233,
   input [0:23] b_2
 );

localparam CHANNEL_LEN = 3;

// Channel 1
 wire [11:0] data_out1_0, data_out1_1, data_out1_2, data_out1_3, data_out1_4,
  data_out1_5, data_out1_6, data_out1_7, data_out1_8, data_out1_9,
  data_out1_10, data_out1_11, data_out1_12, data_out1_13, data_out1_14,
  data_out1_15, data_out1_16, data_out1_17, data_out1_18, data_out1_19,
  data_out1_20, data_out1_21, data_out1_22, data_out1_23, data_out1_24;
 wire valid_out1_buf;

// Channel 2
 wire [11:0] data_out2_0, data_out2_1, data_out2_2, data_out2_3, data_out2_4,
  data_out2_5, data_out2_6, data_out2_7, data_out2_8, data_out2_9,
  data_out2_10, data_out2_11, data_out2_12, data_out2_13, data_out2_14,
  data_out2_15, data_out2_16, data_out2_17, data_out2_18, data_out2_19,
  data_out2_20, data_out2_21, data_out2_22, data_out2_23, data_out2_24;
 wire valid_out2_buf;

 // Channel 3 
 wire [11:0] data_out3_0, data_out3_1, data_out3_2, data_out3_3, data_out3_4,
  data_out3_5, data_out3_6, data_out3_7, data_out3_8, data_out3_9,
  data_out3_10, data_out3_11, data_out3_12, data_out3_13, data_out3_14,
  data_out3_15, data_out3_16, data_out3_17, data_out3_18, data_out3_19,
  data_out3_20, data_out3_21, data_out3_22, data_out3_23, data_out3_24;
 wire valid_out3_buf;

 wire signed [13:0] conv_out_1, conv_out_2, conv_out_3;
 wire valid_out_buf, valid_out_calc_1, valid_out_calc_2, valid_out_calc_3;
 assign valid_out_buf = valid_out1_buf & valid_out2_buf & valid_out3_buf;
 assign valid_out_conv2 = valid_out_calc_1 & valid_out_calc_2 & valid_out_calc_3;

 reg signed [7:0] bias [0:CHANNEL_LEN - 1];
 wire signed [11:0] exp_bias [0:CHANNEL_LEN - 1];

// Channel 1
conv2_buf #(.WIDTH(12), .HEIGHT(12), .DATA_BITS(12)) conv2_buf_1(
   .clk(clk),
   .rst_n(rst_n),
   .valid_in(valid_in),
   .data_in(max_value_1),
   .data_out_0(data_out1_0),    .data_out_1(data_out1_1),   .data_out_2(data_out1_2),   .data_out_3(data_out1_3),   .data_out_4(data_out1_4),
   .data_out_5(data_out1_5),    .data_out_6(data_out1_6),   .data_out_7(data_out1_7),   .data_out_8(data_out1_8),   .data_out_9(data_out1_9),
   .data_out_10(data_out1_10),   .data_out_11(data_out1_11),   .data_out_12(data_out1_12),   .data_out_13(data_out1_13),   .data_out_14(data_out1_14),
   .data_out_15(data_out1_15),   .data_out_16(data_out1_16),   .data_out_17(data_out1_17),   .data_out_18(data_out1_18),   .data_out_19(data_out1_19),
   .data_out_20(data_out1_20),   .data_out_21(data_out1_21),   .data_out_22(data_out1_22),   .data_out_23(data_out1_23),   .data_out_24(data_out1_24),
   .valid_out_buf(valid_out1_buf)
 );

// Channel 2
conv2_buf #(.WIDTH(12), .HEIGHT(12), .DATA_BITS  (12)) conv2_buf_2(
   .clk(clk),
   .rst_n(rst_n),
   .valid_in(valid_in),
   .data_in(max_value_2),
   .data_out_0(data_out2_0),   .data_out_1(data_out2_1),   .data_out_2(data_out2_2),   .data_out_3(data_out2_3),   .data_out_4(data_out2_4),
   .data_out_5(data_out2_5),   .data_out_6(data_out2_6),   .data_out_7(data_out2_7),   .data_out_8(data_out2_8),   .data_out_9(data_out2_9),
   .data_out_10(data_out2_10),   .data_out_11(data_out2_11),   .data_out_12(data_out2_12),   .data_out_13(data_out2_13),   .data_out_14(data_out2_14),
   .data_out_15(data_out2_15),   .data_out_16(data_out2_16),   .data_out_17(data_out2_17),   .data_out_18(data_out2_18),   .data_out_19(data_out2_19),
   .data_out_20(data_out2_20),   .data_out_21(data_out2_21),   .data_out_22(data_out2_22),   .data_out_23(data_out2_23),   .data_out_24(data_out2_24),
   .valid_out_buf(valid_out2_buf)
 );

// Channel 3
conv2_buf #(.WIDTH(12), .HEIGHT(12), .DATA_BITS(12)) conv2_buf_3(
   .clk(clk),
   .rst_n(rst_n),
   .valid_in(valid_in),
   .data_in(max_value_3),
   .data_out_0(data_out3_0),   .data_out_1(data_out3_1),   .data_out_2(data_out3_2),   .data_out_3(data_out3_3),   .data_out_4(data_out3_4),
   .data_out_5(data_out3_5),   .data_out_6(data_out3_6),   .data_out_7(data_out3_7),   .data_out_8(data_out3_8),   .data_out_9(data_out3_9),
   .data_out_10(data_out3_10),   .data_out_11(data_out3_11),   .data_out_12(data_out3_12),   .data_out_13(data_out3_13),   .data_out_14(data_out3_14),
   .data_out_15(data_out3_15),   .data_out_16(data_out3_16),   .data_out_17(data_out3_17),   .data_out_18(data_out3_18),   .data_out_19(data_out3_19),
   .data_out_20(data_out3_20),   .data_out_21(data_out3_21),   .data_out_22(data_out3_22),   .data_out_23(data_out3_23),   .data_out_24(data_out3_24),
   .valid_out_buf(valid_out3_buf)
 );

// Channel 1
conv2_calc #(.DATA_BITS(12), .MUL_LAT(1), .OUT_W(14)) conv2_calc_1(
   .clk(clk),
   .rst_n(rst_n),
   .valid_out_buf(valid_out_buf),

   .data_out1_0(data_out1_0),   .data_out1_1(data_out1_1),   .data_out1_2(data_out1_2),   .data_out1_3(data_out1_3),   .data_out1_4(data_out1_4),
   .data_out1_5(data_out1_5),   .data_out1_6(data_out1_6),   .data_out1_7(data_out1_7),   .data_out1_8(data_out1_8),   .data_out1_9(data_out1_9),
   .data_out1_10(data_out1_10),   .data_out1_11(data_out1_11),   .data_out1_12(data_out1_12),   .data_out1_13(data_out1_13),   .data_out1_14(data_out1_14),
   .data_out1_15(data_out1_15),   .data_out1_16(data_out1_16),   .data_out1_17(data_out1_17),   .data_out1_18(data_out1_18),   .data_out1_19(data_out1_19),
   .data_out1_20(data_out1_20),   .data_out1_21(data_out1_21),   .data_out1_22(data_out1_22),   .data_out1_23(data_out1_23),   .data_out1_24(data_out1_24),

   .data_out2_0(data_out2_0),   .data_out2_1(data_out2_1),   .data_out2_2(data_out2_2),   .data_out2_3(data_out2_3),   .data_out2_4(data_out2_4),
   .data_out2_5(data_out2_5),   .data_out2_6(data_out2_6),   .data_out2_7(data_out2_7),   .data_out2_8(data_out2_8),   .data_out2_9(data_out2_9),
   .data_out2_10(data_out2_10),   .data_out2_11(data_out2_11),   .data_out2_12(data_out2_12),   .data_out2_13(data_out2_13),   .data_out2_14(data_out2_14),
   .data_out2_15(data_out2_15),   .data_out2_16(data_out2_16),   .data_out2_17(data_out2_17),   .data_out2_18(data_out2_18),   .data_out2_19(data_out2_19),
   .data_out2_20(data_out2_20),   .data_out2_21(data_out2_21),   .data_out2_22(data_out2_22),   .data_out2_23(data_out2_23),   .data_out2_24(data_out2_24),

   .data_out3_0(data_out3_0),   .data_out3_1(data_out3_1),   .data_out3_2(data_out3_2),   .data_out3_3(data_out3_3),   .data_out3_4(data_out3_4),
   .data_out3_5(data_out3_5),   .data_out3_6(data_out3_6),   .data_out3_7(data_out3_7),   .data_out3_8(data_out3_8),   .data_out3_9(data_out3_9),
   .data_out3_10(data_out3_10),   .data_out3_11(data_out3_11),   .data_out3_12(data_out3_12),   .data_out3_13(data_out3_13),   .data_out3_14(data_out3_14),
   .data_out3_15(data_out3_15),   .data_out3_16(data_out3_16),   .data_out3_17(data_out3_17),   .data_out3_18(data_out3_18),   .data_out3_19(data_out3_19),
   .data_out3_20(data_out3_20),   .data_out3_21(data_out3_21),   .data_out3_22(data_out3_22),   .data_out3_23(data_out3_23),   .data_out3_24(data_out3_24),

   .conv_out_calc(conv_out_1),
   .valid_out_calc(valid_out_calc_1),

   .w_1(w_211),  .w_2(w_212),  .w_3(w_213)
);

// Channel 2
conv2_calc #(.DATA_BITS(12), .MUL_LAT(1), .OUT_W(14)) conv2_calc_2(
   .clk(clk),
   .rst_n(rst_n),
   .valid_out_buf(valid_out_buf),
   .data_out1_0(data_out1_0),   .data_out1_1(data_out1_1),   .data_out1_2(data_out1_2),   .data_out1_3(data_out1_3),   .data_out1_4(data_out1_4),
   .data_out1_5(data_out1_5),   .data_out1_6(data_out1_6),   .data_out1_7(data_out1_7),   .data_out1_8(data_out1_8),   .data_out1_9(data_out1_9),
   .data_out1_10(data_out1_10),   .data_out1_11(data_out1_11),   .data_out1_12(data_out1_12),   .data_out1_13(data_out1_13),   .data_out1_14(data_out1_14),
   .data_out1_15(data_out1_15),   .data_out1_16(data_out1_16),   .data_out1_17(data_out1_17),   .data_out1_18(data_out1_18),   .data_out1_19(data_out1_19),
   .data_out1_20(data_out1_20),   .data_out1_21(data_out1_21),   .data_out1_22(data_out1_22),   .data_out1_23(data_out1_23),   .data_out1_24(data_out1_24),

   .data_out2_0(data_out2_0),   .data_out2_1(data_out2_1),   .data_out2_2(data_out2_2),   .data_out2_3(data_out2_3),   .data_out2_4(data_out2_4),
   .data_out2_5(data_out2_5),   .data_out2_6(data_out2_6),   .data_out2_7(data_out2_7),   .data_out2_8(data_out2_8),   .data_out2_9(data_out2_9),
   .data_out2_10(data_out2_10),   .data_out2_11(data_out2_11),   .data_out2_12(data_out2_12),   .data_out2_13(data_out2_13),   .data_out2_14(data_out2_14),
   .data_out2_15(data_out2_15),   .data_out2_16(data_out2_16),   .data_out2_17(data_out2_17),   .data_out2_18(data_out2_18),   .data_out2_19(data_out2_19),
   .data_out2_20(data_out2_20),   .data_out2_21(data_out2_21),   .data_out2_22(data_out2_22),   .data_out2_23(data_out2_23),   .data_out2_24(data_out2_24),

   .data_out3_0(data_out3_0),   .data_out3_1(data_out3_1),   .data_out3_2(data_out3_2),   .data_out3_3(data_out3_3),   .data_out3_4(data_out3_4),
   .data_out3_5(data_out3_5),   .data_out3_6(data_out3_6),   .data_out3_7(data_out3_7),   .data_out3_8(data_out3_8),   .data_out3_9(data_out3_9),
   .data_out3_10(data_out3_10),   .data_out3_11(data_out3_11),   .data_out3_12(data_out3_12),   .data_out3_13(data_out3_13),   .data_out3_14(data_out3_14),
   .data_out3_15(data_out3_15),   .data_out3_16(data_out3_16),   .data_out3_17(data_out3_17),   .data_out3_18(data_out3_18),   .data_out3_19(data_out3_19),
   .data_out3_20(data_out3_20),   .data_out3_21(data_out3_21),   .data_out3_22(data_out3_22),   .data_out3_23(data_out3_23),   .data_out3_24(data_out3_24),

   .conv_out_calc(conv_out_2),
   .valid_out_calc(valid_out_calc_2),

   .w_1(w_221),  .w_2(w_222),  .w_3(w_223)   
);

// Channel 3
conv2_calc #(.DATA_BITS(12), .MUL_LAT(1), .OUT_W(14)) conv2_calc_3(
   .clk(clk),
   .rst_n(rst_n),
   .valid_out_buf(valid_out_buf),

   .data_out1_0(data_out1_0),   .data_out1_1(data_out1_1),   .data_out1_2(data_out1_2),   .data_out1_3(data_out1_3),   .data_out1_4(data_out1_4),
   .data_out1_5(data_out1_5),   .data_out1_6(data_out1_6),   .data_out1_7(data_out1_7),   .data_out1_8(data_out1_8),   .data_out1_9(data_out1_9),
   .data_out1_10(data_out1_10),   .data_out1_11(data_out1_11),   .data_out1_12(data_out1_12),   .data_out1_13(data_out1_13),   .data_out1_14(data_out1_14),
   .data_out1_15(data_out1_15),   .data_out1_16(data_out1_16),   .data_out1_17(data_out1_17),   .data_out1_18(data_out1_18),   .data_out1_19(data_out1_19),
   .data_out1_20(data_out1_20),   .data_out1_21(data_out1_21),   .data_out1_22(data_out1_22),   .data_out1_23(data_out1_23),   .data_out1_24(data_out1_24),

   .data_out2_0(data_out2_0),   .data_out2_1(data_out2_1),   .data_out2_2(data_out2_2),   .data_out2_3(data_out2_3),   .data_out2_4(data_out2_4),
   .data_out2_5(data_out2_5),   .data_out2_6(data_out2_6),   .data_out2_7(data_out2_7),   .data_out2_8(data_out2_8),   .data_out2_9(data_out2_9),
   .data_out2_10(data_out2_10),   .data_out2_11(data_out2_11),   .data_out2_12(data_out2_12),   .data_out2_13(data_out2_13),   .data_out2_14(data_out2_14),
   .data_out2_15(data_out2_15),   .data_out2_16(data_out2_16),   .data_out2_17(data_out2_17),   .data_out2_18(data_out2_18),   .data_out2_19(data_out2_19),
   .data_out2_20(data_out2_20),   .data_out2_21(data_out2_21),   .data_out2_22(data_out2_22),   .data_out2_23(data_out2_23),   .data_out2_24(data_out2_24),

   .data_out3_0(data_out3_0),   .data_out3_1(data_out3_1),   .data_out3_2(data_out3_2),   .data_out3_3(data_out3_3),   .data_out3_4(data_out3_4),
   .data_out3_5(data_out3_5),   .data_out3_6(data_out3_6),   .data_out3_7(data_out3_7),   .data_out3_8(data_out3_8),   .data_out3_9(data_out3_9),
   .data_out3_10(data_out3_10),   .data_out3_11(data_out3_11),   .data_out3_12(data_out3_12),   .data_out3_13(data_out3_13),   .data_out3_14(data_out3_14),
   .data_out3_15(data_out3_15),   .data_out3_16(data_out3_16),   .data_out3_17(data_out3_17),   .data_out3_18(data_out3_18),   .data_out3_19(data_out3_19),
   .data_out3_20(data_out3_20),   .data_out3_21(data_out3_21),   .data_out3_22(data_out3_22),   .data_out3_23(data_out3_23),   .data_out3_24(data_out3_24),

   .conv_out_calc(conv_out_3),
   .valid_out_calc(valid_out_calc_3),

   .w_1(w_231),  .w_2(w_232),  .w_3(w_233)   
);

integer i;
always @(*) begin
    for(i=0;i<=2;i=i+1) begin
        bias[i]=b_2[(8*i)+:8];
    end
end
 assign exp_bias[0] = (bias[0][7] == 1) ? {4'b1111, bias[0]} : {4'b0000, bias[0]};
 assign exp_bias[1] = (bias[1][7] == 1) ? {4'b1111, bias[1]} : {4'b0000, bias[1]};
 assign exp_bias[2] = (bias[2][7] == 1) ? {4'b1111, bias[2]} : {4'b0000, bias[2]};

 assign conv2_out_1 = conv_out_1[13:1] + exp_bias[0];
 assign conv2_out_2 = conv_out_2[13:1] + exp_bias[1];
 assign conv2_out_3 = conv_out_3[13:1] + exp_bias[2];
 
 endmodule


/*-------------------------------------------------------------------
 *  Module: conv2_buf
 *------------------------------------------------------------------*/

module conv2_buf #(parameter WIDTH = 12, HEIGHT = 12, DATA_BITS = 12) (
  input clk,
  input rst_n,
  input valid_in,
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
     buf_idx <= 0;
     w_idx <= 0;
     h_idx <= 0;
     buf_flag <= 0;
     state <= 0;
     valid_out_buf <= 0;
     data_out_0 <= 12'bx;     data_out_1 <= 12'bx;     data_out_2 <= 12'bx;     data_out_3 <= 12'bx;     data_out_4 <= 12'bx;
     data_out_5 <= 12'bx;     data_out_6 <= 12'bx;     data_out_7 <= 12'bx;     data_out_8 <= 12'bx;     data_out_9 <= 12'bx;
     data_out_10 <= 12'bx;     data_out_11 <= 12'bx;     data_out_12 <= 12'bx;     data_out_13 <= 12'bx;     data_out_14 <= 12'bx;
     data_out_15 <= 12'bx;     data_out_16 <= 12'bx;     data_out_17 <= 12'bx;     data_out_18 <= 12'bx;     data_out_19 <= 12'bx;
     data_out_20 <= 12'bx;     data_out_21 <= 12'bx;     data_out_22 <= 12'bx;     data_out_23 <= 12'bx;     data_out_24 <= 12'bx;
   end else begin
   if(valid_in) begin
     buf_idx <= buf_idx + 1'b1;
     if(buf_idx == WIDTH * FILTER_SIZE - 1) begin // buffer size = 140 = 28(w) * 5(h)
       buf_idx <= 0;
     end
     
     buffer[buf_idx] <= data_in;  // data input
     // Wait until first 140 input data filled in buffer
     if(!state) begin
       if(buf_idx == WIDTH * FILTER_SIZE - 1) begin
         state <= 1;
       end
     end else begin // valid state
       w_idx <= w_idx + 1'b1; // move right

     if(w_idx == WIDTH - FILTER_SIZE + 1) begin
       valid_out_buf <= 1'b0;  // unvalid area
     end else if(w_idx == WIDTH - 1) begin
       buf_flag <= buf_flag + 1;
       if(buf_flag == FILTER_SIZE - 1) begin
         buf_flag <= 0;
       end

       w_idx <= 0;

        if(h_idx == HEIGHT - FILTER_SIZE) begin // done 1 input read -> 28 * 28
          h_idx <= 0;
          state <= 0;
        end
          h_idx <= h_idx + 1;

      end else if(w_idx == 0) begin
        valid_out_buf <= 1'b1;  // start valid area
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
 end
endmodule

/*-------------------------------------------------------------------
 *  Module: conv2_calc
 *------------------------------------------------------------------*/
module conv2_calc #(
  parameter integer DATA_BITS = 12,  // input activations
  parameter integer MUL_LAT   = 1,   // multiplier latency stages to match DSPs
  parameter integer OUT_W     = 14   // output width after scaling (default 14b)
)(
  input clk,
  input rst_n,
  input valid_out_buf,
	input signed [11:0] data_out1_0, data_out1_1, data_out1_2, data_out1_3, data_out1_4,
	  data_out1_5, data_out1_6, data_out1_7, data_out1_8, data_out1_9,
	  data_out1_10, data_out1_11, data_out1_12, data_out1_13, data_out1_14,
	  data_out1_15, data_out1_16, data_out1_17, data_out1_18, data_out1_19,
	  data_out1_20, data_out1_21, data_out1_22, data_out1_23, data_out1_24,
	
	  data_out2_0, data_out2_1, data_out2_2, data_out2_3, data_out2_4,
	  data_out2_5, data_out2_6, data_out2_7, data_out2_8, data_out2_9,
	  data_out2_10, data_out2_11, data_out2_12, data_out2_13, data_out2_14,
	  data_out2_15, data_out2_16, data_out2_17, data_out2_18, data_out2_19,
	  data_out2_20, data_out2_21, data_out2_22, data_out2_23, data_out2_24,
	
	  data_out3_0, data_out3_1, data_out3_2, data_out3_3, data_out3_4,
	  data_out3_5, data_out3_6, data_out3_7, data_out3_8, data_out3_9,
	  data_out3_10, data_out3_11, data_out3_12, data_out3_13, data_out3_14,
	  data_out3_15, data_out3_16, data_out3_17, data_out3_18, data_out3_19,
	  data_out3_20, data_out3_21, data_out3_22, data_out3_23, data_out3_24,

	output reg [OUT_W-1:0] conv_out_calc,
  	output reg valid_out_calc,
  	input [0:199] w_1,
   	input [0:199] w_2,
	input [0:199] w_3
);
  localparam K       = 5;
  localparam N_TAPS  = K*K;
  localparam A_W     = DATA_BITS + 1;      // 13 (px: unsigned->signed ?  ?  )
  localparam B_W     = DATA_BITS;          // 12 (weight)
  localparam integer W_W     = 8;              // weight width
  localparam integer MUL_W   = B_W + W_W; // 12 + 8 = 20

  wire signed [19:0] calc_out, calc_out_1, calc_out_2, calc_out_3;
  
  wire signed [B_W-1:0] x1 [0:N_TAPS-1];
  wire signed [B_W-1:0] x2 [0:N_TAPS-1];
  wire signed [B_W-1:0] x3 [0:N_TAPS-1];
  
// x1
assign x1[0]  = data_out1_0,  x1[1]  = data_out1_1,  x1[2]  = data_out1_2,  x1[3]  = data_out1_3,  x1[4]  = data_out1_4;
assign x1[5]  = data_out1_5,  x1[6]  = data_out1_6,  x1[7]  = data_out1_7,  x1[8]  = data_out1_8,  x1[9]  = data_out1_9;
assign x1[10] = data_out1_10, x1[11] = data_out1_11, x1[12] = data_out1_12, x1[13] = data_out1_13, x1[14] = data_out1_14;
assign x1[15] = data_out1_15, x1[16] = data_out1_16, x1[17] = data_out1_17, x1[18] = data_out1_18, x1[19] = data_out1_19;
assign x1[20] = data_out1_20, x1[21] = data_out1_21, x1[22] = data_out1_22, x1[23] = data_out1_23, x1[24] = data_out1_24;

// x2
assign x2[0]  = data_out2_0,  x2[1]  = data_out2_1,  x2[2]  = data_out2_2,  x2[3]  = data_out2_3,  x2[4]  = data_out2_4;
assign x2[5]  = data_out2_5,  x2[6]  = data_out2_6,  x2[7]  = data_out2_7,  x2[8]  = data_out2_8,  x2[9]  = data_out2_9;
assign x2[10] = data_out2_10, x2[11] = data_out2_11, x2[12] = data_out2_12, x2[13] = data_out2_13, x2[14] = data_out2_14;
assign x2[15] = data_out2_15, x2[16] = data_out2_16, x2[17] = data_out2_17, x2[18] = data_out2_18, x2[19] = data_out2_19;
assign x2[20] = data_out2_20, x2[21] = data_out2_21, x2[22] = data_out2_22, x2[23] = data_out2_23, x2[24] = data_out2_24;

// x3
assign x3[0]  = data_out3_0,  x3[1]  = data_out3_1,  x3[2]  = data_out3_2,  x3[3]  = data_out3_3,  x3[4]  = data_out3_4;
assign x3[5]  = data_out3_5,  x3[6]  = data_out3_6,  x3[7]  = data_out3_7,  x3[8]  = data_out3_8,  x3[9]  = data_out3_9;
assign x3[10] = data_out3_10, x3[11] = data_out3_11, x3[12] = data_out3_12, x3[13] = data_out3_13, x3[14] = data_out3_14;
assign x3[15] = data_out3_15, x3[16] = data_out3_16, x3[17] = data_out3_17, x3[18] = data_out3_18, x3[19] = data_out3_19;
assign x3[20] = data_out3_20, x3[21] = data_out3_21, x3[22] = data_out3_22, x3[23] = data_out3_23, x3[24] = data_out3_24;

  reg signed [7:0] w1 [0:N_TAPS-1], w2 [0:N_TAPS-1], w3 [0:N_TAPS-1];
  
  integer i;
  always @(*) begin
    for(i=0;i<=24;i=i+1) begin
        w1[i]=w_1[(8*i)+:8];
        w2[i]=w_2[(8*i)+:8];
        w3[i]=w_3[(8*i)+:8];
    end
  end

  (* use_dsp="yes" *) wire signed [MUL_W-1:0] m1_w [0:N_TAPS-1];
  (* use_dsp="yes" *) wire signed [MUL_W-1:0] m2_w [0:N_TAPS-1];
  (* use_dsp="yes" *) wire signed [MUL_W-1:0] m3_w [0:N_TAPS-1];

  genvar gi;
  generate
    for (gi=0; gi<N_TAPS; gi=gi+1) begin: MULS
      assign m1_w[gi] = x1[gi] * w1[gi];
      assign m2_w[gi] = x2[gi] * w2[gi];
      assign m3_w[gi] = x3[gi] * w3[gi];
    end
  endgenerate
  
  reg signed [MUL_W-1:0] m1 [0:MUL_LAT-1][0:N_TAPS-1];
  reg signed [MUL_W-1:0] m2 [0:MUL_LAT-1][0:N_TAPS-1];
  reg signed [MUL_W-1:0] m3 [0:MUL_LAT-1][0:N_TAPS-1];

  integer m,n;
  always @(posedge clk) begin
    if (!rst_n) begin
      for (m=0; m<MUL_LAT; m=m+1) begin
        for (n=0; n<N_TAPS; n=n+1) begin
          m1[m][n] <= 0; m2[m][n] <= 0; m3[m][n] <= 0;
        end
      end
    end else begin
      for (m=MUL_LAT-1; m>0; m=m-1) //shift
        for (n=0; n<N_TAPS; n=n+1) begin
          m1[m][n] <= m1[m-1][n];
          m2[m][n] <= m2[m-1][n];
          m3[m][n] <= m3[m-1][n];
        end
      // insert
     for (n=0; n<N_TAPS; n=n+1) begin
        m1[0][n] <= valid_out_buf ? m1_w[n] : {MUL_W{1'b0}};
        m2[0][n] <= valid_out_buf ? m2_w[n] : {MUL_W{1'b0}};
        m3[0][n] <= valid_out_buf ? m3_w[n] : {MUL_W{1'b0}};
      end
    end
  end

wire signed [MUL_W-1:0] sum1, sum2, sum3;
  adder_tree25_pipe #(.IN_W(MUL_W), .SUM_W(MUL_W)) AT1 (
    .clk(clk), .rst_n(rst_n),
    .in0(m1[MUL_LAT-1][0]),   .in1(m1[MUL_LAT-1][1]),   .in2(m1[MUL_LAT-1][2]),   .in3(m1[MUL_LAT-1][3]),   .in4(m1[MUL_LAT-1][4]),
    .in5(m1[MUL_LAT-1][5]),   .in6(m1[MUL_LAT-1][6]),   .in7(m1[MUL_LAT-1][7]),   .in8(m1[MUL_LAT-1][8]),   .in9(m1[MUL_LAT-1][9]),
    .in10(m1[MUL_LAT-1][10]),   .in11(m1[MUL_LAT-1][11]),   .in12(m1[MUL_LAT-1][12]),   .in13(m1[MUL_LAT-1][13]),   .in14(m1[MUL_LAT-1][14]),
    .in15(m1[MUL_LAT-1][15]),   .in16(m1[MUL_LAT-1][16]),   .in17(m1[MUL_LAT-1][17]),   .in18(m1[MUL_LAT-1][18]),   .in19(m1[MUL_LAT-1][19]),
    .in20(m1[MUL_LAT-1][20]),   .in21(m1[MUL_LAT-1][21]),   .in22(m1[MUL_LAT-1][22]),   .in23(m1[MUL_LAT-1][23]),   .in24(m1[MUL_LAT-1][24]), 
    .sum(sum1)
  );
  adder_tree25_pipe #(.IN_W(MUL_W), .SUM_W(MUL_W)) AT2 (
    .clk(clk), .rst_n(rst_n),
    .in0(m2[MUL_LAT-1][0]),   .in1(m2[MUL_LAT-1][1]),   .in2(m2[MUL_LAT-1][2]),   .in3(m2[MUL_LAT-1][3]),   .in4(m2[MUL_LAT-1][4]),
    .in5(m2[MUL_LAT-1][5]),   .in6(m2[MUL_LAT-1][6]),   .in7(m2[MUL_LAT-1][7]),   .in8(m2[MUL_LAT-1][8]),   .in9(m2[MUL_LAT-1][9]),
    .in10(m2[MUL_LAT-1][10]),   .in11(m2[MUL_LAT-1][11]),   .in12(m2[MUL_LAT-1][12]),   .in13(m2[MUL_LAT-1][13]),   .in14(m2[MUL_LAT-1][14]),
    .in15(m2[MUL_LAT-1][15]),   .in16(m2[MUL_LAT-1][16]),   .in17(m2[MUL_LAT-1][17]),   .in18(m2[MUL_LAT-1][18]),   .in19(m2[MUL_LAT-1][19]),
    .in20(m2[MUL_LAT-1][20]),   .in21(m2[MUL_LAT-1][21]),   .in22(m2[MUL_LAT-1][22]),   .in23(m2[MUL_LAT-1][23]),   .in24(m2[MUL_LAT-1][24]), 
    .sum(sum2)
  );
  adder_tree25_pipe #(.IN_W(MUL_W), .SUM_W(MUL_W)) AT3 (
    .clk(clk), .rst_n(rst_n),
    .in0(m3[MUL_LAT-1][0]),   .in1(m3[MUL_LAT-1][1]),   .in2(m3[MUL_LAT-1][2]),   .in3(m3[MUL_LAT-1][3]),   .in4(m3[MUL_LAT-1][4]),
    .in5(m3[MUL_LAT-1][5]),   .in6(m3[MUL_LAT-1][6]),   .in7(m3[MUL_LAT-1][7]),   .in8(m3[MUL_LAT-1][8]),   .in9(m3[MUL_LAT-1][9]),
    .in10(m3[MUL_LAT-1][10]),   .in11(m3[MUL_LAT-1][11]),   .in12(m3[MUL_LAT-1][12]),   .in13(m3[MUL_LAT-1][13]),   .in14(m3[MUL_LAT-1][14]),
    .in15(m3[MUL_LAT-1][15]),   .in16(m3[MUL_LAT-1][16]),   .in17(m3[MUL_LAT-1][17]),   .in18(m3[MUL_LAT-1][18]),   .in19(m3[MUL_LAT-1][19]),
    .in20(m3[MUL_LAT-1][20]),   .in21(m3[MUL_LAT-1][21]),   .in22(m3[MUL_LAT-1][22]),   .in23(m3[MUL_LAT-1][23]),   .in24(m3[MUL_LAT-1][24]),
    .sum(sum3)
  );
   reg signed [MUL_W-1:0] sum12;   
   reg signed [MUL_W-1:0] sum3_d1;
   reg signed [MUL_W-1:0] sum123;  
   always @(posedge clk) begin
    if (!rst_n) begin
        sum12   <= {MUL_W{1'b0}};
        sum3_d1 <= {MUL_W{1'b0}};
        sum123  <= {MUL_W{1'b0}};
    end else begin
        sum12   <= sum1 + sum2;   // t
        sum3_d1 <= sum3;          // t : sum3 1-cycle delay
        sum123  <= sum12 + sum3_d1; // t+1
    end
  end

always @(posedge clk) begin
  if (!rst_n) conv_out_calc <= 0;
  else        conv_out_calc <= sum123[19:6];
end

  localparam integer LAT_TREE = 5;
  localparam integer LAT_TOT  = MUL_LAT + LAT_TREE+1;
  
  reg [LAT_TOT-1:0] vpipe;
  reg vld_tog;
  
 always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vpipe         <= {LAT_TOT{1'b0}};
    vld_tog       <= 1'b0;
    valid_out_calc <= 1'b0;
  end else begin
    vpipe         <= {vpipe[LAT_TOT-2:0], valid_out_buf};
    
    if (vpipe[LAT_TOT-1]) 
      vld_tog <= ~vld_tog;
      
    valid_out_calc <= vpipe[LAT_TOT-1] & vld_tog; // **논블로킹(<=)**
  end
end
  
endmodule