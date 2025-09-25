`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/25 15:33:10
// Design Name: 
// Module Name: CM_host_pkt_gen
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

`include "XRNIC_REG_configuration.vh"
`include "Board_define.vh"
module RoCE_host_pkt_gen
#(
	parameter										C_AXIS_DATA_WIDTH=512,
	parameter										CHANNEL_NUM=0
)(

	input 											clk,
	input 											rst,
	
	input                               			m_axis_tready,
	output  [C_AXIS_DATA_WIDTH-1 : 0]    			m_axis_tdata,
	output 	[C_AXIS_DATA_WIDTH/8-1:0]    			m_axis_tkeep,
	output                               			m_axis_tvalid,
	output                               			m_axis_tlast,
	
	input											CM_REQ_en,
	input											CM_RTS_en,
	input											RC_SEND_en,
	input											RC_ACK_en,
	input											need_ACK,
	
//	input	[47:0]									host_MAC,
//	input	[31:0]									host_IP,
	input	[23:0]									fpga_QPN,
	input	[23:0]									recv_PSN
//	input	[23:0]									init_PSN
	
);


typedef enum logic [2:0] {
  	IDLE,
	CM_TX,
	RC_SEND_TX,
	RC_ACK_TX,
  	FINISH
} state_t;

state_t 								cur_st, nxt_st;

logic [ETH_CM_len*8-1:0]				CM_pkt_buffer;
logic [ETH_RC_SEND_len*8-1:0]			RC_SEND_pkt_buffer;
logic [ETH_ACK_len*8-1:0]				RC_ACK_pkt_buffer;
logic [3:0]     						header_words;
logic [9:0]								remain_len;
logic									RC_SEND_done;

logic                               	m_usr_axis_tready;
logic  	[C_AXIS_DATA_WIDTH-1 : 0]    	m_usr_axis_tdata;
logic 	[C_AXIS_DATA_WIDTH/8-1:0]    	m_usr_axis_tkeep;
logic                               	m_usr_axis_tvalid;
logic                               	m_usr_axis_tlast;

logic	[9:0]							pkt_send_cnt;

logic [23:0]	host_qpn=24'h8;
logic [23:0]	host_start_psn=24'hac_ca_bd;
logic [23:0]	cur_host_PSN;
logic [23:0]	fpga_start_PSN;
logic [23:0]	cur_ACK_PSN=0;
logic			first_ACK=1;
//logic [23:0]	fpga_qpn=24'h2;

logic	[23:0]									cur_IMC0_PSN;
logic	[23:0]									cur_IMC1_PSN;
logic	[23:0]									cur_IMC2_PSN;

logic	[31:0]									host_IP;
logic	[47:0]									host_MAC;
logic	[23:0]									cur_MSN=0;

`include "ETH_pkt_define.sv"
//rocev2_CM_pkt_t 			CM_req_pkt_eth0_imc0;
//rocev2_CM_pkt_t 			CM_req_pkt_eth0_imc1;
//rocev2_CM_pkt_t 			CM_req_pkt_eth0_imc2;
rocev2_CM_req_pkt_t 		CM_req_pkt;
//rocev2_CM_req_pkt_t 		CM_req_pkt_test;
//rocev2_CM_pkt_t 			CM_rts_pkt_eth0_imc0;
//rocev2_CM_pkt_t 			CM_rts_pkt_eth0_imc1;
//rocev2_CM_pkt_t 			CM_rts_pkt_eth0_imc2;
rocev2_CM_rts_pkt_t 		CM_rts_pkt;
//rocev2_RC_SEND_pkt_t		RC_SEND_pkt_eth0_imc0;
//rocev2_RC_SEND_pkt_t		RC_SEND_pkt_eth0_imc1;
//rocev2_RC_SEND_pkt_t		RC_SEND_pkt_eth0_imc2;
rocev2_RC_SEND_pkt_t		RC_SEND_pkt;
rocev2_RC_ACK_pkt_t			RC_ACK_pkt;
rocev2_rc_send_connect_t	host_CM_MSG;

