`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/13 09:31:48
// Design Name: 
// Module Name: XRNIC_WQE_manager
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

`include "XRNIC_define.vh"
//`include "XRNIC_Reg_Config.vh"
`include "XRNIC_REG_configuration.vh"
`include "proj_define.vh"
module XRNIC_WQE_manager_new
# (
  parameter C_AXIS_DATA_WIDTH 			= 512,
  parameter C_AXI_ADDR_WIDTH 			= 32,
  parameter DDR_C_AXI_ADDR_WIDTH		= 32,
  parameter SIM						="FALSE"
  )(
  	input                               	core_clk,
  	input                               	core_aresetn,

// WQE Posting -- Related Signals
  	input    	[C_AXI_ADDR_WIDTH-1 :0]    	qp_mgr_m_axi_araddr,
  	input		[7:0]						qp_mgr_m_axi_arlen,
  	input		[2:0]						qp_mgr_m_axi_arsize,
  	input		[1:0]						qp_mgr_m_axi_arburst,
  	input		[3:0]						qp_mgr_m_axi_arcache,
  	input		[2:0]						qp_mgr_m_axi_arprot,
  	input                               	qp_mgr_m_axi_arvalid,
  	output logic                            qp_mgr_m_axi_arready,
  	input									qp_mgr_m_axi_arlock,
// Read data/response channel
  	output  logic   [511:0]                 qp_mgr_m_axi_rdata,
  	output  logic                           qp_mgr_m_axi_rlast,
  	output  logic                           qp_mgr_m_axi_rvalid,
  	input                               	qp_mgr_m_axi_rready,
  	output 	[1:0]							qp_mgr_m_axi_rresp,

  	output logic							cm_reply_ddr_write_en,
  	input									cm_reply_ddr_write_done,

//SQ PI hardware handshake
  	output logic [15:0]                     o_qp_sq_pidb_hndshk,
  	output logic [31:0]                     o_qp_sq_pidb_wr_addr_hndshk,
  	output logic                            o_qp_sq_pidb_wr_valid_hndshk,
  	input                               	i_qp_sq_pidb_wr_rdy,
  	
  	input									resp_hndler_o_send_cq_db_cnt_valid,
  	input		[9:0]						resp_hndler_o_send_cq_db_addr,
  	
  	input									CM_reply_tx_en,
  	output									CM_reply_tx_done,
  	output  logic							RDMA_track_done,
  
  	input									ddr_TDI_write_done,
  	input									ddr_INFO_write_done,
  	input  	[DDR_C_AXI_ADDR_WIDTH-1:0]      track_last_TDI_DDR_addr,
  	input  	[DDR_C_AXI_ADDR_WIDTH-1:0]      track_last_INFO_DDR_addr,
  	input       							track_last_DDR_addr_vld,
  
  	input	[31:0]							sim_part_valid_line_cnt,
  	input	[3:0]							IMC_NUM,
  	input	[3:0]							track_num_per_IMC,
  	input	[15:0]							track_num_per_wafer,

	input [3:0]								rx_MR_QPn,
	input									rx_MR_tvalid,
	input [63:0]							host_MR_addr0,
	input [63:0]							host_MR_addr1,
//	input [63:0]							host_MR_len0,
//	input [63:0]							host_MR_len1,
	input [31:0]							host_MR_rkey0,
	input [31:0]							host_MR_rkey1,
  
  	input									info_enable,
  	
  	output	logic							db_write_enable,
  
  /****************************		STATE	****************************/
  	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic [31:0]						write_db_cnt=0,
  	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic [31:0]						db_cq_all_cnt=0,
  	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic [31:0]						db_cnt=0,
  	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic [31:0]						db_write_all_cnt=0,
  	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic [31:0]						all_time_cnt=0,
  	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic [31:0]						retry_qp_count=0,
  	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic [9:0]						XRNIC_db_fsm,
  	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic [9:0]						XRNIC_qp_wr_fsm
  
  
    );

//assign qp_mgr_m_axi_arready=1;

`include "ETH_pkt_define.sv"


//logic	[`CM_REPLY_PKT_LEN*8-1:0]				cm_reply_pkt_send;
//logic	[15:0]									cm_reply_ip_csum;
//logic	[`RDMA_WRITE_MSG_WQE_SIZE*8-1:0]		write_MSG_start_pkt_send;
//logic	[`RDMA_WRITE_MSG_WQE_SIZE*8-1:0]		write_MSG_end_pkt_send;


