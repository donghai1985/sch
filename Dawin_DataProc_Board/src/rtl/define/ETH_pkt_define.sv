`timescale 1ns / 1ps
`include "XRNIC_define.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/26 13:39:43
// Design Name: 
// Module Name: ETH_pkt_define
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
localparam ETH_CM_len=16'd318;
localparam ETH_RC_SEND_payload_len=104;
localparam ETH_ACK_len='d58;
localparam ETH_RC_SEND_len=54+ETH_RC_SEND_payload_len;


localparam e_MSG_MR=1;
localparam e_MSG_START=8'h1;
localparam e_MSG_STOP=8'h2;
localparam host_MR_addr0_sim=64'h7f8071fcb010;
localparam host_MR_len0_sim=64'h280000000;
localparam host_MR_len0_RKEY=32'h201f00;
localparam host_MR_addr1_sim=64'h5ac071674100;
localparam host_MR_len1_sim=64'h0;
localparam host_MR_len1_RKEY=32'h304d00;

typedef struct packed {
  // ETH 头
  logic [47:0] 	mac_dst;
  logic [47:0] 	mac_src;
  logic [15:0] 	eth_type;
  
  // IPv4头 (20 bytes)
  logic [3:0]  	ip_ver;        // 4'h4
  logic [3:0]  	ip_head_len;        // 5 (5*4=20 bytes)
  logic [7:0]  	ip_dscp_ecn;
  logic [15:0] 	ip_total_len;
  logic [15:0] 	ip_id;
  logic [2:0]  	ip_flags;
  logic [12:0] 	ip_frag_offset;
  logic [7:0]  	ip_ttl;
  logic [7:0]  	ip_proto;      // 17 (UDP)
  logic [15:0] 	ip_csum;
  logic [31:0] 	ip_src;
  logic [31:0] 	ip_dst;
  } ipv4_header_t;
  
typedef struct packed {
  // UDP头 (8 bytes)
  logic [15:0] 	udp_sport;     // 0x12B7 (4791)
  logic [15:0] 	udp_dport;     // 0x12B7
  logic [15:0] 	udp_len;       // UDP头+BTH+Payload
  logic [15:0] 	udp_csum;      // 可置零
  } udp_header_t;

typedef struct packed {
  // BTH头 (12 bytes) - 精确到bit的协议规范实现
  logic [7:0]  	bth_opcode;    // [7:0]
  logic        	bth_se;        // [7]
  logic        	bth_migreq;    // [6]
  logic [1:0]  	bth_padcnt;    // [5:4]
  logic [3:0]  	bth_tver;      // [3:0] + [4]保留位（实际3位有效）
  logic [15:0] 	bth_pkey;      // Partition Key [15:0]
  logic [7:0]  	bth_resv1;     // 保留字节
  logic [23:0]	bth_dqpn;      // Dest QP Number [23:0]
  logic			bth_ack_req;
  logic [6:0] 	bth_resv2;     // 最后2字节保留
  logic [23:0] 	bth_psn;       // PSN [23:0]
} rocev2_bth_header_t;

typedef struct packed {
//DETH
	logic [31:0] 	Q_KEY;
	logic [7:0] 	DETH_reserved;
	logic [23:0] 	QPN;
	//MAD HEADER
	logic [7:0]		MAD_Base_ver;
	logic [7:0]		MAD_Management_class;
	logic [7:0]		MAD_Class_ver;
	logic [7:0]		MAD_Method;
	logic [15:0]	MAD_Status;
	logic [15:0]	MAD_Specific;
	logic [63:0]	MAD_Trans_ID;
	logic [15:0]	MAD_Attri_ID;
	logic [15:0] 	MAD_reserved;
	logic [31:0]	MAD_Attri_Modifer;
	//CM Connect
	logic [31:0]	CM_Comm_ID;
	logic [31:0]	CM_reserved_1;
	logic [39:0]	CM_Prefix;
	logic [7:0]		CM_Protocol;
	logic [15:0]	CM_DPort;
	logic [63:0]	CM_Local_CA_GUID;
	logic [31:0]	CM_reserved_2;
	logic [31:0]	CM_Local_Q_Key;
	logic [23:0]	CM_Local_QPN;
	logic [7:0]		CM_Resp_resource;
	logic [23:0]	CM_Local_EECN;
	logic [7:0]		CM_Init_Depth;
	logic [23:0] 	CM_remote_EECN;
	logic [4:0] 	CM_remote_resp_timeout;
	logic [1:0] 	CM_transport_service;
	logic [0:0] 	CM_end_to_end_flow_ctrl;
	//logic [23:0]	CM_start_PSN=24'haa_cf_a8;
	logic [23:0]	CM_start_PSN;
	logic [4:0]		CM_local_resp_timeout;
	logic [2:0]		CM_retry_cnt;
	logic [15:0]	CM_P_KEY;
	logic [3:0]		CM_payload_MTU;
	logic [0:0]		CM_RDC_exist;
	logic [2:0]		CM_RNR_retry_cnt;
	logic [3:0]		CM_QP3_Max_retry_cnt;
	logic [0:0]		CM_SRQ;
	logic [2:0]		CM_Extended_transport;
	logic [15:0]	CM_pri_local_port_LID;
	logic [15:0]	CM_pri_remote_port_LID;
	logic [95:0]	CM_pri_reserved_0;
	logic [31:0]	CM_pri_local_port_GID;
	logic [95:0]	CM_pri_reserved_1;
	logic [31:0]	CM_pri_remote_port_GID;
	logic [19:0]	CM_pri_flow_label;
	logic [5:0]		CM_reserved_3;
	logic [5:0]		CM_pri_pkt_rate;
	logic [7:0]		CM_pri_Traffic_class;
	logic [7:0]		CM_pri_hop_limit;
	logic [3:0]		CM_pri_SL;
	logic [0:0]		CM_pri_subnet_local;
	logic [2:0]		CM_reserved_4;
	logic [4:0]		CM_pri_ACK_timeout;
	logic [2:0]		CM_reserved_5;
	//Alter	
	logic [15:0]	CM_Alter_Local_LID;
	logic [15:0]	CM_Alter_Remote_LID;
	logic [127:0]	CM_Alter_Local_GID;
	logic [127:0]	CM_Alter_Remote_GID;
	logic [19:0]	CM_Alter_flow_label;
	logic [5:0]		CM_Alter_reserved;
	logic [5:0]		CM_Alter_pkt_rate;
	logic [7:0]		CM_Alter_traffic_class;
	logic [7:0]		CM_Alter_Hop_limit;
	logic [3:0]		CM_Alter_SL;
	logic [0:0]		CM_Alter_Subnet_local;
	logic [2:0]		CM_Alter_reserved_2;
	logic [4:0]		CM_Alter_ACK_timeout;
	logic [2:0]		CM_Alter_reserved_3;
	//IP CM Private DATA
	logic [3:0]		CM_IP_major_version;
	logic [3:0]		CM_IP_minor_version;
	logic [3:0]		CM_IP_version;
	logic [3:0]		CM_IP_reserved;
	logic [15:0]	CM_IP_src_port;
	logic [95:0]	CM_reserved_6;
	logic [31:0]	CM_IP_src_ip;
	logic [95:0]	CM_reserved_7;
	logic [31:0]	CM_IP_dst_ip;
	logic [447:0]	CM_IP_consumer_data;
} rocev2_CM_req_header_t;

