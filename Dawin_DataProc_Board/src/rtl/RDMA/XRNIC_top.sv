//`include "XRNIC_Reg_Config.vh"
`timescale 1ns/1ns
`include "proj_define.vh"
module XRNIC_top 
#(
parameter DDR_C_AXI_ADDR_WIDTH  = 32,
parameter C_AXI_ADDR_WIDTH   = 64,
parameter C_AXIS_DATA_WIDTH = 512,
parameter CHANNEL_NUM=0,
parameter SIM="FALSE"
)(
input 										clk_200,
input 										aresetn_1,
input										s_axi_lite_aclk,
input 										cmac_rx_clk,
input 										cmac_tx_clk,
input 										cmac_rst,

output                              		roce_cmac_s_axis_tready,
input   [C_AXIS_DATA_WIDTH-1 : 0]    		roce_cmac_s_axis_tdata,
input  	[C_AXIS_DATA_WIDTH/8-1:0]    		roce_cmac_s_axis_tkeep,
input                                		roce_cmac_s_axis_tvalid,
input                                		roce_cmac_s_axis_tlast,

input                               		cmac_m_axis_tready,
output  [C_AXIS_DATA_WIDTH-1 : 0]    		cmac_m_axis_tdata,
output 	[C_AXIS_DATA_WIDTH/8-1:0]    		cmac_m_axis_tkeep,
output                               		cmac_m_axis_tvalid,
output                               		cmac_m_axis_tlast,

/***************************** from ETH proc ************************/
output	[31:0]								cur_Q_KEY,

input										CM_Req_tvalid,
input										CM_ReadyToUse_tvalid,

input	[47:0]								recv_host_mac,
input	[31:0]								recv_host_ip,
input 	[23:0]								recv_CM_QPN,
input 	[31:0]								recv_CM_Q_KEY,
input 	[23:0]								recv_QPn_start_PSN,
input  	[31:0] 								recv_CM_local_Comm_ID,
input  	[63:0]								recv_CM_loacl_CA_GUID,
input	[63:0]								recv_MAD_Transaction_ID,
	
/***************************** to DDR proc ************************/
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

output										cm_reply_ddr_write_en,
input										cm_reply_ddr_write_done,
input										ddr_TDI_write_done,
input										ddr_INFO_write_done,
input										track_tlast,
output										RDMA_write_ready,

input  	[DDR_C_AXI_ADDR_WIDTH-1:0]      	track_last_TDI_DDR_addr,
input  	[DDR_C_AXI_ADDR_WIDTH-1:0]      	track_last_INFO_DDR_addr,
input       								track_last_DDR_addr_vld,

input	[31:0]								sim_part_valid_line_cnt,
input	[3:0]								IMC_NUM,
input	[3:0]								track_num_per_IMC,
input	[15:0]								track_num_per_wafer,

output										rx_MR_tvalid	,
output 	[3:0]								rx_MR_QPn		,
output	[63:0]								host_MR_addr0	,
output	[63:0]								host_MR_addr1	,


input										info_enable,

output										db_write_enable,

/***************************** 		for sim 	************************/
//output										CM_ReadyToUse_en,
//output										CM_Req_tx_en,
output										QPn_init_done,
output										QP1_init_done,
output										ERNIC_init_done,
input										sim_reg_read_en,
input 	[3:0]								sim_reg_read_QPn,

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

localparam C_AXI_LITE_DATA_WIDTH = 32;

localparam C_M_AXI_ID_WIDTH =1;

 logic   [32-1:0]           			s_axi_lite_awaddr;
 logic                                  s_axi_lite_awready;
 logic                                  s_axi_lite_awvalid;
 logic   [32-1:0]           			s_axi_lite_araddr;
 logic                                  s_axi_lite_arready;
 logic                                  s_axi_lite_arvalid;
 logic   [32-1:0]      					s_axi_lite_wdata;
 logic   [32/8 -1:0]   					s_axi_lite_wstrb;
 logic                                  s_axi_lite_wready;
 logic                                  s_axi_lite_wvalid;
 logic  [32-1:0]       					s_axi_lite_rdata;
 logic  [1:0]                           s_axi_lite_rresp;
 logic                                  s_axi_lite_rready;
 logic                                  s_axi_lite_rvalid;
 logic  [1:0]                           s_axi_lite_bresp;
 logic                                  s_axi_lite_bready;
 logic                                  s_axi_lite_bvalid;

 logic  [C_AXI_ADDR_WIDTH-1:0]    		qp_mgr_m_axi_araddr; 
 logic	[7:0]							qp_mgr_m_axi_arlen;
 logic	[2:0]							qp_mgr_m_axi_arsize;
 logic	[1:0]							qp_mgr_m_axi_arburst;
 logic	[3:0]							qp_mgr_m_axi_arcache;
 logic	[2:0]							qp_mgr_m_axi_arprot;
 logic                                  qp_mgr_m_axi_arvalid;
 logic                                  qp_mgr_m_axi_arready;
 logic									qp_mgr_m_axi_arlock;
 logic  [C_AXIS_DATA_WIDTH-1:0]        	qp_mgr_m_axi_rdata;
 logic  [1:0]                           qp_mgr_m_axi_rresp ;
 logic                                  qp_mgr_m_axi_rlast ;
 logic                                  qp_mgr_m_axi_rvalid ;
 logic                                  qp_mgr_m_axi_rready ;
 
 logic 	[1:0] 							rx_pkt_hndler_ddr_m_axi_rresp;
 logic [C_M_AXI_ID_WIDTH-1:0]         	rx_pkt_hndler_ddr_m_axi_awid;
 logic [C_AXI_ADDR_WIDTH-1:0]       	rx_pkt_hndler_ddr_m_axi_awaddr;
 logic [7:0]                          	rx_pkt_hndler_ddr_m_axi_awlen;
 logic [2:0]                          	rx_pkt_hndler_ddr_m_axi_awsize;
 logic [1:0]                          	rx_pkt_hndler_ddr_m_axi_awburst;
 logic [3:0]                          	rx_pkt_hndler_ddr_m_axi_awcache;
 logic [2:0]                          	rx_pkt_hndler_ddr_m_axi_awprot;
 logic                                	rx_pkt_hndler_ddr_m_axi_awvalid;
 logic                                	rx_pkt_hndler_ddr_m_axi_awready;
 logic [511:0]                        	rx_pkt_hndler_ddr_m_axi_wdata;
 logic [ 63:0]                        	rx_pkt_hndler_ddr_m_axi_wstrb;
 logic                                	rx_pkt_hndler_ddr_m_axi_wlast;
 logic                                	rx_pkt_hndler_ddr_m_axi_wvalid;
 logic                                	rx_pkt_hndler_ddr_m_axi_wready;
 logic                                	rx_pkt_hndler_ddr_m_axi_awlock;
 logic [C_M_AXI_ID_WIDTH-1 :0]        	rx_pkt_hndler_ddr_m_axi_bid;
 logic [1:0]                          	rx_pkt_hndler_ddr_m_axi_bresp;
 logic                                	rx_pkt_hndler_ddr_m_axi_bvalid;
 logic                                	rx_pkt_hndler_ddr_m_axi_bready;

 logic [C_M_AXI_ID_WIDTH-1:0]         	rx_pkt_hndler_rdrsp_m_axi_awid;
 logic [C_AXI_ADDR_WIDTH-1:0]       	rx_pkt_hndler_rdrsp_m_axi_awaddr;
 logic [7:0]                          	rx_pkt_hndler_rdrsp_m_axi_awlen;
 logic [2:0]                          	rx_pkt_hndler_rdrsp_m_axi_awsize;
 logic [1:0]                          	rx_pkt_hndler_rdrsp_m_axi_awburst;
 logic [3:0]                          	rx_pkt_hndler_rdrsp_m_axi_awcache;
 logic [2:0]                          	rx_pkt_hndler_rdrsp_m_axi_awprot;
 logic                                	rx_pkt_hndler_rdrsp_m_axi_awvalid;
 logic                                	rx_pkt_hndler_rdrsp_m_axi_awready;
 logic [511:0]                        	rx_pkt_hndler_rdrsp_m_axi_wdata;
 logic [63:0]                        	rx_pkt_hndler_rdrsp_m_axi_wstrb;
 logic                                	rx_pkt_hndler_rdrsp_m_axi_wlast;
 logic                                	rx_pkt_hndler_rdrsp_m_axi_wvalid;
 logic                                	rx_pkt_hndler_rdrsp_m_axi_wready;
 logic                                	rx_pkt_hndler_rdrsp_m_axi_awlock;
 logic [C_M_AXI_ID_WIDTH-1 :0]        	rx_pkt_hndler_rdrsp_m_axi_bid;
 logic [1:0]                          	rx_pkt_hndler_rdrsp_m_axi_bresp;
 logic                                	rx_pkt_hndler_rdrsp_m_axi_bvalid;
 logic                                	rx_pkt_hndler_rdrsp_m_axi_bready;

 logic [15:0]                         	o_qp_sq_pidb_hndshk;
 logic [31:0]                         	o_qp_sq_pidb_wr_addr_hndshk;
 logic                                	o_qp_sq_pidb_wr_valid_hndshk;
 logic                                	i_qp_sq_pidb_wr_rdy;

 logic  [15:0] 							qp_rq_cidb_hndshk;
 logic  [31:0] 							qp_rq_cidb_wr_addr_hndshk;
 logic     								qp_rq_cidb_wr_valid_hndshk;
 logic     								qp_rq_cidb_wr_rdy;

 logic									roce_cmac_s_axis_tuser;
assign roce_cmac_s_axis_tuser=roce_cmac_s_axis_tlast;

 logic aresetn_2;
 logic aresetn;

 logic [4:0]							local_QPN;
 logic [15:0]							local_QPn_Partition_Key;
assign local_QPn_Partition_Key=16'hffff;

 logic 									CM_reply_tx_en 			;
 logic 									CM_reply_tx_done 		;
// logic									QP1_init_en				;
 logic 									QPn_init_en				;

logic	[63:0]							host_MR_len0	;
logic	[63:0]							host_MR_len1	;
logic	[31:0]							host_MR_rkey0	;
logic	[31:0]							host_MR_rkey1	;

 logic									ddr_wr_done_sync;
 logic									track_tlast_sync;
 logic									cm_reply_ddr_write_en_sync;
 logic									cm_reply_ddr_write_done_sync;
 
 logic									rx_pkt_hndler_o_rq_db_data_valid;
 logic [31:0]							rx_pkt_hndler_o_rq_db_data;
 logic [9:0]							rx_pkt_hndler_o_rq_db_addr;
 logic									rx_pkt_hndler_i_rq_db_rdy;
 

 logic									resp_hndler_o_send_cq_db_cnt_valid;
 logic [9:0]							resp_hndler_o_send_cq_db_addr;
 
logic	[3:0]							cur_CM_reply_QPN;




logic									RDMA_track_done;
(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)logic									rnic_intr;
 
 logic	[C_AXI_ADDR_WIDTH-1:0]			wqe_proc_top_m_axi_araddr_ernic;
 assign wqe_proc_top_m_axi_araddr=wqe_proc_top_m_axi_araddr_ernic[DDR_C_AXI_ADDR_WIDTH-1:0];
 

//xpm_cdc_single #(  .DEST_SYNC_FF(4),  .INIT_SYNC_FF(1),  .SIM_ASSERT_CHK(0), .SRC_INPUT_REG(0))
//xpm_cdc_ddr_wr_done_inst (  		.dest_out(ddr_wr_done_sync),   				.dest_clk(clk_200),   	.src_clk(clk_300),    	.src_in(ddr_TDI_write_done));

//xpm_cdc_single#(  .DEST_SYNC_FF(4),  .INIT_SYNC_FF(1),  .SIM_ASSERT_CHK(0), .SRC_INPUT_REG(0))
//xpm_cdc_track_tlast_done_inst (  	.dest_out(track_tlast_sync),  				.dest_clk(clk_200),		.src_clk(clk_300), 		.src_in	(track_tlast));

//xpm_cdc_single #(  .DEST_SYNC_FF(4),  .INIT_SYNC_FF(1),  .SIM_ASSERT_CHK(0), .SRC_INPUT_REG(1))
//xpm_cm_reply_ddr_write_en_inst (  	.dest_out(cm_reply_ddr_write_en),   		.dest_clk(gt_clk),   	.src_clk(clk_200),    	.src_in(cm_reply_ddr_write_en_sync));
		
//xpm_cdc_single #(  .DEST_SYNC_FF(4),  .INIT_SYNC_FF(1),  .SIM_ASSERT_CHK(0), .SRC_INPUT_REG(1))
//xpm_cm_reply_ddr_write_done_inst (  .dest_out(cm_reply_ddr_write_done_sync),   .dest_clk(clk_200),   	.src_clk(gt_clk),    	.src_in(cm_reply_ddr_write_done));				

assign ddr_wr_done_sync=ddr_TDI_write_done;
assign track_tlast_sync=track_tlast;
assign cm_reply_ddr_write_en=cm_reply_ddr_write_en_sync;
assign cm_reply_ddr_write_done_sync=cm_reply_ddr_write_done;

// XRNIC Module Instantiation
// Needs to be parameterized based on the model parameters

assign roce_cmac_s_axis_tready=1;


always @(posedge clk_200) begin
       aresetn_2 <= aresetn_1;
       aresetn   <= aresetn_2;
end

//generate
//if(SIM=="FALSE") begin
  ernic_0 ernic_0 (
          .s_axi_lite_aclk       					(s_axi_lite_aclk),
          .s_axi_lite_aresetn    					(aresetn),
          .m_axi_aclk            					(clk_200),
          .m_axi_aresetn         					(aresetn),
          .cmac_rx_clk           					(cmac_rx_clk),                                             
          .cmac_rx_rst           					(cmac_rst),                                             
          .cmac_tx_clk           					(cmac_tx_clk), 
          .cmac_tx_rst           					(cmac_rst),                                             

         .s_axi_lite_awaddr      					(s_axi_lite_awaddr),
         .s_axi_lite_awready     					(s_axi_lite_awready),
         .s_axi_lite_awvalid     					(s_axi_lite_awvalid),
         .s_axi_lite_araddr      					(s_axi_lite_araddr),
         .s_axi_lite_arready     					(s_axi_lite_arready),
         .s_axi_lite_arvalid     					(s_axi_lite_arvalid),
         .s_axi_lite_wdata       					(s_axi_lite_wdata),
         .s_axi_lite_wstrb       					(s_axi_lite_wstrb),
         .s_axi_lite_wready      					(s_axi_lite_wready),
         .s_axi_lite_wvalid      					(s_axi_lite_wvalid),
         .s_axi_lite_rdata       					(s_axi_lite_rdata),
         .s_axi_lite_rresp       					(s_axi_lite_rresp),
         .s_axi_lite_rready      					(s_axi_lite_rready),
         .s_axi_lite_rvalid      					(s_axi_lite_rvalid),
         .s_axi_lite_bresp       					(s_axi_lite_bresp),
         .s_axi_lite_bready      					(s_axi_lite_bready),
         .s_axi_lite_bvalid      					(s_axi_lite_bvalid),

         .rx_pkt_hndler_ddr_m_axi_wready			( 1'b1),
         .rx_pkt_hndler_ddr_m_axi_awready			( 1'b1 ),
         .rx_pkt_hndler_ddr_m_axi_wvalid			(rx_pkt_hndler_ddr_m_axi_wvalid),
         .rx_pkt_hndler_ddr_m_axi_bvalid 			(1'b1),
         .rx_pkt_hndler_ddr_m_axi_wlast 			(rx_pkt_hndler_ddr_m_axi_wlast),
         .rx_pkt_hndler_ddr_m_axi_bresp 			( 2'b00 ),
         .rx_pkt_hndler_ddr_m_axi_bid 				( 1'b0 ),
         .rx_pkt_hndler_ddr_m_axi_rresp 			( 2'b00 ),
         .rx_pkt_hndler_ddr_m_axi_wstrb     		(rx_pkt_hndler_ddr_m_axi_wstrb  ),   
         .rx_pkt_hndler_ddr_m_axi_awid      		(rx_pkt_hndler_ddr_m_axi_awid   ),
         .rx_pkt_hndler_ddr_m_axi_awaddr    		(rx_pkt_hndler_ddr_m_axi_awaddr ), 
         .rx_pkt_hndler_ddr_m_axi_awlen     		(rx_pkt_hndler_ddr_m_axi_awlen  ),
         .rx_pkt_hndler_ddr_m_axi_awsize    		(rx_pkt_hndler_ddr_m_axi_awsize ),
         .rx_pkt_hndler_ddr_m_axi_awburst   		(rx_pkt_hndler_ddr_m_axi_awburst),
         .rx_pkt_hndler_ddr_m_axi_awcache   		(rx_pkt_hndler_ddr_m_axi_awcache),
         .rx_pkt_hndler_ddr_m_axi_awprot    		(rx_pkt_hndler_ddr_m_axi_awprot ), 
         .rx_pkt_hndler_ddr_m_axi_awvalid   		(rx_pkt_hndler_ddr_m_axi_awvalid),
         .rx_pkt_hndler_ddr_m_axi_wdata     		(rx_pkt_hndler_ddr_m_axi_wdata  ),
         .rx_pkt_hndler_ddr_m_axi_bready    		(rx_pkt_hndler_ddr_m_axi_bready ),
         .rx_pkt_hndler_ddr_m_axi_rid       		(1'b0),
         .rx_pkt_hndler_ddr_m_axi_rdata     		(512'd0),
         .rx_pkt_hndler_ddr_m_axi_rlast     		(1'b0),
         .rx_pkt_hndler_ddr_m_axi_rvalid    		(1'b0),
         .rx_pkt_hndler_ddr_m_axi_arready   		(1'b1),

         .rx_pkt_hndler_rdrsp_m_axi_awready 		(1'b1),
         .rx_pkt_hndler_rdrsp_m_axi_wready  		(1'b1),
         .rx_pkt_hndler_rdrsp_m_axi_bid     		(1'b0),
         .rx_pkt_hndler_rdrsp_m_axi_bresp   		(2'b00),
         .rx_pkt_hndler_rdrsp_m_axi_bvalid  		(1'b1),
         .rx_pkt_hndler_rdrsp_m_axi_rresp   		( 2'b00 ),
         .rx_pkt_hndler_rdrsp_m_axi_wstrb   		(rx_pkt_hndler_rdrsp_m_axi_wstrb  ),   
         .rx_pkt_hndler_rdrsp_m_axi_awid    		(rx_pkt_hndler_rdrsp_m_axi_awid   ),
         .rx_pkt_hndler_rdrsp_m_axi_awaddr  		(rx_pkt_hndler_rdrsp_m_axi_awaddr ), 
         .rx_pkt_hndler_rdrsp_m_axi_awlen   		(rx_pkt_hndler_rdrsp_m_axi_awlen  ),
         .rx_pkt_hndler_rdrsp_m_axi_awsize  		(rx_pkt_hndler_rdrsp_m_axi_awsize ),
         .rx_pkt_hndler_rdrsp_m_axi_awburst 		(rx_pkt_hndler_rdrsp_m_axi_awburst),
         .rx_pkt_hndler_rdrsp_m_axi_awcache 		(rx_pkt_hndler_rdrsp_m_axi_awcache),
         .rx_pkt_hndler_rdrsp_m_axi_awprot  		(rx_pkt_hndler_rdrsp_m_axi_awprot ), 
         .rx_pkt_hndler_rdrsp_m_axi_awvalid 		(rx_pkt_hndler_rdrsp_m_axi_awvalid),
         .rx_pkt_hndler_rdrsp_m_axi_wdata   		(rx_pkt_hndler_rdrsp_m_axi_wdata  ),
         .rx_pkt_hndler_rdrsp_m_axi_bready  		(rx_pkt_hndler_rdrsp_m_axi_bready ),
         .rx_pkt_hndler_rdrsp_m_axi_wvalid  		(rx_pkt_hndler_rdrsp_m_axi_wvalid),
         .rx_pkt_hndler_rdrsp_m_axi_wlast   		(rx_pkt_hndler_rdrsp_m_axi_wlast),
         .rx_pkt_hndler_rdrsp_m_axi_rid       		(1'b0),
         .rx_pkt_hndler_rdrsp_m_axi_rdata     		(512'd0),
         .rx_pkt_hndler_rdrsp_m_axi_rlast     		(1'b0),
         .rx_pkt_hndler_rdrsp_m_axi_rvalid    		(1'b0),
         .rx_pkt_hndler_rdrsp_m_axi_arready   		(1'b1),


 
//DATA response channel
        .qp_mgr_m_axi_araddr						(qp_mgr_m_axi_araddr			),
		.qp_mgr_m_axi_arlen							(qp_mgr_m_axi_arlen				),
		.qp_mgr_m_axi_arsize						(qp_mgr_m_axi_arsize			),
		.qp_mgr_m_axi_arburst						(qp_mgr_m_axi_arburst			),
		.qp_mgr_m_axi_arcache						(qp_mgr_m_axi_arcache			),
		.qp_mgr_m_axi_arprot						(qp_mgr_m_axi_arprot			),
		.qp_mgr_m_axi_arvalid						(qp_mgr_m_axi_arvalid			),
		.qp_mgr_m_axi_arready						(qp_mgr_m_axi_arready			),
		.qp_mgr_m_axi_arlock						(qp_mgr_m_axi_arlock 			),
		.qp_mgr_m_axi_rdata    						(qp_mgr_m_axi_rdata  ),
        .qp_mgr_m_axi_rresp    						(2'b00  ),
        .qp_mgr_m_axi_rlast    						(qp_mgr_m_axi_rlast  ),
        .qp_mgr_m_axi_rvalid   						(qp_mgr_m_axi_rvalid ),
        .qp_mgr_m_axi_rready   						(qp_mgr_m_axi_rready ),
        .qp_mgr_m_axi_awready  						(1'b1),
        .qp_mgr_m_axi_wready   						(1'b1),
        .qp_mgr_m_axi_bid      						(1'b0),
        .qp_mgr_m_axi_bresp    						(2'b00),
        .qp_mgr_m_axi_bvalid   						(1'b1),
        .qp_mgr_m_axi_rid      						(1'b0),

        //read request channel for NVME_write    
        .cmac_m_axis_tdata							(cmac_m_axis_tdata),
        .cmac_m_axis_tkeep							(cmac_m_axis_tkeep),
        .cmac_m_axis_tvalid							(cmac_m_axis_tvalid),
        .cmac_m_axis_tlast							(cmac_m_axis_tlast),
        .cmac_m_axis_tready 						(cmac_m_axis_tready),

        // wqe proc wr ddr i/f
        .wqe_proc_wr_ddr_m_axi_awready   			(1'b1),
        .wqe_proc_wr_ddr_m_axi_wready    			(1'b1),                    
        .wqe_proc_wr_ddr_m_axi_bid       			(1'b0),                       
        .wqe_proc_wr_ddr_m_axi_bresp     			(2'b00),                     
        .wqe_proc_wr_ddr_m_axi_bvalid    			(1'b1),                    
        .wqe_proc_wr_ddr_m_axi_arready   			(1'b1),                   
        .wqe_proc_wr_ddr_m_axi_rid       			(1'b0),                       
        .wqe_proc_wr_ddr_m_axi_rdata     			(512'd0),                     
        .wqe_proc_wr_ddr_m_axi_rresp     			(2'b00),                     
        .wqe_proc_wr_ddr_m_axi_rlast     			(1'b0),                     
        .wqe_proc_wr_ddr_m_axi_rvalid    			(1'b0),  


        //read response channel for NVME_READ
		.wqe_proc_top_m_axi_arid					(wqe_proc_top_m_axi_arid),                    
		.wqe_proc_top_m_axi_araddr					(wqe_proc_top_m_axi_araddr_ernic),                  
		.wqe_proc_top_m_axi_arlen					(wqe_proc_top_m_axi_arlen),                   
		.wqe_proc_top_m_axi_arsize					(wqe_proc_top_m_axi_arsize),                  
		.wqe_proc_top_m_axi_arburst					(wqe_proc_top_m_axi_arburst),                 
		.wqe_proc_top_m_axi_arcache					(wqe_proc_top_m_axi_arcache),                 
		.wqe_proc_top_m_axi_arprot					(wqe_proc_top_m_axi_arprot),                  
		.wqe_proc_top_m_axi_arvalid					(wqe_proc_top_m_axi_arvalid),                 
		.wqe_proc_top_m_axi_arready					(wqe_proc_top_m_axi_arready),                 
		.wqe_proc_top_m_axi_rid						(wqe_proc_top_m_axi_rid),                     
		.wqe_proc_top_m_axi_rdata					(wqe_proc_top_m_axi_rdata),                   
		.wqe_proc_top_m_axi_rresp					(wqe_proc_top_m_axi_rresp),                   
		.wqe_proc_top_m_axi_rlast					(wqe_proc_top_m_axi_rlast),                   
		.wqe_proc_top_m_axi_rvalid					(wqe_proc_top_m_axi_rvalid),                  
		.wqe_proc_top_m_axi_rready					(wqe_proc_top_m_axi_rready),                  
		.wqe_proc_top_m_axi_arlock					(wqe_proc_top_m_axi_arlock),                  
        
        .resp_hndler_m_axi_awready   				(1'b1),
        .resp_hndler_m_axi_wready    				(1'b1),
        .resp_hndler_m_axi_bid       				(1'b0),
        .resp_hndler_m_axi_bresp     				(2'b00),
        .resp_hndler_m_axi_bvalid    				(1'b1),
        .resp_hndler_m_axi_rid       				(1'b0),
        .resp_hndler_m_axi_rdata     				(512'd0),
        .resp_hndler_m_axi_rlast     				(1'b0),
        .resp_hndler_m_axi_rvalid    				(1'b0),
        .resp_hndler_m_axi_arready   				(1'b1),
        .resp_hndler_m_axi_rresp     				(2'b00),
       
        .i_qp_rq_cidb_hndshk         				(qp_rq_cidb_hndshk),
        .i_qp_rq_cidb_wr_addr_hndshk 				(qp_rq_cidb_wr_addr_hndshk),
        .i_qp_rq_cidb_wr_valid_hndshk				(qp_rq_cidb_wr_valid_hndshk),
        .o_qp_rq_cidb_wr_rdy         				(qp_rq_cidb_wr_rdy),

        .i_qp_sq_pidb_hndshk          				(o_qp_sq_pidb_hndshk),
        .i_qp_sq_pidb_wr_addr_hndshk  				(o_qp_sq_pidb_wr_addr_hndshk),
        .i_qp_sq_pidb_wr_valid_hndshk 				(o_qp_sq_pidb_wr_valid_hndshk),
        .o_qp_sq_pidb_wr_rdy          				(i_qp_sq_pidb_wr_rdy),

        .rx_pkt_hndler_o_rq_db_data       			(rx_pkt_hndler_o_rq_db_data),
        .rx_pkt_hndler_o_rq_db_addr       			(rx_pkt_hndler_o_rq_db_addr),
        .rx_pkt_hndler_o_rq_db_data_valid 			(rx_pkt_hndler_o_rq_db_data_valid),
        .rx_pkt_hndler_i_rq_db_rdy        			(rx_pkt_hndler_i_rq_db_rdy),

        .resp_hndler_o_send_cq_db_cnt_valid  		(resp_hndler_o_send_cq_db_cnt_valid),
        .resp_hndler_o_send_cq_db_addr       		(resp_hndler_o_send_cq_db_addr),
        .resp_hndler_o_send_cq_db_cnt        		(resp_hndler_o_send_cq_db_cnt),
        .resp_hndler_i_send_cq_db_rdy 				(1'b1),

         .roce_cmac_s_axis_tvalid 					(roce_cmac_s_axis_tvalid),                   
         .roce_cmac_s_axis_tdata  					(roce_cmac_s_axis_tdata),                    
         .roce_cmac_s_axis_tkeep  					(roce_cmac_s_axis_tkeep),                    
         .roce_cmac_s_axis_tlast  					(roce_cmac_s_axis_tlast),                    
         .roce_cmac_s_axis_tuser  					(roce_cmac_s_axis_tuser),
         
		 .non_roce_cmac_s_axis_tvalid 				(1'b0),                   
         .non_roce_cmac_s_axis_tdata  				(512'd0),                    
         .non_roce_cmac_s_axis_tkeep  				(64'd0),                    
         .non_roce_cmac_s_axis_tlast  				(1'b0),                    
         .non_roce_cmac_s_axis_tuser  				(1'b0),
         
         .non_roce_dma_s_axis_tvalid 				(1'b0),                   
         .non_roce_dma_s_axis_tdata  				(512'd0),                    
         .non_roce_dma_s_axis_tkeep  				(64'd0),                    
         .non_roce_dma_s_axis_tlast  				(1'b0), 
         .non_roce_dma_s_axis_tready 				(),
		 
         .non_roce_dma_m_axis_tvalid 				(),                   
         .non_roce_dma_m_axis_tdata  				(),                    
         .non_roce_dma_m_axis_tkeep  				(),                    
         .non_roce_dma_m_axis_tlast  				(),       
         .non_roce_dma_m_axis_tready  				(1'b0), 
		 
         .stat_rx_pause_req							(8'h0),                                    // input wire [8 : 0] stat_rx_pause_req
         //.ctl_rx_pause_ack(),                                      // output wire [8 : 0] ctl_rx_pause_ack
         .ctl_tx_pause_req							(),                                      // output wire [8 : 0] ctl_tx_pause_req
         .ctl_tx_resend_pause						(),                                // output wire ctl_tx_resend_pause
         //.stat_tx_pause(1'b0),                                            // input wire stat_tx_pause
         //.stat_tx_user_pause(1'b0),                                  // input wire stat_tx_user_pause
         //.stat_tx_pause_valid(8'h0),                                // input wire [8 : 0] stat_tx_pause_valid
         .ieth_immdt_axis_tvalid					(),                          // output wire ieth_immdt_axis_tvalid
         .ieth_immdt_axis_tlast						(),                            // output wire ieth_immdt_axis_tlast
         .ieth_immdt_axis_tdata						(),                            // output wire [63 : 0] ieth_immdt_axis_tdata
         .ieth_immdt_axis_trdy						(1'b1),                              // input wire ieth_immdt_axis_trdy
         .rnic_intr									(rnic_intr)

  );
//  end
//  else if(SIM=="TRUE") begin
//  ernic_sim ernic_sim (
//         .s_axi_lite_aclk       (s_axi_lite_aclk),
//          .s_axi_lite_aresetn    (aresetn),
//          .m_axi_aclk            (clk_200),
//          .m_axi_aresetn         (aresetn),
//          .cmac_rx_clk           (cmac_rx_clk),                                             
//          .cmac_rx_rst           (cmac_rst),                                             
//          .cmac_tx_clk           (cmac_tx_clk), 

//          .cmac_tx_rst           (cmac_rst),                                             

//         .s_axi_lite_awaddr      (s_axi_lite_awaddr),
//         .s_axi_lite_awready     (s_axi_lite_awready),
//         .s_axi_lite_awvalid     (s_axi_lite_awvalid),
//         .s_axi_lite_araddr      (s_axi_lite_araddr),
//         .s_axi_lite_arready     (s_axi_lite_arready),
//         .s_axi_lite_arvalid     (s_axi_lite_arvalid),
//         .s_axi_lite_wdata       (s_axi_lite_wdata),
//         .s_axi_lite_wstrb       (s_axi_lite_wstrb),
//         .s_axi_lite_wready      (s_axi_lite_wready),
//         .s_axi_lite_wvalid      (s_axi_lite_wvalid),
//         .s_axi_lite_rdata       (s_axi_lite_rdata),
//         .s_axi_lite_rresp       (s_axi_lite_rresp),
//         .s_axi_lite_rready      (s_axi_lite_rready),
//         .s_axi_lite_rvalid      (s_axi_lite_rvalid),
//         .s_axi_lite_bresp       (s_axi_lite_bresp),
//         .s_axi_lite_bready      (s_axi_lite_bready),
//         .s_axi_lite_bvalid      (s_axi_lite_bvalid),

//         .rx_pkt_hndler_ddr_m_axi_wready( 1'b1),
//         .rx_pkt_hndler_ddr_m_axi_awready( 1'b1 ),
//         .rx_pkt_hndler_ddr_m_axi_wvalid(rx_pkt_hndler_ddr_m_axi_wvalid),
//         .rx_pkt_hndler_ddr_m_axi_bvalid (1'b1),
//         .rx_pkt_hndler_ddr_m_axi_wlast (rx_pkt_hndler_ddr_m_axi_wlast),
//         .rx_pkt_hndler_ddr_m_axi_bresp ( 2'b00 ),
//         .rx_pkt_hndler_ddr_m_axi_bid ( 1'b0 ),
//         .rx_pkt_hndler_ddr_m_axi_rresp ( 2'b00 ),
//         .rx_pkt_hndler_ddr_m_axi_wstrb     (rx_pkt_hndler_ddr_m_axi_wstrb  ),   
//         .rx_pkt_hndler_ddr_m_axi_awid      (rx_pkt_hndler_ddr_m_axi_awid   ),
//         .rx_pkt_hndler_ddr_m_axi_awaddr    (rx_pkt_hndler_ddr_m_axi_awaddr ), 
//         .rx_pkt_hndler_ddr_m_axi_awlen     (rx_pkt_hndler_ddr_m_axi_awlen  ),
//         .rx_pkt_hndler_ddr_m_axi_awsize    (rx_pkt_hndler_ddr_m_axi_awsize ),
//         .rx_pkt_hndler_ddr_m_axi_awburst   (rx_pkt_hndler_ddr_m_axi_awburst),
//         .rx_pkt_hndler_ddr_m_axi_awcache   (rx_pkt_hndler_ddr_m_axi_awcache),
//         .rx_pkt_hndler_ddr_m_axi_awprot    (rx_pkt_hndler_ddr_m_axi_awprot ), 
//         .rx_pkt_hndler_ddr_m_axi_awvalid   (rx_pkt_hndler_ddr_m_axi_awvalid),
//         .rx_pkt_hndler_ddr_m_axi_wdata     (rx_pkt_hndler_ddr_m_axi_wdata  ),
//         .rx_pkt_hndler_ddr_m_axi_bready    (rx_pkt_hndler_ddr_m_axi_bready ),
//         .rx_pkt_hndler_ddr_m_axi_rid       (1'b0),
//         .rx_pkt_hndler_ddr_m_axi_rdata     (512'd0),
//         .rx_pkt_hndler_ddr_m_axi_rlast     (1'b0),
//         .rx_pkt_hndler_ddr_m_axi_rvalid    (1'b0),
//         .rx_pkt_hndler_ddr_m_axi_arready   (1'b1),

//         .rx_pkt_hndler_rdrsp_m_axi_awready (1'b1),
//         .rx_pkt_hndler_rdrsp_m_axi_wready  (1'b1),
//         .rx_pkt_hndler_rdrsp_m_axi_bid     (1'b0),
//         .rx_pkt_hndler_rdrsp_m_axi_bresp   (2'b00),
//         .rx_pkt_hndler_rdrsp_m_axi_bvalid  (1'b1),
//         .rx_pkt_hndler_rdrsp_m_axi_rresp   ( 2'b00 ),
//         .rx_pkt_hndler_rdrsp_m_axi_wstrb   (rx_pkt_hndler_rdrsp_m_axi_wstrb  ),   
//         .rx_pkt_hndler_rdrsp_m_axi_awid    (rx_pkt_hndler_rdrsp_m_axi_awid   ),
//         .rx_pkt_hndler_rdrsp_m_axi_awaddr  (rx_pkt_hndler_rdrsp_m_axi_awaddr ), 
//         .rx_pkt_hndler_rdrsp_m_axi_awlen   (rx_pkt_hndler_rdrsp_m_axi_awlen  ),
//         .rx_pkt_hndler_rdrsp_m_axi_awsize  (rx_pkt_hndler_rdrsp_m_axi_awsize ),
//         .rx_pkt_hndler_rdrsp_m_axi_awburst (rx_pkt_hndler_rdrsp_m_axi_awburst),
//         .rx_pkt_hndler_rdrsp_m_axi_awcache (rx_pkt_hndler_rdrsp_m_axi_awcache),
//         .rx_pkt_hndler_rdrsp_m_axi_awprot  (rx_pkt_hndler_rdrsp_m_axi_awprot ), 
//         .rx_pkt_hndler_rdrsp_m_axi_awvalid (rx_pkt_hndler_rdrsp_m_axi_awvalid),
//         .rx_pkt_hndler_rdrsp_m_axi_wdata   (rx_pkt_hndler_rdrsp_m_axi_wdata  ),
//         .rx_pkt_hndler_rdrsp_m_axi_bready  (rx_pkt_hndler_rdrsp_m_axi_bready ),
//         .rx_pkt_hndler_rdrsp_m_axi_wvalid  (rx_pkt_hndler_rdrsp_m_axi_wvalid),
//         .rx_pkt_hndler_rdrsp_m_axi_wlast   (rx_pkt_hndler_rdrsp_m_axi_wlast),
//         .rx_pkt_hndler_rdrsp_m_axi_rid       (1'b0),
//         .rx_pkt_hndler_rdrsp_m_axi_rdata     (512'd0),
//         .rx_pkt_hndler_rdrsp_m_axi_rlast     (1'b0),
//         .rx_pkt_hndler_rdrsp_m_axi_rvalid    (1'b0),
//         .rx_pkt_hndler_rdrsp_m_axi_arready   (1'b1),


 
////DATA response channel
//        .qp_mgr_m_axi_araddr				(qp_mgr_m_axi_araddr			),
//		.qp_mgr_m_axi_arlen					(qp_mgr_m_axi_arlen				),
//		.qp_mgr_m_axi_arsize				(qp_mgr_m_axi_arsize			),
//		.qp_mgr_m_axi_arburst				(qp_mgr_m_axi_arburst			),
//		.qp_mgr_m_axi_arcache				(qp_mgr_m_axi_arcache			),
//		.qp_mgr_m_axi_arprot				(qp_mgr_m_axi_arprot			),
//		.qp_mgr_m_axi_arvalid				(qp_mgr_m_axi_arvalid			),
//		.qp_mgr_m_axi_arready				(qp_mgr_m_axi_arready			),
//		.qp_mgr_m_axi_arlock				(qp_mgr_m_axi_arlock 			),
		
//		.qp_mgr_m_axi_rdata    (qp_mgr_m_axi_rdata  ),
//        .qp_mgr_m_axi_rresp    (2'b00  ),
//        .qp_mgr_m_axi_rlast    (qp_mgr_m_axi_rlast  ),
//        .qp_mgr_m_axi_rvalid   (qp_mgr_m_axi_rvalid ),
//        .qp_mgr_m_axi_rready   (qp_mgr_m_axi_rready ),
        
//        .qp_mgr_m_axi_awready  (1'b1),
//        .qp_mgr_m_axi_wready   (1'b1),
//        .qp_mgr_m_axi_bid      (1'b0),
//        .qp_mgr_m_axi_bresp    (2'b00),
//        .qp_mgr_m_axi_bvalid   (1'b1),
//        .qp_mgr_m_axi_rid      (1'b0),



//        //read request channel for NVME_write    
//        .cmac_m_axis_tdata(cmac_m_axis_tdata),
//        .cmac_m_axis_tkeep(cmac_m_axis_tkeep),
//        .cmac_m_axis_tvalid(cmac_m_axis_tvalid),
//        .cmac_m_axis_tlast(cmac_m_axis_tlast),
//        .cmac_m_axis_tready (cmac_m_axis_tready),

//        // wqe proc wr ddr i/f
//        .wqe_proc_wr_ddr_m_axi_awready   (1'b1),
//        .wqe_proc_wr_ddr_m_axi_wready    (1'b1),                    
//        .wqe_proc_wr_ddr_m_axi_bid       (1'b0),                       
//        .wqe_proc_wr_ddr_m_axi_bresp     (2'b00),                     
//        .wqe_proc_wr_ddr_m_axi_bvalid    (1'b1),                    
//        .wqe_proc_wr_ddr_m_axi_arready   (1'b1),                   
//        .wqe_proc_wr_ddr_m_axi_rid       (1'b0),                       
//        .wqe_proc_wr_ddr_m_axi_rdata     (512'd0),                     
//        .wqe_proc_wr_ddr_m_axi_rresp     (2'b00),                     
//        .wqe_proc_wr_ddr_m_axi_rlast     (1'b0),                     
//        .wqe_proc_wr_ddr_m_axi_rvalid    (1'b0),  


//        //read response channel for NVME_READ
//		.wqe_proc_top_m_axi_arid		(wqe_proc_top_m_axi_arid),                    
//		.wqe_proc_top_m_axi_araddr		(wqe_proc_top_m_axi_araddr_ernic),                  
//		.wqe_proc_top_m_axi_arlen		(wqe_proc_top_m_axi_arlen),                   
//		.wqe_proc_top_m_axi_arsize		(wqe_proc_top_m_axi_arsize),                  
//		.wqe_proc_top_m_axi_arburst		(wqe_proc_top_m_axi_arburst),                 
//		.wqe_proc_top_m_axi_arcache		(wqe_proc_top_m_axi_arcache),                 
//		.wqe_proc_top_m_axi_arprot		(wqe_proc_top_m_axi_arprot),                  
//		.wqe_proc_top_m_axi_arvalid		(wqe_proc_top_m_axi_arvalid),                 
//		.wqe_proc_top_m_axi_arready		(wqe_proc_top_m_axi_arready),                 
//		.wqe_proc_top_m_axi_rid			(wqe_proc_top_m_axi_rid),                     
//		.wqe_proc_top_m_axi_rdata		(wqe_proc_top_m_axi_rdata),                   
//		.wqe_proc_top_m_axi_rresp		(wqe_proc_top_m_axi_rresp),                   
//		.wqe_proc_top_m_axi_rlast		(wqe_proc_top_m_axi_rlast),                   
//		.wqe_proc_top_m_axi_rvalid		(wqe_proc_top_m_axi_rvalid),                  
//		.wqe_proc_top_m_axi_rready		(wqe_proc_top_m_axi_rready),                  
//		.wqe_proc_top_m_axi_arlock		(wqe_proc_top_m_axi_arlock),                  
        
//        .resp_hndler_m_axi_awready   (1'b1),
//        .resp_hndler_m_axi_wready    (1'b1),
//        .resp_hndler_m_axi_bid       (1'b0),
//        .resp_hndler_m_axi_bresp     (2'b00),
//        .resp_hndler_m_axi_bvalid    (1'b1),
//        .resp_hndler_m_axi_rid       (1'b0),
//        .resp_hndler_m_axi_rdata     (512'd0),
//        .resp_hndler_m_axi_rlast     (1'b0),
//        .resp_hndler_m_axi_rvalid    (1'b0),
//        .resp_hndler_m_axi_arready   (1'b1),
//        .resp_hndler_m_axi_rresp     (2'b00),
       
//        .i_qp_rq_cidb_hndshk         (qp_rq_cidb_hndshk),
//        .i_qp_rq_cidb_wr_addr_hndshk (qp_rq_cidb_wr_addr_hndshk),
//        .i_qp_rq_cidb_wr_valid_hndshk(qp_rq_cidb_wr_valid_hndshk),
//        .o_qp_rq_cidb_wr_rdy         (qp_rq_cidb_wr_rdy),

//        .i_qp_sq_pidb_hndshk          (o_qp_sq_pidb_hndshk),
//        .i_qp_sq_pidb_wr_addr_hndshk  (o_qp_sq_pidb_wr_addr_hndshk),
//        .i_qp_sq_pidb_wr_valid_hndshk (o_qp_sq_pidb_wr_valid_hndshk),
//        .o_qp_sq_pidb_wr_rdy          (i_qp_sq_pidb_wr_rdy),

//        .rx_pkt_hndler_o_rq_db_data       (rx_pkt_hndler_o_rq_db_data),
//        .rx_pkt_hndler_o_rq_db_addr       (rx_pkt_hndler_o_rq_db_addr),
//        .rx_pkt_hndler_o_rq_db_data_valid (rx_pkt_hndler_o_rq_db_data_valid),
//        .rx_pkt_hndler_i_rq_db_rdy        (rx_pkt_hndler_i_rq_db_rdy),

//        .resp_hndler_o_send_cq_db_cnt_valid  (resp_hndler_o_send_cq_db_cnt_valid),
//        .resp_hndler_o_send_cq_db_addr       (resp_hndler_o_send_cq_db_addr),
//        .resp_hndler_o_send_cq_db_cnt        (resp_hndler_o_send_cq_db_cnt),
//        .resp_hndler_i_send_cq_db_rdy 		(1'b1),
         
//// Streaming I/F
//         /*.roce_cmac_s_axis_tvalid (tx_m_axis_tvalid_filter),                   
//         .roce_cmac_s_axis_tdata  (tx_m_axis_tdata_filter),                    
//         .roce_cmac_s_axis_tkeep  (tx_m_axis_tkeep_filter),                    
//         .roce_cmac_s_axis_tlast  (tx_m_axis_tlast_filter),                    
//         .roce_cmac_s_axis_tuser  (tx_m_axis_tlast_filter),*/
         
//         .roce_cmac_s_axis_tvalid (roce_cmac_s_axis_tvalid),                   
//         .roce_cmac_s_axis_tdata  (roce_cmac_s_axis_tdata),                    
//         .roce_cmac_s_axis_tkeep  (roce_cmac_s_axis_tkeep),                    
//         .roce_cmac_s_axis_tlast  (roce_cmac_s_axis_tlast),                    
//         .roce_cmac_s_axis_tuser  (roce_cmac_s_axis_tuser),
         
//		 .non_roce_cmac_s_axis_tvalid (1'b0),                   
//         .non_roce_cmac_s_axis_tdata  (512'd0),                    
//         .non_roce_cmac_s_axis_tkeep  (64'd0),                    
//         .non_roce_cmac_s_axis_tlast  (1'b0),                    
//         .non_roce_cmac_s_axis_tuser  (1'b0),
         
//         .non_roce_dma_s_axis_tvalid (1'b0),                   
//         .non_roce_dma_s_axis_tdata  (512'd0),                    
//         .non_roce_dma_s_axis_tkeep  (64'd0),                    
//         .non_roce_dma_s_axis_tlast  (1'b0), 
//         .non_roce_dma_s_axis_tready (),
		 
//         .non_roce_dma_m_axis_tvalid (),                   
//         .non_roce_dma_m_axis_tdata  (),                    
//         .non_roce_dma_m_axis_tkeep  (),                    
//         .non_roce_dma_m_axis_tlast  (),       
//         .non_roce_dma_m_axis_tready  (1'b0), 
		 
//         .stat_rx_pause_req(8'h0),                                    // input wire [8 : 0] stat_rx_pause_req
//         //.ctl_rx_pause_ack(),                                      // output wire [8 : 0] ctl_rx_pause_ack
//         .ctl_tx_pause_req(),                                      // output wire [8 : 0] ctl_tx_pause_req
//         .ctl_tx_resend_pause(),                                // output wire ctl_tx_resend_pause
//         //.stat_tx_pause(1'b0),                                            // input wire stat_tx_pause
//         //.stat_tx_user_pause(1'b0),                                  // input wire stat_tx_user_pause
//         //.stat_tx_pause_valid(8'h0),                                // input wire [8 : 0] stat_tx_pause_valid
//         .ieth_immdt_axis_tvalid(),                          // output wire ieth_immdt_axis_tvalid
//         .ieth_immdt_axis_tlast(),                            // output wire ieth_immdt_axis_tlast
//         .ieth_immdt_axis_tdata(),                            // output wire [63 : 0] ieth_immdt_axis_tdata
//         .ieth_immdt_axis_trdy(1'b1)                              // input wire ieth_immdt_axis_trdy

//  );
//  end
//  endgenerate

`ifdef DEBUG_ILA
ila_ernic ila_ernic (
	.clk		(clk_200), // input wire clk
	.probe0		(roce_cmac_s_axis_tvalid), // input wire [0:0]  probe0  
	.probe1		(roce_cmac_s_axis_tdata), // input wire [511:0]  probe1 
	.probe2		(roce_cmac_s_axis_tkeep), // input wire [63:0]  probe2 
	.probe3		(roce_cmac_s_axis_tlast), // input wire [0:0]  probe3 
	.probe4		(cmac_m_axis_tvalid), // input wire [0:0]  probe4 
	.probe5		(cmac_m_axis_tready), // input wire [0:0]  probe5 
	.probe6		(cmac_m_axis_tdata), // input wire [511:0]  probe6 
	.probe7		(cmac_m_axis_tkeep), // input wire [63:0]  probe7 
	.probe8		(cmac_m_axis_tlast) // input wire [0:0]  probe8
);
`endif

RDMA_fsm RDMA_fsm
(
	.core_clk           		(clk_200								),
	.core_aresetn           	(aresetn							),
	
	.CM_Req_tvalid 				(CM_Req_tvalid 						),
	.CM_ReadyToUse_tvalid 		(CM_ReadyToUse_tvalid 				),
//	.CM_Req_tx_en 				(CM_Req_tx_en 						),
//	.CM_ReadyToUse_en			(CM_ReadyToUse_en					),
	.CM_reply_tx_en 			(CM_reply_tx_en 					),
	.CM_reply_tx_done 			(CM_reply_tx_done					),
	
//	.QP1_init_en				(QP1_init_en 						),
	.QP1_init_done 				(QP1_init_done						),
	.QPn_init_en				(QPn_init_en						),
	.QPn_init_done				(QPn_init_done						),
	.RDMA_write_ready			(RDMA_write_ready					),
	.RDMA_write_en				(RDMA_write_en						),
	.ERNIC_init_done 			(ERNIC_init_done					),
	
//	.cur_host_MR_addr0			(cur_host_MR_addr0					),
//	.cur_host_MR_addr1			(cur_host_MR_addr1					),
//	.cur_host_MR_rkey0			(cur_host_MR_rkey0					),
//	.cur_host_MR_rkey1			(cur_host_MR_rkey1					),
	
	.IMC_NUM					(IMC_NUM							),
	.track_num_per_IMC			(track_num_per_IMC					),
	
	.cur_Q_KEY					(cur_Q_KEY							),
	.recv_host_ip				(recv_host_ip						),
	
	.ddr_TDI_write_done			(ddr_wr_done_sync					),
	.track_tlast				(track_tlast_sync 					),
	.RDMA_track_done			(RDMA_track_done					),
	
	.cur_CM_reply_QPN			(cur_CM_reply_QPN					),
	
	.rx_MR_tvalid				(rx_MR_tvalid						),
	.rx_MR_QPn					(rx_MR_QPn							),
//	.host_MR_addr0				(host_MR_addr0						),
//    .host_MR_addr1				(host_MR_addr1						),
//    .host_MR_len0				(host_MR_len0						),
//    .host_MR_len1				(host_MR_len1						),
//    .host_MR_rkey0				(host_MR_rkey0						),
//    .host_MR_rkey1				(host_MR_rkey1						),

	
	.cmac_m_axis_tready			(cmac_m_axis_tready					),
	.cmac_m_axis_tlast			(cmac_m_axis_tlast					),
	.cmac_m_axis_tvalid			(cmac_m_axis_tvalid					),
	
	.XRNIC_fsm					(XRNIC_fsm							)

);
  
  XRNIC_reg_config_fsm
  #(
	 .C_S_AXI_LITE_ADDR_WIDTH 	(32),
	 .CHANNEL_NUM				(CHANNEL_NUM),
	 .SIM						(SIM)
	) XRNIC_reg_config_fsm
	(
		.s_axi_lite_aclk        	(s_axi_lite_aclk				),
        .s_axi_lite_arstn       	(aresetn						),
        .core_clk					(clk_200							),
        
        .s_axi_lite_awaddr      	(s_axi_lite_awaddr				),
        .s_axi_lite_awready     	(s_axi_lite_awready				),
        .s_axi_lite_awvalid     	(s_axi_lite_awvalid				),
        .s_axi_lite_araddr      	(s_axi_lite_araddr				),
        .s_axi_lite_arready     	(s_axi_lite_arready				),
        .s_axi_lite_arvalid     	(s_axi_lite_arvalid				),
        .s_axi_lite_wdata       	(s_axi_lite_wdata				),
        .s_axi_lite_wstrb       	(s_axi_lite_wstrb				),
        .s_axi_lite_wready      	(s_axi_lite_wready				),
        .s_axi_lite_wvalid      	(s_axi_lite_wvalid				),
        .s_axi_lite_rdata       	(s_axi_lite_rdata				),
        .s_axi_lite_rresp       	(s_axi_lite_rresp				),
        .s_axi_lite_rready      	(s_axi_lite_rready				),
        .s_axi_lite_rvalid      	(s_axi_lite_rvalid				),
        .s_axi_lite_bresp       	(s_axi_lite_bresp				),
        .s_axi_lite_bready      	(s_axi_lite_bready				),
        .s_axi_lite_bvalid      	(s_axi_lite_bvalid				),
        
//        .QP1_init_en				(QP1_init_en 					),
		.QP1_init_done 				(QP1_init_done					),
        .ERNIC_init_done       		(ERNIC_init_done				),
        .sim_reg_read_en 			(sim_reg_read_en				),
        .sim_reg_read_QPn			(sim_reg_read_QPn				),
        
        .rdma_write_mode			(rdma_write_mode 				),
        
        .QPn_init_en				(QPn_init_en					),
        .QPn_init_done				(QPn_init_done					),
        
        .local_QPN					(cur_CM_reply_QPN				),
        .local_QPn_Partition_Key 	(local_QPn_Partition_Key		),
        
        .recv_CM_QPN				(recv_CM_QPN					),
        .recv_CM_Q_KEY				(recv_CM_Q_KEY					),
        .recv_QPn_start_PSN			(recv_QPn_start_PSN				),
        .recv_CM_Dst_MAC			(recv_host_mac					),//recv_CM_Dst_MAC
        .recv_QPn_IPv4				(recv_host_ip					),
        
        .XRNIC_reg_fsm				(XRNIC_reg_fsm					)
        
  	);
  
  
XRNIC_rx_path_proc
  #(
	 .C_AXI_ADDR_WIDTH 							(C_AXI_ADDR_WIDTH)
	)
  XRNIC_rx_path_proc (
    .core_clk                     				(clk_200),
    .core_rst                     				(~aresetn),
    .capsule_ddr_m_axi_awid       				(rx_pkt_hndler_ddr_m_axi_awid),
    .capsule_ddr_m_axi_awaddr     				(rx_pkt_hndler_ddr_m_axi_awaddr),
    .capsule_ddr_m_axi_awlen      				(rx_pkt_hndler_ddr_m_axi_awlen),
    .capsule_ddr_m_axi_awsize     				(rx_pkt_hndler_ddr_m_axi_awsize),
    .capsule_ddr_m_axi_awburst    				(rx_pkt_hndler_ddr_m_axi_awburst),
    .capsule_ddr_m_axi_awcache    				(rx_pkt_hndler_ddr_m_axi_awcache),
    .capsule_ddr_m_axi_awprot     				(rx_pkt_hndler_ddr_m_axi_awprot),
    .capsule_ddr_m_axi_awvalid    				(rx_pkt_hndler_ddr_m_axi_awvalid),
    .capsule_ddr_m_axi_awready    				(rx_pkt_hndler_ddr_m_axi_awready),
    .capsule_ddr_m_axi_wdata      				(rx_pkt_hndler_ddr_m_axi_wdata),
    .capsule_ddr_m_axi_wstrb      				(rx_pkt_hndler_ddr_m_axi_wstrb),
    .capsule_ddr_m_axi_wlast      				(rx_pkt_hndler_ddr_m_axi_wlast),
    .capsule_ddr_m_axi_wvalid     				(rx_pkt_hndler_ddr_m_axi_wvalid),
    .capsule_ddr_m_axi_wready     				(rx_pkt_hndler_ddr_m_axi_wready),
    .capsule_ddr_m_axi_bid        				(rx_pkt_hndler_ddr_m_axi_bid),
    .capsule_ddr_m_axi_bresp      				(rx_pkt_hndler_ddr_m_axi_bresp),
    .capsule_ddr_m_axi_bvalid     				(rx_pkt_hndler_ddr_m_axi_bvalid),
    .capsule_ddr_m_axi_bready     				(rx_pkt_hndler_ddr_m_axi_bready),

//    .data_m_axi_awid              			(rx_pkt_hndler_rdrsp_m_axi_awid),
//    .data_m_axi_awaddr            			(rx_pkt_hndler_rdrsp_m_axi_awaddr),
//    .data_m_axi_awlen             			(rx_pkt_hndler_rdrsp_m_axi_awlen),
//    .data_m_axi_awsize            			(rx_pkt_hndler_rdrsp_m_axi_awsize),
//    .data_m_axi_awburst           			(rx_pkt_hndler_rdrsp_m_axi_awburst),
//    .data_m_axi_awcache           			(rx_pkt_hndler_rdrsp_m_axi_awcache),
//    .data_m_axi_awprot            			(rx_pkt_hndler_rdrsp_m_axi_awprot),
//    .data_m_axi_awvalid           			(rx_pkt_hndler_rdrsp_m_axi_awvalid),
//    .data_m_axi_awready           			(rx_pkt_hndler_rdrsp_m_axi_awready),
//    .data_m_axi_wdata             			(rx_pkt_hndler_rdrsp_m_axi_wdata),
//    .data_m_axi_wstrb             			(rx_pkt_hndler_rdrsp_m_axi_wstrb),
//    .data_m_axi_wlast             			(rx_pkt_hndler_rdrsp_m_axi_wlast),
//    .data_m_axi_wvalid            			(rx_pkt_hndler_rdrsp_m_axi_wvalid),
//    .data_m_axi_wready            			(rx_pkt_hndler_rdrsp_m_axi_wready),
//    .data_m_axi_bid               			(rx_pkt_hndler_rdrsp_m_axi_bid),
//    .data_m_axi_bresp             			(rx_pkt_hndler_rdrsp_m_axi_bresp),
//    .data_m_axi_bvalid            			(rx_pkt_hndler_rdrsp_m_axi_bvalid),
//    .data_m_axi_bready            			(rx_pkt_hndler_rdrsp_m_axi_bready),
    .rx_pkt_hndler_o_rq_db_data_valid 			(rx_pkt_hndler_o_rq_db_data_valid),
    .rx_pkt_hndler_o_rq_db_data       			(rx_pkt_hndler_o_rq_db_data),
    .rx_pkt_hndler_o_rq_db_addr       			(rx_pkt_hndler_o_rq_db_addr),
    .rx_pkt_hndler_i_rq_db_rdy        			(rx_pkt_hndler_i_rq_db_rdy),
    .resp_hndler_o_send_cq_db_cnt_valid 		(resp_hndler_o_send_cq_db_cnt_valid),
    .qp_rq_cidb_hndshk         					(qp_rq_cidb_hndshk),
    .qp_rq_cidb_wr_addr_hndshk 					(qp_rq_cidb_wr_addr_hndshk),
    .qp_rq_cidb_wr_valid_hndshk					(qp_rq_cidb_wr_valid_hndshk),
    .qp_rq_cidb_wr_rdy         					(qp_rq_cidb_wr_rdy),
    
    .rx_MR_tvalid								(rx_MR_tvalid),
    .rx_MR_QPn									(rx_MR_QPn),
    .host_MR_addr0								(host_MR_addr0),
    .host_MR_addr1								(host_MR_addr1),
    .host_MR_len0								(host_MR_len0),
    .host_MR_len1								(host_MR_len1),
    .host_MR_rkey0								(host_MR_rkey0),
    .host_MR_rkey1								(host_MR_rkey1)
);


  XRNIC_WQE_manager_new
  #(
  	.C_AXI_ADDR_WIDTH						(C_AXI_ADDR_WIDTH					),
  	.DDR_C_AXI_ADDR_WIDTH					(DDR_C_AXI_ADDR_WIDTH				),
	.SIM  									(SIM								)
  )  XRNIC_WQE_manager_new (
    .core_clk                     			(clk_200							),
    .core_aresetn                 			(aresetn							),

    .o_qp_sq_pidb_hndshk          			(o_qp_sq_pidb_hndshk				),
    .o_qp_sq_pidb_wr_addr_hndshk  			(o_qp_sq_pidb_wr_addr_hndshk		),
    .o_qp_sq_pidb_wr_valid_hndshk 			(o_qp_sq_pidb_wr_valid_hndshk		),
    .i_qp_sq_pidb_wr_rdy          			(i_qp_sq_pidb_wr_rdy				),
    
    .resp_hndler_o_send_cq_db_cnt_valid  	(resp_hndler_o_send_cq_db_cnt_valid	),
    .resp_hndler_o_send_cq_db_addr       	(resp_hndler_o_send_cq_db_addr		),
    
    .qp_mgr_m_axi_araddr					(qp_mgr_m_axi_araddr				),
 	.qp_mgr_m_axi_arlen						(qp_mgr_m_axi_arlen					),
 	.qp_mgr_m_axi_arsize					(qp_mgr_m_axi_arsize				),
 	.qp_mgr_m_axi_arburst					(qp_mgr_m_axi_arburst				),
	.qp_mgr_m_axi_arcache					(qp_mgr_m_axi_arcache				),
	.qp_mgr_m_axi_arprot					(qp_mgr_m_axi_arprot				),
	.qp_mgr_m_axi_arvalid					(qp_mgr_m_axi_arvalid				),
	.qp_mgr_m_axi_arready					(qp_mgr_m_axi_arready				),
	.qp_mgr_m_axi_arlock					(qp_mgr_m_axi_arlock 				),
        
    .qp_mgr_m_axi_rdata          			(qp_mgr_m_axi_rdata  				),
    .qp_mgr_m_axi_rlast          			(qp_mgr_m_axi_rlast  				),
    .qp_mgr_m_axi_rvalid         			(qp_mgr_m_axi_rvalid 				),
    .qp_mgr_m_axi_rready         			(qp_mgr_m_axi_rready 				),
    .qp_mgr_m_axi_rresp						(qp_mgr_m_axi_rresp					),

	.cm_reply_ddr_write_en					(cm_reply_ddr_write_en_sync 		),
	.cm_reply_ddr_write_done				(cm_reply_ddr_write_done_sync		),

	.CM_reply_tx_en							(CM_reply_tx_en						),
    .CM_reply_tx_done						(CM_reply_tx_done					),
    .ddr_TDI_write_done						(ddr_TDI_write_done					),
    .ddr_INFO_write_done					(ddr_INFO_write_done				),
    .RDMA_track_done						(RDMA_track_done					),
//    .RDMA_send_en					(RDMA_send_en					),
    

    .track_last_TDI_DDR_addr				(track_last_TDI_DDR_addr			),
    .track_last_INFO_DDR_addr				(track_last_INFO_DDR_addr			),
    .track_last_DDR_addr_vld				(track_last_DDR_addr_vld			),
    
    .IMC_NUM								(IMC_NUM 							),
    .track_num_per_IMC						(track_num_per_IMC					),
    .sim_part_valid_line_cnt				(sim_part_valid_line_cnt			),
    .track_num_per_wafer					(track_num_per_wafer				),

	.rx_MR_tvalid							(rx_MR_tvalid						),
	.rx_MR_QPn								(rx_MR_QPn							),
	.host_MR_addr0							(host_MR_addr0						),
    .host_MR_addr1							(host_MR_addr1						),
//    .host_MR_len0							(host_MR_len0						),
//    .host_MR_len1							(host_MR_len1						),
    .host_MR_rkey0							(host_MR_rkey0						),
    .host_MR_rkey1							(host_MR_rkey1						),
    
    .info_enable							(info_enable						),
    .db_write_enable						(db_write_enable					),
    
    .write_db_cnt							(write_db_cnt						),
    .db_cq_all_cnt							(db_cq_all_cnt						),
    .db_cnt									(db_cnt								),
    .db_write_all_cnt						(db_write_all_cnt					),
    .all_time_cnt							(all_time_cnt						),
    .retry_qp_count							(retry_qp_count						),
    .XRNIC_db_fsm							(XRNIC_db_fsm						),
    .XRNIC_qp_wr_fsm						(XRNIC_qp_wr_fsm					)
  );
  
 generate
if(SIM=="TRUE") begin
logic [511:0]	tx_m_axis_tdata;
logic [63:0]	tx_m_axis_tkeep;
logic			tx_m_axis_tvalid;
logic			tx_m_axis_tready=1;
logic			tx_m_axis_tlast;
logic [63:0]	wqe_proc_top_m_axi_rkeep;

 exdes_crc_wrap inst_crc  (
   .core_clk           (clk_200),
   .core_rst           (~aresetn),
   .m_axis_tdata       (tx_m_axis_tdata),
   .m_axis_tkeep       (tx_m_axis_tkeep),
   .m_axis_tvalid      (tx_m_axis_tvalid),
   .m_axis_tready      (tx_m_axis_tready),
   .m_axis_tlast       (tx_m_axis_tlast),
   .s_axis_tdata       (wqe_proc_top_m_axi_rdata),
   .s_axis_tkeep       (wqe_proc_top_m_axi_rkeep),
   .s_axis_tvalid      (wqe_proc_top_m_axi_rvalid),
   .s_axis_tlast       (wqe_proc_top_m_axi_rlast),
   .s_axis_tready      ()
);
assign wqe_proc_top_m_axi_rkeep=(wqe_proc_top_m_axi_rvalid && wqe_proc_top_m_axi_rlast) ? 64'h3fff_ffff_ffff_ffff : 64'hffff_ffff_ffff_ffff;
end
endgenerate

  /*rnic_exdes_tx_checker rnic_exdes_tx_checker (
  .core_clk                     (clk_200),
  .core_aresetn                 (aresetn),
  .wqe_proc_top_m_axis_tdata(wqe_proc_top_m_axis_tdata),
  .wqe_proc_top_m_axis_tkeep(wqe_proc_top_m_axis_tkeep),
  .wqe_proc_top_m_axis_tvalid(wqe_proc_top_m_axis_tvalid),
  .wqe_proc_top_m_axis_tlast(wqe_proc_top_m_axis_tlast),
  .rdma_write_payload_chk_pass_cnt (rdma_write_payload_chk_pass_cnt)
); */

//INITIATOR CHANGES
endmodule

