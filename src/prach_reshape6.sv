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

  logic [17:0] buffer[64];

  logic [ 7:0] cnt;

  logic [ 5:0] addrr;
  logic [ 5:0] addri;

  initial begin
    for (int i = 0; i < 64; i++) begin
      buffer[i] <= '0;
    end
  end

  always_ff @(posedge clk) begin
    if (din_chn < 48) begin
      buffer[din_chn] <= {sync_in, din_dv, din_dq};
    end
  end

  always_ff @(posedge clk) begin
    if (din_chn == 24) begin
      cnt <= 0;
    end else begin
      cnt <= cnt + 1;
    end
  end

  always_ff @(posedge clk) begin
    if (cnt < 24) begin
      {sync_out, dout_dv, dout_dr} <= buffer[addrr];
    end else begin
      {sync_out, dout_dv, dout_dr} <= '0;
    end
  end

  always_ff @(posedge clk) begin
    if (cnt < 24) begin
      dout_di <= buffer[addri][15:0];
    end else begin
      dout_di <= '0;
    end
  end

  assign addrr = {cnt[4:3], 1'b0, cnt[2:0]};
  assign addri = {cnt[4:3], 1'b1, cnt[2:0]};

  always_ff @(posedge clk) begin
    dout_chn <= cnt;
  end

endmodule

`default_nettype wire
