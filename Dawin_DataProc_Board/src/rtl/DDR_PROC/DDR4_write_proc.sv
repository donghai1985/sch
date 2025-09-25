`timescale 1ps/1ps 
`include "XRNIC_define.vh"
`include "XRNIC_REG_configuration.vh"
module DDR4_write_proc #(
  parameter C_AXI_ID_WIDTH           	= 4,
  parameter C_AXI_ADDR_WIDTH         	= 33, 
  parameter C_AXI_DATA_WIDTH         	= 512,
  parameter C_DATA_PATTERN_PRBS      	= 3'd1,
  parameter C_DATA_PATTERN_WALKING0  	= 3'd2,
  parameter C_DATA_PATTERN_WALKING1  	= 3'd3,
  parameter C_DATA_PATTERN_ALL_F     	= 3'd4,
  parameter C_DATA_PATTERN_ALL_0     	= 3'd5,
  parameter C_DATA_PATTERN_A5A5      	= 3'd6,
  parameter C_STRB_PATTERN_DEFAULT   	= 3'd1,
  parameter C_STRB_PATTERN_WALKING1  	= 3'd2,
  parameter C_STRB_PATTERN_WALKING0  	= 3'd3,
  parameter TCQ                      	= 100,
  parameter DDR_PART					= 0,
  parameter SIM 						= "FALSE"
)
( //connected to axi sequence generator
	input                                  		clk,
	input                                  		rst,
	
	input  [511:0] 								TDI_axis_tdata,
    input  										TDI_axis_tvalid,
    (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output  									TDI_axis_tready,
    input  										TDI_axis_tlast,
    input										TDI_fifo_prog_full,
    
    input  [511:0] 								INFO_axis_tdata,
    input  										INFO_axis_tvalid,
    output  									INFO_axis_tready,
    input  										INFO_axis_tlast,
    input										INFO_fifo_prog_full,
    

	input										c_init_calib_complete,
	input                                 		axi_awready, 			// Indicates slave is ready to accept a 
	output logic [C_AXI_ID_WIDTH-1:0]        	axi_awid,    			// Write ID
	output logic [C_AXI_ADDR_WIDTH-1:0]      	axi_awaddr,  			// Write address
	output logic [7:0]                       	axi_awlen,   			// Write Burst Length
	output logic [2:0]                       	axi_awsize,  			// Write Burst size
	output logic [1:0]                       	axi_awburst, 			// Write Burst type
	output logic                             	axi_awlock,  			// Write lock type
	output logic [3:0]                       	axi_awcache, 			// Write Cache type
	output logic [2:0]                       	axi_awprot,  			// Write Protection type
	output logic                             	axi_awvalid, 			// Write address ar_cnt 
// AXI write data channel signals
	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)input                                  		axi_wready,  			// Write data ready
	output logic [C_AXI_DATA_WIDTH-1:0]         axi_wdata,    			// Write data
	output logic [C_AXI_DATA_WIDTH/8-1:0]       axi_wstrb,    			// Write strobes
	output logic                                axi_wlast,    			// Last write transaction   
	output logic                             	axi_wvalid,   			// Write valid  

	input  [C_AXI_ID_WIDTH-1:0]            		axi_bid,     			// Response ID
 	input  [1:0]                           		axi_bresp,   			// Write response
  	input                                  		axi_bvalid,  			// Write reponse valid
  	output logic                             	axi_bready,  			// Response ready
  	
  	input										TDI_trigger,
  	input										track_tlast,
  	input										cm_reply_ddr_write_en,
  	output logic								cm_reply_ddr_write_done,
  	
  	output logic								ddr_TDI_write_done,
  	output logic								ddr_INFO_write_done,
  	
  	input										part_num,
//  	input										first_part_flag,
  	output logic [C_AXI_ADDR_WIDTH-1:0]      	track_last_TDI_DDR_addr=0,
  	output logic [C_AXI_ADDR_WIDTH-1:0]      	track_last_INFO_DDR_addr=0,
  	output logic      							track_last_DDR_addr_vld=0,
  	input	[31:0]								sim_part_valid_line_cnt			,
  	input	[3:0]								IMC_NUM,
  	input	[3:0]								track_num_per_IMC,

  	input [3:0]									rx_MR_QPn,
	input										rx_MR_tvalid,
	input [63:0]								host_MR_addr0,
	input [63:0]								host_MR_addr1,
//	input [63:0]								host_MR_len0,
//	input [63:0]								host_MR_len1,
//	input [31:0]								host_MR_rkey0,
//	input [31:0]								host_MR_rkey1,
	
	input	[47:0]								recv_host_mac,
	input	[31:0]								recv_host_ip,
	input 	[31:0] 								recv_CM_local_Comm_ID,
	input 	[63:0]								recv_CM_loacl_CA_GUID,	
	input	[63:0]								recv_MAD_Transaction_ID,

	input										info_enable,
	
/***************************** 		STATE 	************************/
	output	[9:0]								DDR4_wr_fsm
	
);

//localparam RD_CNT_PER_ROUND=20;
//localparam TOTAL_ROUND=2;
`include "ETH_pkt_define.sv"

