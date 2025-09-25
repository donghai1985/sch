`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/08 14:00:41
// Design Name: 
// Module Name: RDMA_fsm
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
`include "proj_define.vh"
module RDMA_fsm(
	input                             		core_clk,
	input                              		core_aresetn,
	
	input									CM_Req_tvalid,
	input									CM_ReadyToUse_tvalid,
	
	output									CM_reply_tx_en,
	input									CM_reply_tx_done,
	
	/***************************** for sim ************************/
//	output									CM_ReadyToUse_en,
//	output									CM_Req_tx_en,
	/**************************************************************/
//	output									QP1_init_en,
	input									QP1_init_done,
	output									QPn_init_en,
	input									QPn_init_done,
	
	input									ERNIC_init_done,
	
	output logic							RDMA_write_en,
	output logic							RDMA_write_ready,
	
	input	[3:0]							IMC_NUM,
	input	[3:0]							track_num_per_IMC,

	output logic [31:0]						cur_Q_KEY,
	
	input [31:0]							recv_host_ip,
	
	input [3:0]								rx_MR_QPn,
	input									rx_MR_tvalid,
	output	[3:0]							cur_CM_reply_QPN,
	
	input									cmac_m_axis_tready,
	input									cmac_m_axis_tvalid,
	input									cmac_m_axis_tlast,
	
	input									ddr_TDI_write_done,
	input									RDMA_track_done,
	input									track_tlast,
	
	/****************************		STATE	****************************/
  	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic	[9:0]					XRNIC_fsm
	
	
    );
    
    logic [QP_NUM-2:0]						host_MR_done=0;
//    logic	[63:0]							host_MR_addr0_reg	[QP_NUM-2:0];
//	logic	[63:0]							host_MR_addr1_reg	[QP_NUM-2:0];
//	logic	[63:0]							host_MR_len0_reg	[QP_NUM-2:0];
//	logic	[63:0]							host_MR_len1_reg	[QP_NUM-2:0];
//	logic	[31:0]							host_MR_rkey0_reg	[QP_NUM-2:0];
//	logic	[31:0]							host_MR_rkey1_reg	[QP_NUM-2:0];
	
