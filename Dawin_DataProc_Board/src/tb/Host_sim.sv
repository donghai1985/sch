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

module Host_sim
#(
	parameter										C_AXIS_DATA_WIDTH=512,
	parameter										CHANNEL_NUM=0
)(
	input 											clk,
	input 											rst,
	
	
	output                               			s_axis_tready,
	input  	[C_AXIS_DATA_WIDTH-1 : 0]    			s_axis_tdata,
	input 	[C_AXIS_DATA_WIDTH/8-1:0]    			s_axis_tkeep,
	input                               			s_axis_tvalid,
	input                               			s_axis_tlast,
		
	input                               			m_axis_tready,
	output  [C_AXIS_DATA_WIDTH-1 : 0]    			m_axis_tdata,
	output 	[C_AXIS_DATA_WIDTH/8-1:0]    			m_axis_tkeep,
	output                               			m_axis_tvalid,
	output                               			m_axis_tlast,
	
	input											QPn_init_done,
	input											ERNIC_init_done,
	
	input											arp_req_tx,
	input											CM_Req_usr_en,
	input											MR_SEND_usr_en,
	input											RC_ACK_usr_en,
	input	[23:0]									fpga_QPN
//	output											need_ACK
//	input											ETH_num
    );

    localparam PAYLOAD_LEN=56;
    
	
	typedef struct packed {
		logic	[C_AXIS_DATA_WIDTH-1	:	0]			tdata;
		logic	[C_AXIS_DATA_WIDTH/8-1	:	0]    		tkeep;
		logic 											tvalid;
		logic 											tready;
		logic 											tlast;
	} pkt_axis;
	
//	logic			CM_Req_tx_en;
	logic						CM_Req_tvalid;
	logic						CM_ReadyToUse_en;
	logic						CM_ReadyToUse_tvalid;
	logic						CM_REQ_en;
	logic						CM_RTS_en;
	logic						RC_ACK_en;
	logic						RC_SEND_en;
	logic [47:0]				host_MAC;
	logic [31:0]				host_IP;
	logic [23:0]				host_PSN;
	logic [PAYLOAD_LEN*8-1:0]	payload_data='h0;
	logic [23:0]				recv_PSN;
	logic						need_ACK;
	
	logic                              				roce_m_axis_tready;
	logic  [C_AXIS_DATA_WIDTH-1 : 0]    			roce_m_axis_tdata;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			roce_m_axis_tkeep;
	logic                               			roce_m_axis_tvalid;
	logic                               			roce_m_axis_tlast;
	
	logic                              				arp_m_axis_tready;
	logic  [C_AXIS_DATA_WIDTH-1 : 0]    			arp_m_axis_tdata;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			arp_m_axis_tkeep;
	logic                               			arp_m_axis_tvalid;
	logic                               			arp_m_axis_tlast;

	
//	logic	[2:0]									done_cnt;
	
	assign roce_m_axis_tready=m_axis_tready;
	assign arp_m_axis_tready=m_axis_tready;
	assign m_axis_tvalid=roce_m_axis_tvalid | arp_m_axis_tvalid;
	assign m_axis_tlast=roce_m_axis_tlast | arp_m_axis_tlast;
	assign m_axis_tkeep=roce_m_axis_tvalid ? roce_m_axis_tkeep : arp_m_axis_tkeep;
	assign m_axis_tdata=roce_m_axis_tvalid ? roce_m_axis_tdata : arp_m_axis_tdata;
	
//	logic			RoCE_send_en;
//	logic [23:0]	start_PSN;
	
	pkt_axis 		CM_pkt;
	pkt_axis 		RoCE_send_pkt;
	pkt_axis		host_rx;
	
	enum {IDLE,CM_req_tx_start,CM_req_tx,CM_reply_rx,CM_rts_tx_start,CM_rts_tx,RC_ACK_tx,MR_send_tx_start,MR_send_tx,wait_config_done,RC_ack_rx,Done} cur_st,nxt_st;
	always@(posedge clk or posedge rst)
		if(rst)		cur_st<=IDLE;
		else		cur_st<=nxt_st;

	always@(*)
	begin
		nxt_st=cur_st;
		case(cur_st)
			IDLE:				if(CM_Req_usr_en)						nxt_st=CM_req_tx_start;
								else if(MR_SEND_usr_en)					nxt_st=MR_send_tx_start;