logic	[512*5-1:0]								TDI_compressed_data=0;
logic 	[C_AXI_ADDR_WIDTH-1:0]					expected_qp_addr_QP	[QP_NUM-2:0];
logic 	[C_AXI_ADDR_WIDTH-1:0]					qp_addr_start_QP	[QP_NUM-2:0];
logic 	[C_AXI_ADDR_WIDTH-1:0]					qp_addr_end_QP		[QP_NUM-2:0];
logic	[QP_NUM-2:0]							qp_unexpected_addr_flag;
//logic	[31:0]									retry_qp_count_QP	[QP_NUM-1:0];

logic 	[C_AXI_ADDR_WIDTH-1:0]					qp_mgr_m_axi_awaddr;
logic	[C_AXI_ADDR_WIDTH-1:0]					qp_mgr_m_axi_awaddr_QP	[QP_NUM-1:0];
logic 	[7:0]									qp_mgr_m_axi_awlen=0;
logic 	[2:0]									qp_mgr_m_axi_awsize='h6;
logic 	[1:0]									qp_mgr_m_axi_awburst='h1;
logic 	[3:0]									qp_mgr_m_axi_awcache='h3;
logic 	[2:0]									qp_mgr_m_axi_awprot='h0;
logic 											qp_mgr_m_axi_awvalid;
logic 											qp_mgr_m_axi_awready;
logic 	[511:0]									qp_mgr_m_axi_wdata=0;
logic 	[63:0]									qp_mgr_m_axi_wstrb=64'hffff_ffff_ffff_ffff;
logic 											qp_mgr_m_axi_wlast;
logic 											qp_mgr_m_axi_wvalid;
logic 											qp_mgr_m_axi_wready;
logic 											qp_mgr_m_axi_awlock='h0;
logic 	[1:0]									qp_mgr_m_axi_bresp;
logic 											qp_mgr_m_axi_bvalid;
logic 											qp_mgr_m_axi_bready='h1;

logic [DDR_C_AXI_ADDR_WIDTH-1:0]				fpga_TDI_ddr_addr=0;
logic [DDR_C_AXI_ADDR_WIDTH-1:0]				fpga_INFO_ddr_addr=0;
logic [31:0]									remain_TDI_sq_cnt=0;
logic [31:0]									remain_INFO_sq_cnt=0;

logic [15:0]									o_qp_sq_pidb_hndshk_QP	[QP_NUM-1:0];
logic [15:0]									qp_sq_pidb_hndshk_QP;
logic											RDMA_wr_db_ring;


logic [31:0]									TDI_qp_trigger_cnt=0;
logic											TDI_qp_part_eof;
logic [31:0]									INFO_qp_trigger_cnt=0;
logic											INFO_qp_part_eof;
logic [31:0]									TDI_track_tlast_cnt=0;
logic [31:0]									INFO_track_tlast_cnt=0;
logic											track_done;
logic											track_TDI_done;
logic											track_INFO_done;

logic											track_last_DDR_addr_vld_reg=0;
logic [DDR_C_AXI_ADDR_WIDTH-1:0]				track_last_TDI_DDR_addr_reg=0;
logic [DDR_C_AXI_ADDR_WIDTH-1:0]				track_last_INFO_DDR_addr_reg=0;

logic [2:0]										cur_QPN=1;
logic [15:0]									WRID=0;

logic [3:0]										cur_track_num=0;

enum logic [9:0]{	QP_RETRY_INIT,			DB_IDLE,	
					CM_REPLY_DDR_WR,		CM_REPLY_WQE_WR,		CM_REPLY_DB_RING,
					WAIT_DDR_WR_DONE,
//					SEND_START_WQE_WR,		SEND_START_DB_RING,
					WRITE_TDI_WQE_WR,		WRITE_TDI_DB_RING,		WRITE_TDI_DB_DONE,
					WRITE_INFO_WQE_WR,		WRITE_INFO_DB_RING,		WRITE_INFO_DB_DONE,
					SEND_END_WQE_WR,		SEND_END_DB_RING,
					WAIT_1s
} db_cur_st,db_nxt_st;
enum logic [9:0]{QP_IDLE,QP_WR_ST,QP_AW_ST} qp_wr_cur_st;

/**********************************************************************************************************************/
/*	host MR manager  */
/**********************************************************************************************************************/	
logic	[63:0]							cur_host_MR_addr0;
logic	[63:0]							cur_host_MR_addr1;
logic	[31:0]							cur_host_MR_rkey0;
logic	[31:0]							cur_host_MR_rkey1;

logic	[63:0]							host_MR_addr0_reg	[QP_NUM-2:0];
logic	[63:0]							host_MR_addr1_reg	[QP_NUM-2:0];
logic	[31:0]							host_MR_rkey0_reg	[QP_NUM-2:0];
logic	[31:0]							host_MR_rkey1_reg	[QP_NUM-2:0];

