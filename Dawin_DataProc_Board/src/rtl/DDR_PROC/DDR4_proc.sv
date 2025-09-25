`timescale 1ps/1ps 
module DDR4_proc #(
	parameter C_AXI_ADDR_WIDTH         	= 33, 
  	parameter C_AXI_DATA_WIDTH         	= 512,
	parameter CHANNEL_0_LEN    			= 128 ,//	128*32=2304
	parameter CHANNEL_1_LEN     			= 126,
	parameter CHANNEL_NUM					= 0,
	parameter SIM 							= "FALSE"
)( //connected to axi sequence generator
	input                                  		clk_200,
	input                                  		rst,
	
	input  [511:0] 								TDI_axis_tdata,
    input  										TDI_axis_tvalid,
    output  									TDI_axis_tready,
    input  										TDI_axis_tlast,
    input										TDI_fifo_prog_full,
    
    input  [511:0] 								INFO_axis_tdata,
    input  										INFO_axis_tvalid,
    output  									INFO_axis_tready,
    input  										INFO_axis_tlast,
    input										INFO_fifo_prog_full,

	input                   					c_sys_clk_p,
    input                   					c_sys_clk_n,
    output                  					c_ddr4_act_n,
    output [16:0]            					c_ddr4_adr,
    output [1:0]            					c_ddr4_ba,
    output [0:0]            					c_ddr4_bg,
    output [0:0]            					c_ddr4_cke,
    output [0:0]            					c_ddr4_odt,
    output [0:0]            					c_ddr4_cs_n,
    output [0:0]            					c_ddr4_ck_t,
    output [0:0]            					c_ddr4_ck_c,
    output                  					c_ddr4_reset_n,
    inout  [7:0]            					c_ddr4_dm_dbi_n,
    inout  [63:0]            					c_ddr4_dq,
    inout  [7:0]           			 			c_ddr4_dqs_t,
    inout  [7:0]            					c_ddr4_dqs_c,
    
    input [3:0]      							ddr4_s_axi_arid,
	input [C_AXI_ADDR_WIDTH-1:0]    			ddr4_s_axi_araddr,
	input [7:0]                     			ddr4_s_axi_arlen,
	input [2:0]                     			ddr4_s_axi_arsize,
	input [1:0]                     			ddr4_s_axi_arburst,
	input [2:0]									ddr4_s_axi_arprot,
	input [3:0]                     			ddr4_s_axi_arcache,
	input                           			ddr4_s_axi_arvalid,
	output                          			ddr4_s_axi_arready,
	input                           			ddr4_s_axi_rready,
	output [3:0]      							ddr4_s_axi_rid,
	output [511:0]    							ddr4_s_axi_rdata,
	output [1:0]                    			ddr4_s_axi_rresp,
	output                          			ddr4_s_axi_rlast,
	output                          			ddr4_s_axi_rvalid,
	
	input										cm_reply_ddr_write_en,
  	output logic								cm_reply_ddr_write_done,
	output										ddr_TDI_write_done,
	output										ddr_INFO_write_done,
	input										TDI_trigger,
	input										track_tlast,
	output logic								c_init_calib_complete,
	
	output logic [C_AXI_ADDR_WIDTH-1:0]      	track_last_TDI_DDR_addr,
	output logic [C_AXI_ADDR_WIDTH-1:0]      	track_last_INFO_DDR_addr,
  	output logic      							track_last_DDR_addr_vld,
	
	input	[3:0]								track_num_per_IMC,
	input	[3:0]								IMC_NUM,
	input	[31:0]								sim_part_valid_line_cnt,
	
	input [3:0]									rx_MR_QPn,
	input										rx_MR_tvalid,
	input [63:0]								host_MR_addr0,
	input [63:0]								host_MR_addr1,
//	input [63:0]								host_MR_len0,
//	input [63:0]								host_MR_len1,
//	input [31:0]								host_MR_rkey0,
//	input [31:0]								host_MR_rkey1,
	
//	input										part_num,
	input										part_num,
    input										first_part_flag,
	
	input		[47:0]							recv_host_mac,
	input		[31:0]							recv_host_ip,
	input 		[31:0] 							recv_CM_local_Comm_ID,
	input 		[63:0]							recv_CM_loacl_CA_GUID,	
	input		[63:0]							recv_MAD_Transaction_ID,
	
	input										info_enable,
	
	output		[9:0]							DDR4_wr_fsm
	
);
	logic                  			c_ddr4_rst;
	logic                  			dbg_clk;
	logic                           c_ddr4_aresetn;
	logic [3:0]      				c_ddr4_s_axi_awid;
	logic [C_AXI_ADDR_WIDTH-1:0]    c_ddr4_s_axi_awaddr;
	logic [7:0]                     c_ddr4_s_axi_awlen;
	logic [2:0]                     c_ddr4_s_axi_awsize;
	logic [1:0]                     c_ddr4_s_axi_awburst;
	logic [3:0]                     c_ddr4_s_axi_awcache;
	logic [2:0]                     c_ddr4_s_axi_awprot;
	logic                           c_ddr4_s_axi_awvalid;
	logic                           c_ddr4_s_axi_awready;
	logic [511:0]    				c_ddr4_s_axi_wdata;
	logic [63:0]  					c_ddr4_s_axi_wstrb;
	logic                           c_ddr4_s_axi_wlast;
	logic                           c_ddr4_s_axi_wvalid;
	logic                           c_ddr4_s_axi_wready;
	logic                           c_ddr4_s_axi_bready;
	logic [3:0]      				c_ddr4_s_axi_bid;
	logic [1:0]                     c_ddr4_s_axi_bresp;
	logic                           c_ddr4_s_axi_bvalid;
	logic [3:0]      				c_ddr4_s_axi_arid;
	logic [C_AXI_ADDR_WIDTH-1:0]    c_ddr4_s_axi_araddr;
	logic [7:0]                     c_ddr4_s_axi_arlen;
	logic [2:0]                     c_ddr4_s_axi_arsize;
	logic [1:0]                     c_ddr4_s_axi_arburst;
	logic [3:0]                     c_ddr4_s_axi_arcache;
	logic [2:0]						c_ddr4_s_axi_arprot;
	logic                           c_ddr4_s_axi_arvalid;
	logic                           c_ddr4_s_axi_arready;
	logic                           c_ddr4_s_axi_rready;
	logic [3:0]      				c_ddr4_s_axi_rid;
	logic [511:0]    				c_ddr4_s_axi_rdata;
	logic [1:0]                     c_ddr4_s_axi_rresp;
	logic                           c_ddr4_s_axi_rlast;
	logic                           c_ddr4_s_axi_rvalid;
  
	logic                           ddr4_aresetn;
	logic [3:0]      				ddr4_s_axi_awid;
	logic [C_AXI_ADDR_WIDTH-1:0]    ddr4_s_axi_awaddr;
	logic [7:0]                     ddr4_s_axi_awlen;
	logic [2:0]                     ddr4_s_axi_awsize;
	logic [1:0]                     ddr4_s_axi_awburst;
	logic [3:0]                     ddr4_s_axi_awcache;
	logic [2:0]                     ddr4_s_axi_awprot;
	logic                           ddr4_s_axi_awvalid;
	logic                           ddr4_s_axi_awready;
	logic [511:0]    				ddr4_s_axi_wdata;
	logic [63:0]  					ddr4_s_axi_wstrb;
	logic                           ddr4_s_axi_wlast;
	logic                           ddr4_s_axi_wvalid;
	logic                           ddr4_s_axi_wready;
	logic                           ddr4_s_axi_bready;
	logic [3:0]      				ddr4_s_axi_bid;
	logic [1:0]                     ddr4_s_axi_bresp;
	logic                           ddr4_s_axi_bvalid;

  	logic                           c_ddr4_data_msmatch_err;
	logic                           c_ddr4_write_err;
	logic                           c_ddr4_read_err;
	logic                           c_ddr4_test_cmptd;
	logic                           c_ddr4_write_cmptd;
	logic                           c_ddr4_read_cmptd;
	logic                           c_ddr4_cmptd_one_wr_rd;
	logic                           c_ddr4_tg_data_err_status_rdy;
	logic [1:0]                     c_ddr4_tg_data_err_status;

	logic [511:0]                   dbg_bus;        

	
	logic							ddr_rd_resetn;
	logic							ddr_wr_resetn;
	logic							interconnect_resetn;

ddr4_test u_ddr4_test
(
   	.sys_rst           					(rst),
   	.c0_sys_clk_p                   	(c_sys_clk_p),
   	.c0_sys_clk_n                   	(c_sys_clk_n),
   	.c0_init_calib_complete 			(c_init_calib_complete),
   	.c0_ddr4_act_n          			(c_ddr4_act_n),
   	.c0_ddr4_adr            			(c_ddr4_adr),
   	.c0_ddr4_ba             			(c_ddr4_ba),
   	.c0_ddr4_bg             			(c_ddr4_bg),
   	.c0_ddr4_cke            			(c_ddr4_cke),
   	.c0_ddr4_odt            			(c_ddr4_odt),
   	.c0_ddr4_cs_n           			(c_ddr4_cs_n),
   	.c0_ddr4_ck_t           			(c_ddr4_ck_t),
   	.c0_ddr4_ck_c           			(c_ddr4_ck_c),
   	.c0_ddr4_reset_n        			(c_ddr4_reset_n),
   	.c0_ddr4_dm_dbi_n       			(c_ddr4_dm_dbi_n),
   	.c0_ddr4_dq             			(c_ddr4_dq),
   	.c0_ddr4_dqs_c          			(c_ddr4_dqs_c),
   	.c0_ddr4_dqs_t          			(c_ddr4_dqs_t),
   	.c0_ddr4_ui_clk                		(c_ddr4_clk),
 	.c0_ddr4_ui_clk_sync_rst			(c_ddr4_rst),
	.dbg_clk                            (dbg_clk),
  	.c0_ddr4_aresetn                    (1'b1),
  	.c0_ddr4_s_axi_awid                 (c_ddr4_s_axi_awid),
  	.c0_ddr4_s_axi_awaddr               (c_ddr4_s_axi_awaddr),
  	.c0_ddr4_s_axi_awlen                (c_ddr4_s_axi_awlen),
  	.c0_ddr4_s_axi_awsize               (c_ddr4_s_axi_awsize),
  	.c0_ddr4_s_axi_awburst              (c_ddr4_s_axi_awburst),
  	.c0_ddr4_s_axi_awlock               (1'b0),
  	.c0_ddr4_s_axi_awcache              (c_ddr4_s_axi_awcache),
  	.c0_ddr4_s_axi_awprot               (c_ddr4_s_axi_awprot),
  	.c0_ddr4_s_axi_awqos                (4'b0),
  	.c0_ddr4_s_axi_awvalid              (c_ddr4_s_axi_awvalid),
  	.c0_ddr4_s_axi_awready              (c_ddr4_s_axi_awready),
  	.c0_ddr4_s_axi_wdata                (c_ddr4_s_axi_wdata),
  	.c0_ddr4_s_axi_wstrb                (c_ddr4_s_axi_wstrb),
  	.c0_ddr4_s_axi_wlast                (c_ddr4_s_axi_wlast),
  	.c0_ddr4_s_axi_wvalid               (c_ddr4_s_axi_wvalid),
  	.c0_ddr4_s_axi_wready               (c_ddr4_s_axi_wready),
  	.c0_ddr4_s_axi_bid                  (c_ddr4_s_axi_bid),
  	.c0_ddr4_s_axi_bresp                (c_ddr4_s_axi_bresp),
  	.c0_ddr4_s_axi_bvalid               (c_ddr4_s_axi_bvalid),
  	.c0_ddr4_s_axi_bready               (c_ddr4_s_axi_bready),
  	.c0_ddr4_s_axi_arid                 (c_ddr4_s_axi_arid),
  	.c0_ddr4_s_axi_araddr               (c_ddr4_s_axi_araddr),
  	.c0_ddr4_s_axi_arlen                (c_ddr4_s_axi_arlen),
  	.c0_ddr4_s_axi_arsize               (c_ddr4_s_axi_arsize),
  	.c0_ddr4_s_axi_arburst              (c_ddr4_s_axi_arburst),
  	.c0_ddr4_s_axi_arlock               (1'b0),
  	.c0_ddr4_s_axi_arcache              (c_ddr4_s_axi_arcache),
  	.c0_ddr4_s_axi_arprot               (c_ddr4_s_axi_arprot),
  	.c0_ddr4_s_axi_arqos                (4'b0),
  	.c0_ddr4_s_axi_arvalid              (c_ddr4_s_axi_arvalid),
  	.c0_ddr4_s_axi_arready              (c_ddr4_s_axi_arready),
  	.c0_ddr4_s_axi_rid                  (c_ddr4_s_axi_rid),
  	.c0_ddr4_s_axi_rdata                (c_ddr4_s_axi_rdata),
  	.c0_ddr4_s_axi_rresp                (c_ddr4_s_axi_rresp),
  	.c0_ddr4_s_axi_rlast                (c_ddr4_s_axi_rlast),
  	.c0_ddr4_s_axi_rvalid               (c_ddr4_s_axi_rvalid),
  	.c0_ddr4_s_axi_rready               (c_ddr4_s_axi_rready),
  	.dbg_bus         					(dbg_bus)                                             

);
//   always @(posedge c_ddr4_clk) begin
//     c_ddr4_aresetn <= ~c_ddr4_rst;
//   end



//***************************************************************************
// The AXI testbench module instantiated below drives traffic (patterns)
// on the application interface of the memory controller
//***************************************************************************

DDR4_write_proc
#(
	.C_AXI_ADDR_WIDTH				(C_AXI_ADDR_WIDTH),
	.SIM							(SIM),
	.DDR_PART						(CHANNEL_NUM)
)DDR4_write_proc (
	.clk							(clk_200					),
	.rst							(~ddr_wr_resetn				),
  	.c_init_calib_complete			(c_init_calib_complete		),
	.axi_awready                    (ddr4_s_axi_awready			),
	.axi_awid                       (ddr4_s_axi_awid			),
	.axi_awaddr                     (ddr4_s_axi_awaddr			),
	.axi_awlen                      (ddr4_s_axi_awlen			),
	.axi_awsize                     (ddr4_s_axi_awsize			),
	.axi_awburst                    (ddr4_s_axi_awburst			),
	.axi_awlock                     (							),
	.axi_awcache                    (ddr4_s_axi_awcache			),
	.axi_awprot                     (ddr4_s_axi_awprot			),
	.axi_awvalid                    (ddr4_s_axi_awvalid			),
	.axi_wready                     (ddr4_s_axi_wready			),
	.axi_wdata                      (ddr4_s_axi_wdata			),
	.axi_wstrb                      (ddr4_s_axi_wstrb			),
	.axi_wlast                      (ddr4_s_axi_wlast			),
	.axi_wvalid                     (ddr4_s_axi_wvalid			),
	.axi_bid                        (ddr4_s_axi_bid				),
	.axi_bresp                      (ddr4_s_axi_bresp			),
	.axi_bvalid                     (ddr4_s_axi_bvalid			),
	.axi_bready                     (ddr4_s_axi_bready			),
	
	.TDI_axis_tdata					(TDI_axis_tdata				),
    .TDI_axis_tvalid				(TDI_axis_tvalid			),
    .TDI_axis_tready				(TDI_axis_tready			),
    .TDI_axis_tlast					(TDI_axis_tlast				),
    .TDI_fifo_prog_full				(TDI_fifo_prog_full			),
    .ddr_TDI_write_done				(ddr_TDI_write_done			),
    
    .INFO_axis_tdata				(INFO_axis_tdata			),
    .INFO_axis_tvalid				(INFO_axis_tvalid			),
    .INFO_axis_tready				(INFO_axis_tready			),
    .INFO_axis_tlast				(INFO_axis_tlast			),
    .INFO_fifo_prog_full			(INFO_fifo_prog_full		),
    .ddr_INFO_write_done			(ddr_INFO_write_done		),
    
    .cm_reply_ddr_write_en			(cm_reply_ddr_write_en		),
    .cm_reply_ddr_write_done		(cm_reply_ddr_write_done	),
    .TDI_trigger					(TDI_trigger				),
    .track_tlast					(track_tlast				),
    .part_num						(part_num					),
//   	.first_part_flag				(first_part_flag			),
    
    .track_last_TDI_DDR_addr		(track_last_TDI_DDR_addr	),
    .track_last_INFO_DDR_addr		(track_last_INFO_DDR_addr	),
    .track_last_DDR_addr_vld		(track_last_DDR_addr_vld	),
    .sim_part_valid_line_cnt		(sim_part_valid_line_cnt	),
    .IMC_NUM						(IMC_NUM					),
    .track_num_per_IMC				(track_num_per_IMC			),
    
    .rx_MR_tvalid					(rx_MR_tvalid				),
	.rx_MR_QPn						(rx_MR_QPn					),
	.host_MR_addr0					(host_MR_addr0				),
    .host_MR_addr1					(host_MR_addr1				),
//    .host_MR_len0					(host_MR_len0				),
//    .host_MR_len1					(host_MR_len1				),
//    .host_MR_rkey0					(host_MR_rkey0				),
//    .host_MR_rkey1					(host_MR_rkey1				),

	.recv_host_mac					(recv_host_mac				),
	.recv_host_ip					(recv_host_ip				),
	.recv_CM_local_Comm_ID			(recv_CM_local_Comm_ID		),
	.recv_CM_loacl_CA_GUID			(recv_CM_loacl_CA_GUID		),	
	.recv_MAD_Transaction_ID        (recv_MAD_Transaction_ID	),
	
	.info_enable					(info_enable				),
	
	.DDR4_wr_fsm					(DDR4_wr_fsm				)

);

assign interconnect_resetn=c_init_calib_complete;
axi_interconnect_0 axi_interconnect_ddr (
  .INTERCONNECT_ACLK		(c_ddr4_clk				),        // input wire INTERCONNECT_ACLK
  .INTERCONNECT_ARESETN		(interconnect_resetn 						),  // input wire INTERCONNECT_ARESETN
  .S00_AXI_ARESET_OUT_N		(ddr_rd_resetn				),  // output wire S00_AXI_ARESET_OUT_N
  .S00_AXI_ACLK				(clk_200					),                  // input wire S00_AXI_ACLK
  .S00_AXI_AWID				(),                  // input wire [0 : 0] S00_AXI_AWID
  .S00_AXI_AWADDR			(),              // input wire [31 : 0] S00_AXI_AWADDR
  .S00_AXI_AWLEN			(),                // input wire [7 : 0] S00_AXI_AWLEN
  .S00_AXI_AWSIZE			(),              // input wire [2 : 0] S00_AXI_AWSIZE
  .S00_AXI_AWBURST			(),            // input wire [1 : 0] S00_AXI_AWBURST
  .S00_AXI_AWLOCK			(),              // input wire S00_AXI_AWLOCK
  .S00_AXI_AWCACHE			(),            // input wire [3 : 0] S00_AXI_AWCACHE
  .S00_AXI_AWPROT			(),              // input wire [2 : 0] S00_AXI_AWPROT
  .S00_AXI_AWQOS			(),                // input wire [3 : 0] S00_AXI_AWQOS
  .S00_AXI_AWVALID			(),            // input wire S00_AXI_AWVALID
  .S00_AXI_AWREADY			(),            // output wire S00_AXI_AWREADY
  .S00_AXI_WDATA			(),                // input wire [511 : 0] S00_AXI_WDATA
  .S00_AXI_WSTRB			(),                // input wire [63 : 0] S00_AXI_WSTRB
  .S00_AXI_WLAST			(),                // input wire S00_AXI_WLAST
  .S00_AXI_WVALID			(),              // input wire S00_AXI_WVALID
  .S00_AXI_WREADY			(),              // output wire S00_AXI_WREADY
  .S00_AXI_BID				(),                    // output wire [0 : 0] S00_AXI_BID
  .S00_AXI_BRESP			(),                // output wire [1 : 0] S00_AXI_BRESP
  .S00_AXI_BVALID			(),              // output wire S00_AXI_BVALID
  .S00_AXI_BREADY			(),              // input wire S00_AXI_BREADY
  .S00_AXI_ARID				(ddr4_s_axi_arid		),                  // input wire [0 : 0] S00_AXI_ARID
  .S00_AXI_ARADDR			(ddr4_s_axi_araddr		),              // input wire [31 : 0] S00_AXI_ARADDR
  .S00_AXI_ARLEN			(ddr4_s_axi_arlen		),                // input wire [7 : 0] S00_AXI_ARLEN
  .S00_AXI_ARSIZE			(ddr4_s_axi_arsize		),              // input wire [2 : 0] S00_AXI_ARSIZE
  .S00_AXI_ARBURST			(ddr4_s_axi_arburst		),            // input wire [1 : 0] S00_AXI_ARBURST
  .S00_AXI_ARLOCK			(1'b0),              // input wire S00_AXI_ARLOCK
  .S00_AXI_ARCACHE			(ddr4_s_axi_arcache	),            // input wire [3 : 0] S00_AXI_ARCACHE
  .S00_AXI_ARPROT			(ddr4_s_axi_arprot),              // input wire [2 : 0] S00_AXI_ARPROT
  .S00_AXI_ARQOS			(4'h0),                // input wire [3 : 0] S00_AXI_ARQOS
  .S00_AXI_ARVALID			(ddr4_s_axi_arvalid		),            // input wire S00_AXI_ARVALID
  .S00_AXI_ARREADY			(ddr4_s_axi_arready		),            // output wire S00_AXI_ARREADY
  .S00_AXI_RID				(ddr4_s_axi_rid),                    // output wire [0 : 0] S00_AXI_RID
  .S00_AXI_RDATA			(ddr4_s_axi_rdata),                // output wire [511 : 0] S00_AXI_RDATA
  .S00_AXI_RRESP			(ddr4_s_axi_rresp),                // output wire [1 : 0] S00_AXI_RRESP
  .S00_AXI_RLAST			(ddr4_s_axi_rlast),                // output wire S00_AXI_RLAST
  .S00_AXI_RVALID			(ddr4_s_axi_rvalid),              // output wire S00_AXI_RVALID
  .S00_AXI_RREADY			(ddr4_s_axi_rready),              // input wire S00_AXI_RREADY
  .S01_AXI_ARESET_OUT_N		(ddr_wr_resetn),  // output wire S01_AXI_ARESET_OUT_N
  .S01_AXI_ACLK				(clk_200),                  // input wire S01_AXI_ACLK
  .S01_AXI_AWID				(ddr4_s_axi_awid),                  // input wire [0 : 0] S01_AXI_AWID
  .S01_AXI_AWADDR			(ddr4_s_axi_awaddr),              // input wire [31 : 0] S01_AXI_AWADDR
  .S01_AXI_AWLEN			(ddr4_s_axi_awlen),                // input wire [7 : 0] S01_AXI_AWLEN
  .S01_AXI_AWSIZE			(ddr4_s_axi_awsize),              // input wire [2 : 0] S01_AXI_AWSIZE
  .S01_AXI_AWBURST			(ddr4_s_axi_awburst),            // input wire [1 : 0] S01_AXI_AWBURST
  .S01_AXI_AWLOCK			(1'b0),              // input wire S01_AXI_AWLOCK
  .S01_AXI_AWCACHE			(ddr4_s_axi_awcache),            // input wire [3 : 0] S01_AXI_AWCACHE
  .S01_AXI_AWPROT			(ddr4_s_axi_awprot),              // input wire [2 : 0] S01_AXI_AWPROT
  .S01_AXI_AWQOS			(4'h0),                // input wire [3 : 0] S01_AXI_AWQOS
  .S01_AXI_AWVALID			(ddr4_s_axi_awvalid),            // input wire S01_AXI_AWVALID
  .S01_AXI_AWREADY			(ddr4_s_axi_awready),            // output wire S01_AXI_AWREADY
  .S01_AXI_WDATA			(ddr4_s_axi_wdata),                // input wire [511 : 0] S01_AXI_WDATA
  .S01_AXI_WSTRB			(ddr4_s_axi_wstrb),                // input wire [63 : 0] S01_AXI_WSTRB
  .S01_AXI_WLAST			(ddr4_s_axi_wlast),                // input wire S01_AXI_WLAST
  .S01_AXI_WVALID			(ddr4_s_axi_wvalid),              // input wire S01_AXI_WVALID
  .S01_AXI_WREADY			(ddr4_s_axi_wready),              // output wire S01_AXI_WREADY
  .S01_AXI_BID				(ddr4_s_axi_bid),                    // output wire [0 : 0] S01_AXI_BID
  .S01_AXI_BRESP			(ddr4_s_axi_bresp),                // output wire [1 : 0] S01_AXI_BRESP
  .S01_AXI_BVALID			(ddr4_s_axi_bvalid),              // output wire S01_AXI_BVALID
  .S01_AXI_BREADY			(ddr4_s_axi_bready),              // input wire S01_AXI_BREADY
  .S01_AXI_ARID				(),                  // input wire [0 : 0] S01_AXI_ARID
  .S01_AXI_ARADDR			(),              // input wire [31 : 0] S01_AXI_ARADDR
  .S01_AXI_ARLEN			(),                // input wire [7 : 0] S01_AXI_ARLEN
  .S01_AXI_ARSIZE			(),              // input wire [2 : 0] S01_AXI_ARSIZE
  .S01_AXI_ARBURST			(),            // input wire [1 : 0] S01_AXI_ARBURST
  .S01_AXI_ARLOCK			(),              // input wire S01_AXI_ARLOCK
  .S01_AXI_ARCACHE			(),            // input wire [3 : 0] S01_AXI_ARCACHE
  .S01_AXI_ARPROT			(),              // input wire [2 : 0] S01_AXI_ARPROT
  .S01_AXI_ARQOS			(),                // input wire [3 : 0] S01_AXI_ARQOS
  .S01_AXI_ARVALID			(),            // input wire S01_AXI_ARVALID
  .S01_AXI_ARREADY			(),            // output wire S01_AXI_ARREADY
  .S01_AXI_RID				(),                    // output wire [0 : 0] S01_AXI_RID
  .S01_AXI_RDATA			(),                // output wire [511 : 0] S01_AXI_RDATA
  .S01_AXI_RRESP			(),                // output wire [1 : 0] S01_AXI_RRESP
  .S01_AXI_RLAST			(),                // output wire S01_AXI_RLAST
  .S01_AXI_RVALID			(),              // output wire S01_AXI_RVALID
  .S01_AXI_RREADY			(),              // input wire S01_AXI_RREADY
  .M00_AXI_ARESET_OUT_N		(c_ddr4_aresetn),  // output wire M00_AXI_ARESET_OUT_N
  .M00_AXI_ACLK				(c_ddr4_clk),                  // input wire M00_AXI_ACLK
  .M00_AXI_AWID				(c_ddr4_s_axi_awid),                  // output wire [3 : 0] M00_AXI_AWID
  .M00_AXI_AWADDR			(c_ddr4_s_axi_awaddr),              // output wire [31 : 0] M00_AXI_AWADDR
  .M00_AXI_AWLEN			(c_ddr4_s_axi_awlen),                // output wire [7 : 0] M00_AXI_AWLEN
  .M00_AXI_AWSIZE			(c_ddr4_s_axi_awsize),              // output wire [2 : 0] M00_AXI_AWSIZE
  .M00_AXI_AWBURST			(c_ddr4_s_axi_awburst),            // output wire [1 : 0] M00_AXI_AWBURST
  .M00_AXI_AWLOCK			(),              // output wire M00_AXI_AWLOCK
  .M00_AXI_AWCACHE			(c_ddr4_s_axi_awcache),            // output wire [3 : 0] M00_AXI_AWCACHE
  .M00_AXI_AWPROT			(c_ddr4_s_axi_awprot),              // output wire [2 : 0] M00_AXI_AWPROT
  .M00_AXI_AWQOS			(),                // output wire [3 : 0] M00_AXI_AWQOS
  .M00_AXI_AWVALID			(c_ddr4_s_axi_awvalid),            // output wire M00_AXI_AWVALID
  .M00_AXI_AWREADY			(c_ddr4_s_axi_awready),            // input wire M00_AXI_AWREADY
  .M00_AXI_WDATA			(c_ddr4_s_axi_wdata),                // output wire [511 : 0] M00_AXI_WDATA
  .M00_AXI_WSTRB			(c_ddr4_s_axi_wstrb),                // output wire [63 : 0] M00_AXI_WSTRB
  .M00_AXI_WLAST			(c_ddr4_s_axi_wlast),                // output wire M00_AXI_WLAST
  .M00_AXI_WVALID			(c_ddr4_s_axi_wvalid),              // output wire M00_AXI_WVALID
  .M00_AXI_WREADY			(c_ddr4_s_axi_wready),              // input wire M00_AXI_WREADY
  .M00_AXI_BID				(c_ddr4_s_axi_bid),                    // input wire [3 : 0] M00_AXI_BID
  .M00_AXI_BRESP			(c_ddr4_s_axi_bresp),                // input wire [1 : 0] M00_AXI_BRESP
  .M00_AXI_BVALID			(c_ddr4_s_axi_bvalid),              // input wire M00_AXI_BVALID
  .M00_AXI_BREADY			(c_ddr4_s_axi_bready),              // output wire M00_AXI_BREADY
  .M00_AXI_ARID				(c_ddr4_s_axi_arid),                  // output wire [3 : 0] M00_AXI_ARID
  .M00_AXI_ARADDR			(c_ddr4_s_axi_araddr),              // output wire [31 : 0] M00_AXI_ARADDR
  .M00_AXI_ARLEN			(c_ddr4_s_axi_arlen),                // output wire [7 : 0] M00_AXI_ARLEN
  .M00_AXI_ARSIZE			(c_ddr4_s_axi_arsize),              // output wire [2 : 0] M00_AXI_ARSIZE
  .M00_AXI_ARBURST			(c_ddr4_s_axi_arburst),            // output wire [1 : 0] M00_AXI_ARBURST
  .M00_AXI_ARLOCK			(),              // output wire M00_AXI_ARLOCK
  .M00_AXI_ARCACHE			(c_ddr4_s_axi_arcache),            // output wire [3 : 0] M00_AXI_ARCACHE
  .M00_AXI_ARPROT			(c_ddr4_s_axi_arprot),              // output wire [2 : 0] M00_AXI_ARPROT
  .M00_AXI_ARQOS			(),                // output wire [3 : 0] M00_AXI_ARQOS
  .M00_AXI_ARVALID			(c_ddr4_s_axi_arvalid),            // output wire M00_AXI_ARVALID
  .M00_AXI_ARREADY			(c_ddr4_s_axi_arready),            // input wire M00_AXI_ARREADY
  .M00_AXI_RID				(c_ddr4_s_axi_rid),                    // input wire [3 : 0] M00_AXI_RID
  .M00_AXI_RDATA			(c_ddr4_s_axi_rdata),                // input wire [511 : 0] M00_AXI_RDATA
  .M00_AXI_RRESP			(c_ddr4_s_axi_rresp),                // input wire [1 : 0] M00_AXI_RRESP
  .M00_AXI_RLAST			(c_ddr4_s_axi_rlast),                // input wire M00_AXI_RLAST
  .M00_AXI_RVALID			(c_ddr4_s_axi_rvalid),              // input wire M00_AXI_RVALID
  .M00_AXI_RREADY			(c_ddr4_s_axi_rready)              // output wire M00_AXI_RREADY
);

//ila_interconnect ila_interconnect (
//	.clk		(c_ddr4_clk), // input wire clk
//	.probe0		(c_ddr4_s_axi_awaddr), // input wire [32:0]  probe0  
//	.probe1		(c_ddr4_s_axi_awvalid), // input wire [0:0]  probe1 
//	.probe2		(c_ddr4_s_axi_awready), // input wire [0:0]  probe2 
//	.probe3		(c_ddr4_s_axi_wdata), // input wire [511:0]  probe3 
//	.probe4		(c_ddr4_s_axi_wvalid), // input wire [0:0]  probe4 
//	.probe5		(c_ddr4_s_axi_wready), // input wire [0:0]  probe5 
//	.probe6		(c_ddr4_s_axi_wlast), // input wire [0:0]  probe6
//	.probe7		(c_ddr4_s_axi_araddr), // input wire [32:0]  probe0  
//	.probe8		(c_ddr4_s_axi_arvalid), // input wire [0:0]  probe1 
//	.probe9		(c_ddr4_s_axi_arready), // input wire [0:0]  probe2 
//	.probe10	(c_ddr4_s_axi_rdata), // input wire [511:0]  probe3 
//	.probe11	(c_ddr4_s_axi_rvalid), // input wire [0:0]  probe4 
//	.probe12	(c_ddr4_s_axi_rready), // input wire [0:0]  probe5 
//	.probe13	(c_ddr4_s_axi_rlast) // input wire [0:0]  probe6
//);

endmodule