typedef struct packed {
//DETH
	logic [31:0] 	Q_KEY;
	logic [7:0] 	DETH_reserved;
	logic [23:0] 	QPN;
	//MAD HEADER
	logic [7:0]		MAD_Base_ver;
	logic [7:0]		MAD_Management_class;
	logic [7:0]		MAD_Class_ver;
	logic [7:0]		MAD_Method;
	logic [15:0]	MAD_Status;
	logic [15:0]	MAD_Specific;
	logic [63:0]	MAD_Trans_ID;
	logic [15:0]	MAD_Attri_ID;
	logic [15:0] 	MAD_reserved;
	logic [31:0]	MAD_Attri_Modifer;
	//CM Connect
	logic [31:0]	CM_local_Comm_ID;
	logic [31:0]	CM_remote_Comm_ID;
	logic [31:0]	CM_local_Q_KEY;
	logic [23:0]	CM_local_QPN;
	logic [7:0]		CM_reserved_1;
	logic [23:0]	CM_Local_EECN;
	logic [7:0]		CM_reserved_2;
	logic [23:0]	CM_start_PSN;
	logic [7:0]		CM_reserved_3;
	logic [7:0]		CM_respond_resource;
	logic [7:0]		CM_Init_Depth;
	logic [4:0]		CM_target_ACK_delay;
	logic [1:0]		CM_Failover_acceptd;
	logic [0:0]		CM_end_to_end_flow_ctrl;
	logic [2:0]		CM_RNR_retry_count;
	logic [0:0]		CM_SRQ;
	logic [3:0]		CM_reserved_4;
	logic [63:0]	CM_Local_CA_GUID;	
	logic [1567:0]	CM_Private_data;
} rocev2_CM_reply_header_t;

typedef struct packed {
//DETH
	logic [31:0] 	Q_KEY;
	logic [7:0] 	DETH_reserved;
	logic [23:0] 	QPN;
	//MAD HEADER
	logic [7:0]		MAD_Base_ver;
	logic [7:0]		MAD_Management_class;
	logic [7:0]		MAD_Class_ver;
	logic [7:0]		MAD_Method;
	logic [15:0]	MAD_Status;
	logic [15:0]	MAD_Specific;
	logic [63:0]	MAD_Trans_ID;
	logic [15:0]	MAD_Attri_ID;
	logic [15:0] 	MAD_reserved;
	logic [31:0]	MAD_Attri_Modifer;
	//CM Connect
	logic [31:0]	CM_local_Comm_ID;
	logic [31:0]	CM_remote_Comm_ID;
	logic [1791:0]	CM_Private_data;
} rocev2_CM_rts_header_t;

typedef struct packed {
	logic [47:0]  	reserved;    // [7:0]
	logic [7:0]		type2;
	logic [7:0]		type1;
	logic [63:0]	context0;
	logic [63:0]	pd0;
	logic [63:0]	addr0;
	logic [63:0]	len0;
	logic [31:0]	lkey0;
	logic [31:0]	handle0;
	logic [31:0]	padding0;
	logic [31:0]	rkey0;
	logic [63:0]	context1;
	logic [63:0]	pd1;
	logic [63:0]	addr1;
	logic [63:0]	len1;
	logic [31:0]	lkey1;
	logic [31:0]	handle1;
	logic [31:0]	padding1;
	logic [31:0]	rkey1;
} rocev2_rc_send_connect_t;	//RC SEND CM建链包交互

typedef struct packed {
	logic [31:0]  	reserved;    // [7:0]
	logic [7:0]  	track_num;
	logic [7:0]  	seq_num;
	logic [7:0]		type3;
	logic [7:0]		type2;
	logic [63:0]	TDI_data_aadr;
	logic [511:0]	TDI_checksum;
	logic [63:0]	INFO_data_aadr;
	logic [511:0]	INFO_checksum;
} rocev2_write_MSG_t;	//Write Message Packet

typedef struct packed {
ipv4_header_t 				ipv4_header;
udp_header_t				udp_header;
rocev2_bth_header_t 		rocev2_bth_header;
rocev2_CM_req_header_t		rocev2_CM_req_header;
}rocev2_CM_req_pkt_t;

typedef struct packed {
ipv4_header_t 				ipv4_header;
udp_header_t				udp_header;
rocev2_bth_header_t 		rocev2_bth_header;
rocev2_CM_reply_header_t	rocev2_CM_reply_header;
}rocev2_CM_reply_pkt_t;