logic	[63:0]							cur_host_MR_addr0_reg=0	;
logic	[63:0]							cur_host_MR_addr1_reg=0	;

genvar i;
generate
	for(i=0;i<QP_NUM-1;i=i+1)
	begin
		always_ff@(posedge core_clk or negedge core_aresetn)
			if(~core_aresetn) begin
				host_MR_addr0_reg[i]	<=0;
				host_MR_addr1_reg[i]	<=0;
				host_MR_rkey0_reg[i]	<=0;
				host_MR_rkey1_reg[i]	<=0;
			end
			else if(rx_MR_tvalid && (i==(rx_MR_QPn-2))) begin
				host_MR_addr0_reg[i]	<=host_MR_addr0;
				host_MR_addr1_reg[i]	<=host_MR_addr1;
				host_MR_rkey0_reg[i]	<=host_MR_rkey0;
				host_MR_rkey1_reg[i]	<=host_MR_rkey1;
			end
	end
endgenerate

assign cur_host_MR_addr0=host_MR_addr0_reg[cur_QPN-1];
assign cur_host_MR_addr1=host_MR_addr1_reg[cur_QPN-1];
assign cur_host_MR_rkey0=host_MR_rkey0_reg[cur_QPN-1];
assign cur_host_MR_rkey1=host_MR_rkey1_reg[cur_QPN-1];

always_ff@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn) 
		cur_host_MR_addr0_reg	<=0;
	else if(db_cur_st==DB_IDLE && TDI_track_tlast_cnt==0) 			//	for 1 IMC testing, if 3 IMC, need to modify
		cur_host_MR_addr0_reg	<=cur_host_MR_addr0;
	else if(db_cur_st==WRITE_TDI_WQE_WR && qp_mgr_m_axi_wready && qp_mgr_m_axi_wlast && qp_mgr_m_axi_wvalid)
		cur_host_MR_addr0_reg	<=cur_host_MR_addr0_reg+(`COMPRESSED_WR_BURST_TOTAL_LEN<<6);

always_ff@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn) 
		cur_host_MR_addr1_reg	<=0;
	else if(db_cur_st==DB_IDLE && INFO_track_tlast_cnt==0) 			//	for 1 IMC testing, if 3 IMC, need to modify
		cur_host_MR_addr1_reg	<=cur_host_MR_addr1;
	else if(db_cur_st==WRITE_INFO_WQE_WR && qp_mgr_m_axi_wready && qp_mgr_m_axi_wlast && qp_mgr_m_axi_wvalid)
		cur_host_MR_addr1_reg	<=cur_host_MR_addr1_reg+(`INFO_BURST_LEN<<6);

/**********************************************************************************************************************/
/*	cur QPN  */
/**********************************************************************************************************************/	

always_ff@(posedge core_clk)
	if(cur_track_num==(track_num_per_IMC-1) && RDMA_track_done)											cur_track_num<=0;
	else if(RDMA_track_done)																			cur_track_num<=cur_track_num+1;

always_ff@(posedge core_clk)
	if(RDMA_track_done && cur_track_num==(track_num_per_IMC-1) && cur_QPN>=IMC_NUM)						cur_QPN<=1;
	else if(RDMA_track_done && cur_track_num==(track_num_per_IMC-1))									cur_QPN<=cur_QPN+1;


assign track_done=track_TDI_done && track_INFO_done ;
assign track_TDI_done=track_last_DDR_addr_vld_reg && fpga_TDI_ddr_addr==track_last_TDI_DDR_addr_reg;
assign track_INFO_done=info_enable ? track_last_DDR_addr_vld_reg && fpga_INFO_ddr_addr==track_last_INFO_DDR_addr_reg : 1;

/**********************************************************************************************************************/
/*	DB management  */
/**********************************************************************************************************************/	


always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn)		db_cur_st<=DB_IDLE;
	else 					db_cur_st<=db_nxt_st;

always @(*) 
begin
	db_nxt_st=db_cur_st;
    case(db_cur_st)
    	QP_RETRY_INIT:																															db_nxt_st=DB_IDLE;
    	DB_IDLE:					if(CM_reply_tx_en)																							db_nxt_st=CM_REPLY_DDR_WR;
    								else if(remain_TDI_sq_cnt>0)																				db_nxt_st=WRITE_TDI_WQE_WR;
    								else if(info_enable && remain_INFO_sq_cnt>0)																db_nxt_st=WRITE_INFO_WQE_WR;
    								else if(track_done)																							db_nxt_st=SEND_END_WQE_WR;
    	CM_REPLY_DDR_WR:			if(cm_reply_ddr_write_done)																					db_nxt_st=CM_REPLY_WQE_WR;
    	CM_REPLY_WQE_WR:			if(qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																db_nxt_st=CM_REPLY_DB_RING;
    	CM_REPLY_DB_RING:			if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)														db_nxt_st=DB_IDLE;
