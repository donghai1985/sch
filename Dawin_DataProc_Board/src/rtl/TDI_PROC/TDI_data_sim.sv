`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/31 15:46:01
// Design Name: 
// Module Name: gen_data
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
module TDI_data_sim#(
    parameter				TDI_sim_CLK			=	200_000_000,
    parameter				TRIG_period 		=	TDI_sim_CLK/1_000_000
)(
    input                   clk              	 	,
    input					clk_300					,
    input                   rst               		,
    input                   TDI_sim_start         	,
    input					TDI_sim_start_auto		,
    input					db_write_enable			,
    input					TDI_max_speed_mode		,
    
    input                   i_dma_ready_0         	,
    output  [511:0]         o_dma_data_0          	,
    output                  o_dma_vlaid_0         	,
    output                  o_dma_last_0          	,
    output					o_TDI_0_fifo_full		,
    
    input                   i_dma_ready_1         	,
    output  [511:0]         o_dma_data_1          	,
    output                  o_dma_vlaid_1         	,
    output                  o_dma_last_1          	,
    output					o_TDI_1_fifo_full		,
    
//    input	[31:0]			sim_part_valid_line_cnt			,
    input	[31:0]			sim_track_valid_line_cnt		,
    input	[31:0]			sim_track_total_line_cnt		,
    
    (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic	[31:0]			max_trigger_cnt_1s_reg=0		,
//    output logic			part_num=0						,
    
    
    output					TDI_trigger				,
    output					track_tlast
    
//    output                  o_dma_sop           ,
//    output                  o_dma_eop           ,
//    output                  o_dma_sol           ,
//    output                  o_dma_eol           ,
    
//    input	[15 : 0]        r_data_real         

);


    logic  	[511:0]       		TDI_axis_tdata_0   			;
    logic  	[511:0]       		TDI_axis_tdata_0_reverse    ;
    logic                     	TDI_axis_tvlaid_0     		;
    logic                     	TDI_axis_tlast_0      		;
    logic                     	TDI_axis_tready_0     		;
    
    logic  	[511:0]       		TDI_asyn_axis_tdata_0      	;
    logic                     	TDI_asyn_axis_tvlaid_0     	;
    logic                     	TDI_asyn_axis_tlast_0      	;
    logic                     	TDI_asyn_axis_tready_0     	;
    
    logic  	[511:0]       		TDI_axis_tdata_1      		;
    logic  	[511:0]       		TDI_axis_tdata_1_reverse    ;
    logic                     	TDI_axis_tvlaid_1     		;
    logic                     	TDI_axis_tlast_1      		;
    logic                     	TDI_axis_tready_1     		;
    
    logic  	[511:0]       		TDI_asyn_axis_tdata_1      	;
    logic                     	TDI_asyn_axis_tvlaid_1     	;
    logic                     	TDI_asyn_axis_tlast_1      	;
    logic                     	TDI_asyn_axis_tready_1     	;
    
    logic						TDI_0_fifo_full			;
    logic						TDI_1_fifo_full			;
    logic						TDI_0_fifo_prog_full	;
    logic						TDI_1_fifo_prog_full	;
    
    logic	[9:0]				cur_data_0=0			;
    logic	[9:0]				cur_data_1=0			;
    logic	[15:0]				TDI_cnt					;
    logic	[3:0]				state=0					;
    

//    logic                     ro_dma_sop          ;
//    logic                     ro_dma_sop_1d       ;                      
//    logic                     ro_dma_eop          ;
//    logic                     ro_dma_eop_1d       ;                      
//    logic                     ro_dma_sol          ;
//    logic                     ro_dma_sol_1d       ;                      
//    logic                     ro_dma_eol          ;
//    logic                     ro_dma_eol_1d       ;          
    
    logic [31:0]				trig_cnt=0				;
//    logic [31:0]				trig_part_num=0			;
//    logic						part_num=0				;
    logic [31:0]				trig_num=0				;
    logic [31:0]				line_cnt=0				;
	logic						TDI_sim_start_d=0		;
    logic						TDI_sim_start_pos		;
//    logic						TDI_trigger				;
//    logic						track_tlast				;
    logic						track_en=0				;
//    logic [15:0]				rst_cnt					;
	logic [31:0]				cnt_1s=0				;		// one second cnt
    logic [15:0]				TDI_fifo_0_wr_cnt		;
    logic [15:0]				TDI_fifo_1_wr_cnt		;
    
    logic	[31:0]				max_trigger_cnt_1s=0	;
    
    always_ff@(posedge clk)    	TDI_sim_start_d<=TDI_sim_start;    
    assign 						TDI_sim_start_pos=!TDI_sim_start_d && TDI_sim_start;
    
    always_ff@(posedge clk)		
    	if(TDI_sim_start_auto)			track_en<=1;
    	else if(TDI_sim_start_pos)		track_en<=1;
    	else if(track_tlast)			track_en<=0;
    
    always_ff@(posedge clk)
    	if(track_en) begin
			if(trig_cnt==((TRIG_period)-1))			trig_cnt<=0;
			else									trig_cnt<=trig_cnt+1;
		end	else									trig_cnt<=0;
    
    

    assign TDI_trigger=trig_cnt==((TRIG_period)-1)  && trig_num<sim_track_valid_line_cnt;
    
    always_ff@(posedge clk)
    	if(TDI_trigger)					trig_num<=trig_num+1;
    	else if(track_tlast)			trig_num<=0;
    
//    always_ff@(posedge clk)
//    	if(TDI_trigger && trig_part_num==(sim_part_valid_line_cnt-1))			part_num<=~part_num;
//    	else if(track_tlast)													part_num<=~part_num;
    	
//    always_ff@(posedge clk)
//    	if(TDI_trigger)															trig_part_num<=trig_part_num+1;
//    	else if(TDI_trigger && trig_part_num==(sim_part_valid_line_cnt-1))		trig_part_num<=0;
//    	else if(track_tlast)													trig_part_num<=0;

   	always_ff@(posedge clk)
   		if(track_tlast)									line_cnt<=0;	
   		else if(trig_cnt==((TRIG_period)-1))			line_cnt<=line_cnt+1;	

	assign track_tlast=line_cnt==sim_track_total_line_cnt;            

    genvar i;
    generate
    for(i=0;i<32;i=i+1)
    begin
        assign				TDI_axis_tdata_0[i*16+:10]     = cur_data_0+i;
        assign				TDI_axis_tdata_0[i*16+10+:6]   = 'h0;
        assign				TDI_axis_tdata_1[i*16+:10]     = cur_data_1+i;
        assign				TDI_axis_tdata_1[i*16+10+:6]   = 'h0;
    end
    endgenerate
    assign TDI_axis_tdata_0_reverse=TDI_data_reorder(TDI_axis_tdata_0);
    assign TDI_axis_tdata_1_reverse=TDI_data_reorder(TDI_axis_tdata_1);

    always @(posedge clk or posedge rst )
        if(rst)															cur_data_0<='d0;
        else if(TDI_axis_tvlaid_0 && TDI_axis_tlast_0) 					cur_data_0<='d0;
        else if(TDI_axis_tvlaid_0) 										cur_data_0<=cur_data_0+32;
        
     always @(posedge clk or posedge rst )
        if(rst)															cur_data_1<='d0;
        else if(TDI_axis_tvlaid_1 && TDI_axis_tlast_1) 					cur_data_1<='d0;
        else if(TDI_axis_tvlaid_1) 										cur_data_1<=cur_data_1+32;

	always @(posedge clk or posedge rst )
        if(rst)																	TDI_cnt<='d0;
        else if(TDI_axis_tlast_0 && TDI_axis_tvlaid_0 && TDI_axis_tready_0)		TDI_cnt<=0;
        else if(TDI_axis_tvlaid_0 && TDI_axis_tready_0) 						TDI_cnt<=TDI_cnt+1;
	
	enum {IDLE,TDI_SIM_DATA,TDI_SIM_MAX_DATA}cur_st,nxt_st;
	always_ff@(posedge clk or posedge rst)
		if(rst)			cur_st<=IDLE;
		else 			cur_st<=nxt_st;
	
	always_comb
	begin
		nxt_st=cur_st;
		case(cur_st)
			IDLE:						if(TDI_trigger)						nxt_st=TDI_SIM_DATA;
										else if(TDI_max_speed_mode)			nxt_st=TDI_SIM_MAX_DATA;
			TDI_SIM_DATA:				if(TDI_axis_tlast_0)				nxt_st=IDLE;
			TDI_SIM_MAX_DATA:			if(!TDI_max_speed_mode)				nxt_st=IDLE;
		endcase
	end
	
	always_ff@(posedge clk)
		if(TDI_max_speed_mode && cnt_1s==32'd200_000_000)		cnt_1s<=0;
		else if(TDI_max_speed_mode)								cnt_1s<=cnt_1s+1;
		else 													cnt_1s<=0;
	
	always_ff@(posedge clk)
		if(TDI_max_speed_mode && TDI_axis_tvlaid_0 && TDI_axis_tlast_0 && TDI_axis_tready_0)	max_trigger_cnt_1s<=max_trigger_cnt_1s+1;
		else if(TDI_max_speed_mode && cnt_1s==32'd200_000_000)									max_trigger_cnt_1s<=0;
		else if(cur_st==IDLE)																	max_trigger_cnt_1s<=0;
		
	always_ff@(posedge clk)	
		if(TDI_max_speed_mode && cnt_1s==32'd200_000_000)						max_trigger_cnt_1s_reg<=max_trigger_cnt_1s;
	
	assign TDI_axis_tvlaid_0=(cur_st==TDI_SIM_DATA | (cur_st==TDI_SIM_MAX_DATA && db_write_enable)) && (TDI_cnt<`CHANNEL_0_LEN);
	assign TDI_axis_tvlaid_1=(cur_st==TDI_SIM_DATA | (cur_st==TDI_SIM_MAX_DATA && db_write_enable)) && (TDI_cnt<`CHANNEL_1_LEN);
	assign TDI_axis_tlast_0=(cur_st==TDI_SIM_DATA | (cur_st==TDI_SIM_MAX_DATA && db_write_enable)) && (TDI_cnt==(`CHANNEL_0_LEN-1));
	assign TDI_axis_tlast_1=(cur_st==TDI_SIM_DATA | (cur_st==TDI_SIM_MAX_DATA && db_write_enable)) && (TDI_cnt==(`CHANNEL_1_LEN-1));
	
//	always_ff@(posedge clk or posedge rst)
//		if(rst)								rst_cnt<=0;
//		else if(track_tlast)				rst_cnt<=0;
//		else if(rst_cnt==100)				rst_cnt<=100;
//		else								rst_cnt<=rst_cnt+1;
	
//	assign o_TDI_0_fifo_full=TDI_0_fifo_prog_full && rst_cnt==100;
//	assign o_TDI_1_fifo_full=TDI_1_fifo_prog_full && rst_cnt==100;

	assign o_TDI_0_fifo_full=TDI_0_fifo_prog_full;
	assign o_TDI_1_fifo_full=TDI_1_fifo_prog_full;
	
	TDI_fifo TDI_asyn_fifo_0 (
	  	.s_aclk																(clk						),      // input wire s_aclk
	  	.m_aclk																(clk_300					),
	  	.s_aresetn															(!rst						),      // input wire s_aresetn
	  	.s_axis_tvalid														(TDI_axis_tvlaid_0			),  	// input wire s_axis_tvalid
	  	.s_axis_tready														(TDI_axis_tready_0			),  	// output wire s_axis_tready
	  	.s_axis_tdata														(TDI_axis_tdata_0_reverse	),    	// input wire [511 : 0] s_axis_tdata
	  	.s_axis_tlast														(TDI_axis_tlast_0			),    	// input wire s_axis_tlast
	  	.s_axis_tuser														(4'h0						),    // input wire [3 : 0] s_axis_tuser
	  	.m_axis_tvalid														(TDI_asyn_axis_tvlaid_0		),  // output wire m_axis_tvalid
	  	.m_axis_tready														(TDI_asyn_axis_tready_0		),  // input wire m_axis_tready
	  	.m_axis_tdata														(TDI_asyn_axis_tdata_0		),    // output wire [511 : 0] m_axis_tdata
	  	.m_axis_tlast														(TDI_asyn_axis_tlast_0		),    // output wire m_axis_tlast
	  	.m_axis_tuser														(							)    // output wire [3 : 0] m_axis_tuser
	);
	
	TDI_fifo TDI_asyn_fifo_1 (
	  	.s_aclk																(clk						),      // input wire s_aclk
	  	.m_aclk																(clk_300					),
	  	.s_aresetn															(!rst 						),      // input wire s_aresetn
	  	.s_axis_tvalid														(TDI_axis_tvlaid_1			),  	// input wire s_axis_tvalid
	  	.s_axis_tready														(TDI_axis_tready_1			),  	// output wire s_axis_tready
	  	.s_axis_tdata														(TDI_axis_tdata_1_reverse	),    	// input wire [511 : 0] s_axis_tdata
	  	.s_axis_tlast														(TDI_axis_tlast_1			),    	// input wire s_axis_tlast
	  	.s_axis_tuser														(4'h0						),    // input wire [3 : 0] s_axis_tuser
	  	.m_axis_tvalid														(TDI_asyn_axis_tvlaid_1		),  // output wire m_axis_tvalid
	  	.m_axis_tready														(TDI_asyn_axis_tready_1		),  // input wire m_axis_tready
	  	.m_axis_tdata														(TDI_asyn_axis_tdata_1		),    // output wire [511 : 0] m_axis_tdata
	  	.m_axis_tlast														(TDI_asyn_axis_tlast_1		),    // output wire m_axis_tlast
	  	.m_axis_tuser														(							)    // output wire [3 : 0] m_axis_tuser
	);
	
	xpm_fifo_axis #(
      .CASCADE_HEIGHT		(0),             // DECIMAL
      .CDC_SYNC_STAGES		(2),            // DECIMAL
      .CLOCKING_MODE		("common_clock"), // String
      .ECC_MODE				("no_ecc"),            // String
      .FIFO_DEPTH			(4096),              // DECIMAL
      .FIFO_MEMORY_TYPE		("ultra"),      // String
      .PACKET_FIFO			("true"),          // String
      .PROG_EMPTY_THRESH	(10),         // DECIMAL
      .PROG_FULL_THRESH		(`CHANNEL_0_LEN<<3),          // DECIMAL
      .RD_DATA_COUNT_WIDTH	(12),        // DECIMAL
      .RELATED_CLOCKS		(0),             // DECIMAL
      .SIM_ASSERT_CHK		(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH			(512),               // DECIMAL
      .TDEST_WIDTH			(1),                // DECIMAL
      .TID_WIDTH			(1),                  // DECIMAL
      .TUSER_WIDTH			(1),                // DECIMAL
      .USE_ADV_FEATURES		("100e"),      // String
      .WR_DATA_COUNT_WIDTH	(12)         // DECIMAL
   )
   TDI_fifo_0 (
		.m_aclk					(clk_300						),                         
		.s_aclk					(clk_300						),
		.s_aresetn				(!rst 							),//| track_tlast)
		.s_axis_tvalid			(TDI_asyn_axis_tvlaid_0			),
		.s_axis_tready			(TDI_asyn_axis_tready_0			),
		.s_axis_tdata			(TDI_asyn_axis_tdata_0			),
		.s_axis_tlast			(TDI_asyn_axis_tlast_0			),
		.almost_empty_axis		(								),
		.almost_full_axis		(TDI_0_fifo_full				),
		.dbiterr_axis			(								),     
		.m_axis_tvalid			(o_dma_vlaid_0					),
		.m_axis_tready			(i_dma_ready_0					),
		.m_axis_tdata			(o_dma_data_0					),  
		.m_axis_tlast			(o_dma_last_0					),         
		.m_axis_tdest			(								),            
		.m_axis_tid				(								),                
		.m_axis_tkeep			(								),            
		.m_axis_tstrb			(								),            
		.m_axis_tuser			(								),             
		.prog_empty_axis 		(								),       
		.prog_full_axis			(TDI_0_fifo_prog_full 			),        
		.rd_data_count_axis		(								),
		.sbiterr_axis			(								),            
		.wr_data_count_axis		(TDI_fifo_0_wr_cnt				),
		.injectdbiterr_axis		('h0							), 
		.injectsbiterr_axis		('h0							), 
		.s_axis_tdest			('h0							),            
		.s_axis_tid				('h0							),                
		.s_axis_tkeep			('hffff_ffff_ffff_ffff			),            
		.s_axis_tstrb			('hffff_ffff_ffff_ffff			),            
		.s_axis_tuser			('h0							)             
   );
   
   xpm_fifo_axis #(
      .CASCADE_HEIGHT		(0),             // DECIMAL
      .CDC_SYNC_STAGES		(2),            // DECIMAL
      .CLOCKING_MODE		("common_clock"), // String
      .ECC_MODE				("no_ecc"),            // String
      .FIFO_DEPTH			(4096),              // DECIMAL
      .FIFO_MEMORY_TYPE		("ultra"),      // String
      .PACKET_FIFO			("true"),          // String
      .PROG_EMPTY_THRESH	(10),         // DECIMAL
      .PROG_FULL_THRESH		(`CHANNEL_1_LEN<<3),          // DECIMAL
      .RD_DATA_COUNT_WIDTH	(12),        // DECIMAL
      .RELATED_CLOCKS		(0),             // DECIMAL
      .SIM_ASSERT_CHK		(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH			(512),               // DECIMAL
      .TDEST_WIDTH			(1),                // DECIMAL
      .TID_WIDTH			(1),                  // DECIMAL
      .TUSER_WIDTH			(1),                // DECIMAL
      .USE_ADV_FEATURES		("100e"),      // String
      .WR_DATA_COUNT_WIDTH	(12)         // DECIMAL
   )
   TDI_fifo_1 (
		.m_aclk					(clk_300						),                         
		.s_aclk					(clk_300						),
		.s_aresetn				(!rst							),// | track_tlast)
		.s_axis_tvalid			(TDI_asyn_axis_tvlaid_1			),
		.s_axis_tready			(TDI_asyn_axis_tready_1			),
		.s_axis_tdata			(TDI_asyn_axis_tdata_1			),
		.s_axis_tlast			(TDI_asyn_axis_tlast_1			),
		.almost_empty_axis		(								),
		.almost_full_axis		(TDI_1_fifo_full				),
		.dbiterr_axis			(								),     
		.m_axis_tvalid			(o_dma_vlaid_1					),
		.m_axis_tready			(i_dma_ready_1					),
		.m_axis_tdata			(o_dma_data_1					),  
		.m_axis_tlast			(o_dma_last_1					),         
		.m_axis_tdest			(								),            
		.m_axis_tid				(								),                
		.m_axis_tkeep			(								),            
		.m_axis_tstrb			(								),            
		.m_axis_tuser			(								),             
		.prog_empty_axis 		(								),       
		.prog_full_axis			(TDI_1_fifo_prog_full 			),        
		.rd_data_count_axis		(								),
		.sbiterr_axis			(								),            
		.wr_data_count_axis		(TDI_fifo_1_wr_cnt				),
		.injectdbiterr_axis		('h0							), 
		.injectsbiterr_axis		('h0							), 
		.s_axis_tdest			('h0							),            
		.s_axis_tid				('h0							),                
		.s_axis_tkeep			('hffff_ffff_ffff_ffff			),            
		.s_axis_tstrb			('hffff_ffff_ffff_ffff			),            
		.s_axis_tuser			('h0							)             
   );
	
	
//   	always @(posedge i_clk or posedge i_rst ) begin
//        if(i_rst) begin
//            ro_dma_sop      <=  'd0;
//            ro_dma_sol      <=  'd0;
//        end
//        else if(r_process_flag && r_data_cnt=='d0) begin 
//            ro_dma_sop      <=  'd1;
//            ro_dma_sol      <=  'd1;            
//        end
//        else begin
//            ro_dma_sop      <=  'd0;
//            ro_dma_sol      <=  'd0;                  
//        end
//    end

//   always @(posedge i_clk or posedge i_rst ) begin
//        if(i_rst) begin
//            ro_dma_eop      <=  'd0;
//            ro_dma_eol      <=  'd0;
//        end
//        else if(r_process_flag && r_data_cnt==GEN_DATA_NUM-1) begin 
//            ro_dma_eol      <=  'd1;
//            ro_dma_eop      <=  'd1;            
//        end
//        else begin
//            ro_dma_eol      <=  'd0;
//            ro_dma_eop      <=  'd0;                  
//        end
//    end

//   always @(posedge i_clk or posedge i_rst ) begin
//        if(i_rst) begin
//            ro_dma_eop_1d      <=  'd0;
//            ro_dma_eol_1d      <=  'd0;
//            ro_dma_sop_1d      <=  'd0;
//            ro_dma_sol_1d      <=  'd0;
//        end
//        else begin
//            ro_dma_eop_1d      <=  ro_dma_eop;
//            ro_dma_eol_1d      <=  ro_dma_eol;
//            ro_dma_sop_1d      <=  ro_dma_sop;
//            ro_dma_sol_1d      <=  ro_dma_sol;               
//        end
//    end

//    assign  o_dma_eol       = ro_dma_eol_1d;
//    assign  o_dma_eop       = ro_dma_eop_1d;    
//    assign  o_dma_sol       = ro_dma_sol_1d;
//    assign  o_dma_sop       = ro_dma_sop_1d;       
//    assign  o_dma_data      = ro_dma_data;
//    assign  o_dma_vlaid     = ro_dma_vlaid_1d;
//    assign  o_dma_last      = ro_dma_last_1d;
endmodule