typedef struct packed {
ipv4_header_t 				ipv4_header;
udp_header_t				udp_header;
rocev2_bth_header_t 		rocev2_bth_header;
rocev2_CM_rts_header_t		rocev2_CM_rts_header;
}rocev2_CM_rts_pkt_t;

function rocev2_write_MSG_t rocev2_write_MSG_build;
	input [7:0]		start_stop;
	input [7:0]		INFO_flag;
	input [7:0]		track_num;
	input [7:0]		seq_num;
	input [63:0]	TDI_data_aadr;
	input [511:0]	TDI_checksum;
	input [63:0]	INFO_data_aadr;
	input [511:0]	INFO_checksum;
begin
	rocev2_write_MSG_build.reserved=48'h0;
	rocev2_write_MSG_build.type3=(INFO_flag==1)?8'h2:8'h1;
	rocev2_write_MSG_build.type2=(start_stop==1)?8'h2:8'h1;
	rocev2_write_MSG_build.track_num=track_num;
	rocev2_write_MSG_build.seq_num=seq_num;
	rocev2_write_MSG_build.TDI_data_aadr=TDI_data_aadr;
	rocev2_write_MSG_build.TDI_checksum=TDI_checksum;
	rocev2_write_MSG_build.INFO_data_aadr=INFO_data_aadr;
	rocev2_write_MSG_build.INFO_checksum=INFO_checksum;
end
endfunction

function rocev2_CM_req_pkt_t CM_req_pkt_build;
	input [47:0]			src_mac;
	input [31:0]			src_ip;
	input [47:0]			dst_mac;
	input [31:0]			dst_ip;
	input [23:0]			pkt_psn;
	input [23:0]			host_qpn;
	input [23:0]			fpga_start_psn;
begin
	CM_req_pkt_build.ipv4_header.mac_dst = dst_mac;
	CM_req_pkt_build.ipv4_header.mac_src = src_mac;
	CM_req_pkt_build.ipv4_header.eth_type = 16'h0800;
	CM_req_pkt_build.ipv4_header.ip_ver = 4'h4;        // 4'h4
	CM_req_pkt_build.ipv4_header.ip_head_len = 4'h5;        // 5 (5*4=20 bytes)
	CM_req_pkt_build.ipv4_header.ip_dscp_ecn = 8'h02;
	CM_req_pkt_build.ipv4_header.ip_total_len = 16'd308;
	CM_req_pkt_build.ipv4_header.ip_id = 16'h0000;
	CM_req_pkt_build.ipv4_header.ip_flags = 3'h2;
	CM_req_pkt_build.ipv4_header.ip_frag_offset = 12'h0;
	CM_req_pkt_build.ipv4_header.ip_ttl = 8'd64;
	CM_req_pkt_build.ipv4_header.ip_proto = 8'd17;      // 17 (UDP)
	CM_req_pkt_build.ipv4_header.ip_csum = ipv4_chk_sum_calc(CM_req_pkt_build.ipv4_header);
	CM_req_pkt_build.ipv4_header.ip_src = src_ip;
	CM_req_pkt_build.ipv4_header.ip_dst = dst_ip;
	CM_req_pkt_build.udp_header.udp_sport = 16'h12b7;     // 0x12B7 (4791)
	CM_req_pkt_build.udp_header.udp_dport = 16'h12b7;     // 0x12B7
	CM_req_pkt_build.udp_header.udp_len = 16'd288;       // UDP头+BTH+Payload
	CM_req_pkt_build.udp_header.udp_csum = 16'h0;      // 可置零
	CM_req_pkt_build.rocev2_bth_header.bth_opcode = 8'h64;    // [7:0]
	CM_req_pkt_build.rocev2_bth_header.bth_se = 1'b0;        // [7]
	CM_req_pkt_build.rocev2_bth_header.bth_migreq = 1'b1;    // [6]
	CM_req_pkt_build.rocev2_bth_header.bth_padcnt = 2'b0;    // [5:4]
	CM_req_pkt_build.rocev2_bth_header.bth_tver = 4'b0;      // [3:0] + [4]保留位（实际3位有效）
	CM_req_pkt_build.rocev2_bth_header.bth_pkey = 16'hffff;      // Partition Key [15:0]
	CM_req_pkt_build.rocev2_bth_header.bth_resv1 = 8'h0;     // 保留字节
	CM_req_pkt_build.rocev2_bth_header.bth_dqpn = 24'h1;      // Dest QP Number [23:0]
	CM_req_pkt_build.rocev2_bth_header.bth_ack_req = 1'b0;
	CM_req_pkt_build.rocev2_bth_header.bth_resv2 = 7'h0;     // 最后2字节保留
	CM_req_pkt_build.rocev2_bth_header.bth_psn = pkt_psn;       // PSN [23:0]
	CM_req_pkt_build.rocev2_CM_req_header.Q_KEY = 32'h80_01_00_00;
	CM_req_pkt_build.rocev2_CM_req_header.DETH_reserved = 8'h0;
	CM_req_pkt_build.rocev2_CM_req_header.QPN = 24'h00_00_01;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_Base_ver = 8'h01;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_Management_class = 8'h07;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_Class_ver = 8'h02;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_Method = 8'h03;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_Status = 16'h0;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_Specific = 16'h0;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_Trans_ID = 64'h03_8b_73_83_99;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_Attri_ID = 16'h10;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_reserved = 16'h0;
	CM_req_pkt_build.rocev2_CM_req_header.MAD_Attri_Modifer = 32'h30_00_00_00;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Comm_ID = 32'h99_83_73_8b;
	CM_req_pkt_build.rocev2_CM_req_header.CM_reserved_1 = 32'h15_b3;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Prefix = 40'h00_00_00_00_01;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Protocol = 8'h06;
	CM_req_pkt_build.rocev2_CM_req_header.CM_DPort = 16'h12_b7;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Local_CA_GUID = 64'h6c_b3_11_03_00_88_10_98;
	CM_req_pkt_build.rocev2_CM_req_header.CM_reserved_2 = 32'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Local_Q_Key = 32'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Local_QPN = host_qpn;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Resp_resource = 8'h00;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Local_EECN = 24'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Init_Depth = 8'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_remote_EECN = 24'h00_00_00;
	CM_req_pkt_build.rocev2_CM_req_header.CM_remote_resp_timeout = 5'h16;
	CM_req_pkt_build.rocev2_CM_req_header.CM_transport_service = 2'b00;
	CM_req_pkt_build.rocev2_CM_req_header.CM_end_to_end_flow_ctrl = 1'b0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_start_PSN = fpga_start_psn;
	CM_req_pkt_build.rocev2_CM_req_header.CM_local_resp_timeout = 5'h16;
	CM_req_pkt_build.rocev2_CM_req_header.CM_retry_cnt = 3'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_P_KEY = 16'hff_ff;
	CM_req_pkt_build.rocev2_CM_req_header.CM_payload_MTU = 4'h5;
	CM_req_pkt_build.rocev2_CM_req_header.CM_RDC_exist = 1'b0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_RNR_retry_cnt = 3'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_QP3_Max_retry_cnt = 4'hf;
	CM_req_pkt_build.rocev2_CM_req_header.CM_SRQ = 1'b0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Extended_transport = 3'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_local_port_LID = 16'hff_ff;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_remote_port_LID = 16'hff_ff;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_local_port_GID = src_ip;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_reserved_1=96'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_remote_port_GID = dst_ip;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_flow_label = 20'h00_99_a;
	CM_req_pkt_build.rocev2_CM_req_header.CM_reserved_3 = 6'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_pkt_rate = 6'h00;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_Traffic_class = 8'h00;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_hop_limit = 8'h40;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_SL = 4'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_subnet_local = 1'b0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_reserved_4 = 3'b0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_ACK_timeout = 5'h13;
	CM_req_pkt_build.rocev2_CM_req_header.CM_reserved_5 = 3'b0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_Local_LID = 16'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_pri_reserved_0 = 96'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_Remote_LID = 16'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_Local_GID = 128'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_Remote_GID = 128'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_flow_label = 20'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_reserved = 6'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_pkt_rate = 6'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_traffic_class = 8'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_Hop_limit = 8'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_SL = 4'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_Subnet_local = 1'b0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_reserved_2 = 3'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_ACK_timeout = 5'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_Alter_reserved_3 = 3'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_IP_major_version = 4'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_IP_minor_version = 4'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_IP_version = 4'h4;
	CM_req_pkt_build.rocev2_CM_req_header.CM_IP_src_port=16'h12_b7;
	CM_req_pkt_build.rocev2_CM_req_header.CM_IP_reserved=4'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_IP_src_ip=src_ip;
	CM_req_pkt_build.rocev2_CM_req_header.CM_reserved_6=96'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_IP_dst_ip=dst_ip;
	CM_req_pkt_build.rocev2_CM_req_header.CM_reserved_7=96'h0;
	CM_req_pkt_build.rocev2_CM_req_header.CM_IP_consumer_data=448'h0;
