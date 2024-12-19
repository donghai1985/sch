`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/20 13:58:40
// Design Name: 
// Module Name: lval_synncode
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
module lval_synncode_Nchan#(
	parameter integer lvds_pairs  = 6   
)
(	
	input				           clk_rxg,
	input				           rst_rx,    
    input [1:0]		               ADC_depth,
	input [1:0]	                   chan_num,  		//0: 0~5	1: 0,2,4	2: 0,3	3: 0
	input				           firstframe_del_en, 
	input [1:0]	                   lines_setting,  //0:single line  1:dual line  2: triple line  3:quad line
	input		                   pixel_pitch_7um,//0:3.5um  1:7um  
	input [lvds_pairs-1:0]	       data_valid,
 	input[lvds_pairs*12-1:0]       data_in,   
 	output reg		               lval_out, 
	output reg[lvds_pairs*12-1:0]  data_out 
    );

 	wire [lvds_pairs-1:0]          Sync_Valid;  
	wire[lvds_pairs*12-1:0]	   	   Sync_Data;   
 
	genvar			i;    
 	generate
        for (i = 0; i < lvds_pairs; i = i+1) begin:loop
			lval_synncode_0chan  inst_lval_synncode_0chan(
				.clk_rxg 		    (clk_rxg), 	 
				.rst_rx 		    (rst_rx),      
				.ADC_depth          (ADC_depth),   
				.chan_num			(chan_num),  
				.data_valid			(data_valid[i]), 
				.data_in			(data_in[12*i+11:12*i]), 
				.Sync_Valid			(Sync_Valid[i]),  
				.Sync_Data		    (Sync_Data[12*i+11:12*i])
			);   
	    end
    endgenerate  	 
	 
	reg[1:0]     chan_num_in;    
	reg[1:0]	 lines_setting_in; 
	reg		     pixel_pitch_7um_in;
	reg[15:0]    LVAL_LENGTH;
	reg[1:0]     num_del;
	always @(posedge clk_rxg)begin
	
		chan_num_in             <= chan_num;
		pixel_pitch_7um_in      <= pixel_pitch_7um;
		lines_setting_in        <= lines_setting;
		
		case(chan_num_in)  
		    3'd0:begin
			        LVAL_LENGTH  <= 16'd352; 
			    end
		    3'd1:begin
			        LVAL_LENGTH  <= 16'd704; 
			    end
		    3'd2:begin
			        LVAL_LENGTH  <= 16'd1056; 
			    end
		    3'd3:begin
			        LVAL_LENGTH  <= 16'd2112; 
			    end 
		endcase
     	if(pixel_pitch_7um_in)begin
		    case(lines_setting_in) 
			    2'd0:begin
				        num_del  <= 2'd0; 
				    end
			    2'd1:begin
				        num_del  <= 2'd1; 
				    end
			    2'd2:begin
				        num_del  <= 2'd2; 
				    end
			    2'd3:begin
				        num_del  <= 2'd3; 
				    end
			endcase
		end
		else begin
		    case(lines_setting_in) 
			    2'd0:begin
				        num_del  <= 2'd1;
				    end
			    default:begin
				        num_del  <= 2'd3;
				    end 
			endcase
		end
	end
	
	
	reg  	      lval_out_pre ;
	reg  	      lval_out_pre_q ;
	reg  	      flag_firstframe_del; 
 	reg[lvds_pairs*12-1:0]			data_out_pre; 
 	reg[lvds_pairs*12-1:0]			data_out_pre_q; 
	reg[1:0]      cnt_del	;
	always @(posedge clk_rxg)begin
		if(rst_rx)begin 
		    lval_out_pre        <= 1'b0;
 		    lval_out_pre_q      <= 1'b0;
 		    data_out_pre        <= {lvds_pairs*12{1'b0}}; 
		    data_out            <= {lvds_pairs*12{1'b0}}; 
			cnt_del             <= 2'd0;
			flag_firstframe_del <= 1'b0;
		end
		else begin		  
		    data_out_pre       <= Sync_Data;
		    data_out           <= data_out_pre;  
			
		    lval_out_pre       <= Sync_Valid[0];
		    lval_out_pre_q     <= lval_out_pre;
			if(flag_firstframe_del)begin 
		        lval_out       <= lval_out_pre;//lval_out_pre_q; 
			end
			else begin
			    if(firstframe_del_en)begin
				    if((lval_out_pre==1'b0)&&(lval_out_pre_q==1'b1)) 
					    if(cnt_del==num_del)flag_firstframe_del <= 1'b1;
						else cnt_del  <= cnt_del + 2'd1;
				end
				else begin 
				    flag_firstframe_del<=1'b1;
				end
			end
 		end
	end
			
endmodule
