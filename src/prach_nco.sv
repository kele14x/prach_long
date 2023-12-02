`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_nco (
    input var         clk,
    input var         rst_n,
    // Sync
    input var         din_dv,
    input var  [ 7:0] din_chn,
    input var         sync_in,
    //
    output var [15:0] dout_cos,
    output var [15:0] dout_sin,
    output var        dout_dv,
    output var [ 7:0] dout_chn,
    output var        sync_out,
    // CSR
    //---
    input var         clk_csr,
    input var         rst_csr_n,
    //
    input var  [15:0] ctrl_fcw [8]
);

  localparam int Latency = 4;

  localparam logic [15:0] Phase000 = 16'b0000000000000000;
  localparam logic [15:0] PhasePI4 = 16'b0001100000000000;
  localparam logic [15:0] PhasePi2 = 16'b0011000000000000;
  localparam logic [15:0] Phase1Pi = 16'b0110000000000000;
  localparam logic [15:0] Phase2Pi = 16'b1100000000000000;

  logic [ 2:0] chn;

  logic [15:0] sin_lut      [1024];

  logic [15:0] cos_addr_pre;
  logic [ 9:0] cos_addr;
  logic [ 9:0] sin_addr;

  logic [15:0] cos_r1;
  logic [15:0] sin_r1;

  logic [15:0] cos_r2;
  logic [15:0] sin_r2;

  logic [15:0] fcw          [   8];
  logic [15:0] acc          [   8];

  function automatic logic [15:0] phase_add(input logic [15:0] a, input logic [15:0] b);
    logic [16:0] phi;
    logic [ 2:0] phi_hi;
    phi = a + b;
    phi_hi = phi[16:14] % 3;
    return {phi_hi[1:0], phi[13:0]};
  endfunction

  // Channel counter

  always_ff @(posedge clk or negedge rst_n) begin
    if (din_dv) begin
      chn <= din_chn[2:0];
    end
  end

  // LUT, fi(1, 16, 14)

  initial begin
    for (int i = 0; i < 1024; i++) begin
      if (i < 768) begin
        sin_lut[i] = int'($sin(3.1415926535 * 2 * i / 768) * 2 ** 14);
      end else begin
        sin_lut[i] = '0;
      end
    end
  end

  assign cos_addr_pre = phase_add(acc[chn], PhasePi2);

  always_ff @(posedge clk) begin
    cos_addr <= cos_addr_pre[15:6];
    sin_addr <= acc[chn][15:6];
  end

  always_ff @(posedge clk) begin
    cos_r1 <= sin_lut[cos_addr];
    sin_r1 <= sin_lut[sin_addr];
  end

  always_ff @(posedge clk) begin
    cos_r2 <= cos_r1;
    sin_r2 <= sin_r1;
  end

  assign dout_cos = cos_r2;
  assign dout_sin = sin_r2;

  // Phase Accumulator

  generate
    for (genvar i = 0; i < 8; i++) begin : g_interleaved_channel

      always_ff @(posedge clk) begin
        fcw[i] <= ctrl_fcw[i];
      end

      always_ff @(posedge clk) begin
        if (sync_in) begin
          acc[i] <= '0;
        end else if (din_dv && din_chn == i) begin
          acc[i] <= phase_add(acc[i], fcw[i]);
        end
      end

    end
  endgenerate

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