end
endfunction

function rocev2_CM_reply_pkt_t CM_reply_pkt_build;
	input [47:0]			src_mac;
	input [31:0]			src_ip;
	input [47:0]			dst_mac;
	input [31:0]			dst_ip;
//	input [15:0]			ip_csum;
	input [23:0]			pkt_psn;
	input [23:0]			fpga_qpn;
	input [23:0]			host_start_psn;
	input [31:0]			host_comm_ID;
	input [63:0]			host_CA_GUID;
	input [63:0]			host_Transaction_ID;
begin
	CM_reply_pkt_build.ipv4_header.mac_dst = dst_mac;
	CM_reply_pkt_build.ipv4_header.mac_src = src_mac;
	CM_reply_pkt_build.ipv4_header.eth_type = 16'h0800;
	CM_reply_pkt_build.ipv4_header.ip_ver = 4'h4;        // 4'h4
	CM_reply_pkt_build.ipv4_header.ip_head_len = 4'h5;        // 5 (5*4=20 bytes)
	CM_reply_pkt_build.ipv4_header.ip_dscp_ecn = 8'h02;
	CM_reply_pkt_build.ipv4_header.ip_total_len = 16'd308;
	CM_reply_pkt_build.ipv4_header.ip_id = 16'h0000;
	CM_reply_pkt_build.ipv4_header.ip_flags = 3'h2;
	CM_reply_pkt_build.ipv4_header.ip_frag_offset = 12'h0;
	CM_reply_pkt_build.ipv4_header.ip_ttl = 8'd64;
	CM_reply_pkt_build.ipv4_header.ip_proto = 8'd17;      // 17 (UDP)
	CM_reply_pkt_build.ipv4_header.ip_src = src_ip;
	CM_reply_pkt_build.ipv4_header.ip_dst = dst_ip;
	CM_reply_pkt_build.ipv4_header.ip_csum = ipv4_chk_sum_calc(CM_reply_pkt_build.ipv4_header);
	CM_reply_pkt_build.udp_header.udp_sport = 16'h12b7;     // 0x12B7 (4791)
	CM_reply_pkt_build.udp_header.udp_dport = 16'h12b7;     // 0x12B7
	CM_reply_pkt_build.udp_header.udp_len = 16'd288;       // UDP头+BTH+Payload
	CM_reply_pkt_build.udp_header.udp_csum = 16'h0;      // 可置零
	CM_reply_pkt_build.rocev2_bth_header.bth_opcode = 8'h64;    // [7:0]
	CM_reply_pkt_build.rocev2_bth_header.bth_se = 1'b0;        // [7]
	CM_reply_pkt_build.rocev2_bth_header.bth_migreq = 1'b1;    // [6]
	CM_reply_pkt_build.rocev2_bth_header.bth_padcnt = 2'b0;    // [5:4]
	CM_reply_pkt_build.rocev2_bth_header.bth_tver = 4'b0;      // [3:0] + [4]保留位（实际3位有效）
	CM_reply_pkt_build.rocev2_bth_header.bth_pkey = 16'hffff;      // Partition Key [15:0]
	CM_reply_pkt_build.rocev2_bth_header.bth_resv1 = 8'h0;     // 保留字节
	CM_reply_pkt_build.rocev2_bth_header.bth_dqpn = 24'h1;      // Dest QP Number [23:0]
	CM_reply_pkt_build.rocev2_bth_header.bth_ack_req = 1'b0;
	CM_reply_pkt_build.rocev2_bth_header.bth_resv2 = 7'h0;     // 最后2字节保留
	CM_reply_pkt_build.rocev2_bth_header.bth_psn = pkt_psn;       // PSN [23:0]
	CM_reply_pkt_build.rocev2_CM_reply_header.Q_KEY = 32'h80_01_00_00;
	CM_reply_pkt_build.rocev2_CM_reply_header.DETH_reserved = 8'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.QPN = 24'h00_00_01;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_Base_ver = 8'h01;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_Management_class = 8'h07;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_Class_ver = 8'h02;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_Method = 8'h03;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_Status = 16'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_Specific = 16'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_Trans_ID = host_Transaction_ID;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_Attri_ID = 16'h13;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_reserved = 16'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.MAD_Attri_Modifer = 32'h30_00_00_00;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_local_Comm_ID = 32'h12_34_56_78;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_remote_Comm_ID = host_comm_ID;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_local_Q_KEY = 32'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_local_QPN = fpga_qpn;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_reserved_1 = 'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_Local_EECN = 'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_reserved_2 = 'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_start_PSN = host_start_psn;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_reserved_3 = 'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_respond_resource ='h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_Init_Depth = 'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_target_ACK_delay ='h10;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_Failover_acceptd = 'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_end_to_end_flow_ctrl ='h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_RNR_retry_count ='h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_SRQ = 'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_reserved_4 = 'h0;
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_Local_CA_GUID = host_CA_GUID;	
	CM_reply_pkt_build.rocev2_CM_reply_header.CM_Private_data = 'h0;
