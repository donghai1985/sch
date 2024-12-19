`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/11 8:40:10
// Design Name: 
// Module Name: timing_top_if
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


module timing_top_if(
		input	wire		clk,
		input	wire		clk_h,
		input	wire		rst,
		
		output	wire [7:0]	to_timing_eds_data,
		
		input	wire		to_spi_clk,
		input	wire		to_spi_mosi,
		
		input	wire		clk_div,
		output	reg			rd_en,
		input	wire [127:0]rd_data,
		input	wire [12:0]	rd_data_count,
		
		input	wire		eds_power_en_test,
		input	wire		eds_frame_en_test,
		
		output	reg			clear_buffer,
		output	reg			eds_power_en,
		output	reg			eds_frame_en,
		output	reg	 [31:0]	texp_time,
		output	reg	 [31:0]	frame_to_frame_time,
		output	reg			test_en

);

//////////////////////////////////////////
localparam	TRAINING_WORD		=	12'd797;
localparam	SYNC_CODE_1st		=	12'hFFF;
localparam	SYNC_CODE_2st		=	12'h000;
localparam	SYNC_CODE_3st		=	12'h000;	
localparam	SYNC_CODE_4th_SOL	=	12'hAB0;
localparam	SYNC_CODE_4th_EOL	=	12'hB60;

reg		[3:0]	tx_state;
reg		[15:0]	tx_data_cnt;
reg				flag;
reg		[5:0]	eds_data_0;
reg		[5:0]	eds_data_1;
reg		[5:0]	eds_data_2;
reg		[5:0]	eds_data_3;
reg		[5:0]	eds_data_4;
reg		[5:0]	eds_data_5;
reg		[5:0]	eds_data_6;
reg		[5:0]	eds_data_7;

reg		[127:0]	rd_data_temp;

reg				eds_power_en_reg1;
reg				eds_power_en_reg2;
reg				eds_frame_en_reg1;
reg				eds_frame_en_reg2;

reg				eds_power_en_test_reg1;
reg				eds_power_en_test_reg2;
reg				eds_frame_en_test_reg1;
reg				eds_frame_en_test_reg2;			

always	@(posedge clk_div or posedge rst)
begin
	if(rst) begin
		eds_power_en_reg1		<=	1'b0;
		eds_power_en_reg2		<=	1'b0;
		eds_frame_en_reg1		<=	1'b0;
		eds_frame_en_reg2		<=	1'b0;
		eds_power_en_test_reg1	<=	1'b0;
		eds_power_en_test_reg2	<=	1'b0;
		eds_frame_en_test_reg1	<=	1'b0;
		eds_frame_en_test_reg2	<=	1'b0;
	end
	else begin
		eds_power_en_reg1		<=	eds_power_en;
		eds_power_en_reg2		<=	eds_power_en_reg1;
		eds_frame_en_reg1		<=	eds_frame_en;
		eds_frame_en_reg2		<=	eds_frame_en_reg1;
		eds_power_en_test_reg1	<=	eds_power_en_test;
		eds_power_en_test_reg2	<=	eds_power_en_test_reg1;
		eds_frame_en_test_reg1	<=	eds_frame_en_test;
		eds_frame_en_test_reg2	<=	eds_frame_en_test_reg1;
	end
end

ila_rd_data_test	ila_rd_data_test_inst(
	.clk(clk_div),
	.probe0(rd_en),
	.probe1(rd_data),
	.probe2(eds_data_0),
	.probe3(eds_data_1),
	.probe4(tx_state)
); 


always	@(posedge clk_div or posedge rst)
begin
	if(rst) begin
		tx_state	<=	'd0;
	end
	else if((~eds_power_en_reg2) && (~eds_power_en_test_reg2)) begin
		tx_state	<=	'd0;
	end
	else begin
		case(tx_state)
		4'b0: begin
			if(eds_frame_en_reg2 || eds_frame_en_test_reg2) begin
				tx_state	<=	'd1;
			end
			else begin
				tx_state	<=	'd0;
			end
		end
		4'd1: begin
			if((rd_data_count >= 'd256) && flag)begin
				if(eds_frame_en_reg2 || eds_frame_en_test_reg2) begin
					tx_state	<=	tx_state + 1'd1;
				end
				else begin
					tx_state	<=	'd0;
				end
			end
			else begin
				tx_state	<=	tx_state;
			end
		end
		4'd2: begin		//SYNC_CODE_1st
			if(flag)
				tx_state	<=	tx_state + 1'd1;
			else
				tx_state	<=	tx_state;
		end
		4'd3: begin		//SYNC_CODE_2st
			if(flag)
				tx_state	<=	tx_state + 1'd1;
			else
				tx_state	<=	tx_state;
		end
		4'd4: begin		//SYNC_CODE_3st
			if(flag)
				tx_state	<=	tx_state + 1'd1;
			else
				tx_state	<=	tx_state;
		end
		4'd5: begin		//SYNC_CODE_4th_SOL
			if(flag)
				tx_state	<=	tx_state + 1'd1;
			else
				tx_state	<=	tx_state;
		end
		4'd6: begin
			if(flag && (tx_data_cnt == 'd255)) begin
				tx_state	<=	tx_state + 1'd1;
			end
			else begin
				tx_state	<=	tx_state;
			end
		end
		4'd7: begin		//SYNC_CODE_1st
			if(flag)
				tx_state	<=	tx_state + 1'd1;
			else
				tx_state	<=	tx_state;
		end
		4'd8: begin		//SYNC_CODE_2st
			if(flag)
				tx_state	<=	tx_state + 1'd1;
			else
				tx_state	<=	tx_state;
		end
		4'd9: begin		//SYNC_CODE_3st
			if(flag)
				tx_state	<=	tx_state + 1'd1;
			else
				tx_state	<=	tx_state;
		end
		4'd10: begin		//SYNC_CODE_4th_EOL
			if(flag)
				tx_state	<=	tx_state + 1'd1;
			else
				tx_state	<=	tx_state;
		end			
		4'd11: begin
			if(eds_frame_en_reg2 || eds_frame_en_test_reg2)
				tx_state	<=	'd1;
			else
				tx_state	<=	'd0;
		end
		default: begin
			tx_state	<=	'd0;
		end
		endcase
	end
end

always	@(posedge clk_div or posedge rst)
begin
	if(rst) begin
		eds_data_0	<=	'd0;
		eds_data_1	<=	'd0;
		eds_data_2	<=	'd0;
		eds_data_3	<=	'd0;
		eds_data_4	<=	'd0;
		eds_data_5	<=	'd0;
		eds_data_6	<=	'd0;
		eds_data_7	<=	'd0;
		rd_data_temp<=	'd0;
		rd_en		<=	1'b0;
		tx_data_cnt	<=	'd0;
		flag		<=	1'b0;
	end
	else if((~eds_power_en_reg2) && (~eds_power_en_test_reg2)) begin
		eds_data_0	<=	'd0;
		eds_data_1	<=	'd0;
		eds_data_2	<=	'd0;
		eds_data_3	<=	'd0;
		eds_data_4	<=	'd0;
		eds_data_5	<=	'd0;
		eds_data_6	<=	'd0;
		eds_data_7	<=	'd0;
		rd_data_temp<=	'd0;
		rd_en		<=	1'b0;
		tx_data_cnt	<=	'd0;
		flag		<=	1'b0;
	end
	else begin
		flag		<=	~flag;
		
		case(tx_state)
		4'd0: begin
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			rd_data_temp<=	'd0;
			if(flag) begin
				eds_data_0	<=	TRAINING_WORD[5:0];
				eds_data_1	<=	TRAINING_WORD[5:0];
				eds_data_2	<=	TRAINING_WORD[5:0];
				eds_data_3	<=	TRAINING_WORD[5:0];
				eds_data_4	<=	TRAINING_WORD[5:0];
				eds_data_5	<=	TRAINING_WORD[5:0];
				eds_data_6	<=	TRAINING_WORD[5:0];
				eds_data_7	<=	TRAINING_WORD[5:0];
			end
			else begin
				eds_data_0	<=	TRAINING_WORD[11:6];
				eds_data_1	<=	TRAINING_WORD[11:6];
				eds_data_2	<=	TRAINING_WORD[11:6];
				eds_data_3	<=	TRAINING_WORD[11:6];
				eds_data_4	<=	TRAINING_WORD[11:6];
				eds_data_5	<=	TRAINING_WORD[11:6];
				eds_data_6	<=	TRAINING_WORD[11:6];
				eds_data_7	<=	TRAINING_WORD[11:6];
			end
		end
		4'd1: begin
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			if(flag) begin
				eds_data_0	<=	TRAINING_WORD[5:0];
				eds_data_1	<=	TRAINING_WORD[5:0];
				eds_data_2	<=	TRAINING_WORD[5:0];
				eds_data_3	<=	TRAINING_WORD[5:0];
				eds_data_4	<=	TRAINING_WORD[5:0];
				eds_data_5	<=	TRAINING_WORD[5:0];
				eds_data_6	<=	TRAINING_WORD[5:0];
				eds_data_7	<=	TRAINING_WORD[5:0];
			end
			else begin
				eds_data_0	<=	TRAINING_WORD[11:6];
				eds_data_1	<=	TRAINING_WORD[11:6];
				eds_data_2	<=	TRAINING_WORD[11:6];
				eds_data_3	<=	TRAINING_WORD[11:6];
				eds_data_4	<=	TRAINING_WORD[11:6];
				eds_data_5	<=	TRAINING_WORD[11:6];
				eds_data_6	<=	TRAINING_WORD[11:6];
				eds_data_7	<=	TRAINING_WORD[11:6];
			end
		end
		4'd2: begin		//SYNC_CODE_1st
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			if(flag) begin
				eds_data_0	<=	SYNC_CODE_1st[5:0];
				eds_data_1	<=	SYNC_CODE_1st[5:0];
				eds_data_2	<=	SYNC_CODE_1st[5:0];
				eds_data_3	<=	SYNC_CODE_1st[5:0];
				eds_data_4	<=	SYNC_CODE_1st[5:0];
				eds_data_5	<=	SYNC_CODE_1st[5:0];
				eds_data_6	<=	SYNC_CODE_1st[5:0];
				eds_data_7	<=	SYNC_CODE_1st[5:0];
			end
			else begin
				eds_data_0	<=	SYNC_CODE_1st[11:6];
				eds_data_1	<=	SYNC_CODE_1st[11:6];
				eds_data_2	<=	SYNC_CODE_1st[11:6];
				eds_data_3	<=	SYNC_CODE_1st[11:6];
				eds_data_4	<=	SYNC_CODE_1st[11:6];
				eds_data_5	<=	SYNC_CODE_1st[11:6];
				eds_data_6	<=	SYNC_CODE_1st[11:6];
				eds_data_7	<=	SYNC_CODE_1st[11:6];
			end
		end
		4'd3: begin		//SYNC_CODE_2st
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			if(flag) begin
				eds_data_0	<=	SYNC_CODE_2st[5:0];
				eds_data_1	<=	SYNC_CODE_2st[5:0];
				eds_data_2	<=	SYNC_CODE_2st[5:0];
				eds_data_3	<=	SYNC_CODE_2st[5:0];
				eds_data_4	<=	SYNC_CODE_2st[5:0];
				eds_data_5	<=	SYNC_CODE_2st[5:0];
				eds_data_6	<=	SYNC_CODE_2st[5:0];
				eds_data_7	<=	SYNC_CODE_2st[5:0];
			end
			else begin
				eds_data_0	<=	SYNC_CODE_2st[11:6];
				eds_data_1	<=	SYNC_CODE_2st[11:6];
				eds_data_2	<=	SYNC_CODE_2st[11:6];
				eds_data_3	<=	SYNC_CODE_2st[11:6];
				eds_data_4	<=	SYNC_CODE_2st[11:6];
				eds_data_5	<=	SYNC_CODE_2st[11:6];
				eds_data_6	<=	SYNC_CODE_2st[11:6];
				eds_data_7	<=	SYNC_CODE_2st[11:6];
			end
		end
		4'd4: begin		//SYNC_CODE_3st
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			if(flag) begin
				eds_data_0	<=	SYNC_CODE_3st[5:0];
				eds_data_1	<=	SYNC_CODE_3st[5:0];
				eds_data_2	<=	SYNC_CODE_3st[5:0];
				eds_data_3	<=	SYNC_CODE_3st[5:0];
				eds_data_4	<=	SYNC_CODE_3st[5:0];
				eds_data_5	<=	SYNC_CODE_3st[5:0];
				eds_data_6	<=	SYNC_CODE_3st[5:0];
				eds_data_7	<=	SYNC_CODE_3st[5:0];
			end
			else begin
				eds_data_0	<=	SYNC_CODE_3st[11:6];
				eds_data_1	<=	SYNC_CODE_3st[11:6];
				eds_data_2	<=	SYNC_CODE_3st[11:6];
				eds_data_3	<=	SYNC_CODE_3st[11:6];
				eds_data_4	<=	SYNC_CODE_3st[11:6];
				eds_data_5	<=	SYNC_CODE_3st[11:6];
				eds_data_6	<=	SYNC_CODE_3st[11:6];
				eds_data_7	<=	SYNC_CODE_3st[11:6];
			end
		end
		4'd5: begin		//SYNC_CODE_4th_SOL
			tx_data_cnt	<=	'd0;
			rd_data_temp<=	rd_data;
			if(flag) begin
				eds_data_0	<=	SYNC_CODE_4th_SOL[5:0];
				eds_data_1	<=	SYNC_CODE_4th_SOL[5:0];
				eds_data_2	<=	SYNC_CODE_4th_SOL[5:0];
				eds_data_3	<=	SYNC_CODE_4th_SOL[5:0];
				eds_data_4	<=	SYNC_CODE_4th_SOL[5:0];
				eds_data_5	<=	SYNC_CODE_4th_SOL[5:0];
				eds_data_6	<=	SYNC_CODE_4th_SOL[5:0];
				eds_data_7	<=	SYNC_CODE_4th_SOL[5:0];
				rd_en		<=	1'b1;
			end
			else begin
				eds_data_0	<=	SYNC_CODE_4th_SOL[11:6];
				eds_data_1	<=	SYNC_CODE_4th_SOL[11:6];
				eds_data_2	<=	SYNC_CODE_4th_SOL[11:6];
				eds_data_3	<=	SYNC_CODE_4th_SOL[11:6];
				eds_data_4	<=	SYNC_CODE_4th_SOL[11:6];
				eds_data_5	<=	SYNC_CODE_4th_SOL[11:6];
				eds_data_6	<=	SYNC_CODE_4th_SOL[11:6];
				eds_data_7	<=	SYNC_CODE_4th_SOL[11:6];
				rd_en		<=	1'b0;
			end
		end
		4'd6: begin
			if(flag && (tx_data_cnt == 'd255)) begin
				tx_data_cnt	<=	'd0;
				rd_en		<=	1'b0;
			end
			else if(flag) begin
				tx_data_cnt	<=	tx_data_cnt + 1'd1;
				rd_en		<=	1'b1;
			end
			else begin
				tx_data_cnt	<=	tx_data_cnt;
				rd_en		<=	1'b0;
			end
			
			if(flag) begin
				eds_data_0	<=	rd_data_temp[5:0];
				eds_data_1	<=	rd_data_temp[21:16];
				eds_data_2	<=	rd_data_temp[37:32];
				eds_data_3	<=	rd_data_temp[53:48];
				eds_data_4	<=	rd_data_temp[69:64];
				eds_data_5	<=	rd_data_temp[85:80];
				eds_data_6	<=	rd_data_temp[101:96];
				eds_data_7	<=	rd_data_temp[117:112];
				rd_data_temp<=	rd_data;
			end
			else begin
				eds_data_0	<=	rd_data_temp[11:6];
				eds_data_1	<=	rd_data_temp[27:22];
				eds_data_2	<=	rd_data_temp[43:38];
				eds_data_3	<=	rd_data_temp[59:54];
				eds_data_4	<=	rd_data_temp[75:70];
				eds_data_5	<=	rd_data_temp[91:86];
				eds_data_6	<=	rd_data_temp[107:102];
				eds_data_7	<=	rd_data_temp[123:118];
				rd_data_temp<=	rd_data_temp;
			end
		end
		4'd7: begin		//SYNC_CODE_1st
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			if(flag) begin
				eds_data_0	<=	SYNC_CODE_1st[5:0];
				eds_data_1	<=	SYNC_CODE_1st[5:0];
				eds_data_2	<=	SYNC_CODE_1st[5:0];
				eds_data_3	<=	SYNC_CODE_1st[5:0];
				eds_data_4	<=	SYNC_CODE_1st[5:0];
				eds_data_5	<=	SYNC_CODE_1st[5:0];
				eds_data_6	<=	SYNC_CODE_1st[5:0];
				eds_data_7	<=	SYNC_CODE_1st[5:0];
			end
			else begin
				eds_data_0	<=	SYNC_CODE_1st[11:6];
				eds_data_1	<=	SYNC_CODE_1st[11:6];
				eds_data_2	<=	SYNC_CODE_1st[11:6];
				eds_data_3	<=	SYNC_CODE_1st[11:6];
				eds_data_4	<=	SYNC_CODE_1st[11:6];
				eds_data_5	<=	SYNC_CODE_1st[11:6];
				eds_data_6	<=	SYNC_CODE_1st[11:6];
				eds_data_7	<=	SYNC_CODE_1st[11:6];
			end
		end
		4'd8: begin		//SYNC_CODE_2st
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			if(flag) begin
				eds_data_0	<=	SYNC_CODE_2st[5:0];
				eds_data_1	<=	SYNC_CODE_2st[5:0];
				eds_data_2	<=	SYNC_CODE_2st[5:0];
				eds_data_3	<=	SYNC_CODE_2st[5:0];
				eds_data_4	<=	SYNC_CODE_2st[5:0];
				eds_data_5	<=	SYNC_CODE_2st[5:0];
				eds_data_6	<=	SYNC_CODE_2st[5:0];
				eds_data_7	<=	SYNC_CODE_2st[5:0];
			end
			else begin
				eds_data_0	<=	SYNC_CODE_2st[11:6];
				eds_data_1	<=	SYNC_CODE_2st[11:6];
				eds_data_2	<=	SYNC_CODE_2st[11:6];
				eds_data_3	<=	SYNC_CODE_2st[11:6];
				eds_data_4	<=	SYNC_CODE_2st[11:6];
				eds_data_5	<=	SYNC_CODE_2st[11:6];
				eds_data_6	<=	SYNC_CODE_2st[11:6];
				eds_data_7	<=	SYNC_CODE_2st[11:6];
			end
		end
		4'd9: begin		//SYNC_CODE_3st
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			if(flag) begin
				eds_data_0	<=	SYNC_CODE_3st[5:0];
				eds_data_1	<=	SYNC_CODE_3st[5:0];
				eds_data_2	<=	SYNC_CODE_3st[5:0];
				eds_data_3	<=	SYNC_CODE_3st[5:0];
				eds_data_4	<=	SYNC_CODE_3st[5:0];
				eds_data_5	<=	SYNC_CODE_3st[5:0];
				eds_data_6	<=	SYNC_CODE_3st[5:0];
				eds_data_7	<=	SYNC_CODE_3st[5:0];
			end
			else begin
				eds_data_0	<=	SYNC_CODE_3st[11:6];
				eds_data_1	<=	SYNC_CODE_3st[11:6];
				eds_data_2	<=	SYNC_CODE_3st[11:6];
				eds_data_3	<=	SYNC_CODE_3st[11:6];
				eds_data_4	<=	SYNC_CODE_3st[11:6];
				eds_data_5	<=	SYNC_CODE_3st[11:6];
				eds_data_6	<=	SYNC_CODE_3st[11:6];
				eds_data_7	<=	SYNC_CODE_3st[11:6];
			end
		end
		4'd10: begin		//SYNC_CODE_4th_EOL
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			if(flag) begin
				eds_data_0	<=	SYNC_CODE_4th_EOL[5:0];
				eds_data_1	<=	SYNC_CODE_4th_EOL[5:0];
				eds_data_2	<=	SYNC_CODE_4th_EOL[5:0];
				eds_data_3	<=	SYNC_CODE_4th_EOL[5:0];
				eds_data_4	<=	SYNC_CODE_4th_EOL[5:0];
				eds_data_5	<=	SYNC_CODE_4th_EOL[5:0];
				eds_data_6	<=	SYNC_CODE_4th_EOL[5:0];
				eds_data_7	<=	SYNC_CODE_4th_EOL[5:0];
			end
			else begin
				eds_data_0	<=	SYNC_CODE_4th_EOL[11:6];
				eds_data_1	<=	SYNC_CODE_4th_EOL[11:6];
				eds_data_2	<=	SYNC_CODE_4th_EOL[11:6];
				eds_data_3	<=	SYNC_CODE_4th_EOL[11:6];
				eds_data_4	<=	SYNC_CODE_4th_EOL[11:6];
				eds_data_5	<=	SYNC_CODE_4th_EOL[11:6];
				eds_data_6	<=	SYNC_CODE_4th_EOL[11:6];
				eds_data_7	<=	SYNC_CODE_4th_EOL[11:6];
			end
		end
		4'd11: begin
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			if(flag) begin
				eds_data_0	<=	TRAINING_WORD[5:0];
				eds_data_1	<=	TRAINING_WORD[5:0];
				eds_data_2	<=	TRAINING_WORD[5:0];
				eds_data_3	<=	TRAINING_WORD[5:0];
				eds_data_4	<=	TRAINING_WORD[5:0];
				eds_data_5	<=	TRAINING_WORD[5:0];
				eds_data_6	<=	TRAINING_WORD[5:0];
				eds_data_7	<=	TRAINING_WORD[5:0];
			end
			else begin
				eds_data_0	<=	TRAINING_WORD[11:6];
				eds_data_1	<=	TRAINING_WORD[11:6];
				eds_data_2	<=	TRAINING_WORD[11:6];
				eds_data_3	<=	TRAINING_WORD[11:6];
				eds_data_4	<=	TRAINING_WORD[11:6];
				eds_data_5	<=	TRAINING_WORD[11:6];
				eds_data_6	<=	TRAINING_WORD[11:6];
				eds_data_7	<=	TRAINING_WORD[11:6];
			end
		end
		default: begin
			eds_data_0	<=	'd0;
			eds_data_1	<=	'd0;
			eds_data_2	<=	'd0;
			eds_data_3	<=	'd0;
			eds_data_4	<=	'd0;
			eds_data_5	<=	'd0;
			eds_data_6	<=	'd0;
			eds_data_7	<=	'd0;
			rd_data_temp<=	'd0;
			rd_en		<=	1'b0;
			tx_data_cnt	<=	'd0;
			flag		<=	1'b0;
		end
		endcase
	end
end

OSERDESE2 #(
  .DATA_RATE_OQ		("DDR")		,   		// DDR, SDR
  .DATA_RATE_TQ		("DDR")		,   		// DDR, BUF, SDR
  .DATA_WIDTH		(6)			,   		// Parallel data width (2-8,10,14)
  .INIT_OQ			(1'b0)		,   		// Initial value of OQ output (1'b0,1'b1)
  .INIT_TQ			(1'b0)		,   		// Initial value of TQ output (1'b0,1'b1)
  .SERDES_MODE		("MASTER")	, 			// MASTER, SLAVE
  .SRVAL_OQ			(1'b0)		,			// OQ output value when SR is used (1'b0,1'b1)
  .SRVAL_TQ			(1'b0)		,			// TQ output value when SR is used (1'b0,1'b1)
  .TBYTE_CTL		("FALSE")	,			// Enable tristate byte operation (FALSE, TRUE)
  .TBYTE_SRC		("FALSE")	,			// Tristate byte source (FALSE, TRUE)
  .TRISTATE_WIDTH	(1)      				// 3-state converter width (1,4)
	) OSERDESE2_inst0(
	  .OFB				()					,	// 1-bit output: Feedback path for data
	  .OQ				(to_timing_eds_data[0])			,	// 1-bit output: Data path output
	  .SHIFTOUT1		()					,
	  .SHIFTOUT2		()					,
	  .TBYTEOUT			()					,   // 1-bit output: Byte group tristate
	  .TFB				()					,	// 1-bit output: 3-state control
	  .TQ				()					,	// 1-bit output: 3-state control
	  .CLK				(clk)				,	// 1-bit input: High speed clock
	  .CLKDIV			(clk_div)			,	// 1-bit input: Divided clock
	  .D1				(eds_data_0[5])		,
	  .D2				(eds_data_0[4])		,
	  .D3				(eds_data_0[3])		,
	  .D4				(eds_data_0[2])		,
	  .D5				(eds_data_0[1])		,
	  .D6				(eds_data_0[0])		,
	  .D7				()					,
	  .D8				()					,
	  .OCE				(1'b1)				,	// 1-bit input: Output data clock enable
	  .RST				(rst)				,	// 1-bit input: Reset
	  .SHIFTIN1			()					,
	  .SHIFTIN2			()					,
	  .T1				(1'b0)				,
	  .T2				(1'b0)				,
	  .T3				(1'b0)				,
	  .T4				(1'b0)				,
	  .TBYTEIN			(1'b0)				,	// 1-bit input: Byte group tristate
	  .TCE				(1'b0)              	// 1-bit input: 3-state clock enable
);

OSERDESE2 #(
  .DATA_RATE_OQ		("DDR")		,   		// DDR, SDR
  .DATA_RATE_TQ		("DDR")		,   		// DDR, BUF, SDR
  .DATA_WIDTH		(6)			,   		// Parallel data width (2-8,10,14)
  .INIT_OQ			(1'b0)		,   		// Initial value of OQ output (1'b0,1'b1)
  .INIT_TQ			(1'b0)		,   		// Initial value of TQ output (1'b0,1'b1)
  .SERDES_MODE		("MASTER")	, 			// MASTER, SLAVE
  .SRVAL_OQ			(1'b0)		,			// OQ output value when SR is used (1'b0,1'b1)
  .SRVAL_TQ			(1'b0)		,			// TQ output value when SR is used (1'b0,1'b1)
  .TBYTE_CTL		("FALSE")	,			// Enable tristate byte operation (FALSE, TRUE)
  .TBYTE_SRC		("FALSE")	,			// Tristate byte source (FALSE, TRUE)
  .TRISTATE_WIDTH	(1)      				// 3-state converter width (1,4)
	) OSERDESE2_inst1(
	  .OFB				()					,	// 1-bit output: Feedback path for data
	  .OQ				(to_timing_eds_data[1])			,	// 1-bit output: Data path output
	  .SHIFTOUT1		()					,
	  .SHIFTOUT2		()					,
	  .TBYTEOUT			()					,   // 1-bit output: Byte group tristate
	  .TFB				()					,	// 1-bit output: 3-state control
	  .TQ				()					,	// 1-bit output: 3-state control
	  .CLK				(clk)				,	// 1-bit input: High speed clock
	  .CLKDIV			(clk_div)			,	// 1-bit input: Divided clock
	  .D1				(eds_data_1[5])		,
	  .D2				(eds_data_1[4])		,
	  .D3				(eds_data_1[3])		,
	  .D4				(eds_data_1[2])		,
	  .D5				(eds_data_1[1])		,
	  .D6				(eds_data_1[0])		,
	  .D7				()					,
	  .D8				()					,
	  .OCE				(1'b1)				,	// 1-bit input: Output data clock enable
	  .RST				(rst)				,	// 1-bit input: Reset
	  .SHIFTIN1			()					,
	  .SHIFTIN2			()					,
	  .T1				(1'b0)				,
	  .T2				(1'b0)				,
	  .T3				(1'b0)				,
	  .T4				(1'b0)				,
	  .TBYTEIN			(1'b0)				,	// 1-bit input: Byte group tristate
	  .TCE				(1'b0)              	// 1-bit input: 3-state clock enable
);

OSERDESE2 #(
  .DATA_RATE_OQ		("DDR")		,   		// DDR, SDR
  .DATA_RATE_TQ		("DDR")		,   		// DDR, BUF, SDR
  .DATA_WIDTH		(6)			,   		// Parallel data width (2-8,10,14)
  .INIT_OQ			(1'b0)		,   		// Initial value of OQ output (1'b0,1'b1)
  .INIT_TQ			(1'b0)		,   		// Initial value of TQ output (1'b0,1'b1)
  .SERDES_MODE		("MASTER")	, 			// MASTER, SLAVE
  .SRVAL_OQ			(1'b0)		,			// OQ output value when SR is used (1'b0,1'b1)
  .SRVAL_TQ			(1'b0)		,			// TQ output value when SR is used (1'b0,1'b1)
  .TBYTE_CTL		("FALSE")	,			// Enable tristate byte operation (FALSE, TRUE)
  .TBYTE_SRC		("FALSE")	,			// Tristate byte source (FALSE, TRUE)
  .TRISTATE_WIDTH	(1)      				// 3-state converter width (1,4)
	) OSERDESE2_inst2(
	  .OFB				()					,	// 1-bit output: Feedback path for data
	  .OQ				(to_timing_eds_data[2])			,	// 1-bit output: Data path output
	  .SHIFTOUT1		()					,
	  .SHIFTOUT2		()					,
	  .TBYTEOUT			()					,   // 1-bit output: Byte group tristate
	  .TFB				()					,	// 1-bit output: 3-state control
	  .TQ				()					,	// 1-bit output: 3-state control
	  .CLK				(clk)				,	// 1-bit input: High speed clock
	  .CLKDIV			(clk_div)			,	// 1-bit input: Divided clock
	  .D1				(eds_data_2[5])		,
	  .D2				(eds_data_2[4])		,
	  .D3				(eds_data_2[3])		,
	  .D4				(eds_data_2[2])		,
	  .D5				(eds_data_2[1])		,
	  .D6				(eds_data_2[0])		,
	  .D7				()					,
	  .D8				()					,
	  .OCE				(1'b1)				,	// 1-bit input: Output data clock enable
	  .RST				(rst)				,	// 1-bit input: Reset
	  .SHIFTIN1			()					,
	  .SHIFTIN2			()					,
	  .T1				(1'b0)				,
	  .T2				(1'b0)				,
	  .T3				(1'b0)				,
	  .T4				(1'b0)				,
	  .TBYTEIN			(1'b0)				,	// 1-bit input: Byte group tristate
	  .TCE				(1'b0)              	// 1-bit input: 3-state clock enable
);

OSERDESE2 #(
  .DATA_RATE_OQ		("DDR")		,   		// DDR, SDR
  .DATA_RATE_TQ		("DDR")		,   		// DDR, BUF, SDR
  .DATA_WIDTH		(6)			,   		// Parallel data width (2-8,10,14)
  .INIT_OQ			(1'b0)		,   		// Initial value of OQ output (1'b0,1'b1)
  .INIT_TQ			(1'b0)		,   		// Initial value of TQ output (1'b0,1'b1)
  .SERDES_MODE		("MASTER")	, 			// MASTER, SLAVE
  .SRVAL_OQ			(1'b0)		,			// OQ output value when SR is used (1'b0,1'b1)
  .SRVAL_TQ			(1'b0)		,			// TQ output value when SR is used (1'b0,1'b1)
  .TBYTE_CTL		("FALSE")	,			// Enable tristate byte operation (FALSE, TRUE)
  .TBYTE_SRC		("FALSE")	,			// Tristate byte source (FALSE, TRUE)
  .TRISTATE_WIDTH	(1)      				// 3-state converter width (1,4)
	) OSERDESE2_inst3(
	  .OFB				()					,	// 1-bit output: Feedback path for data
	  .OQ				(to_timing_eds_data[3])			,	// 1-bit output: Data path output
	  .SHIFTOUT1		()					,
	  .SHIFTOUT2		()					,
	  .TBYTEOUT			()					,   // 1-bit output: Byte group tristate
	  .TFB				()					,	// 1-bit output: 3-state control
	  .TQ				()					,	// 1-bit output: 3-state control
	  .CLK				(clk)				,	// 1-bit input: High speed clock
	  .CLKDIV			(clk_div)			,	// 1-bit input: Divided clock
	  .D1				(eds_data_3[5])		,
	  .D2				(eds_data_3[4])		,
	  .D3				(eds_data_3[3])		,
	  .D4				(eds_data_3[2])		,
	  .D5				(eds_data_3[1])		,
	  .D6				(eds_data_3[0])		,
	  .D7				()					,
	  .D8				()					,
	  .OCE				(1'b1)				,	// 1-bit input: Output data clock enable
	  .RST				(rst)				,	// 1-bit input: Reset
	  .SHIFTIN1			()					,
	  .SHIFTIN2			()					,
	  .T1				(1'b0)				,
	  .T2				(1'b0)				,
	  .T3				(1'b0)				,
	  .T4				(1'b0)				,
	  .TBYTEIN			(1'b0)				,	// 1-bit input: Byte group tristate
	  .TCE				(1'b0)              	// 1-bit input: 3-state clock enable
);

OSERDESE2 #(
  .DATA_RATE_OQ		("DDR")		,   		// DDR, SDR
  .DATA_RATE_TQ		("DDR")		,   		// DDR, BUF, SDR
  .DATA_WIDTH		(6)			,   		// Parallel data width (2-8,10,14)
  .INIT_OQ			(1'b0)		,   		// Initial value of OQ output (1'b0,1'b1)
  .INIT_TQ			(1'b0)		,   		// Initial value of TQ output (1'b0,1'b1)
  .SERDES_MODE		("MASTER")	, 			// MASTER, SLAVE
  .SRVAL_OQ			(1'b0)		,			// OQ output value when SR is used (1'b0,1'b1)
  .SRVAL_TQ			(1'b0)		,			// TQ output value when SR is used (1'b0,1'b1)
  .TBYTE_CTL		("FALSE")	,			// Enable tristate byte operation (FALSE, TRUE)
  .TBYTE_SRC		("FALSE")	,			// Tristate byte source (FALSE, TRUE)
  .TRISTATE_WIDTH	(1)      				// 3-state converter width (1,4)
	) OSERDESE2_inst4(
	  .OFB				()					,	// 1-bit output: Feedback path for data
	  .OQ				(to_timing_eds_data[4])			,	// 1-bit output: Data path output
	  .SHIFTOUT1		()					,
	  .SHIFTOUT2		()					,
	  .TBYTEOUT			()					,   // 1-bit output: Byte group tristate
	  .TFB				()					,	// 1-bit output: 3-state control
	  .TQ				()					,	// 1-bit output: 3-state control
	  .CLK				(clk)				,	// 1-bit input: High speed clock
	  .CLKDIV			(clk_div)			,	// 1-bit input: Divided clock
	  .D1				(eds_data_4[5])		,
	  .D2				(eds_data_4[4])		,
	  .D3				(eds_data_4[3])		,
	  .D4				(eds_data_4[2])		,
	  .D5				(eds_data_4[1])		,
	  .D6				(eds_data_4[0])		,
	  .D7				()					,
	  .D8				()					,
	  .OCE				(1'b1)				,	// 1-bit input: Output data clock enable
	  .RST				(rst)				,	// 1-bit input: Reset
	  .SHIFTIN1			()					,
	  .SHIFTIN2			()					,
	  .T1				(1'b0)				,
	  .T2				(1'b0)				,
	  .T3				(1'b0)				,
	  .T4				(1'b0)				,
	  .TBYTEIN			(1'b0)				,	// 1-bit input: Byte group tristate
	  .TCE				(1'b0)              	// 1-bit input: 3-state clock enable
);

OSERDESE2 #(
  .DATA_RATE_OQ		("DDR")		,   		// DDR, SDR
  .DATA_RATE_TQ		("DDR")		,   		// DDR, BUF, SDR
  .DATA_WIDTH		(6)			,   		// Parallel data width (2-8,10,14)
  .INIT_OQ			(1'b0)		,   		// Initial value of OQ output (1'b0,1'b1)
  .INIT_TQ			(1'b0)		,   		// Initial value of TQ output (1'b0,1'b1)
  .SERDES_MODE		("MASTER")	, 			// MASTER, SLAVE
  .SRVAL_OQ			(1'b0)		,			// OQ output value when SR is used (1'b0,1'b1)
  .SRVAL_TQ			(1'b0)		,			// TQ output value when SR is used (1'b0,1'b1)
  .TBYTE_CTL		("FALSE")	,			// Enable tristate byte operation (FALSE, TRUE)
  .TBYTE_SRC		("FALSE")	,			// Tristate byte source (FALSE, TRUE)
  .TRISTATE_WIDTH	(1)      				// 3-state converter width (1,4)
	) OSERDESE2_inst5(
	  .OFB				()					,	// 1-bit output: Feedback path for data
	  .OQ				(to_timing_eds_data[5])			,	// 1-bit output: Data path output
	  .SHIFTOUT1		()					,
	  .SHIFTOUT2		()					,
	  .TBYTEOUT			()					,   // 1-bit output: Byte group tristate
	  .TFB				()					,	// 1-bit output: 3-state control
	  .TQ				()					,	// 1-bit output: 3-state control
	  .CLK				(clk)				,	// 1-bit input: High speed clock
	  .CLKDIV			(clk_div)			,	// 1-bit input: Divided clock
	  .D1				(eds_data_5[5])		,
	  .D2				(eds_data_5[4])		,
	  .D3				(eds_data_5[3])		,
	  .D4				(eds_data_5[2])		,
	  .D5				(eds_data_5[1])		,
	  .D6				(eds_data_5[0])		,
	  .D7				()					,
	  .D8				()					,
	  .OCE				(1'b1)				,	// 1-bit input: Output data clock enable
	  .RST				(rst)				,	// 1-bit input: Reset
	  .SHIFTIN1			()					,
	  .SHIFTIN2			()					,
	  .T1				(1'b0)				,
	  .T2				(1'b0)				,
	  .T3				(1'b0)				,
	  .T4				(1'b0)				,
	  .TBYTEIN			(1'b0)				,	// 1-bit input: Byte group tristate
	  .TCE				(1'b0)              	// 1-bit input: 3-state clock enable
);

OSERDESE2 #(
  .DATA_RATE_OQ		("DDR")		,   		// DDR, SDR
  .DATA_RATE_TQ		("DDR")		,   		// DDR, BUF, SDR
  .DATA_WIDTH		(6)			,   		// Parallel data width (2-8,10,14)
  .INIT_OQ			(1'b0)		,   		// Initial value of OQ output (1'b0,1'b1)
  .INIT_TQ			(1'b0)		,   		// Initial value of TQ output (1'b0,1'b1)
  .SERDES_MODE		("MASTER")	, 			// MASTER, SLAVE
  .SRVAL_OQ			(1'b0)		,			// OQ output value when SR is used (1'b0,1'b1)
  .SRVAL_TQ			(1'b0)		,			// TQ output value when SR is used (1'b0,1'b1)
  .TBYTE_CTL		("FALSE")	,			// Enable tristate byte operation (FALSE, TRUE)
  .TBYTE_SRC		("FALSE")	,			// Tristate byte source (FALSE, TRUE)
  .TRISTATE_WIDTH	(1)      				// 3-state converter width (1,4)
	) OSERDESE2_inst6(
	  .OFB				()					,	// 1-bit output: Feedback path for data
	  .OQ				(to_timing_eds_data[6])			,	// 1-bit output: Data path output
	  .SHIFTOUT1		()					,
	  .SHIFTOUT2		()					,
	  .TBYTEOUT			()					,   // 1-bit output: Byte group tristate
	  .TFB				()					,	// 1-bit output: 3-state control
	  .TQ				()					,	// 1-bit output: 3-state control
	  .CLK				(clk)				,	// 1-bit input: High speed clock
	  .CLKDIV			(clk_div)			,	// 1-bit input: Divided clock
	  .D1				(eds_data_6[5])		,
	  .D2				(eds_data_6[4])		,
	  .D3				(eds_data_6[3])		,
	  .D4				(eds_data_6[2])		,
	  .D5				(eds_data_6[1])		,
	  .D6				(eds_data_6[0])		,
	  .D7				()					,
	  .D8				()					,
	  .OCE				(1'b1)				,	// 1-bit input: Output data clock enable
	  .RST				(rst)				,	// 1-bit input: Reset
	  .SHIFTIN1			()					,
	  .SHIFTIN2			()					,
	  .T1				(1'b0)				,
	  .T2				(1'b0)				,
	  .T3				(1'b0)				,
	  .T4				(1'b0)				,
	  .TBYTEIN			(1'b0)				,	// 1-bit input: Byte group tristate
	  .TCE				(1'b0)              	// 1-bit input: 3-state clock enable
);

OSERDESE2 #(
  .DATA_RATE_OQ		("DDR")		,   		// DDR, SDR
  .DATA_RATE_TQ		("DDR")		,   		// DDR, BUF, SDR
  .DATA_WIDTH		(6)			,   		// Parallel data width (2-8,10,14)
  .INIT_OQ			(1'b0)		,   		// Initial value of OQ output (1'b0,1'b1)
  .INIT_TQ			(1'b0)		,   		// Initial value of TQ output (1'b0,1'b1)
  .SERDES_MODE		("MASTER")	, 			// MASTER, SLAVE
  .SRVAL_OQ			(1'b0)		,			// OQ output value when SR is used (1'b0,1'b1)
  .SRVAL_TQ			(1'b0)		,			// TQ output value when SR is used (1'b0,1'b1)
  .TBYTE_CTL		("FALSE")	,			// Enable tristate byte operation (FALSE, TRUE)
  .TBYTE_SRC		("FALSE")	,			// Tristate byte source (FALSE, TRUE)
  .TRISTATE_WIDTH	(1)      				// 3-state converter width (1,4)
	) OSERDESE2_inst7(
	  .OFB				()					,	// 1-bit output: Feedback path for data
	  .OQ				(to_timing_eds_data[7])			,	// 1-bit output: Data path output
	  .SHIFTOUT1		()					,
	  .SHIFTOUT2		()					,
	  .TBYTEOUT			()					,   // 1-bit output: Byte group tristate
	  .TFB				()					,	// 1-bit output: 3-state control
	  .TQ				()					,	// 1-bit output: 3-state control
	  .CLK				(clk)				,	// 1-bit input: High speed clock
	  .CLKDIV			(clk_div)			,	// 1-bit input: Divided clock
	  .D1				(eds_data_7[5])		,
	  .D2				(eds_data_7[4])		,
	  .D3				(eds_data_7[3])		,
	  .D4				(eds_data_7[2])		,
	  .D5				(eds_data_7[1])		,
	  .D6				(eds_data_7[0])		,
	  .D7				()					,
	  .D8				()					,
	  .OCE				(1'b1)				,	// 1-bit input: Output data clock enable
	  .RST				(rst)				,	// 1-bit input: Reset
	  .SHIFTIN1			()					,
	  .SHIFTIN2			()					,
	  .T1				(1'b0)				,
	  .T2				(1'b0)				,
	  .T3				(1'b0)				,
	  .T4				(1'b0)				,
	  .TBYTEIN			(1'b0)				,	// 1-bit input: Byte group tristate
	  .TCE				(1'b0)              	// 1-bit input: 3-state clock enable
);

//////////////////////////////////////////
localparam		TIMEOUT_LENGTH	=	16'd68;	// > 200M/50M * 16

reg		[3:0]	rx_state;
reg		[15:0]	rx_clk_cnt;
reg		[15:0]	timeout_cnt;

reg				rx_en_temp;
reg		[15:0]	rx_data_temp;

reg				to_spi_clk_reg1;
reg				to_spi_clk_reg2;
wire			up_edge_to_spi_clk;

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		to_spi_clk_reg1	<=	1'b0;
		to_spi_clk_reg2	<=	1'b0;
	end
	else begin
		to_spi_clk_reg1	<=	to_spi_clk;
		to_spi_clk_reg2	<=	to_spi_clk_reg1;
	end
end
assign		up_edge_to_spi_clk		= 	to_spi_clk_reg1 && (~to_spi_clk_reg2);

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		rx_state	<=	'd0;
	end
	else begin
		case(rx_state)
		4'd0: begin
			if(up_edge_to_spi_clk)begin
				rx_state	<=	'd1;
			end
			else begin
				rx_state	<=	'd0;
			end
		end
		4'd1: begin
			if(timeout_cnt == TIMEOUT_LENGTH) begin
				rx_state	<=	'd0;
			end
			else if(up_edge_to_spi_clk && (rx_clk_cnt == 'd15))begin
				rx_state	<=	'd0;
			end
			else begin
				rx_state	<=	'd1;
			end
		end
		default: begin
			rx_state	<=	'd0;
		end
		endcase
	end
end


always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		rx_data_temp<=	'd0;
		rx_en_temp	<=	1'b0;
		rx_clk_cnt	<=	'd0;
		timeout_cnt	<=	'd0;
	end
	else begin
		case(rx_state)
		4'd0: begin
			rx_en_temp	<=	1'b0;
			timeout_cnt	<=	'd0;
			if(up_edge_to_spi_clk) begin
				rx_data_temp<=	{rx_data_temp[14:0],to_spi_mosi};
				rx_clk_cnt	<=	rx_clk_cnt + 1'd1;
			end
			else begin
				rx_data_temp<=	rx_data_temp;
				rx_clk_cnt	<=	'd0;
			end
		end
		4'd1: begin
			if(timeout_cnt == TIMEOUT_LENGTH) begin
				rx_data_temp<=	'd0;
				rx_clk_cnt	<=	'd0;
				rx_en_temp	<=	1'b0;
				timeout_cnt	<=	'd0;
			end
			else if(up_edge_to_spi_clk && (rx_clk_cnt == 'd15))begin
				rx_data_temp<=	{rx_data_temp[14:0],to_spi_mosi};
				rx_clk_cnt	<=	'd0;
				rx_en_temp	<=	1'b1;
				timeout_cnt	<=	'd0;
			end
			else if(up_edge_to_spi_clk) begin
				rx_data_temp<=	{rx_data_temp[14:0],to_spi_mosi};
				rx_clk_cnt	<=	rx_clk_cnt + 1'd1;
				rx_en_temp	<=	1'b0;
				timeout_cnt	<=	timeout_cnt + 1'd1;
			end
			else begin
				rx_data_temp<=	rx_data_temp;
				rx_clk_cnt	<=	rx_clk_cnt;
				rx_en_temp	<=	1'b0;
				timeout_cnt	<=	timeout_cnt + 1'd1;
			end
		end
		default: begin
			rx_data_temp<=	'd0;
			rx_en_temp	<=	1'b0;
			rx_clk_cnt	<=	'd0;
			timeout_cnt	<=	'd0;
		end
		endcase
	end
end

///////////////////////////////////////
reg		[3:0]	eds_power_en_state;

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		eds_power_en_state	<=	'd0;
	end
	else begin
		case(eds_power_en_state)
		4'd0: begin
			if(rx_en_temp && (rx_data_temp == 'h55aa))begin
				eds_power_en_state	<=	'd1;
			end
			else begin
				eds_power_en_state	<=	'd0;
			end
		end
		4'd1: begin
			if(rx_en_temp && (rx_data_temp == 'h0001)) begin
				eds_power_en_state	<=	'd2;
			end
			else if(rx_en_temp) begin
				eds_power_en_state	<=	'd0;
			end
			else begin
				eds_power_en_state	<=	eds_power_en_state;
			end
		end
		4'd2: begin
			if(rx_en_temp) begin
				eds_power_en_state	<=	'd0;
			end
			else begin
				eds_power_en_state	<=	eds_power_en_state;
			end
		end
		default: begin
			eds_power_en_state	<=	'd0;
		end
		endcase
	end
end

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		eds_power_en	<=	1'b0;
	end
	else begin
		case(eds_power_en_state)
		4'd2: begin
			if(rx_en_temp && (rx_data_temp == 'h0001)) begin
				eds_power_en	<=	1'b1;
			end
			else if(rx_en_temp && (rx_data_temp == 'h0000)) begin
				eds_power_en	<=	1'b0;
			end
			else begin
				eds_power_en	<=	eds_power_en;
			end
		end
		default: begin
			eds_power_en	<=	eds_power_en;
		end
		endcase
	end
end

///////////////////////////////////////
reg		[3:0]	eds_frame_en_state;
reg		[15:0]	delay_cnt;

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		eds_frame_en_state	<=	'd0;
	end
	else begin
		case(eds_frame_en_state)
		4'd0: begin
			if(rx_en_temp && (rx_data_temp == 'h55aa))begin
				eds_frame_en_state	<=	'd1;
			end
			else begin
				eds_frame_en_state	<=	'd0;
			end
		end
		4'd1: begin
			if(rx_en_temp && (rx_data_temp == 'h0002)) begin
				eds_frame_en_state	<=	'd2;
			end
			else if(rx_en_temp) begin
				eds_frame_en_state	<=	'd0;
			end
			else begin
				eds_frame_en_state	<=	eds_frame_en_state;
			end
		end
		4'd2: begin
			if(rx_en_temp && (rx_data_temp == 'h0001)) begin
				eds_frame_en_state	<=	eds_frame_en_state + 1'd1;
			end
			else if(rx_en_temp) begin
				eds_frame_en_state	<=	'd0;
			end
			else begin
				eds_frame_en_state	<=	eds_frame_en_state;
			end
		end
		4'd3: begin
			if(delay_cnt == 'd600) begin
				eds_frame_en_state	<=	'd0;
			end
			else begin
				eds_frame_en_state	<=	eds_frame_en_state;
			end
		end		
		default: begin
			eds_frame_en_state	<=	'd0;
		end
		endcase
	end
end

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		eds_frame_en	<=	1'b0;
		clear_buffer	<=	1'b0;
		delay_cnt		<=	'd0;
	end
	else begin
		case(eds_frame_en_state)
		4'd2: begin
			clear_buffer	<=	1'b0;
			delay_cnt		<=	'd0;
			if(rx_en_temp && (rx_data_temp == 'h0000)) begin
				eds_frame_en	<=	1'b0;
			end
			else begin
				eds_frame_en	<=	eds_frame_en;
			end
		end
		4'd3: begin
			if(delay_cnt == 'd600) begin
				eds_frame_en	<=	1'b1;
				delay_cnt		<=	'd0;
			end
			else begin
				eds_frame_en	<=	1'b0;
				delay_cnt		<=	delay_cnt + 1'd1;
			end
			
			if(delay_cnt <= 'd60) begin
				clear_buffer	<=	1'b1;
			end
			else begin
				clear_buffer	<=	1'b0;
			end
		end
		default: begin
			eds_frame_en	<=	eds_frame_en;
			clear_buffer	<=	1'b0;
			delay_cnt		<=	'd0;
		end
		endcase
	end
end

///////////////////////////////////////
reg		[3:0]	texp_time_state;
reg		[31:0]	texp_time_temp;

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		texp_time_state	<=	'd0;
	end
	else begin
		case(texp_time_state)
		4'd0: begin
			if(rx_en_temp && (rx_data_temp == 'h55aa))begin
				texp_time_state	<=	'd1;
			end
			else begin
				texp_time_state	<=	'd0;
			end
		end
		4'd1: begin
			if(rx_en_temp && (rx_data_temp == 'h0003)) begin
				texp_time_state	<=	'd2;
			end
			else if(rx_en_temp) begin
				texp_time_state	<=	'd0;
			end
			else begin
				texp_time_state	<=	texp_time_state;
			end
		end
		4'd2: begin
			if(rx_en_temp) begin
				texp_time_state	<=	'd3;
			end
			else begin
				texp_time_state	<=	texp_time_state;
			end
		end
		4'd3: begin
			if(rx_en_temp) begin
				texp_time_state	<=	'd0;
			end
			else begin
				texp_time_state	<=	texp_time_state;
			end
		end
		default: begin
			texp_time_state	<=	'd0;
		end
		endcase
	end
end

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		texp_time_temp	<=	'd0;
		texp_time		<=	'd660;
	end
	else begin
		case(texp_time_state)
		4'd2: begin
			if(rx_en_temp) begin
				texp_time_temp	<=	{rx_data_temp,texp_time_temp[15:0]};
				texp_time		<=	texp_time;
			end
			else begin
				texp_time_temp	<=	texp_time_temp;
				texp_time		<=	texp_time;
			end
		end
		4'd3: begin
			if(rx_en_temp) begin
				texp_time_temp	<=	'd0;
				texp_time		<=	{texp_time_temp[31:16],rx_data_temp};
			end
			else begin
				texp_time_temp	<=	texp_time_temp;
				texp_time		<=	texp_time;
			end
		end
		default: begin
			texp_time_temp	<=	texp_time_temp;
			texp_time		<=	texp_time;
		end
		endcase
	end
end

///////////////////////////////////////
reg		[3:0]	frame_to_frame_time_state;
reg		[31:0]	frame_to_frame_time_temp;

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		frame_to_frame_time_state	<=	'd0;
	end
	else begin
		case(frame_to_frame_time_state)
		4'd0: begin
			if(rx_en_temp && (rx_data_temp == 'h55aa))begin
				frame_to_frame_time_state	<=	'd1;
			end
			else begin
				frame_to_frame_time_state	<=	'd0;
			end
		end
		4'd1: begin
			if(rx_en_temp && (rx_data_temp == 'h0004)) begin
				frame_to_frame_time_state	<=	'd2;
			end
			else if(rx_en_temp) begin
				frame_to_frame_time_state	<=	'd0;
			end
			else begin
				frame_to_frame_time_state	<=	frame_to_frame_time_state;
			end
		end
		4'd2: begin
			if(rx_en_temp) begin
				frame_to_frame_time_state	<=	'd3;
			end
			else begin
				frame_to_frame_time_state	<=	frame_to_frame_time_state;
			end
		end
		4'd3: begin
			if(rx_en_temp) begin
				frame_to_frame_time_state	<=	'd0;
			end
			else begin
				frame_to_frame_time_state	<=	frame_to_frame_time_state;
			end
		end
		default: begin
			frame_to_frame_time_state	<=	'd0;
		end
		endcase
	end
end

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		frame_to_frame_time_temp	<=	'd0;
		frame_to_frame_time			<=	'd4750;//'d1520;		76M/48K*3
	end
	else begin
		case(frame_to_frame_time_state)
		4'd2: begin
			if(rx_en_temp) begin
				frame_to_frame_time_temp	<=	{rx_data_temp,frame_to_frame_time_temp[15:0]};
				frame_to_frame_time			<=	frame_to_frame_time;
			end
			else begin
				frame_to_frame_time_temp	<=	frame_to_frame_time_temp;
				frame_to_frame_time			<=	frame_to_frame_time;
			end
		end
		4'd3: begin
			if(rx_en_temp) begin
				frame_to_frame_time_temp	<=	'd0;
				frame_to_frame_time			<=	{frame_to_frame_time_temp[31:16],rx_data_temp};
			end
			else begin
				frame_to_frame_time_temp	<=	frame_to_frame_time_temp;
				frame_to_frame_time			<=	frame_to_frame_time;
			end
		end
		default: begin
			frame_to_frame_time_temp	<=	frame_to_frame_time_temp;
			frame_to_frame_time			<=	frame_to_frame_time;
		end
		endcase
	end
end

///////////////////////////////////////
reg		[3:0]	test_en_state;

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		test_en_state	<=	'd0;
	end
	else begin
		case(test_en_state)
		4'd0: begin
			if(rx_en_temp && (rx_data_temp == 'h55aa))begin
				test_en_state	<=	'd1;
			end
			else begin
				test_en_state	<=	'd0;
			end
		end
		4'd1: begin
			if(rx_en_temp && (rx_data_temp == 'h0005)) begin
				test_en_state	<=	'd2;
			end
			else if(rx_en_temp) begin
				test_en_state	<=	'd0;
			end
			else begin
				test_en_state	<=	test_en_state;
			end
		end
		4'd2: begin
			if(rx_en_temp) begin
				test_en_state	<=	'd0;
			end
			else begin
				test_en_state	<=	test_en_state;
			end
		end
		default: begin
			test_en_state	<=	'd0;
		end
		endcase
	end
end

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		test_en	<=	1'b0;
	end
	else begin
		case(test_en_state)
		4'd2: begin
			if(rx_en_temp && (rx_data_temp == 'h0001)) begin
				test_en	<=	1'b1;
			end
			else if(rx_en_temp && (rx_data_temp == 'h0000)) begin
				test_en	<=	1'b0;
			end
			else begin
				test_en	<=	test_en;
			end
		end
		default: begin
			test_en	<=	test_en;
		end
		endcase
	end
end

endmodule