`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_buffer (
    input var         clk,
    input var         rst_n,
    //
    input var  [15:0] din_dq,
    input var         din_dv,
    input var  [ 7:0] din_chn,
    input var         sync_in,
    //
    output var [15:0] dout_dr,
    output var [15:0] dout_di,
    output var        dout_dv,
    output var        sync_out,
    //
    input var  [15:0] ctrl_time_offset[3][8]
);

  logic [15:0] din_dq_d;
  logic        din_dv_d;
  logic [ 7:0] din_chn_d;

  logic [15:0] din_sample_k;

  logic        done_req     [3][8];
  logic        done_ack     [3][8];

  logic [10:0] rd_addr;
  logic        rd_en        [3][8];
  logic [31:0] rd_data      [3][8];


  always_ff @(posedge clk) begin
    din_dq_d  <= din_dq;
    din_dv_d  <= din_dv;
    din_chn_d <= din_chn;
  end

  always_ff @(posedge clk) begin
    if (sync_in) begin
      din_sample_k <= '0;
    end else if (din_chn == 0) begin
      din_sample_k <= din_sample_k + 1;
    end
  end

  generate
    for (genvar cc = 0; cc < 3; cc++) begin : g_cc
      for (genvar ant = 0; ant < 8; ant++) begin : g_ant

        prach_buffer_ch #(
            .CHANNEL(cc * 16 + ant)
        ) u_ch (
            .clk             (clk),
            .rst_n           (rst_n),
            //
            .din_dq          (din_dq_d),
            .din_dv          (din_dv_d),
            .din_chn         (din_chn_d),
            .din_sample_k    (din_sample_k),
            // Buffer
            .done_req        (done_req[cc][ant]),
            .done_ack        (done_ack[cc][ant]),
            //
            .rd_addr         (rd_addr),
            .rd_en           (rd_en[cc][ant]),
            .rd_data         (rd_data[cc][ant]),
            //
            .ctrl_time_offset(ctrl_time_offset[cc][ant])
        );

      end
    end
  endgenerate

  prach_buffer_readout u_readout (
      .clk     (clk),
      .rst_n   (rst_n),
      // Buffer
      .done_req(done_req),
      .done_ack(done_ack),
      //
      .rd_addr (rd_addr),
      .rd_en   (rd_en),
      .rd_data (rd_data),
      // FFT
      .dout_dr (dout_dr),
      .dout_di (dout_di),
      .dout_dv (dout_dv),
      .sync_out(sync_out)
  );

endmodule

`default_nettype wire
