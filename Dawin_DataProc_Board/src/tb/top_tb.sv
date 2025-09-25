`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/13 18:27:07
// Design Name: 
// Module Name: Data_proc_top_tb
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
`include "XRNIC_define.vh"
`include "proj_define.vh"
module top_tb(

    );
	localparam C_AXIS_DATA_WIDTH=512;
	localparam RDMA_WRITE_pkt_cnt=`RDMA_WRITE_WQE_SIZE/64;
	
	
	logic											CM_Req_usr_en=0;
	logic											MR_SEND_usr_en=0;
	logic											RC_ACK_usr_en=0;
	logic											arp_req_tx=0;
	logic	[23:0]									fpga_QPN;
	
`ifdef RDMA_CHANNEL_1    
    logic                               			s_axis_tready_0;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			s_axis_tdata_0;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			s_axis_tkeep_0;
	logic                               			s_axis_tvalid_0;
	logic                               			s_axis_tlast_0;
		
	logic                               			m_axis_tready_0;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			m_axis_tdata_0;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			m_axis_tkeep_0;
	logic                               			m_axis_tvalid_0;
	logic                               			m_axis_tlast_0;
	
//	logic                 							c0_sys_clk_p;
//	logic                 							c0_sys_clk_n;
	logic                 							c0_ddr4_act_n;
	logic  [16:0]          							c0_ddr4_adr;
	logic  [1:0]          							c0_ddr4_ba;
	logic  [0:0]    								c0_ddr4_bg;
	logic  [0:0]           							c0_ddr4_cke;
	logic  [0:0]           							c0_ddr4_odt;
	logic  [0:0]            						c0_ddr4_cs_n;
	logic  [0:0]  									c0_ddr4_ck_t_int;
	logic  [0:0]  									c0_ddr4_ck_c_int;
	logic    										c0_ddr4_ck_t;
	logic    										c0_ddr4_ck_c;
    logic                  							c0_ddr4_reset_n;
    wire  [7:0]            							c0_ddr4_dm_dbi_n;
    wire  [63:0]            						c0_ddr4_dq;
    wire  [7:0]           			 				c0_ddr4_dqs_t;
    wire  [7:0]            							c0_ddr4_dqs_c;
    
    logic											c0_init_calib_complete;
    logic											RDMA_write_ready_0;
	logic											QP1_init_done_0;
	logic											QPn_init_done_0;
	logic											ERNIC_init_done_0;
	
`endif