//		SEND_START_WQE_WR:			if(qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																db_nxt_st=SEND_START_DB_RING;
//    	SEND_START_DB_RING:			if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)														db_nxt_st=WRITE_TDI_WQE_WR;
    	WAIT_DDR_WR_DONE:			if(track_done)																								db_nxt_st=SEND_END_WQE_WR;
    								else if(remain_TDI_sq_cnt>0)																				db_nxt_st=WRITE_TDI_WQE_WR;
    								else if(info_enable && remain_INFO_sq_cnt>0)																db_nxt_st=WRITE_INFO_WQE_WR;
    								
		WRITE_TDI_WQE_WR:			if(qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																db_nxt_st=WRITE_TDI_DB_RING;
		WRITE_TDI_DB_RING:			if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)														db_nxt_st=WRITE_TDI_DB_DONE;
		WRITE_TDI_DB_DONE:																														db_nxt_st=WAIT_DDR_WR_DONE;
		WRITE_INFO_WQE_WR:			if(qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																db_nxt_st=WRITE_INFO_DB_RING;
		WRITE_INFO_DB_RING:			if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)														db_nxt_st=WRITE_INFO_DB_DONE;
		WRITE_INFO_DB_DONE:																														db_nxt_st=WAIT_DDR_WR_DONE;
		SEND_END_WQE_WR:			if(qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																db_nxt_st=SEND_END_DB_RING;
    	SEND_END_DB_RING:			if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)														db_nxt_st=DB_IDLE;
//    	WAIT_1s:					if(wait_cnt==32'd200_000_000)																				db_nxt_st=DB_IDLE;
    	default:																																db_nxt_st=DB_IDLE;
    endcase
end
assign XRNIC_db_fsm=db_cur_st;

assign RDMA_track_done=db_cur_st==SEND_END_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk;
//always_ff@(posedge core_clk)
//	if(RDMA_write_en)			fpga_TDI_end_addr<=`TDI_DDR_START_ADDR+TOTAL_write_db_cnt*WQE_write_len;

							
assign db_write_enable=db_cnt<(QPn_Send_Q_depth>>1);

always_ff@(posedge core_clk)
	if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk && resp_hndler_o_send_cq_db_cnt_valid)				db_cnt<=db_cnt;
	else if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)												db_cnt<=db_cnt+1;
	else if(resp_hndler_o_send_cq_db_cnt_valid)																	db_cnt<=db_cnt-1;

assign o_qp_sq_pidb_wr_valid_hndshk	=(db_cur_st==WRITE_TDI_DB_RING) | (db_cur_st==WRITE_INFO_DB_RING)| (db_cur_st==SEND_END_DB_RING) | (db_cur_st==CM_REPLY_DB_RING) && db_write_enable;			//(db_cur_st==SEND_START_DB_RING) | 


assign cm_reply_ddr_write_en=CM_reply_tx_en;
assign CM_reply_tx_done=db_cur_st==CM_REPLY_DB_RING && i_qp_sq_pidb_wr_rdy;

assign o_qp_sq_pidb_wr_addr_hndshk 	= 	(db_cur_st==CM_REPLY_DB_RING) ? 32'h20228					:	32'h20228+{cur_QPN,8'h0};			//16'h0100*cur_QPN
//assign o_qp_sq_pidb_hndshk=				qp_sq_pidb_hndshk_QP;
assign o_qp_sq_pidb_hndshk=				(db_cur_st==CM_REPLY_DB_RING) ? o_qp_sq_pidb_hndshk_QP[0] 	: 	o_qp_sq_pidb_hndshk_QP[cur_QPN];

//always@(posedge core_clk or negedge core_aresetn)
//	if(~core_aresetn)																									o_qp_sq_pidb_hndshk<=1;
//	else if(o_qp_sq_pidb_wr_addr_hndshk==32'h20238)																		o_qp_sq_pidb_hndshk<=1;
//	else if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk && o_qp_sq_pidb_hndshk==QPn_Send_Q_depth)				o_qp_sq_pidb_hndshk<=1;
//	else if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)														o_qp_sq_pidb_hndshk<=o_qp_sq_pidb_hndshk+1;

generate
for(i=1;i<QP_NUM;i=i+1) begin
	always@(posedge core_clk or negedge core_aresetn)
		if(~core_aresetn)																																o_qp_sq_pidb_hndshk_QP[i]<=1;
		else if(db_cur_st==CM_REPLY_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)			 											o_qp_sq_pidb_hndshk_QP[i]<=o_qp_sq_pidb_hndshk_QP[i];		// if on CM st, other QP 
		else if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk && o_qp_sq_pidb_hndshk_QP[i]==QPn_Send_Q_depth && cur_QPN==i)						o_qp_sq_pidb_hndshk_QP[i]<=1;
		else if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk && cur_QPN==i)																		o_qp_sq_pidb_hndshk_QP[i]<=o_qp_sq_pidb_hndshk_QP[i]+1;
