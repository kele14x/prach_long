`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_buffer_ch #(
    parameter int CHANNEL = 0
) (
    input var         clk,
    input var         rst_n,
    //
    input var  [15:0] din_dq,
    input var         din_dv,
    input var  [ 7:0] din_chn,
    input var  [15:0] din_sample_k,
    //
    output var        done_req,
    input var         done_ack,
    //
    input var  [10:0] rd_addr,
    input var         rd_en,
    output var [31:0] rd_data,
    //
    input var  [15:0] ctrl_time_offset
);

  logic [15:0] time_offset;

  logic [15:0] mem         [3072];

  logic [11:0] wr_addr;
  logic        wr_en;
  logic [15:0] wr_data;

  logic [31:0] rd_data_d1;
  logic [31:0] rd_data_d2;
  logic [31:0] rd_data_d3;


  // Sample counter

  always_ff @(posedge clk) begin
    time_offset <= ctrl_time_offset;
  end

  // Write

  always_ff @(posedge clk) begin
    wr_addr <= (din_sample_k - time_offset) * 2 + (din_chn == CHANNEL + 8);
  end

  always_ff @(posedge clk) begin
    if (din_sample_k >= time_offset && din_sample_k < time_offset + 1536) begin
      wr_en <= din_dv && (din_chn == CHANNEL || din_chn == CHANNEL + 8);
    end else begin
      wr_en <= 1'b0;
    end
  end

  always_ff @(posedge clk) begin
    wr_data <= din_dq;
  end

  // Mem write

  always_ff @(posedge clk) begin
    if (wr_en) begin
      mem[wr_addr] <= wr_data;
    end
  end

  // Mem read

  always_ff @(posedge clk) begin
    if (rd_en) begin
      rd_data_d1 <= {mem[{rd_addr, 1'b1}], mem[{rd_addr, 1'b0}]};
    end else begin
      rd_data_d1 <= '0;
    end
  end

  always_ff @(posedge clk) begin
    rd_data_d2 <= rd_data_d1;
    rd_data_d3 <= rd_data_d2;
  end

  assign rd_data = rd_data_d3;

  // 
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      done_req <= 1'b0;
    end else if (din_dv && din_chn == 0 && din_sample_k == time_offset + 1536) begin
      done_req <= 1'b1;
    end else if (done_ack) begin
      done_req <= 1'b0;
    end
  end

endmodule

`default_nettype wire
