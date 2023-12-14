`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_fft #(
    parameter int HDR_WIDTH = 120
) (
    input var                  clk,
    input var                  rst_n,
    //
    input var  [         15:0] din_dr,
    input var  [         15:0] din_di,
    input var                  din_dv,
    input var                  sync_in,
    input var  [HDR_WIDTH-1:0] hdr_in,
    //
    output var [         15:0] dout_dr,
    output var [         15:0] dout_di,
    output var                 dout_dv,
    output var                 sync_out,
    output var [HDR_WIDTH-1:0] hdr_out
);

  localparam int NumFftStage = 10;
  localparam int NumFftPoints = 3 * 2 ** (NumFftStage - 1);

  localparam int Latency = 1582;

  logic signed [17:0] s0_dr        [NumFftStage+1];
  logic signed [17:0] s0_di        [NumFftStage+1];
  logic               s0_dv        [NumFftStage+1];
  logic               s0_sync      [NumFftStage+1];

  logic               s0_dv_ahead  [NumFftStage+1];
  logic               s0_sync_ahead[NumFftStage+1];

  assign s0_dr[0]         = $signed(din_dr);
  assign s0_di[0]         = $signed(din_di);
  assign s0_dv[0]         = din_dv;
  assign s0_sync[0]       = sync_in;

  assign s0_dv_ahead[0]   = din_dv;
  assign s0_sync_ahead[0] = sync_in;

  prach_ditfft3 u_ditfft3 (
      .clk     (clk),
      .rst_n   (rst_n),
      //
      .din_dr  (s0_dr[0]),
      .din_di  (s0_di[0]),
      .din_dv  (s0_dv[0]),
      .sync_in (s0_sync[0]),
      //
      .dout_dr (s0_dr[1]),
      .dout_di (s0_di[1]),
      .dout_dv (s0_dv[1]),
      .sync_out(s0_sync[1])
  );

  delay #(
      .WIDTH(2),
      .DELAY(6)
  ) u_delay_sync_ahead (
      .clk  (clk),
      .rst_n(1'b1),
      .din  ({s0_sync_ahead[0], s0_dv_ahead[0]}),
      .dout ({s0_sync_ahead[1], s0_dv_ahead[1]})
  );

  generate
    for (genvar i = 0; i < NumFftStage - 1; i++) begin : g_dit2

      prach_ditfft2 #(
          .NUM_FFT_LENGTH(3 * 2 ** (i + 1))
      ) u_ditfft2 (
          .clk           (clk),
          .rst_n         (rst_n),
          //
          .din_dr        (s0_dr[i+1]),
          .din_di        (s0_di[i+1]),
          .din_dv        (s0_dv[i+1]),
          .sync_in       (s0_sync[i+1]),
          //
          .din_dv_ahead  (s0_dv_ahead[i+1]),
          .sync_ahead_in (s0_sync_ahead[i+1]),
          //
          .dout_dr       (s0_dr[i+2]),
          .dout_di       (s0_di[i+2]),
          .dout_dv       (s0_dv[i+2]),
          .sync_out      (s0_sync[i+2]),
          //
          .dout_dv_ahead (s0_dv_ahead[i+2]),
          .sync_ahead_out(s0_sync_ahead[i+2])
      );

    end
  endgenerate

  assign dout_dr  = s0_dr[NumFftStage];
  assign dout_di  = s0_di[NumFftStage];
  assign dout_dv  = s0_dv[NumFftStage];
  assign sync_out = s0_sync[NumFftStage];

  // Assume header FIFO will never full
  sync_fifo #(
      .ADD_RAM_OUTPUT_REGISTER("ON"),
      .ALMOST_EMPTY_VALUE     (1),
      .ALMOST_FULL_VALUE      (1),
      .ENABLE_SCLR            ("OFF"),
      .ENABLE_ACLR            ("OFF"),
      .ALLOW_RWCYCLE_WHEN_FULL("OFF"),
      .ENABLE_SHOWAHEAD       ("ON"),
      .DATA_WIDTH             (HDR_WIDTH),
      .ADDR_WIDTH             (5),
      .OVERFLOW_CHECKING      ("ON"),
      .UNDERFLOW_CHECKING     ("ON"),
      .MAXIMUM_DEPTH          (32),
      .BYTE_SIZE              (8),
      .BYTE_EN_WIDTH          (HDR_WIDTH/8)
  ) u_hdr_fifo (
      .clock       (clk),
      .sclr        (1'b0),
      .aclr        (1'b0),
      .usedw       (  /* not used */),
      // Write
      .wrreq       (sync_in),
      .data        (hdr_in),
      .byteena     (1'b1),
      .full        (  /* not used */),
      .almost_full (  /* not used */),
      // Read
      .rdreq       (sync_out),
      .q           (hdr_out),
      .empty       (  /* not used */),
      .almost_empty(  /* not used */)
  );

endmodule

`default_nettype wire