end
endfunction

function rocev2_CM_rts_pkt_t CM_rts_pkt_build;
	input [47:0]			src_mac;
	input [31:0]			src_ip;
	input [47:0]			dst_mac;
	input [31:0]			dst_ip;
	input [23:0]			pkt_psn;
begin
	CM_rts_pkt_build.ipv4_header.mac_dst = dst_mac;
	CM_rts_pkt_build.ipv4_header.mac_src = src_mac;
	CM_rts_pkt_build.ipv4_header.eth_type = 16'h0800;
	CM_rts_pkt_build.ipv4_header.ip_ver = 4'h4;        // 4'h4
	CM_rts_pkt_build.ipv4_header.ip_head_len = 4'h5;        // 5 (5*4=20 bytes)
	CM_rts_pkt_build.ipv4_header.ip_dscp_ecn = 8'h02;
	CM_rts_pkt_build.ipv4_header.ip_total_len = 16'd308;
	CM_rts_pkt_build.ipv4_header.ip_id = 16'h0000;
	CM_rts_pkt_build.ipv4_header.ip_flags = 3'h2;
	CM_rts_pkt_build.ipv4_header.ip_frag_offset = 12'h0;
	CM_rts_pkt_build.ipv4_header.ip_ttl = 8'd64;
	CM_rts_pkt_build.ipv4_header.ip_proto = 8'd17;      // 17 (UDP)
	CM_rts_pkt_build.ipv4_header.ip_src = src_ip;
	CM_rts_pkt_build.ipv4_header.ip_dst = dst_ip;
	CM_rts_pkt_build.ipv4_header.ip_csum = ipv4_chk_sum_calc(CM_rts_pkt_build.ipv4_header);
	CM_rts_pkt_build.udp_header.udp_sport = 16'h12b7;     // 0x12B7 (4791)
	CM_rts_pkt_build.udp_header.udp_dport = 16'h12b7;     // 0x12B7
	CM_rts_pkt_build.udp_header.udp_len = 16'd288;       // UDP头+BTH+Payload
	CM_rts_pkt_build.udp_header.udp_csum = 16'h0;      // 可置零
	CM_rts_pkt_build.rocev2_bth_header.bth_opcode = 8'h64;    // [7:0]
	CM_rts_pkt_build.rocev2_bth_header.bth_se = 1'b0;        // [7]
	CM_rts_pkt_build.rocev2_bth_header.bth_migreq = 1'b1;    // [6]
	CM_rts_pkt_build.rocev2_bth_header.bth_padcnt = 2'b0;    // [5:4]
	CM_rts_pkt_build.rocev2_bth_header.bth_tver = 4'b0;      // [3:0] + [4]保留位（实际3位有效）
	CM_rts_pkt_build.rocev2_bth_header.bth_pkey = 16'hffff;      // Partition Key [15:0]
	CM_rts_pkt_build.rocev2_bth_header.bth_resv1 = 8'h0;     // 保留字节
	CM_rts_pkt_build.rocev2_bth_header.bth_dqpn = 24'h1;      // Dest QP Number [23:0]
	CM_rts_pkt_build.rocev2_bth_header.bth_ack_req = 1'b0;
	CM_rts_pkt_build.rocev2_bth_header.bth_resv2 = 7'h0;     // 最后2字节保留
	CM_rts_pkt_build.rocev2_bth_header.bth_psn = pkt_psn;       // PSN [23:0]
	CM_rts_pkt_build.rocev2_CM_rts_header.Q_KEY = 32'h80_01_00_00;
	CM_rts_pkt_build.rocev2_CM_rts_header.DETH_reserved = 8'h0;
	CM_rts_pkt_build.rocev2_CM_rts_header.QPN = 24'h00_00_01;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_Base_ver = 8'h01;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_Management_class = 8'h07;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_Class_ver = 8'h02;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_Method = 8'h03;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_Status = 16'h0;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_Specific = 16'h0;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_Trans_ID = 64'h03_8b_73_83_99;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_Attri_ID = 16'h14;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_reserved = 16'h0;
	CM_rts_pkt_build.rocev2_CM_rts_header.MAD_Attri_Modifer = 32'h30_00_00_00;
	CM_rts_pkt_build.rocev2_CM_rts_header.CM_local_Comm_ID = 32'h99_83_73_8b;
	CM_rts_pkt_build.rocev2_CM_rts_header.CM_remote_Comm_ID = 32'h12_34_56_78;
	CM_rts_pkt_build.rocev2_CM_rts_header.CM_Private_data='h0;
