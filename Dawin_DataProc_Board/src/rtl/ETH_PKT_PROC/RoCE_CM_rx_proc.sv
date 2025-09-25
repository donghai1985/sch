`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/10 14:00:44
// Design Name: 
// Module Name: RoCE_CM_rx_proc
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

module RoCE_CM_rx_proc#
(
	parameter C_AXIS_DATA_WIDTH = 512
)(
	input  wire                             	core_clk,
	input  wire                             	core_aresetn,
	
	output                               		rx_s_axis_tready,
	input  	[C_AXIS_DATA_WIDTH-1 : 0]    		rx_s_axis_tdata,
	input 	[C_AXIS_DATA_WIDTH/8-1:0]    		rx_s_axis_tkeep,
	input                               		rx_s_axis_tvalid,
	input                               		rx_s_axis_tlast,
	
	output logic								CM_Req_tvalid,
	output logic								CM_ReadyToUse_tvalid,
	
	output logic [47:0]							recv_CM_src_mac,
	output logic [31:0]							recv_CM_src_ip,
	output logic [63:0] 						recv_MAD_Transaction_ID,
	output logic [15:0] 						recv_MAD_Attribute_ID,
	output logic [31:0] 						recv_CM_local_Comm_ID,
	output logic [63:0]							recv_CM_loacl_CA_GUID,			
	output logic [23:0]							recv_CM_QPN,	
	output logic [31:0]							recv_CM_Q_KEY,
	output logic [23:0]							recv_QPn_start_PSN,
	output logic [31:0]							recv_QPn_IPv4
);

logic [7:0]							recv_IB_opcode;
logic [23:0]						recv_dst_QP_num;
logic								is_CM_req;
//logic								is_req;
//logic								is_rts;

logic [3:0]							rx_pkt_cnt=0;


logic [15:0] 						Protocol_ID = 16'h0800;
logic [7:0] 						UDP_Protocol_ID = 8'h11;
logic [15:0]						MAD_Attribute_ID;



//logic [5:0]							cur_local_QPN=2;
//logic [15:0]						QPn_Partition_Key=16'h2233_4455;

assign rx_s_axis_tready=1;

assign recv_IB_opcode=rx_s_axis_tdata[16*8-1-:8];
assign recv_dst_QP_num=rx_s_axis_tdata[11*8-1-:24];
//assign local_QPn_Partition_Key=QPn_Partition_Key;
//assign recv_MAD_Transaction_ID=reorder_rx_s_axis_tdata[511-12*8-:64];
//assign recv_MAD_Attribute_ID=reorder_rx_s_axis_tdata[511-20*8-:16];
//assign recv_CM_local_Comm_ID=reorder_rx_s_axis_tdata[511-28*8-:32];
//assign recv_CM_start_PSN=reorder_rx_s_axis_tdata[511-8*8-:24];
//assign recv_CM_loacl_CA_GUID=reorder_rx_s_axis_tdata[40*4-1-:64];


enum {IDLE,PKT_RX}cur_st,nxt_st;
always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn)				cur_st<=IDLE;
	else							cur_st<=nxt_st;

always@(*)
begin
	nxt_st=cur_st;
	case(cur_st)
		IDLE:		if(rx_s_axis_tvalid)																	nxt_st=PKT_RX;
		PKT_RX:		if(rx_s_axis_tvalid && rx_s_axis_tlast)													nxt_st=IDLE;
		default:																							nxt_st=IDLE;
	endcase
end

//assign is_req=	rx_pkt_cnt==1 && rx_s_axis_tvalid && recv_MAD_Attribute_ID==`RoCE_ConnectRequest;
//assign is_rts=	rx_pkt_cnt==1 && rx_s_axis_tvalid && recv_MAD_Attribute_ID==`RoCE_ReadyToUse;


assign CM_Req_tvalid=			rx_s_axis_tlast && rx_s_axis_tvalid && recv_MAD_Attribute_ID==`RoCE_ConnectRequest;
assign CM_ReadyToUse_tvalid=	rx_s_axis_tlast && rx_s_axis_tvalid && recv_MAD_Attribute_ID==`RoCE_ReadyToUse;
assign MAD_Attribute_ID=		rx_s_axis_tdata[511-14*8-:16];
/*assign local_QPN=cur_local_QPN;
always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn)										cur_local_QPN<=1;
	else if((cur_st==CM_REQ_5) && rx_s_axis_tvalid)			cur_local_QPN<=cur_local_QPN+1;
	
always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn)										QPn_Partition_Key<=16'hffff;
	else if((cur_st==CM_REQ_5) && rx_s_axis_tvalid)			QPn_Partition_Key<=QPn_Partition_Key+16'h100;*/

always@(posedge core_clk)
	if(cur_st==PKT_RX && rx_s_axis_tlast)	rx_pkt_cnt<=0;
	else if(rx_s_axis_tvalid)				rx_pkt_cnt<=rx_pkt_cnt+1;

always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn)
	begin
		recv_CM_src_mac<=0;
		recv_CM_src_ip<=0;
		recv_MAD_Attribute_ID<=0;
		recv_CM_local_Comm_ID<=0;
		recv_CM_loacl_CA_GUID<=0;
		recv_QPn_start_PSN<=0;
		recv_MAD_Transaction_ID<=0;
		recv_CM_Q_KEY<=0;
		recv_CM_QPN<=0;
	end
	else if(rx_pkt_cnt==0 && rx_s_axis_tvalid)	
	begin
		recv_CM_src_mac<=rx_s_axis_tdata[512-1-48-:48];
		recv_CM_src_ip<=rx_s_axis_tdata[512-1-128-80-:32];
	end
	else if(rx_pkt_cnt==1 && rx_s_axis_tvalid && (MAD_Attribute_ID==`RoCE_ConnectRequest))					
	begin
		recv_MAD_Transaction_ID<=rx_s_axis_tdata[511-6*8-:64];
		recv_MAD_Attribute_ID<=rx_s_axis_tdata[511-14*8-:16];
		recv_CM_local_Comm_ID<=rx_s_axis_tdata[511-22*8-:32];
		recv_CM_loacl_CA_GUID<=rx_s_axis_tdata[18*8+:64];
		recv_CM_Q_KEY<=rx_s_axis_tdata[10*8+:32];
		recv_CM_QPN<=rx_s_axis_tdata[8*7+:24];
	end
	else if(rx_pkt_cnt==1 && rx_s_axis_tvalid)					
	begin
		recv_MAD_Attribute_ID<=rx_s_axis_tdata[511-14*8-:16];
	end
	else if(rx_pkt_cnt==2 && rx_s_axis_tvalid && (recv_MAD_Attribute_ID==`RoCE_ConnectRequest))
	begin
		recv_QPn_start_PSN<=rx_s_axis_tdata[511-2*8-:24];
	end
	else if(rx_pkt_cnt==3 && rx_s_axis_tvalid && (recv_MAD_Attribute_ID==`RoCE_ConnectRequest))
	begin
		recv_QPn_IPv4<=rx_s_axis_tdata[256+2*8+:32];
	end



/*initial begin
	wait(cur_st==RDMA_WRITE_TEST_RX && rx_s_axis_tlast);
	#1000;
	$finish;
end*/

//initial
//begin
//	while(1) begin
//	@(posedge core_clk);
//		if(rx_s_axis_tvalid)
//			$display("rx_s_axis_tdata is: %h \n",rx_s_axis_tdata);
//	end
//end

endmodule
