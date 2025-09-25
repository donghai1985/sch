`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/02 15:21:00
// Design Name: 
// Module Name: rx_pkt_decode
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
//`include "XRNIC_REG_configuration.vh"
module rx_pkt_decode#
(
	parameter C_AXIS_DATA_WIDTH = 512,
	parameter C_AXIS_KEEP_WIDTH = C_AXIS_DATA_WIDTH/8,
	parameter CHANNEL_NUM=0
	
)(
	input                               			clk,
	input                               			rstn,
	
	output                               			rx_s_axis_tready,
	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)input  	[C_AXIS_DATA_WIDTH-1 : 0]    			rx_s_axis_tdata,
	input 	[C_AXIS_DATA_WIDTH/8-1:0]    			rx_s_axis_tkeep,
	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)input                               			rx_s_axis_tvalid,
	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)input                               			rx_s_axis_tlast,


	// synthesis translate_off		
	output logic									need_ACK,
	output logic	[23:0]							recv_PSN=0,
	// synthesis translate_on  
	input                               			arp_s_axis_tready,
	output logic  	[C_AXIS_DATA_WIDTH-1 : 0]    	arp_s_axis_tdata,
	output logic 	[C_AXIS_DATA_WIDTH/8-1:0]    	arp_s_axis_tkeep,
	output logic                               		arp_s_axis_tvalid,
	output logic                               		arp_s_axis_tlast,
	
	input                               			RoCE_CM_s_axis_tready,
	output logic  	[C_AXIS_DATA_WIDTH-1 : 0]    	RoCE_CM_s_axis_tdata,
	output logic 	[C_AXIS_DATA_WIDTH/8-1:0]    	RoCE_CM_s_axis_tkeep,
	output logic                               		RoCE_CM_s_axis_tvalid,
	output logic                               		RoCE_CM_s_axis_tlast,
	
	input                               			RoCE_cmac_s_axis_tready,
	output logic  	[C_AXIS_DATA_WIDTH-1 : 0]    	RoCE_cmac_s_axis_tdata,
	output logic 	[C_AXIS_DATA_WIDTH/8-1:0]    	RoCE_cmac_s_axis_tkeep,
	output logic                               		RoCE_cmac_s_axis_tvalid,
	output logic                               		RoCE_cmac_s_axis_tlast
);
    
function [C_AXIS_DATA_WIDTH-1 : 0] hdr_byte_reorder;
  input [C_AXIS_DATA_WIDTH-1 :0] in_hdr;
  integer i;
  for(i=0;i<C_AXIS_DATA_WIDTH;i=i+8) begin
    hdr_byte_reorder[C_AXIS_DATA_WIDTH-i-1 -: 8] = in_hdr[i+7 -: 8];
  end
endfunction

function [C_AXIS_KEEP_WIDTH-1 : 0] tkeep_reorder;
  input [C_AXIS_KEEP_WIDTH-1 :0] in_hdr;
  integer i;
  for(i=0;i<C_AXIS_KEEP_WIDTH;i=i+1) begin
    tkeep_reorder[C_AXIS_KEEP_WIDTH-i-1] = in_hdr[i];
  end
endfunction

logic [C_AXIS_DATA_WIDTH-1 : 0]				reorder_rx_s_axis_tdata;
logic [7:0]									recv_IB_opcode;
logic [23:0]								recv_dst_QP_num;

logic [5:0]									rx_pkt_cnt;

logic [47:0]								recv_dst_MAC;
logic [31:0]								recv_dst_IPv4;
logic [31:0]								arp_dst_IPv4;
(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)logic [15:0]								recv_eth_type;
logic [15:0]								recv_dst_port;

//logic [47:0]								recv_src_MAC;
//logic [31:0]								recv_src_IPv4;

logic										is_RoCE_CM;
(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)logic										is_RoCE_CNP;
logic										is_arp;
logic										is_RoCE_cmac;


logic										is_RoCE_CM_reg=0;
logic										is_RoCE_CNP_reg=0;
logic										is_arp_reg=0;
logic										is_RoCE_cmac_reg=0;

logic										pkt_valid;
logic										ip_mac_match;

logic	[C_AXIS_DATA_WIDTH-1 : 0]			m_axis_tdata		;
logic										m_axis_tdest		;
logic										m_axis_tid			;
logic	[C_AXIS_DATA_WIDTH/8-1:0]			m_axis_tkeep		;
logic										m_axis_tlast		;
logic	[C_AXIS_DATA_WIDTH/8-1:0]			m_axis_tstrb		;
logic										m_axis_tuser		;
logic										m_axis_tvalid		;

assign reorder_rx_s_axis_tdata=hdr_byte_reorder(rx_s_axis_tdata);


enum {PARSER_IDLE,DROP,WRITE_FIFO}cur_st,nxt_st;
enum {IDLE,ARP_RX,RoCE_CM_RX,RoCE_CMAC_RX}cur_tx_st,nxt_tx_st;
always@(posedge clk or negedge rstn)
	if(~rstn)						cur_st<=PARSER_IDLE;
	else							cur_st<=nxt_st;

