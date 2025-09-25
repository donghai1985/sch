`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/13 16:45:35
// Design Name: 
// Module Name: XRNIC_reg_config_fsm
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
//`include "XRNIC_REG_configuration.vh"
(* keep_hierarchy = "yes" *)module XRNIC_reg_config_fsm
#(
  parameter C_S_AXI_LITE_ADDR_WIDTH = 32,
  parameter C_S_AXI_LITE_DATA_WIDTH = 32,
  parameter C_READ_BCK_REG = 0,
  parameter CHANNEL_NUM=0,
  parameter SIM="FALSE"
)(
  input                                    		s_axi_lite_aclk,
  input                                    		s_axi_lite_arstn,
  input 										core_clk,

  output	[C_S_AXI_LITE_ADDR_WIDTH-1:0] 		s_axi_lite_awaddr,
  input                                    		s_axi_lite_awready,
  output                                   		s_axi_lite_awvalid,

  output	[C_S_AXI_LITE_ADDR_WIDTH-1:0] 		s_axi_lite_araddr,
  input                                    		s_axi_lite_arready,
  output                                   		s_axi_lite_arvalid,

  output	[C_S_AXI_LITE_DATA_WIDTH-1:0] 		s_axi_lite_wdata,
  output	[C_S_AXI_LITE_DATA_WIDTH/8 -1:0] 	s_axi_lite_wstrb,
  input                                   		s_axi_lite_wready,
  output                                   		s_axi_lite_wvalid,

  input		[C_S_AXI_LITE_DATA_WIDTH-1:0] 		s_axi_lite_rdata,
  input		[1:0]                         		s_axi_lite_rresp,
  output                                  		s_axi_lite_rready,
  input                                   		s_axi_lite_rvalid,

  input     [1:0]                         		s_axi_lite_bresp,
  output                                  		s_axi_lite_bready,
  input                                   		s_axi_lite_bvalid,

  output logic                                 	ERNIC_init_done,
  input											QPn_init_en,
  output logic									QP1_init_done,
//  input											QP1_init_en,
  output logic									QPn_init_done,
  
  input		[3:0]								local_QPN,
  input		[15:0]								local_QPn_Partition_Key,
  input  	[23:0]								recv_CM_QPN,	
  input		[31:0]								recv_CM_Q_KEY,
  input		[23:0]								recv_QPn_start_PSN,
  input		[47:0]								recv_CM_Dst_MAC,
  input		[31:0]								recv_QPn_IPv4,
  
  input											sim_reg_read_en,
  input		[3:0]								sim_reg_read_QPn,
  
  input		[3:0]								rdma_write_mode,
  
  /****************************		STATE	****************************/
  (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic	[9:0]							XRNIC_reg_fsm
  
  
  
);

	logic [52*QPn_reg_config_part1_num-1 :0]	QPn_reg_config_part1;
	logic [52*QPn_reg_config_part2_num-1 :0]	QPn_reg_config_part2;
	logic [52*QP1_reg_config_num-1 :0]			QP1_reg_config;
	logic [52*XRNIC_basic_reg_config_num-1 :0]	XRNIC_basic_reg_config;
	logic [23:0]								cur_QPn_SEND_PSN=0;

	logic										reg_en;
	logic										reg_wr;
	logic [C_S_AXI_LITE_ADDR_WIDTH-1:0]  		reg_addr;
	logic [C_S_AXI_LITE_DATA_WIDTH-1:0]  		reg_i_data;
	logic										reg_done;
	logic [C_S_AXI_LITE_DATA_WIDTH-1:0]  		reg_o_data;
	logic										reg_o_data_vld;	
	
	logic [C_S_AXI_LITE_ADDR_WIDTH-1:0]  		reg_addr_test;
	
	logic										debug_reg_en;
	logic										debug_reg_en_d;
	logic										debug_reg_pos;
	logic										debug_reg_wr;
	logic [C_S_AXI_LITE_ADDR_WIDTH-1:0]			debug_reg_addr;
	logic [C_S_AXI_LITE_DATA_WIDTH-1:0]  		debug_reg_i_data;
	
	logic										sim_reg_read_en_d;
	
	logic [4:0]									QPn_Timeout_value_real;

	

	logic [15:0]								XRNIC_reg_wr_cnt;
	logic [15:0]								XRNIC_reg_rd_cnt;
	
	logic [15:0]								XRNIC_reg_rd_addr;
	logic [15:0]								XRNIC_reg_wr_addr;

	logic [9:0]									global_status_reg_cnt;
	logic [9:0]									QP_status_reg_cnt;

	logic										read_back_enable;
	
	logic [15:0]								QPn_part1_reg_addr_offset;
	logic [15:0]								QPn_part2_reg_addr_offset;
	
	genvar i;
	logic [20*XRNIC_basic_reg_config_num-1 :0] 	XRNIC_basic_reg;
	logic [20*QPn_reg_config_num-1 :0]			QPn_reg;
	
	
	logic [15:0]								wait_write_ack_cnt;
	
	logic [31:0]								sim_cnt;
	
	
	logic                                 		ERNIC_init_done_int=0;
	logic										QPn_init_en_int;
	logic										QP1_init_done_int=0;
  	logic										QP1_init_en_int;
	logic										QPn_init_done_int;
	
	logic [4:0]									QPn_Timeout_value;
  
	xpm_cdc_pulse #(      .DEST_SYNC_FF(2),.INIT_SYNC_FF(1),.REG_OUTPUT(0),.RST_USED(0),.SIM_ASSERT_CHK(1))
	xpm_cdc_pulse_ERNIC_init_done 		(   .dest_pulse(ERNIC_init_done), 	.dest_clk(core_clk),		.dest_rst('d0),	.src_clk(s_axi_lite_aclk),	.src_pulse(ERNIC_init_done_int),	.src_rst(0)   );

//	xpm_cdc_pulse #(      .DEST_SYNC_FF(2),.INIT_SYNC_FF(1),.REG_OUTPUT(0),.RST_USED(0),.SIM_ASSERT_CHK(1))
//	xpm_cdc_pulse_QP1_init_done 		(   .dest_pulse(QP1_init_done), 	.dest_clk(core_clk),		.dest_rst('d0),	.src_clk(s_axi_lite_aclk),	.src_pulse(QP1_init_done_int),		.src_rst(0)   );
	assign QP1_init_done=QP1_init_done_int;
   	
	xpm_cdc_pulse #(      .DEST_SYNC_FF(2),.INIT_SYNC_FF(1),.REG_OUTPUT(0),.RST_USED(0),.SIM_ASSERT_CHK(1))
	xpm_cdc_pulse_QPn_init_done 		(   .dest_pulse(QPn_init_done), 	.dest_clk(core_clk),		.dest_rst('d0),	.src_clk(s_axi_lite_aclk),	.src_pulse(QPn_init_done_int),		.src_rst(0)   );

	xpm_cdc_pulse #(      .DEST_SYNC_FF(2),.INIT_SYNC_FF(1),.REG_OUTPUT(0),.RST_USED(0),.SIM_ASSERT_CHK(1))
	xpm_cdc_pulse_QPn_init_en 			(   .dest_pulse(QPn_init_en_int), 	.dest_clk(s_axi_lite_aclk),	.dest_rst('d0),	.src_clk(core_clk),			.src_pulse(QPn_init_en),			.src_rst(0)   );
   	
   	xpm_cdc_pulse #(      .DEST_SYNC_FF(2),.INIT_SYNC_FF(1),.REG_OUTPUT(0),.RST_USED(0),.SIM_ASSERT_CHK(1))
   	xpm_cdc_pulse_QP1_init_en 			(   .dest_pulse(QP1_init_en_int), 	.dest_clk(s_axi_lite_aclk),	.dest_rst('d0),	.src_clk(core_clk),			.src_pulse(QP1_init_en),			.src_rst(0)   );
   	
//   	xpm_cdc_single #(      .DEST_SYNC_FF(2),       .INIT_SYNC_FF(1),        .SIM_ASSERT_CHK(1),       .SRC_INPUT_REG(1)   )
//   	xpm_cdc_single_ERNIC_init_done 	(      .dest_out(ERNIC_init_done), 	.dest_clk(core_clk), 	.src_clk(s_axi_lite_aclk),	.src_in(ERNIC_init_done_int)   );
   	
//   	xpm_cdc_single #(      .DEST_SYNC_FF(2),       .INIT_SYNC_FF(1),        .SIM_ASSERT_CHK(1),       .SRC_INPUT_REG(1)   )
//   	xpm_cdc_single_QP1_init_done 	(      .dest_out(QP1_init_done), 	.dest_clk(core_clk), 	.src_clk(s_axi_lite_aclk),	.src_in(QP1_init_done_int)   );
   	
//   	xpm_cdc_single #(      .DEST_SYNC_FF(2),       .INIT_SYNC_FF(1),        .SIM_ASSERT_CHK(1),       .SRC_INPUT_REG(1)   )
//   	xpm_cdc_single_QPn_init_done 	(      .dest_out(QPn_init_done), 	.dest_clk(core_clk), 	.src_clk(s_axi_lite_aclk),	.src_in(QPn_init_done_int)   );
   	
//   	xpm_cdc_single #(      .DEST_SYNC_FF(2),       .INIT_SYNC_FF(1),        .SIM_ASSERT_CHK(1),       .SRC_INPUT_REG(1)   )
//   	xpm_cdc_single_QPn_init_en 	(      .dest_out(QPn_init_en_int), 	.dest_clk(s_axi_lite_aclk), 	.src_clk(core_clk),	.src_in(QPn_init_en)   );
   	
//   	xpm_cdc_single #(      .DEST_SYNC_FF(2),       .INIT_SYNC_FF(1),        .SIM_ASSERT_CHK(1),       .SRC_INPUT_REG(1)   )
//   	xpm_cdc_single_QP1_init_en 	(      .dest_out(QP1_init_en_int), 	.dest_clk(s_axi_lite_aclk), 	.src_clk(core_clk),	.src_in(QP1_init_en)   );

	always@(posedge s_axi_lite_aclk) 
		cur_QPn_SEND_PSN<=QPn_Send_Q_PSN*(local_QPN-1)-24'h1;
		
	assign QPn_reg_config_part1=	{
		{20'h00000,{8{RESERVED}},QPn_PD_num},
		{20'h00004,QPn_virtual_addr[31:0]},
		{20'h00008,QPn_virtual_addr[63:32]},
		{20'h0000C,QPn_base_addr[31:0]},
		{20'h00010,QPn_base_addr[63:32]},
		{20'h00014,{24{RESERVED}},QPn_R_KEY},
		{20'h00018,QPn_buffer_len[31:0]},
		{20'h00010,QPn_buffer_len[47:32],{12{RESERVED}},4'b0010}		// read/write access
	};
	assign QPn_reg_config_part2=	{
		{20'h20200,QPn_RQ_buffer_size,{5{RESERVED}},QPn_PMTU,QPn_QP_IPv4or6,QPn_QP_under_recovery,QPn_CQE_write_enable,QPn_HW_handshake_disable,QPn_CQ_intr_enable,QPn_RQ_intr_enable,1'b0,1'b1},
		{20'h20204,local_QPn_Partition_Key,QPn_Time_to_live,{2{RESERVED}},QPn_Traffic_class},
		{20'h20208,QPn_Rcv_Q_buf_base_addr[31:0]},
		{20'h202C0,QPn_Rcv_Q_buf_base_addr[63:32]},
		{20'h20210,QPn_Send_Q_buf_base_addr[31:0]+{(local_QPN-2'h2)*(QPn_Send_Q_depth<<6)}},
		{20'h202C8,QPn_Send_Q_buf_base_addr[63:32]},
		{20'h20218,QPn_CQ_base_addr[31:0]},
		{20'h202D0,QPn_CQ_base_addr[63:32]},
		{20'h20228,28'h0,local_QPN},
		{20'h20220,28'h0,local_QPN},
		{20'h2023C,QPn_Rcv_Q_depth,QPn_Send_Q_depth},
		{20'h20240,{8{RESERVED}},recv_QPn_start_PSN},
		{20'h20244,{8'h04,cur_QPn_SEND_PSN}},
//		{20'h20244,{8'h04,QPn_Send_Q_PSN-24'h1}},
		{20'h20248,{8{RESERVED}},recv_CM_QPN},
		{20'h2024C,{11{RESERVED}},QPn_RNR_NACK_timeout,{2{RESERVED}},QPn_Max_RNR_retry_cnt,QPn_Max_retry_cnt,{3{RESERVED}},QPn_Timeout_value},	//according to xrnic code, width of timeout valid is 5 which is diff from pg322
		{20'h20250,recv_CM_Dst_MAC[31:0]},
		{20'h20254,{16{RESERVED}},recv_CM_Dst_MAC[47:32]},
		{20'h20260,recv_QPn_IPv4}
	};
//	assign QPn_Timeout_value_real=rdma_write_mode==1 ? 5'h01 : QPn_Timeout_value;

	
	assign QP1_reg_config=	{
		{20'h00000,{8{RESERVED}},QPn_PD_num},
		{20'h00004,QPn_virtual_addr[31:0]},
		{20'h00008,QPn_virtual_addr[63:32]},
		{20'h0000C,QPn_base_addr[31:0]},
		{20'h00010,QPn_base_addr[63:32]},
		{20'h00014,{24{RESERVED}},QPn_R_KEY},
		{20'h00018,QPn_buffer_len[31:0]},
		{20'h00010,QPn_buffer_len[47:32],{12{RESERVED}},4'b0010},
		{20'h20200,QP1_RQ_buffer_size,{5{RESERVED}},QP1_PMTU,QP1_QP_IPv4or6,QP1_QP_under_recovery,QP1_CQE_write_enable,QP1_HW_handshake_disable,QP1_CQ_intr_enable,QP1_RQ_intr_enable,1'b0,1'b1},
		{20'h20208,QP1_Rcv_Q_buf_base_addr[31:0]},
		{20'h202C0,QP1_Rcv_Q_buf_base_addr[63:32]},
		{20'h20210,QP1_Send_Q_buf_base_addr[31:0]},
		{20'h202C8,QP1_Send_Q_buf_base_addr[63:32]},
		{20'h20218,QP1_CQ_base_addr[31:0]},
		{20'h202D0,QP1_CQ_base_addr[63:32]},
		{20'h2023C,QP1_Rcv_Q_depth,QP1_Send_Q_depth},
		{20'h20248,{8{RESERVED}},QP1_Dest_QPID},
		{20'h20250,32'h0},//recv_CM_Dst_MAC[31:0]
		{20'h20254,{16{RESERVED}},16'h0},//recv_CM_Dst_MAC[47:32]
		{20'h20260,32'h0}//recv_QPn_IPv4
	};
	
	assign  XRNIC_basic_reg_config = {
		{20'h2_0000,UDP_src_port,QP_NUM,{2{RESERVED}},ERROR_buffer_enable,TX_ACK_gen,{2{RESERVED}},1'b1},
		{20'h2_0004,12'h0,4'h09,16'h0},
		{20'h2_0008,XOFF,XON},
		{20'h2_000C,{19{RESERVED}},disable_prio_check,PFC_prio_non_RoCE,PFC_prio_RoCE,{2{RESERVED}},PFC_enable_non_RoCE,PFC_enable_RoCE},
		{20'h2_0010,Local_MAC[31:0]+CHANNEL_NUM},
		{20'h2_0014,{16{RESERVED}},Local_MAC[47:32]},
		{20'h2_0018,XOFF_non_RoCE,XON_non_RoCE},
		{20'h2_0020,IPv6_addr[31:0]},
		{20'h2_0024,IPv6_addr[63:32]},
		{20'h2_0028,IPv6_addr[95:64]},
		{20'h2_002C,IPv6_addr[127:96]},
		{20'h2_0060,error_buffer_base_addr[31:0]},
		{20'h2_0064,error_buffer_base_addr[63:32]},
		{20'h2_0068,error_buffer_size,error_buffer_num},
		{20'h2_0070,local_IPv4+CHANNEL_NUM},
		{20'h2_00A0,retry_buffer_base_addr[31:0]},
		{20'h2_00A4,retry_buffer_base_addr[63:32]},
		{20'h2_00A8,retry_buffer_base_addr[63:32]},
		{20'h2_0180,{23{RESERVED}},intr_enable_reg}
	};
	
//	localparam [52*(XRNIC_basic_reg_config_num)-1:0]XRNIC_base_init_reg=	{XRNIC_basic_reg_config};
	
	generate
	for(i=0;i<XRNIC_basic_reg_config_num;i=i+1) begin
		assign XRNIC_basic_reg[i*20+:20]=XRNIC_basic_reg_config[(i+1)*52-1-:20];
	end
	for(i=0;i<QPn_reg_config_num;i=i+1) begin
		if(i<QPn_reg_config_part1_num) begin
			assign QPn_reg[i*20+:20]=QPn_reg_config_part1[(i+1)*52-1-:20];
		end
		else begin
			assign QPn_reg[i*20+:20]=QPn_reg_config_part2[(i-QPn_reg_config_part1_num+1)*52-1-:20];
		end
	end
	endgenerate
	
	logic [20*(XRNIC_basic_reg_config_num+QPn_reg_config_num+global_status_reg_num+QP_status_reg_num)-1:0]XRNIC_rd_reg;
	assign XRNIC_rd_reg=	{{XRNIC_basic_reg},{global_status_reg},{QPn_reg}};
	
	assign read_back_enable=XRNIC_RB_basic_config_rd_en || XRNIC_RB_QP_config_rd_en || XRNIC_RB_globle_config_rd_en || XRNIC_QP_status_reg_rd_en	;
	
	enum logic [9:0]	{	IDLE,					REG_READ_BACK,		
							QP1_REG_PART1_INIT,		QP1_REG_INIT_DONE,
							QPn_REG_Part1_READ,		QPn_REG_Part2_READ,		QPn_Status_read,
							REG_READ_BACK_DONE,		
							BASE_REG_INIT,			BASE_REG_INIT_DONE,		
							QPn_REG_PART1_INIT,		QPn_REG_PART2_INIT,		QPn_REG_INIT_DONE
						} cur_st,nxt_st;
	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)
		if(~s_axi_lite_arstn)					cur_st<=IDLE;
		else									cur_st<=nxt_st;
	
	always@(*)
	begin
		nxt_st=cur_st;
		case(cur_st)
			IDLE:	
									if(SIM=="TRUE" && sim_cnt<100)											nxt_st=IDLE;
									else if(!ERNIC_init_done_int)											nxt_st=BASE_REG_INIT;
									else if(QPn_init_en_int)												nxt_st=QPn_REG_PART1_INIT;
									else if(sim_reg_read_en)												nxt_st=REG_READ_BACK;
									else if(!QP1_init_done_int)												nxt_st=QP1_REG_PART1_INIT;
			REG_READ_BACK:			if(XRNIC_reg_rd_cnt==1 && reg_done && sim_reg_read_en_d)				nxt_st=QPn_REG_Part1_READ;
									else if(XRNIC_reg_rd_cnt==1 && reg_done)								nxt_st=BASE_REG_INIT;
			QP1_REG_PART1_INIT:		if(XRNIC_reg_wr_cnt==1 && reg_done)										nxt_st=QP1_REG_INIT_DONE;
			QP1_REG_INIT_DONE:																				nxt_st=IDLE;
			QPn_REG_Part1_READ:		if(XRNIC_reg_rd_cnt==1 && reg_done)										nxt_st=QPn_REG_Part2_READ;
			QPn_REG_Part2_READ:		if(XRNIC_reg_rd_cnt==1 && reg_done)										nxt_st=QPn_Status_read;
			QPn_Status_read:		if(XRNIC_reg_rd_cnt==1 && reg_done)										nxt_st=REG_READ_BACK_DONE;
			REG_READ_BACK_DONE:																				nxt_st=IDLE;
			BASE_REG_INIT:			if(XRNIC_reg_wr_cnt==1 && reg_done)										nxt_st=BASE_REG_INIT_DONE;	
			BASE_REG_INIT_DONE:																				nxt_st=IDLE;
			QPn_REG_PART1_INIT:		if(XRNIC_reg_wr_cnt==1 && reg_done)										nxt_st=QPn_REG_PART2_INIT;
			QPn_REG_PART2_INIT:		if(XRNIC_reg_wr_cnt==1 && reg_done)										nxt_st=QPn_REG_INIT_DONE;		
			QPn_REG_INIT_DONE:																				nxt_st=IDLE;
			default:																						nxt_st=IDLE;
		endcase
	end
	assign XRNIC_reg_fsm=cur_st;
	
	always_ff@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)
		if(~s_axi_lite_arstn)						sim_cnt<=0;
		else if(SIM=="TRUE" && sim_cnt==10000)		sim_cnt<=10000;
		else if(SIM=="TRUE")						sim_cnt<=sim_cnt+1;
	
	always_ff@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)
		if(~s_axi_lite_arstn)					sim_reg_read_en_d<=0;
		else if(sim_reg_read_en)				sim_reg_read_en_d<=1;
		else if(cur_st==REG_READ_BACK_DONE)		sim_reg_read_en_d<=0;
	
	
	/*initial begin
	wait(QPn_init_done);
	#2000;
	sim_reg_read_en=1;
	wait(cur_st==REG_READ_BACK_DONE)	sim_reg_read_en=0;
	#2000;
//	#100000;
	$finish;
	end*/
	
	assign QPn_init_done_int=cur_st==QPn_REG_INIT_DONE;
//	assign QP1_init_done_int=cur_st==QP1_REG_INIT_DONE;
	always@(posedge s_axi_lite_aclk)
		if(cur_st==QP1_REG_INIT_DONE)	QP1_init_done_int<=1;
	
	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn) 
		if(~s_axi_lite_arstn)						ERNIC_init_done_int<=0;
		else if(cur_st==BASE_REG_INIT_DONE)			ERNIC_init_done_int<=1;
	
	assign QPn_part1_reg_addr_offset=((cur_st==QPn_REG_Part1_READ) | (cur_st==QPn_REG_Part2_READ)) ? sim_reg_read_QPn*16'h0100 : local_QPN*16'h0100;
	assign QPn_part2_reg_addr_offset=((cur_st==QPn_REG_Part1_READ) | (cur_st==QPn_REG_Part2_READ)) ? (sim_reg_read_QPn-1)*16'h0100 :(local_QPN-1)*16'h0100;
	
	assign reg_en=debug_reg_pos | cur_st==REG_READ_BACK | cur_st==QP1_REG_PART1_INIT | cur_st==QPn_REG_Part1_READ | cur_st==QPn_REG_Part2_READ | cur_st==QPn_Status_read | cur_st==BASE_REG_INIT | cur_st==QPn_REG_PART1_INIT | cur_st==QPn_REG_PART2_INIT;
	assign reg_wr=	(cur_st==BASE_REG_INIT | cur_st==QPn_REG_PART1_INIT)	?	`op_write		:
					(cur_st==BASE_REG_INIT | cur_st==QPn_REG_PART2_INIT)	?	`op_write		:
					(cur_st==QP1_REG_PART1_INIT)							?	`op_write		:
					(cur_st==REG_READ_BACK)									?	`op_read		:
					(cur_st==QPn_REG_Part1_READ)							?	`op_read		:
					(cur_st==QPn_REG_Part2_READ)							?	`op_read		:
					(cur_st==QPn_Status_read)								?	`op_read		:
					debug_reg_pos 											?	debug_reg_wr	:
					0;
					
	assign reg_addr=	(cur_st==REG_READ_BACK)						?	XRNIC_rd_reg[XRNIC_reg_rd_addr-1-:20]										:
						(cur_st==QPn_REG_Part1_READ)				?	QPn_reg_config_part1[XRNIC_reg_rd_addr-1-:20]+QPn_part1_reg_addr_offset		:
						(cur_st==QPn_REG_Part2_READ)				?	QPn_reg_config_part2[XRNIC_reg_rd_addr-1-:20]+QPn_part2_reg_addr_offset		:
						(cur_st==QPn_Status_read)					?	QP_status_reg[XRNIC_reg_rd_addr-1-:20]+QPn_part2_reg_addr_offset			:
						(cur_st==BASE_REG_INIT)						?	XRNIC_basic_reg_config[XRNIC_reg_wr_addr-1-:20]								:
						(cur_st==QPn_REG_PART1_INIT)				?	QPn_reg_config_part1[XRNIC_reg_wr_addr-1-:20]+QPn_part1_reg_addr_offset		:
						(cur_st==QPn_REG_PART2_INIT)				?	QPn_reg_config_part2[XRNIC_reg_wr_addr-1-:20]+QPn_part2_reg_addr_offset		:
						(cur_st==QP1_REG_PART1_INIT)				?	QP1_reg_config[XRNIC_reg_wr_addr-1-:20]										:
						debug_reg_pos								?	debug_reg_addr																:
						0;
	
	assign reg_addr_test=QPn_reg_config_part2[XRNIC_reg_wr_addr-1-:20];
	
	assign reg_i_data=	(cur_st==REG_READ_BACK)					?	XRNIC_rd_reg[20*XRNIC_reg_rd_cnt-1-20-:32]								:
						(cur_st==BASE_REG_INIT)					?	XRNIC_basic_reg_config[XRNIC_reg_wr_addr-1-20-:32]							:
						(cur_st==QPn_REG_PART1_INIT)			?	QPn_reg_config_part1[XRNIC_reg_wr_addr-1-20-:32]						:
						(cur_st==QPn_REG_PART2_INIT)			?	QPn_reg_config_part2[XRNIC_reg_wr_addr-1-20-:32]						:
						(cur_st==QP1_REG_PART1_INIT)			?	QP1_reg_config[XRNIC_reg_wr_addr-1-20-:32]									:
						debug_reg_pos							?	debug_reg_i_data														:
						0;
		
	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)
		if(~s_axi_lite_arstn)													XRNIC_reg_rd_cnt<=0;
		else if(cur_st==IDLE)													XRNIC_reg_rd_cnt<=XRNIC_reg_rd_num;
		else if(cur_st==REG_READ_BACK && XRNIC_reg_rd_cnt==1 && reg_done)		XRNIC_reg_rd_cnt<=QPn_reg_config_part1_num;
		else if(cur_st==QPn_REG_Part1_READ && XRNIC_reg_rd_cnt==1 && reg_done)	XRNIC_reg_rd_cnt<=QPn_reg_config_part2_num;
		else if(cur_st==QPn_REG_Part2_READ && XRNIC_reg_rd_cnt==1 && reg_done)	XRNIC_reg_rd_cnt<=QP_status_reg_num;
//		else if(cur_st==QPn_REG_Part2_READ && XRNIC_reg_rd_cnt==1 && reg_done)	XRNIC_reg_rd_cnt<=0;
		else if(cur_st==REG_READ_BACK && reg_done)								XRNIC_reg_rd_cnt<=XRNIC_reg_rd_cnt-1;
		else if(cur_st==QPn_REG_Part1_READ && reg_done)							XRNIC_reg_rd_cnt<=XRNIC_reg_rd_cnt-1;
		else if(cur_st==QPn_REG_Part2_READ && reg_done)							XRNIC_reg_rd_cnt<=XRNIC_reg_rd_cnt-1;
		else if(cur_st==QPn_Status_read && reg_done)							XRNIC_reg_rd_cnt<=XRNIC_reg_rd_cnt-1;
	
	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)
		if(~s_axi_lite_arstn)													XRNIC_reg_rd_addr<=0;
		else if(cur_st==IDLE)													XRNIC_reg_rd_addr<=XRNIC_reg_rd_addr_max;
		else if(cur_st==REG_READ_BACK && XRNIC_reg_rd_cnt==1 && reg_done)		XRNIC_reg_rd_addr<=XRNIC_QPn_reg_p1_addr_max;
		else if(cur_st==REG_READ_BACK && reg_done)								XRNIC_reg_rd_addr<=XRNIC_reg_rd_addr-20;
		else if(cur_st==QPn_REG_Part1_READ && XRNIC_reg_rd_cnt==1 && reg_done)	XRNIC_reg_rd_addr<=XRNIC_QPn_reg_p2_addr_max;
		else if(cur_st==QPn_REG_Part1_READ && reg_done)							XRNIC_reg_rd_addr<=XRNIC_reg_rd_addr-52;
		else if(cur_st==QPn_REG_Part2_READ && XRNIC_reg_rd_cnt==1 && reg_done)	XRNIC_reg_rd_addr<=QP_status_reg_addr_max;
		else if(cur_st==QPn_REG_Part2_READ && reg_done)							XRNIC_reg_rd_addr<=XRNIC_reg_rd_addr-52;
		else if(cur_st==QPn_Status_read && reg_done)							XRNIC_reg_rd_addr<=XRNIC_reg_rd_addr-20;

	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)
		if(~s_axi_lite_arstn)													XRNIC_reg_wr_addr<=0;
		else if(cur_st==IDLE && !ERNIC_init_done_int)							XRNIC_reg_wr_addr<=XRNIC_base_reg_addr_max;
		else if(cur_st==IDLE && QPn_init_en_int)								XRNIC_reg_wr_addr<=XRNIC_QPn_reg_p1_addr_max;
		else if(cur_st==IDLE && !QP1_init_done_int)								XRNIC_reg_wr_addr<=XRNIC_QP1_reg_addr_max;
		else if(cur_st==QPn_REG_PART1_INIT && XRNIC_reg_wr_cnt==1 && reg_done)	XRNIC_reg_wr_addr<=XRNIC_QPn_reg_p2_addr_max;
		else if(cur_st==BASE_REG_INIT && reg_done)								XRNIC_reg_wr_addr<=XRNIC_reg_wr_addr-52;
		else if(cur_st==QPn_REG_PART1_INIT && reg_done)							XRNIC_reg_wr_addr<=XRNIC_reg_wr_addr-52;
		else if(cur_st==QPn_REG_PART2_INIT && reg_done)							XRNIC_reg_wr_addr<=XRNIC_reg_wr_addr-52;
		else if(cur_st==QP1_REG_PART1_INIT && reg_done)							XRNIC_reg_wr_addr<=XRNIC_reg_wr_addr-52;
		
	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)
		if(~s_axi_lite_arstn)																		XRNIC_reg_wr_cnt<=XRNIC_base_reg_num;
		else if(cur_st==IDLE && (!ERNIC_init_done_int))												XRNIC_reg_wr_cnt<=XRNIC_base_reg_num;
		else if(cur_st==IDLE && QPn_init_en_int)													XRNIC_reg_wr_cnt<=QPn_reg_config_part1_num;
		else if(cur_st==IDLE && !QP1_init_done_int)													XRNIC_reg_wr_cnt<=QP1_reg_config_num;
		else if(cur_st==QPn_REG_PART1_INIT && XRNIC_reg_wr_cnt==1 && reg_done)						XRNIC_reg_wr_cnt<=QPn_reg_config_part2_num;
		else if(cur_st==BASE_REG_INIT && reg_done)													XRNIC_reg_wr_cnt<=XRNIC_reg_wr_cnt-1;
		else if(cur_st==QP1_REG_PART1_INIT && reg_done)												XRNIC_reg_wr_cnt<=XRNIC_reg_wr_cnt-1;
		else if(cur_st==QPn_REG_PART1_INIT && reg_done)												XRNIC_reg_wr_cnt<=XRNIC_reg_wr_cnt-1;
		else if(cur_st==QPn_REG_PART2_INIT && reg_done)												XRNIC_reg_wr_cnt<=XRNIC_reg_wr_cnt-1;
		
	always@(posedge s_axi_lite_aclk)
		debug_reg_en_d<=debug_reg_en;
	
	assign debug_reg_pos=debug_reg_en && (~debug_reg_en_d);
	
	
	axi_lite_interface axi_lite_interface
	(
		.s_axi_lite_aclk        	(s_axi_lite_aclk	),
     	.s_axi_lite_arstn       	(s_axi_lite_arstn	),
     	.s_axi_lite_awaddr      	(s_axi_lite_awaddr	),
     	.s_axi_lite_awready     	(s_axi_lite_awready	),
     	.s_axi_lite_awvalid     	(s_axi_lite_awvalid	),
     	.s_axi_lite_araddr      	(s_axi_lite_araddr	),
     	.s_axi_lite_arready     	(s_axi_lite_arready	),
     	.s_axi_lite_arvalid     	(s_axi_lite_arvalid	),
     	.s_axi_lite_wdata       	(s_axi_lite_wdata	),
     	.s_axi_lite_wstrb       	(s_axi_lite_wstrb	),
     	.s_axi_lite_wready      	(s_axi_lite_wready	),
     	.s_axi_lite_wvalid      	(s_axi_lite_wvalid	),
     	.s_axi_lite_rdata       	(s_axi_lite_rdata	),
     	.s_axi_lite_rresp       	(s_axi_lite_rresp	),
     	.s_axi_lite_rready      	(s_axi_lite_rready	),
     	.s_axi_lite_rvalid      	(s_axi_lite_rvalid	),
     	.s_axi_lite_bresp       	(s_axi_lite_bresp	),
     	.s_axi_lite_bready      	(s_axi_lite_bready	),
     	.s_axi_lite_bvalid      	(s_axi_lite_bvalid 	),
     	
		.i_en						(reg_en 			),
		.i_wr						(reg_wr				),
		.i_addr						(reg_addr			),
		.i_data						(reg_i_data			),
		.o_done						(reg_done			),
		.o_data						(reg_o_data			),
		.o_data_vld					(reg_o_data_vld		)
	
	);
	
	vio_reg_config vio_reg_config (
	  .clk				(s_axi_lite_aclk	),  // input wire clk
	  .probe_out0		(debug_reg_en		),  // output wire [0 : 0] probe_out0
	  .probe_out1		(debug_reg_wr		),  // output wire [0 : 0] probe_out1
	  .probe_out2		(debug_reg_addr		),  // output wire [31 : 0] probe_out2
	  .probe_out3		(debug_reg_i_data	),  // output wire [31 : 0] probe_out3
	  .probe_out4		(QPn_Timeout_value	),
	  .probe_in0		(reg_o_data			)
	);


//	ila_XRNIC_reg ila_XRNIC_reg (
//		.clk		(s_axi_lite_aclk	), // input wire clk
//		.probe0		(reg_en				), // input wire [0:0]  probe0  
//		.probe1		(reg_wr				), // input wire [0:0]  probe1 
//		.probe2		(reg_addr			), // input wire [31:0]  probe2 
//		.probe3		(reg_i_data			), // input wire [31:0]  probe3 
//		.probe4		(reg_done			), // input wire [0:0]  probe4 
//		.probe5		(reg_o_data			), // input wire [31:0]  probe5 
//		.probe6		(reg_o_data_vld		), // input wire [0:0]  probe6
//		.probe7		(cur_st				),
//		.probe8		(QPn_init_en_int	)
//	);

	
	

endmodule
