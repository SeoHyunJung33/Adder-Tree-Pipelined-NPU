/*------------------------------------------------------------------------
 *
 * File name  : fully_connected.v
 * Design     : Fully Connected Layer for CNN (Corrected to match output)
 *
 *------------------------------------------------------------------------*/
module fully_connected #(
  parameter integer INPUT_NUM  = 48,
  parameter integer OUTPUT_NUM = 10,
  parameter integer DATA_BITS  = 8,
  parameter integer SHIFT      = 7
)(
  input  wire                  clk,
  input  wire                  rst_n,

  input  wire                  valid_in,
  input  wire signed [11:0]    data_in_1,
  input  wire signed [11:0]    data_in_2,
  input  wire signed [11:0]    data_in_3,

  output reg  [11:0]           data_out,
  output reg                   valid_out_fc,

  input  wire [0:INPUT_NUM*OUTPUT_NUM*DATA_BITS-1] w_fc,
  input  wire [0:OUTPUT_NUM*DATA_BITS-1]           b_fc
);

  function integer CLOG2;
    input integer v;
    integer t;
    begin
      t=v-1; CLOG2=0; while(t>0) begin t=t>>1; CLOG2=CLOG2+1; end
    end
  endfunction

  // =========================================================================
  // ## [수정 1] 파이프라인 깊이(LAT)를 10으로 수정 ##
  // BRAM Address(1) + Latch(1) + Multiply(1) + Adder Tree(6) = 9 stages to get s1.
  // The final output stage is the 10th stage.
  // =========================================================================
  localparam integer INPUT_WIDTH = 16;
  localparam integer FILL_W      = CLOG2(INPUT_WIDTH);
  localparam integer OUT_W       = CLOG2(OUTPUT_NUM);
  localparam integer WB_DW       = INPUT_NUM*DATA_BITS;
  localparam integer WB_AW       = CLOG2(OUTPUT_NUM);
  localparam integer PROD_W      = 22; // 14x8
  localparam integer LAT         = 10;

  // Input Buffer & FSM States
  reg signed [13:0] buffer [0:INPUT_NUM-1];
  reg [FILL_W-1:0]  buf_idx;
  reg               state;
  reg [OUT_W-1:0]   out_idx;

  wire signed [13:0] d1 = data_in_1[11] ? {2'b11,data_in_1} : {2'b00,data_in_1};
  wire signed [13:0] d2 = data_in_2[11] ? {2'b11,data_in_2} : {2'b00,data_in_2};
  wire signed [13:0] d3 = data_in_3[11] ? {2'b11,data_in_3} : {2'b00,data_in_3};

  // Bias memory
  reg signed [DATA_BITS-1:0] bias_mem [0:OUTPUT_NUM-1];
  integer bi;
  always @(*) begin
    for (bi=0; bi<OUTPUT_NUM; bi=bi+1)
      bias_mem[bi] = b_fc[(DATA_BITS*bi)+:DATA_BITS];
  end

  // Weight BRAM interface
  wire [WB_DW-1:0] wb_r_data;
  reg  [WB_AW-1:0] wb_r_addr;
  reg              wb_w_en;
  reg  [WB_AW-1:0]  wb_w_addr;
  reg  [WB_DW-1:0]  wb_w_data;

  // BRAM Instantiation
  // Assuming a 'weight_bram' module with 1-clock synchronous read latency exists.
  weight_bram #(
    .DATA_WIDTH (WB_DW),
    .DEPTH      (OUTPUT_NUM),
    .ADDR_WIDTH (WB_AW)
  ) weight_bram_inst (
    .clk(clk), .rst_n(rst_n), .w_en(wb_w_en), .w_addr(wb_w_addr),
    .w_data(wb_w_data), .r_addr(wb_r_addr), .r_data(wb_r_data)
  );