always@(*)
begin
	nxt_st=cur_st;
	case(cur_st)
		PARSER_IDLE:	if(rx_s_axis_tvalid && rx_s_axis_tlast && pkt_valid)							nxt_st=PARSER_IDLE;
						else if(rx_s_axis_tvalid && pkt_valid)											nxt_st=WRITE_FIFO;
						else if(rx_s_axis_tvalid)														nxt_st=DROP;
		WRITE_FIFO:		if(rx_s_axis_tvalid && rx_s_axis_tlast)											nxt_st=PARSER_IDLE;
		DROP:			if(rx_s_axis_tvalid && rx_s_axis_tlast)											nxt_st=PARSER_IDLE;
		default:																						nxt_st=PARSER_IDLE;
	endcase
end

always@(posedge clk or negedge rstn)
	if(~rstn)										rx_pkt_cnt<=0;
	else if(rx_s_axis_tlast && rx_s_axis_tvalid)	rx_pkt_cnt<=0;
	else if(rx_s_axis_tvalid)						rx_pkt_cnt<=rx_pkt_cnt+1;

assign recv_eth_type=	(rx_s_axis_tvalid && rx_pkt_cnt==0)	?	reorder_rx_s_axis_tdata[512-12*8-1-:16]				:0;

assign recv_dst_MAC=	(rx_s_axis_tvalid && rx_pkt_cnt==0)	?	reorder_rx_s_axis_tdata[512-1-:48]					:0;
assign recv_dst_IPv4=	(rx_s_axis_tvalid && rx_pkt_cnt==0)	?	reorder_rx_s_axis_tdata[256+2*8-1-:32]				:0;
assign arp_dst_IPv4=	(rx_s_axis_tvalid && rx_pkt_cnt==0)	?	reorder_rx_s_axis_tdata[256-6*8-1-:32]				:0;
assign recv_IB_opcode=	(rx_s_axis_tvalid && rx_pkt_cnt==0)	?	reorder_rx_s_axis_tdata[128+8*6-1-:8]				:0;
assign recv_dst_QP_num=	(rx_s_axis_tvalid && rx_pkt_cnt==0)	?	reorder_rx_s_axis_tdata[5*8-1-:24]					:0;
assign recv_dst_port=	(rx_s_axis_tvalid && rx_pkt_cnt==0)	?	reorder_rx_s_axis_tdata[512-1-256-32-:16]			:0;


assign is_arp=(arp_dst_IPv4==(local_IPv4+CHANNEL_NUM)) && recv_eth_type==`ETH_TYPE_ARP;
assign is_RoCE_CM=ip_mac_match && recv_dst_port==16'h12b7 && recv_IB_opcode==`RoCE_OPCODE_UD_SEND_ONLY && recv_dst_QP_num==1;
assign is_RoCE_cmac=ip_mac_match && recv_dst_port==16'h12b7 && recv_IB_opcode[7:5]==`RoCE_OPCODE_RC;
assign is_RoCE_CNP=ip_mac_match && recv_dst_port==16'h12b7 && recv_IB_opcode==`RoCE_OPCODE_CNP;
assign pkt_valid=is_arp | is_RoCE_CM | is_RoCE_cmac | is_RoCE_CNP;



always@(posedge clk)
	if(is_arp && (!rx_s_axis_tlast))				is_arp_reg<=1;
	else if(rx_s_axis_tlast)						is_arp_reg<=0;

always@(posedge clk)
	if(is_RoCE_CM && (!rx_s_axis_tlast))			is_RoCE_CM_reg<=1;
	else if(rx_s_axis_tlast)						is_RoCE_CM_reg<=0;

always@(posedge clk)
	if(is_RoCE_CNP && (!rx_s_axis_tlast))			is_RoCE_CNP_reg<=1;
	else if(rx_s_axis_tlast)						is_RoCE_CNP_reg<=0;

always@(posedge clk)
	if(is_RoCE_cmac && (!rx_s_axis_tlast))			is_RoCE_cmac_reg<=1;
	else if(rx_s_axis_tlast)						is_RoCE_cmac_reg<=0;



// synthesis translate_off		
logic			is_RoCE_write_last;
logic			is_RoCE_send_only;
logic			is_RoCE_write_last_reg=0;
logic			is_RoCE_send_only_reg=0;
logic	[1:0]	ACK_opcode=0;

assign is_RoCE_write_last=recv_dst_port==16'h12b7 && recv_IB_opcode==`RoCE_OPCODE_WRITE_LAST;
assign is_RoCE_send_only=recv_dst_port==16'h12b7 && recv_IB_opcode==`RoCE_OPCODE_SEND_ONLY;

always@(posedge clk)
	if(is_RoCE_write_last && (!rx_s_axis_tlast))	is_RoCE_write_last_reg<=1;
	else if(rx_s_axis_tlast)						is_RoCE_write_last_reg<=0;
		
