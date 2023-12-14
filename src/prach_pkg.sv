`timescale 1 ns / 1 ps
//
`default_nettype none

package prach_pkg;

  // This is the RTC ID table for 8 Antenna x 3 CCs
  // 4'b DU_ID, 4'b Band_Sector, 4'b CC_ID, 4'b Ant_ID

  localparam logic [15:0] PrachRtcId[3][8] = '{
      '{16'h0000, 16'h0001, 16'h0002, 16'h0003, 16'h0100, 16'h0101, 16'h0102, 16'h0103},
      '{16'h0010, 16'h0011, 16'h0012, 16'h0013, 16'h0110, 16'h0111, 16'h0112, 16'h0113},
      '{16'h0020, 16'h0021, 16'h0022, 16'h0023, 16'h0120, 16'h0121, 16'h0122, 16'h0123}
  //  |                  N25                   |                 N66                   |
  //  |CC0: Ant0,     Ant1,     Ant2,     Ant3,|CC0:Ant0,     Ant1,     Ant2,     Ant3,|
  //  |CC1: Ant0,     Ant1,     Ant2,     Ant3,|CC1:Ant0,     Ant1,     Ant2,     Ant3,|
  //  |CC2: Ant0,     Ant1,     Ant2,     Ant3,|CC2:Ant0,     Ant1,     Ant2,     Ant3,|
  };

endpackage

`default_nettype wire