`ifdef RDMA_CHANNEL_2

	logic                               			s_axis_tready_1;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			s_axis_tdata_1;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			s_axis_tkeep_1;
	logic                               			s_axis_tvalid_1;
	logic                               			s_axis_tlast_1;
		
	logic                               			m_axis_tready_1;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			m_axis_tdata_1;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			m_axis_tkeep_1;
	logic                               			m_axis_tvalid_1;
	logic                               			m_axis_tlast_1;
	
	logic                 							c1_ddr4_act_n;
	logic  [16:0]          							c1_ddr4_adr;
	logic  [1:0]          							c1_ddr4_ba;
	logic  [0:0]    								c1_ddr4_bg;
	logic  [0:0]           							c1_ddr4_cke;
	logic  [0:0]           							c1_ddr4_odt;
	logic  [0:0]            						c1_ddr4_cs_n;
	logic  [0:0]  									c1_ddr4_ck_t_int;
	logic  [0:0]  									c1_ddr4_ck_c_int;
	logic    										c1_ddr4_ck_t;
	logic    										c1_ddr4_ck_c;
    logic                  							c1_ddr4_reset_n;
    wire  [7:0]            							c1_ddr4_dm_dbi_n;
    wire  [63:0]            						c1_ddr4_dq;
    wire  [7:0]           			 				c1_ddr4_dqs_t;
    wire  [7:0]            							c1_ddr4_dqs_c;
   
    logic											c1_init_calib_complete;
    logic											RDMA_write_ready_1;
	logic											QP1_init_done_1;
	logic											QPn_init_done_1;
	logic											ERNIC_init_done_1;
`endif
    	
	logic											sim_reg_read_en=0;
    logic	[3:0]									sim_reg_read_QPn=0;
    logic											TDI_sim_start=0;
    logic											TDI_sim_start_auto=0;
    logic											TDI_max_speed_mode=0;
	
	logic											gt_clk=0;
	
	logic											rx_rdma_write_start=0;
	logic 	[9:0]									rx_rdma_write_cnt=0;

	
	logic 	sysclk_p=0;
	logic	sysclk_n;
	logic 	c0_sys_clk_p=0;
	logic	c0_sys_clk_n;
	logic 	c1_sys_clk_p;
	logic	c1_sys_clk_n;
	logic	rst;
	logic	clk_wiz_locked;
	
	logic	gt0_tx_pause=0;

    always #10 sysclk_p=!sysclk_p;
    assign sysclk_n=!sysclk_p;
    always #5 c0_sys_clk_p=!c0_sys_clk_p;
    assign c0_sys_clk_n=!c0_sys_clk_p;
    assign c1_sys_clk_p=c0_sys_clk_p;
    assign c1_sys_clk_n=c0_sys_clk_n;

    always #3.333 gt_clk=!gt_clk;
    
    localparam CHANNEL_NUM=1;
    
    top #
    (
    	.SIM				("TRUE")	
    )top
    (
    	.sysclk_p						(sysclk_p			),
    	.sysclk_n						(sysclk_n			),
`ifdef RDMA_CHANNEL_1
    	.c0_sys_clk_p					(c0_sys_clk_p		),
    	.c0_sys_clk_n					(c0_sys_clk_n		),
    	.c0_ddr4_act_n          		(c0_ddr4_act_n),
		.c0_ddr4_adr            		(c0_ddr4_adr),
		.c0_ddr4_ba             		(c0_ddr4_ba),
		.c0_ddr4_bg             		(c0_ddr4_bg),
		.c0_ddr4_cke            		(c0_ddr4_cke),
		.c0_ddr4_odt            		(c0_ddr4_odt),
		.c0_ddr4_cs_n           		(c0_ddr4_cs_n),
		.c0_ddr4_ck_t           		(c0_ddr4_ck_t_int),
		.c0_ddr4_ck_c           		(c0_ddr4_ck_c_int),
		.c0_ddr4_reset_n        		(c0_ddr4_reset_n),
		.c0_ddr4_dm_dbi_n       		(c0_ddr4_dm_dbi_n),
		.c0_ddr4_dq             		(c0_ddr4_dq),
		.c0_ddr4_dqs_c          		(c0_ddr4_dqs_c),
		.c0_ddr4_dqs_t          		(c0_ddr4_dqs_t),
`endif
`ifdef RDMA_CHANNEL_2
		.c1_sys_clk_p					(c1_sys_clk_p		),
    	.c1_sys_clk_n					(c1_sys_clk_n		),
		.c1_ddr4_act_n          		(c1_ddr4_act_n),
		.c1_ddr4_adr            		(c1_ddr4_adr),
		.c1_ddr4_ba             		(c1_ddr4_ba),
		.c1_ddr4_bg             		(c1_ddr4_bg),
		.c1_ddr4_cke            		(c1_ddr4_cke),
		.c1_ddr4_odt            		(c1_ddr4_odt),
		.c1_ddr4_cs_n           		(c1_ddr4_cs_n),
		.c1_ddr4_ck_t           		(c1_ddr4_ck_t_int),
		.c1_ddr4_ck_c           		(c1_ddr4_ck_c_int),
		.c1_ddr4_reset_n        		(c1_ddr4_reset_n),
		.c1_ddr4_dm_dbi_n       		(c1_ddr4_dm_dbi_n),
		.c1_ddr4_dq             		(c1_ddr4_dq),
		.c1_ddr4_dqs_c          		(c1_ddr4_dqs_c),
		.c1_ddr4_dqs_t          		(c1_ddr4_dqs_t),
`endif

		/*.c0_init_calib_complete			(c0_init_calib_complete),
		.RDMA_write_ready				(RDMA_write_ready	),
    	
    	.QPn_init_done					(QPn_init_done 		),
    	.QP1_init_done					(QP1_init_done		),
    	.ERNIC_init_done				(ERNIC_init_done	),
    	
    	.sim_reg_read_en				(sim_reg_read_en	),
    	.sim_reg_read_QPn				(sim_reg_read_QPn	),
    	.TDI_sim_start					(TDI_sim_start		),
    	.TDI_sim_start_auto				(TDI_sim_start_auto	),
    	.info_enable					(info_enable		),
    	
    	.gt_226_tx_clk					(gt_clk				)*/
    	.cha_fan_pwm					()
    );
	assign top.TDI_sim_start							=TDI_sim_start;
    assign top.TDI_sim_start_auto						=TDI_sim_start_auto;
    assign top.TDI_max_speed_mode						=TDI_max_speed_mode;

    assign clk_wiz_locked=top.clk_wiz_locked;
    	
    	