always@(posedge clk)
	if(is_RoCE_send_only && (!rx_s_axis_tlast))		is_RoCE_send_only_reg<=1;
	else if(rx_s_axis_tlast)						is_RoCE_send_only_reg<=0;

assign need_ACK=	rx_s_axis_tlast && (is_RoCE_write_last | is_RoCE_write_last_reg | is_RoCE_send_only | is_RoCE_send_only_reg);

always_ff@(posedge clk)
	if(rx_s_axis_tvalid && rx_pkt_cnt==0)
		recv_PSN<=reorder_rx_s_axis_tdata[511-384-24-:24];
		
always_ff@(posedge clk)
	if(rx_s_axis_tvalid && rx_pkt_cnt==0)
		ACK_opcode<=reorder_rx_s_axis_tdata[511-384-48-1:2];	
// synthesis translate_on  

assign ip_mac_match=	((recv_dst_IPv4==(local_IPv4+CHANNEL_NUM)) && (recv_dst_MAC==(Local_MAC+CHANNEL_NUM)))		?	1	:	0;

assign rx_s_axis_tready=	(is_arp_reg 		| is_arp)			?	arp_s_axis_tready			:
							(is_RoCE_CM_reg 	| is_RoCE_CM)		?	RoCE_CM_s_axis_tready		:
							(is_RoCE_cmac_reg 	| is_RoCE_cmac)		?	RoCE_cmac_s_axis_tready		:
							(is_RoCE_CNP_reg	| is_RoCE_CNP)		?	RoCE_cmac_s_axis_tready		:
							cur_st==DROP							?	1							:
							0;

assign RoCE_CM_s_axis_tdata=	(is_RoCE_CM_reg 	| is_RoCE_CM)	?	hdr_byte_reorder(rx_s_axis_tdata)	:	0;
assign RoCE_CM_s_axis_tvalid=	(is_RoCE_CM_reg 	| is_RoCE_CM)	?	rx_s_axis_tvalid					:	0;
assign RoCE_CM_s_axis_tkeep=	(is_RoCE_CM_reg 	| is_RoCE_CM)	?	tkeep_reorder(rx_s_axis_tkeep)		:	0;
assign RoCE_CM_s_axis_tlast=	(is_RoCE_CM_reg 	| is_RoCE_CM)	?	rx_s_axis_tlast						:	0;

assign arp_s_axis_tdata=	(is_arp_reg 		| is_arp)	?	hdr_byte_reorder(rx_s_axis_tdata)			:	0;
assign arp_s_axis_tvalid=	(is_arp_reg 		| is_arp)	?	rx_s_axis_tvalid							:	0;
assign arp_s_axis_tkeep=	(is_arp_reg 		| is_arp)	?	tkeep_reorder(rx_s_axis_tkeep)				:	0;
assign arp_s_axis_tlast=	(is_arp_reg 		| is_arp)	?	rx_s_axis_tlast								:	0;

assign RoCE_cmac_s_axis_tdata=	(is_RoCE_cmac_reg 	| is_RoCE_cmac | is_RoCE_CNP | is_RoCE_CNP_reg)	?	rx_s_axis_tdata						:	0;
assign RoCE_cmac_s_axis_tvalid=	(is_RoCE_cmac_reg 	| is_RoCE_cmac | is_RoCE_CNP | is_RoCE_CNP_reg)	?	rx_s_axis_tvalid					:	0;
assign RoCE_cmac_s_axis_tkeep=	(is_RoCE_cmac_reg 	| is_RoCE_cmac | is_RoCE_CNP | is_RoCE_CNP_reg)	?	rx_s_axis_tkeep						:	0;
assign RoCE_cmac_s_axis_tlast=	(is_RoCE_cmac_reg 	| is_RoCE_cmac | is_RoCE_CNP | is_RoCE_CNP_reg)	?	rx_s_axis_tlast						:	0;


//ila_rx_decode ila_rx_decode (
//	.clk		(clk), // input wire clk
//	.probe0		(reorder_rx_s_axis_tdata), // input wire [511:0]  probe0  
//	.probe1		(rx_s_axis_tvalid), // input wire [0:0]  probe1 
//	.probe2		(recv_eth_type), // input wire [15:0]  probe2 
//	.probe3		(cur_tx_st), // input wire [31:0]  probe3
//	.probe4		(arp_dst_IPv4),
//	.probe5		(is_arp),
//	.probe6		(recv_dst_port),
//	.probe7		(recv_IB_opcode),
//	.probe8		(recv_dst_QP_num),
//	.probe9		(is_RoCE_CM)
//);

/*initial
begin
	while(1) begin
	@(posedge core_clk);
		if(rx_s_axis_tvalid)
			$display("reorder_rx_s_axis_tdata is: %h \n",reorder_rx_s_axis_tdata);
	end
end*/

    
    
endmodule