//								else if(RC_ACK_usr_en && need_ACK)		nxt_st=RC_ACK_tx;
			CM_req_tx_start:											nxt_st=CM_req_tx;
//			CM_req_tx:			if(m_axis_tvalid && m_axis_tlast)		nxt_st=CM_reply_rx;
			CM_req_tx:			if(m_axis_tvalid && m_axis_tlast)		nxt_st=CM_reply_rx;
			CM_reply_rx:		if(s_axis_tvalid && s_axis_tlast)		nxt_st=CM_rts_tx_start;
			CM_rts_tx_start:											nxt_st=CM_rts_tx;
			CM_rts_tx:			if(m_axis_tvalid && m_axis_tlast)		nxt_st=wait_config_done;
			wait_config_done:	if(QPn_init_done)						nxt_st=IDLE;
			MR_send_tx_start:											nxt_st=MR_send_tx;
			MR_send_tx:			if(m_axis_tvalid && m_axis_tlast)		nxt_st=Done;
//			RC_ACK_tx:													nxt_st=IDLE;
			Done:														nxt_st=IDLE;
			default:													nxt_st=IDLE;
		endcase
	end
	
	assign CM_REQ_en=cur_st==CM_req_tx_start;
	assign CM_RTS_en=cur_st==CM_rts_tx_start;
	assign RC_SEND_en=cur_st==MR_send_tx_start;
	assign RC_ACK_en=cur_st==RC_ACK_tx;

	
//	always_ff@(posedge clk or posedge rst)
//		if(rst)
//		begin
//			host_MAC<=0;
//			host_IP<=0;
//		end
//		else if(CM_Req_usr_en)
//		case(ETH_num)
//			0:	
//			begin
//				host_MAC<=IMC_0_ETH0_MAC_SIM;
//				host_IP<=IMC_0_ETH0_IP;
//			end
//			1:
//			begin
//				host_MAC<=IMC_0_ETH1_MAC_SIM;
//				host_IP<=IMC_0_ETH1_IP;
//			end
//			default:
//			begin
//				host_MAC<=IMC_0_ETH0_MAC_SIM;
//				host_IP<=IMC_0_ETH0_IP;
//			end
//			endcase
	
