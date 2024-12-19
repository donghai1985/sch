`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: training
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
module training#( 
	parameter lvds_pairs                = 6 
)(   
    input                               clk_rxg, 		 
    input                               clk_rxg_x2, 	 
    input                               clk_ddr, 		 
    input                               rst_rx, 		    
    input                               clk_sys,   
    input                               rst_sys,   
 	input [1:0]		                    ADC_depth, //0:8bit, 2:12bit
    input [lvds_pairs-1:0]		        sensor_data_p,
    input [lvds_pairs-1:0]		        sensor_data_n,  
    input [11:0]		                training_word,
    input			                    cmd_start_training, 
    output [lvds_pairs*12-1:0]	        data_par_trained, 
    output[lvds_pairs-1:0]              data_valid, 
    output reg		                    training_done,
	output reg							training_result
);
	
	reg						fifo_train_wen;
	reg	[7:0]				fifo_train_din;
	
	wire[11:0]				data_par_2D[lvds_pairs-1:0];
	wire[4:0]				loc_eye_start[lvds_pairs-1:0];  
	wire[4:0]				loc_eye_mid[lvds_pairs-1:0];  
	wire[4:0]				loc_eye_end[lvds_pairs-1:0]; 
	wire[2:0]				cnt_timeout2[lvds_pairs-1:0];	
	wire[3:0]				loc_word[lvds_pairs-1:0];
	wire[lvds_pairs-1:0]	loc_ok;
	wire[lvds_pairs-1:0]	training_done_pre;

	
	localparam			s_WR_IDLE		= 4'd0,
						s_WAIT_TIME		= 4'd1,
						s_WRITE_START	= 4'd2,
						s_WRITE_MID		= 4'd3,
						s_WRITE_END		= 4'd4,
						s_WRITE_TIMES	= 4'd5,
						s_WRITE_WORD	= 4'd6,
						s_WRITE_OK		= 4'd7,
						s_CHAN_NUM		= 4'd8;
	(*MARK_DEBUG = "true"*)reg[3:0]			fsm_wr_result=s_WR_IDLE;
							
	(*MARK_DEBUG = "true"*)reg[5:0]			chan_sel;
	
	(*async_reg="true"*)reg[5:0]			cmd_start_training_q;
	
	always@(posedge clk_sys)begin
		if(rst_sys)begin
			fsm_wr_result			 <= s_WR_IDLE;
			fifo_train_din  		 <= 8'd0;
			fifo_train_wen  		 <= 1'b0; 
			cmd_start_training_q	 <= 6'd0; 
			chan_sel				 <= 6'd0;
			training_done            <= 1'b0;
			training_result			 <=	1'b0;
		end
		else begin
			cmd_start_training_q[5:1]<= cmd_start_training_q[4:0]; 
			cmd_start_training_q[0]	 <= cmd_start_training;   
			
			fifo_train_wen  	<= 1'b0;
			
			case(fsm_wr_result)
				s_WR_IDLE:		begin
									if((cmd_start_training_q[4] == 1'b1)&&(cmd_start_training_q[5] == 1'b0))begin
										chan_sel			<= 6'd0;
										training_done       <= 1'b0;
										training_result		<= 1'b0;
										fsm_wr_result		<= s_WAIT_TIME;
									end
								end
				s_WAIT_TIME:	begin
									if(training_done_pre == 6'b111111)begin
										chan_sel		<= 6'd0;
										if(cnt_timeout2[0] == 3'b111)begin
											fsm_wr_result		<= s_WR_IDLE;
											training_done       <= 1'b1;
											training_result		<= 1'b0;
										end
										else begin
											fsm_wr_result		<= s_WRITE_START;
											training_done       <= 1'b0;
											training_result		<= 1'b0;
										end
									end
									else begin
										chan_sel		<= 6'd0;
										fsm_wr_result	<= fsm_wr_result;
									end
								end
				s_WRITE_START:	begin
									fifo_train_din  		<={3'd0, loc_eye_start[chan_sel]}; //{2'd0, chan_sel};
									fifo_train_wen  		<= 1'b1;
									fsm_wr_result 			<= s_WRITE_MID;
								end 
				s_WRITE_MID:	begin
									fifo_train_din  		<= {3'd0, loc_eye_mid[chan_sel]};
									fifo_train_wen  		<= 1'b1;
									fsm_wr_result 			<= s_WRITE_END;
								end
				s_WRITE_END:	begin
									fifo_train_din  		<= {3'd0,loc_eye_end[chan_sel]}; 
									fifo_train_wen  		<= 1'b1;
									fsm_wr_result 			<= s_WRITE_WORD;
								end
				s_WRITE_WORD:	begin
									fifo_train_din  		<= {4'b0000,loc_word[chan_sel]};
									fifo_train_wen  		<= 1'b1;
									fsm_wr_result 			<= s_WRITE_TIMES;
								end
				s_WRITE_TIMES:	begin
									fifo_train_din  		<= {5'd0, cnt_timeout2[chan_sel]};
									fifo_train_wen  		<= 1'b1;
									fsm_wr_result 			<= s_WRITE_OK;
								end
				s_WRITE_OK:		begin
									fifo_train_din  		<= {7'b0000000, loc_ok[chan_sel]};
									fifo_train_wen  		<= 1'b1;
									fsm_wr_result 			<= s_CHAN_NUM;
								end 
				s_CHAN_NUM:		begin
									if (chan_sel == lvds_pairs -1) begin
										fsm_wr_result		<= s_WR_IDLE;
										training_done       <= 1'b1;
										training_result		<= 1'b1;
									end
									else begin
										chan_sel			<= chan_sel + 6'd1;
										fsm_wr_result		<= s_WRITE_START;
									end
								end
				default:        fsm_wr_result		<= s_WR_IDLE;
			endcase
		end
	end
 
 
 
//train_word_align模块修改为12bit版本，要支持8bit，需要修改该模块   

	genvar			i;    
 	generate
        for (i = 0; i < lvds_pairs; i = i+1) begin:loop
            train_word_align#(
				.PARA_GROUP	("GROUP")
			)   train_word_align ( 
                .clk_rxg				(clk_rxg),	
				.clk_rxg_x2			 	(clk_rxg_x2),
                .clk_rxio				(clk_ddr),	
                .rst_rx				    (rst_rx),	 
				.ADC_depth              (ADC_depth),  
				.cmd_start_training		(cmd_start_training),	
				.training_word			(training_word), 
                .lvds_data_p    		(sensor_data_p[i]), 
                .lvds_data_n      		(sensor_data_n[i]), 
			    .data_valid			    (data_valid[i]), 
                .dataout_glb        	(data_par_2D[i]),
				.training_done			(training_done_pre[i]),              
				.loc_eye_start          (loc_eye_start[i]),                                                     
				.loc_eye_mid			(loc_eye_mid[i]),                                                      
				.loc_eye_end			(loc_eye_end[i]),                  
				.cnt_timeout2			(cnt_timeout2[i]),                   
				.loc_word				(loc_word[i]),   
				.loc_ok					(loc_ok[i]) 				
			);           
			
		    assign	data_par_trained [(i+1)*12-1:i*12]	=  data_par_2D[i]; 
        end
    endgenerate  	    
  		  
			 
endmodule
