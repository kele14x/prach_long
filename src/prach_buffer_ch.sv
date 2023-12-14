`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_buffer_ch #(
    parameter int CHANNEL = 0
) (
    input var          clk,
    input var          rst_n,
    //
    input var  [ 15:0] din_dr,
    input var  [ 15:0] din_di,
    input var  [  7:0] din_chn,
    input var  [ 15:0] din_sample_k,
    //
    output var [119:0] ap_hdr,
    output var         ap_req,
    input var          ap_ack,
    //
    input var  [ 11:0] rd_addr,
    input var          rd_en,
    output var [ 31:0] rd_data,
    // C-Plane
    input var          clk_eth_xran,
    input var          rst_eth_xran_n,
    //
    input var          c_valid,
    input var  [119:0] c_header,
    input var  [ 19:0] c_time_offset,
    input var  [  3:0] c_num_symbol
);

  // C-Plane message

  logic         c_valid_s;
  logic [119:0] c_header_s;
  logic [ 19:0] c_time_offset_s;
  logic [  3:0] c_num_symbol_s;

  logic         fifo_rd_req;
  logic         fifo_rd_empty;

  // Assume header FIFO will never full
  async_fifo #(
      .DATA_WIDTH_A           (144),
      .ADDR_WIDTH_A           (5),
      .DATA_WIDTH_B           (144),
      .ADDR_WIDTH_B           (5),
      .RDSYNC_DELAYPIPE       (2),
      .WRSYNC_DELAYPIPE       (2),
      .ENABLE_SHOWAHEAD       ("ON"),
      .UNDERFLOW_CHECKING     ("ON"),
      .OVERFLOW_CHECKING      ("ON"),
      .ADD_USEDW_MSB_BIT      ("ON"),
      .WRITE_ACLR_SYNCH       ("OFF"),
      .READ_ACLR_SYNCH        ("OFF"),
      .ADD_RAM_OUTPUT_REGISTER("ON"),
      .MAXIMUM_DEPTH          (32),
      .BYTE_EN_WIDTH          (18),
      .BYTE_SIZE              (8)
  ) u_cp_fifo (
      .aclr   (1'b0),
      //
      .wrclk  (clk_eth_xran),
      .wrreq  (c_valid),
      .byteena('1),
      .wrfull (),
      .data   ({c_header, c_time_offset, c_num_symbol}),
      .wrempty(),
      .wrusedw(),
      //
      .rdclk  (clk),
      .rdreq  (fifo_rd_req),
      .rdfull (),
      .rdusedw(),
      .rdempty(fifo_rd_empty),
      .q      ({c_header_s, c_time_offset_s, c_num_symbol_s})
  );

  assign c_valid_s = ~fifo_rd_empty;

  // RAM

  logic [31:0] mem        [4096];

  logic [11:0] wr_addr;
  logic        wr_en;
  logic [31:0] wr_data;

  logic [31:0] rd_data_r1;
  logic [31:0] rd_data_r2;
  logic [31:0] rd_data_r3;

  always_ff @(posedge clk) begin
    if (wr_en) begin
      mem[wr_addr] <= wr_data;
    end
  end

  always_ff @(posedge clk) begin
    if (rd_en) begin
      rd_data_r1 <= mem[rd_addr];
    end else begin
      rd_data_r1 <= '0;
    end
  end

  always_ff @(posedge clk) begin
    rd_data_r2 <= rd_data_r1;
    rd_data_r3 <= rd_data_r2;
  end

  assign rd_data = rd_data_r3;

  // Write FSM

  logic        wr_run;
  logic [11:0] wr_cnt;

  logic [15:0] r_seq_id;

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      wr_run <= 1'b0;
    end else if (c_valid_s && din_sample_k == c_time_offset_s[19:4]) begin
      wr_run <= 1'b1;
    end else if (wr_cnt == 1536 * c_num_symbol_s - 1 && din_chn == CHANNEL) begin
      wr_run <= 1'b0;
    end
  end

  assign fifo_rd_req = wr_cnt == 1536 * c_num_symbol_s - 1;

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      wr_cnt <= '0;
    end else if (wr_cnt == 1536 * c_num_symbol_s - 1 && din_chn == CHANNEL) begin
      wr_cnt <= '0;
    end else if (wr_run && din_chn == CHANNEL) begin
      wr_cnt <= wr_cnt + 1;
    end else if (wr_run) begin
      wr_cnt <= wr_cnt;
    end else begin
      wr_cnt <= '0;
    end
  end

  // Write

  always_ff @(posedge clk) begin
    wr_addr <= wr_cnt;
  end

  always_ff @(posedge clk) begin
    wr_en <= wr_run && (din_chn == CHANNEL);
  end

  always_ff @(posedge clk) begin
    wr_data <= {din_di, din_dr};
  end

  // After buffer the required samples, send request

  always_ff @(posedge clk) begin
    if (wr_cnt == 1536 * c_num_symbol_s - 1 && din_chn == CHANNEL) begin
      ap_hdr <= c_header_s;
    end
  end

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      ap_req <= 1'b0;
    end else if (wr_cnt == 1536 * c_num_symbol_s - 1 && din_chn == CHANNEL) begin
      ap_req <= 1'b1;
    end else if (ap_ack) begin
      ap_req <= 1'b0;
    end
  end

endmodule

`default_nettype wire
