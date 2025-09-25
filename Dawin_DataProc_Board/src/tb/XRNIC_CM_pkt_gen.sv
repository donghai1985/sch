`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/26 13:58:12
// Design Name: 
// Module Name: XRNIC_CM_pkt_gen
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
`include "proj_define.vh"
//`include "XRNIC_Reg_Config.vh"
`include "XRNIC_REG_configuration.vh"
module XRNIC_CM_pkt_gen
# (
  parameter C_AXIS_DATA_WIDTH = 512
  )
(
 	input                               			core_clk,
 	input                               			core_aresetn,
 	input                               			tx_m_axis_tready,
 	output logic [C_AXIS_DATA_WIDTH-1 : 0]    		tx_m_axis_tdata,
 	output logic [C_AXIS_DATA_WIDTH/8-1:0]    		tx_m_axis_tkeep,
 	output logic                              		tx_m_axis_tvalid,
 	output logic                              		tx_m_axis_tlast,
 	
 	input											CM_Req_tx_en,
 	input											CM_ReadyToUse_en,
 	
 	input											CM_Req_tvalid,
 	input											CM_ReadyToUse_tvalid,
  
  	input 			[63:0] 							recv_MAD_Transaction_ID,
//	input  		 	[15:0] 							recv_MAD_Attribute_ID,
	input  		 	[31:0] 							recv_CM_local_Comm_ID,
	input  		 	[63:0]							recv_CM_loacl_CA_GUID,	
	input  			[47:0]							recv_CM_src_mac,
	input  			[31:0]							recv_CM_src_ip,
	
	input			[3:0]							local_QPN,
	input			[31:0]							local_Q_KEY,
	input			[15:0]							local_QPn_Partition_Key,

  	input											CM_reply_tx_en,
  	output logic									CM_reply_tx_done
  	
  	
  	
 
);


localparam PKT_LEN=16'd318;
localparam PKT_LEN_GEN=PKT_LEN/64*64+64;
localparam PKT_LEN_REMAIN=PKT_LEN_GEN-PKT_LEN;


function [PKT_LEN*8-1 : 0] hdr_byte_reorder;
  input [PKT_LEN*8-1 :0] in_hdr;
  integer i;
  for(i=0;i<PKT_LEN;i=i+1) begin
    hdr_byte_reorder[((PKT_LEN-i)*8)-1 -: 8] = in_hdr[((i+1)*8)-1 -: 8];
  end
endfunction

logic [24:0] chekcsum_i;
function [2*8-1 : 0] chk_sum_calc;
  input [18*8-1 :0] in_ipv4_hdr;
begin

  chekcsum_i = in_ipv4_hdr[18*8-1 -: 16] + in_ipv4_hdr[16*8-1 -: 16] +  in_ipv4_hdr[14*8-1 -: 16] + in_ipv4_hdr[12*8-1 -: 16] + in_ipv4_hdr[10*8-1 -: 16] + in_ipv4_hdr[8*8-1 -: 16] + 
                  in_ipv4_hdr[6*8-1 -: 16] + in_ipv4_hdr[4*8-1 -: 16] + in_ipv4_hdr[2*8-1 -: 16];
  if(|chekcsum_i[19:16]) begin
    chekcsum_i = chekcsum_i[15:0] + chekcsum_i[19:16];
  end
  chk_sum_calc = {~chekcsum_i[15:8],~chekcsum_i[7:0]};
end

endfunction


/***************************** Header fields	*****************************************************/


logic [15:0] 	IPV4_CHKSUM = 16'h245c;
logic [15:0] 	Total_Len_rd_resp = 16'h0130;

logic [15:0] 	Protocol_ID = 16'h0800;
logic [7:0] 	UDP_Protocol_ID = 8'h11;
logic [15:0] 	IPV4_CHKSUM_QP3 = 16'h76f8; // QP3
logic [15:0] 	IPV4_CHKSUM_QP2 = 16'h2510; //QP2
logic [15:0] 	Total_Len = PKT_LEN + 16'd4 - 16'd14;
logic [15:0] 	PKT_PAYLOAD_LEN=Total_Len-16'd20;

logic [7:0]		IB_opcode=`RoCE_OPCODE_UD_SEND_ONLY;
logic [23:0] 	CM_SRC_QP=24'h00_00_01;
logic [31:0] 	CM_SRC_Q_KEY=32'h80_01_00_00;
logic [7:0] 	MAD_BASE_VERSION=8'h01;
logic [7:0] 	MAD_Manage_class=8'h07;
logic [7:0] 	MAD_class_version=8'h02;
logic [7:0] 	MAD_methon=8'h03;	//send
logic [63:0] 	MAD_Transaction_ID=64'h00_00_00_03_d3_85_01_2e;
logic [15:0] 	MAD_Attribute_ID=`RoCE_ConnectRequest;
logic [31:0] 	MAD_Attribute_Modifier=32'h30_00_00_00;
logic [31:0] 	CM_local_Comm_ID=32'h44_44_00_03;
logic [31:0] 	CM_remote_Comm_ID=32'h2e_01_85_d3;
logic [63:0] 	CM_loacl_CA_GUID=64'h6c_b3_11_03_00_88_0e_b4;
logic [31:0] 	CM_local_Q_KEY=32'h12_34_56_78;
logic [23:0] 	CM_local_QPN=24'h00_00_02;
logic [7:0] 	CM_Responder_Resource=8'h00;
logic [23:0] 	CM_local_EECN=24'h00_00_00;
logic [7:0] 	CM_Init_Depth=8'h00;
logic [23:0] 	CM_remote_EECN=24'h00_00_00;
logic [4:0] 	CM_remote_resp_timeout=5'h16;
logic [1:0] 	CM_transport_service=2'b00;
logic [0:0] 	CM_end_to_end_flow_ctrl=1'b0;
//logic [23:0]	CM_start_PSN=24'haa_cf_a8;
logic [23:0]	CM_start_PSN;
logic [4:0]		CM_local_resp_timeout=5'h16;
logic [2:0]		CM_retry_cnt=3'h0;
logic [15:0]	CM_P_KEY=16'hff_ff;
logic [3:0]		CM_payload_MTU=4'h5;
logic [0:0]		CM_RDC_exist=1'b0;
logic [2:0]		CM_RNR_retry_cnt=3'h0;
logic [3:0]		CM_QP3_Max_retry_cnt=4'hf;
logic [0:0]		CM_SRQ=1'b0;
logic [2:0]		CM_Extended_transport=3'h0;
logic [15:0]	CM_pri_local_port_LID=16'hff_ff;
logic [15:0]	CM_pri_remote_port_LID=16'hff_ff;
logic [31:0]	CM_pri_local_port_GID=IMC_0_ETH0_IP;
logic [31:0]	CM_pri_remote_port_GID=local_IPv4;
logic [19:0]	CM_pri_flow_label=20'h00_99_a;
logic [5:0]		CM_pri_pkt_rate=6'h00;
logic [7:0]		CM_pri_QP3_Traffic_class=8'h00;
logic [7:0]		CM_pri_hop_limit=8'h40;
logic [3:0]		CM_pri_SL=4'h0;
logic [0:0]		CM_pri_subnet_local=1'b0;
logic [4:0]		CM_pri_ack_timeout=5'h13;
logic [351:0]	CM_alter_content=352'h0;
logic [3:0]		CM_IP_major_version=4'h0;
logic [3:0]		CM_IP_minor_version=4'h0;
logic [3:0]		CM_IP_version=4'h4;
logic [15:0]	CM_IP_src_port=16'hd2d5;
logic [31:0]	CM_IP_src_ip=IMC_0_ETH0_IP;
logic [31:0]	CM_IP_dst_ip=local_IPv4;
logic [447:0]	CM_IP_consumer_data=448'h0;
/***********************************************************************************************************/
//assign start_PSN=CM_start_PSN;


logic [PKT_LEN*8-1:0] 			CM_req_pkt;
logic [PKT_LEN*8-1:0] 			CM_reply_pkt;
logic [PKT_LEN*8-1:0] 			CM_ReadyToUse_pkt;
logic [PKT_LEN_GEN*8-1:0]		pkt_tx;
logic [9:0]						remain_tx_cnt;
logic [9:0]						pkt_tx_cnt;


logic [23:0] 					rcvd_qp_num;

logic                               	tx_m_usr_axis_tready;
logic [C_AXIS_DATA_WIDTH-1 : 0]    		tx_m_usr_axis_tdata;
logic [C_AXIS_DATA_WIDTH/8-1:0]    		tx_m_usr_axis_tkeep;
logic                              		tx_m_usr_axis_tvalid;
logic                              		tx_m_usr_axis_tlast;


enum {IDLE,CM_TX,CM_TX_DONE,CM_RESP_TX} cur_st,nxt_st;
logic [7:0]	RoCE_OPCODE;
//assign RoCE_OPCODE=wqe_proc_top_m_axis_tdata[`RoCE_OPCODE_POS];

