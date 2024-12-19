`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: image_rx
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


module image_rx#( 
	parameter lvds_pairs                = 6
)(
        input                         clk_rxg,	 
        input                         clk_rxg_x2, 	 
        input                         clk_ddr, 	 
        input                         rst_rx,  	    
        input                         clk_sys,   
        input                         rst_sys,     
		input						  eds_frame_en,
		input [1:0]		              ADC_depth, //0:8bit, 2:12bit
        input  	                      firstframe_del_en,  
        input [lvds_pairs-1:0]		  sensor_data_p,
        input [lvds_pairs-1:0]		  sensor_data_n,
        input [1:0]			          chan_num,	//0: 0~5	1: 0,2,4	2: 0,3	3: 0
        input [11:0]		          training_word,
        input			              cmd_start_training,
        input			              test_image_en,   
        output reg 		              lval_out, 
        output reg [lvds_pairs*12-1:0]data_out,
        output			              training_done, 
        output						  training_result
    );
	
    wire[lvds_pairs*12-1:0]	data_par_trained;
    (*dont_touch = "true"*)(*MARK_DEBUG = "true"*)wire[lvds_pairs-1:0]      data_valid; 
    wire 		                  lval_sync; 
    wire [lvds_pairs*12-1:0]	  data_sync;
 
    training #(         
		.lvds_pairs    	            (lvds_pairs) 
    )	training(
		.clk_rxg 		            (clk_rxg),		
		.clk_rxg_x2 	            (clk_rxg_x2),	
		.clk_ddr 		            (clk_ddr),		
		.rst_rx 		            (rst_rx),	 
		.clk_sys				    (clk_sys),
		.rst_sys				    (rst_sys),
		.ADC_depth                  (ADC_depth),  
		.sensor_data_p            	(sensor_data_p), 
        .sensor_data_n            	(sensor_data_n),
		.training_word				(training_word),
		.cmd_start_training			(cmd_start_training), 
		.data_valid			        (data_valid), 
		.data_par_trained			(data_par_trained),
		.training_done				(training_done),
		.training_result			(training_result)
	);
      

 	lval_synncode_Nchan#(         
		.lvds_pairs    	            (lvds_pairs)
    )
	inst_lval_synncode_Nchan(
		.clk_rxg 		            (clk_rxg), 	 
		.rst_rx 		            (rst_rx),     
		.ADC_depth                  (ADC_depth),  
		.firstframe_del_en			(firstframe_del_en),
		.lines_setting              (2'd0), 		//0:single line  1:dual line  2: triple line  3:quad line
 		.pixel_pitch_7um            (1'b1),			//0:3.5um  1:7um
		.chan_num					(chan_num),  	//0: 0~5	1: 0,2,4	2: 0,3	3: 0
		.data_valid			        (data_valid), 
		.data_in			        (data_par_trained), 
 		.lval_out					(lval_sync), 
		.data_out			        (data_sync)  
	);
	
	reg		test_image_en_reg1;
	reg		test_image_en_reg2;
	reg		eds_frame_en_reg1;
	reg		eds_frame_en_reg2;
	
	always @(posedge clk_rxg)begin
		if(rst_rx)begin
			test_image_en_reg1	<=	1'b0;
			test_image_en_reg2	<=	1'b0;
			eds_frame_en_reg1	<=	1'b0;
			eds_frame_en_reg2	<=	1'b0;
		end
		else begin
			test_image_en_reg1	<=	test_image_en;
			test_image_en_reg2	<=	test_image_en_reg1;
			eds_frame_en_reg1	<=	eds_frame_en;
			eds_frame_en_reg2	<=	eds_frame_en_reg1;
		end
	end
	
	reg	[11:0]	cnt_0;
	reg	[11:0]	cnt_1;
	reg	[11:0]	cnt_2;
	reg	[11:0]	cnt_3;
	reg	[11:0]	cnt_4;
	reg	[11:0]	cnt_5;
	
	always @(posedge clk_rxg)begin
		if(rst_rx)begin 
			lval_out    <= 1'b0;
	        data_out    <= {lvds_pairs*12{1'b0}}; 
			cnt_0	<=	'd0;
			cnt_1	<=	'd352;
			cnt_2	<=	'd704;
			cnt_3	<=	'd1056;
			cnt_4	<=	'd1408;
			cnt_5	<=	'd1760;
		end
		else if(~eds_frame_en_reg2) begin
			lval_out    <= 1'b0;
	        data_out    <= {lvds_pairs*12{1'b0}}; 
			cnt_0	<=	'd0;
			cnt_1	<=	'd352;
			cnt_2	<=	'd704;
			cnt_3	<=	'd1056;
			cnt_4	<=	'd1408;
			cnt_5	<=	'd1760;
		end
		else if(~test_image_en_reg2) begin
			lval_out    <= lval_sync;
			data_out    <= data_sync; 
			cnt_0	<=	'd0;
			cnt_1	<=	'd352;
			cnt_2	<=	'd704;
			cnt_3	<=	'd1056;
			cnt_4	<=	'd1408;
			cnt_5	<=	'd1760;
		end
		else begin
			if(lval_sync && (cnt_0 == 'd351)) begin
				lval_out    <= 1'b1;
				data_out    <= {cnt_5,cnt_4,cnt_3,cnt_2,cnt_1,cnt_0}; 
				cnt_0	<=	'd0;
				cnt_1	<=	'd352;
				cnt_2	<=	'd704;
				cnt_3	<=	'd1056;
				cnt_4	<=	'd1408;
				cnt_5	<=	'd1760;
			end
			else if(lval_sync) begin
				lval_out    <= 1'b1;
				data_out    <= {cnt_5,cnt_4,cnt_3,cnt_2,cnt_1,cnt_0}; 
				cnt_0	<=	cnt_0 + 1'd1;
				cnt_1	<=	cnt_1 + 1'd1;
				cnt_2	<=	cnt_2 + 1'd1;
				cnt_3	<=	cnt_3 + 1'd1;
				cnt_4	<=	cnt_4 + 1'd1;
				cnt_5	<=	cnt_5 + 1'd1;
			end
			else begin
				lval_out    <= 1'b0;
				data_out    <= data_out; 
				cnt_0	<=	cnt_0;
				cnt_1	<=	cnt_1;
				cnt_2	<=	cnt_2;
				cnt_3	<=	cnt_3;
				cnt_4	<=	cnt_4;
				cnt_5	<=	cnt_5;
			end
		end
	end
	
endmodule
