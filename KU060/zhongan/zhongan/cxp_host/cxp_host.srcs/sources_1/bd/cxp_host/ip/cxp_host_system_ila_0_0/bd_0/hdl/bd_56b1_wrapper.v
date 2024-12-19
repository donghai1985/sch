//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_56b1_wrapper.bd
//Design : bd_56b1_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_56b1_wrapper
   (SLOT_0_HELLO_FPGA_CXP_DMA_dma_data,
    SLOT_0_HELLO_FPGA_CXP_DMA_dma_empty,
    SLOT_0_HELLO_FPGA_CXP_DMA_dma_eol,
    SLOT_0_HELLO_FPGA_CXP_DMA_dma_eop,
    SLOT_0_HELLO_FPGA_CXP_DMA_dma_ready,
    SLOT_0_HELLO_FPGA_CXP_DMA_dma_sol,
    SLOT_0_HELLO_FPGA_CXP_DMA_dma_sop,
    SLOT_0_HELLO_FPGA_CXP_DMA_dma_valid,
    SLOT_1_CXP_VIDEO_HEADER_video_dsize,
    SLOT_1_CXP_VIDEO_HEADER_video_image_hdr_valid,
    SLOT_1_CXP_VIDEO_HEADER_video_pixel_format,
    SLOT_1_CXP_VIDEO_HEADER_video_xsize,
    SLOT_1_CXP_VIDEO_HEADER_video_ysize,
    clk,
    probe0,
    probe1,
    probe2,
    probe3);
  input [127:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_data;
  input [3:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_empty;
  input [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_eol;
  input [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_eop;
  input [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_ready;
  input [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_sol;
  input [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_sop;
  input [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_valid;
  input [23:0]SLOT_1_CXP_VIDEO_HEADER_video_dsize;
  input [0:0]SLOT_1_CXP_VIDEO_HEADER_video_image_hdr_valid;
  input [15:0]SLOT_1_CXP_VIDEO_HEADER_video_pixel_format;
  input [23:0]SLOT_1_CXP_VIDEO_HEADER_video_xsize;
  input [23:0]SLOT_1_CXP_VIDEO_HEADER_video_ysize;
  input clk;
  input [3:0]probe0;
  input [3:0]probe1;
  input [3:0]probe2;
  input [0:0]probe3;

  wire [127:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_data;
  wire [3:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_empty;
  wire [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_eol;
  wire [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_eop;
  wire [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_ready;
  wire [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_sol;
  wire [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_sop;
  wire [0:0]SLOT_0_HELLO_FPGA_CXP_DMA_dma_valid;
  wire [23:0]SLOT_1_CXP_VIDEO_HEADER_video_dsize;
  wire [0:0]SLOT_1_CXP_VIDEO_HEADER_video_image_hdr_valid;
  wire [15:0]SLOT_1_CXP_VIDEO_HEADER_video_pixel_format;
  wire [23:0]SLOT_1_CXP_VIDEO_HEADER_video_xsize;
  wire [23:0]SLOT_1_CXP_VIDEO_HEADER_video_ysize;
  wire clk;
  wire [3:0]probe0;
  wire [3:0]probe1;
  wire [3:0]probe2;
  wire [0:0]probe3;

  bd_56b1 bd_56b1_i
       (.SLOT_0_HELLO_FPGA_CXP_DMA_dma_data(SLOT_0_HELLO_FPGA_CXP_DMA_dma_data),
        .SLOT_0_HELLO_FPGA_CXP_DMA_dma_empty(SLOT_0_HELLO_FPGA_CXP_DMA_dma_empty),
        .SLOT_0_HELLO_FPGA_CXP_DMA_dma_eol(SLOT_0_HELLO_FPGA_CXP_DMA_dma_eol),
        .SLOT_0_HELLO_FPGA_CXP_DMA_dma_eop(SLOT_0_HELLO_FPGA_CXP_DMA_dma_eop),
        .SLOT_0_HELLO_FPGA_CXP_DMA_dma_ready(SLOT_0_HELLO_FPGA_CXP_DMA_dma_ready),
        .SLOT_0_HELLO_FPGA_CXP_DMA_dma_sol(SLOT_0_HELLO_FPGA_CXP_DMA_dma_sol),
        .SLOT_0_HELLO_FPGA_CXP_DMA_dma_sop(SLOT_0_HELLO_FPGA_CXP_DMA_dma_sop),
        .SLOT_0_HELLO_FPGA_CXP_DMA_dma_valid(SLOT_0_HELLO_FPGA_CXP_DMA_dma_valid),
        .SLOT_1_CXP_VIDEO_HEADER_video_dsize(SLOT_1_CXP_VIDEO_HEADER_video_dsize),
        .SLOT_1_CXP_VIDEO_HEADER_video_image_hdr_valid(SLOT_1_CXP_VIDEO_HEADER_video_image_hdr_valid),
        .SLOT_1_CXP_VIDEO_HEADER_video_pixel_format(SLOT_1_CXP_VIDEO_HEADER_video_pixel_format),
        .SLOT_1_CXP_VIDEO_HEADER_video_xsize(SLOT_1_CXP_VIDEO_HEADER_video_xsize),
        .SLOT_1_CXP_VIDEO_HEADER_video_ysize(SLOT_1_CXP_VIDEO_HEADER_video_ysize),
        .clk(clk),
        .probe0(probe0),
        .probe1(probe1),
        .probe2(probe2),
        .probe3(probe3));
endmodule