logic [9:0]	ack_send_cnt;

always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn) 		cur_st<=IDLE;
	else					cur_st<=nxt_st;

always@(*)
begin
	nxt_st=cur_st;		
    case(cur_st)
    	IDLE:		if(CM_Req_tx_en)										nxt_st=CM_TX;
    				else if(CM_reply_tx_en)									nxt_st=CM_TX;
    				else if(CM_ReadyToUse_en)								nxt_st=CM_TX;
    	CM_TX:		if(tx_m_usr_axis_tlast && tx_m_usr_axis_tready)			nxt_st=CM_TX_DONE;
    	CM_TX_DONE:															nxt_st=IDLE;
    				/*if(CM_Req_tx_en && CM_Req_tvalid)						nxt_st=IDLE;
    				else if(CM_reply_tx_en)									nxt_st=IDLE;
    				else if(CM_ReadyToUse_en && CM_ReadyToUse_tvalid)		nxt_st=IDLE;
    				else													nxt_st=CM_TX_DONE;*/
//    	CM_RESP_TX:	if(CM_resp_en)											nxt_st=CM_TX;
    	default:															nxt_st=IDLE;
    endcase
end

assign CM_reply_tx_done=cur_st==CM_TX_DONE && CM_reply_tx_en;
	

assign CM_req_pkt = {Local_MAC,IMC_0_ETH0_MAC_SIM,Protocol_ID,8'h45,8'h02,Total_Len,16'h43f9,16'h4000,8'h40,UDP_Protocol_ID,chk_sum_calc({8'h45,8'h02,Total_Len,16'h43f9,16'h4000,8'h40,UDP_Protocol_ID,IMC_0_ETH0_IP,local_IPv4}),IMC_0_ETH0_IP,local_IPv4,UDP_dst_port,UDP_src_port,PKT_PAYLOAD_LEN,16'h0000,IB_opcode,8'h40,16'hffff,8'h00,24'h000001,8'h00,24'h1,
		CM_SRC_Q_KEY,8'h00,CM_SRC_QP,MAD_BASE_VERSION,MAD_Manage_class,MAD_class_version,MAD_methon,16'h0000,16'h0000,MAD_Transaction_ID,MAD_Attribute_ID,16'h0000,MAD_Attribute_Modifier,
		CM_remote_Comm_ID,32'h00_00_15_b3,48'h00_00_00_00_01_06,UDP_src_port,CM_loacl_CA_GUID,32'h00_00_00_00,CM_local_Q_KEY,CM_local_QPN,CM_Responder_Resource,CM_local_EECN,CM_Init_Depth,CM_remote_EECN,CM_remote_resp_timeout,CM_transport_service,CM_end_to_end_flow_ctrl,CM_start_PSN,CM_local_resp_timeout,CM_retry_cnt,CM_P_KEY,CM_payload_MTU,CM_RDC_exist,
		CM_RNR_retry_cnt,CM_QP3_Max_retry_cnt,CM_SRQ,CM_Extended_transport,
		CM_pri_local_port_LID,CM_pri_remote_port_LID,80'h0,16'hff_ff,CM_pri_local_port_GID,80'h0,16'hff_ff,CM_pri_remote_port_GID,CM_pri_flow_label,6'h00,CM_pri_pkt_rate,CM_pri_QP3_Traffic_class,CM_pri_hop_limit,CM_pri_SL,CM_pri_subnet_local,3'b0,CM_pri_ack_timeout,3'b0,
		CM_alter_content,
		CM_IP_major_version,CM_IP_minor_version,CM_IP_version,4'h0,CM_IP_src_port,96'h0,CM_IP_src_ip,96'h0,CM_IP_dst_ip,CM_IP_consumer_data};

