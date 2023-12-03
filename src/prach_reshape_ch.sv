`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_reshape_ch #(
    parameter int SIZE = 8
) (
    input var         clk,
    input var         rst_n,
    //
    input var  [15:0] din_dq1,
    input var  [15:0] din_dq2,
    input var         din_dv,
    input var  [ 7:0] din_chn,
    input var         sync_in,
    //
    output var [15:0] dout_dp1,
    output var [15:0] dout_dp2,
    output var        dout_dv,
    output var [ 7:0] dout_chn,
    output var        sync_out
);

  // x0s0s, x0s1s
  // x1s0s, x1s1s
  // =>
  // x0s0s, x1s0s
  // x0s1s, x1s1s

  localparam int Latency = SIZE + 1;
  localparam int CounterWidth = $clog2(SIZE) + 1;

  logic [CounterWidth-1:0] cnt;

  logic [            15:0] din_dq2_d;
  logic                    din_dv_d;
  logic                    sync_in_d;

  logic [            15:0] delay_in;
  logic [            15:0] delay_out;

  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      cnt <= '0;
    end else if (sync_in_d) begin
      cnt <= 1;
    end else if (cnt > 0 || din_dv_d) begin
      cnt <= cnt == SIZE - 1 ? 0 : cnt + 1;
    end
  end

  delay #(
      .WIDTH(18),
      .DELAY(SIZE)
  ) u_delay (
      .clk  (clk),
      .rst_n(1'b1),
      .din  ({sync_in, din_dv, din_dq2}),
      .dout ({sync_in_d, din_dv_d, din_dq2_d})
  );

  delay #(
      .WIDTH(16),
      .DELAY(SIZE)
  ) u_delay_dx (
      .clk  (clk),
      .rst_n(1'b1),
      .din  (delay_in),
      .dout (delay_out)
  );

  always_ff @(posedge clk) begin
    dout_dp1 <= delay_out;
  end

  always_ff @(posedge clk) begin
    if (cnt < SIZE) begin
      dout_dp2 <= din_dq1;
    end else begin
      dout_dp2 <= din_dq2_d;
    end
  end

  always_comb begin
    if (cnt < SIZE) begin
      delay_in = din_dq2_d;
    end else begin
      delay_in = din_dq1;
    end
  end

  always_ff @(posedge clk) begin
    dout_dv  <= din_dv_d;
    dout_chn <= cnt;
    sync_out <= sync_in_d;
  end

endmodule

`default_nettype wire
