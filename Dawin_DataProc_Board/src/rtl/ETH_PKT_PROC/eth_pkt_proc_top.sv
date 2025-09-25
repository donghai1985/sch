`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/12 10:18:13
// Design Name: 
// Module Name: eth_pkt_proc_top
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


module eth_pkt_proc_top
#(
	parameter C_AXIS_DATA_WIDTH = 512,
	parameter CHANNEL_NUM=0
)(
	input                               			clk,
	input											gt_clk,
	input                               			rstn,
	
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
	input	[7:0]									stat_rx_pause_req,
	
	output                               			cmac_m_axis_tready,
	input  	[C_AXIS_DATA_WIDTH-1 : 0]    			cmac_m_axis_tdata,
	input 	[C_AXIS_DATA_WIDTH/8-1:0]    			cmac_m_axis_tkeep,
	input                               			cmac_m_axis_tvalid,
	input                               			cmac_m_axis_tlast,
	
	input                               			roce_cmac_s_axis_tready,
	output  [C_AXIS_DATA_WIDTH-1 : 0]    			roce_cmac_s_axis_tdata,
	output 	[C_AXIS_DATA_WIDTH/8-1:0]    			roce_cmac_s_axis_tkeep,
	output                               			roce_cmac_s_axis_tvalid,
	output                               			roce_cmac_s_axis_tlast,
	
	input	[31:0]									cur_Q_KEY,
	input	[31:0]									eth_interval_cnt,
	
	output											CM_Req_tvalid,
	output											CM_ReadyToUse_tvalid,
	
	input											CM_reply_tx_en,
	
	
	output  [47:0]									recv_CM_src_mac,
	output 	[31:0]									recv_CM_src_ip,
	output	[23:0]									recv_CM_QPN,
	output	[31:0]									recv_CM_Q_KEY,
	output 	[23:0]									recv_QPn_start_PSN,
	output  [31:0] 									recv_CM_local_Comm_ID,
	output  [63:0]									recv_CM_loacl_CA_GUID,
	output 	[63:0] 									recv_MAD_Transaction_ID
	
	
	
	
    );

	logic                               			arp_s_axis_tready;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			arp_s_axis_tdata;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			arp_s_axis_tkeep;
	logic                               			arp_s_axis_tvalid;
	logic                               			arp_s_axis_tlast;
	
	logic                               			arp_m_axis_tready;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			arp_m_axis_tdata;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			arp_m_axis_tkeep;
	logic                               			arp_m_axis_tvalid;
	logic                               			arp_m_axis_tlast;
	
	logic                               			tx_m_axis_tready;
	logic  [C_AXIS_DATA_WIDTH-1 : 0]    			tx_m_axis_tdata;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			tx_m_axis_tkeep;
	logic                               			tx_m_axis_tvalid;
	logic                               			tx_m_axis_tlast;
	
	/*assign arp_s_axis_tvalid=s_axis_tvalid;
	assign s_axis_tready=arp_s_axis_tready;
	assign arp_s_axis_tdata=s_axis_tdata;
	assign arp_s_axis_tkeep=s_axis_tkeep;
	assign arp_s_axis_tlast=s_axis_tlast;*/
	
	
	
	
	logic                               			RoCE_CM_s_axis_tready;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			RoCE_CM_s_axis_tdata;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			RoCE_CM_s_axis_tkeep;
	logic                               			RoCE_CM_s_axis_tvalid;
	logic                               			RoCE_CM_s_axis_tlast;

	logic	[47:0]									arp_src_mac;
	logic	[31:0]									arp_src_ip;
	logic											arp_rx_valid;
	
//	logic 	[63:0] 									recv_MAD_Transaction_ID;
	logic  	[15:0] 									recv_MAD_Attribute_ID;
//	logic  	[31:0] 									recv_CM_local_Comm_ID;
//	logic  	[63:0]									recv_CM_loacl_CA_GUID;	
	
	
	logic	[31:0]									recv_QPn_IPv4;
	
	logic	[15:0]									local_QPn_Partition_Key;
	assign local_QPn_Partition_Key=16'hffff;

	logic	[C_AXIS_DATA_WIDTH-1 : 0]			rx_s_axis_tdata		;
	logic										rx_s_axis_tdest		;
	logic										rx_s_axis_tid		;
	logic	[C_AXIS_DATA_WIDTH/8-1:0]			rx_s_axis_tkeep		;
	logic										rx_s_axis_tlast		;
	logic	[C_AXIS_DATA_WIDTH/8-1:0]			rx_s_axis_tstrb		;
	logic										rx_s_axis_tuser		;
	logic										rx_s_axis_tvalid	;
	
	/*input	[31:0]									arp_dst_ip,
	output	[47:0]									arp_dst_mac,
	output 											arp_table_overflow,*/
	
	logic	[31:0]									arp_dst_ip;
	logic	[47:0]									arp_dst_mac;
	logic 											arp_table_overflow;
	
	logic	[31:0]									interval_cnt=0;
	
	
	(* DONT_TOUCH = "true" *)logic										eth_tx_fifo_prog_full;
	(* DONT_TOUCH = "true" *)logic										eth_tx_fifo_full;

	enum {IDLE,ARP_TX,ROCE_TX,ETH_INTERVAL,TX_PAUSE} cur_st,nxt_st;

	assign arp_m_axis_tready		=	cur_st==ARP_TX 	? tx_m_axis_tready : 0;
	assign cmac_m_axis_tready 		=	cur_st==ROCE_TX ? tx_m_axis_tready : 0;
//	assign tx_m_axis_tdata=		arp_m_axis_tvalid 	?	arp_m_axis_tdata			:	(RoCE_CM_m_axis_tvalid 	?	RoCE_CM_m_axis_tdata	:	cmac_m_axis_tdata);
//	assign tx_m_axis_tkeep=		arp_m_axis_tvalid 	?	arp_m_axis_tkeep			:	(RoCE_CM_m_axis_tvalid	?	RoCE_CM_m_axis_tkeep	:	cmac_m_axis_tkeep);			
//	assign tx_m_axis_tvalid=	arp_m_axis_tvalid	|	RoCE_CM_m_axis_tvalid	|	cmac_m_axis_tvalid;
//	assign tx_m_axis_tlast=		arp_m_axis_tvalid 	?	arp_m_axis_tlast 			:	(RoCE_CM_m_axis_tvalid	?	RoCE_CM_m_axis_tlast	:	cmac_m_axis_tlast);

	assign tx_m_axis_tdata=		cur_st==ARP_TX 	?	arp_m_axis_tdata				:	(cur_st==ROCE_TX		?	cmac_m_axis_tdata		:	0);
	assign tx_m_axis_tkeep=		cur_st==ARP_TX 	?	arp_m_axis_tkeep				:	(cur_st==ROCE_TX		?	cmac_m_axis_tkeep		:	0);
	assign tx_m_axis_tvalid=	cur_st==ARP_TX 	?	arp_m_axis_tvalid				:	(cur_st==ROCE_TX		?	cmac_m_axis_tvalid		:	0);
	assign tx_m_axis_tlast=		cur_st==ARP_TX 	?	arp_m_axis_tlast				:	(cur_st==ROCE_TX		?	cmac_m_axis_tlast		:	0);
	
	always_ff@(posedge clk or negedge rstn)
		if(!rstn)		cur_st<=IDLE;
		else 			cur_st<=nxt_st;
	
	always_comb
	begin
		nxt_st=cur_st;
		case(cur_st)
			IDLE:			if(arp_m_axis_tvalid)														nxt_st=ARP_TX;
							else if(|stat_rx_pause_req)													nxt_st=TX_PAUSE;
							else if(cmac_m_axis_tvalid && (!eth_tx_fifo_prog_full))						nxt_st=ROCE_TX;
			ARP_TX:			if(arp_m_axis_tlast && arp_m_axis_tready)									nxt_st=IDLE;
			ROCE_TX:		if(cmac_m_axis_tlast && cmac_m_axis_tready)									nxt_st=ETH_INTERVAL;
			ETH_INTERVAL:	if(interval_cnt>=eth_interval_cnt)											nxt_st=IDLE;
			TX_PAUSE:		if(stat_rx_pause_req=='h0)													nxt_st=IDLE;
			default:																					nxt_st=IDLE;
		endcase
	end
	
	always_ff@(posedge clk)
		if(cur_st==IDLE)					interval_cnt<=0;
		else if(cur_st==ETH_INTERVAL)		interval_cnt<=interval_cnt+1;
	
	
	
	
 xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(2),            // DECIMAL
      .CLOCKING_MODE("independent_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .FIFO_DEPTH(128),              // DECIMAL
      .FIFO_MEMORY_TYPE("auto"),      // String
      .PACKET_FIFO("false"),          // String
      .PROG_EMPTY_THRESH(12),         // DECIMAL
      .PROG_FULL_THRESH(12),          // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),        // DECIMAL
      .RELATED_CLOCKS(0),             // DECIMAL
      .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH(512),               // DECIMAL
      .TDEST_WIDTH(1),                // DECIMAL
      .TID_WIDTH(1),                  // DECIMAL
      .TUSER_WIDTH(1),                // DECIMAL
      .USE_ADV_FEATURES("1000"),      // String
      .WR_DATA_COUNT_WIDTH(1)         // DECIMAL
   )
   xpm_fifo_rx_axis_inst (
      .almost_empty_axis		(),
      .almost_full_axis			(),     
      .dbiterr_axis				(),            
      .m_axis_tdata				(rx_s_axis_tdata),             
      .m_axis_tdest				(rx_s_axis_tdest),            
      .m_axis_tid				(),                 
      .m_axis_tkeep				(rx_s_axis_tkeep),            
      .m_axis_tlast				(rx_s_axis_tlast),            
      .m_axis_tstrb				(),            
      .m_axis_tuser				(),            
      .m_axis_tvalid			(rx_s_axis_tvalid),    
      .m_aclk					(clk),                         
      .m_axis_tready			(rx_s_axis_tready),                
      .prog_empty_axis			(),      
      .prog_full_axis			(),         
      .rd_data_count_axis		(), 
      .sbiterr_axis				(),             
      .wr_data_count_axis		(), 
      .injectdbiterr_axis		(0),
      .injectsbiterr_axis		(0), 
      .s_aclk					(gt_clk),                        
      .s_aresetn				(rstn),          
      .s_axis_tready			(s_axis_tready),          
      .s_axis_tdata				(s_axis_tdata),            
      .s_axis_tdest				(0),            
      .s_axis_tid				(0),                 
      .s_axis_tkeep				(s_axis_tkeep),            
      .s_axis_tlast				(s_axis_tlast),            
      .s_axis_tstrb				(s_axis_tkeep),            
      .s_axis_tuser				(s_axis_tuser),             
      .s_axis_tvalid			(s_axis_tvalid)            
   );
   
   xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(2),            // DECIMAL
      .CLOCKING_MODE("independent_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .FIFO_DEPTH(256),              // DECIMAL
      .FIFO_MEMORY_TYPE("auto"),      // String
      .PACKET_FIFO("true"),          // String
      .PROG_EMPTY_THRESH(1),         // DECIMAL
      .PROG_FULL_THRESH(128),          // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),        // DECIMAL
      .RELATED_CLOCKS(0),             // DECIMAL
      .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH(512),               // DECIMAL
      .TDEST_WIDTH(1),                // DECIMAL
      .TID_WIDTH(1),                  // DECIMAL
      .TUSER_WIDTH(1),                // DECIMAL
      .USE_ADV_FEATURES("100e"),      // String
      .WR_DATA_COUNT_WIDTH(1)         // DECIMAL
   )
   xpm_fifo_tx_axis_inst (
      .almost_empty_axis		(),
      .almost_full_axis			(eth_tx_fifo_full),     
      .dbiterr_axis				(),     
      .m_aclk					(gt_clk),                         
      .m_axis_tready			(m_axis_tready),       //
      .m_axis_tdata				(m_axis_tdata),             
      .m_axis_tdest				(m_axis_tdest),            
      .m_axis_tid				(),                 
      .m_axis_tkeep				(m_axis_tkeep),            
      .m_axis_tlast				(m_axis_tlast),            
      .m_axis_tstrb				(),            
      .m_axis_tuser				(),            
      .m_axis_tvalid			(m_axis_tvalid),           
      .prog_empty_axis			(),      
      .prog_full_axis			(eth_tx_fifo_prog_full),         
      .rd_data_count_axis		(), 
      .s_axis_tready			(tx_m_axis_tready),          
      .sbiterr_axis				(),             
      .wr_data_count_axis		(), 
      .injectdbiterr_axis		(0),
      .injectsbiterr_axis		(0), 
      .s_aclk					(clk),                        
      .s_aresetn				(rstn),                  
      .s_axis_tdata				(tx_m_axis_tdata),            
      .s_axis_tdest				(0),            
      .s_axis_tid				(0),                 
      .s_axis_tkeep				(tx_m_axis_tkeep),            
      .s_axis_tlast				(tx_m_axis_tlast),            
      .s_axis_tstrb				(tx_m_axis_tkeep),            
      .s_axis_tuser				(tx_m_axis_tuser),             
      .s_axis_tvalid			(tx_m_axis_tvalid)            
   );
   
    rx_pkt_decode
    #(
    	.C_AXIS_DATA_WIDTH							(C_AXIS_DATA_WIDTH),
    	.CHANNEL_NUM								(CHANNEL_NUM)
    )rx_pkt_decode
    (
    	.clk										(clk							),
    	.rstn										(rstn							),
    	.rx_s_axis_tready							(rx_s_axis_tready				),
    	.rx_s_axis_tdata							(rx_s_axis_tdata				),
    	.rx_s_axis_tkeep							(rx_s_axis_tkeep				),
    	.rx_s_axis_tvalid							(rx_s_axis_tvalid				),
    	.rx_s_axis_tlast							(rx_s_axis_tlast				),
    	.arp_s_axis_tready							(arp_s_axis_tready				),
    	.arp_s_axis_tdata							(arp_s_axis_tdata				),
    	.arp_s_axis_tkeep							(arp_s_axis_tkeep				),
    	.arp_s_axis_tvalid							(arp_s_axis_tvalid				),
    	.arp_s_axis_tlast							(arp_s_axis_tlast				),
    	.RoCE_CM_s_axis_tready						(RoCE_CM_s_axis_tready			),
    	.RoCE_CM_s_axis_tdata						(RoCE_CM_s_axis_tdata			),
    	.RoCE_CM_s_axis_tkeep						(RoCE_CM_s_axis_tkeep			),
    	.RoCE_CM_s_axis_tvalid						(RoCE_CM_s_axis_tvalid			),
    	.RoCE_CM_s_axis_tlast						(RoCE_CM_s_axis_tlast			),
    	.RoCE_cmac_s_axis_tready					(roce_cmac_s_axis_tready		),
    	.RoCE_cmac_s_axis_tdata						(roce_cmac_s_axis_tdata			),
    	.RoCE_cmac_s_axis_tkeep						(roce_cmac_s_axis_tkeep			),
    	.RoCE_cmac_s_axis_tvalid					(roce_cmac_s_axis_tvalid		),
    	.RoCE_cmac_s_axis_tlast						(roce_cmac_s_axis_tlast			)
    
    );
    
    arp_rx#(
    	.C_AXIS_DATA_WIDTH							(C_AXIS_DATA_WIDTH)
    ) arp_rx
    (
    	.clk 										(clk				),
    	.rstn										(rstn				),
    	.rx_s_axis_tready							(arp_s_axis_tready	),
		.rx_s_axis_tdata							(arp_s_axis_tdata	),
		.rx_s_axis_tkeep							(arp_s_axis_tkeep	),
		.rx_s_axis_tvalid							(arp_s_axis_tvalid	),
		.rx_s_axis_tlast							(arp_s_axis_tlast	),
		
		.arp_src_mac 								(arp_src_mac		),
		.arp_src_ip									(arp_src_ip			),
		.arp_rx_valid								(arp_rx_valid		)
    
    
    );
    
    arp_tx#(
    	.CHANNEL_NUM								(CHANNEL_NUM),
    	.C_AXIS_DATA_WIDTH							(C_AXIS_DATA_WIDTH)
    ) arp_tx
    (
    	.clk 										(clk				),
    	.rstn										(rstn				),
    	
    	.tx_m_axis_tready							(arp_m_axis_tready	),
 		.tx_m_axis_tdata							(arp_m_axis_tdata	),
 		.tx_m_axis_tkeep							(arp_m_axis_tkeep	),
 		.tx_m_axis_tvalid							(arp_m_axis_tvalid	),
 		.tx_m_axis_tlast							(arp_m_axis_tlast	),

		.arp_req_tx									('h0				),
 		.arp_ack_tx									(arp_rx_valid		),
 		.arp_ack_tx_done							(),
 		.arp_src_mac								(arp_src_mac		),
 		.arp_src_ip									(arp_src_ip			)
    
    
    );
    
    /*ila_arp ila_arp (
	.clk		(clk), // input wire clk
	.probe0		(arp_src_ip), // input wire [31:0]  probe0  
	.probe1		(arp_src_mac), // input wire [47:0]  probe1 
	.probe2		(arp_m_axis_tready), // input wire [0:0]  probe2 
	.probe3		(arp_m_axis_tdata), // input wire [511:0]  probe3 
	.probe4		(arp_m_axis_tkeep), // input wire [63:0]  probe4 
	.probe5		(arp_m_axis_tvalid), // input wire [0:0]  probe5 
	.probe6		(arp_m_axis_tlast), // input wire [0:0]  probe6 
	.probe7		(arp_s_axis_tvalid), // input wire [0:0]  probe7 
	.probe8		(arp_s_axis_tdata), // input wire [511:0]  probe8 
	.probe9		(arp_s_axis_tkeep), // input wire [63:0]  probe9 
	.probe10	(arp_s_axis_tlast) // input wire [0:0]  probe10
);*/

`ifdef DEBUG_ILA
ila_CM ila_CM (
	.clk		(clk), // input wire clk
	.probe0		(tx_m_axis_tready), // input wire [0:0]  probe0  
	.probe1		(cmac_m_axis_tdata), // input wire [511:0]  probe1 
	.probe2		(cmac_m_axis_tkeep), // input wire [63:0]  probe2 
	.probe3		(cmac_m_axis_tvalid), // input wire [0:0]  probe3 
	.probe4		(cmac_m_axis_tlast), // input wire [0:0]  probe4 
	.probe5		(RoCE_CM_m_axis_tvalid), // input wire [0:0]  probe5 
	.probe6		(RoCE_CM_m_axis_tdata), // input wire [511:0]  probe6 
	.probe7		(RoCE_CM_m_axis_tkeep), // input wire [63:0]  probe7 
	.probe8		(RoCE_CM_m_axis_tlast), // input wire [0:0]  probe8 
	.probe9		(recv_MAD_Transaction_ID), // input wire [63:0]  probe9 
	.probe10	(recv_MAD_Attribute_ID), // input wire [15:0]  probe10 
	.probe11	(recv_CM_local_Comm_ID), // input wire [31:0]  probe11 
	.probe12	(recv_CM_loacl_CA_GUID), // input wire [63:0]  probe12 
	.probe13	(recv_CM_QPN), // input wire [23:0]  probe13 
	.probe14	(recv_CM_Q_KEY), // input wire [31:0]  probe14 
	.probe15	(recv_QPn_start_PSN), // input wire [23:0]  probe15 
	.probe16	(recv_QPn_IPv4), // input wire [31:0]  probe16 
	.probe17	(CM_Req_tvalid), // input wire [0:0]  probe17
	.probe18	(CM_ReadyToUse_tvalid),
	.probe19	(arp_m_axis_tvalid), // input wire [0:0]  probe5 
	.probe20	(arp_m_axis_tdata), // input wire [511:0]  probe6 
	.probe21	(arp_m_axis_tkeep), // input wire [63:0]  probe7 
	.probe22	(arp_m_s_axis_tlast), // input wire [0:0]  probe8 
	.probe23	(tx_m_axis_tvalid), // input wire [0:0]  probe5 
	.probe24	(tx_m_axis_tdata), // input wire [511:0]  probe6 
	.probe25	(tx_m_axis_tkeep), // input wire [63:0]  probe7 
	.probe26	(tx_m_axis_tlast), // input wire [0:0]  probe8 
	.probe27	(roce_cmac_s_axis_tready), // input wire [0:0]  probe5 
	.probe28	(roce_cmac_s_axis_tvalid),
	.probe29	(roce_cmac_s_axis_tdata), // input wire [511:0]  probe6 
	.probe30	(roce_cmac_s_axis_tkeep), // input wire [63:0]  probe7 
	.probe31	(roce_cmac_s_axis_tlast) // input wire [0:0]  probe8 
	
);
`endif
    
    arp_table arp_table
    (
    	.clk										(clk 				),
    	.arp_table_rst								(arp_table_rst		),
    	.arp_src_mac								(arp_src_mac		),
    	.arp_src_ip									(arp_src_ip			),
    	.arp_rx_valid								(arp_rx_valid		),
    	.arp_dst_ip									(arp_dst_ip			),
    	.arp_dst_mac								(arp_dst_mac		),
    	.arp_table_overflow							(arp_table_overflow	)
    
    );
    

  RoCE_CM_rx_proc
  #(
  	.C_AXIS_DATA_WIDTH			(C_AXIS_DATA_WIDTH				)
  )RoCE_CM_rx_proc(
  	.core_clk           		(clk								),
	.core_aresetn           	(rstn								),
  	.rx_s_axis_tready 			(RoCE_CM_s_axis_tready				),
  	.rx_s_axis_tdata 			(RoCE_CM_s_axis_tdata				),
  	.rx_s_axis_tkeep			(RoCE_CM_s_axis_tkeep				),
  	.rx_s_axis_tvalid			(RoCE_CM_s_axis_tvalid				),
  	.rx_s_axis_tlast			(RoCE_CM_s_axis_tlast				),
  	
  	.CM_Req_tvalid				(CM_Req_tvalid						),
  	.CM_ReadyToUse_tvalid		(CM_ReadyToUse_tvalid				),
  	
  	.recv_MAD_Transaction_ID 	(recv_MAD_Transaction_ID			),
  	.recv_MAD_Attribute_ID		(recv_MAD_Attribute_ID				),
  	.recv_CM_local_Comm_ID		(recv_CM_local_Comm_ID				),
  	.recv_CM_loacl_CA_GUID		(recv_CM_loacl_CA_GUID				),
  	.recv_CM_QPN				(recv_CM_QPN						),
  	.recv_CM_Q_KEY				(recv_CM_Q_KEY						),
  	.recv_QPn_start_PSN			(recv_QPn_start_PSN					),
  	.recv_QPn_IPv4				(recv_QPn_IPv4						),
  	.recv_CM_src_mac			(recv_CM_src_mac					),
  	.recv_CM_src_ip				(recv_CM_src_ip						)

  );
  
endmodule
