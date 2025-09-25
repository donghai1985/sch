`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/21 13:55:52
// Design Name: 
// Module Name: QPn_LUT
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

`include "Board_define.vh"
module QPn_LUT(
input 	[7:0]		host_IPv4_last_in,


// synthesis translate_off
input	[23:0]		sim_fpga_QPn,
output	[31:0]		sim_IP,
output	[47:0]		sim_MAC,
output	[23:0]		sim_host_QPn,
output	[23:0]		sim_fpga_start_PSN,
// synthesis translate_on   

output	[3:0]		QPn_out
    );
    
    assign QPn_out=	(host_IPv4_last_in==IMC_0_ETH0_IP[7:0])	?	2	:
    				(host_IPv4_last_in==IMC_0_ETH1_IP[7:0])	?	2	:
    				(host_IPv4_last_in==IMC_1_ETH0_IP[7:0])	?	3	:
    				(host_IPv4_last_in==IMC_1_ETH1_IP[7:0])	?	3	:
    				(host_IPv4_last_in==IMC_2_ETH0_IP[7:0])	?	4	:
    				(host_IPv4_last_in==IMC_2_ETH1_IP[7:0])	?	4	:
    				0;
    
    // synthesis translate_off				
   	assign sim_IP=	(sim_fpga_QPn==2)	?	IMC_0_ETH0_IP	:
    				(sim_fpga_QPn==3)	?	IMC_1_ETH0_IP	:
    				(sim_fpga_QPn==4)	?	IMC_2_ETH0_IP	:
    				0;
    
    assign sim_MAC=	(sim_fpga_QPn==2)	?	IMC_0_ETH0_MAC_SIM	:
    				(sim_fpga_QPn==3)	?	IMC_1_ETH0_MAC_SIM	:
    				(sim_fpga_QPn==4)	?	IMC_2_ETH0_MAC_SIM	:
    				0;
    				
    assign sim_host_QPn=	(sim_fpga_QPn==2)	?	IMC_0_QPn	:
    						(sim_fpga_QPn==3)	?	IMC_1_QPn	:
    						(sim_fpga_QPn==4)	?	IMC_2_QPn	:
    						0;
    						
    assign sim_fpga_start_PSN=	(sim_fpga_QPn==2)	?	IMC_0_fpga_start_PSN	:
    							(sim_fpga_QPn==3)	?	IMC_1_fpga_start_PSN	:
    							(sim_fpga_QPn==4)	?	IMC_2_fpga_start_PSN	:
    							0;		
	// synthesis translate_on   			
endmodule