end
endgenerate

always@(posedge core_clk or negedge core_aresetn)
		if(~core_aresetn)																																	o_qp_sq_pidb_hndshk_QP[0]<=1;
		else if(db_cur_st==CM_REPLY_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk && o_qp_sq_pidb_hndshk_QP[0]==QPn_Send_Q_depth)			o_qp_sq_pidb_hndshk_QP[0]<=1;
		else if(db_cur_st==CM_REPLY_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)															o_qp_sq_pidb_hndshk_QP[0]<=o_qp_sq_pidb_hndshk_QP[0]+1;

always@(posedge core_clk or negedge core_aresetn)
		if(~core_aresetn)																																	qp_sq_pidb_hndshk_QP<=1;
		else if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk && qp_sq_pidb_hndshk_QP==QPn_Send_Q_depth)												qp_sq_pidb_hndshk_QP<=1;
		else if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)																						qp_sq_pidb_hndshk_QP<=qp_sq_pidb_hndshk_QP+1;


always@(posedge core_clk)
	if(ddr_TDI_write_done && db_cur_st==WRITE_TDI_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)		remain_TDI_sq_cnt<=remain_TDI_sq_cnt;
	else if(ddr_TDI_write_done)																							remain_TDI_sq_cnt<=remain_TDI_sq_cnt+1;
	else if(db_cur_st==WRITE_TDI_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)						remain_TDI_sq_cnt<=remain_TDI_sq_cnt-1;

always@(posedge core_clk)
	if(ddr_INFO_write_done && db_cur_st==WRITE_INFO_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)		remain_INFO_sq_cnt<=remain_INFO_sq_cnt;
	else if(ddr_INFO_write_done)																						remain_INFO_sq_cnt<=remain_INFO_sq_cnt+1;
	else if(db_cur_st==WRITE_INFO_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)						remain_INFO_sq_cnt<=remain_INFO_sq_cnt-1;

always@(posedge core_clk)
	if(db_cur_st==SEND_END_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk && TDI_track_tlast_cnt==(track_num_per_IMC-1))						TDI_track_tlast_cnt<=0;
	else if(db_cur_st==SEND_END_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)																	TDI_track_tlast_cnt<=TDI_track_tlast_cnt+1;

always@(posedge core_clk)
	if(db_cur_st==SEND_END_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk && INFO_track_tlast_cnt==(track_num_per_wafer-1))						INFO_track_tlast_cnt<=0;
	else if(db_cur_st==SEND_END_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)																	INFO_track_tlast_cnt<=INFO_track_tlast_cnt+1;

always@(posedge core_clk)
	if(db_cur_st==SEND_END_WQE_WR)								track_last_DDR_addr_vld_reg<=0;
	else if(track_last_DDR_addr_vld)							track_last_DDR_addr_vld_reg<=1;

always@(posedge core_clk)
	if(db_cur_st==SEND_END_WQE_WR)								track_last_TDI_DDR_addr_reg<=0;
	else if(track_last_DDR_addr_vld)							track_last_TDI_DDR_addr_reg<=track_last_TDI_DDR_addr;

always@(posedge core_clk)
	if(db_cur_st==SEND_END_WQE_WR)								track_last_INFO_DDR_addr_reg<=0;
	else if(track_last_DDR_addr_vld)							track_last_INFO_DDR_addr_reg<=track_last_INFO_DDR_addr;

/**********************************************************************************************************************/
/*	Status  */
/**********************************************************************************************************************/
always_ff@(posedge core_clk or negedge core_aresetn)
	if(!core_aresetn)																				db_cq_all_cnt<=0;
	else if(resp_hndler_o_send_cq_db_cnt_valid)														db_cq_all_cnt<=db_cq_all_cnt+1;

always@(posedge core_clk or negedge core_aresetn)
	if(!core_aresetn)																				db_write_all_cnt<=0;
	else if(i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)									db_write_all_cnt<=db_write_all_cnt+1;

