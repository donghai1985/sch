`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/09 17:08:49
// Design Name: 
// Module Name: arp_rx
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


module arp_rx
  #(
   	parameter C_AXIS_DATA_WIDTH = 512 
    )(
    input                							clk        			, //时钟信号
    input                							rstn      			, //复位信号，低电平有效
                                    
    output                               			rx_s_axis_tready	,
	input  	[C_AXIS_DATA_WIDTH-1 : 0]    			rx_s_axis_tdata		,
	input 	[C_AXIS_DATA_WIDTH/8-1:0]    			rx_s_axis_tkeep		,
	input                               			rx_s_axis_tvalid	,
	input                               			rx_s_axis_tlast		,
	
	output logic [47:0]								arp_src_mac			,
	output logic [31:0]								arp_src_ip			,
	output logic									arp_rx_valid
    );
	localparam PKT_LEN=64;
	assign rx_s_axis_tready=1;
//reg define
	always@(posedge clk or negedge rstn) 
		if(!rstn)
			arp_src_mac<=0;
		else if(rx_s_axis_tvalid && rx_s_axis_tready)
			arp_src_mac<=rx_s_axis_tdata[512-1-48-:48];
	
	always@(posedge clk or negedge rstn) 
		if(!rstn)
			arp_src_ip<=0;
		else if(rx_s_axis_tvalid && rx_s_axis_tready)
			arp_src_ip<=rx_s_axis_tdata[512-1-128-96-:32];

	always@(posedge clk or negedge rstn)
		if(!rstn)			arp_rx_valid<=0;
		else 				arp_rx_valid<=rx_s_axis_tvalid;
	
endmodule