assign CM_reply_pkt={recv_CM_src_mac,Local_MAC,Protocol_ID,8'h45,8'h02,Total_Len,16'h43f9,16'h4000,8'h40,UDP_Protocol_ID,chk_sum_calc({8'h45,8'h02,Total_Len,16'h43f9,16'h4000,8'h40,UDP_Protocol_ID,local_IPv4,recv_CM_src_ip}),local_IPv4,recv_CM_src_ip,UDP_src_port,UDP_dst_port,PKT_PAYLOAD_LEN,16'h0000,IB_opcode,8'h40,16'hffff,8'h00,24'h000001,8'h00,24'h1,
		CM_SRC_Q_KEY,8'h00,CM_SRC_QP,MAD_BASE_VERSION,MAD_Manage_class,MAD_class_version,MAD_methon,16'h0000,16'h0000,recv_MAD_Transaction_ID,`RoCE_ConnectReply,16'h0000,MAD_Attribute_Modifier,
		CM_local_Comm_ID,recv_CM_local_Comm_ID,local_Q_KEY,20'h0,local_QPN,8'h0,CM_local_EECN,8'h0,QPn_Send_Q_PSN,8'h00,8'h00,CM_Init_Depth,8'h80,8'h00,recv_CM_loacl_CA_GUID,1568'h0};