`ifdef RDMA_CHANNEL_1
    ddr_model_tb_top ddr_model_tb_top_0
     (
     	.c0_ddr4_act_n          		(c0_ddr4_act_n),
		.c0_ddr4_adr            		(c0_ddr4_adr),
		.c0_ddr4_ba             		(c0_ddr4_ba),
		.c0_ddr4_bg             		(c0_ddr4_bg),
		.c0_ddr4_cke            		(c0_ddr4_cke),
		.c0_ddr4_odt            		(c0_ddr4_odt),
		.c0_ddr4_cs_n           		(c0_ddr4_cs_n),
		.c0_ddr4_ck_t_int           	(c0_ddr4_ck_t_int),
		.c0_ddr4_ck_c_int           	(c0_ddr4_ck_c_int),
		.c0_ddr4_reset_n        		(c0_ddr4_reset_n),
		.c0_ddr4_dm_dbi_n       		(c0_ddr4_dm_dbi_n),
		.c0_ddr4_dq             		(c0_ddr4_dq),
		.c0_ddr4_dqs_c          		(c0_ddr4_dqs_c),
		.c0_ddr4_dqs_t          		(c0_ddr4_dqs_t)
     );
     
     Host_sim
    #(
    	.CHANNEL_NUM				(0								)
    ) Host_sim_0
    (
    	.clk 						(gt_clk							),
    	.s_axis_tready				(s_axis_tready_0				),
    	.s_axis_tdata				(s_axis_tdata_0					),
    	.s_axis_tkeep				(s_axis_tkeep_0					),
    	.s_axis_tvalid				(s_axis_tvalid_0				),
    	.s_axis_tlast				(s_axis_tlast_0					),
    	
    	.m_axis_tready				(m_axis_tready_0				),
    	.m_axis_tdata				(m_axis_tdata_0					),
    	.m_axis_tkeep				(m_axis_tkeep_0					),
    	.m_axis_tvalid				(m_axis_tvalid_0				),
    	.m_axis_tlast 				(m_axis_tlast_0 				),
    	
    	.QPn_init_done				(QPn_init_done_0				),
    	.ERNIC_init_done			(ERNIC_init_done_0				),
    	
    	.*
    	
    );
     
    assign c0_init_calib_complete	=top.RDMA_proc_top_0.c_init_calib_complete;
    assign RDMA_write_ready_0		=top.RDMA_proc_top_0.RDMA_write_ready;
    assign QPn_init_done_0			=top.RDMA_proc_top_0.QPn_init_done;
    assign QP1_init_done_0			=top.RDMA_proc_top_0.QP1_init_done;
    assign ERNIC_init_done_0		=top.RDMA_proc_top_0.ERNIC_init_done;
    assign s_axis_tvalid_0			=top.RDMA_proc_top_0.gt_tx_usr_axis_tvalid;
    assign s_axis_tdata_0			=top.RDMA_proc_top_0.gt_tx_usr_axis_tdata;
    assign s_axis_tkeep_0			=top.RDMA_proc_top_0.gt_tx_usr_axis_tkeep;
    assign s_axis_tlast_0			=top.RDMA_proc_top_0.gt_tx_usr_axis_tlast;
	assign m_axis_tready_0			=top.RDMA_proc_top_0.gt_rx_usr_axis_tready;
	
    assign top.RDMA_proc_top_0.gt_tx_clk				=gt_clk;
    assign top.RDMA_proc_top_0.sim_reg_read_en			=sim_reg_read_en;
    assign top.RDMA_proc_top_0.sim_reg_read_QPn			=sim_reg_read_QPn;
    assign top.RDMA_proc_top_0.gt_tx_usr_axis_tready	=gt0_tx_pause ? 0 : s_axis_tready_0;
    assign top.RDMA_proc_top_0.gt_rx_usr_axis_tvalid	=m_axis_tvalid_0;
    assign top.RDMA_proc_top_0.gt_rx_usr_axis_tdata		=m_axis_tdata_0;
    assign top.RDMA_proc_top_0.gt_rx_usr_axis_tkeep		=m_axis_tkeep_0;
    assign top.RDMA_proc_top_0.gt_rx_usr_axis_tlast		=m_axis_tlast_0;
`endif

