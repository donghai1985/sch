`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/22 10:03:28
// Design Name: 
// Module Name: RDMA_proc_top
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


module RDMA_proc_top#
(
    parameter C_AXI_ADDR_WIDTH          = 33, 
    parameter C_AXI_DATA_WIDTH          = 512, 
    parameter SIM                       ="FALSE",
    parameter CHANNEL_NUM               =0
)(
    input                                           sysclk_100,
    input                                           sysclk_200,
    input											rst,
    
    
    input  [3 :0]                                   gt_rxp_in,
    input  [3 :0]                                   gt_rxn_in,
    output [3 :0]                                   gt_txp_out,
    output [3 :0]                                   gt_txn_out,
    input                                           gt_ref_clk_p,
    input                                           gt_ref_clk_n,
    
    input	[3:0]									IMC_NUM,
    input	[3:0]									track_num_per_IMC,
    input   [31:0]                                  sim_part_valid_line_cnt,
    input                                           info_enable,
    output											db_write_enable,
    input	[31:0]									eth_interval_cnt,
    input	[15:0]									track_num_per_wafer,
    
    input											TDI_trigger,
    input											track_tlast,
    input											part_num,
    input											first_part_flag,
    
    output                               			TDI_axis_tready,
	input  	[C_AXI_DATA_WIDTH-1 : 0]    			TDI_axis_tdata,
	input                               			TDI_axis_tvalid,
	input                               			TDI_axis_tlast,
	input											TDI_fifo_prog_full,
	
	output                               			INFO_axis_tready,
	input  	[C_AXI_DATA_WIDTH-1 : 0]    			INFO_axis_tdata,
	input                               			INFO_axis_tvalid,
	input                               			INFO_axis_tlast,
	input											INFO_fifo_prog_full,
    
    // synthesis translate_off
    input											gt_tx_clk,
    input											rst_usr,
    
    output											c_init_calib_complete,
    output											RDMA_write_ready,
    
    input                               			gt_tx_usr_axis_tready,
    output  [C_AXI_DATA_WIDTH-1 : 0]                gt_tx_usr_axis_tdata,
    output  [C_AXI_DATA_WIDTH/8-1:0]    			gt_tx_usr_axis_tkeep,
    output                               			gt_tx_usr_axis_tvalid,
    output                               			gt_tx_usr_axis_tlast,
    
    output                               			gt_rx_usr_axis_tready,
    input   [C_AXI_DATA_WIDTH-1 : 0]    			gt_rx_usr_axis_tdata,
    input   [C_AXI_DATA_WIDTH/8-1:0]    			gt_rx_usr_axis_tkeep,
    input                               			gt_rx_usr_axis_tvalid,
    input                               			gt_rx_usr_axis_tlast,
    
    output											QPn_init_done,
    output											QP1_init_done,
    output											ERNIC_init_done,
    
    input											sim_reg_read_en,
    input 	[3:0]									sim_reg_read_QPn,

// synthesis translate_on   
    
    input                                           c_sys_clk_p,		// 200M
    input                                           c_sys_clk_n,
    output                                          c_ddr4_act_n,
    output [16:0]                                   c_ddr4_adr,
    output [1:0]                                    c_ddr4_ba,
    output [0:0]                                    c_ddr4_bg,
    output [0:0]                                    c_ddr4_cke,
    output [0:0]                                    c_ddr4_odt,
    output [0:0]                                    c_ddr4_cs_n,
    output [0:0]                                    c_ddr4_ck_t,
    output [0:0]                                    c_ddr4_ck_c,
    output                                          c_ddr4_reset_n,
    inout  [7:0]                                    c_ddr4_dm_dbi_n,
    inout  [63:0]                                   c_ddr4_dq,
    inout  [7:0]                                    c_ddr4_dqs_t,
    inout  [7:0]                                    c_ddr4_dqs_c
    
    
    
    
   );
   
    logic				                           gt_tx_clk;
    logic				                           gt_reset;
(* DONT_TOUCH = "true" *)   logic				   rst_usr;
    
    logic                               			gt_tx_usr_axis_tready;
    logic  	[C_AXI_DATA_WIDTH-1 : 0]    			gt_tx_usr_axis_tdata;
    logic 	[C_AXI_DATA_WIDTH/8-1:0]    			gt_tx_usr_axis_tkeep;
    logic                               			gt_tx_usr_axis_tvalid;
    logic                               			gt_tx_usr_axis_tlast;
    
    logic                               			gt_rx_usr_axis_tready;
    logic  	[C_AXI_DATA_WIDTH-1 : 0]    			gt_rx_usr_axis_tdata;
    logic 	[C_AXI_DATA_WIDTH/8-1:0]    			gt_rx_usr_axis_tkeep;
    logic                               			gt_rx_usr_axis_tvalid;
    logic                               			gt_rx_usr_axis_tlast;
    
    logic	[31:0]									TOTAL_write_db_cnt;				
  	logic	[31:0]									WQE_write_len;		
  	
    logic   [0 : 0] 								wqe_proc_top_m_axi_arid ;
    logic   [C_AXI_ADDR_WIDTH-1 : 0] 				wqe_proc_top_m_axi_araddr;
    logic   [7 : 0] 								wqe_proc_top_m_axi_arlen;
    logic   [2 : 0] 								wqe_proc_top_m_axi_arsize;
    logic   [1 : 0] 								wqe_proc_top_m_axi_arburst;
    logic   [3 : 0] 								wqe_proc_top_m_axi_arcache;
    logic   [2 : 0] 								wqe_proc_top_m_axi_arprot;
	logic 											wqe_proc_top_m_axi_arvalid;
	logic											wqe_proc_top_m_axi_arready;    
    logic   [0 : 0] 								wqe_proc_top_m_axi_rid  ;
    logic   [511 : 0] 								wqe_proc_top_m_axi_rdata;
    logic   [1 : 0]									wqe_proc_top_m_axi_rresp;
	logic											wqe_proc_top_m_axi_rlast;    
	logic											wqe_proc_top_m_axi_rvali;    
	logic 											wqe_proc_top_m_axi_rread;   
	logic 											wqe_proc_top_m_axi_arlock;
	
	logic											c_init_calib_complete;
	
	
//	logic											part_num;
	logic											ddr_TDI_write_done;
	logic											ddr_INFO_write_done;
	
	logic											cm_reply_ddr_write_en;
  	logic											cm_reply_ddr_write_done;
  	logic											RDMA_write_ready;
  	
  	logic [3:0]										rx_MR_QPn		;
	logic											rx_MR_tvalid	;
	logic [63:0]									host_MR_addr0	;
	logic [63:0]									host_MR_addr1	;
//	logic [63:0]									host_MR_len0	;
//	logic [63:0]									host_MR_len1	;
//	logic [31:0]									host_MR_rkey0	;
//	logic [31:0]									host_MR_rkey1	;
	
	logic	[47:0]                                   recv_host_mac;
	logic	[31:0]                                   recv_host_ip;
    logic 	[31:0]                                   recv_CM_local_Comm_ID;
    logic 	[63:0]                                   recv_CM_loacl_CA_GUID;
    logic	[63:0]                                   recv_MAD_Transaction_ID;
	
	logic                               			s_axis_tready=1;
	logic  	[C_AXI_DATA_WIDTH-1 : 0]    			s_axis_tdata;
	logic 	[C_AXI_DATA_WIDTH/8-1:0]    			s_axis_tkeep;
	logic                               			s_axis_tvalid;
	logic                               			s_axis_tlast;
		
	logic                               			m_axis_tready;
	logic  	[C_AXI_DATA_WIDTH-1 : 0]    			m_axis_tdata;
	logic 	[C_AXI_DATA_WIDTH/8-1:0]    			m_axis_tkeep;
	logic                               			m_axis_tvalid;
	logic                               			m_axis_tlast;
	
	
	
	logic											QPn_init_done;
	logic											QP1_init_done;
	logic											ERNIC_init_done;
	
    logic [C_AXI_ADDR_WIDTH-1:0]                   track_last_TDI_DDR_addr;
    logic [C_AXI_ADDR_WIDTH-1:0]                   track_last_INFO_DDR_addr;
  	logic      										track_last_DDR_addr_vld;

/***********************	STATE	***********************************/
	logic [9:0]										DDR4_wr_fsm;
 	logic [9:0]										XRNIC_fsm;
 	logic [9:0]										XRNIC_reg_fsm;
 	logic [31:0]									write_db_cnt;
 	logic [31:0]									db_cq_all_cnt;
 	logic [31:0]									db_write_all_cnt;
 	logic [31:0]									all_time_cnt;
 	logic [31:0]									retry_qp_count;
 	logic [9:0]										XRNIC_db_fsm;
 	logic [9:0]										XRNIC_qp_wr_fsm;
 	logic [63:0]									cmac_tx_speed_reg;
 	
 	logic [7:0]										stat_rx_pause_req;
   
   
generate
if(SIM=="FALSE") begin       
    rst_usr_gen rst_usr_gen
   	(
        .gt_tx_clk                  (gt_tx_clk),
        .gt_reset                   (gt_reset),
        .rst_usr                    (rst_usr)
   	);

    cmac_usplus_top
	#(
		.BANK								(226+CHANNEL_NUM)
	)cmac_usplus_top
	(
		.gt_rxp_in							(gt_rxp_in				),
		.gt_rxn_in							(gt_rxn_in				),
		.gt_txp_out							(gt_txp_out				),
		.gt_txn_out							(gt_txn_out				),
    	.sys_reset 							(rst					),
    	.gt_reset_out						(gt_reset				),
    	.gt_ref_clk_p						(gt_ref_clk_p			),
    	.gt_ref_clk_n						(gt_ref_clk_n			),
    	.init_clk							(sysclk_100				),
    	.tx_clk 							(gt_tx_clk				),
    	
    	.tx_usr_axis_tready					(gt_tx_usr_axis_tready	),
    	.tx_usr_axis_tvalid					(gt_tx_usr_axis_tvalid	),
    	.tx_usr_axis_tdata 					(gt_tx_usr_axis_tdata	),
    	.tx_usr_axis_tkeep 					(gt_tx_usr_axis_tkeep 	),
    	.tx_usr_axis_tlast 					(gt_tx_usr_axis_tlast	),
    	.rx_usr_axis_tvalid					(gt_rx_usr_axis_tvalid	),
    	.rx_usr_axis_tdata 					(gt_rx_usr_axis_tdata	),
    	.rx_usr_axis_tkeep 					(gt_rx_usr_axis_tkeep 	),
    	.rx_usr_axis_tlast 					(gt_rx_usr_axis_tlast	),
    	
    	.stat_rx_pause_req					(stat_rx_pause_req		)
    
    );
    
    CMAC_monitor CMAC_monitor_226
    (
    	.gt_clk 							(gt_tx_clk				),
    	.tx_usr_axis_tready					(gt_tx_usr_axis_tready	),
    	.tx_usr_axis_tvalid					(gt_tx_usr_axis_tvalid	),
    	.tx_usr_axis_tdata 					(gt_tx_usr_axis_tdata	),
    	.tx_usr_axis_tkeep 					(gt_tx_usr_axis_tkeep 	),
    	.tx_usr_axis_tlast 					(gt_tx_usr_axis_tlast	),
    	.cmac_tx_speed_reg					(cmac_tx_speed_reg		)
    );

end
else begin
	assign gt_rx_usr_axis_tready=1;
	assign rst_usr=rst;
end
endgenerate
   
   DDR4_proc
	#(
		.C_AXI_ADDR_WIDTH				(C_AXI_ADDR_WIDTH),
		.SIM							(SIM),
		.CHANNEL_NUM					(CHANNEL_NUM)	
	)DDR4_proc
	(
		.rst           					(rst						),
		.clk_200						(sysclk_200					),
		
		.TDI_axis_tdata					(TDI_axis_tdata				),
		.TDI_axis_tvalid				(TDI_axis_tvalid			),
		.TDI_axis_tready				(TDI_axis_tready			),
		.TDI_axis_tlast					(TDI_axis_tlast				),
		.TDI_fifo_prog_full				(TDI_fifo_prog_full			),
		
		.INFO_axis_tdata				(INFO_axis_tdata 			),
   		.INFO_axis_tvalid 				(INFO_axis_tvalid 			),
   		.INFO_axis_tready				(INFO_axis_tready 			),
   		.INFO_axis_tlast 				(INFO_axis_tlast 			),
   		.INFO_fifo_prog_full			(INFO_fifo_prog_full		),
		
		.c_init_calib_complete			(c_init_calib_complete		),
		
		.c_sys_clk_p           			(c_sys_clk_p				),
		.c_sys_clk_n           			(c_sys_clk_n				),
		
		.c_ddr4_act_n          			(c_ddr4_act_n				),
		.c_ddr4_adr            			(c_ddr4_adr					),
		.c_ddr4_ba             			(c_ddr4_ba					),
		.c_ddr4_bg             			(c_ddr4_bg					),
		.c_ddr4_cke            			(c_ddr4_cke					),
		.c_ddr4_odt            			(c_ddr4_odt					),
		.c_ddr4_cs_n           			(c_ddr4_cs_n				),
		.c_ddr4_ck_t           			(c_ddr4_ck_t				),
		.c_ddr4_ck_c           			(c_ddr4_ck_c				),
		.c_ddr4_reset_n        			(c_ddr4_reset_n				),
		.c_ddr4_dm_dbi_n       			(c_ddr4_dm_dbi_n			),
		.c_ddr4_dq             			(c_ddr4_dq					),
		.c_ddr4_dqs_c          			(c_ddr4_dqs_c				),
		.c_ddr4_dqs_t          			(c_ddr4_dqs_t				),
		 
		.ddr4_s_axi_arid				(wqe_proc_top_m_axi_arid	),
		.ddr4_s_axi_araddr				(wqe_proc_top_m_axi_araddr	),
		.ddr4_s_axi_arlen				(wqe_proc_top_m_axi_arlen	),
		.ddr4_s_axi_arsize				(wqe_proc_top_m_axi_arsize	),
		.ddr4_s_axi_arprot				(wqe_proc_top_m_axi_arprot	),
		.ddr4_s_axi_arburst				(wqe_proc_top_m_axi_arburst	),
		.ddr4_s_axi_arcache				(wqe_proc_top_m_axi_arcache	),
		.ddr4_s_axi_arvalid				(wqe_proc_top_m_axi_arvalid	),
		.ddr4_s_axi_arready				(wqe_proc_top_m_axi_arready	),
		.ddr4_s_axi_rready				(wqe_proc_top_m_axi_rready	),
		.ddr4_s_axi_rid					(wqe_proc_top_m_axi_rid		),
		.ddr4_s_axi_rdata				(wqe_proc_top_m_axi_rdata	),
		.ddr4_s_axi_rresp				(wqe_proc_top_m_axi_rresp	),
		.ddr4_s_axi_rlast				(wqe_proc_top_m_axi_rlast	),
		.ddr4_s_axi_rvalid				(wqe_proc_top_m_axi_rvalid	),
		
		
		.cm_reply_ddr_write_en			(cm_reply_ddr_write_en		),
		.cm_reply_ddr_write_done		(cm_reply_ddr_write_done	),
		.ddr_TDI_write_done				(ddr_TDI_write_done			),
		.ddr_INFO_write_done			(ddr_INFO_write_done		),
		.TDI_trigger					(TDI_trigger				),
		.track_tlast					(track_tlast				),
		.IMC_NUM						(IMC_NUM					),
		.track_num_per_IMC				(track_num_per_IMC			),
		.sim_part_valid_line_cnt		(sim_part_valid_line_cnt	),
		.part_num						(part_num					),
   		.first_part_flag				(first_part_flag			),
		
		.track_last_TDI_DDR_addr		(track_last_TDI_DDR_addr	),
		.track_last_INFO_DDR_addr		(track_last_INFO_DDR_addr	),
    	.track_last_DDR_addr_vld		(track_last_DDR_addr_vld	),
		
		.rx_MR_tvalid					(rx_MR_tvalid				),
		.rx_MR_QPn						(rx_MR_QPn					),
		.host_MR_addr0					(host_MR_addr0				),
		.host_MR_addr1					(host_MR_addr1				),
	//    .host_MR_len0					(host_MR_len0				),
	//    .host_MR_len1					(host_MR_len1				),
//		.host_MR_rkey0					(host_MR_rkey0				),
//		.host_MR_rkey1					(host_MR_rkey1				),

		.recv_host_mac					(recv_host_mac				),
		.recv_host_ip					(recv_host_ip				),
		.recv_CM_local_Comm_ID			(recv_CM_local_Comm_ID		),
		.recv_CM_loacl_CA_GUID			(recv_CM_loacl_CA_GUID		),	
		.recv_MAD_Transaction_ID        (recv_MAD_Transaction_ID	),
		
		.info_enable					(info_enable				),

		.DDR4_wr_fsm					(DDR4_wr_fsm				)

     );
    
    Data_proc_top
    #(
    	.DDR_C_AXI_ADDR_WIDTH          	(C_AXI_ADDR_WIDTH			),
    	.C_AXIS_DATA_WIDTH             	(C_AXI_DATA_WIDTH			),
    	.CHANNEL_NUM					(CHANNEL_NUM				),
    	.SIM                           	(SIM						)
    )Data_proc_top_226
    (
    	.clk 							(sysclk_200					),
    	.s_axi_lite_aclk				(sysclk_100					),
    	.gt_clk							(gt_tx_clk					),
    	.rst							(rst						),
    	
    	.s_axis_tready					(							),
    	.s_axis_tdata					(gt_rx_usr_axis_tdata		),
    	.s_axis_tkeep					(gt_rx_usr_axis_tkeep		),
    	.s_axis_tvalid					(gt_rx_usr_axis_tvalid		),
    	.s_axis_tlast					(gt_rx_usr_axis_tlast		),
    	
    	
//    	.CM_ReadyToUse_en				(CM_ReadyToUse_en				),
//    	.CM_Req_tx_en					(CM_Req_tx_en					),
    	.CM_Req_tvalid					(CM_Req_tvalid					),
    	.CM_ReadyToUse_tvalid			(CM_ReadyToUse_tvalid			),
    	
    	.m_axis_tready					(gt_tx_usr_axis_tready		),
    	.m_axis_tdata					(gt_tx_usr_axis_tdata		),
    	.m_axis_tkeep					(gt_tx_usr_axis_tkeep		),
    	.m_axis_tvalid					(gt_tx_usr_axis_tvalid		),
    	.m_axis_tlast					(gt_tx_usr_axis_tlast		),
    	.stat_rx_pause_req				(stat_rx_pause_req			),
    	
    	.sim_reg_read_en				(sim_reg_read_en				),
    	.sim_reg_read_QPn				(sim_reg_read_QPn				),
    	
    	.QP1_init_done					(QP1_init_done					),
    	.QPn_init_done					(QPn_init_done					),
    	.ERNIC_init_done				(ERNIC_init_done				),
    	
    	.TOTAL_write_db_cnt				(TOTAL_write_db_cnt				),
    	.WQE_write_len					(WQE_write_len					),
    	
		.wqe_proc_top_m_axi_arid		(wqe_proc_top_m_axi_arid		),              
		.wqe_proc_top_m_axi_araddr		(wqe_proc_top_m_axi_araddr		),            
		.wqe_proc_top_m_axi_arlen		(wqe_proc_top_m_axi_arlen		),             
		.wqe_proc_top_m_axi_arsize		(wqe_proc_top_m_axi_arsize		),            
		.wqe_proc_top_m_axi_arburst		(wqe_proc_top_m_axi_arburst		),           
		.wqe_proc_top_m_axi_arcache		(wqe_proc_top_m_axi_arcache		),           
		.wqe_proc_top_m_axi_arprot		(wqe_proc_top_m_axi_arprot		),            
		.wqe_proc_top_m_axi_arvalid		(wqe_proc_top_m_axi_arvalid		),           
		.wqe_proc_top_m_axi_arready		(wqe_proc_top_m_axi_arready		),           
		.wqe_proc_top_m_axi_rid			(wqe_proc_top_m_axi_rid			),               
		.wqe_proc_top_m_axi_rdata		(wqe_proc_top_m_axi_rdata		),             
		.wqe_proc_top_m_axi_rresp		(wqe_proc_top_m_axi_rresp		),             
		.wqe_proc_top_m_axi_rlast		(wqe_proc_top_m_axi_rlast		),             
		.wqe_proc_top_m_axi_rvalid		(wqe_proc_top_m_axi_rvalid		),            
		.wqe_proc_top_m_axi_rready		(wqe_proc_top_m_axi_rready		),            
		.wqe_proc_top_m_axi_arlock		(wqe_proc_top_m_axi_arlock		),     
		
		.cm_reply_ddr_write_en			(cm_reply_ddr_write_en			),
		.cm_reply_ddr_write_done		(cm_reply_ddr_write_done		),
		.ddr_TDI_write_done				(ddr_TDI_write_done				),
		.ddr_INFO_write_done			(ddr_INFO_write_done			),
		.track_tlast					(track_tlast					),
		.RDMA_write_ready				(RDMA_write_ready				),

		.track_last_TDI_DDR_addr		(track_last_TDI_DDR_addr 		),
		.track_last_INFO_DDR_addr		(track_last_INFO_DDR_addr		),
    	.track_last_DDR_addr_vld		(track_last_DDR_addr_vld		),
    	
    	.IMC_NUM						(IMC_NUM						),
    	.track_num_per_IMC				(track_num_per_IMC				),
    	.sim_part_valid_line_cnt		(sim_part_valid_line_cnt		),
    	.eth_interval_cnt				(eth_interval_cnt				),
    	.track_num_per_wafer			(track_num_per_wafer			),
		
		.rx_MR_tvalid					(rx_MR_tvalid					),
		.rx_MR_QPn						(rx_MR_QPn						),
		.host_MR_addr0					(host_MR_addr0					),
		.host_MR_addr1					(host_MR_addr1					),

		.recv_host_mac					(recv_host_mac					),
		.recv_host_ip					(recv_host_ip					),
		.recv_CM_local_Comm_ID			(recv_CM_local_Comm_ID			),
		.recv_CM_loacl_CA_GUID			(recv_CM_loacl_CA_GUID 			),	
		.recv_MAD_Transaction_ID        (recv_MAD_Transaction_ID		),
		
		.info_enable					(info_enable					),
		.db_write_enable				(db_write_enable				),
		
		.XRNIC_fsm						(XRNIC_fsm						),
		.XRNIC_reg_fsm					(XRNIC_reg_fsm					),
		.write_db_cnt					(write_db_cnt					),
		.db_cq_all_cnt					(db_cq_all_cnt					),
		.db_write_all_cnt				(db_write_all_cnt				),
		.all_time_cnt					(all_time_cnt					),
		.retry_qp_count					(retry_qp_count					),
		.XRNIC_db_fsm					(XRNIC_db_fsm					),
		.XRNIC_qp_wr_fsm				(XRNIC_qp_wr_fsm				)
    
    );
   
   
   
   
   
endmodule
