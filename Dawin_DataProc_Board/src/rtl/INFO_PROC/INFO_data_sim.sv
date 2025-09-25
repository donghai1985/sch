`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/07 15:55:15
// Design Name: 
// Module Name: INFO_data_sim
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
module INFO_data_sim#(
    parameter				TDI_sim_CLK			=	200_000_000,
    parameter				TRIG_period 		=	TDI_sim_CLK/1_000_000
)(
    input                   clk              	 		,
    input                   rst               			,
    
    input					TDI_trigger					,
    input					track_tlast					,
    
    output	[511:0]			INFO_axis_tdata				,
    output					INFO_axis_tvalid			,
    output 					INFO_axis_tlast				,
    input					INFO_axis_tready			,
    output					INFO_fifo_prog_full			,

	input	[31:0]			sim_track_valid_line_cnt	,
	input	[31:0]			sim_track_total_line_cnt	
);
	
	logic	[511:0]			INFO_axis_tdata_usr				;
	logic	[511:0]			INFO_axis_tdata_usr_reverse		;
    logic					INFO_axis_tvalid_usr			;
    logic 					INFO_axis_tlast_usr				;
    logic					INFO_axis_tready_usr			;
	
	(* DONT_TOUCH = "true" *)logic					INFO_fifo_full					;
	logic	[15:0]			cur_data=0						;
	
	logic	[31:0]			INFO_axis_cnt=0					;
	logic	[31:0]			INFO_pkt_cnt=0					;
	
//	logic	[31:0]			trig_cnt=0						;
	
	enum logic[3:0]	{IDLE,INFO_GEN} cur_st,nxt_st;
	
	`include "ETH_pkt_define.sv"
	genvar i;
    generate
    for(i=0;i<32;i=i+1)
    begin
        assign				INFO_axis_tdata_usr[i*16+:16]     = cur_data+i;
    end
    endgenerate
    assign INFO_axis_tdata_usr_reverse=TDI_data_reorder(INFO_axis_tdata_usr);

//	always @(posedge clk)
//		if(TDI_trigger && trig_cnt==(sim_track_valid_line_cnt-1))			trig_cnt<=0;
//		else if(TDI_trigger)												trig_cnt<=trig_cnt+1;
	
    always @(posedge clk)
        if(INFO_axis_tready_usr && INFO_axis_tlast_usr) 				cur_data<='d0;
        else if(INFO_axis_tvalid_usr && INFO_axis_tready_usr) 			cur_data<=cur_data+32;
	
	always @(posedge clk or posedge rst)
		if(rst)				cur_st<=IDLE;
		else				cur_st<=nxt_st;
	
	always_comb
	begin
		nxt_st=cur_st;
		case(cur_st)
			IDLE:		if(TDI_trigger)													nxt_st=INFO_GEN;
			INFO_GEN:	if(INFO_axis_cnt==(`INFO_LEN-1) && INFO_axis_tready_usr)		nxt_st=IDLE;
			default:																	nxt_st=IDLE;
		endcase
	end
	
	assign INFO_axis_tvalid_usr=cur_st==INFO_GEN;
	
	always @(posedge clk)	
		if(cur_st==IDLE)											INFO_axis_cnt<=0;
		else if(INFO_axis_tvalid_usr && INFO_axis_tready_usr)		INFO_axis_cnt<=INFO_axis_cnt+1;

	always @(posedge clk)	
		if(INFO_axis_tlast_usr && INFO_axis_tready_usr)				INFO_pkt_cnt<=0;
		else if(INFO_axis_tvalid_usr && INFO_axis_tready_usr)		INFO_pkt_cnt<=INFO_pkt_cnt+1;
		
	assign INFO_axis_tlast_usr=INFO_pkt_cnt==(`INFO_BURST_LEN-1);
	
	
	xpm_fifo_axis #(
      .CASCADE_HEIGHT		(0),             // DECIMAL
      .CDC_SYNC_STAGES		(2),            // DECIMAL
      .CLOCKING_MODE		("common_clock"), // String
      .ECC_MODE				("no_ecc"),            // String
      .FIFO_DEPTH			(2048),              // DECIMAL
      .FIFO_MEMORY_TYPE		("ultra"),      // String
      .PACKET_FIFO			("true"),          // String
      .PROG_EMPTY_THRESH	(10),         // DECIMAL
      .PROG_FULL_THRESH		(`INFO_BURST_LEN),          // DECIMAL
      .RD_DATA_COUNT_WIDTH	(11),        // DECIMAL
      .RELATED_CLOCKS		(0),             // DECIMAL
      .SIM_ASSERT_CHK		(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH			(512),               // DECIMAL
      .TDEST_WIDTH			(1),                // DECIMAL
      .TID_WIDTH			(1),                  // DECIMAL
      .TUSER_WIDTH			(1),                // DECIMAL
      .USE_ADV_FEATURES		("100e"),      // String
      .WR_DATA_COUNT_WIDTH	(11)         // DECIMAL
   )
   INFO_fifo (
		.m_aclk					(clk							),                         
		.s_aclk					(clk							),
		.s_aresetn				(!rst							),
		.s_axis_tvalid			(INFO_axis_tvalid_usr			),
		.s_axis_tready			(INFO_axis_tready_usr			),
		.s_axis_tdata			(INFO_axis_tdata_usr_reverse	),
		.s_axis_tlast			(INFO_axis_tlast_usr			),
		.almost_empty_axis		(								),
		.almost_full_axis		(INFO_fifo_full					),
		.dbiterr_axis			(								),     
		.m_axis_tvalid			(INFO_axis_tvalid				),
		.m_axis_tready			(INFO_axis_tready				),
		.m_axis_tdata			(INFO_axis_tdata				),  
		.m_axis_tlast			(INFO_axis_tlast				),         
		.m_axis_tdest			(								),            
		.m_axis_tid				(								),                
		.m_axis_tkeep			(								),            
		.m_axis_tstrb			(								),            
		.m_axis_tuser			(								),             
		.prog_empty_axis 		(								),       
		.prog_full_axis			(INFO_fifo_prog_full 			),        
		.rd_data_count_axis		(								),
		.sbiterr_axis			(								),            
		.wr_data_count_axis		(								),
		.injectdbiterr_axis		('h0							), 
		.injectsbiterr_axis		('h0							), 
		.s_axis_tdest			('h0							),            
		.s_axis_tid				('h0							),                
		.s_axis_tkeep			('hffff_ffff_ffff_ffff			),            
		.s_axis_tstrb			('hffff_ffff_ffff_ffff			),            
		.s_axis_tuser			(								)            
            
   );
   
//   ila_INFO_sim ila_INFO_sim (
//	.clk			(clk), // input wire clk
//	.probe0			(INFO_axis_tvalid_usr), // input wire [0:0]  probe0  
//	.probe1			(INFO_axis_tready_usr), // input wire [0:0]  probe1 
//	.probe2			(INFO_axis_tlast_usr), // input wire [0:0]  probe2 
//	.probe3			(INFO_fifo_prog_full) // input wire [0:0]  probe3
//);
	
endmodule
