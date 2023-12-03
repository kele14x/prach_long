`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_reshape1 (
    input var         clk,
    input var         rst_n,
    //
    input var  [15:0] din_dr  [3],
    input var  [15:0] din_di  [3],
    input var         din_dv,
    input var  [ 7:0] din_chn,
    input var         sync_in,
    //
    output var [15:0] dout_dp1[3],
    output var [15:0] dout_dp2[3],
    output var        dout_dv,
    output var [ 7:0] dout_chn,
    output var        sync_out
);

  logic [ 3:0] cnt;

  logic [15:0] din_di_d  [3];
  logic        din_dv_d;
  logic        sync_in_d;

  logic [15:0] delay_in  [3];
  logic [15:0] delay_out [3];

  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      cnt <= '0;
    end else if (sync_in_d) begin
      cnt <= 1;
    end else if (cnt > 0 || din_dv_d) begin
      cnt <= cnt + 1;
    end
  end

  delay #(
      .WIDTH(2),
      .DELAY(8)
  ) u_delay_dv (
      .clk  (clk),
      .rst_n(1'b1),
      .din  ({sync_in, din_dv}),
      .dout ({sync_in_d, din_dv_d})
  );

  generate
    for (genvar i = 0; i < 3; i++) begin : g_ch

      delay #(
          .WIDTH(16),
          .DELAY(8)
      ) u_delay_di (
          .clk  (clk),
          .rst_n(1'b1),
          .din  (din_di[i]),
          .dout (din_di_d[i])
      );

      delay #(
          .WIDTH(16),
          .DELAY(8)
      ) u_delay_dx (
          .clk  (clk),
          .rst_n(1'b1),
          .din  (delay_in[i]),
          .dout (delay_out[i])
      );

      always_ff @(posedge clk) begin
        dout_dp1[i] <= delay_out[i];
      end

      always_ff @(posedge clk) begin
        if (cnt < 8) begin
          dout_dp2[i] <= din_dr[i];
        end else begin
          dout_dp2[i] <= din_di_d[i];
        end
      end

      always_comb begin
        if (cnt < 8) begin
          delay_in[i] = din_di_d[i];
        end else begin
          delay_in[i] = din_dr[i];
        end
      end

    end
  endgenerate

  always_ff @(posedge clk) begin
    dout_dv  <= din_dv_d;
    dout_chn <= cnt;
    sync_out <= sync_in_d;
  end

endmodule

`default_nettype wire
