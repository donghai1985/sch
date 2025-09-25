`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/12 10:50:26
// Design Name: 
// Module Name: TDI_data_proc
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
module TDI_data_proc(
    input logic 			clk,
    input logic				clk_300,
    input logic 			rst,
    // AXI-Stream 输入接口
    input logic [511:0] 	s_axis_tdata_0,
    input logic 			s_axis_tvalid_0,
    output logic 			s_axis_tready_0,
    input logic 			s_axis_tlast_0,
    input logic				TDI_0_fifo_full,

    input logic [511:0] 	s_axis_tdata_1,
    input logic 			s_axis_tvalid_1,
    output logic 			s_axis_tready_1,
    input logic 			s_axis_tlast_1,
    input logic				TDI_1_fifo_full,
    
    // AXI-Stream 输出接口
    output logic [511:0] 	m_axis_tdata_0,
    output logic 			m_axis_tvalid_0,
    input logic 			m_axis_tready_0,
    output logic 			m_axis_tlast_0,
    
    output logic [511:0] 	m_axis_tdata_1,
    output logic 			m_axis_tvalid_1,
    input logic 			m_axis_tready_1,
    output logic 			m_axis_tlast_1,
    
    input					TDI_trigger,
    input					track_tlast,
    output logic			part_num=0,
    output logic			first_part_flag=0,
    
    input	[31:0]			sim_part_valid_line_cnt,
    
    (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)output logic			compressed_fifo_prog_full
);
    
    `include "ETH_pkt_define.sv"
    
    logic 				state=0;
    
    logic [511:0] 		in_use_axis_tdata;
    logic 				in_use_axis_tvalid;
    logic 				in_use_axis_tready;
    logic 				in_use_axis_tlast ; 
    
    logic [511:0]		compressed_m_axis_tdata_reverse;
    
    logic				chaneel_sel=0;

	
    
    logic [319:0] 		trunc_data ;
    logic [1023:0] 		data_shift_reg;
    logic [1023:0] 		buffer_data_reg;
    logic [11:0] 		buffer_data_cnt=0;
    logic [15:0] 		round_cnt = 0;
    logic [15:0] 		output_cnt = 0;
    logic [15:0] 		remain_cnt = 0;
    
    logic [511:0] 		compressed_m_axis_tdata;
    logic 				compressed_m_axis_tvalid;
    logic 				compressed_m_axis_tready;
    logic 				compressed_m_axis_tlast;
    
    logic [511:0] 		compressed_asyn_m_axis_tdata;
    logic 				compressed_asyn_m_axis_tvalid;
    logic 				compressed_asyn_m_axis_tready;
    logic 				compressed_asyn_m_axis_tlast;
    
    logic [511:0] 		m_axis_tdata;
    logic 				m_axis_tvalid;
    logic 				m_axis_tready;
    logic 				m_axis_tlast;
    
    logic [47:0]		sim_part_valid_pkt_cnt_multi=0;
    logic [31:0]		sim_part_valid_pkt_cnt=0;
