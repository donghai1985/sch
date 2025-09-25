`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/13 11:32:24
// Design Name: 
// Module Name: arp_table
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


module arp_table(
	input								clk,
	input								arp_table_rst,
	
	input 			[47:0]				arp_src_mac,
	input 			[31:0]				arp_src_ip,
	input								arp_rx_valid,
	
	input 			[31:0]				arp_dst_ip,
	output logic 	[47:0]				arp_dst_mac,
	
	output logic						arp_table_overflow
	
    );
    
    logic [31:0]		arp_ip_table			[7:0]	;
    logic [47:0]		arp_mac_table			[7:0]	;
    logic [2:0]			table_id						;
    
    genvar i;
    generate
    for (i=0;i<8;i=i+1) begin
		always@(posedge clk or posedge arp_table_rst)
			if(arp_table_rst)							arp_ip_table[i]<=0;
			else if(arp_rx_valid && table_id==i)		arp_ip_table[i]<=arp_src_ip;
			
		always@(posedge clk or posedge arp_table_rst)
			if(arp_table_rst)							arp_mac_table[i]<=0;
			else if(arp_rx_valid && table_id==i)		arp_mac_table[i]<=arp_src_mac;
    
    	always@(*)
    		if(arp_dst_ip==arp_ip_table[i])	arp_dst_mac=arp_mac_table[i];
    		else							arp_dst_mac='h0;
    end
    endgenerate
    
    always@(posedge clk or posedge arp_table_rst)
    	if(arp_table_rst)				table_id<=0;
    	else if(arp_rx_valid)			table_id<=table_id+1;
    
    always@(posedge clk or posedge arp_table_rst)
    	if(arp_table_rst)								arp_table_overflow<=0;
    	else if(arp_rx_valid && table_id==7)			arp_table_overflow<=1;
    
endmodule
