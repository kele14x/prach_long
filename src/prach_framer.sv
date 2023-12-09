`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_framer (
    input var          clk_dsp,
    input var          rst_dsp_n,
    //
    input var  [ 15:0] din_dr,
    input var  [ 15:0] din_di,
    input var          din_dv,
    input var  [  7:0] din_chn,
    input var          sync_in,
    // ORAN
    input var          clk_eth_xran,
    input var          clk_eth_xran_n,
    //
    output var [127:0] avst_source_u_data,
    output var         avst_source_u_valid,
    output var         avst_source_u_startofpacket,
    output var         avst_source_u_endofpacket,
    input var          avst_source_u_ready,
    //
    output var [ 15:0] tx_u_size,
    output var [ 15:0] tx_u_pc_id,
    output var [ 15:0] tx_u_seq_id,
    output var         tx_u_dataDirection,
    output var [  3:0] tx_u_filterIndex,
    output var [  7:0] tx_u_frameId,
    output var [  3:0] tx_u_subframeId,
    output var [  5:0] tx_u_slotID,
    output var [  5:0] tx_u_symbolid,
    output var [ 11:0] tx_u_sectionId,
    output var         tx_u_rb,
    output var [  9:0] tx_u_startPrb,
    output var [  7:0] tx_u_numPrb,
    output var [  7:0] tx_u_udCompHdr
);

  logic [31:0] buffer   [1024];

  logic [ 9:0] wr_addr;
  logic        wr_en;
  logic [31:0] wr_data;

  logic [ 9:0] rd_addr;
  logic        rd_en1;
  logic        rd_en2;
  logic        rd_en3;
  logic [31:0] rd_data1;
  logic [31:0] rd_data2;
  logic [31:0] rd_data3;


  // Write

  always_ff @(posedge clk_dsp) begin
    if (sync_in) begin
      wr_addr <= '0;
    end else if (din_dv) begin
      wr_addr <= wr_addr + 1;
    end
  end

  always_ff @(posedge clk_dsp) begin
    wr_en <= din_dv && wr_addr < 839;
  end

  always_ff @(posedge clk_dsp) begin
    wr_data <= {din_di, din_dr};
  end


  // Buffer

  always_ff @(posedge clk_dsp) begin
    if (wr_en) begin
      buffer[wr_addr] <= wr_data;
    end
  end

  always_ff @(posedge clk_eth_xran) begin
    if (rd_en1) begin
      rd_data1 <= buffer[rd_addr];
    end
  end

  always_ff @(posedge clk_eth_xran) begin
    if (rd_en2) begin
      rd_data2 <= rd_data1;
    end
  end

  always_ff @(posedge clk_eth_xran) begin
    if (rd_en3) begin
      rd_data3 <= rd_data2;
    end
  end

  // Read

  always_ff @(posedge clk_eth_xran) begin
    if (wr_done_s) begin
      rd_en <= 1'b1;
    end else if (rd_addr == 838) begin
      wr_en <= 1'b0;
    end
  end

  always_ff @(posedge clk_eth_xran) begin
    if (~rd_en) begin
      rd_addr <= '0;
    end else begin
      rd_addr <= rd_addr + 1;
    end
  end

  always_comb begin
    for (int i = 0; i < 4; i++) begin
      avst_source_data = rd_data3[i*16+15-:16];
    end
  end


endmodule

`default_nettype wire
