`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_mixer_ch (
    input var         clk,
    input var         rst_n,
    //
    input var  [15:0] din_dr,
    input var  [15:0] din_di,
    input var         din_dv,
    input var  [ 7:0] din_chn,
    input var         sync_in,
    //
    output var [15:0] dout_dr,
    output var [15:0] dout_di,
    output var        dout_dv,
    output var [ 7:0] dout_chn,
    output var        sync_out,
    // CSR
    //----
    input var         clk_csr,
    input var         rst_csr_n,
    //
    input var  [15:0] ctrl_fcw [8]
);

  parameter int Latency = 8;

  logic signed [15:0] cos;
  logic signed [15:0] sin;

  logic        [15:0] din_dr_d;
  logic        [15:0] din_di_d;

  delay #(
      .WIDTH(10),
      .DELAY(Latency)
  ) u_delay (
      .clk  (clk),
      .rst_n(1'b1),
      .din  ({sync_in, din_dv, din_chn}),
      .dout ({sync_out, dout_dv, dout_chn})
  );

  prach_nco u_nco (
      .clk      (clk),
      .rst_n    (rst_n),
      //
      .din_dv   (din_dv),
      .din_chn  (din_chn),
      .sync_in  (sync_in),
      //
      .dout_cos (cos),
      .dout_sin (sin),
      .dout_dv  (),
      .dout_chn (),
      .sync_out (),
      //
      .clk_csr  (clk_csr),
      .rst_csr_n(rst_csr_n),
      //
      .ctrl_fcw (ctrl_fcw)
  );

  delay #(
      .WIDTH(32),
      .DELAY(4)
  ) u_dq_delay (
      .clk  (clk),
      .rst_n(1'b1),
      .din  ({din_di, din_dr}),
      .dout ({din_di_d, din_dr_d})
  );

  cmult #(
      .A_WIDTH(16),
      .B_WIDTH(16),
      .P_WIDTH(16),
      .SHIFT  (14)
  ) u_cmult (
      .clk    (clk),
      .rst_n  (rst_n),
      //
      .ar     (din_dr_d),
      .ai     (din_di_d),
      //
      .br     (cos),
      .bi     (sin),
      //
      .pr     (dout_dr),
      .pi     (dout_di),
      //
      .err_ovf()
  );

endmodule

`default_nettype wire
