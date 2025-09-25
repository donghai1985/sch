`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/24 18:10:05
// Design Name: 
// Module Name: CMAC_monitor
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


module CMAC_monitor(
	input 						gt_clk,
	input						sys_reset,

    output             			tx_usr_axis_tready, 
    input              			tx_usr_axis_tvalid,
    input  		[511:0]    		tx_usr_axis_tdata,
    input             			tx_usr_axis_tlast,
    input  		[63:0]     		tx_usr_axis_tkeep,
    
    output logic [63:0]			cmac_tx_speed_reg
    );
    
    localparam GT_CLK_PERIOD=322_266_000;
    logic [31:0]				second_cnt=0;
    logic [63:0]				speed;
//    logic [63:0]				speed_reg;	
    always_ff@(posedge gt_clk)
    	if(second_cnt==(GT_CLK_PERIOD-1))			second_cnt<=0;
    	else										second_cnt<=second_cnt+1;
   	
   	always_ff@(posedge gt_clk)
   		if(second_cnt==(GT_CLK_PERIOD-1))															speed<=0;
   		else if(tx_usr_axis_tvalid && tx_usr_axis_tready)											speed<=speed+512;
   	
   	always_ff@(posedge gt_clk)
   		if(second_cnt==(GT_CLK_PERIOD-1))															cmac_tx_speed_reg<=speed;
   	
//   	ila_cmac_speed ila_cmac_speed (
//		.clk		(gt_clk), // input wire clk
//		.probe0		(speed_reg) // input wire [63:0] probe0
//	);
   	
   		
    		
    
    
    
    
endmodule
