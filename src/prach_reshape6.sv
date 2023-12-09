`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_reshape6 (
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
    output var [ 7:0] dout_chn,
    output var        sync_out
);

  prach_reshape_ch #(
      .SIZE(16)
  ) u_ch (
      .clk     (clk),
      .rst_n   (rst_n),
      //
      .din_dq1 (din_dq),
      .din_dq2 ('0),
      .din_dv  (din_dv),
      .din_chn (din_chn),
      .sync_in (sync_in),
      //
      .dout_dp1(dout_dr),
      .dout_dp2(dout_di),
      .dout_dv (dout_dv),
      .dout_chn(dout_chn),
      .sync_out(sync_out)
  );

endmodule

`default_nettype wire
