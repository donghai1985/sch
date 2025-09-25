`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/13 16:50:47
// Design Name: 
// Module Name: axi_lite_interface
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
module axi_lite_interface
#(
  parameter C_S_AXI_LITE_ADDR_WIDTH = 32,
  parameter C_S_AXI_LITE_DATA_WIDTH = 32,
  parameter C_READ_BCK_REG = 0
)
(
  input   wire                                		s_axi_lite_aclk,
  input   wire                                		s_axi_lite_arstn,

  output  reg   [C_S_AXI_LITE_ADDR_WIDTH-1:0] 		s_axi_lite_awaddr,
  input   wire                                		s_axi_lite_awready,
  output  reg                                 		s_axi_lite_awvalid,

  output  reg   [C_S_AXI_LITE_ADDR_WIDTH-1:0] 		s_axi_lite_araddr,
  input   wire                                		s_axi_lite_arready,
  output  reg                                 		s_axi_lite_arvalid,

  output  reg   [C_S_AXI_LITE_DATA_WIDTH-1:0] 		s_axi_lite_wdata,
  output     	[C_S_AXI_LITE_DATA_WIDTH/8 -1:0] 	s_axi_lite_wstrb,
  input   wire                                		s_axi_lite_wready,
  output  reg                                 		s_axi_lite_wvalid,

  input   wire  [C_S_AXI_LITE_DATA_WIDTH-1:0] 		s_axi_lite_rdata,
  input   wire  [1:0]                         		s_axi_lite_rresp,
  output  reg                                 		s_axi_lite_rready,
  input   wire                                		s_axi_lite_rvalid,

  input   wire  [1:0]                         		s_axi_lite_bresp,
  output  reg                                 		s_axi_lite_bready,
  input   wire                                		s_axi_lite_bvalid,

  input	  wire										i_en,
  input   wire                                		i_wr,
  input   wire [C_S_AXI_LITE_ADDR_WIDTH-1:0]  		i_addr,
  input   wire [C_S_AXI_LITE_DATA_WIDTH-1:0]  		i_data,
  output											o_done,
  output  reg	[C_S_AXI_LITE_DATA_WIDTH-1:0]  		o_data,
  output  reg										o_data_vld
  

);

	enum {IDLE,WRITE_ADDR,WRITE_DATA,WRITE_ACK,READ,READ_ACK,DONE}cur_st,nxt_st;
	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)
		if(~s_axi_lite_arstn)			cur_st<=IDLE;
		else 							cur_st<=nxt_st;
	
	always@(*)
	begin
		nxt_st=cur_st;
		case(cur_st)
			IDLE:
				if(i_en && i_wr==`op_read)								nxt_st=READ;
				else if(i_en && i_wr==`op_write)						nxt_st=WRITE_ADDR;
			READ:		
				if(s_axi_lite_arready)									nxt_st=READ_ACK;
			READ_ACK:	
				if(s_axi_lite_rready && s_axi_lite_rvalid)				nxt_st=DONE;
			WRITE_ADDR:
				if(s_axi_lite_awready)									nxt_st=WRITE_DATA;
			WRITE_DATA:
				if(s_axi_lite_wready)									nxt_st=WRITE_ACK;
			WRITE_ACK:
				if(s_axi_lite_bvalid && s_axi_lite_bready)				nxt_st=DONE;
			DONE:
																		nxt_st=IDLE;
			default:													nxt_st=IDLE;
		endcase
	end
	
	assign o_done=cur_st==DONE;
	
	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)	
		if(~s_axi_lite_arstn)
		begin
			s_axi_lite_araddr<=0;
			s_axi_lite_rready<=0;
		end
		else if(cur_st==IDLE && i_en && i_wr==`op_read)
		begin
			s_axi_lite_araddr<=i_addr;
			s_axi_lite_rready<=0;
		end
		/*else if(cur_st==READ)
		begin
			s_axi_lite_arvalid<=1;
		end	*/
		else if(cur_st==READ_ACK && s_axi_lite_rready && s_axi_lite_rvalid)
		begin
			s_axi_lite_rready<=0;
//			s_axi_lite_arvalid<=0;
		end
		else if(cur_st==READ_ACK && s_axi_lite_rvalid)
		begin
			s_axi_lite_rready<=1;
			s_axi_lite_araddr<=s_axi_lite_araddr;
		end
		
	assign s_axi_lite_arvalid=cur_st==READ;
	
	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)
		if(~s_axi_lite_arstn)
		begin
			o_data<=0;
			o_data_vld<=0;
		end
		else if(cur_st==READ_ACK && s_axi_lite_rready && s_axi_lite_rvalid)
		begin
			o_data<=s_axi_lite_rdata;
			o_data_vld<=1;
		end
		else begin
			o_data<=o_data;
			o_data_vld<=0;
		end
	
	always@(posedge s_axi_lite_aclk or negedge s_axi_lite_arstn)	
		if(~s_axi_lite_arstn)
		begin
			s_axi_lite_bready<=0;
			s_axi_lite_awaddr<=0;
			s_axi_lite_wdata<=0;
		end
		else if(cur_st==IDLE && i_en && i_wr==`op_write)
		begin
			s_axi_lite_bready<=0;
			s_axi_lite_awaddr<=i_addr;
			s_axi_lite_wdata<=i_data;
		end
		/*else if(cur_st==WRITE_ADDR && s_axi_lite_awready)
		begin
			s_axi_lite_bready<=0;
			s_axi_lite_awaddr<=s_axi_lite_awaddr;
			s_axi_lite_wdata<=0;
		end
		else if(cur_st==WRITE_DATA && s_axi_lite_awready)
		begin
			s_axi_lite_bready<=0;
			s_axi_lite_awaddr<=0;
			s_axi_lite_wdata<=i_data;
		end
		else if(cur_st==WRITE_ACK && s_axi_lite_bvalid && s_axi_lite_bready)
		begin
			s_axi_lite_bready<=0;
			s_axi_lite_awaddr<=0;
			s_axi_lite_wdata<=0;
		end*/
		else if(cur_st==WRITE_ACK)
		begin
			s_axi_lite_bready<=1;
			s_axi_lite_awaddr<=0;
			s_axi_lite_wdata<=0;
		end
	assign s_axi_lite_awvalid=cur_st==WRITE_ADDR;
	assign s_axi_lite_wvalid=cur_st==WRITE_DATA;
	assign s_axi_lite_wstrb=4'hf;

endmodule
