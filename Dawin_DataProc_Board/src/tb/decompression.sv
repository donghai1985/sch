`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/13 09:42:59
// Design Name: 
// Module Name: decompression
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


module decompression(
    input logic clk,
    input logic rst,
    
    // AXI-Stream  ‰»ÎΩ”ø⁄
    input 	logic [511:0] 	s_axis_tdata,
    input 	logic 			s_axis_tvalid,
    input 	logic 			s_axis_tready,
    input 	logic 			s_axis_tlast
    );
    `include "ETH_pkt_define.sv"
    
    logic [2559:0]	data_buffer;
    logic [4095:0]	data_decom;
    logic [511:0]	data_decom_reg	[7:0];
    logic [2:0]		in_cnt;
    logic			tvalid;
    
    logic [511:0]	s_axis_tdata_reverse;
    assign s_axis_tdata_reverse=hdr_byte_reorder(s_axis_tdata);
    
    genvar i;
    
//    logic [511:0]	s_axis_tdata_shift;
//    generate
//    for(i=0;i<32;i=i+1)
//    	assign s_axis_tdata_shift[i*16+:16]=s_axis_tdata_reverse[(32-i)*16-1-:16];
//    endgenerate
    
    
    always_ff@(posedge clk or posedge rst)
    	if(rst) 													data_buffer<=0;
    	else if(in_cnt==0 && s_axis_tvalid && s_axis_tready)		data_buffer<=s_axis_tdata;
    	else if(s_axis_tvalid && s_axis_tready)						data_buffer<=data_buffer<<512 | s_axis_tdata;
    
//    genvar i;
    generate
    	for(i=0;i<256;i=i+1)
    	begin
    		assign data_decom[i*16+:10]=data_buffer[i*10+:10];
    		assign data_decom[i*16+10+:6]=6'h0;
    	end
    	
    	for(i=0;i<8;i=i+1)
    	begin
    		always_ff@(posedge clk or posedge rst)
    			if(rst)					data_decom_reg[i]<=0;
    			else if(tvalid)			data_decom_reg[i]<=data_decom[i*512+:512];
    	end
    endgenerate
    
    always_ff@(posedge clk or posedge rst)
    	if(rst)														tvalid<=0;
    	else if(in_cnt==4 && s_axis_tvalid && s_axis_tready)		tvalid<=1;
    	else														tvalid<=0;
    
    always_ff@(posedge clk or posedge rst)
    	if(rst)														in_cnt<=0;
    	else if(s_axis_tvalid && in_cnt==4 && s_axis_tready)		in_cnt<=0;
    	else if(s_axis_tvalid && s_axis_tready)						in_cnt<=in_cnt+1;
    
endmodule
