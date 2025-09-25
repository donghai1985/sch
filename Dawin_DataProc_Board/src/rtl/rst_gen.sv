`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/14 10:48:49
// Design Name: 
// Module Name: rst_gen
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


(* keep_hierarchy = "yes" *)module rst_gen
#
(
	parameter SIM="FALSE"
)(
    input sysclk_100,
    input clk_wiz_locked,
    output rst
);
    logic				rst_initial;
    logic [31:0]		rst_initial_cnt;
    logic				rst_debug;
/***********************    rst     **********************************/    
generate 
if(SIM=="FALSE") begin
    always_ff@(posedge sysclk_100)
   		if(~clk_wiz_locked)							rst_initial_cnt<='d0;
   		else if(rst_initial_cnt=='d200_000_000)		rst_initial_cnt<='d200_000_000;
   		else										rst_initial_cnt<=rst_initial_cnt+1;

   	assign rst_initial=(rst_initial_cnt>'d100_000_000 && rst_initial_cnt<'d200_000_000)?1:0;
   	assign rst=rst_initial | rst_debug;
   	
   	vio_rst vio_rst (
	  .clk				(sysclk_100),                // input wire clk
	  .probe_out0		(rst_debug)  // output wire [0 : 0] probe_out0
	);
end
else begin
	always_ff@(posedge sysclk_100)
   		if(~clk_wiz_locked)							rst_initial_cnt<='d0;
   		else if(rst_initial_cnt=='d20)				rst_initial_cnt<='d20;
   		else										rst_initial_cnt<=rst_initial_cnt+1;

   	assign rst_initial=(rst_initial_cnt>'d10 && rst_initial_cnt<'d20)?1:0;
   	assign rst=rst_initial;
end
endgenerate
    
    
endmodule
