`timescale 1 ns / 1 ps
//
`default_nettype none

module prach_c_plane (
    // !@ clk_eth_xran
    input var          clk,
    input var          rst_n,
    // C-Plane
    input var          avst_sink_c_valid,
    input var          avst_sink_c_startofpacket,
    input var          avst_sink_c_endofpacket,
    input var          avst_sink_c_error,
    //
    input var  [ 15:0] rx_c_rtc_id,
    input var  [ 15:0] rx_c_seq_id,
    //
    input var          rx_c_dataDirection,
    input var  [  2:0] rx_c_payloadVersion,
    input var  [  3:0] rx_c_filterIndex,
    input var  [  7:0] rx_c_frameId,
    input var  [  3:0] rx_c_subframeId,
    input var  [  5:0] rx_c_slotId,
    input var  [  5:0] rx_c_symbolId,
    input var  [  7:0] rx_c_sectionType,
    //
    input var  [ 15:0] rx_c_timeOffset,
    input var  [  7:0] rx_c_frameStructure,
    input var  [ 15:0] rx_c_cpLength,
    input var  [  7:0] rx_c_udCompHdr,
    //
    input var  [ 11:0] rx_c_sectionId,
    input var          rx_c_rb,
    input var          rx_c_symInc,
    input var  [  9:0] rx_c_startPrbc,
    input var  [  7:0] rx_c_numPrbc,
    input var  [ 11:0] rx_c_reMask,
    input var  [  3:0] rx_c_numSymbol,
    input var          rx_c_ef,
    input var  [ 14:0] rx_c_beamid,
    input var  [ 23:0] rx_c_freqOffset,
    // PRACH
    //------
    output var         c_valid                  [3][8],
    output var [ 16:0] c_frequency_offset,
    output var [ 19:0] c_time_offset,
    output var [  3:0] c_num_symbol,
    //
    output var [119:0] c_header
);

  import prach_pkg::*;

  logic        avst_sink_c_valid_d;
  //
  logic [15:0] rx_c_rtc_id_d;
  logic [15:0] rx_c_seq_id_d;
  //
  logic        rx_c_dataDirection_d;
  logic [ 2:0] rx_c_payloadVersion_d;
  logic [ 3:0] rx_c_filterIndex_d;
  logic [ 7:0] rx_c_frameId_d;
  logic [ 3:0] rx_c_subframeId_d;
  logic [ 5:0] rx_c_slotId_d;
  logic [ 5:0] rx_c_symbolId_d;
  logic [ 7:0] rx_c_sectionType_d;
  //
  logic [15:0] rx_c_timeOffset_d;
  logic [ 7:0] rx_c_frameStructure_d;
  logic [15:0] rx_c_cpLength_d;
  logic [ 7:0] rx_c_udCompHdr_d;
  //
  logic [11:0] rx_c_sectionId_d;
  logic        rx_c_rb_d;
  logic        rx_c_symInc_d;
  logic [ 9:0] rx_c_startPrbc_d;
  logic [ 7:0] rx_c_numPrbc_d;
  logic [11:0] rx_c_reMask_d;
  logic [ 3:0] rx_c_numSymbol_d;
  logic        rx_c_ef_d;
  logic [14:0] rx_c_beamid_d;
  logic [23:0] rx_c_freqOffset_d;

  logic        valid_prach_msg;

  always_ff @(posedge clk) begin
    avst_sink_c_valid_d <= avst_sink_c_valid;
    if (avst_sink_c_valid) begin
      rx_c_rtc_id_d         <= rx_c_rtc_id;
      rx_c_seq_id_d         <= rx_c_seq_id;
      //
      rx_c_dataDirection_d  <= rx_c_dataDirection;
      rx_c_payloadVersion_d <= rx_c_payloadVersion;
      rx_c_filterIndex_d    <= rx_c_filterIndex;
      rx_c_frameId_d        <= rx_c_frameId;
      rx_c_subframeId_d     <= rx_c_subframeId;
      rx_c_slotId_d         <= rx_c_slotId;
      rx_c_symbolId_d       <= rx_c_symbolId;
      rx_c_sectionType_d    <= rx_c_sectionType;
      //
      rx_c_timeOffset_d     <= rx_c_timeOffset;
      rx_c_frameStructure_d <= rx_c_frameStructure;
      rx_c_cpLength_d       <= rx_c_cpLength;
      rx_c_udCompHdr_d      <= rx_c_udCompHdr;
      //
      rx_c_sectionId_d      <= rx_c_sectionId;
      rx_c_rb_d             <= rx_c_rb;
      rx_c_symInc_d         <= rx_c_symInc;
      rx_c_startPrbc_d      <= rx_c_startPrbc;
      rx_c_numPrbc_d        <= rx_c_numPrbc;
      rx_c_reMask_d         <= rx_c_reMask;
      rx_c_numSymbol_d      <= rx_c_numSymbol;
      rx_c_ef_d             <= rx_c_ef;
      rx_c_beamid_d         <= rx_c_beamid;
      rx_c_freqOffset_d     <= rx_c_freqOffset;
    end
  end

  assign valid_prach_msg = (
        avst_sink_c_valid_d &&
        rx_c_dataDirection_d == 1'b0 &&
        rx_c_filterIndex_d == 4'b0001 &&
        rx_c_sectionType_d == 8'd3);

  always_ff @(posedge clk) begin
    if (valid_prach_msg) begin
      c_frequency_offset <= rx_c_freqOffset_d;
      c_time_offset <= rx_c_subframeId * 61440 +
          rx_c_symbolId * 4096 + rx_c_symbolId_d * 288 + ((rx_c_symbolId_d + 6) % 7) * 32 +
          + rx_c_timeOffset_d * 2 + rx_c_cpLength_d * 2;
      c_num_symbol <= rx_c_numSymbol_d;
      //
      c_header <= {
        16'b0,  // size
        rx_c_rtc_id_d,
        16'b0,  // seq_id
        //
        rx_c_dataDirection_d,
        rx_c_payloadVersion_d,
        rx_c_filterIndex_d,
        rx_c_frameId_d,
        rx_c_subframeId_d,
        rx_c_slotId_d,
        rx_c_symbolId_d,
        //
        rx_c_sectionId_d,
        rx_c_rb_d,
        rx_c_symInc_d,
        rx_c_startPrbc_d,
        rx_c_numPrbc_d,
        rx_c_udCompHdr_d
      };
    end
  end

  generate
    for (genvar cc = 0; cc < 3; cc++) begin : g_cc
      for (genvar ant = 0; ant < 8; ant++) begin : g_ant

        always_ff @(posedge clk) begin
          c_valid[cc][ant] <= valid_prach_msg && rx_c_rtc_id_d == PrachRtcId[cc][ant];
        end

      end
    end
  endgenerate

endmodule

`default_nettype wire
