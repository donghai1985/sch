`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/04 16:01:41
// Design Name: 
// Module Name: axi_bram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_bram(
	input wire        s_axi_aclk,         // AXI时钟 [[11,14]]
    input wire        s_axi_aresetn,      // AXI复位（低有效）[[11,14]]
    
    // AXI写地址通道
    input wire [15:0] s_axi_awaddr,       // 写地址 [[14,22]]
    input wire [7:0]  s_axi_awlen,        // 突发长度 [[22]]
    input wire [2:0]  s_axi_awsize,       // 突发大小 [[22]]
    input wire [1:0]  s_axi_awburst,      // 突发类型 [[22]]
    input wire        s_axi_awlock,       // 原子锁 [[22]]
    input wire [3:0]  s_axi_awcache,      // 缓存类型 [[22]]
    input wire [2:0]  s_axi_awprot,       // 保护类型 [[14]]
    input wire        s_axi_awvalid,      // 写地址有效 [[11]]
    output wire       s_axi_awready,      // 写地址就绪 [[11]]
    
    // AXI写数据通道
    input wire [511:0] s_axi_wdata,       // 写数据 [[22]]
    input wire [63:0]  s_axi_wstrb,       // 写字节选通 [[11]]
    input wire         s_axi_wlast,       // 突发末数据 [[22]]
    input wire         s_axi_wvalid,      // 写数据有效 [[11]]
    output wire        s_axi_wready,      // 写数据就绪 [[11]]
    
    // AXI写响应通道
    output wire [1:0]  s_axi_bresp,       // 写响应状态 [[11]]
    output wire        s_axi_bvalid,      // 写响应有效 [[11]]
    input wire         s_axi_bready,       // 写响应就绪 [[11]]
    
    // AXI读地址通道
    input wire [15:0] s_axi_araddr,       // 读地址 [[14,22]]
    input wire [7:0]  s_axi_arlen,        // 突发长度 [[22]]
    input wire [2:0]  s_axi_arsize,       // 突发大小 [[22]]
    input wire [1:0]  s_axi_arburst,      // 突发类型 [[22]]
    input wire        s_axi_arlock,       // 原子锁 [[22]]
    input wire [3:0]  s_axi_arcache,      // 缓存类型 [[22]]
    input wire [2:0]  s_axi_arprot,       // 保护类型 [[14]]
    input wire        s_axi_arvalid,      // 读地址有效 [[11]]
    output wire       s_axi_arready,      // 读地址就绪 [[11]]
    
    // AXI读数据通道
    output wire [511:0] s_axi_rdata,      // 读数据 [[22]]
    output wire [1:0]   s_axi_rresp,      // 读响应状态 [[11]]
    output wire         s_axi_rlast,      // 突发末数据 [[22]]
    output wire         s_axi_rvalid,     // 读数据有效 [[11]]
    input wire          s_axi_rready     // 读数据就绪 [[11]]
    
    /*
    // BRAM接口
    output wire        bram_rst_a,        // BRAM复位 [[5]]
    output wire        bram_clk_a,        // BRAM时钟 [[5]]
    output wire        bram_en_a,         // BRAM使能 [[5]]
    output wire [63:0] bram_we_a,         // BRAM写使能 [[5]]
    output wire [15:0] bram_addr_a,       // BRAM地址 [[5]]
    output wire [511:0] bram_wrdata_a,    // BRAM写数据 [[5]]
    input wire [511:0]  bram_rddata_a     // BRAM读数据 [[5]]
    */
);
wire        	bram_rst_a;        // BRAM复位 [[5]]
wire        	bram_clk_a;        // BRAM时钟 [[5]]
wire        	bram_en_a;         // BRAM使能 [[5]]
wire [63:0] 	bram_we_a;         // BRAM写使能 [[5]]
wire [15:0] 	bram_addr_a;       // BRAM地址 [[5]]
wire [511:0] 	bram_wrdata_a;    // BRAM写数据 [[5]]
wire [511:0]  	bram_rddata_a;     // BRAM读数据 [[5]]

qp_axi_bram_ctrl qp_axi_bram_ctrl (
  .s_axi_aclk       (s_axi_aclk),        // input wire s_axi_aclk
  .s_axi_aresetn    (s_axi_aresetn),    // input wire s_axi_aresetn
  .s_axi_awaddr     (s_axi_awaddr),     // input wire [15 : 0] s_axi_awaddr
  .s_axi_awlen      (s_axi_awlen),      // input wire [7 : 0] s_axi_awlen
  .s_axi_awsize     (s_axi_awsize),     // input wire [2 : 0] s_axi_awsize
  .s_axi_awburst    (s_axi_awburst),    // input wire [1 : 0] s_axi_awburst
  .s_axi_awlock     (s_axi_awlock),     // input wire s_axi_awlock
  .s_axi_awcache    (s_axi_awcache),    // input wire [3 : 0] s_axi_awcache
  .s_axi_awprot     (s_axi_awprot),     // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid    (s_axi_awvalid),    // input wire s_axi_awvalid
  .s_axi_awready    (s_axi_awready),    // output wire s_axi_awready
  .s_axi_wdata      (s_axi_wdata),      // input wire [511 : 0] s_axi_wdata
  .s_axi_wstrb      (s_axi_wstrb),      // input wire [63 : 0] s_axi_wstrb
  .s_axi_wlast      (s_axi_wlast),      // input wire s_axi_wlast
  .s_axi_wvalid     (s_axi_wvalid),     // input wire s_axi_wvalid
  .s_axi_wready     (s_axi_wready),     // output wire s_axi_wready
  .s_axi_bresp      (s_axi_bresp),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid     (s_axi_bvalid),     // output wire s_axi_bvalid
  .s_axi_bready     (s_axi_bready),     // input wire s_axi_bready
  .s_axi_araddr     (s_axi_araddr),     // input wire [15 : 0] s_axi_araddr
  .s_axi_arlen      (s_axi_arlen),      // input wire [7 : 0] s_axi_arlen
  .s_axi_arsize     (s_axi_arsize),     // input wire [2 : 0] s_axi_arsize
  .s_axi_arburst    (s_axi_arburst),    // input wire [1 : 0] s_axi_arburst
  .s_axi_arlock     (s_axi_arlock),     // input wire s_axi_arlock
  .s_axi_arcache    (s_axi_arcache),    // input wire [3 : 0] s_axi_arcache
  .s_axi_arprot     (s_axi_arprot),     // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid    (s_axi_arvalid),    // input wire s_axi_arvalid
  .s_axi_arready    (s_axi_arready),    // output wire s_axi_arready
  .s_axi_rdata      (s_axi_rdata),      // output wire [511 : 0] s_axi_rdata
  .s_axi_rresp      (s_axi_rresp),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rlast      (s_axi_rlast),      // output wire s_axi_rlast
  .s_axi_rvalid     (s_axi_rvalid),     // output wire s_axi_rvalid
  .s_axi_rready     (s_axi_rready),     // input wire s_axi_rready
  .bram_rst_a       (bram_rst_a),       // output wire bram_rst_a
  .bram_clk_a       (bram_clk_a),       // output wire bram_clk_a
  .bram_en_a        (bram_en_a),        // output wire bram_en_a
  .bram_we_a        (bram_we_a),        // output wire [63 : 0] bram_we_a
  .bram_addr_a      (bram_addr_a),      // output wire [15 : 0] bram_addr_a
  .bram_wrdata_a    (bram_wrdata_a),    // output wire [511 : 0] bram_wrdata_a
  .bram_rddata_a    (bram_rddata_a)     // input wire [511 : 0] bram_rddata_a
);

qp_blk_mem qp_blk_mem (
  .clka		(bram_clk_a),    // input wire clka
  .ena		(bram_en_a),      // input wire ena
  .wea		(bram_we_a),      // input wire [63 : 0] wea
  .addra	(bram_addr_a[13:6]),  // input wire [7 : 0] addra
  .dina		(bram_wrdata_a),    // input wire [511 : 0] dina
  .douta	(bram_rddata_a)  // output wire [511 : 0] douta
);



endmodule