end
endfunction


typedef struct packed {
ipv4_header_t 									ipv4_header;
udp_header_t									udp_header;
rocev2_bth_header_t 							rocev2_bth_header;
logic [ETH_RC_SEND_payload_len*8-1:0]			rocev2_rc_send_connect_reorder;
}rocev2_RC_SEND_pkt_t;

function rocev2_rc_send_connect_t RC_SEND_connect_pkt_build;
	input								msg_start;
	input [2:0]							IMC_NUM;
	input [2:0]							QP_num;
begin
	RC_SEND_connect_pkt_build.reserved='h0;
	RC_SEND_connect_pkt_build.type1=e_MSG_MR;
	RC_SEND_connect_pkt_build.type2=msg_start ? 1 : 2;
	RC_SEND_connect_pkt_build.context0='h0;
	RC_SEND_connect_pkt_build.pd0='h0;
	RC_SEND_connect_pkt_build.addr0=host_MR_addr0_sim+32'h1234_5678*IMC_NUM+64'h0001_0000_0000_0000*QP_num;
	RC_SEND_connect_pkt_build.len0=host_MR_len0_sim+32'h1234_5678*IMC_NUM;
	RC_SEND_connect_pkt_build.handle0='h0;
	RC_SEND_connect_pkt_build.lkey0='h0;
	RC_SEND_connect_pkt_build.padding0='h0;
	RC_SEND_connect_pkt_build.rkey0=host_MR_len0_RKEY+32'h1234_5678*IMC_NUM;
	RC_SEND_connect_pkt_build.context1='h0;
	RC_SEND_connect_pkt_build.pd1='h0;
	RC_SEND_connect_pkt_build.addr1=host_MR_addr1_sim+32'h1234_5678*IMC_NUM+64'h0001_0000_0000_0000*QP_num;
	RC_SEND_connect_pkt_build.len1=host_MR_len1_sim+32'h1234_5678*IMC_NUM;
	RC_SEND_connect_pkt_build.handle1='h0;
	RC_SEND_connect_pkt_build.lkey1='h0;
	RC_SEND_connect_pkt_build.padding1='h0;
	RC_SEND_connect_pkt_build.rkey1=host_MR_len1_RKEY+32'h1234_5678*IMC_NUM;
end
endfunction

function rocev2_RC_SEND_pkt_t RC_SEND_pkt_build;
	input [47:0]						src_mac;
	input [31:0]						src_ip;
	input [47:0]						dst_mac;
	input [31:0]						dst_ip;
	input [23:0]						host_psn;
	input [23:0]						fpga_qpn;
//	input [15:0]			payload_len;
	input rocev2_rc_send_connect_t		host_CM_MSG;
begin
	RC_SEND_pkt_build.ipv4_header.mac_dst = dst_mac;
	RC_SEND_pkt_build.ipv4_header.mac_src = src_mac;
	RC_SEND_pkt_build.ipv4_header.eth_type = 16'h0800;
	RC_SEND_pkt_build.ipv4_header.ip_ver = 4'h4;        // 4'h4
	RC_SEND_pkt_build.ipv4_header.ip_head_len = 4'h5;        // 5 (5*4=20 bytes)
	RC_SEND_pkt_build.ipv4_header.ip_dscp_ecn = 8'h02;
	RC_SEND_pkt_build.ipv4_header.ip_total_len = 16'd20+16'd20+16'd104+16'd4;
	RC_SEND_pkt_build.ipv4_header.ip_id = 16'h0000;
	RC_SEND_pkt_build.ipv4_header.ip_flags = 3'h2;
	RC_SEND_pkt_build.ipv4_header.ip_frag_offset = 12'h0;
	RC_SEND_pkt_build.ipv4_header.ip_ttl = 8'd64;
	RC_SEND_pkt_build.ipv4_header.ip_proto = 8'd17;      // 17 (UDP)
//	$display("RC_SEND_pkt_build ");
//	$display("ip_csum is %h ", RC_SEND_pkt_build.ipv4_header.ip_csum);
//	$display("ip_csum is %h ", RC_SEND_pkt_build.ipv4_header.ip_csum);
	RC_SEND_pkt_build.ipv4_header.ip_src = src_ip;
	RC_SEND_pkt_build.ipv4_header.ip_dst = dst_ip;
	RC_SEND_pkt_build.udp_header.udp_sport = 16'h12b7;     // 0x12B7 (4791)
	RC_SEND_pkt_build.udp_header.udp_dport = 16'h12b7;     // 0x12B7
	RC_SEND_pkt_build.udp_header.udp_len = 16'd20 + 16'd104 + 16'd4;       // UDP头+BTH+Payload
	RC_SEND_pkt_build.udp_header.udp_csum = 16'h0;      // 可置零
	RC_SEND_pkt_build.ipv4_header.ip_csum = ipv4_chk_sum_calc(RC_SEND_pkt_build.ipv4_header);
	RC_SEND_pkt_build.rocev2_bth_header.bth_opcode = 8'h04;    // [7:0]
	RC_SEND_pkt_build.rocev2_bth_header.bth_se = 1'b0;        // [7]
	RC_SEND_pkt_build.rocev2_bth_header.bth_migreq = 1'b1;    // [6]
	RC_SEND_pkt_build.rocev2_bth_header.bth_padcnt = 2'b0;    // [5:4]
	RC_SEND_pkt_build.rocev2_bth_header.bth_tver = 4'b0;      // [3:0] + [4]保留位（实际3位有效）
	RC_SEND_pkt_build.rocev2_bth_header.bth_pkey = 16'hffff;      // Partition Key [15:0]
	RC_SEND_pkt_build.rocev2_bth_header.bth_resv1 = 8'h0;     // 保留字节
	RC_SEND_pkt_build.rocev2_bth_header.bth_dqpn = fpga_qpn;      // Dest QP Number [23:0]
	RC_SEND_pkt_build.rocev2_bth_header.bth_ack_req = 1'b0;
	RC_SEND_pkt_build.rocev2_bth_header.bth_resv2 = 7'h0;     // 最后2字节保留
	RC_SEND_pkt_build.rocev2_bth_header.bth_psn = host_psn;       // PSN [23:0]
	RC_SEND_pkt_build.rocev2_rc_send_connect_reorder=host_tx_data_reorder(host_CM_MSG);
	