assign CM_ReadyToUse_pkt={Local_MAC,IMC_0_ETH0_MAC_SIM,Protocol_ID,8'h45,8'h02,Total_Len,16'h43f9,16'h4000,8'h40,UDP_Protocol_ID,chk_sum_calc({8'h45,8'h02,Total_Len,16'h43f9,16'h4000,8'h40,UDP_Protocol_ID,IMC_0_ETH0_IP,local_IPv4}),IMC_0_ETH0_IP,local_IPv4,UDP_dst_port,UDP_src_port,PKT_PAYLOAD_LEN,16'h0000,IB_opcode,8'h40,16'hffff,8'h00,24'h000001,8'h00,24'h2,
		CM_SRC_Q_KEY,8'h00,CM_SRC_QP,MAD_BASE_VERSION,MAD_Manage_class,MAD_class_version,MAD_methon,16'h0000,16'h0000,MAD_Transaction_ID,`RoCE_ReadyToUse,16'h0000,MAD_Attribute_Modifier,
		CM_remote_Comm_ID,CM_local_Comm_ID,1792'h0};

initial begin
wait(CM_reply_tx_en);
$display("CM_reply_pkt is: %h",CM_reply_pkt);
end

always@(posedge core_clk or negedge core_aresetn) 
	if(!core_aresetn)
		pkt_tx<=0;
	else if(cur_st==IDLE && CM_Req_tx_en)
		pkt_tx<=hdr_byte_reorder(CM_req_pkt);
	else if(cur_st==IDLE && CM_reply_tx_en)
		pkt_tx<=hdr_byte_reorder(CM_reply_pkt);
	else if(cur_st==IDLE && CM_ReadyToUse_en)
		pkt_tx<=hdr_byte_reorder(CM_ReadyToUse_pkt);