//    logic				part_num=0;
    logic [31:0]		m_axis_tvalid_cnt=0;
    
    
    (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)logic				compressed_fifo_full;
    
    //2025.6.9 add 
    logic [31:0]		expected_compressed_tvalid_cnt_reg=0;
    logic [31:0]		expected_compressed_tvalid_cnt=0;
    logic [31:0]		expected_uncompressed_tvalid_cnt=0;
    logic [31:0]		cur_compressed_tvalid_cnt=0;
    logic				track_tlast_reg=0;

    always_ff@(posedge clk_300 or posedge rst)
    	if(rst)																							round_cnt<=0;
    	else if(s_axis_tlast_1 && s_axis_tready_1 && s_axis_tvalid_1 && round_cnt==7)					round_cnt<=0;
    	else if(s_axis_tlast_1 && s_axis_tready_1 && s_axis_tvalid_1)									round_cnt<=round_cnt+1;
    
    always_ff@(posedge clk_300 or posedge rst)
    	if(rst)																								state<=0;
    	else if(state==0 && TDI_0_fifo_full && TDI_1_fifo_full)												state<=1;
    	else if(state==1 && s_axis_tlast_1 && s_axis_tready_1 && s_axis_tvalid_1 && round_cnt==7)			state<=0;
    
    
    always_ff@(posedge clk_300)
    	if(chaneel_sel==0 && s_axis_tlast_0 && s_axis_tvalid_0 && s_axis_tready_0)				chaneel_sel<=1;
    	else if(chaneel_sel==1 && s_axis_tlast_1 && s_axis_tvalid_1 && s_axis_tready_1)			chaneel_sel<=0;
    
    assign s_axis_tready_0=chaneel_sel==0 && in_use_axis_tready;
    assign s_axis_tready_1=chaneel_sel==1 && in_use_axis_tready;
    
    assign in_use_axis_tvalid	=	(state==1)	?	(chaneel_sel	?	s_axis_tvalid_1						:	s_axis_tvalid_0)					:	0;
    assign in_use_axis_tdata	=	(state==1)	?	(chaneel_sel	?	s_axis_tdata_1						:	s_axis_tdata_0)						:	0;
    assign in_use_axis_tlast	=	(state==1)	?	(chaneel_sel	?	s_axis_tlast_1						:	s_axis_tlast_0)						:	0;
    assign in_use_axis_tready 	=	(state==1)	?	(buffer_data_cnt<960)																			:	0;
     
    genvar i;
    generate
	for (i=0; i<32; i++) begin
		assign trunc_data[i*10+:10] = in_use_axis_tdata[i*16 +: 10]; // 截取低10位[[11]]
	end
    endgenerate

	assign data_shift_reg=buffer_data_reg<<320;
	always_ff @(posedge clk_300 or posedge rst) 
		if(rst)																										buffer_data_cnt<=0;
		else if(in_use_axis_tvalid && in_use_axis_tready && compressed_m_axis_tready && buffer_data_cnt>=512)		buffer_data_cnt<=buffer_data_cnt+320-512;
		else if(in_use_axis_tvalid && in_use_axis_tready)															buffer_data_cnt<=buffer_data_cnt+320;
		else if(compressed_m_axis_tready && buffer_data_cnt>=512)													buffer_data_cnt<=buffer_data_cnt-512;
	
	always_ff @(posedge clk_300 or posedge rst) 
		if(rst)																								buffer_data_reg<=0;
		else if(in_use_axis_tvalid && in_use_axis_tready)													buffer_data_reg<=data_shift_reg | trunc_data;
	
