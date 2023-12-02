`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_mixer (
    input var         clk,
    input var         rst_n,
    //
    input var  [15:0] din_dr   [3],
    input var  [15:0] din_di   [3],
    input var         din_dv,
    input var  [ 7:0] din_chn,
    input var         sync_in,
    //
    output var [15:0] dout_dr  [3],
    output var [15:0] dout_di  [3],
    output var        dout_dv,
    output var [ 7:0] dout_chn,
    output var        sync_out,
    // CSR
    //----
    input var         clk_csr,
    input var         rst_csr_n,
    //
    input var  [15:0] ctrl_fcw [3][8]
);

  parameter int Latency = 8;

  logic signed [15:0] cos     [3];
  logic signed [15:0] sin     [3];

  logic        [15:0] din_dr_d[3];
  logic        [15:0] din_di_d[3];

  delay #(
      .WIDTH(10),
      .DELAY(Latency)
  ) u_delay (
      .clk  (clk),
      .rst_n(1'b1),
      .din  ({sync_in, din_dv, din_chn}),
      .dout ({sync_out, dout_dv, dout_chn})
  );

  generate
    for (genvar i = 0; i < 3; i++) begin : g_parallel_ch

      prach_nco u_nco (
          .clk      (clk),
          .rst_n    (rst_n),
          //
          .din_dv   (din_dv),
          .din_chn  (din_chn),
          .sync_in  (sync_in),
          //
          .dout_cos (cos[i]),
          .dout_sin (sin[i]),
          .dout_dv  (),
          .dout_chn (),
          .sync_out (),
          //
          .clk_csr  (clk_csr),
          .rst_csr_n(rst_csr_n),
          //
          .ctrl_fcw (ctrl_fcw[i])
      );

      delay #(
          .WIDTH(32),
          .DELAY(4)
      ) u_dq_delay (
          .clk  (clk),
          .rst_n(1'b1),
          .din  ({din_di[i], din_dr[i]}),
          .dout ({din_di_d[i], din_dr_d[i]})
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
          .ar     (din_dr_d[i]),
          .ai     (din_di_d[i]),
          //
          .br     (cos[i]),
          .bi     (sin[i]),
          //
          .pr     (dout_dr[i]),
          .pi     (dout_di[i]),
          //
          .err_ovf()
      );

    end
  endgenerate

endmodule

`default_nettype wire
