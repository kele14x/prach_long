`timescale 1 ns / 1 ps
//
`default_nettype none

module tb_prach ();

  localparam int Tc = 1;
  localparam int TvLength = 30720;

  // DUT signals

  logic         clk_eth_xran;
  logic         clk_eth_xran_n;

  logic         clk_dsp;
  logic         rst_dsp_n;

  logic         clk_jesd;
  logic         rst_jesd_n;

  logic         clk_csr;
  logic         rst_csr_n;

  logic [255:0] avst_sink_data;
  logic         avst_sink_valid;
  logic [  7:0] avst_sink_channel;

  logic         sync_in;

  logic [127:0] avst_source_data;
  logic         avst_source_valid;
  logic [ 15:0] avst_source_channel;
  logic         avst_source_startofpacket;
  logic         avst_source_endofpacket;
  logic         avst_source_ready;

  logic         ctrl_rat                  [       8] [3];
  logic         ctrl_scsby15              [       8] [3];
  logic [  3:0] ctrl_bwby10               [       8] [3];
  logic [ 15:0] ctrl_fcw                  [       8] [3];
  logic [ 15:0] ctrl_time_offset          [       8] [3];

  // Test vector

  logic [ 31:0] tv_data                   [TvLength];

  int           fd;


  initial begin
    $readmemh("tv_ant0_cc0.txt", tv_data);

    for (int ant = 0; ant < 8; ant = ant + 1) begin
      for (int cc = 0; cc < 3; cc = cc + 1) begin
        ctrl_rat[ant][cc]         = 1'b0;  // LTE
        ctrl_scsby15[ant][cc]     = 1'b0;  // 15kHz SCS
        ctrl_bwby10[ant][cc]      = 4'd2;  // 20Mhz
        ctrl_fcw[ant][cc]         = (ant == 0 && cc == 0) ? 16'd6768 : 16'd0;
        ctrl_time_offset[ant][cc] = 16'd0;
      end
    end
  end

  task automatic reset();
    sync_in <= 1'b0;

    avst_sink_data    <= 256'd0;
    avst_sink_valid   <= 1'b0;
    avst_sink_channel <= 8'b0;
  endtask

  // Flush the pipeline for specific clock ticks
  task automatic flush_pipeline(input int n);
    for (int i = 0; i < n; i++) begin
      for (int ch = 0; ch < 4; ch++) begin
        avst_sink_data    <= 256'd0;
        avst_sink_valid   <= 1'b1;
        avst_sink_channel <= ch;
        @(posedge clk_jesd);
      end  // ch
    end  // i
  endtask

  task automatic send_tv();
    for (int i = 0; i < TvLength; i++) begin
      for (int ch = 0; ch < 4; ch++) begin
        for (int ant = 0; ant < 8; ant++) begin
          if (ant == 0 && ch == 0) begin
            avst_sink_data[255-32*ant-:32] <= tv_data[i];
          end else begin
            avst_sink_data[255-32*ant-:32] <= '0;
          end
        end  // ant
        avst_sink_valid   <= 1'b1;
        avst_sink_channel <= ch;
        @(posedge clk_jesd);
      end  // ch
    end  // i
    avst_sink_data    <= 256'b0;
    avst_sink_valid   <= 1'b0;
    avst_sink_channel <= 8'd0;
  endtask

  task automatic impulse();
    for (int i = 0; i < 1000; i++) begin
      for (int ch = 0; ch < 4; ch++) begin
        for (int ant = 0; ant < 8; ant++) begin
          if (i == 0 && ch == 0 && ant == 0) begin
            avst_sink_data[255-32*ant-:32] <= 16384;
          end else begin
            avst_sink_data[255-32*ant-:32] <= '0;
          end
        end  // ant
        avst_sink_valid   <= 1'b1;
        avst_sink_channel <= ch;
        @(posedge clk_jesd);
      end  // ch
    end  // i
    avst_sink_data    <= 256'b0;
    avst_sink_valid   <= 1'b0;
    avst_sink_channel <= 8'd0;
  endtask

  // Clock & Reset Generation

  // clk_eth_xran @ 402.83203125
  initial begin
    clk_eth_xran = 0;
    forever begin
      #(1.241) clk_eth_xran = ~clk_eth_xran;
    end
  end

  // clk_dsp @ 491.52 MHz
  initial begin
    clk_dsp = 0;
    forever begin
      #(1.017) clk_dsp = ~clk_dsp;
    end
  end

  // clk_dsp @ 122.88 MHz
  initial begin
    clk_jesd = 0;
    forever begin
      #(4.068) clk_jesd = ~clk_jesd;
    end
  end

  // clk_csr @ 122.88 MHz
  initial begin
    clk_csr = 0;
    forever begin
      #(4.068) clk_csr = ~clk_csr;
    end
  end

  initial begin
    clk_eth_xran_n = 0;
    #100;
    @(posedge clk_eth_xran);
    clk_eth_xran_n = 1;
  end

  initial begin
    rst_dsp_n = 0;
    #100;
    @(posedge clk_dsp);
    rst_dsp_n = 1;
  end

  initial begin
    rst_jesd_n = 0;
    #100;
    @(posedge clk_jesd);
    rst_jesd_n = 1;
  end

  initial begin
    rst_csr_n = 0;
    #100;
    @(posedge clk_csr);
    rst_csr_n = 1;
  end

  // Test Input
  //   chn |  0  |  1  |  2  |  3  |
  // Ant 0 | cc0 | cc1 | cc2 |  x  |
  // Ant 1 | cc0 | cc1 | cc2 |  x  |
  // Ant 2 | cc0 | cc1 | cc2 |  x  |
  // Ant 3 | cc0 | cc1 | cc2 |  x  |
  // Ant 4 | cc0 | cc1 | cc2 |  x  |
  // Ant 5 | cc0 | cc1 | cc2 |  x  |
  // Ant 6 | cc0 | cc1 | cc2 |  x  |
  // Ant 7 | cc0 | cc1 | cc2 |  x  |

  initial begin
    int t;

    $display("*** Simulation starts");
    reset();

    wait (rst_dsp_n);
    wait (rst_jesd_n);
    #100;

    case (Tc)
      0: begin
        flush_pipeline(1000);
        fork
          begin
            #260;
            @(posedge clk_dsp);
            sync_in <= 1'b1;
            @(posedge clk_dsp);
            sync_in <= 1'b0;
          end

          begin
            impulse();
          end
        join
      end

      1: begin
        flush_pipeline(1000);
        fork
          begin
            #260;
            @(posedge clk_dsp);
            sync_in <= 1'b1;
            @(posedge clk_dsp);
            sync_in <= 1'b0;
          end

          begin
            send_tv();
          end
        join
      end

      default: #100;
    endcase

    #1000;
    $finish();
  end

  initial begin
    fd = $fopen("test_out.txt", "w");
    if (!fd) begin
      $fatal("Could not open file");
      $finish();
    end

    // Wait sync
    forever begin
      @(posedge clk_dsp);
      if (DUT.u_fft.s0_sync[10]) break;
    end

    repeat(1536) begin
      if (DUT.u_fft.s0_dv[10] == 1) begin  // I
        $fwrite(fd, "%d, ", $signed(DUT.u_fft.s0_dr[10]));
        $fwrite(fd, "%d\n", $signed(DUT.u_fft.s0_di[10]));
      end
      @(posedge clk_dsp);
    end
  end

  final begin
    $fclose(fd);
    $display("*** Simulation ends");
  end

  // DUT

  prach_top DUT (.*);

endmodule

`default_nettype wire
