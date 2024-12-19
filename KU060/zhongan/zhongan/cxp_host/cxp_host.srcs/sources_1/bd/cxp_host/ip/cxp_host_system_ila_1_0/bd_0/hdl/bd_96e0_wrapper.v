//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_96e0_wrapper.bd
//Design : bd_96e0_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_96e0_wrapper
   (SLOT_0_GPIO_tri_o,
    SLOT_1_AXI_araddr,
    SLOT_1_AXI_arprot,
    SLOT_1_AXI_arready,
    SLOT_1_AXI_arvalid,
    SLOT_1_AXI_awaddr,
    SLOT_1_AXI_awprot,
    SLOT_1_AXI_awready,
    SLOT_1_AXI_awvalid,
    SLOT_1_AXI_bready,
    SLOT_1_AXI_bresp,
    SLOT_1_AXI_bvalid,
    SLOT_1_AXI_rdata,
    SLOT_1_AXI_rready,
    SLOT_1_AXI_rresp,
    SLOT_1_AXI_rvalid,
    SLOT_1_AXI_wdata,
    SLOT_1_AXI_wready,
    SLOT_1_AXI_wstrb,
    SLOT_1_AXI_wvalid,
    SLOT_2_HELLO_FPGA_CXP_CONTROL_control_address,
    SLOT_2_HELLO_FPGA_CXP_CONTROL_control_burstcount,
    SLOT_2_HELLO_FPGA_CXP_CONTROL_control_byteenable,
    SLOT_2_HELLO_FPGA_CXP_CONTROL_control_read,
    SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdata,
    SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdatavalid,
    SLOT_2_HELLO_FPGA_CXP_CONTROL_control_waitrequest,
    SLOT_2_HELLO_FPGA_CXP_CONTROL_control_write,
    SLOT_2_HELLO_FPGA_CXP_CONTROL_control_writedata,
    clk,
    probe0,
    resetn);
  input SLOT_0_GPIO_tri_o;
  input [31:0]SLOT_1_AXI_araddr;
  input [2:0]SLOT_1_AXI_arprot;
  input SLOT_1_AXI_arready;
  input SLOT_1_AXI_arvalid;
  input [31:0]SLOT_1_AXI_awaddr;
  input [2:0]SLOT_1_AXI_awprot;
  input SLOT_1_AXI_awready;
  input SLOT_1_AXI_awvalid;
  input SLOT_1_AXI_bready;
  input [1:0]SLOT_1_AXI_bresp;
  input SLOT_1_AXI_bvalid;
  input [31:0]SLOT_1_AXI_rdata;
  input SLOT_1_AXI_rready;
  input [1:0]SLOT_1_AXI_rresp;
  input SLOT_1_AXI_rvalid;
  input [31:0]SLOT_1_AXI_wdata;
  input SLOT_1_AXI_wready;
  input [3:0]SLOT_1_AXI_wstrb;
  input SLOT_1_AXI_wvalid;
  input [15:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_address;
  input [0:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_burstcount;
  input [3:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_byteenable;
  input SLOT_2_HELLO_FPGA_CXP_CONTROL_control_read;
  input [31:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdata;
  input SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdatavalid;
  input SLOT_2_HELLO_FPGA_CXP_CONTROL_control_waitrequest;
  input SLOT_2_HELLO_FPGA_CXP_CONTROL_control_write;
  input [31:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_writedata;
  input clk;
  input [3:0]probe0;
  input resetn;

  wire SLOT_0_GPIO_tri_o;
  wire [31:0]SLOT_1_AXI_araddr;
  wire [2:0]SLOT_1_AXI_arprot;
  wire SLOT_1_AXI_arready;
  wire SLOT_1_AXI_arvalid;
  wire [31:0]SLOT_1_AXI_awaddr;
  wire [2:0]SLOT_1_AXI_awprot;
  wire SLOT_1_AXI_awready;
  wire SLOT_1_AXI_awvalid;
  wire SLOT_1_AXI_bready;
  wire [1:0]SLOT_1_AXI_bresp;
  wire SLOT_1_AXI_bvalid;
  wire [31:0]SLOT_1_AXI_rdata;
  wire SLOT_1_AXI_rready;
  wire [1:0]SLOT_1_AXI_rresp;
  wire SLOT_1_AXI_rvalid;
  wire [31:0]SLOT_1_AXI_wdata;
  wire SLOT_1_AXI_wready;
  wire [3:0]SLOT_1_AXI_wstrb;
  wire SLOT_1_AXI_wvalid;
  wire [15:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_address;
  wire [0:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_burstcount;
  wire [3:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_byteenable;
  wire SLOT_2_HELLO_FPGA_CXP_CONTROL_control_read;
  wire [31:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdata;
  wire SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdatavalid;
  wire SLOT_2_HELLO_FPGA_CXP_CONTROL_control_waitrequest;
  wire SLOT_2_HELLO_FPGA_CXP_CONTROL_control_write;
  wire [31:0]SLOT_2_HELLO_FPGA_CXP_CONTROL_control_writedata;
  wire clk;
  wire [3:0]probe0;
  wire resetn;

  bd_96e0 bd_96e0_i
       (.SLOT_0_GPIO_tri_o(SLOT_0_GPIO_tri_o),
        .SLOT_1_AXI_araddr(SLOT_1_AXI_araddr),
        .SLOT_1_AXI_arprot(SLOT_1_AXI_arprot),
        .SLOT_1_AXI_arready(SLOT_1_AXI_arready),
        .SLOT_1_AXI_arvalid(SLOT_1_AXI_arvalid),
        .SLOT_1_AXI_awaddr(SLOT_1_AXI_awaddr),
        .SLOT_1_AXI_awprot(SLOT_1_AXI_awprot),
        .SLOT_1_AXI_awready(SLOT_1_AXI_awready),
        .SLOT_1_AXI_awvalid(SLOT_1_AXI_awvalid),
        .SLOT_1_AXI_bready(SLOT_1_AXI_bready),
        .SLOT_1_AXI_bresp(SLOT_1_AXI_bresp),
        .SLOT_1_AXI_bvalid(SLOT_1_AXI_bvalid),
        .SLOT_1_AXI_rdata(SLOT_1_AXI_rdata),
        .SLOT_1_AXI_rready(SLOT_1_AXI_rready),
        .SLOT_1_AXI_rresp(SLOT_1_AXI_rresp),
        .SLOT_1_AXI_rvalid(SLOT_1_AXI_rvalid),
        .SLOT_1_AXI_wdata(SLOT_1_AXI_wdata),
        .SLOT_1_AXI_wready(SLOT_1_AXI_wready),
        .SLOT_1_AXI_wstrb(SLOT_1_AXI_wstrb),
        .SLOT_1_AXI_wvalid(SLOT_1_AXI_wvalid),
        .SLOT_2_HELLO_FPGA_CXP_CONTROL_control_address(SLOT_2_HELLO_FPGA_CXP_CONTROL_control_address),
        .SLOT_2_HELLO_FPGA_CXP_CONTROL_control_burstcount(SLOT_2_HELLO_FPGA_CXP_CONTROL_control_burstcount),
        .SLOT_2_HELLO_FPGA_CXP_CONTROL_control_byteenable(SLOT_2_HELLO_FPGA_CXP_CONTROL_control_byteenable),
        .SLOT_2_HELLO_FPGA_CXP_CONTROL_control_read(SLOT_2_HELLO_FPGA_CXP_CONTROL_control_read),
        .SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdata(SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdata),
        .SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdatavalid(SLOT_2_HELLO_FPGA_CXP_CONTROL_control_readdatavalid),
        .SLOT_2_HELLO_FPGA_CXP_CONTROL_control_waitrequest(SLOT_2_HELLO_FPGA_CXP_CONTROL_control_waitrequest),
        .SLOT_2_HELLO_FPGA_CXP_CONTROL_control_write(SLOT_2_HELLO_FPGA_CXP_CONTROL_control_write),
        .SLOT_2_HELLO_FPGA_CXP_CONTROL_control_writedata(SLOT_2_HELLO_FPGA_CXP_CONTROL_control_writedata),
        .clk(clk),
        .probe0(probe0),
        .resetn(resetn));
endmodule