//logic		[63:0]							host_MR_addr0_reg	;
//logic		[63:0]							host_MR_addr1_reg	;




//`ifndef SIMULATION_MODE
//vio_DDR_param vio_DDR_param (
//  .clk			(clk),                // input wire clk
//  .probe_out0	(WR_CNT_PER_ROUND),  // output wire [31 : 0] probe_out0
//  .probe_out1	(TOTAL_ROUND),  // output wire [31 : 0] probe_out1
//  .probe_out2	(ddr_mode)
//);
//`else
//	assign WR_CNT_PER_ROUND=10;
//	assign TOTAL_ROUND=20;
//`endif

logic [31:0]									wr_cnt;
(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)logic [31:0]									wr_pkt_cnt;
logic [31:0]									aw_cnt;
(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)logic [19:0]									remain_len=0;
logic [31:0]									ddr_wr_time;
logic [C_AXI_ADDR_WIDTH-1:0]					TDI_ddr_addr=0;
logic [C_AXI_ADDR_WIDTH-1:0]					INFO_ddr_addr=0;
logic [31:0]									track_tlast_cnt=0;

logic		[`CM_REPLY_PKT_LEN*8-1:0]			cm_reply_pkt_send=0;
//logic		[15:0]								cm_reply_ip_csum;
//rocev2_CM_reply_pkt_t 							cm_reply_pkt;
logic		[`RDMA_WRITE_MSG_WQE_SIZE*8-1:0]	write_MSG_start_pkt_send=0;
logic		[`RDMA_WRITE_MSG_WQE_SIZE*8-1:0]	write_MSG_end_pkt_send=0;
logic											is_cm_reply=0;
logic											is_TDI_data=0;
logic											is_write_start_MSG=0;
logic											is_write_end_MSG=0;

logic											ddr_write_done_1=0;
logic											ddr_write_done_2=0;

logic											track_tlast_reg=0;

logic [31:0]									TDI_aw_trigger_cnt=0;
logic											TDI_aw_part_eof;
logic [31:0]									INFO_aw_trigger_cnt=0;
logic											INFO_aw_part_eof;

logic	[31:0]									TDI_trig_num=0;
logic											trigger_part_num=0;
//logic	[31:0]									remain_TDI_trig_num=0;
//logic	[31:0]									TDI_part_trig_num=0;
logic	[31:0]									expected_TDI_DDR_write_num=0;
logic	[31:0]									expected_TDI_DDR_write_num_reg=0;
logic	[31:0]									cur_TDI_DDR_write_num=0;
logic	[31:0]									expected_INFO_DDR_write_num=0;
logic	[31:0]									expected_INFO_DDR_write_num_reg=0;
logic	[31:0]									cur_INFO_DDR_write_num=0;
logic											TDI_track_wr_done;
logic											INFO_track_wr_done;
logic	[7:0]									MSG_track_num=0;
//logic	[7:0]									MSG_seq_num=0;


logic	[3:0]									cur_CM_reply_QPN;
logic	[2:0]									cur_QPN=1;
logic	[23:0]									cur_QPn_SEND_PSN=0;

logic											first_part_port_nxt=0;
logic											first_part_port=0;

logic											first_part_flag;
logic	[1:0]									track_flag;

(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)enum logic [3:0] {	IDLE,
					CM_Reply_AW,CM_Reply_WR,
					wait_host_ready,wait_fifo_prog_full,
//					MSG_START_AW,MSG_START_WR,
					TDI_AW,TDI_WR,TRACK_TDI_DDR_DONE,
					INFO_AW,INFO_WR,TRACK_INFO_DDR_DONE,
					MSG_END_AW,MSG_END_WR,DDR_Error,
					SET_MR_ADDR} cur_st,nxt_st;

/**********************************************************************************************************************/
/*	host MR manager  */
/**********************************************************************************************************************/	
logic	[63:0]							cur_host_MR_addr0;
logic	[63:0]							cur_host_MR_addr1;
//logic	[31:0]							host_MR_rkey0;
//logic	[31:0]							host_MR_rkey1;

logic	[63:0]							host_MR_addr0_reg	[QP_NUM-2:0];
logic	[63:0]							host_MR_addr1_reg	[QP_NUM-2:0];
//logic	[31:0]							host_MR_rkey0_reg	[QP_NUM-2:0];
//logic	[31:0]							host_MR_rkey1_reg	[QP_NUM-2:0];

logic	[63:0]							cur_host_MR_addr0_reg=0	;
logic	[63:0]							cur_host_MR_addr1_reg=0	;

genvar i;
generate
	for(i=0;i<QP_NUM-1;i=i+1)
	begin
		always_ff@(posedge clk or posedge rst)
			if(rst) begin
				host_MR_addr0_reg[i]	<=0;
				host_MR_addr1_reg[i]	<=0;
//				host_MR_rkey0_reg[i]	<=0;
//				host_MR_rkey1_reg[i]	<=0;
			end
			else if(rx_MR_tvalid && (i==(rx_MR_QPn-2))) begin
				host_MR_addr0_reg[i]	<=host_MR_addr0;
				host_MR_addr1_reg[i]	<=host_MR_addr1;
//				host_MR_rkey0_reg[i]	<=host_MR_rkey0;
//				host_MR_rkey1_reg[i]	<=host_MR_rkey1;
			end
	end
endgenerate

assign cur_host_MR_addr0=host_MR_addr0_reg[cur_QPN-1];
assign cur_host_MR_addr1=host_MR_addr1_reg[cur_QPN-1];
//assign host_MR_rkey0=host_MR_rkey0_reg[cur_QPN-1];
//assign host_MR_rkey1=host_MR_rkey1_reg[cur_QPN-1];

always_ff@(posedge clk or posedge rst)
	if(rst) 
		cur_host_MR_addr0_reg	<=0;
	else if(cur_st==IDLE)
		cur_host_MR_addr0_reg	<=cur_host_MR_addr0;
	else if(cur_st==SET_MR_ADDR && track_tlast_cnt==0)
		cur_host_MR_addr0_reg	<=cur_host_MR_addr0;
	else if(cur_st==TDI_AW && axi_awready && axi_awvalid)
		cur_host_MR_addr0_reg	<=cur_host_MR_addr0_reg+((axi_awlen+1)<<6);

always_ff@(posedge clk or posedge rst)
	if(rst) 
		cur_host_MR_addr1_reg	<=0;
	else if(cur_st==IDLE)
		cur_host_MR_addr1_reg	<=cur_host_MR_addr1;
	else if(cur_st==SET_MR_ADDR && track_tlast_cnt==0)
		cur_host_MR_addr1_reg	<=cur_host_MR_addr1;
	else if(cur_st==INFO_AW && axi_awready && axi_awvalid)
		cur_host_MR_addr1_reg	<=cur_host_MR_addr1_reg+((axi_awlen+1)<<6);

/**********************************************************************************************************************/
/*	cur QPN  */
/**********************************************************************************************************************/

always_ff@(posedge clk)
	if(cur_st==MSG_END_WR && axi_wlast && axi_wready && axi_wvalid && track_tlast_cnt==(track_num_per_IMC-1) && cur_QPN>=IMC_NUM)					cur_QPN<=1;
	else if(cur_st==MSG_END_WR && axi_wlast && axi_wready && axi_wvalid && track_tlast_cnt==(track_num_per_IMC-1))									cur_QPN<=cur_QPN+1;		
	
/**********************************************************************************************************************/
/*	DDR WR state  */
/**********************************************************************************************************************/	
always_ff@(posedge clk or posedge rst)
	if(rst)				cur_st<=IDLE;
	else 				cur_st<=nxt_st;

always_comb
begin
	nxt_st=cur_st;
	case(cur_st)
		IDLE:					if(c_init_calib_complete && cm_reply_ddr_write_en)															nxt_st=CM_Reply_AW;
								else if(!c_init_calib_complete && cm_reply_ddr_write_en)													nxt_st=DDR_Error;
								else if(TDI_fifo_prog_full && part_num==DDR_PART)															nxt_st=TDI_AW;
								else if(INFO_fifo_prog_full && info_enable)																	nxt_st=INFO_AW;
								else if(INFO_track_wr_done && TDI_track_wr_done && info_enable)												nxt_st=MSG_END_AW;
								else if(TDI_track_wr_done && (!info_enable))																nxt_st=MSG_END_AW;
		CM_Reply_AW:			if(axi_awvalid && axi_awready)																				nxt_st=CM_Reply_WR;
		CM_Reply_WR:			if(axi_wlast && axi_wready && axi_wvalid)																	nxt_st=IDLE;
//		wait_host_ready:		if(TDI_fifo_prog_full && remain_TDI_trig_num>0)																nxt_st=MSG_START_AW;
//		MSG_START_AW:			if(axi_awvalid && axi_awready)																				nxt_st=MSG_START_WR;
//		MSG_START_WR:			if(axi_wlast && axi_wready && axi_wvalid)																	nxt_st=wait_fifo_prog_full;
		wait_fifo_prog_full:	if(TDI_fifo_prog_full && part_num==DDR_PART)																nxt_st=TDI_AW;
								else if(INFO_fifo_prog_full && info_enable)																	nxt_st=INFO_AW;
								else if(INFO_track_wr_done && TDI_track_wr_done && info_enable)												nxt_st=MSG_END_AW;
								else if(TDI_track_wr_done && (!info_enable))																nxt_st=MSG_END_AW;
		TDI_AW:					if(axi_awready && axi_awvalid && aw_cnt==(`COMPRESSED_WR_BURST_WR_CNT-1))									nxt_st=TDI_WR;
		TDI_WR:					if(axi_wlast && axi_wready && axi_wvalid && wr_pkt_cnt==(`COMPRESSED_WR_BURST_WR_CNT-1))					nxt_st=TRACK_TDI_DDR_DONE;
		INFO_AW:				if(axi_awready && axi_awvalid)																				nxt_st=INFO_WR;
		INFO_WR:				if(axi_wlast && axi_wready && axi_wvalid)																	nxt_st=TRACK_INFO_DDR_DONE;
		TRACK_TDI_DDR_DONE:																													nxt_st=wait_fifo_prog_full;
		TRACK_INFO_DDR_DONE:																												nxt_st=wait_fifo_prog_full;
		MSG_END_AW:				if(axi_awvalid && axi_awready)																				nxt_st=MSG_END_WR;
		MSG_END_WR:				if(axi_wlast && axi_wready && axi_wvalid)																	nxt_st=SET_MR_ADDR;//nxt_st=MSG_START_AW;
		SET_MR_ADDR:																															nxt_st=wait_fifo_prog_full;
		DDR_Error:																															nxt_st=DDR_Error;
		default:																															nxt_st=IDLE;
	endcase
end
assign DDR4_wr_fsm=cur_st;

assign cm_reply_ddr_write_done=cur_st==CM_Reply_WR && axi_wlast && axi_wready && axi_wvalid;
assign ddr_TDI_write_done=cur_st==TRACK_TDI_DDR_DONE;
assign ddr_INFO_write_done=cur_st==TRACK_INFO_DDR_DONE;

always_ff@(posedge clk or posedge rst)
	if(rst)										ddr_wr_time<=0;
	else if(cur_st==IDLE)						ddr_wr_time<=0;
	else if(cur_st==TDI_AW)						ddr_wr_time<=ddr_wr_time+1;
	else if(cur_st==TDI_WR)						ddr_wr_time<=ddr_wr_time+1;  

always_ff@(posedge clk or posedge rst)
	if(rst)																					aw_cnt<=0;
	else if(cur_st==TDI_AW && axi_awvalid && axi_awready)									aw_cnt<=aw_cnt+1;
	else if(cur_st==TDI_AW)																	aw_cnt<=aw_cnt;
	else																					aw_cnt<=0;

always_ff@(posedge clk or posedge rst)
	if(rst)																					wr_cnt<=0;
	else if(cur_st==TDI_WR && axi_wvalid && axi_wready)										wr_cnt<=wr_cnt+1;
	else if(cur_st==TDI_WR)																	wr_cnt<=wr_cnt;
	else if(cur_st==CM_Reply_WR && axi_wvalid && axi_wready)								wr_cnt<=wr_cnt+1;
	else if(cur_st==CM_Reply_WR)															wr_cnt<=wr_cnt;
//	else if(cur_st==MSG_START_WR && axi_wvalid && axi_wready)								wr_cnt<=wr_cnt+1;
//	else if(cur_st==MSG_START_WR)															wr_cnt<=wr_cnt;
	else if(cur_st==MSG_END_WR && axi_wvalid && axi_wready)									wr_cnt<=wr_cnt+1;
	else if(cur_st==MSG_END_WR)																wr_cnt<=wr_cnt;
	else																					wr_cnt<=0;

always_ff@(posedge clk or posedge rst)
	if(rst)																					wr_pkt_cnt<=0;
	else if(cur_st==TDI_WR && axi_wvalid && axi_wready && axi_wlast)						wr_pkt_cnt<=wr_pkt_cnt+1;
	else if(cur_st==TDI_WR)																	wr_pkt_cnt<=wr_pkt_cnt;
	else																					wr_pkt_cnt<=0;
	
always_ff@(posedge clk)
	if(cur_st==wait_fifo_prog_full)										remain_len<=`COMPRESSED_WR_BURST_TOTAL_LEN;
	else if(cur_st==IDLE)												remain_len<=`COMPRESSED_WR_BURST_TOTAL_LEN;
	else if(cur_st==TDI_AW && axi_awready && axi_awvalid)				remain_len<=remain_len-'d256;
	
//always_ff@(posedge clk)
//	if(cur_st==IDLE)							axi_awaddr<=`TDI_DDR_START_ADDR;
//	else if(axi_awvalid && axi_awready)			axi_awaddr<=axi_awaddr+(axi_awlen<<6);


always_ff@(posedge clk)
	if(cur_st==IDLE)																										TDI_ddr_addr<=`TDI_DDR_START_ADDR;
	else if(TDI_aw_part_eof)																								TDI_ddr_addr<=`TDI_DDR_START_ADDR;
	else if(cur_st==TDI_AW && axi_awvalid && axi_awready && (TDI_ddr_addr+((axi_awlen+1)<<6))>`TDI_DDR_END_ADDR)			TDI_ddr_addr<=`TDI_DDR_START_ADDR;
	else if(cur_st==TDI_AW && axi_awvalid && axi_awready)																	TDI_ddr_addr<=TDI_ddr_addr+((axi_awlen+1)<<6);


always_ff@(posedge clk or posedge rst)
	if(rst)																													TDI_aw_trigger_cnt<=0;
	else if(TDI_aw_part_eof)																								TDI_aw_trigger_cnt<=0;
	else if(cur_st==TDI_AW && axi_awvalid && axi_awready && aw_cnt==(`COMPRESSED_WR_BURST_WR_CNT-1))						TDI_aw_trigger_cnt<=TDI_aw_trigger_cnt+`WR_BURST_LINE;

assign TDI_aw_part_eof=TDI_aw_trigger_cnt==sim_part_valid_line_cnt;

always_ff@(posedge clk or posedge rst)
	if(rst)																													INFO_aw_trigger_cnt<=0;
	else if(INFO_aw_part_eof)																								INFO_aw_trigger_cnt<=0;
	else if(cur_st==INFO_AW && axi_awvalid && axi_awready)																	INFO_aw_trigger_cnt<=INFO_aw_trigger_cnt+`INFO_BURST_TRIGGER_CNT;

assign INFO_aw_part_eof=INFO_aw_trigger_cnt==sim_part_valid_line_cnt;

always_ff@(posedge clk)
	if(cur_st==IDLE)																										INFO_ddr_addr<=`INFO_DDR_START_ADDR;
	else if(INFO_aw_part_eof)																								INFO_ddr_addr<=`INFO_DDR_START_ADDR;
	else if(cur_st==INFO_AW && axi_awvalid && axi_awready && (INFO_ddr_addr+((axi_awlen+1)<<6))>`INFO_DDR_END_ADDR)			INFO_ddr_addr<=`INFO_DDR_START_ADDR;
	else if(cur_st==INFO_AW && axi_awvalid && axi_awready)																	INFO_ddr_addr<=INFO_ddr_addr+((axi_awlen+1)<<6);

//always_ff@(posedge clk)
//	if(cur_st==TDI_WR && axi_wlast && axi_wready && axi_wvalid  && wr_pkt_cnt==(`COMPRESSED_WR_BURST_WR_CNT-1) && TDI_part_trig_num==(sim_part_valid_line_cnt-1))		TDI_part_trig_num<=0;
//	else if(cur_st==TDI_WR && axi_wlast && axi_wready && axi_wvalid  && wr_pkt_cnt==(`COMPRESSED_WR_BURST_WR_CNT-1))													TDI_part_trig_num<=TDI_part_trig_num+`WR_BURST_LINE;

always_ff@(posedge clk)
	if(track_tlast)																									TDI_trig_num<=0;
	else if(TDI_trig_num==(sim_part_valid_line_cnt-1) && TDI_trigger)												TDI_trig_num<=0;
	else if(TDI_trigger)																							TDI_trig_num<=TDI_trig_num+1;

always_ff@(posedge clk)
	if(track_tlast && TDI_trig_num>0)																				trigger_part_num<=!trigger_part_num;
	else if(TDI_trig_num==(sim_part_valid_line_cnt-1) && TDI_trigger)												trigger_part_num<=!trigger_part_num;

always_ff@(posedge clk)
	if(TDI_trigger && TDI_trig_num[2:0]==3'd7 && trigger_part_num==DDR_PART)										expected_TDI_DDR_write_num<=expected_TDI_DDR_write_num+1;
	else if(track_tlast)																							expected_TDI_DDR_write_num<=0;						

always_ff@(posedge clk)
	if(track_tlast)																									expected_TDI_DDR_write_num_reg<=expected_TDI_DDR_write_num;

always_ff@(posedge clk)
	if(cur_st==TDI_WR && axi_wvalid && axi_wlast && axi_wready && wr_pkt_cnt==(`COMPRESSED_WR_BURST_WR_CNT-1))		cur_TDI_DDR_write_num<=cur_TDI_DDR_write_num+1;
	else if(cur_st==MSG_END_WR)																						cur_TDI_DDR_write_num<=0;			

always_ff@(posedge clk)
	if(TDI_trigger)																									expected_INFO_DDR_write_num<=expected_INFO_DDR_write_num+`INFO_LEN;
	else if(track_tlast)																							expected_INFO_DDR_write_num<=0;	

always_ff@(posedge clk)
	if(track_tlast)																									expected_INFO_DDR_write_num_reg<=expected_INFO_DDR_write_num;

always_ff@(posedge clk)
	if(cur_st==INFO_WR && axi_wlast && axi_wready && axi_wvalid)													cur_INFO_DDR_write_num<=cur_INFO_DDR_write_num+`INFO_BURST_LEN;
	else if(cur_st==MSG_END_WR)																						cur_INFO_DDR_write_num<=0;						
	

assign TDI_track_wr_done=track_tlast_reg && (cur_TDI_DDR_write_num==expected_TDI_DDR_write_num_reg);
assign INFO_track_wr_done=track_tlast_reg && (cur_INFO_DDR_write_num==expected_INFO_DDR_write_num_reg);

always_ff@(posedge clk)
	if(cur_st==MSG_END_WR && axi_wlast && axi_wready && axi_wvalid)
	begin
		track_last_TDI_DDR_addr<=TDI_ddr_addr;
		track_last_INFO_DDR_addr<=INFO_ddr_addr;
		track_last_DDR_addr_vld<=1;
	end
	else begin
		track_last_TDI_DDR_addr<=0;
		track_last_INFO_DDR_addr<=0;
		track_last_DDR_addr_vld<=0;
	end
	


assign axi_bready='d1;

assign axi_awid=0;
assign axi_awaddr=		(cur_st==CM_Reply_AW)	?	`CM_REPLY_DDR_ADDR			:
//						(cur_st==MSG_START_AW)	?	`WRITE_START_DDR_ADDR		:
						(cur_st==MSG_END_AW)	?	`WRITE_END_DDR_ADDR			:
						(cur_st==INFO_AW)		?	INFO_ddr_addr				:
						(cur_st==TDI_AW)		?	TDI_ddr_addr				:
						0;
						
assign axi_awlen=		(cur_st==CM_Reply_AW)	?	`CM_REPLY_PKT_CNT-1								:
//						(cur_st==MSG_START_AW)	?	`RDMA_WRITE_MSG_CNT-1							:
						(cur_st==MSG_END_AW)	?	`RDMA_WRITE_MSG_CNT-1							:
						(cur_st==INFO_AW)		?	`INFO_BURST_LEN-1								:
						(cur_st==TDI_AW)		?	((remain_len>256)		?	255	:remain_len-1)	:
						0;
						
assign axi_awsize='d6;
assign axi_awburst='d1;
assign axi_awlock='d0;
assign axi_awcache='d0;
assign axi_awprot='d0;
assign axi_awvalid=(cur_st==CM_Reply_AW | cur_st==TDI_AW | cur_st==INFO_AW| cur_st== MSG_END_AW) && axi_awready;	// | cur_st==MSG_START_AW
assign axi_wstrb=64'hffff_ffff_ffff_ffff;

assign axi_wvalid= 	(cur_st==CM_Reply_WR)	?	1									:
//					(cur_st==MSG_START_WR)	?	1									:
					(cur_st==MSG_END_WR)	?	1									:
					(cur_st==INFO_WR)		?	INFO_axis_tvalid && INFO_axis_tready	:
					(cur_st==TDI_WR)		?	TDI_axis_tvalid && TDI_axis_tready	:
					0;
assign axi_wlast=	(cur_st==CM_Reply_WR)	?	wr_cnt==(`CM_REPLY_PKT_CNT-1)		:
//					(cur_st==MSG_START_WR)	?	wr_cnt==(`RDMA_WRITE_MSG_CNT-1)		:
					(cur_st==MSG_END_WR)	?	wr_cnt==(`RDMA_WRITE_MSG_CNT-1)		:
					(cur_st==INFO_WR)		?	INFO_axis_tlast						:
					(cur_st==TDI_WR)		?	TDI_axis_tlast						:
					0;
					
assign axi_wdata=	(cur_st==CM_Reply_WR)	?	hdr_byte_reorder(cm_reply_pkt_send[`CM_REPLY_PKT_LEN*8-1-:512])											:
//					(cur_st==MSG_START_WR)	?	host_tx_data_reorder(hdr_byte_reorder(write_MSG_start_pkt_send[`RDMA_WRITE_MSG_WQE_SIZE*8-1-:512]))		:
					(cur_st==MSG_END_WR)	?	host_tx_data_reorder(hdr_byte_reorder(write_MSG_end_pkt_send[`RDMA_WRITE_MSG_WQE_SIZE*8-1-:512]))		:
					(cur_st==TDI_WR)		?	hdr_byte_reorder(TDI_axis_tdata)																		:
					(cur_st==INFO_WR)		?	hdr_byte_reorder(INFO_axis_tdata)																		:
					0;
assign TDI_axis_tready=cur_st==TDI_WR ? axi_wready : 0;
assign INFO_axis_tready=cur_st==INFO_WR ? axi_wready : 0;

always_ff@(posedge clk)
	if(track_tlast)															track_tlast_reg<=1;
	else if(cur_st==MSG_END_WR && axi_wlast && axi_wready && axi_wvalid)	track_tlast_reg<=0;

always@(posedge clk)
	if(cur_st==MSG_END_WR && axi_wlast && axi_wready && axi_wvalid && track_tlast_cnt==(track_num_per_IMC-1))				track_tlast_cnt<=0;
	else if(cur_st==MSG_END_WR && axi_wlast && axi_wready && axi_wvalid)													track_tlast_cnt<=track_tlast_cnt+1;

/***********************************************************************************************************************/
/* CM reply / RC start / RC end
/***********************************************************************************************************************/
always@(posedge clk) 
		cur_QPn_SEND_PSN<=QPn_Send_Q_PSN*(cur_CM_reply_QPN-1);
		
//assign cm_reply_ip_csum=ipv4_chk_sum_calc(cm_reply_pkt.ipv4_header);
always@(posedge clk) 
	if(cur_st==CM_Reply_AW)											cm_reply_pkt_send<=CM_reply_pkt_build(Local_MAC+DDR_PART,local_IPv4+DDR_PART,recv_host_mac,recv_host_ip,'h1,cur_CM_reply_QPN,cur_QPn_SEND_PSN,recv_CM_local_Comm_ID,recv_CM_loacl_CA_GUID,recv_MAD_Transaction_ID);
	else if(cur_st==CM_Reply_WR && axi_wready && axi_wvalid)		cm_reply_pkt_send<=cm_reply_pkt_send<<512;


QPn_LUT QPn_LUT
(
	.host_IPv4_last_in			(recv_host_ip[7:0]),
	.QPn_out					(cur_CM_reply_QPN)
);

//always@(posedge clk or posedge rst)
//	if(rst)																											MSG_seq_num<=0; 
//	else if(cur_st==MSG_END_WR && axi_wvalid && axi_wready  && axi_wlast && MSG_seq_num==(track_num_per_IMC-1))		MSG_seq_num<=0;
//	else if(cur_st==MSG_END_WR && axi_wvalid && axi_wready  && axi_wlast)											MSG_seq_num<=MSG_seq_num+1;

always@(posedge clk or posedge rst)
	if(rst)																			MSG_track_num<=0; 
	else if(cur_st==MSG_END_WR && axi_wvalid && axi_wready  && axi_wlast)			MSG_track_num<=MSG_track_num+1;

//always@(posedge clk) 
//	if(cur_st==MSG_START_AW)										write_MSG_start_pkt_send<=rocev2_write_MSG_build(8'h0,{7'h0,info_enable},MSG_track_num,seq_num,host_MR_addr0_reg,512'h12345678,host_MR_addr1_reg,512'h90abcdef);
//	else if(cur_st==MSG_START_WR && axi_wready && axi_wvalid)		write_MSG_start_pkt_send<=write_MSG_start_pkt_send<<512;

//always@(posedge clk)
//begin
//	if(first_part_flag)											first_part_port_nxt<=part_num;		//
//	if(cur_st==MSG_END_AW && axi_awvalid && axi_awready)		first_part_port<=first_part_port_nxt;
//end

/********************	FIRST PART NUM	**********************/
always@(posedge clk)
	if(TDI_fifo_prog_full)												track_flag<=1;		//
	else if(cur_st==MSG_END_AW && axi_awvalid && axi_awready)			track_flag<=0;


always@(posedge clk)
	if(TDI_fifo_prog_full && track_flag==0)								first_part_flag<=1;		//
	else																first_part_flag<=0;

always@(posedge clk)
	if(first_part_flag)													first_part_port<=part_num;		//
/**************************************************************/


always@(posedge clk) 
	if(cur_st==MSG_END_AW && axi_awvalid && axi_awready)			write_MSG_end_pkt_send<=rocev2_write_MSG_build(8'h1,{7'h0,info_enable},MSG_track_num,first_part_port,cur_host_MR_addr0_reg,512'h12345678,cur_host_MR_addr1_reg,512'h90abcdef);
	else if(cur_st==MSG_END_WR && axi_wready && axi_wvalid)			write_MSG_end_pkt_send<=write_MSG_end_pkt_send<<512;

//ila_ddr ila_ddr (
//	.clk		(clk), // input wire clk
//	.probe0		(axi_awaddr), // input wire [32:0]  probe0  
//	.probe1		(axi_awvalid), // input wire [0:0]  probe1 
//	.probe2		(axi_awready), // input wire [0:0]  probe2 
//	.probe3		(axi_wdata), // input wire [511:0]  probe3 
//	.probe4		(axi_wvalid), // input wire [0:0]  probe4 
//	.probe5		(axi_wready), // input wire [0:0]  probe5 
//	.probe6		(axi_wlast), // input wire [0:0]  probe6
//	.probe7		(cur_st),
//	.probe8		(track_tlast),
//	.probe9		(track_tlast_reg),
//	.probe10	(cur_TDI_DDR_write_num),
//	.probe11	(expected_TDI_DDR_write_num_reg),
//	.probe12	(cur_INFO_DDR_write_num),
//	.probe13	(expected_INFO_DDR_write_num_reg)
//);

endmodule


