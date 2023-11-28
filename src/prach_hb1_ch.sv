`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_hb1_ch (
    input var         clk,
    input var         rst_n,
    //
    input var  [15:0] din_dp1,
    input var  [15:0] din_dp2,
    input var         din_dv,
    input var  [ 7:0] din_chn,
    input var         sync_in,
    //
    output var [15:0] dout_dq,
    output var        dout_dv,
    output var [ 7:0] dout_chn,
    output var        sync_out
);

  localparam int NumChannel = 16;
  localparam int NumUniqCoe = 2;
  localparam logic [17:0] UniqCoe[NumUniqCoe] = '{18'h3efda, 18'h09025};

  localparam int Latency = 6;
  localparam int Delay = 49;

  logic [15:0] xp1[Delay];
  logic [15:0] xp2[Delay];

  logic signed [15:0] ay1;
  logic signed [15:0] ay2;
  logic signed [15:0] ay3;

  logic signed [15:0] az1;
  logic signed [15:0] az2;
  logic signed [15:0] az3;

  logic signed [15:0] by1;
  logic signed [15:0] by2;
  logic signed [15:0] by3;

  logic signed [15:0] bz1;
  logic signed [15:0] bz2;
  logic signed [15:0] bz3;

  logic signed [16:0] asum;
  logic signed [34:0] amult;

  logic signed [16:0] bsum;
  logic signed [34:0] bmult;

  logic signed [35:0] result;
  logic signed [35:0] result2;

  // Data delay line

  always_ff @(posedge clk) begin
    xp1[0] <= din_dp1;
    for (int i = 1; i < Delay; i++) begin
      xp1[i] <= xp1[i-1];
    end
  end

  always_ff @(posedge clk) begin
    xp2[0] <= din_dp2;
    for (int i = 1; i < Delay; i++) begin
      xp2[i] <= xp2[i-1];
    end
  end

  // DSP1

  always_ff @(posedge clk) begin
    ay1 <= xp2[0];
    ay2 <= ay1;
    ay3 <= ay2;
    az1 <= xp2[48];
    az2 <= az1;
    az3 <= az2;
  end

  always_comb begin
    asum = ay3 + az3;
  end

  always_comb begin
    amult = asum * UniqCoe[0];
  end

  // DSP2

  always_ff @(posedge clk) begin
    by1 <= xp2[16];
    by2 <= by1;
    by3 <= by2;
    bz1 <= xp2[32];
    bz2 <= bz1;
    bz3 <= bz2;
  end

  always_comb begin
    bsum = by3 + bz3;
  end

  always_comb begin
    bmult = bsum * UniqCoe[1];
  end

  always_ff @(posedge clk) begin
    result <= amult + bmult;
  end

  always_ff @(posedge clk) begin
    result2 <= result + $signed({xp1[36], 16'b0});
  end

  assign dout_dq = result2[32:17];

  delay #(
      .WIDTH(10),
      .DELAY(Latency)
  ) u_delay (
      .clk  (clk),
      .rst_n(1'b1),
      .din  ({sync_in, din_dv, din_chn}),
      .dout ({sync_out, dout_dv, dout_chn})
  );

endmodule

`default_nettype wire