always @(posedge core_clk or negedge core_aresetn)
    if(~core_aresetn)
    	remain_tx_cnt        		<= 'b0;
    else if(cur_st==IDLE && CM_Req_tx_en)
    	remain_tx_cnt<=PKT_LEN;
    else if(cur_st==IDLE && CM_reply_tx_en)
    	remain_tx_cnt<=PKT_LEN;
    else if(cur_st==IDLE && CM_ReadyToUse_en)
    	remain_tx_cnt<=PKT_LEN;
    else if(cur_st==CM_TX && tx_m_usr_axis_tvalid && tx_m_usr_axis_tready && (remain_tx_cnt>64))
    	remain_tx_cnt<=remain_tx_cnt-64;

always@(posedge core_clk or negedge core_aresetn)
	if(~core_aresetn)
		pkt_tx_cnt 			<=0;
	else if(cur_st==CM_TX && tx_m_usr_axis_tvalid && tx_m_usr_axis_tready && tx_m_usr_axis_tlast)
		pkt_tx_cnt<=0;	
	else if(cur_st==CM_TX && tx_m_usr_axis_tvalid && tx_m_usr_axis_tready)
		pkt_tx_cnt<=pkt_tx_cnt+1;
	

assign tx_m_usr_axis_tlast=		(cur_st==CM_TX && tx_m_usr_axis_tvalid && tx_m_usr_axis_tready && (remain_tx_cnt<=64));
assign tx_m_usr_axis_tvalid=	(cur_st==CM_TX)?1:0;
assign tx_m_usr_axis_tdata=		pkt_tx[pkt_tx_cnt*512+:512];
assign tx_m_usr_axis_tkeep=		(cur_st==CM_TX && tx_m_usr_axis_tvalid && (remain_tx_cnt<=64))	?	(64'hffff_ffff_ffff_ffff >> (64-remain_tx_cnt))	:
								(cur_st==CM_TX && tx_m_usr_axis_tvalid)	?							64'hffff_ffff_ffff_ffff 						:
								0;

exdes_crc_wrap inst_crc  (
   .core_clk           (core_clk),
   .core_rst           (~core_aresetn),
   .m_axis_tdata       (tx_m_axis_tdata),
   .m_axis_tkeep       (tx_m_axis_tkeep),
   .m_axis_tvalid      (tx_m_axis_tvalid),
   .m_axis_tready      (tx_m_axis_tready),
   .m_axis_tlast       (tx_m_axis_tlast),
   .s_axis_tdata       (tx_m_usr_axis_tdata),
   .s_axis_tkeep       (tx_m_usr_axis_tkeep),
   .s_axis_tvalid      (tx_m_usr_axis_tvalid),
   .s_axis_tlast       (tx_m_usr_axis_tlast),
   .s_axis_tready      (tx_m_usr_axis_tready)
);

`ifdef DEBUG_ILA
ila_CM_crc ila_CM_crc (
	.clk		(core_clk), 		// input wire clk
	.probe0		(tx_m_axis_tdata), 	// input wire [511:0]  probe0  
	.probe1		(tx_m_axis_tkeep), 	// input wire [63:0]  probe1 
	.probe2		(tx_m_axis_tvalid), // input wire [0:0]  probe2 
	.probe3		(tx_m_axis_tready), // input wire [0:0]  probe3 
	.probe4		(tx_m_axis_tlast), 	// input wire [0:0]  probe4 
	.probe5		(CM_reply_tx_en), 	// input wire [0:0]  probe5 
	.probe6		(remain_tx_cnt) 	// input wire [9:0]  probe6 
);
`endif

endmodule