assign host_CM_MSG=	RC_SEND_connect_pkt_build(0,CHANNEL_NUM,fpga_QPN);
assign CM_req_pkt=	CM_req_pkt_build(host_MAC+CHANNEL_NUM,host_IP+CHANNEL_NUM,Local_MAC+CHANNEL_NUM,local_IPv4+CHANNEL_NUM,cur_host_PSN,host_qpn,fpga_start_PSN);
assign CM_rts_pkt=	CM_rts_pkt_build(host_MAC+CHANNEL_NUM,host_IP+CHANNEL_NUM,Local_MAC+CHANNEL_NUM,local_IPv4+CHANNEL_NUM,cur_host_PSN+1);
assign RC_SEND_pkt=	RC_SEND_pkt_build(host_MAC+CHANNEL_NUM,host_IP+CHANNEL_NUM,Local_MAC+CHANNEL_NUM,local_IPv4+CHANNEL_NUM,cur_host_PSN,fpga_QPN,host_CM_MSG);
assign RC_ACK_pkt=	RC_ACK_pkt_build(host_MAC+CHANNEL_NUM,host_IP+CHANNEL_NUM,Local_MAC+CHANNEL_NUM,local_IPv4+CHANNEL_NUM,recv_PSN,fpga_QPN,cur_MSN);

//always_ff @(posedge clk or posedge rst) 
//	if(rst)							first_ACK<=1;
//	else if(RC_ACK_en)				first_ACK<=0;

//always_ff @(posedge clk or posedge rst) 
//	if(rst)								cur_ACK_PSN<=0;
//	else if(RC_ACK_en && first_ACK)		cur_ACK_PSN<=fpga_start_PSN;	//+15
//	else if(RC_ACK_en)					cur_ACK_PSN<=cur_ACK_PSN+1;

always_ff @(posedge clk or posedge rst) 
	if(rst)								cur_MSN<=0;
	else if(need_ACK)					cur_MSN<=cur_MSN+1;

always_ff @(posedge clk or posedge rst) 
	if(rst)									cur_IMC0_PSN<=IMC_0_init_PSN;
	else if(CM_REQ_en && fpga_QPN==2)		cur_IMC0_PSN<=IMC_0_init_PSN;
	else if(RC_SEND_done && fpga_QPN==2)	cur_IMC0_PSN<=cur_IMC0_PSN+1;

always_ff @(posedge clk or posedge rst) 
	if(rst)									cur_IMC1_PSN<=IMC_1_init_PSN;
	else if(CM_REQ_en && fpga_QPN==3)		cur_IMC1_PSN<=IMC_1_init_PSN;
	else if(RC_SEND_done && fpga_QPN==3)	cur_IMC1_PSN<=cur_IMC1_PSN+1;

always_ff @(posedge clk or posedge rst) 
	if(rst)									cur_IMC2_PSN<=IMC_2_init_PSN;
	else if(CM_REQ_en && fpga_QPN==4)		cur_IMC2_PSN<=IMC_2_init_PSN;
	else if(RC_SEND_done && fpga_QPN==4)	cur_IMC2_PSN<=cur_IMC2_PSN+1;

assign cur_host_PSN=	(fpga_QPN==2)	?	cur_IMC0_PSN	:
						(fpga_QPN==3)	?	cur_IMC1_PSN	:
						(fpga_QPN==4)	?	cur_IMC2_PSN	:
						0;

// Ö÷×´Ì¬»ú ----------------------------------------------------------
always_ff @(posedge clk or posedge rst) 
  if (rst)     	cur_st <= IDLE;
  else			cur_st <= nxt_st;

always_comb
begin
	nxt_st = cur_st;
    case(cur_st)
      IDLE:         if (CM_REQ_en) 			nxt_st = CM_TX;
      				else if(CM_RTS_en)		nxt_st = CM_TX;
      				else if(RC_SEND_en)		nxt_st = RC_SEND_TX;
      				else if(RC_ACK_en)		nxt_st = RC_ACK_TX;
      CM_TX:		if (remain_len <= 64)	nxt_st = FINISH;
      RC_SEND_TX:	if (remain_len <= 64)	nxt_st = FINISH;
      RC_ACK_TX:	if (remain_len <= 64)	nxt_st = IDLE;
      FINISH: 								nxt_st = IDLE;
      default:								nxt_st = IDLE;
    endcase
end

always_ff @(posedge clk or posedge rst) 
	if(rst)							remain_len<=0;
	else if(CM_REQ_en)				remain_len<=ETH_CM_len;
	else if(CM_RTS_en)				remain_len<=ETH_CM_len;
	else if(RC_SEND_en)				remain_len<=ETH_RC_SEND_len;
	else if(RC_ACK_en)				remain_len<=ETH_ACK_len;
	else if(cur_st==CM_TX)			remain_len<=remain_len-64;
	else if(cur_st==RC_SEND_TX)		remain_len<=remain_len-64;
//	else if(cur_st==IDLE)	remain_len<=54+PAYLOAD_LEN;

always_ff @(posedge clk or posedge rst) 
	if(rst)										CM_pkt_buffer<=0;