end
endfunction

typedef struct packed {
ipv4_header_t 									ipv4_header;
udp_header_t									udp_header;
rocev2_bth_header_t 							rocev2_bth_header;
logic [7:0]										Syndrome;
logic [23:0]									Message_seq_num;
}rocev2_RC_ACK_pkt_t;

function rocev2_RC_ACK_pkt_t RC_ACK_pkt_build;
	input [47:0]						src_mac;
	input [31:0]						src_ip;
	input [47:0]						dst_mac;
	input [31:0]						dst_ip;
	input [23:0]						host_psn;
	input [23:0]						fpga_qpn;
	input [23:0]						ack_MSN;
begin
	RC_ACK_pkt_build.ipv4_header.mac_dst = dst_mac;
	RC_ACK_pkt_build.ipv4_header.mac_src = src_mac;
	RC_ACK_pkt_build.ipv4_header.eth_type = 16'h0800;
	RC_ACK_pkt_build.ipv4_header.ip_ver = 4'h4;        // 4'h4
	RC_ACK_pkt_build.ipv4_header.ip_head_len = 4'h5;        // 5 (5*4=20 bytes)
	RC_ACK_pkt_build.ipv4_header.ip_dscp_ecn = 8'h02;
	RC_ACK_pkt_build.ipv4_header.ip_total_len = 16'd48;
	RC_ACK_pkt_build.ipv4_header.ip_id = 16'h0000;
	RC_ACK_pkt_build.ipv4_header.ip_flags = 3'h2;
	RC_ACK_pkt_build.ipv4_header.ip_frag_offset = 12'h0;
	RC_ACK_pkt_build.ipv4_header.ip_ttl = 8'd64;
	RC_ACK_pkt_build.ipv4_header.ip_proto = 8'd17;      // 17 (UDP)
	RC_ACK_pkt_build.ipv4_header.ip_src = src_ip;
	RC_ACK_pkt_build.ipv4_header.ip_dst = dst_ip;
	RC_ACK_pkt_build.ipv4_header.ip_csum = ipv4_chk_sum_calc(RC_ACK_pkt_build.ipv4_header);
	RC_ACK_pkt_build.udp_header.udp_sport = 16'h12b7;     // 0x12B7 (4791)
	RC_ACK_pkt_build.udp_header.udp_dport = 16'h12b7;     // 0x12B7
	RC_ACK_pkt_build.udp_header.udp_len = 16'd28;       // UDP头+BTH+Payload
	RC_ACK_pkt_build.udp_header.udp_csum = 16'h0;      // 可置零
	RC_ACK_pkt_build.rocev2_bth_header.bth_opcode = 8'h11;    // [7:0]
	RC_ACK_pkt_build.rocev2_bth_header.bth_se = 1'b0;        // [7]
	RC_ACK_pkt_build.rocev2_bth_header.bth_migreq = 1'b1;    // [6]
	RC_ACK_pkt_build.rocev2_bth_header.bth_padcnt = 2'b0;    // [5:4]
	RC_ACK_pkt_build.rocev2_bth_header.bth_tver = 4'b0;      // [3:0] + [4]保留位（实际3位有效）
	RC_ACK_pkt_build.rocev2_bth_header.bth_pkey = 16'hffff;      // Partition Key [15:0]
	RC_ACK_pkt_build.rocev2_bth_header.bth_resv1 = 8'h0;     // 保留字节
	RC_ACK_pkt_build.rocev2_bth_header.bth_dqpn = fpga_qpn;      // Dest QP Number [23:0]
	RC_ACK_pkt_build.rocev2_bth_header.bth_ack_req = 1'b0;
	RC_ACK_pkt_build.rocev2_bth_header.bth_resv2 = 7'h0;     // 最后2字节保留
	RC_ACK_pkt_build.rocev2_bth_header.bth_psn = host_psn;       // PSN [23:0]
	RC_ACK_pkt_build.Syndrome=8'h2;
	RC_ACK_pkt_build.Message_seq_num=ack_MSN;
end
endfunction

   // 定义打包结构体（总宽度512位）
typedef struct packed {
    logic [95:0]  	Reserved_2;      // 511:416 (96位)
    logic [31:0]  	IMMDT_DATA;      // 415:384 (32位)
//    fpga_send_t		fpga_send;
    logic [127:0] 	SDATA;           // 383:256 (128位)
    logic [31:0]  	RTAG;            // 255:224 (32位)
    logic [63:0]  	ROFFSET;         // 223:160 (64位)
    logic [23:0]  	Reserved_1;      // 159:136 (24位)
    logic [7:0]   	OPCODE;          // 135:128 (8位)
    logic [31:0]  	LENGTH;          // 127:96  (32位)
    logic [63:0]  	LADDR;           // 95:32   (64位)
    logic [15:0]  	Reserved_0;      // 31:16   (16位)
    logic [15:0]  	WRID;            // 15:0    (16位)
} wqe_t;

function wqe_t write_MSG_wqe_build;
	input [15:0]WRID;
	input [63:0]fpga_ddr_addr;