//	logic	[3:0]							track_tlast_cnt=0;
//	logic	[3:0]							cur_RDMA_wr_QPN=0;
    
    
    genvar i;
    generate
    for(i=0;i<QP_NUM-1;i=i+1)
    begin
    	always_ff@(posedge core_clk or negedge core_aresetn)
    		if(!core_aresetn)								host_MR_done[i]<=0;
    		else if(i==(rx_MR_QPn-2) && rx_MR_tvalid)		host_MR_done[i]<=1;
    end
    endgenerate
    
    enum logic [9:0]{IDLE,						wait_CM_Req,
//    				QP1_INIT,					wait_QP1_INIT_DONE,
    				CM_reply,					wait_CM_reply_done,				wait_CM_RTS,QPn_INIT,
    				wait_QPn_INIT_DONE,			wait_ACK_done,					//wait_host_SEND,	
    				RDMA_send_RKEY,				RDMA_recv_RKEY,					RDMA_write,
    				wait_DDR_WR_done,			wait_WRITE_done,
    				ERNIC_error
    				}cur_st,nxt_st;
    
    always@(posedge core_clk or negedge core_aresetn)
    	if(~core_aresetn)					cur_st<=IDLE;
    	else								cur_st<=nxt_st;
   	
   	always@(*)
   	begin
   		nxt_st=cur_st;
   		case(cur_st)
   			IDLE:					if(CM_Req_tvalid && QP1_init_done)										nxt_st=CM_reply;
   									else if(!QP1_init_done && CM_Req_tvalid)								nxt_st=ERNIC_error;
   									else if(host_MR_done==((8'h1<<IMC_NUM)-1))								nxt_st=wait_DDR_WR_done;
   									else if(rx_MR_tvalid)													nxt_st=wait_ACK_done;
   			wait_DDR_WR_done:		if(ddr_TDI_write_done)													nxt_st=RDMA_write;
//			QP1_INIT:																						nxt_st=wait_QP1_INIT_DONE;
//			wait_QP1_INIT_DONE:		if(QP1_init_done)														nxt_st=CM_reply;
   			CM_reply:																						nxt_st=wait_CM_reply_done;
   			wait_CM_reply_done:		if(CM_reply_tx_done)													nxt_st=wait_CM_RTS;
   			wait_CM_RTS:			if(CM_ReadyToUse_tvalid)												nxt_st=QPn_INIT;
   			QPn_INIT:																						nxt_st=wait_QPn_INIT_DONE;
   			wait_QPn_INIT_DONE:		if(QPn_init_done)														nxt_st=IDLE;
//   			wait_host_SEND:			if(rx_MR_tvalid)														nxt_st=wait_ACK_done;
   			wait_ACK_done:			if(cmac_m_axis_tready && cmac_m_axis_tvalid && cmac_m_axis_tlast)		nxt_st=IDLE;
   			RDMA_write:																						nxt_st=wait_WRITE_done;
   			wait_WRITE_done:		if(RDMA_track_done)														nxt_st=RDMA_write;
   			ERNIC_error:																					nxt_st=ERNIC_error;
   			default:																						nxt_st=IDLE;
   		endcase
   	end
   	assign XRNIC_fsm=cur_st;
   	
   	assign RDMA_write_ready=cur_st==wait_DDR_WR_done;
   	assign RDMA_write_en=cur_st==RDMA_write;
//   	assign QP1_init_en=cur_st==QP1_INIT;

   	assign CM_reply_tx_en=cur_st==CM_reply;
   	assign QPn_init_en=cur_st==QPn_INIT;
    
    always@(posedge core_clk or negedge core_aresetn)
    	if(~core_aresetn)						cur_Q_KEY<=0;
    	else if(QPn_init_done)					cur_Q_KEY<=0;
 	
 	QPn_LUT QPn_LUT
 	(
 		.host_IPv4_last_in			(recv_host_ip[7:0]),
 		.QPn_out					(cur_CM_reply_QPN)
 	);
 	
//	generate
//	for(i=0;i<QP_NUM-1;i=i+1)
//	begin
//		always_ff@(posedge core_clk or negedge core_aresetn)
//			if(~core_aresetn) begin
//				host_MR_addr0_reg[i]	<=0;
//				host_MR_addr1_reg[i]	<=0;
//				host_MR_len0_reg[i]		<=0;
//				host_MR_len1_reg[i]		<=0;
//				host_MR_rkey0_reg[i]	<=0;
//				host_MR_rkey1_reg[i]	<=0;
//			end
//			else if(rx_MR_tvalid && (i==(rx_MR_QPn-2))) begin
//				host_MR_addr0_reg[i]	<=host_MR_addr0;
//				host_MR_addr1_reg[i]	<=host_MR_addr1;
//				host_MR_len0_reg[i]		<=host_MR_len0;
//				host_MR_len1_reg[i]		<=host_MR_len1;
//				host_MR_rkey0_reg[i]	<=host_MR_rkey0;
//				host_MR_rkey1_reg[i]	<=host_MR_rkey1;
//			end
//	end
//	endgenerate
	
	
//	always@(posedge core_clk or negedge core_aresetn)
//		if(~core_aresetn)																					cur_RDMA_wr_QPN<=0;
//		else if(track_tlast && track_tlast_cnt==(track_num_per_IMC-1) && cur_RDMA_wr_QPN>=(IMC_NUM-1))		cur_RDMA_wr_QPN<=0;
//		else if(track_tlast && track_tlast_cnt==(track_num_per_IMC-1))										cur_RDMA_wr_QPN<=cur_RDMA_wr_QPN+1;
	
//	always@(posedge core_clk or negedge core_aresetn)
//		if(~core_aresetn)														track_tlast_cnt<=0;
//		else if(track_tlast && track_tlast_cnt==(track_num_per_IMC-1))			track_tlast_cnt<=0;
//		else if(track_tlast)													track_tlast_cnt<=track_tlast_cnt+1;
	
//	assign cur_host_MR_addr0=host_MR_addr0_reg[cur_RDMA_wr_QPN];
//	assign cur_host_MR_addr1=host_MR_addr1_reg[cur_RDMA_wr_QPN];
//	assign cur_host_MR_rkey0=host_MR_rkey0_reg[cur_RDMA_wr_QPN];
//	assign cur_host_MR_rkey1=host_MR_rkey1_reg[cur_RDMA_wr_QPN];

//   	ila_RDMA_fsm ila_RDMA_fsm (
//		.clk		(core_clk), // input wire clk
//		.probe0		(CM_ReadyToUse_tvalid), // input wire [0:0]  probe0  
//		.probe1		(cur_st), // input wire [31:0]  probe1 
//		.probe2		(QPn_init_en), // input wire [0:0]  probe2 
//		.probe3 	(QPn_init_done) // input wire [0:0]  probe3
//	);
 	
 	
endmodule