//	assign 	compressed_m_axis_tdata_reverse=buffer_data_reg>>(buffer_data_cnt-512);
	assign	compressed_m_axis_tvalid=buffer_data_cnt>=512;
	assign	compressed_m_axis_tdata=buffer_data_reg>>(buffer_data_cnt-512);
	assign	compressed_m_axis_tlast=compressed_m_axis_tvalid && compressed_m_axis_tready && output_cnt==(remain_cnt>256 ? 255 : (remain_cnt-1));


    // tlast生成
    always_ff @(posedge clk_300 or posedge rst) 
        if (rst)             																								output_cnt <= 0;
        else if(compressed_m_axis_tvalid && compressed_m_axis_tready && remain_cnt>256 && output_cnt==255)					output_cnt <= 0;
        else if (compressed_m_axis_tvalid && compressed_m_axis_tready && remain_cnt<=256 && output_cnt==(remain_cnt-1))		output_cnt <= 0;
        else if (compressed_m_axis_tvalid && compressed_m_axis_tready)             											output_cnt <= output_cnt + 1;

	always_ff @(posedge clk_300) 
		if(state==0)																								remain_cnt<=(`CHANNEL_0_LEN+`CHANNEL_1_LEN)*5;
		else if(compressed_m_axis_tvalid && compressed_m_axis_tready && compressed_m_axis_tlast && remain_cnt>256)	remain_cnt<=remain_cnt-256;
		else if(compressed_m_axis_tvalid && compressed_m_axis_tready && compressed_m_axis_tlast)					remain_cnt<=remain_cnt;
	
   	
	
	TDI_fifo TDI_asyn_compressed_fifo (
	  	.s_aclk																(clk_300								),      // input wire s_aclk
	  	.m_aclk																(clk									),
	  	.s_aresetn															(!rst									),      // input wire s_aresetn
	  	.s_axis_tvalid														(compressed_m_axis_tvalid				),  	// input wire s_axis_tvalid
	  	.s_axis_tready														(compressed_m_axis_tready				),  	// output wire s_axis_tready
	  	.s_axis_tdata														(compressed_m_axis_tdata				),    	// input wire [511 : 0] s_axis_tdata
	  	.s_axis_tlast														(compressed_m_axis_tlast				),    	// input wire s_axis_tlast
	  	.s_axis_tuser														(4'h0									),    // input wire [3 : 0] s_axis_tuser
	  	.m_axis_tvalid														(compressed_asyn_m_axis_tvalid			),  // output wire m_axis_tvalid
	  	.m_axis_tready														(compressed_asyn_m_axis_tready			),  // input wire m_axis_tready
	  	.m_axis_tdata														(compressed_asyn_m_axis_tdata			),    // output wire [511 : 0] m_axis_tdata
	  	.m_axis_tlast														(compressed_asyn_m_axis_tlast			),    // output wire m_axis_tlast
	  	.m_axis_tuser														(										)    // output wire [3 : 0] m_axis_tuser
	);
	
	always_ff @(posedge clk) 
   	begin
   		sim_part_valid_pkt_cnt_multi<=(`CHANNEL_0_LEN+`CHANNEL_1_LEN)*sim_part_valid_line_cnt;
   		sim_part_valid_pkt_cnt<=sim_part_valid_pkt_cnt_multi[47:3]*5;
   	end
   	
   	always_ff @(posedge clk) 
   	begin
   		if(track_tlast_reg && cur_compressed_tvalid_cnt==expected_compressed_tvalid_cnt)				m_axis_tvalid_cnt<=0;
   		else if(m_axis_tvalid && m_axis_tready && m_axis_tvalid_cnt==(sim_part_valid_pkt_cnt-1))		m_axis_tvalid_cnt<=0;
   		else if(m_axis_tvalid && m_axis_tready)															m_axis_tvalid_cnt<=m_axis_tvalid_cnt+1;
   	end
   	
   	//2025.6.9 add
   	always_ff @(posedge clk) 
   		if(TDI_trigger && expected_uncompressed_tvalid_cnt==(`WR_BURST_LINE-1))				expected_uncompressed_tvalid_cnt<=0;
   		else if(TDI_trigger)																expected_uncompressed_tvalid_cnt<=expected_uncompressed_tvalid_cnt+1;
   	
   	always_ff @(posedge clk) 
   		if(track_tlast)																		expected_compressed_tvalid_cnt<=0;
   		else if(TDI_trigger && expected_uncompressed_tvalid_cnt==(`WR_BURST_LINE-1))		expected_compressed_tvalid_cnt<=expected_compressed_tvalid_cnt+`COMPRESSED_WR_BURST_TOTAL_LEN;
   	
   	always_ff @(posedge clk) 
   		if(track_tlast)																		expected_compressed_tvalid_cnt_reg<=expected_compressed_tvalid_cnt;
   	
   	always_ff @(posedge clk) 
   		if(track_tlast_reg && cur_compressed_tvalid_cnt==expected_compressed_tvalid_cnt_reg)	cur_compressed_tvalid_cnt<=0;
   		else if(m_axis_tvalid && m_axis_tready)													cur_compressed_tvalid_cnt<=cur_compressed_tvalid_cnt+1;
   		
   	always_ff @(posedge clk)
   		if(track_tlast_reg && cur_compressed_tvalid_cnt==expected_compressed_tvalid_cnt_reg)	track_tlast_reg<=0;
   		else if(track_tlast)																	track_tlast_reg<=1;
   	 
	//2026.6.9 bug fixed
	//if(m_axis_tvalid_cnt>0 && track_tlast) part_num<=~part_num;
   	always_ff @(posedge clk) 
   		if(track_tlast_reg && m_axis_tvalid && m_axis_tready && cur_compressed_tvalid_cnt==(expected_compressed_tvalid_cnt_reg-1))			part_num<=~part_num;
   		else if(m_axis_tvalid && m_axis_tready && m_axis_tvalid_cnt==(sim_part_valid_pkt_cnt-1))											part_num<=~part_num;
	
	always_ff @(posedge clk) 
   		if(track_tlast_reg && m_axis_tvalid && m_axis_tready && cur_compressed_tvalid_cnt==(expected_compressed_tvalid_cnt_reg-1))			first_part_flag<=1;
   		else																																first_part_flag<=0;
	
	
	assign m_axis_tready=	(part_num==0) ? m_axis_tready_0	:	m_axis_tready_1;
	assign m_axis_tvalid_0=	(part_num==0) ? m_axis_tvalid	:	0;
	assign m_axis_tvalid_1=	(part_num==1) ? m_axis_tvalid	:	0;
	assign m_axis_tlast_0=	(part_num==0) ? m_axis_tlast	:	0;
	assign m_axis_tlast_1=	(part_num==1) ? m_axis_tlast	:	0;
	assign m_axis_tdata_0=	(part_num==0) ? m_axis_tdata	:	0;
	assign m_axis_tdata_1=	(part_num==1) ? m_axis_tdata	:	0;

	
 	xpm_fifo_axis #(
      .CASCADE_HEIGHT		(0),             // DECIMAL
      .CDC_SYNC_STAGES		(2),            // DECIMAL
      .CLOCKING_MODE		("common_clock"), // String
      .ECC_MODE				("no_ecc"),            // String
      .FIFO_DEPTH			(8192),              // DECIMAL
      .FIFO_MEMORY_TYPE		("ultra"),      // String
      .PACKET_FIFO			("true"),          // String
      .PROG_EMPTY_THRESH	(10),         // DECIMAL
      .PROG_FULL_THRESH		((`CHANNEL_0_LEN+`CHANNEL_1_LEN)*5),          // DECIMAL
      .RD_DATA_COUNT_WIDTH	(13),        // DECIMAL
      .RELATED_CLOCKS		(0),             // DECIMAL
      .SIM_ASSERT_CHK		(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH			(512),               // DECIMAL
      .TDEST_WIDTH			(1),                // DECIMAL
      .TID_WIDTH			(1),                  // DECIMAL
      .TUSER_WIDTH			(1),                // DECIMAL
      .USE_ADV_FEATURES		("100e"),      // String
      .WR_DATA_COUNT_WIDTH	(13)         // DECIMAL
   )
   TDI_compressed_fifo (
		.m_aclk					(clk							),                         
		.s_aclk					(clk							),
		.s_aresetn				(!rst							),
		.s_axis_tvalid			(compressed_asyn_m_axis_tvalid	),
		.s_axis_tready			(compressed_asyn_m_axis_tready	),
		.s_axis_tdata			(compressed_asyn_m_axis_tdata	),
		.s_axis_tlast			(compressed_asyn_m_axis_tlast	),
		.almost_empty_axis		(								),
		.almost_full_axis		(compressed_fifo_full			),
		.dbiterr_axis			(								),     
		.m_axis_tvalid			(m_axis_tvalid					),
		.m_axis_tready			(m_axis_tready					),
		.m_axis_tdata			(m_axis_tdata					),  
		.m_axis_tlast			(m_axis_tlast					),         
		.m_axis_tdest			(								),            
		.m_axis_tid				(								),                
		.m_axis_tkeep			(								),            
		.m_axis_tstrb			(								),            
		.m_axis_tuser			(								),             
		.prog_empty_axis 		(								),       
		.prog_full_axis			(compressed_fifo_prog_full 		),        
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
   
//   ila_TDI_data_proc ila_TDI_data_proc (
//		.clk		(clk_300), // input wire clk
//		.probe0		(in_use_axis_tvalid), // input wire [0:0]  probe0  
//		.probe1		(in_use_axis_tready), // input wire [0:0]  probe1 
//		.probe2		(in_use_axis_tlast), // input wire [0:0]  probe2 
//		.probe3		(chaneel_sel), // input wire [0:0]  probe3 
//		.probe4		(buffer_data_cnt), // input wire [11:0]  probe4 
//		.probe5		(round_cnt), // input wire [15:0]  probe5 
//		.probe6		(output_cnt), // input wire [15:0]  probe6 
//		.probe7		(remain_cnt), // input wire [15:0]  probe7 
//		.probe8		(compressed_fifo_prog_full), // input wire [0:0]  probe8 
//		.probe9		(compressed_m_axis_tvalid), // input wire [0:0]  probe9 
//		.probe10	(compressed_m_axis_tready), // input wire [0:0]  probe10 
//		.probe11	(compressed_m_axis_tlast), // input wire [0:0]  probe11 
//		.probe12	(compressed_asyn_m_axis_tvalid), // input wire [0:0]  probe12 
//		.probe13	(compressed_asyn_m_axis_tready), // input wire [0:0]  probe13 
//		.probe14	(compressed_asyn_m_axis_tlast) // input wire [0:0]  probe14
//	);

endmodule

