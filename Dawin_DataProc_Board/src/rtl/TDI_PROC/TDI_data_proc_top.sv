`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/12 18:18:01
// Design Name: 
// Module Name: TDI_data_proc_tb
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


module TDI_data_proc_top(
input							clk					,
input							clk_300				,
input							rst					,

input							TDI_sim_start		,
input							TDI_sim_start_auto	,
input							db_write_enable		,
input 							TDI_max_speed_mode	,

output	logic	[511:0]			TDI_axis_tdata_0	,
output	logic 					TDI_axis_tvalid_0	,
input	logic					TDI_axis_tready_0	,
output	logic					TDI_axis_tlast_0	,

output	logic	[511:0]			TDI_axis_tdata_1	,
output	logic 					TDI_axis_tvalid_1	,
input	logic					TDI_axis_tready_1	,
output	logic					TDI_axis_tlast_1	,

output	logic					TDI_fifo_prog_full	,

output 							part_num			,
output							first_part_flag		,

input	[31:0]					sim_part_valid_line_cnt			,
input	[31:0]					sim_track_valid_line_cnt		,
input	[31:0]					sim_track_total_line_cnt		,
output 	logic					TDI_trigger,
output	logic					track_tlast
    );
    `include "ETH_pkt_define.sv"

    logic                  	i_dma_ready        [1:0]	;
    logic  [511:0]         	o_dma_data         [1:0]	;
    logic                  	o_dma_vlaid        [1:0]	;
    logic                  	o_dma_last         [1:0]	;
    logic                  	o_dma_sop          [1:0]	;
    logic                  	o_dma_eop          [1:0]	;
    logic                  	o_dma_sol          [1:0]	;
    logic                  	o_dma_eol          [1:0]	;
	logic					o_TDI_0_fifo_full			;
	logic					o_TDI_1_fifo_full			;
    
    
//    logic [31:0]			pixel_cnt=0			;
//    logic [31:0]			line_cnt=0			;

    
    

	TDI_data_sim TDI_data_sim
	(
		.clk				(clk				),
		.clk_300			(clk_300			),
		.rst				(rst				),
		.TDI_sim_start  	(TDI_sim_start  	),
		.TDI_sim_start_auto (TDI_sim_start_auto	),
		.TDI_max_speed_mode	(TDI_max_speed_mode ),
		.db_write_enable	(db_write_enable	),
		
		.i_dma_ready_0		(i_dma_ready	[0]	),
		.o_dma_data_0 		(o_dma_data 	[0]	),
		.o_dma_vlaid_0		(o_dma_vlaid	[0]	),
		.o_dma_last_0 		(o_dma_last 	[0]	),
		.o_TDI_0_fifo_full	(o_TDI_0_fifo_full	),
		
		
		.i_dma_ready_1		(i_dma_ready	[1]	),
		.o_dma_data_1 		(o_dma_data 	[1]	),
		.o_dma_vlaid_1		(o_dma_vlaid	[1]	),
		.o_dma_last_1 		(o_dma_last 	[1]	),
		.o_TDI_1_fifo_full 	(o_TDI_1_fifo_full	),
		
//		.part_num					(part_num					),
//		.sim_part_valid_line_cnt	(sim_part_valid_line_cnt	),
		.sim_track_valid_line_cnt	(sim_track_valid_line_cnt	),
		.sim_track_total_line_cnt	(sim_track_total_line_cnt	),
		
		
		.TDI_trigger		(TDI_trigger 		),
		.track_tlast		(track_tlast		)
		
	);

   	TDI_data_proc TDI_data_proc
   	(
   		.clk						(clk				),
   		.clk_300					(clk_300			),
   		.rst						(rst				),
   		.s_axis_tdata_0				(o_dma_data[0]		),
   		.s_axis_tvalid_0 			(o_dma_vlaid[0] 	),
   		.s_axis_tready_0 			(i_dma_ready[0] 	),
   		.s_axis_tlast_0 			(o_dma_last[0] 		),
   		.TDI_0_fifo_full			(o_TDI_0_fifo_full	),
   		
   		.s_axis_tdata_1				(o_dma_data[1]		),
   		.s_axis_tvalid_1 			(o_dma_vlaid[1] 	),
   		.s_axis_tready_1 			(i_dma_ready[1] 	),
   		.s_axis_tlast_1 			(o_dma_last[1] 		),
   		.TDI_1_fifo_full			(o_TDI_1_fifo_full	),
   		
   		.m_axis_tdata_0				(TDI_axis_tdata_0 	),
   		.m_axis_tvalid_0 			(TDI_axis_tvalid_0 	),
   		.m_axis_tready_0			(TDI_axis_tready_0 	),
   		.m_axis_tlast_0 			(TDI_axis_tlast_0 	),
   		
   		.m_axis_tdata_1				(TDI_axis_tdata_1 	),
   		.m_axis_tvalid_1 			(TDI_axis_tvalid_1 	),
   		.m_axis_tready_1			(TDI_axis_tready_1 	),
   		.m_axis_tlast_1 			(TDI_axis_tlast_1 	),
   		
   		.TDI_trigger				(TDI_trigger		),
   		.track_tlast				(track_tlast		),
   		.part_num					(part_num			),
   		.first_part_flag			(first_part_flag	),
   		
   		.sim_part_valid_line_cnt	(sim_part_valid_line_cnt),
   		
   		.compressed_fifo_prog_full	(TDI_fifo_prog_full	)

   	);
   	
   	// synthesis translate_off
   	decompression decompression
   	(
   		.clk				(clk				),
   		.rst				(rst				),
   		.s_axis_tdata		(TDI_axis_tdata_0	),
   		.s_axis_tvalid 		(TDI_axis_tvalid_0 	),
   		.s_axis_tready 		(TDI_axis_tready_0 	),
   		.s_axis_tlast 		(TDI_axis_tlast_0 	)
   	);
    // synthesis translate_on
    
    
endmodule
