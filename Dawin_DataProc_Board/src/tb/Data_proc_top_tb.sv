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
module Data_proc_top_tb(

    );
    
    localparam RDMA_WRITE_pkt_cnt=`RDMA_WRITE_WQE_SIZE/64;
    localparam DDR_C_AXI_ADDR_WIDTH=33;
    localparam SIM="TRUE";
    
    logic											clk_200;
    logic											clk_300;
    logic											gt_clk;
    logic											s_axi_lite_aclk;
    logic											rst=0;
    logic											CM_Req_usr_en=0;
    logic											MR_SEND_usr_en=0;
    logic											RC_ACK_usr_en=0;
    logic											arp_req_tx=0;
//    logic											ETH_num;
    logic											sim_reg_read_en=0;
    logic	[3:0]									sim_reg_read_QPn=0;
    
    
    

    
    localparam	C_AXIS_DATA_WIDTH=512;
    
	logic                               			s_axis_tready=0;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			s_axis_tdata;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			s_axis_tkeep;
	logic                               			s_axis_tvalid;
	logic                               			s_axis_tlast;
		
	logic                               			m_axis_tready;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			m_axis_tdata;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			m_axis_tkeep;
	logic                               			m_axis_tvalid;
	logic                               			m_axis_tlast;
	
	logic                               			TDI_m_axis_tready_0;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			TDI_m_axis_tdata_0;
	logic                               			TDI_m_axis_tvalid_0;
	logic                               			TDI_m_axis_tlast_0;
	
	logic                               			TDI_m_axis_tready_1;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			TDI_m_axis_tdata_1;
	logic                               			TDI_m_axis_tvalid_1;
	logic                               			TDI_m_axis_tlast_1;
	assign 	TDI_m_axis_tready_1=1;
	
	logic                               			INFO_m_axis_tready;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			INFO_m_axis_tdata;
	logic                               			INFO_m_axis_tvalid;
	logic                               			INFO_m_axis_tlast;
	
	logic											QPn_init_done;
	logic											QP1_init_done;
	logic											ERNIC_init_done;
	logic	[23:0]									fpga_QPN;
	
	logic											rx_rdma_write_start=0;
	logic 	[9:0]									rx_rdma_write_cnt=0;
	
	logic	[31:0]									TOTAL_write_db_cnt='d2;				
  	logic	[31:0]									WQE_write_len='d5120;		
	
	logic                 							c0_sys_clk_p;
	logic                 							c0_sys_clk_n;
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
	
	logic [0 : 0] 									wqe_proc_top_m_axi_arid ;
	logic [31 : 0] 									wqe_proc_top_m_axi_araddr;
	logic [7 : 0] 									wqe_proc_top_m_axi_arlen;
	logic [2 : 0] 									wqe_proc_top_m_axi_arsize;
	logic [1 : 0] 									wqe_proc_top_m_axi_arburst;
	logic [3 : 0] 									wqe_proc_top_m_axi_arcache;
	logic [2 : 0] 									wqe_proc_top_m_axi_arprot;
	logic 											wqe_proc_top_m_axi_arvalid;
	logic											wqe_proc_top_m_axi_arready;    
	logic[0 : 0] 									wqe_proc_top_m_axi_rid  ;
	logic[511 : 0] 									wqe_proc_top_m_axi_rdata;
	logic[1 : 0]									wqe_proc_top_m_axi_rresp;
	logic											wqe_proc_top_m_axi_rlast;    
	logic											wqe_proc_top_m_axi_rvali;    
	logic 											wqe_proc_top_m_axi_rread;   
	logic 											wqe_proc_top_m_axi_arlock;
	
	logic											c0_init_calib_complete;
	
	logic											TDI_sim_start=0;
	logic											TDI_sim_start_auto=0;
	logic											ddr_write_done;
	
	logic											cm_reply_ddr_write_en;
  	logic											cm_reply_ddr_write_done;
  	logic											ddr_write_done;
  	logic											TDI_trigger;
  	logic											track_tlast;
  	logic											RDMA_write_ready;
  	
  	
  	logic		[63:0]								cur_host_MR_addr0;
	logic		[63:0]								cur_host_MR_addr1;
//	logic		[63:0]								host_MR_len0;
//	logic		[63:0]								host_MR_len1;
//	logic		[31:0]								host_MR_rkey0;
//	logic		[31:0]								host_MR_rkey1;
	logic											host_MR_tvalid;
	logic											part_num;
	
	logic		[3:0]								cur_RDMA_QPN;
	logic		[47:0]								recv_host_mac;
	logic		[31:0]								recv_host_ip;
	logic 		[31:0] 								recv_CM_local_Comm_ID;
	logic 		[63:0]								recv_CM_loacl_CA_GUID;
	logic		[63:0]								recv_MAD_Transaction_ID;
	
	logic 		[31:0]      						track_last_TDI_DDR_addr;
  	logic      										track_last_DDR_addr_vld;

	
    initial clk_200=0;
    always #10 clk_200=!clk_200;
    
    initial clk_300=0;
    always #6.6666 clk_300=!clk_300;
    
    initial gt_clk=0;
    always #6.333 gt_clk=!gt_clk;
    
    initial s_axi_lite_aclk=0;
    always #40 s_axi_lite_aclk=!s_axi_lite_aclk;
    
    initial begin
    	rst=0;
    	#200 rst=1;
    	#200 rst=0;
    end
    
    assign c0_sys_clk_p=clk_200;
    assign c0_sys_clk_n=!c0_sys_clk_p;
    
    
	
	TDI_data_proc_top TDI_data_proc_top
   	(
   		.clk						(clk_200				),
   		.clk_300					(clk_300				),
   		.rst						(rst					),
   		.TDI_sim_start				(TDI_sim_start			),
   		.TDI_sim_start_auto			(TDI_sim_start_auto		),
   		
   		.TDI_axis_tdata_0			(TDI_m_axis_tdata_0 	),
   		.TDI_axis_tvalid_0 			(TDI_m_axis_tvalid_0 	),
   		.TDI_axis_tready_0			(TDI_m_axis_tready_0 	),
   		.TDI_axis_tlast_0 			(TDI_m_axis_tlast_0 	),
   		
   		.TDI_axis_tdata_1			(TDI_m_axis_tdata_1 	),
   		.TDI_axis_tvalid_1 			(TDI_m_axis_tvalid_1 	),
   		.TDI_axis_tready_1			(TDI_m_axis_tready_1 	),
   		.TDI_axis_tlast_1 			(TDI_m_axis_tlast_1 	),
   		
   		
   		.TDI_fifo_prog_full			(TDI_m_fifo_prog_full	),
   		
   		.sim_part_valid_line_cnt	(`SIM_PART_LINE			),
   		.sim_track_valid_line_cnt	(`SIM_TRACK_VALID_LINE	),
   		.sim_track_total_line_cnt	(`SIM_TRACK_LINE_CNT	),
   		
   		.part_num					(part_num				),
   		.TDI_trigger				(TDI_trigger			),
   		.track_tlast				(track_tlast			)
   	);
   	
   	INFO_data_sim INFO_data_sim
   	(
   		.clk					(clk_200				),
   		.rst					(rst					),
   		
   		.TDI_trigger			(TDI_trigger			),
   		.track_tlast			(track_tlast			),
   		
   		.INFO_axis_tdata		(INFO_m_axis_tdata 		),
   		.INFO_axis_tvalid 		(INFO_m_axis_tvalid 	),
   		.INFO_axis_tready		(INFO_m_axis_tready 	),
   		.INFO_axis_tlast 		(INFO_m_axis_tlast 		),
   		.INFO_fifo_prog_full	(INFO_m_fifo_prog_full	)

   	);	
     
     
	DDR4_proc#
	(
		.C_AXI_ADDR_WIDTH		(DDR_C_AXI_ADDR_WIDTH),
		.SIM					(SIM)
	)DDR4_proc
	(
		.rst           			(rst),
		.clk_200				(clk_200),
		
		.TDI_axis_tdata			(TDI_m_axis_tdata_0		),
		.TDI_axis_tvalid		(TDI_m_axis_tvalid_0	),
		.TDI_axis_tready		(TDI_m_axis_tready_0	),
		.TDI_axis_tlast			(TDI_m_axis_tlast_0		),
		.TDI_fifo_prog_full		(TDI_m_fifo_prog_full),
		
		.INFO_axis_tdata		(INFO_m_axis_tdata 		),
   		.INFO_axis_tvalid 		(INFO_m_axis_tvalid 	),
   		.INFO_axis_tready		(INFO_m_axis_tready 	),
   		.INFO_axis_tlast 		(INFO_m_axis_tlast 		),
   		.INFO_fifo_prog_full	(INFO_m_fifo_prog_full	),
		
		.c0_init_calib_complete	(c0_init_calib_complete),
		
		.c0_sys_clk_p           (c0_sys_clk_p),
		.c0_sys_clk_n           (c0_sys_clk_n),
		
		.c0_ddr4_act_n          (c0_ddr4_act_n),
		.c0_ddr4_adr            (c0_ddr4_adr),
		.c0_ddr4_ba             (c0_ddr4_ba),
		.c0_ddr4_bg             (c0_ddr4_bg),
		.c0_ddr4_cke            (c0_ddr4_cke),
		.c0_ddr4_odt            (c0_ddr4_odt),
		.c0_ddr4_cs_n           (c0_ddr4_cs_n),
		.c0_ddr4_ck_t           (c0_ddr4_ck_t_int),
		.c0_ddr4_ck_c           (c0_ddr4_ck_c_int),
		.c0_ddr4_reset_n        (c0_ddr4_reset_n),
		.c0_ddr4_dm_dbi_n       (c0_ddr4_dm_dbi_n),
		.c0_ddr4_dq             (c0_ddr4_dq),
		.c0_ddr4_dqs_c          (c0_ddr4_dqs_c),
		.c0_ddr4_dqs_t          (c0_ddr4_dqs_t),
		 
		.ddr4_s_axi_arid		(wqe_proc_top_m_axi_arid),
		.ddr4_s_axi_araddr		({1'b0,wqe_proc_top_m_axi_araddr}),
		.ddr4_s_axi_arlen		(wqe_proc_top_m_axi_arlen),
		.ddr4_s_axi_arsize		(wqe_proc_top_m_axi_arsize),
		.ddr4_s_axi_arprot		(wqe_proc_top_m_axi_arprot),
		.ddr4_s_axi_arburst		(wqe_proc_top_m_axi_arburst),
		.ddr4_s_axi_arcache		(wqe_proc_top_m_axi_arcache),
		.ddr4_s_axi_arvalid		(wqe_proc_top_m_axi_arvalid),
		.ddr4_s_axi_arready		(wqe_proc_top_m_axi_arready),
		.ddr4_s_axi_rready		(wqe_proc_top_m_axi_rready),
		.ddr4_s_axi_rid			(wqe_proc_top_m_axi_rid),
		.ddr4_s_axi_rdata		(wqe_proc_top_m_axi_rdata),
		.ddr4_s_axi_rresp		(wqe_proc_top_m_axi_rresp),
		.ddr4_s_axi_rlast		(wqe_proc_top_m_axi_rlast),
		.ddr4_s_axi_rvalid		(wqe_proc_top_m_axi_rvalid),
		
		
		.cm_reply_ddr_write_en			(cm_reply_ddr_write_en),
		.cm_reply_ddr_write_done		(cm_reply_ddr_write_done),
		.ddr_write_done					(ddr_write_done),
		.TDI_trigger					(TDI_trigger),
		.track_last_TDI_DDR_addr		(track_last_TDI_DDR_addr	),
   		.track_last_DDR_addr_vld		(track_last_DDR_addr_vld),
		.track_tlast					(track_tlast),
		
		.part_num						(part_num),
		
		.cur_RDMA_QPN					(cur_RDMA_QPN),
		.cur_host_MR_addr0				(cur_host_MR_addr0),
		.cur_host_MR_addr1				(cur_host_MR_addr1),

		.recv_host_mac					(recv_host_mac),
		.recv_host_ip					(recv_host_ip),
		.recv_CM_local_Comm_ID			(recv_CM_local_Comm_ID),
		.recv_CM_loacl_CA_GUID			(recv_CM_loacl_CA_GUID),	
		.recv_MAD_Transaction_ID        (recv_MAD_Transaction_ID)

     );
     
     ddr_model_tb_top ddr_model_tb_top
     (
     	.*
     );
     
	
    assign m_axis_tready=1;
    Data_proc_top
    #(
    	.DDR_C_AXI_ADDR_WIDTH		(DDR_C_AXI_ADDR_WIDTH			),
    	.SIM						(SIM							)
    )Data_proc_top
    (
    	.clk 						(clk_200						),
    	.s_axi_lite_aclk			(s_axi_lite_aclk				),
    	.gt_clk						(gt_clk							),
    	.rst						(rst							),
    	
    	.s_axis_tready				(m_axis_tready					),
    	.s_axis_tdata				(m_axis_tdata					),
    	.s_axis_tkeep				(m_axis_tkeep					),
    	.s_axis_tvalid				(m_axis_tvalid					),
    	.s_axis_tlast				(m_axis_tlast					),
    	
//    	.CM_ReadyToUse_en			(CM_ReadyToUse_en				),
//    	.CM_Req_tx_en				(CM_Req_tx_en					),
    	.CM_Req_tvalid				(CM_Req_tvalid					),
    	.CM_ReadyToUse_tvalid		(CM_ReadyToUse_tvalid			),
    	
    	.m_axis_tready				(s_axis_tready					),
    	.m_axis_tdata				(s_axis_tdata					),
    	.m_axis_tkeep				(s_axis_tkeep					),
    	.m_axis_tvalid				(s_axis_tvalid					),
    	.m_axis_tlast				(s_axis_tlast					),
    	
    	.sim_reg_read_en			(sim_reg_read_en				),
    	.sim_reg_read_QPn			(sim_reg_read_QPn				),
    	
    	.QP1_init_done				(QP1_init_done					),
    	.QPn_init_done				(QPn_init_done					),
    	.ERNIC_init_done			(ERNIC_init_done				),
    	
    	.TOTAL_write_db_cnt			(TOTAL_write_db_cnt				),
    	.WQE_write_len				(WQE_write_len					),
    	
		.wqe_proc_top_m_axi_arid					(wqe_proc_top_m_axi_arid		),              
		.wqe_proc_top_m_axi_araddr					(wqe_proc_top_m_axi_araddr		),            
		.wqe_proc_top_m_axi_arlen					(wqe_proc_top_m_axi_arlen		),             
		.wqe_proc_top_m_axi_arsize					(wqe_proc_top_m_axi_arsize		),            
		.wqe_proc_top_m_axi_arburst					(wqe_proc_top_m_axi_arburst		),           
		.wqe_proc_top_m_axi_arcache					(wqe_proc_top_m_axi_arcache		),           
		.wqe_proc_top_m_axi_arprot					(wqe_proc_top_m_axi_arprot		),            
		.wqe_proc_top_m_axi_arvalid					(wqe_proc_top_m_axi_arvalid		),           
		.wqe_proc_top_m_axi_arready					(wqe_proc_top_m_axi_arready		),           
		.wqe_proc_top_m_axi_rid						(wqe_proc_top_m_axi_rid			),               
		.wqe_proc_top_m_axi_rdata					(wqe_proc_top_m_axi_rdata		),             
		.wqe_proc_top_m_axi_rresp					(wqe_proc_top_m_axi_rresp		),             
		.wqe_proc_top_m_axi_rlast					(wqe_proc_top_m_axi_rlast		),             
		.wqe_proc_top_m_axi_rvalid					(wqe_proc_top_m_axi_rvalid		),            
		.wqe_proc_top_m_axi_rready					(wqe_proc_top_m_axi_rready		),            
		.wqe_proc_top_m_axi_arlock					(wqe_proc_top_m_axi_arlock		),     
		
		.cm_reply_ddr_write_en			(cm_reply_ddr_write_en),
		.cm_reply_ddr_write_done		(cm_reply_ddr_write_done),
		.ddr_write_done					(ddr_write_done),
		.track_tlast					(track_tlast),
		.track_last_TDI_DDR_addr			(track_last_TDI_DDR_addr	),
   		.track_last_DDR_addr_vld		(track_last_DDR_addr_vld),
		.RDMA_write_ready				(RDMA_write_ready),
		
		.cur_RDMA_QPN					(cur_RDMA_QPN),
		.cur_host_MR_addr0				(cur_host_MR_addr0),
		.cur_host_MR_addr1				(cur_host_MR_addr1),
		
		.recv_host_mac					(recv_host_mac),
		.recv_host_ip					(recv_host_ip),
		.recv_CM_local_Comm_ID			(recv_CM_local_Comm_ID),
		.recv_CM_loacl_CA_GUID			(recv_CM_loacl_CA_GUID),	
		.recv_MAD_Transaction_ID        (recv_MAD_Transaction_ID)

    );
    
    Host_sim Host_sim
    (
    	.clk 						(gt_clk							),
    	.*
    );
    
	task CM_Req_gen(input [23:0]QPn);
		@(posedge gt_clk);  // 等待时钟上升沿
		fpga_QPN=QPn;
		@(posedge gt_clk);
		CM_Req_usr_en = 1'b1;
		@(posedge gt_clk);  // 等待时钟上升沿
		CM_Req_usr_en = 1'b0;
		$display("start CM_Req_tx_en");
		wait(QPn_init_done);
		$display("QPn INIT DONE");
  	endtask
  	
  	task MR_Send_gen(input [23:0]QPn);
		@(posedge gt_clk);  // 等待时钟上升沿
		MR_SEND_usr_en = 1'b1;
		fpga_QPN=QPn;
		@(posedge gt_clk);  // 等待时钟上升沿
		MR_SEND_usr_en = 1'b0;
		$display("start MR SEND");
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
		wait(c0_init_calib_complete);
		wait(RDMA_write_ready);
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
		@(posedge clk_200);  // 等待时钟上升沿
		sim_reg_read_en = 1'b1;
		sim_reg_read_QPn=QPn;
		@(posedge clk_200);  // 等待时钟上升沿
		@(posedge clk_200);  // 等待时钟上升沿
		@(posedge clk_200);
		@(posedge clk_200);
		sim_reg_read_en = 1'b0;
  	endtask
  	
  	always@(posedge gt_clk)
  		 if(rx_rdma_write_start) begin
  			if(s_axis_tvalid && s_axis_tlast && rx_rdma_write_cnt==(RDMA_WRITE_pkt_cnt-1))
  				rx_rdma_write_cnt<=0;
  			else if(s_axis_tvalid && s_axis_tlast)
  				rx_rdma_write_cnt<=rx_rdma_write_cnt+1;
  				
//  			if(s_axis_tvalid && s_axis_tlast && rx_rdma_write_cnt>7)
  				RC_ACK_enable(2);
  			
  		end
  	
  	initial begin
  		#200 rst=1;
    	#200 rst=0;
		wait(ERNIC_init_done);
		arp_req_tx=1;
		@(posedge clk_300);
		arp_req_tx=0;
		#2000;
		CM_Req_gen(2);
		#2000
		MR_Send_gen(2);
		#1000;
		QPn_reg_read(2);
		wait(s_axis_tvalid && s_axis_tlast);	// wait ACK
		#100;
		rx_rdma_write_start=1;
		#200000;
		rx_rdma_write_start=0;
		$finish;

	end
    
endmodule