//	else if(CM_REQ_en && pkt_send_cnt==0)		CM_pkt_buffer<=CM_req_pkt_eth0_imc0;
//	else if(CM_REQ_en && pkt_send_cnt==1)		CM_pkt_buffer<=CM_req_pkt_eth0_imc1;
//	else if(CM_REQ_en && pkt_send_cnt==2)		CM_pkt_buffer<=CM_req_pkt_eth0_imc2;
//	else if(CM_RTS_en && pkt_send_cnt==1)		CM_pkt_buffer<=CM_rts_pkt_eth0_imc0;
//	else if(CM_RTS_en && pkt_send_cnt==2)		CM_pkt_buffer<=CM_rts_pkt_eth0_imc1;
//	else if(CM_RTS_en && pkt_send_cnt==3)		CM_pkt_buffer<=CM_rts_pkt_eth0_imc2;
	else if(CM_REQ_en)							CM_pkt_buffer<=CM_req_pkt_build(host_MAC+CHANNEL_NUM,host_IP+CHANNEL_NUM,Local_MAC+CHANNEL_NUM,local_IPv4+CHANNEL_NUM,cur_host_PSN,host_qpn,fpga_start_PSN);//CM_req_pkt;
	else if(CM_RTS_en)							CM_pkt_buffer<=CM_rts_pkt_build(host_MAC+CHANNEL_NUM,host_IP+CHANNEL_NUM,Local_MAC+CHANNEL_NUM,local_IPv4+CHANNEL_NUM,cur_host_PSN+1);//CM_rts_pkt;
	else if(cur_st==CM_TX)						CM_pkt_buffer<=CM_pkt_buffer<<C_AXIS_DATA_WIDTH;
	
always_ff @(posedge clk or posedge rst) 
	if(rst)										RC_SEND_pkt_buffer<=0;
	else if(RC_SEND_en)							RC_SEND_pkt_buffer<=RC_SEND_pkt;
	else if(cur_st==RC_SEND_TX)					RC_SEND_pkt_buffer<=RC_SEND_pkt_buffer<<C_AXIS_DATA_WIDTH;

always_ff @(posedge clk or posedge rst) 
	if(rst)										RC_ACK_pkt_buffer<=0;
	else if(RC_ACK_en)							RC_ACK_pkt_buffer<=RC_ACK_pkt;
	else if(cur_st==RC_ACK_TX)					RC_ACK_pkt_buffer<=RC_ACK_pkt<<C_AXIS_DATA_WIDTH;


assign m_usr_axis_tlast=	m_usr_axis_tvalid && (remain_len<=64);
assign m_usr_axis_tvalid=	(cur_st==CM_TX) | (cur_st==RC_SEND_TX) | (cur_st==RC_ACK_TX);
assign m_usr_axis_tdata = 	(cur_st==CM_TX) 		? 	hdr_byte_reorder(CM_pkt_buffer[318*8-1-:512])		:
							(cur_st==RC_SEND_TX)	?	hdr_byte_reorder(RC_SEND_pkt_buffer[ETH_RC_SEND_len*8-1-:512])	:
							(cur_st==RC_ACK_TX)		?	hdr_byte_reorder({RC_ACK_pkt_buffer[ETH_ACK_len*8-1:0],{512-ETH_ACK_len*8{1'd0}}})	:
							0;
assign m_usr_axis_tkeep = (m_usr_axis_tlast) ? (64'hFFFF_FFFF_FFFF_FFFF >> (64 - remain_len)) : 64'hFFFF_FFFF_FFFF_FFFF ;
assign RC_SEND_done=((cur_st==RC_SEND_TX) && (remain_len <= 64));

always_ff@(posedge clk or posedge rst)
	if(rst)							pkt_send_cnt<=0;
	else if(CM_REQ_en)				pkt_send_cnt<=pkt_send_cnt+1;


exdes_crc_wrap inst_crc  (
   .core_clk           (clk),
   .core_rst           (rst),
   .m_axis_tdata       (m_axis_tdata),
   .m_axis_tkeep       (m_axis_tkeep),
   .m_axis_tvalid      (m_axis_tvalid),
   .m_axis_tready      (m_axis_tready),
   .m_axis_tlast       (m_axis_tlast),
   .s_axis_tdata       (m_usr_axis_tdata),
   .s_axis_tkeep       (m_usr_axis_tkeep),
   .s_axis_tvalid      (m_usr_axis_tvalid),
   .s_axis_tlast       (m_usr_axis_tlast),
   .s_axis_tready      (m_usr_axis_tready)
);

QPn_LUT QPn_LUT
(
	.sim_fpga_QPn			(fpga_QPN		),
	.sim_IP					(host_IP		),
	.sim_MAC				(host_MAC		),
	.sim_host_QPn			(host_qpn		),
	.sim_fpga_start_PSN		(fpga_start_PSN )
);


endmodule
