`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/13 15:42:23
// Design Name: 
// Module Name: Data_proc_top
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

`include "proj_define.vh"
module Data_proc_top#
(
	parameter DDR_C_AXI_ADDR_WIDTH		= 32,
	parameter	C_AXIS_DATA_WIDTH 	= 512,
	parameter CHANNEL_NUM=0,
	parameter SIM="FALSE"
)(
input 										clk,
input 										s_axi_lite_aclk,
input										gt_clk,
input 										rst,

output                               		s_axis_tready,
input  	[C_AXIS_DATA_WIDTH-1 : 0]    		s_axis_tdata,
input 	[C_AXIS_DATA_WIDTH/8-1:0]    		s_axis_tkeep,
input                               		s_axis_tvalid,
input                               		s_axis_tlast,
	
input                               		m_axis_tready,
output  [C_AXIS_DATA_WIDTH-1 : 0]    		m_axis_tdata,
output 	[C_AXIS_DATA_WIDTH/8-1:0]    		m_axis_tkeep,
output                               		m_axis_tvalid,
output                               		m_axis_tlast,
input	[7:0]								stat_rx_pause_req,

//output											CM_ReadyToUse_en,
//output											CM_Req_tx_en,
input										sim_reg_read_en,
input	[3:0]								sim_reg_read_QPn,

output  [0 : 0] 							wqe_proc_top_m_axi_arid    	,
output  [DDR_C_AXI_ADDR_WIDTH-1 : 0] 		wqe_proc_top_m_axi_araddr 	,
output  [7 : 0] 							wqe_proc_top_m_axi_arlen   	,
output  [2 : 0] 							wqe_proc_top_m_axi_arsize  	,
output  [1 : 0] 							wqe_proc_top_m_axi_arburst 	,
output  [3 : 0] 							wqe_proc_top_m_axi_arcache 	,
output  [2 : 0] 							wqe_proc_top_m_axi_arprot  	,
output  									wqe_proc_top_m_axi_arvalid 	,
input  										wqe_proc_top_m_axi_arready 	,         
input  [0 : 0] 								wqe_proc_top_m_axi_rid     	, 
input  [511 : 0] 							wqe_proc_top_m_axi_rdata  	,
input  [1 : 0]								wqe_proc_top_m_axi_rresp   	, 
input  										wqe_proc_top_m_axi_rlast   	,         
input  										wqe_proc_top_m_axi_rvalid  	,         
output  									wqe_proc_top_m_axi_rready  	,        
output  									wqe_proc_top_m_axi_arlock  	,    



input										ddr_TDI_write_done,
input 										ddr_INFO_write_done,
output										cm_reply_ddr_write_en,
input										cm_reply_ddr_write_done,
input										track_tlast,
output										RDMA_write_ready,

output [3:0]								rx_MR_QPn,
output										rx_MR_tvalid,
output [63:0]								host_MR_addr0,
output [63:0]								host_MR_addr1,
//	output [63:0]								host_MR_len0,
//	output [63:0]								host_MR_len1,
//output [31:0]								host_MR_rkey0,
//output [31:0]								host_MR_rkey1,

output		[47:0]							recv_host_mac,
output		[31:0]							recv_host_ip,
output 		[31:0] 							recv_CM_local_Comm_ID,
output 		[63:0]							recv_CM_loacl_CA_GUID,	
output		[63:0]							recv_MAD_Transaction_ID,

input  		[DDR_C_AXI_ADDR_WIDTH-1:0]      track_last_TDI_DDR_addr,
input  		[DDR_C_AXI_ADDR_WIDTH-1:0]      track_last_INFO_DDR_addr,
input       								track_last_DDR_addr_vld,

input	[3:0]								IMC_NUM,
input	[3:0]								track_num_per_IMC,
input	[31:0]								sim_part_valid_line_cnt,
input	[15:0]								track_num_per_wafer,
input	[31:0]								eth_interval_cnt,

output										CM_Req_tvalid,
output										CM_ReadyToUse_tvalid,
output										QP1_init_done,
output										QPn_init_done,
output										ERNIC_init_done,

input		[31:0]							TOTAL_write_db_cnt,				
input		[31:0]							WQE_write_len,

input										info_enable,
output										db_write_enable,

/***************************** 		STATE 	************************/
output logic [9:0]							XRNIC_fsm,
output logic [9:0]							XRNIC_reg_fsm,
output logic [31:0]							write_db_cnt,
output logic [31:0]							db_cnt,
output logic [31:0]							db_cq_all_cnt,
output logic [31:0]							db_write_all_cnt,
output logic [31:0]							all_time_cnt,
output logic [31:0]							retry_qp_count,
output logic [9:0]							XRNIC_db_fsm,
output logic [9:0]							XRNIC_qp_wr_fsm
    );
   
    logic                               			cmac_m_axis_tready;
    logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			cmac_m_axis_tdata;
    logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			cmac_m_axis_tkeep;
    logic                               			cmac_m_axis_tvalid;
    logic                               			cmac_m_axis_tlast;
    	
    logic                               			roce_cmac_s_axis_tready;
    logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			roce_cmac_s_axis_tdata;
    logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			roce_cmac_s_axis_tkeep;
    logic                               			roce_cmac_s_axis_tvalid;
	logic                               			roce_cmac_s_axis_tlast;
    
    logic	[31:0]									cur_Q_KEY;
    
    
    logic											CM_reply_tx_en;