always@(posedge core_clk)
	if(db_cur_st==DB_IDLE)																			write_db_cnt<=0;
	else if(db_cur_st==WRITE_TDI_DB_RING && i_qp_sq_pidb_wr_rdy && o_qp_sq_pidb_wr_valid_hndshk)	write_db_cnt<=write_db_cnt+1;

/**********************************************************************************************************************/
/*	QP management  */
/**********************************************************************************************************************/	


always@(posedge core_clk or negedge core_aresetn)
	if(!core_aresetn)																																									qp_wr_cur_st<=QP_IDLE;
	else case(qp_wr_cur_st)
		QP_IDLE:	if((db_cur_st==CM_REPLY_WQE_WR) | (db_cur_st==WRITE_TDI_WQE_WR) | (db_cur_st==WRITE_INFO_WQE_WR)| (db_cur_st==SEND_END_WQE_WR))										qp_wr_cur_st<=QP_AW_ST;			// | (db_cur_st==SEND_START_WQE_WR)
		QP_AW_ST:	if(qp_mgr_m_axi_awvalid && qp_mgr_m_axi_awready)																													qp_wr_cur_st<=QP_WR_ST;
		QP_WR_ST:	if(qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																														qp_wr_cur_st<=QP_IDLE;
		default:																																										qp_wr_cur_st<=QP_IDLE;
	endcase
	assign XRNIC_qp_wr_fsm=qp_wr_cur_st;

//2025.6.10 add multi QP
//always@(posedge core_clk or negedge core_aresetn)
//	if(~core_aresetn)																									qp_mgr_m_axi_awaddr<='d0;
//	else if(db_cur_st==CM_REPLY_WQE_WR)																					qp_mgr_m_axi_awaddr<=qp_mgr_m_axi_awaddr_QP[0];
//	else																												qp_mgr_m_axi_awaddr<=qp_mgr_m_axi_awaddr_QP[cur_QPN];


assign RDMA_wr_db_ring=(db_cur_st==SEND_END_DB_RING) | (db_cur_st==WRITE_TDI_DB_RING) | (db_cur_st==WRITE_INFO_DB_RING);
generate
for(i=1;i<QP_NUM;i=i+1) begin
	always@(posedge core_clk or negedge core_aresetn)
		if(~core_aresetn)																																											qp_mgr_m_axi_awaddr_QP[i]<=QPn_Send_Q_buf_base_addr+((i-1)*(QPn_Send_Q_depth<<6));
		else if(RDMA_wr_db_ring  && o_qp_sq_pidb_wr_valid_hndshk && i_qp_sq_pidb_wr_rdy && cur_QPN==i && qp_mgr_m_axi_awaddr_QP[i]==(QPn_Send_Q_buf_base_addr+(i*(QPn_Send_Q_depth<<6))-10'h40))	qp_mgr_m_axi_awaddr_QP[i]<=QPn_Send_Q_buf_base_addr+((i-1)*(QPn_Send_Q_depth<<6));
		else if(RDMA_wr_db_ring  && o_qp_sq_pidb_wr_valid_hndshk && i_qp_sq_pidb_wr_rdy && cur_QPN==i)																								qp_mgr_m_axi_awaddr_QP[i]<=qp_mgr_m_axi_awaddr_QP[i]+10'h40;
end
endgenerate

always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn)																																								qp_mgr_m_axi_awaddr_QP[0]<=0;
	else if(db_cur_st==CM_REPLY_WQE_WR && qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																								qp_mgr_m_axi_awaddr_QP[0]<=qp_mgr_m_axi_awaddr_QP[0]+10'h40;

assign qp_mgr_m_axi_awaddr=		db_cur_st==CM_REPLY_WQE_WR ? qp_mgr_m_axi_awaddr_QP[0]	:	qp_mgr_m_axi_awaddr_QP[cur_QPN];
assign qp_mgr_m_axi_awvalid=	qp_wr_cur_st==QP_AW_ST;
assign qp_mgr_m_axi_wvalid=		qp_wr_cur_st==QP_WR_ST;
assign qp_mgr_m_axi_wlast=		qp_wr_cur_st==QP_WR_ST;

always@(posedge core_clk)
//	if(db_cur_st==SEND_START_WQE_WR)		qp_mgr_m_axi_wdata<=write_MSG_wqe_build(WRID,`WRITE_START_DDR_ADDR);
	if(db_cur_st==WRITE_TDI_WQE_WR)			qp_mgr_m_axi_wdata<=write_DATA_wqe_build(WRID,fpga_TDI_ddr_addr,cur_host_MR_addr0_reg,`COMPRESSED_WR_BURST_TOTAL_LEN<<6,cur_host_MR_rkey0);
	else if(db_cur_st==WRITE_INFO_WQE_WR)	qp_mgr_m_axi_wdata<=write_DATA_wqe_build(WRID,fpga_INFO_ddr_addr,cur_host_MR_addr1_reg,`INFO_BURST_LEN<<6,cur_host_MR_rkey1);
	else if(db_cur_st==SEND_END_WQE_WR)		qp_mgr_m_axi_wdata<=write_MSG_wqe_build(WRID,`WRITE_END_DDR_ADDR);
	else if(db_cur_st==CM_REPLY_WQE_WR)		qp_mgr_m_axi_wdata<=cm_reply_wqe_build;

// synthesis translate_off	
wqe_t TDI_wqe;
wqe_t INFO_wqe;
assign TDI_wqe=write_DATA_wqe_build(WRID,fpga_TDI_ddr_addr,cur_host_MR_addr0_reg,`COMPRESSED_WR_BURST_TOTAL_LEN<<6,host_MR_rkey0);
assign INFO_wqe=write_DATA_wqe_build(WRID,fpga_INFO_ddr_addr,cur_host_MR_addr1_reg,`INFO_BURST_LEN<<6,host_MR_rkey1);

// synthesis translate_on	


always@(posedge core_clk)
	if(TDI_qp_part_eof)																																						TDI_qp_trigger_cnt<=0;
	else if(db_cur_st==WRITE_TDI_WQE_WR && qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																						TDI_qp_trigger_cnt<=TDI_qp_trigger_cnt+`WR_BURST_LINE;

assign TDI_qp_part_eof=db_cur_st==WRITE_TDI_WQE_WR && qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready && TDI_qp_trigger_cnt==(sim_part_valid_line_cnt-`WR_BURST_LINE);

always@(posedge core_clk)
	if(db_cur_st==DB_IDLE)																																					fpga_TDI_ddr_addr<=`TDI_DDR_START_ADDR;
	else if(TDI_qp_part_eof)																																				fpga_TDI_ddr_addr<=`TDI_DDR_START_ADDR;
	else if(db_cur_st==WRITE_TDI_WQE_WR && qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready && (fpga_TDI_ddr_addr+(`COMPRESSED_WR_BURST_TOTAL_LEN<<6))>`TDI_DDR_END_ADDR)			fpga_TDI_ddr_addr<=`TDI_DDR_START_ADDR;
	else if(db_cur_st==WRITE_TDI_WQE_WR && qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																						fpga_TDI_ddr_addr<=fpga_TDI_ddr_addr+(`COMPRESSED_WR_BURST_TOTAL_LEN<<6);

always@(posedge core_clk)
	if(INFO_qp_part_eof)																																					INFO_qp_trigger_cnt<=0;
	else if(db_cur_st==WRITE_INFO_WQE_WR && qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																						INFO_qp_trigger_cnt<=INFO_qp_trigger_cnt+`INFO_BURST_TRIGGER_CNT;

assign INFO_qp_part_eof=db_cur_st==WRITE_INFO_WQE_WR && qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready && INFO_qp_trigger_cnt==(sim_part_valid_line_cnt-`INFO_BURST_TRIGGER_CNT);

always@(posedge core_clk)
	if(db_cur_st==DB_IDLE)																																					fpga_INFO_ddr_addr<=`INFO_DDR_START_ADDR;
	else if(INFO_qp_part_eof)																																				fpga_INFO_ddr_addr<=`INFO_DDR_START_ADDR;
	else if(db_cur_st==WRITE_INFO_WQE_WR && qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready && (fpga_INFO_ddr_addr+(`INFO_BURST_LEN<<6))>`INFO_DDR_END_ADDR)						fpga_INFO_ddr_addr<=`INFO_DDR_START_ADDR;
	else if(db_cur_st==WRITE_INFO_WQE_WR && qp_mgr_m_axi_wvalid && qp_mgr_m_axi_wready)																						fpga_INFO_ddr_addr<=fpga_INFO_ddr_addr+(`INFO_BURST_LEN<<6);

always@(posedge core_clk  or negedge core_aresetn)
	if(~core_aresetn)											WRID<=0;
	else if(qp_mgr_m_axi_awvalid && qp_mgr_m_axi_awready)		WRID<=WRID+1;

	

axi_bram QP_axi_bram
(
	.s_axi_aclk					(core_clk),
	.s_axi_aresetn				(core_aresetn),
	.s_axi_awaddr				(qp_mgr_m_axi_awaddr[15:0]),
	.s_axi_awlen				(qp_mgr_m_axi_awlen),
	.s_axi_awsize				(qp_mgr_m_axi_awsize),
	.s_axi_awburst				(qp_mgr_m_axi_awburst),
	.s_axi_awlock				(qp_mgr_m_axi_awlock),
	.s_axi_awcache				(qp_mgr_m_axi_awcache),
	.s_axi_awprot				(qp_mgr_m_axi_awprot),
	.s_axi_awvalid				(qp_mgr_m_axi_awvalid),
	.s_axi_awready				(qp_mgr_m_axi_awready),
	
	.s_axi_wdata				(qp_mgr_m_axi_wdata),
	.s_axi_wstrb				(qp_mgr_m_axi_wstrb),
	.s_axi_wlast				(qp_mgr_m_axi_wlast),
	.s_axi_wvalid				(qp_mgr_m_axi_wvalid),
	.s_axi_wready				(qp_mgr_m_axi_wready),
	
	.s_axi_bresp				(qp_mgr_m_axi_bresp),
	.s_axi_bvalid				(qp_mgr_m_axi_bvalid),
	.s_axi_bready				(qp_mgr_m_axi_bready),
	
	.s_axi_araddr				(qp_mgr_m_axi_araddr[15:0]),
	.s_axi_arlen				(qp_mgr_m_axi_arlen),  
	.s_axi_arsize				(qp_mgr_m_axi_arsize), 
	.s_axi_arburst				(qp_mgr_m_axi_arburst),
	.s_axi_arlock				(qp_mgr_m_axi_arlock), 
	.s_axi_arcache				(qp_mgr_m_axi_arcache),
	.s_axi_arprot				(qp_mgr_m_axi_arprot), 
	.s_axi_arvalid				(qp_mgr_m_axi_arvalid),				
	.s_axi_arready				(qp_mgr_m_axi_arready),
	
	.s_axi_rdata				(qp_mgr_m_axi_rdata),
    .s_axi_rresp				(qp_mgr_m_axi_rresp),
    .s_axi_rlast				(qp_mgr_m_axi_rlast),
    .s_axi_rvalid				(qp_mgr_m_axi_rvalid),
    .s_axi_rready				(qp_mgr_m_axi_rready)

);

// synthesis translate_off	
logic	[C_AXI_ADDR_WIDTH-1:0]	max_Q_addr;
assign max_Q_addr=QPn_Send_Q_buf_base_addr+(QPn_Send_Q_depth<<6)-8'h40;
// synthesis translate_on

/**********************************************************************************************************************/
/*	retry state  */
/**********************************************************************************************************************/
generate
for(i=0;i<(QP_NUM-1);i=i+1) begin
assign qp_addr_start_QP[i]=QPn_Send_Q_buf_base_addr+i*(QPn_Send_Q_depth<<6);
assign qp_addr_end_QP[i]=QPn_Send_Q_buf_base_addr+(i+1)*(QPn_Send_Q_depth<<6)-8'h40;
assign qp_unexpected_addr_flag[i]=qp_mgr_m_axi_arready && qp_mgr_m_axi_arvalid && qp_mgr_m_axi_araddr<qp_addr_end_QP[i] && qp_mgr_m_axi_araddr>=qp_addr_start_QP[i] && qp_mgr_m_axi_araddr!=expected_qp_addr_QP[i];


always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn)																																	expected_qp_addr_QP[i]<=qp_addr_start_QP[i];
	else if(db_cur_st==QP_RETRY_INIT)																													expected_qp_addr_QP[i]<=qp_addr_start_QP[i];
	else if(qp_mgr_m_axi_arready && qp_mgr_m_axi_arvalid && qp_mgr_m_axi_araddr==qp_addr_end_QP[i])														expected_qp_addr_QP[i]<=qp_addr_start_QP[i];
	else if(qp_mgr_m_axi_arready && qp_mgr_m_axi_arvalid && qp_mgr_m_axi_araddr<qp_addr_end_QP[i] && qp_mgr_m_axi_araddr>=qp_addr_start_QP[i])			expected_qp_addr_QP[i]<=qp_mgr_m_axi_araddr+8'h40;

end
endgenerate

always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn)																																	retry_qp_count<=0;
	else 																																				retry_qp_count<=retry_qp_count+(|qp_unexpected_addr_flag);



//ila_WQE ila_WQE (
//	.clk		(core_clk), // input wire clk
//	.probe0		(db_cnt), // input wire [31:0]  probe0  
//	.probe1		(db_cq_all_cnt), // input wire [31:0]  probe1 
//	.probe2		(db_write_all_cnt), // input wire [31:0]  probe2
//	.probe3		(retry_qp_count),
//	.probe4		(db_cur_st),
//	.probe5		(all_time_cnt),
//	.probe6		(ddr_TDI_write_done),
//	.probe7		(remain_TDI_sq_cnt),
//	.probe8 	(write_db_cnt)
//);










endmodule