//	always_ff@(posedge clk or posedge rst)
//		if(rst)						host_PSN<=24'hac_de_fc;
//		else if(CM_REQ_en)			host_PSN<=24'hac_de_fc;
//		else if(RC_SEND_usr_en)		host_PSN<=24'h12_56_34;


	
	RoCE_host_pkt_gen #(
        .C_AXIS_DATA_WIDTH			(512),
        .CHANNEL_NUM				(CHANNEL_NUM)
    ) roce_host_pkt_gen_inst (
        .clk						(clk),
        .rst						(rst),
        .m_axis_tready				(roce_m_axis_tready),
        .m_axis_tdata				(roce_m_axis_tdata),
        .m_axis_tkeep				(roce_m_axis_tkeep),
        .m_axis_tvalid				(roce_m_axis_tvalid),
        .m_axis_tlast				(roce_m_axis_tlast),
        .CM_REQ_en					(CM_REQ_en),
        .CM_RTS_en					(CM_RTS_en),
        .RC_SEND_en					(RC_SEND_en),
        .RC_ACK_en					(RC_ACK_usr_en && need_ACK),
        .need_ACK					(need_ACK),
//        .host_MAC					(host_MAC),
//        .host_IP					(host_IP),
        .fpga_QPN					(fpga_QPN),
        .recv_PSN					(recv_PSN)
//        .host_PSN					(host_PSN)
    );
    
     arp_tx
     #(
     	.CHANNEL_NUM								(CHANNEL_NUM		)
     )  arp_tx
    (
    	.clk 										(clk				),
    	.rstn										(!rst				),
    	
    	.tx_m_axis_tready							(arp_m_axis_tready	),
 		.tx_m_axis_tdata							(arp_m_axis_tdata	),
 		.tx_m_axis_tkeep							(arp_m_axis_tkeep	),
 		.tx_m_axis_tvalid							(arp_m_axis_tvalid	),
 		.tx_m_axis_tlast							(arp_m_axis_tlast	),
 		
 		.fpga_QPN									(fpga_QPN			),

		.arp_req_tx									(arp_req_tx			),
 		.arp_ack_tx									(0					),
 		.arp_ack_tx_done							(),
 		.arp_src_mac								(arp_src_mac		),
 		.arp_src_ip									(arp_src_ip			)
    );
	
	rx_pkt_decode
    #(
    	.C_AXIS_DATA_WIDTH							(C_AXIS_DATA_WIDTH				),
    	.CHANNEL_NUM								(CHANNEL_NUM					)
    )rx_pkt_decode
    (
    	.clk										(clk							),
    	.rstn										(!rst							),
    	.rx_s_axis_tready							(s_axis_tready					),
    	.rx_s_axis_tdata							(s_axis_tdata					),
    	.rx_s_axis_tkeep							(s_axis_tkeep					),
    	.rx_s_axis_tvalid							(s_axis_tvalid					),
    	.rx_s_axis_tlast							(s_axis_tlast					),
    	
    	.RoCE_CM_s_axis_tready						('b1							),
    	.RoCE_cmac_s_axis_tready					('b1							),
    	.arp_s_axis_tready							('b1							),
    	.need_ACK									(need_ACK						),
    	.recv_PSN									(recv_PSN						)
    
    );
	
	
    /*XRNIC_CM_pkt_gen XRNIC_CM_req_gen
  	(
		.core_clk 					(clk							),
		.core_aresetn 				(!rst							),
		.tx_m_axis_tready			(CM_pkt.tready					),
		.tx_m_axis_tdata			(CM_pkt.tdata					),
		.tx_m_axis_tkeep			(CM_pkt.tkeep					),
		.tx_m_axis_tvalid			(CM_pkt.tvalid					),
		.tx_m_axis_tlast			(CM_pkt.tlast					),
		
		.CM_Req_tx_en				(CM_Req_tx_en 					),
		.CM_Req_tvalid				(CM_Req_tvalid					),
		.CM_ReadyToUse_en 			(CM_ReadyToUse_en 				),
		.CM_ReadyToUse_tvalid		(CM_ReadyToUse_tvalid			),
		.CM_reply_tx_en				(								),
		.CM_reply_tx_done			(								),
		
		.recv_MAD_Transaction_ID	(								),
//		.recv_MAD_Attribute_ID		(								),
		.recv_CM_local_Comm_ID		(								),
		.recv_CM_loacl_CA_GUID		(								),
		
		.local_QPN 					(								),
		.local_QPn_Partition_Key	(								)
//		.start_PSN					(start_PSN						)
  	);
  	assign CM_pkt.tready=m_axis_tready;
  	
	RRoCE_pkt_gen RRoCE_pkt_gen
	(
		.clk 						(clk							),
		.rst						(rst							),
		.m_axis_tready				(RoCE_send_pkt.tready			),
		.m_axis_tdata				(RoCE_send_pkt.tdata			),
		.m_axis_tkeep				(RoCE_send_pkt.tkeep			),
		.m_axis_tvalid				(RoCE_send_pkt.tvalid			),
		.m_axis_tlast				(RoCE_send_pkt.tlast			),
		.dest_qp					(24'h2							),
		.payload_data				({'h1234_5678,416'h0}			),
		.send_start					(RoCE_send_en					),
		.send_done					()
	);*/
	assign RoCE_send_pkt.tready=m_axis_tready;
  	
endmodule
