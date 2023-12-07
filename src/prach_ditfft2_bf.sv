`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_ditfft2_bf #(
    parameter int NUM_FFT_LENGTH = 6
) (
    input var         clk,
    input var         rst_n,
    //
    input var  [17:0] din_dr,
    input var  [17:0] din_di,
    input var         din_dv,
    input var         sync_in,
    input var         din_dv_ahead,
    input var         sync_ahead_in,
    //
    output var [17:0] dout_dr,
    output var [17:0] dout_di,
    output var        dout_dv,
    output var        sync_out,
    output var        dout_dv_ahead,
    output var        sync_ahead_out
);

  // x0s, x1s -> x0s + x1s, x0s - x1s
  localparam int Delay = NUM_FFT_LENGTH / 2 + 1;
  localparam int CounterWidth = $clog2(NUM_FFT_LENGTH);

  logic        [CounterWidth-1:0] cnt;

  logic signed [            17:0] delay_in_dr;
  logic signed [            17:0] delay_in_di;

  logic signed [            17:0] delay_out_dr;
  logic signed [            17:0] delay_out_di;

  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      cnt <= 0;
    end else if (sync_in) begin
      cnt <= 1;
    end else if (din_dv) begin
      cnt <= cnt == NUM_FFT_LENGTH - 1 ? 0 : cnt + 1;
    end
  end

  always_comb begin
    if (cnt < NUM_FFT_LENGTH / 2) begin
      delay_in_dr = din_dr;
      delay_in_di = din_di;
    end else begin
      // x0s - x1s
      delay_in_dr = delay_out_dr - din_dr;
      delay_in_di = delay_out_di - din_di;
    end
  end

  always_ff @(posedge clk) begin
    if (cnt >= NUM_FFT_LENGTH / 2) begin
      // x1 + x2
      dout_dr <= delay_out_dr + din_dr;
      dout_di <= delay_out_di + din_di;
    end else begin
      dout_dr <= delay_out_dr;
      dout_di <= delay_out_di;
    end
  end

  delay #(
      .WIDTH(36),
      .DELAY(NUM_FFT_LENGTH / 2)
  ) u_delay_data (
      .clk  (clk),
      .rst_n(1'b1),
      .din  ({delay_in_di, delay_in_dr}),
      .dout ({delay_out_di, delay_out_dr})
  );

  delay #(
      .WIDTH(4),
      .DELAY(Delay)
  ) u_delay (
      .clk  (clk),
      .rst_n(1'b1),
      .din  ({sync_ahead_in, din_dv_ahead, sync_in, din_dv}),
      .dout ({sync_ahead_out, dout_dv_ahead, sync_out, dout_dv})
  );

endmodule

`default_nettype wire