// -------- Weight loading logic (FIXED: keep last write enabled) --------
reg           load_done;
reg [WB_AW:0] load_cnt;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    load_done <= 1'b0;
    load_cnt  <= { (WB_AW+1){1'b0} };
    wb_w_en   <= 1'b0;
    wb_w_addr <= {WB_AW{1'b0}};
    wb_w_data <= {WB_DW{1'b0}};
  end else if (!load_done) begin
    // write one row per cycle
    wb_w_en   <= 1'b1;
    wb_w_addr <= load_cnt[WB_AW-1:0];
    wb_w_data <= w_fc[(load_cnt*WB_DW) +: WB_DW];

    if (load_cnt == OUTPUT_NUM-1) begin
      // 이번 클럭은 마지막 행을 '진짜로' 쓰고,
      //    load_done만 올려둔다. wb_w_en은 이번 클럭 1로 유지!
      load_done <= 1'b1;
      // load_cnt는 여기서 더 올리지 않음
    end else begin
      load_cnt  <= load_cnt + 1'b1;
    end
  end else begin
    // 마지막 행을 쓴 '다음' 클럭에 w_en을 0으로
    wb_w_en <= 1'b0;
  end
end


  // Pipeline control
  wire fire_calc = valid_in & state & load_done;
  reg [LAT-1:0]   vpipe;
  reg [OUT_W-1:0] out_idx_pipe [0:LAT-1];
  integer pi;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      vpipe <= 0;
      for (pi=0; pi<LAT; pi=pi+1) out_idx_pipe[pi] <= 0;
    end else begin
      vpipe <= {vpipe[LAT-2:0], fire_calc};
      for (pi=LAT-1; pi>0; pi=pi-1) out_idx_pipe[pi] <= out_idx_pipe[pi-1];
      if (fire_calc) out_idx_pipe[0] <= out_idx;
    end
  end

  // Pipeline Stages
  always @(posedge clk or negedge rst_n) begin if (!rst_n) wb_r_addr <= 0; else if (fire_calc) wb_r_addr <= out_idx; end // Stage 1
  reg [WB_DW-1:0] weights_reg;
  always @(posedge clk or negedge rst_n) begin if (!rst_n) weights_reg <= 0; else if (vpipe[0]) weights_reg <= wb_r_data; end // Stage 2
  reg signed [PROD_W-1:0] prod [0:INPUT_NUM-1];
  integer mk;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) for (mk=0; mk<INPUT_NUM; mk=mk+1) prod[mk] <= 0;
  
    else if (vpipe[1]) begin
      for (mk=0; mk<INPUT_NUM; mk=mk+1)
        prod[mk] <= $signed(buffer[mk]) * $signed(weights_reg[((INPUT_NUM-1-mk)*DATA_BITS) +: DATA_BITS]);
    end
  end // Stage 3

  // Adder Tree (Stages 4-9)
  reg signed [PROD_W:0] s24 [0:23]; integer a0; always @(posedge clk or negedge rst_n) begin if (!rst_n) for (a0=0; a0<24; a0=a0+1) s24[a0] <= 0; else if (vpipe[2]) for (a0=0; a0<24; a0=a0+1) s24[a0] <= prod[2*a0] + prod[2*a0+1]; end
  reg signed [PROD_W+1:0] s12 [0:11]; integer a1; always @(posedge clk or negedge rst_n) begin if (!rst_n) for (a1=0; a1<12; a1=a1+1) s12[a1] <= 0; else if (vpipe[3]) for (a1=0; a1<12; a1=a1+1) s12[a1] <= s24[2*a1] + s24[2*a1+1]; end
  reg signed [PROD_W+2:0] s6 [0:5]; integer a2; always @(posedge clk or negedge rst_n) begin if (!rst_n) for (a2=0; a2<6; a2=a2+1) s6[a2] <= 0; else if (vpipe[4]) for (a2=0; a2<6; a2=a2+1) s6[a2] <= s12[2*a2] + s12[2*a2+1]; end
  reg signed [PROD_W+3:0] s3 [0:2]; integer a3; always @(posedge clk or negedge rst_n) begin if (!rst_n) for (a3=0; a3<3; a3=a3+1) s3[a3] <= 0; else if (vpipe[5]) begin s3[0]<=s6[0]+s6[1]; s3[1]<=s6[2]+s6[3]; s3[2]<=s6[4]+s6[5]; end end
  reg signed [PROD_W+4:0] s2 [0:1]; always @(posedge clk or negedge rst_n) begin if (!rst_n) begin s2[0]<=0; s2[1]<=0; end else if (vpipe[6]) begin s2[0]<=s3[0]+s3[1]; s2[1]<=s3[2]; end end
  reg signed [PROD_W+5:0] s1; always @(posedge clk or negedge rst_n) begin if (!rst_n) s1 <= 0; else if (vpipe[7]) s1 <= s2[0] + s2[1]; end

  // Final Output Stage (Stage 10)
  wire [OUT_W-1:0] out_idx_final = out_idx_pipe[LAT-1];
  wire signed [DATA_BITS-1:0] bias8 = bias_mem[out_idx_final];
  wire signed [31:0] sum_with_bias = $signed({{(32-(PROD_W+6)){s1[PROD_W+5]}}, s1}) + $signed({{(32-DATA_BITS){bias8[DATA_BITS-1]}}, bias8});


reg start_compute_pulse;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    start_compute_pulse <= 1'b0;
  end else begin
    start_compute_pulse <= 1'b0; // 기본은 0
    // FILL 상태에서 마지막 인덱스 + 가중치 로딩 완료면 다음 클럭부터 COMPUTE
    if (valid_in && !state && (buf_idx == INPUT_WIDTH-1) && load_done)
      start_compute_pulse <= 1'b1;
  end
end

wire        v_raw = vpipe[LAT-1];
wire [11:0] y_raw = sum_with_bias[SHIFT+11:SHIFT];

// 첫 결과 1회 마스킹 플래그
reg suppress_first_valid;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    data_out            <= 12'd0;
    valid_out_fc        <= 1'b0;
    suppress_first_valid<= 1'b1;   // 리셋 후 첫 결과는 마스킹
  end else begin
    // COMPUTE 새 라운드 시작 시 다시 1회 마스킹 무장
    if (start_compute_pulse)
      suppress_first_valid <= 1'b1;

    // 데이터는 평소대로: v_raw 뜨는 그 사이클에 갱신
    if (v_raw)
      data_out <= y_raw;

    // valid는 첫 결과만 1회 마스킹하고, 그 다음부터는 그대로 통과
    if (v_raw && suppress_first_valid) begin
      valid_out_fc        <= 1'b0;   // 첫 결과는 valid 내지 않음
      suppress_first_valid<= 1'b0;   // 마스킹 해제
    end else begin
      valid_out_fc <= v_raw;         // 그 다음부터는 정상 valid
    end
  end
end



  // Input Fill / Compute FSM
  integer ii;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= 1'b0; buf_idx <= 0; out_idx <= 0;
      for (ii=0; ii<INPUT_NUM; ii=ii+1) buffer[ii] <= 14'sd0;
    end else begin
      if (valid_in) begin
        if (!state) begin
          buffer[buf_idx] <= d1; buffer[INPUT_WIDTH+buf_idx] <= d2; buffer[INPUT_WIDTH*2+buf_idx] <= d3;
          if (buf_idx == INPUT_WIDTH-1) begin
            buf_idx <= 0;
            if (load_done) state <= 1'b1;
          end else begin
            buf_idx <= buf_idx + 1'b1;
          end
        end else begin
          if (out_idx == OUTPUT_NUM-1) out_idx <= 0;
          else                         out_idx <= out_idx + 1'b1;
        end
      end
    end
  end

endmodule
