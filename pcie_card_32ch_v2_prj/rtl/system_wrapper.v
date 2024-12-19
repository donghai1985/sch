//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Wed Oct 11 11:03:05 2023
//Host        : holt running 64-bit major release  (build 9200)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (aclk,
    aresetn,
    lnk_up_led,
    m00_axi_araddr,
    m00_axi_arburst,
    m00_axi_arcache,
    m00_axi_arid,
    m00_axi_arlen,
    m00_axi_arlock,
    m00_axi_arprot,
    m00_axi_arready,
    m00_axi_arsize,
    m00_axi_arvalid,
    m00_axi_awaddr,
    m00_axi_awburst,
    m00_axi_awcache,
    m00_axi_awid,
    m00_axi_awlen,
    m00_axi_awlock,
    m00_axi_awprot,
    m00_axi_awready,
    m00_axi_awsize,
    m00_axi_awvalid,
    m00_axi_bid,
    m00_axi_bready,
    m00_axi_bresp,
    m00_axi_bvalid,
    m00_axi_rdata,
    m00_axi_rid,
    m00_axi_rlast,
    m00_axi_rready,
    m00_axi_rresp,
    m00_axi_rvalid,
    m00_axi_wdata,
    m00_axi_wlast,
    m00_axi_wready,
    m00_axi_wstrb,
    m00_axi_wvalid,
    m00_axil_araddr,
    m00_axil_arprot,
    m00_axil_arready,
    m00_axil_arvalid,
    m00_axil_awaddr,
    m00_axil_awprot,
    m00_axil_awready,
    m00_axil_awvalid,
    m00_axil_bready,
    m00_axil_bresp,
    m00_axil_bvalid,
    m00_axil_rdata,
    m00_axil_rready,
    m00_axil_rresp,
    m00_axil_rvalid,
    m00_axil_wdata,
    m00_axil_wready,
    m00_axil_wstrb,
    m00_axil_wvalid,
    pcie_mgt_rxn,
    pcie_mgt_rxp,
    pcie_mgt_txn,
    pcie_mgt_txp,
    pcie_ref_clk_n,
    pcie_ref_clk_p,
    pcie_rst_n,
    usr_irq_ack,
    usr_irq_req);
  output aclk;
  output aresetn;
  output lnk_up_led;
  output [63:0]m00_axi_araddr;
  output [1:0]m00_axi_arburst;
  output [3:0]m00_axi_arcache;
  output [3:0]m00_axi_arid;
  output [7:0]m00_axi_arlen;
  output m00_axi_arlock;
  output [2:0]m00_axi_arprot;
  input m00_axi_arready;
  output [2:0]m00_axi_arsize;
  output m00_axi_arvalid;
  output [63:0]m00_axi_awaddr;
  output [1:0]m00_axi_awburst;
  output [3:0]m00_axi_awcache;
  output [3:0]m00_axi_awid;
  output [7:0]m00_axi_awlen;
  output m00_axi_awlock;
  output [2:0]m00_axi_awprot;
  input m00_axi_awready;
  output [2:0]m00_axi_awsize;
  output m00_axi_awvalid;
  input [3:0]m00_axi_bid;
  output m00_axi_bready;
  input [1:0]m00_axi_bresp;
  input m00_axi_bvalid;
  input [63:0]m00_axi_rdata;
  input [3:0]m00_axi_rid;
  input m00_axi_rlast;
  output m00_axi_rready;
  input [1:0]m00_axi_rresp;
  input m00_axi_rvalid;
  output [63:0]m00_axi_wdata;
  output m00_axi_wlast;
  input m00_axi_wready;
  output [7:0]m00_axi_wstrb;
  output m00_axi_wvalid;
  output [31:0]m00_axil_araddr;
  output [2:0]m00_axil_arprot;
  input m00_axil_arready;
  output m00_axil_arvalid;
  output [31:0]m00_axil_awaddr;
  output [2:0]m00_axil_awprot;
  input m00_axil_awready;
  output m00_axil_awvalid;
  output m00_axil_bready;
  input [1:0]m00_axil_bresp;
  input m00_axil_bvalid;
  input [31:0]m00_axil_rdata;
  output m00_axil_rready;
  input [1:0]m00_axil_rresp;
  input m00_axil_rvalid;
  output [31:0]m00_axil_wdata;
  input m00_axil_wready;
  output [3:0]m00_axil_wstrb;
  output m00_axil_wvalid;
  input [1:0]pcie_mgt_rxn;
  input [1:0]pcie_mgt_rxp;
  output [1:0]pcie_mgt_txn;
  output [1:0]pcie_mgt_txp;
  input [0:0]pcie_ref_clk_n;
  input [0:0]pcie_ref_clk_p;
  input pcie_rst_n;
  output [1:0]usr_irq_ack;
  input [1:0]usr_irq_req;

  wire aclk;
  wire aresetn;
  wire lnk_up_led;
  wire [63:0]m00_axi_araddr;
  wire [1:0]m00_axi_arburst;
  wire [3:0]m00_axi_arcache;
  wire [3:0]m00_axi_arid;
  wire [7:0]m00_axi_arlen;
  wire m00_axi_arlock;
  wire [2:0]m00_axi_arprot;
  wire m00_axi_arready;
  wire [2:0]m00_axi_arsize;
  wire m00_axi_arvalid;
  wire [63:0]m00_axi_awaddr;
  wire [1:0]m00_axi_awburst;
  wire [3:0]m00_axi_awcache;
  wire [3:0]m00_axi_awid;
  wire [7:0]m00_axi_awlen;
  wire m00_axi_awlock;
  wire [2:0]m00_axi_awprot;
  wire m00_axi_awready;
  wire [2:0]m00_axi_awsize;
  wire m00_axi_awvalid;
  wire [3:0]m00_axi_bid;
  wire m00_axi_bready;
  wire [1:0]m00_axi_bresp;
  wire m00_axi_bvalid;
  wire [63:0]m00_axi_rdata;
  wire [3:0]m00_axi_rid;
  wire m00_axi_rlast;
  wire m00_axi_rready;
  wire [1:0]m00_axi_rresp;
  wire m00_axi_rvalid;
  wire [63:0]m00_axi_wdata;
  wire m00_axi_wlast;
  wire m00_axi_wready;
  wire [7:0]m00_axi_wstrb;
  wire m00_axi_wvalid;
  wire [31:0]m00_axil_araddr;
  wire [2:0]m00_axil_arprot;
  wire m00_axil_arready;
  wire m00_axil_arvalid;
  wire [31:0]m00_axil_awaddr;
  wire [2:0]m00_axil_awprot;
  wire m00_axil_awready;
  wire m00_axil_awvalid;
  wire m00_axil_bready;
  wire [1:0]m00_axil_bresp;
  wire m00_axil_bvalid;
  wire [31:0]m00_axil_rdata;
  wire m00_axil_rready;
  wire [1:0]m00_axil_rresp;
  wire m00_axil_rvalid;
  wire [31:0]m00_axil_wdata;
  wire m00_axil_wready;
  wire [3:0]m00_axil_wstrb;
  wire m00_axil_wvalid;
  wire [1:0]pcie_mgt_rxn;
  wire [1:0]pcie_mgt_rxp;
  wire [1:0]pcie_mgt_txn;
  wire [1:0]pcie_mgt_txp;
  wire [0:0]pcie_ref_clk_n;
  wire [0:0]pcie_ref_clk_p;
  wire pcie_rst_n;
  wire [1:0]usr_irq_ack;
  wire [1:0]usr_irq_req;

  system system_i
       (.aclk(aclk),
        .aresetn(aresetn),
        .lnk_up_led(lnk_up_led),
        .m00_axi_araddr(m00_axi_araddr),
        .m00_axi_arburst(m00_axi_arburst),
        .m00_axi_arcache(m00_axi_arcache),
        .m00_axi_arid(m00_axi_arid),
        .m00_axi_arlen(m00_axi_arlen),
        .m00_axi_arlock(m00_axi_arlock),
        .m00_axi_arprot(m00_axi_arprot),
        .m00_axi_arready(m00_axi_arready),
        .m00_axi_arsize(m00_axi_arsize),
        .m00_axi_arvalid(m00_axi_arvalid),
        .m00_axi_awaddr(m00_axi_awaddr),
        .m00_axi_awburst(m00_axi_awburst),
        .m00_axi_awcache(m00_axi_awcache),
        .m00_axi_awid(m00_axi_awid),
        .m00_axi_awlen(m00_axi_awlen),
        .m00_axi_awlock(m00_axi_awlock),
        .m00_axi_awprot(m00_axi_awprot),
        .m00_axi_awready(m00_axi_awready),
        .m00_axi_awsize(m00_axi_awsize),
        .m00_axi_awvalid(m00_axi_awvalid),
        .m00_axi_bid(m00_axi_bid),
        .m00_axi_bready(m00_axi_bready),
        .m00_axi_bresp(m00_axi_bresp),
        .m00_axi_bvalid(m00_axi_bvalid),
        .m00_axi_rdata(m00_axi_rdata),
        .m00_axi_rid(m00_axi_rid),
        .m00_axi_rlast(m00_axi_rlast),
        .m00_axi_rready(m00_axi_rready),
        .m00_axi_rresp(m00_axi_rresp),
        .m00_axi_rvalid(m00_axi_rvalid),
        .m00_axi_wdata(m00_axi_wdata),
        .m00_axi_wlast(m00_axi_wlast),
        .m00_axi_wready(m00_axi_wready),
        .m00_axi_wstrb(m00_axi_wstrb),
        .m00_axi_wvalid(m00_axi_wvalid),
        .m00_axil_araddr(m00_axil_araddr),
        .m00_axil_arprot(m00_axil_arprot),
        .m00_axil_arready(m00_axil_arready),
        .m00_axil_arvalid(m00_axil_arvalid),
        .m00_axil_awaddr(m00_axil_awaddr),
        .m00_axil_awprot(m00_axil_awprot),
        .m00_axil_awready(m00_axil_awready),
        .m00_axil_awvalid(m00_axil_awvalid),
        .m00_axil_bready(m00_axil_bready),
        .m00_axil_bresp(m00_axil_bresp),
        .m00_axil_bvalid(m00_axil_bvalid),
        .m00_axil_rdata(m00_axil_rdata),
        .m00_axil_rready(m00_axil_rready),
        .m00_axil_rresp(m00_axil_rresp),
        .m00_axil_rvalid(m00_axil_rvalid),
        .m00_axil_wdata(m00_axil_wdata),
        .m00_axil_wready(m00_axil_wready),
        .m00_axil_wstrb(m00_axil_wstrb),
        .m00_axil_wvalid(m00_axil_wvalid),
        .pcie_mgt_rxn(pcie_mgt_rxn),
        .pcie_mgt_rxp(pcie_mgt_rxp),
        .pcie_mgt_txn(pcie_mgt_txn),
        .pcie_mgt_txp(pcie_mgt_txp),
        .pcie_ref_clk_n(pcie_ref_clk_n),
        .pcie_ref_clk_p(pcie_ref_clk_p),
        .pcie_rst_n(pcie_rst_n),
        .usr_irq_ack(usr_irq_ack),
        .usr_irq_req(usr_irq_req));
endmodule
