`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_top (
    // Clock & Reset
    //--------------
    input var          clk_dsp,
    input var          rst_dsp_n,
    //
    input var          sync_in,
    // Data from JESD
    //---------------
    input var          clk_jesd,
    input var          rst_jesd_n,
    //
    input var  [255:0] avst_sink_data,
    input var          avst_sink_valid,
    input var  [  7:0] avst_sink_channel,
    // Output
    //-------
    // !@ clk_eth_xran
    input var          clk_eth_xran,
    input var          clk_eth_xran_n,
    //
    output var [127:0] avst_source_data,
    output var         avst_source_valid,
    output var [ 15:0] avst_source_channel,
    output var         avst_source_startofpacket,
    output var         avst_source_endofpacket,
    input var          avst_source_ready,
    // CSR
    //----
    input var          clk_csr,
    input var          rst_csr_n,
    //
    input var          ctrl_rat                 [8][3],
    input var          ctrl_scsby15             [8][3],
    input var  [  3:0] ctrl_bwby10              [8][3],
    input var  [ 15:0] ctrl_fcw                 [8][3],
    input var  [ 15:0] ctrl_time_offset         [8][3]
);


  logic [15:0] mux_dout_dr       [3];
  logic [15:0] mux_dout_di       [3];
  logic        mux_dout_dv;
  logic [ 7:0] mux_dout_chn;
  logic        mux_sync_out;

  logic [15:0] ddc_dout_dr;
  logic [15:0] ddc_dout_di;
  logic        ddc_dout_dv;
  logic [ 7:0] ddc_dout_chn;
  logic        ddc_sync_out;

  logic [15:0] buffer_dout_dr;
  logic [15:0] buffer_dout_di;
  logic        buffer_dout_dv;
  logic        buffer_sync_out;

  logic [15:0] fft_dout_dr;
  logic [15:0] fft_dout_di;
  logic        fft_dout_dv;
  logic        fft_sync_out;

  logic [15:0] ctrl_fcw_s        [3] [8];
  logic [15:0] ctrl_time_offset_s[3] [8];

  prach_mux u_mux (
      // JESD
      .clk_jesd         (clk_jesd),
      .rst_jesd_n       (rst_jesd_n),
      //
      .avst_sink_data   (avst_sink_data),
      .avst_sink_valid  (avst_sink_valid),
      .avst_sink_channel(avst_sink_channel),
      // Output
      .clk_dsp          (clk_dsp),
      .rst_dsp_n        (rst_dsp_n),
      //
      .sync_in          (sync_in),
      //
      .dout_dr          (mux_dout_dr),
      .dout_di          (mux_dout_di),
      .dout_dv          (mux_dout_dv),
      .dout_chn         (mux_dout_chn),
      .sync_out         (mux_sync_out),
      // CSR
      .clk_csr          (clk_csr),
      .rst_csr_n        (rst_csr_n),
      //
      .ctrl_bwby10      (ctrl_bwby10)
  );

  generate
    for (genvar ant = 0; ant < 8; ant++) begin : g_ant
      for (genvar cc = 0; cc < 3; cc++) begin : g_cc

        assign ctrl_fcw_s[cc][ant] = ctrl_fcw[ant][cc];
        assign ctrl_time_offset_s[cc][ant] = ctrl_time_offset[ant][cc];

      end
    end
  endgenerate

  prach_ddc u_ddc (
      .clk      (clk_dsp),
      .rst_n    (rst_dsp_n),
      //
      .din_dr   (mux_dout_dr),
      .din_di   (mux_dout_di),
      .din_dv   (mux_dout_dv),
      .din_chn  (mux_dout_chn),
      .sync_in  (mux_sync_out),
      //
      .dout_dr  (ddc_dout_dr),
      .dout_di  (ddc_dout_di),
      .dout_dv  (ddc_dout_dv),
      .dout_chn (ddc_dout_chn),
      .sync_out (ddc_sync_out),
      //
      .clk_csr  (clk_csr),
      .rst_csr_n(rst_csr_n),
      //
      .ctrl_fcw (ctrl_fcw_s)
  );

  prach_buffer u_buffer (
      .clk             (clk_dsp),
      .rst_n           (rst_dsp_n),
      //
      .din_dr          (ddc_dout_dr),
      .din_di          (ddc_dout_di),
      .din_dv          (ddc_dout_dv),
      .din_chn         (ddc_dout_chn),
      .sync_in         (ddc_sync_out),
      //
      .dout_dr         (buffer_dout_dr),
      .dout_di         (buffer_dout_di),
      .dout_dv         (buffer_dout_dv),
      .sync_out        (buffer_sync_out),
      //
      .ctrl_time_offset(ctrl_time_offset_s)
  );

  prach_fft u_fft (
      .clk     (clk_dsp),
      .rst_n   (rst_dsp_n),
      //
      .din_dr  (buffer_dout_dr),
      .din_di  (buffer_dout_di),
      .din_dv  (buffer_dout_dv),
      .sync_in (buffer_sync_out),
      //
      .dout_dr (fft_dout_dr),
      .dout_di (fft_dout_di),
      .dout_dv (fft_dout_dv),
      .sync_out(fft_sync_out)
  );

endmodule

`default_nettype wire
