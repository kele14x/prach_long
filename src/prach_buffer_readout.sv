`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_buffer_readout (
    input var         clk,
    input var         rst_n,
    // Buffer
    input var         done_req[3][8],
    output var        done_ack[3][8],
    //
    output var [10:0] rd_addr,
    output var        rd_en   [3][8],
    input var  [31:0] rd_data [3][8],
    // FFT
    output var [15:0] dout_dr,
    output var [15:0] dout_di,
    output var        dout_dv,
    output var        sync_out
);

  logic        busy;
  logic        done;

  logic        req        [24];
  logic        ack        [24];

  logic [31:0] rd_data_or;

  // First channel first arbiter
  generate
    for (genvar i = 0; i < 24; i++) begin : g_arb

      always_ff @(posedge clk) begin
        if (~rst_n) begin
          ack[i] <= 1'b0;
        end else if (busy && done) begin
          ack[i] <= 1'b0;
        end else if (busy) begin
          ack[i] <= ack[i];
        end else begin
          ack[i] <= 1'b1;
          for (int ii = 0; ii < i; ii++) begin
            if (req[ii]) ack[i] <= 1'b0;
          end
          if (~req[i]) ack[i] <= 1'b0;
        end
      end

    end
  endgenerate

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      busy <= 1'b0;
    end else if (busy) begin
      busy <= ~done;
    end else begin
      busy <= 1'b0;
      for (int i = 0; i < 24; i++) begin
        if (req[i]) busy <= 1'b1;
      end
    end
  end


  // Read

  assign done = (rd_addr == 1535);

  always_ff @(posedge clk) begin
    if (~busy) begin
      rd_addr <= '0;
    end else begin
      rd_addr <= rd_addr + 1;
    end
  end

  generate
    for (genvar cc = 0; cc < 3; cc++) begin : g_cc
      for (genvar ant = 0; ant < 8; ant++) begin : g_ant

        assign req[cc*8+ant] = done_req[cc][ant];

        assign done_ack[cc][ant] = ack[cc*8+ant];
        assign rd_en[cc][ant]    = ack[cc*8+ant];

      end
    end
  endgenerate

  always_comb begin
    rd_data_or = '0;
    for (int cc = 0; cc < 3; cc++) begin
      for (int ant = 0; ant < 8; ant++) begin
        rd_data_or = rd_data_or | rd_data[cc][ant];
      end
    end
  end

  always_ff @(posedge clk) begin
    dout_dr <= rd_data_or[15:0];
    dout_di <= rd_data_or[31:16];
  end

  delay #(
      .WIDTH(1),
      .DELAY(4)
  ) u_delay (
      .clk  (clk),
      .rst_n(1'b1),
      .din  (busy),
      .dout (dout_dv)
  );

  delay #(
      .WIDTH(1),
      .DELAY(4)
  ) u_delay_sync (
      .clk  (clk),
      .rst_n(1'b1),
      .din  (rd_addr == 0 && busy),
      .dout (sync_out)
  );

endmodule

`default_nettype wire
