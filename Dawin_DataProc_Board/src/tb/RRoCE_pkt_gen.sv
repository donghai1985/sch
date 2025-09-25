`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/31 10:31:40
// Design Name: 
// Module Name: CM_tb
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
module RRoCE_pkt_gen#(
	parameter										C_AXIS_DATA_WIDTH=512,
	parameter										PAYLOAD_LEN=16'd56
)(
	input 											clk,
	input 											rst,
	
	/*output                               			s_axis_tready,
	input  	[C_AXIS_DATA_WIDTH-1 : 0]    			s_axis_tdata,
	input 	[C_AXIS_DATA_WIDTH/8-1:0]    			s_axis_tkeep,
	input                               			s_axis_tvalid,
	input                               			s_axis_tlast,*/
		
	input                               			m_axis_tready,
	output  [C_AXIS_DATA_WIDTH-1 : 0]    			m_axis_tdata,
	output 	[C_AXIS_DATA_WIDTH/8-1:0]    			m_axis_tkeep,
	output                               			m_axis_tvalid,
	output                               			m_axis_tlast,
	// 控制接口
	input  logic [23:0]  							dest_qp,
	input  logic [56*8-1:0] 						payload_data,
	input  logic         							send_start,
	output logic         							send_done
);


function [2*8-1 : 0] ipv4_chk_sum_calc;
  input [18*8-1 :0] in_ipv4_hdr;
  logic [24:0]		chekcsum_i;
begin
  chekcsum_i = in_ipv4_hdr[18*8-1 -: 16] + in_ipv4_hdr[16*8-1 -: 16] +  in_ipv4_hdr[14*8-1 -: 16] + in_ipv4_hdr[12*8-1 -: 16] + in_ipv4_hdr[10*8-1 -: 16] + in_ipv4_hdr[8*8-1 -: 16] + 
                  in_ipv4_hdr[6*8-1 -: 16] + in_ipv4_hdr[4*8-1 -: 16] + in_ipv4_hdr[2*8-1 -: 16];
  if(|chekcsum_i[19:16]) begin
    chekcsum_i = chekcsum_i[15:0] + chekcsum_i[19:16];
  end
  ipv4_chk_sum_calc = {~chekcsum_i[15:8],~chekcsum_i[7:0]};
end
endfunction
 
function [64*8-1 : 0] hdr_byte_reorder;
  input [64*8-1 :0] in_hdr;
  integer i;
  for(i=0;i<64;i=i+1) begin
    hdr_byte_reorder[((64-i)*8)-1 -: 8] = in_hdr[((i+1)*8)-1 -: 8];
  end
endfunction

typedef struct packed {
  // ETH 头
  logic [47:0] 	mac_dst;
  logic [47:0] 	mac_src;
  logic [15:0] 	eth_type;
  
  // IPv4头 (20 bytes)
  logic [3:0]  	ip_ver;        // 4'h4
  logic [3:0]  	ip_head_len;        // 5 (5*4=20 bytes)
  logic [7:0]  	ip_dscp_ecn;
  logic [15:0] ip_total_len;
  logic [15:0] ip_id;
  logic [2:0]  ip_flags;
  logic [12:0] ip_frag_offset;
  logic [7:0]  ip_ttl;
  logic [7:0]  ip_proto;      // 17 (UDP)
  logic [15:0] ip_csum;
  logic [31:0] ip_src;
  logic [31:0] ip_dst;

  // UDP头 (8 bytes)
  logic [15:0] udp_sport;     // 0x12B7 (4791)
  logic [15:0] udp_dport;     // 0x12B7
  logic [15:0] udp_len;       // UDP头+BTH+Payload
  logic [15:0] udp_csum;      // 可置零

  // BTH头 (12 bytes) - 精确到bit的协议规范实现
  logic [7:0]  	bth_opcode;    // [7:0]
  logic        	bth_se;        // [7]
  logic        	bth_migreq;    // [6]
  logic [1:0]  	bth_padcnt;    // [5:4]
  logic [3:0]  	bth_tver;      // [3:0] + [4]保留位（实际3位有效）
  logic [15:0] 	bth_pkey;      // Partition Key [15:0]
  logic [7:0]  	bth_resv1;     // 保留字节
  logic [23:0]	bth_dqpn;      // Dest QP Number [23:0]
  logic			ack_req;
  logic [6:0] 	bth_resv2;     // 最后2字节保留
  logic [23:0] 	bth_psn;       // PSN [23:0]
} rocev2_header_t;



// 状态机定义 --------------------------------------------------------
typedef enum logic [2:0] {
  	IDLE,
	SEND,
  	FINISH
} state_t;

// 寄存器声明 --------------------------------------------------------
state_t 								cur_st, nxt_st;
rocev2_header_t 						header;
logic [(54+PAYLOAD_LEN)*8-1:0]			pkt_buffer;
logic [23:0]    						curr_psn;
logic [3:0]     						header_words;
logic [9:0]								remain_len;

logic                               	m_usr_axis_tready;
logic  	[C_AXIS_DATA_WIDTH-1 : 0]    	m_usr_axis_tdata;
logic 	[C_AXIS_DATA_WIDTH/8-1:0]    	m_usr_axis_tkeep;
logic                               	m_usr_axis_tvalid;
logic                               	m_usr_axis_tlast;

logic	[18*8-1:0]						csum_in_ipv4_hdr;
logic	[9:0]							pkt_send_cnt;

assign header.mac_dst=Local_MAC;
assign header.mac_src=QP1_Dst_MAC;
assign header.eth_type=16'h0800;
assign header.ip_ver = IP_VERSION;
assign header.ip_head_len = IP_IHL;
assign header.ip_dscp_ecn = 8'h02;
assign header.ip_total_len=16'd20+16'd20+PAYLOAD_LEN+16'd4;
assign header.ip_id = 16'h0000;
assign header.ip_flags = 3'b010; // Don't fragment
assign header.ip_frag_offset = 13'h0;
assign header.ip_ttl = 8'h40;
assign header.ip_proto = 8'h11; // UDP
assign header.ip_src = QP1_Dst_IPv4; // 示例源IP
assign header.ip_dst = local_IPv4; // 示例目的IP
assign header.udp_sport = UDP_PORT;
assign header.udp_dport = UDP_PORT;
assign header.udp_len = 16'd20 + PAYLOAD_LEN + 16'd4; // BTH+Payload
assign header.udp_csum=16'h0;
assign header.bth_opcode = 8'h04; // RC SEND_ONLY
assign header.bth_se = 1'b0;
assign header.bth_migreq = 1'b1;
assign header.bth_padcnt = 2'b00;
assign header.bth_tver=4'h0;
assign header.bth_pkey=16'hffff;
assign header.bth_resv1=8'h0;
assign header.bth_psn = QPn_Send_Q_PSN+pkt_send_cnt;
assign header.bth_dqpn = dest_qp;
assign header.ack_req=1'b1;
assign header.bth_resv2=7'h0;
assign csum_in_ipv4_hdr={	header.ip_ver, header.ip_head_len, header.ip_dscp_ecn, 
							header.ip_total_len, header.ip_id,
							header.ip_flags, header.ip_frag_offset,
							header.ip_ttl, header.ip_proto,
							header.ip_src,	header.ip_dst};
assign header.ip_csum = ipv4_chk_sum_calc(csum_in_ipv4_hdr);



// 常数定义 ----------------------------------------------------------
localparam UDP_PORT = 4791;     // RoCEv2标准端口
localparam IP_IHL = 5;          // 20字节头
localparam IP_VERSION = 4;

// 包结构 ----------------------------------------------------------
/*assign pkt_buffer = {
	header.mac_dst, header.mac_src, header.eth_type,
	header.ip_ver, header.ip_head_len, header.ip_dscp_ecn, header.ip_total_len, header.ip_id,
	header.ip_flags, header.ip_frag_offset,
	header.ip_ttl, header.ip_proto, header.ip_csum,
	header.ip_src,	header.ip_dst,
	header.udp_sport, header.udp_dport,
	header.udp_len, header.udp_csum,
	header.bth_opcode, header.bth_se, header.bth_migreq, 
	header.bth_padcnt, header.bth_tver, header.bth_pkey, header.bth_resv1, 
	header.bth_dqpn, header.ack_req, header.bth_resv2, header.bth_psn,
};*/


// 主状态机 ----------------------------------------------------------
always_ff @(posedge clk or posedge rst) 
  if (rst)     	cur_st <= IDLE;
  else			cur_st <= nxt_st;

always_comb
begin
	nxt_st = cur_st;
    case(cur_st)
      IDLE:         if (send_start) 		nxt_st = SEND;
      SEND:			if (remain_len <= 64)	nxt_st = FINISH;
      FINISH: 								nxt_st = IDLE;
      default:								nxt_st = IDLE;
    endcase
end

always_ff @(posedge clk or posedge rst) 
	if(rst)					remain_len<=0;
	else if(cur_st==SEND)	remain_len<=remain_len-64;
	else if(cur_st==IDLE)	remain_len<=54+PAYLOAD_LEN;

always_ff @(posedge clk or posedge rst) 
	if(rst)										pkt_buffer<=0;
	else if(cur_st==SEND)						pkt_buffer<=pkt_buffer<<C_AXIS_DATA_WIDTH;
	else if(cur_st==IDLE)						pkt_buffer<={header,payload_data};

assign m_usr_axis_tlast=m_usr_axis_tvalid && (remain_len<=64);
assign m_usr_axis_tvalid=cur_st==SEND;
assign m_usr_axis_tdata = hdr_byte_reorder(pkt_buffer[(54+PAYLOAD_LEN)*8-1-:512]);
assign m_usr_axis_tkeep = (m_usr_axis_tlast) ? (64'hFFFF_FFFF_FFFF_FFFF >> (64 - remain_len)) : 64'hFFFF_FFFF_FFFF_FFFF ;

always_ff@(posedge clk or posedge rst)
	if(rst)																		pkt_send_cnt<=0;
	else if(m_usr_axis_tvalid && m_usr_axis_tready && m_usr_axis_tlast)			pkt_send_cnt<=pkt_send_cnt+1;


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

endmodule