`ifdef RDMA_CHANNEL_2
    ddr_model_tb_top ddr_model_tb_top_1
     (
     	.c0_ddr4_act_n          		(c1_ddr4_act_n),
		.c0_ddr4_adr            		(c1_ddr4_adr),
		.c0_ddr4_ba             		(c1_ddr4_ba),
		.c0_ddr4_bg             		(c1_ddr4_bg),
		.c0_ddr4_cke            		(c1_ddr4_cke),
		.c0_ddr4_odt            		(c1_ddr4_odt),
		.c0_ddr4_cs_n           		(c1_ddr4_cs_n),
		.c0_ddr4_ck_t_int           	(c1_ddr4_ck_t_int),
		.c0_ddr4_ck_c_int           	(c1_ddr4_ck_c_int),
		.c0_ddr4_reset_n        		(c1_ddr4_reset_n),
		.c0_ddr4_dm_dbi_n       		(c1_ddr4_dm_dbi_n),
		.c0_ddr4_dq             		(c1_ddr4_dq),
		.c0_ddr4_dqs_c          		(c1_ddr4_dqs_c),
		.c0_ddr4_dqs_t          		(c1_ddr4_dqs_t)
     );
     
     Host_sim
    #(
    	.CHANNEL_NUM				(1								)
    ) Host_sim_1
    (
    	.clk 						(gt_clk							),
    	.s_axis_tready				(s_axis_tready_1				),
    	.s_axis_tdata				(s_axis_tdata_1					),
    	.s_axis_tkeep				(s_axis_tkeep_1					),
    	.s_axis_tvalid				(s_axis_tvalid_1				),
    	.s_axis_tlast				(s_axis_tlast_1					),
    	
    	.m_axis_tready				(m_axis_tready_1				),
    	.m_axis_tdata				(m_axis_tdata_1					),
    	.m_axis_tkeep				(m_axis_tkeep_1					),
    	.m_axis_tvalid				(m_axis_tvalid_1				),
    	.m_axis_tlast 				(m_axis_tlast_1 				),
    	
    	.QPn_init_done				(QPn_init_done_1				),
    	.ERNIC_init_done			(ERNIC_init_done_1				),
    	
    	.*
    	
    );
     
     
    assign c1_init_calib_complete	=top.RDMA_proc_top_1.c_init_calib_complete;
    assign RDMA_write_ready_1		=top.RDMA_proc_top_1.RDMA_write_ready;
    assign QPn_init_done_1			=top.RDMA_proc_top_1.QPn_init_done;
    assign QP1_init_done_1			=top.RDMA_proc_top_1.QP1_init_done;
    assign ERNIC_init_done_1		=top.RDMA_proc_top_1.ERNIC_init_done;
    assign s_axis_tvalid_1			=top.RDMA_proc_top_1.gt_tx_usr_axis_tvalid;
    assign s_axis_tdata_1			=top.RDMA_proc_top_1.gt_tx_usr_axis_tdata;
    assign s_axis_tkeep_1			=top.RDMA_proc_top_1.gt_tx_usr_axis_tkeep;
    assign s_axis_tlast_1			=top.RDMA_proc_top_1.gt_tx_usr_axis_tlast;
	assign m_axis_tready_1			=top.RDMA_proc_top_1.gt_rx_usr_axis_tready;
	
    assign top.RDMA_proc_top_1.gt_tx_clk				=gt_clk;
    assign top.RDMA_proc_top_1.sim_reg_read_en			=sim_reg_read_en;
    assign top.RDMA_proc_top_1.sim_reg_read_QPn			=sim_reg_read_QPn;
    assign top.RDMA_proc_top_1.gt_tx_usr_axis_tready	=s_axis_tready_1;
    assign top.RDMA_proc_top_1.gt_rx_usr_axis_tvalid	=m_axis_tvalid_1;
    assign top.RDMA_proc_top_1.gt_rx_usr_axis_tdata		=m_axis_tdata_1;
    assign top.RDMA_proc_top_1.gt_rx_usr_axis_tkeep		=m_axis_tkeep_1;
    assign top.RDMA_proc_top_1.gt_rx_usr_axis_tlast		=m_axis_tlast_1;
`endif

	
	
    
    task ARP_req_tx_gen(input [23:0]QPn);
    	@(posedge gt_clk);  // 等待时钟上升沿
    	fpga_QPN=QPn;
    	@(posedge gt_clk);
		arp_req_tx = 1'b1;
		@(posedge gt_clk);
		arp_req_tx = 1'b0;
		$display("start ARP_TX");
		#200;
	endtask	
	
    
	task CM_Req_gen(input [23:0]QPn);
		@(posedge gt_clk);  // 等待时钟上升沿
		fpga_QPN=QPn;
		@(posedge gt_clk);
		CM_Req_usr_en = 1'b1;
		@(posedge gt_clk);  // 等待时钟上升沿
		CM_Req_usr_en = 1'b0;
		$display("start CM_Req_tx_en");
		wait(QPn_init_done_0 && QPn_init_done_1);
		$display("QPn INIT DONE");
		#200;
  	endtask
  	
  	task MR_Send_gen(input [23:0]QPn);
		@(posedge gt_clk);  // 等待时钟上升沿
		MR_SEND_usr_en = 1'b1;
		fpga_QPN=QPn;
		@(posedge gt_clk);  // 等待时钟上升沿
		MR_SEND_usr_en = 1'b0;
		$display("start MR SEND");
