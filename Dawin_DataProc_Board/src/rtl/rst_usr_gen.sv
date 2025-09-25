`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/22 14:20:01
// Design Name: 
// Module Name: rst_usr_gen
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


module rst_usr_gen(
    input gt_tx_clk,
    input gt_reset,
    output rst_usr
);
    
    logic [31:0]		rst_usr_cnt;
    
    /***********************    rst_usr_0     ****************************/       	
   	always_ff@(posedge gt_tx_clk or posedge gt_reset)
   		if(gt_reset)                                   	rst_usr_cnt<=0;
   		else if(rst_usr_cnt=='d200_000_000)				rst_usr_cnt<='d200_000_000;
   		else											rst_usr_cnt<=rst_usr_cnt+1;
   	
   	assign rst_usr=(rst_usr_cnt>'d100_000_000 && rst_usr_cnt<'d200_000_000)?1:0;
    
    
    
    
endmodule
