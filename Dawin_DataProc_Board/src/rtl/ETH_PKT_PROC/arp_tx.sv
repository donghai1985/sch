`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/09 17:03:48
// Design Name: 
// Module Name: arp_tx
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
`include "Board_define.vh"
//`include "XRNIC_Reg_Config.vh"
//`include "XRNIC_REG_configuration.vh"
module arp_tx
# (
	parameter CHANNEL_NUM=0,
  	parameter C_AXIS_DATA_WIDTH = 512
  )
(
 	input                               			clk,
 	input                               			rstn,
 	input                               			tx_m_axis_tready,
 	output logic [C_AXIS_DATA_WIDTH-1 : 0]    		tx_m_axis_tdata,
 	output logic [C_AXIS_DATA_WIDTH/8-1:0]    		tx_m_axis_tkeep,
 	output logic                              		tx_m_axis_tvalid,
 	output logic                              		tx_m_axis_tlast,
 	
 	// synthesis translate_off
 	input	[23:0]									fpga_QPN,
 	// synthesis translate_on
 	
 	input											arp_req_tx,
 	input											arp_ack_tx,
 	output logic									arp_ack_tx_done,
 	input [47:0]									arp_src_mac,
 	input [31:0]									arp_src_ip
);


localparam PKT_LEN=16'd60;


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

//logic [15:0] 	Protocol_ID = 16'h0806;		// ARP
localparam  	ETH_TYPE     = 16'h0806 ; //以太网帧类型 ARP协议
localparam  	HD_TYPE      = 16'h0001 ; //硬件类型 以太网
localparam  	PROTOCOL_TYPE= 16'h0800 ; //上层协议为IP协议

/***********************************************************************************************************/

logic [PKT_LEN*8-1:0]			pkt_tx;
logic [9:0]						remain_tx_cnt;
logic [9:0]						pkt_tx_cnt;
logic [PKT_LEN*8-1:0] 			ARP_reply_pkt;
logic [PKT_LEN*8-1:0] 			ARP_req_pkt;
// synthesis translate_off
logic	[31:0]					host_IP;
logic	[47:0]					host_MAC;

// synthesis translate_on

/*logic                               	tx_m_axis_tlast_to_crc;
logic [C_AXIS_DATA_WIDTH-1 : 0]    		tx_m_axis_tdata_to_crc;
logic [C_AXIS_DATA_WIDTH/8-1:0]    		tx_m_axis_tkeep_to_crc;
logic                              		tx_m_axis_tvalid_to_crc;*/


enum {IDLE,ARP_TX,ARP_TX_DONE,ARP_RESP_TX} cur_st,nxt_st;

always@(posedge clk or negedge rstn)
	if(~rstn) 				cur_st<=IDLE;
	else					cur_st<=nxt_st;

always@(*)
begin
	nxt_st=cur_st;		
    case(cur_st)
    	IDLE:		if(arp_ack_tx)											nxt_st=ARP_TX;
    				else if(arp_req_tx)										nxt_st=ARP_TX;
    	ARP_TX:		if(tx_m_axis_tlast && tx_m_axis_tready)					nxt_st=ARP_TX_DONE;
    	ARP_TX_DONE:														nxt_st=IDLE;
    	default:															nxt_st=IDLE;
    endcase
end

assign arp_ack_tx_done=cur_st==ARP_TX_DONE;


assign ARP_reply_pkt = 	{arp_src_mac,Local_MAC+CHANNEL_NUM,ETH_TYPE,HD_TYPE,PROTOCOL_TYPE,8'h06,8'h04,16'h0002,Local_MAC+CHANNEL_NUM,local_IPv4+CHANNEL_NUM,arp_src_mac,arp_src_ip,144'h0};
// synthesis translate_off
assign ARP_req_pkt = 	{Local_MAC+CHANNEL_NUM,host_MAC+CHANNEL_NUM,ETH_TYPE,HD_TYPE,PROTOCOL_TYPE,8'h06,8'h04,16'h0001,host_MAC+CHANNEL_NUM,host_IP+CHANNEL_NUM,48'h0,local_IPv4+CHANNEL_NUM,144'h0};
// synthesis translate_on

//initial begin
//wait(arp_ack_tx);
//$display("arp reply is: %h",ARP_reply_pkt);
//end

always@(posedge clk or negedge rstn) 
	if(!rstn)
		pkt_tx<=0;
	else if(cur_st==IDLE && arp_ack_tx)
		pkt_tx<=hdr_byte_reorder(ARP_reply_pkt);
	// synthesis translate_off
	else if(cur_st==IDLE && arp_req_tx)
		pkt_tx<=hdr_byte_reorder(ARP_req_pkt);
	// synthesis translate_on

assign tx_m_axis_tlast=(cur_st==ARP_TX);
assign tx_m_axis_tvalid=(cur_st==ARP_TX);
assign tx_m_axis_tdata=pkt_tx;
assign tx_m_axis_tkeep=64'h0fff_ffff_ffff_ffff;

// synthesis translate_off
QPn_LUT QPn_LUT
(
	.sim_fpga_QPn			(fpga_QPN		),
	.sim_IP					(host_IP		),
	.sim_MAC				(host_MAC		),
	.sim_host_QPn			(				),
	.sim_fpga_start_PSN		( 				)
);
// synthesis translate_on

/*exdes_crc_wrap inst_crc  (
   .core_clk           (clk),
   .core_rst           (~rstn),
   .m_axis_tdata       (tx_m_axis_tdata),
   .m_axis_tkeep       (tx_m_axis_tkeep),
   .m_axis_tvalid      (tx_m_axis_tvalid),
   .m_axis_tready      (tx_m_axis_tready),
   .m_axis_tlast       (tx_m_axis_tlast),
   .s_axis_tdata       (tx_m_axis_tdata_to_crc),
   .s_axis_tkeep       (tx_m_axis_tkeep_to_crc),
   .s_axis_tvalid      (tx_m_axis_tvalid_to_crc),
   .s_axis_tlast       (tx_m_axis_tlast_to_crc),
   .s_axis_tready      (tx_m_axis_tready_to_crc)
);*/

endmodule