begin
	write_MSG_wqe_build.WRID          				= WRID;                         
	write_MSG_wqe_build.Reserved_0    				= 16'h0;                       
	write_MSG_wqe_build.LADDR         				= fpga_ddr_addr;        
	write_MSG_wqe_build.LENGTH        				= `RDMA_WRITE_MSG_WQE_SIZE;                        
	write_MSG_wqe_build.OPCODE        				= `XRINC_OPCODE_RDMA_SEND;        
	write_MSG_wqe_build.Reserved_1    				= 24'h0;                         
	write_MSG_wqe_build.ROFFSET       				= 64'h0;        
	write_MSG_wqe_build.RTAG          				= 32'h0;      
	write_MSG_wqe_build.SDATA						= 128'h0;
	write_MSG_wqe_build.IMMDT_DATA    				= 32'h0;                       
	write_MSG_wqe_build.Reserved_2    				= 96'h0;   
end                    
endfunction

function wqe_t write_DATA_wqe_build;
	input [15:0]WRID;
	input [63:0]fpga_ddr_addr;
	input [63:0]host_addr;
	input [31:0]len;
	input [31:0]rkey;
begin
	write_DATA_wqe_build.WRID          				= WRID;                         
	write_DATA_wqe_build.Reserved_0    				= 16'h0;                         
	write_DATA_wqe_build.LADDR         				= fpga_ddr_addr;        
	write_DATA_wqe_build.LENGTH        				= len;     //`RDMA_WRITE_SIZE                 
	write_DATA_wqe_build.OPCODE        				= `XRINC_OPCODE_RDMA_WRITE;       
	write_DATA_wqe_build.Reserved_1    				= 24'h0;                         
	write_DATA_wqe_build.ROFFSET       				= host_addr;       
	write_DATA_wqe_build.RTAG          				= rkey;         
	write_DATA_wqe_build.SDATA						= 128'h0;      
	write_DATA_wqe_build.IMMDT_DATA    				= 32'h0;                         
	write_DATA_wqe_build.Reserved_2    				= 96'h0;      
end                 
endfunction

function wqe_t cm_reply_wqe_build ;
	cm_reply_wqe_build.WRID          				= 16'h1;                         
	cm_reply_wqe_build.Reserved_0    				= 16'h0;                         
	cm_reply_wqe_build.LADDR         				= {32'h0,`CM_REPLY_DDR_ADDR};        
	cm_reply_wqe_build.LENGTH        				= `CM_REPLY_PKT_LEN;                      
	cm_reply_wqe_build.OPCODE        				= `XRINC_OPCODE_RDMA_SEND;       
	cm_reply_wqe_build.Reserved_1    				= 24'h0;                         
	cm_reply_wqe_build.ROFFSET       				= 64'h0;       
	cm_reply_wqe_build.RTAG          				= 32'h0;       
	cm_reply_wqe_build.SDATA						= 128'h0;        
	cm_reply_wqe_build.IMMDT_DATA    				= 32'h0;                         
	cm_reply_wqe_build.Reserved_2    				= 96'h0;                       
endfunction


function [2*8-1 : 0] ipv4_chk_sum_calc;
	input ipv4_header_t 	ipv4_pkt;
  	logic [18*8-1 :0] 		in_ipv4_hdr;
  	logic [24:0]			chekcsum_i;
begin
	
	in_ipv4_hdr={	ipv4_pkt.ip_ver, 		ipv4_pkt.ip_head_len, 		ipv4_pkt.ip_dscp_ecn, 
					ipv4_pkt.ip_total_len, 	ipv4_pkt.ip_id,
					ipv4_pkt.ip_flags, 		ipv4_pkt.ip_frag_offset,
					ipv4_pkt.ip_ttl, 		ipv4_pkt.ip_proto,
					ipv4_pkt.ip_src,		ipv4_pkt.ip_dst};
//	$display("in_ipv4_hdr is %h",in_ipv4_hdr);
//	$display("ip_src is %h",ipv4_pkt.ip_src);
  chekcsum_i = in_ipv4_hdr[18*8-1 -: 16] + in_ipv4_hdr[16*8-1 -: 16] +  in_ipv4_hdr[14*8-1 -: 16] + in_ipv4_hdr[12*8-1 -: 16] + in_ipv4_hdr[10*8-1 -: 16] + in_ipv4_hdr[8*8-1 -: 16] + 
                  in_ipv4_hdr[6*8-1 -: 16] + in_ipv4_hdr[4*8-1 -: 16] + in_ipv4_hdr[2*8-1 -: 16];
//  $display("chekcsum_i is %h",chekcsum_i);
  if(|chekcsum_i[19:16]) begin
    chekcsum_i = chekcsum_i[15:0] + chekcsum_i[19:16];
  end
  ipv4_chk_sum_calc = {~chekcsum_i[15:8],~chekcsum_i[7:0]};
//  $display("ipv4_chk_sum_calc is %h",ipv4_chk_sum_calc);
end
endfunction

function [64*8-1 : 0] hdr_byte_reorder;
  input [64*8-1 :0] in_hdr;
  integer i;
  for(i=0;i<64;i=i+1) begin
    hdr_byte_reorder[((64-i)*8)-1 -: 8] = in_hdr[((i+1)*8)-1 -: 8];
  end
endfunction

function [64*ETH_RC_SEND_payload_len/8-1 : 0] host_tx_data_reorder;
  input [64*ETH_RC_SEND_payload_len/8-1 :0] in_hdr;
  integer i;
  integer j;
  for(i=0;i<ETH_RC_SEND_payload_len/8;i=i+1) begin
  	for(j=0;j<8;j=j+1) begin
  		host_tx_data_reorder[i*64+64-1-j*8-:8] = in_hdr[i*64+j*8+:8];
  	end
  end
endfunction
  
function [32*16-1 : 0] TDI_data_reorder;
  input [32*16-1 :0] in_hdr;
  integer i;
  for(i=0;i<32;i=i+1) begin
    TDI_data_reorder[((32-i)*16)-1 -: 16] = in_hdr[i*16 +: 16];
  end
endfunction