//    logic											CM_reply_tx_done;
    
    logic	[47:0]									CM_dst_mac;
    logic	[31:0]									CM_dst_ip;
    logic 	[23:0]									CM_QPN;
	logic 	[31:0]									CM_Q_KEY;
	logic 	[23:0]									CM_QPn_start_PSN;
	logic	[31:0]									CM_local_Comm_ID;
  	logic	[63:0]									CM_loacl_CA_GUID;
  	logic	[63:0]									CM_MAD_Transaction_ID;

    /*assign cmac_m_axis_tready=m_axis_tready;
    assign m_axis_tdata=cmac_m_axis_tdata;
    assign m_axis_tkeep=cmac_m_axis_tkeep;
    assign m_axis_tvalid=cmac_m_axis_tvalid;
    assign m_axis_tlast=cmac_m_axis_tlast;*/
    

    XRNIC_top
    #(
    	.DDR_C_AXI_ADDR_WIDTH						(DDR_C_AXI_ADDR_WIDTH			),
    	.CHANNEL_NUM								(CHANNEL_NUM					),
    	.SIM										(SIM							)
    ) XRNIC_top
    (
		.clk_200									(clk							),
		.s_axi_lite_aclk							(s_axi_lite_aclk				),
		.aresetn_1									(~rst							),
		.cmac_rx_clk								(clk							),
		.cmac_tx_clk								(clk							),
		.cmac_rst									(rst							),
		
		
		.roce_cmac_s_axis_tready					(roce_cmac_s_axis_tready		),
    	.roce_cmac_s_axis_tdata						(roce_cmac_s_axis_tdata			),
    	.roce_cmac_s_axis_tkeep						(roce_cmac_s_axis_tkeep			),
    	.roce_cmac_s_axis_tvalid					(roce_cmac_s_axis_tvalid		),
    	.roce_cmac_s_axis_tlast						(roce_cmac_s_axis_tlast			),
    	
    	.cmac_m_axis_tready							(cmac_m_axis_tready				),
		.cmac_m_axis_tdata							(cmac_m_axis_tdata				),
		.cmac_m_axis_tkeep							(cmac_m_axis_tkeep				),
		.cmac_m_axis_tvalid							(cmac_m_axis_tvalid				),
		.cmac_m_axis_tlast							(cmac_m_axis_tlast				),
		
		.cur_Q_KEY									(cur_Q_KEY						),
		.sim_reg_read_en							(sim_reg_read_en				),
		.sim_reg_read_QPn							(sim_reg_read_QPn				),
		
		.CM_Req_tvalid								(CM_Req_tvalid 					),
		.CM_ReadyToUse_tvalid						(CM_ReadyToUse_tvalid 			),

//		.CM_reply_tx_en								(CM_reply_tx_en					),
//		.CM_reply_tx_done							(CM_reply_tx_done				),
		
		.recv_host_mac								(CM_dst_mac						),
		.recv_host_ip								(CM_dst_ip						),
		.recv_CM_QPN								(CM_QPN							),
		.recv_CM_Q_KEY								(CM_Q_KEY						),
		.recv_QPn_start_PSN							(CM_QPn_start_PSN				),
		.recv_CM_local_Comm_ID						(CM_local_Comm_ID				),
  		.recv_CM_loacl_CA_GUID						(CM_loacl_CA_GUID				),
  		.recv_MAD_Transaction_ID					(CM_MAD_Transaction_ID			),

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
		
		.cm_reply_ddr_write_en						(cm_reply_ddr_write_en			),
		.cm_reply_ddr_write_done					(cm_reply_ddr_write_done		),
		.ddr_TDI_write_done							(ddr_TDI_write_done				),
		.ddr_INFO_write_done						(ddr_INFO_write_done			),
		.track_tlast								(track_tlast					),
		.RDMA_write_ready							(RDMA_write_ready				),
		
		.track_last_TDI_DDR_addr					(track_last_TDI_DDR_addr		),
		.track_last_INFO_DDR_addr					(track_last_INFO_DDR_addr		),
    	.track_last_DDR_addr_vld					(track_last_DDR_addr_vld		),
    	
    	.IMC_NUM									(IMC_NUM						),
    	.track_num_per_IMC							(track_num_per_IMC				),
    	.sim_part_valid_line_cnt					(sim_part_valid_line_cnt		),
    	.track_num_per_wafer						(track_num_per_wafer			),

		.rx_MR_tvalid								(rx_MR_tvalid					),
		.rx_MR_QPn									(rx_MR_QPn						),
		.host_MR_addr0								(host_MR_addr0					),
    	.host_MR_addr1								(host_MR_addr1					),
		
		.info_enable								(info_enable					),
		.db_write_enable							(db_write_enable				),

/***************************** for sim ************************/
//		.CM_ReadyToUse_en							(CM_ReadyToUse_en				),
//		.CM_Req_tx_en								(CM_Req_tx_en					),
		.QP1_init_done								(QP1_init_done					),
		.QPn_init_done								(QPn_init_done					),
		.ERNIC_init_done							(ERNIC_init_done				),
/**************************************************************/
		.XRNIC_fsm									(XRNIC_fsm						),
		.XRNIC_reg_fsm								(XRNIC_reg_fsm					),
		.write_db_cnt								(write_db_cnt					),
		.db_cnt										(db_cnt							),
		.db_cq_all_cnt								(db_cq_all_cnt					),
		.db_write_all_cnt							(db_write_all_cnt				),
		.all_time_cnt								(all_time_cnt					),
		.retry_qp_count								(retry_qp_count					),
		.XRNIC_db_fsm								(XRNIC_db_fsm					),
		.XRNIC_qp_wr_fsm							(XRNIC_qp_wr_fsm				)
		
    );


    
    eth_pkt_proc_top#
    (
    	.C_AXIS_DATA_WIDTH							(512),
    	.CHANNEL_NUM								(CHANNEL_NUM)
    )eth_pkt_proc_top
    (
    	.clk										(clk							),
    	.gt_clk										(gt_clk							),
    	.rstn										(~rst							),
    	.s_axis_tready								(s_axis_tready					),
    	.s_axis_tdata								(s_axis_tdata					),
    	.s_axis_tkeep								(s_axis_tkeep					),
    	.s_axis_tvalid								(s_axis_tvalid					),
    	.s_axis_tlast								(s_axis_tlast					),
    
    	.m_axis_tready								(m_axis_tready					),
    	.m_axis_tdata								(m_axis_tdata					),
    	.m_axis_tkeep								(m_axis_tkeep					),
    	.m_axis_tvalid								(m_axis_tvalid					),
    	.m_axis_tlast								(m_axis_tlast					),
    	.stat_rx_pause_req							(stat_rx_pause_req				),
    	
    	.roce_cmac_s_axis_tready					(roce_cmac_s_axis_tready		),
    	.roce_cmac_s_axis_tdata						(roce_cmac_s_axis_tdata			),
    	.roce_cmac_s_axis_tkeep						(roce_cmac_s_axis_tkeep			),
    	.roce_cmac_s_axis_tvalid					(roce_cmac_s_axis_tvalid		),
    	.roce_cmac_s_axis_tlast						(roce_cmac_s_axis_tlast			),
    	
    	.cmac_m_axis_tready							(cmac_m_axis_tready				),
		.cmac_m_axis_tdata							(cmac_m_axis_tdata				),
		.cmac_m_axis_tkeep							(cmac_m_axis_tkeep				),
		.cmac_m_axis_tvalid							(cmac_m_axis_tvalid				),
		.cmac_m_axis_tlast							(cmac_m_axis_tlast				),

		.cur_Q_KEY									(cur_Q_KEY						),
		
		.CM_Req_tvalid								(CM_Req_tvalid 					),
		.CM_ReadyToUse_tvalid						(CM_ReadyToUse_tvalid 			),
		.eth_interval_cnt							(eth_interval_cnt				),

		.CM_reply_tx_en								(CM_reply_tx_en					),

		.recv_CM_src_mac							(CM_dst_mac						),
		.recv_CM_src_ip								(CM_dst_ip						),
		.recv_CM_QPN								(CM_QPN							),
		.recv_CM_Q_KEY								(CM_Q_KEY						),
		.recv_QPn_start_PSN							(CM_QPn_start_PSN				),
		.recv_CM_local_Comm_ID						(CM_local_Comm_ID				),
  		.recv_CM_loacl_CA_GUID						(CM_loacl_CA_GUID				),
  		.recv_MAD_Transaction_ID					(CM_MAD_Transaction_ID			)

    );
    assign recv_host_ip=CM_dst_ip;
    assign recv_host_mac=CM_dst_mac;
    assign recv_CM_local_Comm_ID=CM_local_Comm_ID;
    assign recv_CM_loacl_CA_GUID=CM_loacl_CA_GUID;
    assign recv_MAD_Transaction_ID=CM_MAD_Transaction_ID;
    
    
endmodule