//		#200;
		wait(s_axis_tvalid_0 && s_axis_tlast_0);	// wait ACK
		#200;
  	endtask
  	
  	task RC_ACK_enable(input [23:0]QPn);
		@(posedge gt_clk);  // 等待时钟上升沿
		RC_ACK_usr_en = 1'b1;
		fpga_QPN=QPn;
		$display("start RC ACK");
  	endtask
  	
  	task RC_ACK_disable(input [23:0]QPn);
		@(posedge gt_clk);  // 等待时钟上升沿
		RC_ACK_usr_en = 1'b0;
		fpga_QPN=QPn;
		$display("stop RC ACK");
  	endtask
  	
  	initial begin
		wait(c0_init_calib_complete && c1_init_calib_complete);
		wait(RDMA_write_ready_0 && RDMA_write_ready_1);
//		gt0_tx_pause=1;

//		#1000 	TDI_max_speed_mode=1'b1;
		#1000  	TDI_sim_start_auto=1;
		
		
//		#1000  
//		@(posedge clk_200);	
//		#5 TDI_sim_start=1;
//		@(posedge clk_200);
//		TDI_sim_start=0;
//		wait(track_tlast);
//		#10000  	
//		@(posedge clk_200);
//		#5 TDI_sim_start=1;
		
    end
  	
  	task QPn_reg_read(input [3:0] QPn);
		@(posedge sysclk_p);  // 等待时钟上升沿
		sim_reg_read_en = 1'b1;
		sim_reg_read_QPn=QPn;
		@(posedge sysclk_p);  // 等待时钟上升沿
		@(posedge sysclk_p);  // 等待时钟上升沿
		@(posedge sysclk_p);
		@(posedge sysclk_p);
		sim_reg_read_en = 1'b0;
  	endtask
  	
  	always@(posedge gt_clk)
  		 if(rx_rdma_write_start) begin
  			if(s_axis_tvalid_0 && s_axis_tlast_0 && rx_rdma_write_cnt==(RDMA_WRITE_pkt_cnt-1))
  				rx_rdma_write_cnt<=0;
  			else if(s_axis_tvalid_0 && s_axis_tlast_0)
  				rx_rdma_write_cnt<=rx_rdma_write_cnt+1;
  				
//  			if(s_axis_tvalid && s_axis_tlast && rx_rdma_write_cnt>7)
  				RC_ACK_enable(2);
  			
  		end
  	
  	initial begin
  		wait(clk_wiz_locked);
  		#200 rst=1;
    	#200 rst=0;

		wait(ERNIC_init_done_0 && ERNIC_init_done_1);
		wait(QP1_init_done_0 && QP1_init_done_1);
		
		if(`SIM_IMC_NUM==1) begin
		ARP_req_tx_gen(2);
		CM_Req_gen(2);
		MR_Send_gen(2);
		end

		if(`SIM_IMC_NUM==2) begin
		
		ARP_req_tx_gen(3);
		CM_Req_gen(3);
		MR_Send_gen(3);
		
		ARP_req_tx_gen(2);
		CM_Req_gen(2);
		MR_Send_gen(2);
		
		end
		
		if(`SIM_IMC_NUM>2) begin
		ARP_req_tx_gen(4);
		CM_Req_gen(4);
		end
		
		/*if(`IMC_NUM>0) begin
		MR_Send_gen(2);
		end
		
		if(`IMC_NUM>1) begin
		MR_Send_gen(3);
		end*/
		
		if(`SIM_IMC_NUM>2) begin
		MR_Send_gen(4);
		end

//		QPn_reg_read(2);
		
		#100;
		rx_rdma_write_start=1;
		#200000;
		rx_rdma_write_start=0;
		$finish;

	end
    
endmodule
