`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_hb2 (
    input var         clk,
    input var         rst_n,
    //
    input var  [15:0] din_dp1 [2],
    input var  [15:0] din_dp2 [2],
    input var         din_dv,
    input var  [ 7:0] din_chn,
    input var         sync_in,
    //
    output var [31:0] dout_dq,
    output var        dout_dv,
    output var [ 7:0] dout_chn,
    output var        sync_out
);

  logic       dout_dv_s;
  logic [7:0] dout_chn_s;
  logic       sync_out_s;

  generate
    for (genvar i = 0; i < 2; i++) begin : g_parallel_channel
      prach_hb2_ch i_ch (
          .clk     (clk),
          .rst_n   (rst_n),
          //
          .din_dp1 (din_dp1[i]),
          .din_dp2 (din_dp2[i]),
          .din_dv  (din_dv),
          .din_chn (din_chn),
          .sync_in (sync_in),
          //
          .dout_dq (dout_dq[i]),
          .dout_dv (dout_dv_s[i]),
          .dout_chn(dout_chn_s[i]),
          .sync_out(sync_out_s[i])
      );
    end
  endgenerate

  assign dout_dv  = dout_dv[0];
  assign dout_chn = dout_chn_s[0];
  assign sync_out = sync_out_s[0];

endmodule

`default_nettype wire
