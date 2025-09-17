
// Description : Breaks the stream, in order that the Line header and image header 		 //
//				 begins from CH0														 //
///////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns


module hello_fpga_cxp_host_stream_breaker
#(	parameter			STREAM_WORDS	= 4,					// 
	parameter			WIDTH_S			= 2,					// 
	parameter			DEVICE			= "Arria V")			// 
(	input								clk,					// clock
	input								clrn,					// reset (active low), async
	input								srst,					// reset (active high), sync
	output 	reg	[STREAM_WORDS*36-1:0]	stream_data_out,		// Data output
	output	reg							stream_valid_out,		// Valid output
	output	reg	[WIDTH_S-1:0]			stream_empty_out,		// Empty Words output
	input								stream_ready_out,		// Ready indicator input
	input 		[STREAM_WORDS*36-1:0]	stream_data_in,			// Data input
	input		[WIDTH_S-1:0]			stream_empty_in,		// Empty Words input
	input								stream_valid_in,		// Valid input
	output								stream_ready_in);		// Ready indicator output

reg	[STREAM_WORDS*36-1:0]	 stream_data_out_pipe;
reg							stream_valid_out_pipe;
reg	[WIDTH_S-1:0]			stream_empty_out_pipe;

always @(posedge clk ) begin
	 stream_data_out <= stream_data_out_pipe;
	stream_valid_out <=stream_valid_out_pipe;
	stream_empty_out <=stream_empty_out_pipe;
end
	
localparam STATE_DATA 	= 1'b0;
localparam STATE_EXTRA 	= 1'b1;

reg 									state;
reg 			[WIDTH_S-1:0]			stream_k_position;
wire 			[WIDTH_S-1:0]			zeros_wire;
reg 			[WIDTH_S-1:0]			stream_k_position_reg;
integer 								i;
integer 								inx;
wire			[WIDTH_S:0]				empty_words_k;
wire			[WIDTH_S:0]				empty_words_next;
reg				[WIDTH_S-1:0]			stream_empty_int;
wire 			[STREAM_WORDS*9-1:0]	data_vote_out;
wire unsigned	[WIDTH_S:0]				valid_words_rx;
reg [STREAM_WORDS*36-1:0] shifted_data; // Combinational shifted data

assign	valid_words_rx		= STREAM_WORDS - stream_empty_in;				// calculate the number of valid words in the current data bus
assign	empty_words_k 		= STREAM_WORDS - stream_k_position;				// determine the empty words for output (according to k position)
assign	empty_words_next	= stream_k_position + stream_empty_in;			// determine the next empty words according to k position and empty words in
assign	stream_ready_in		= stream_ready_out & (state != STATE_EXTRA);	// ready out is high when ready in is high and we don't need another clock to process data
assign	zeros_wire			= {WIDTH_S{1'b0}};

always @(data_vote_out or valid_words_rx)
begin
	// Extract byte data for delimiters
	stream_k_position 		<= 0;
	for (i=0;i<STREAM_WORDS;i=i+1) begin
		if ((i<valid_words_rx) && (data_vote_out[i*9+:9] == 9'h17c)) begin
			stream_k_position	<= i;
		end
	end
end

// Combinational data shifting for STATE_EXTRA
    always @(*) begin
        case (stream_k_position_reg)
            4'd0:    shifted_data = stream_data_out_pipe;
            4'd1:    shifted_data = {{36{1'b0}}, stream_data_out_pipe[576-1:36]};  // Shift by 1 word
            4'd2:    shifted_data = {{72{1'b0}}, stream_data_out_pipe[576-1:72]};  // Shift by 2 words
            4'd3:    shifted_data = {{108{1'b0}}, stream_data_out_pipe[576-1:108]}; // Shift by 3 words
            4'd4:    shifted_data = {{144{1'b0}}, stream_data_out_pipe[576-1:144]}; // Shift by 4 words
            4'd5:    shifted_data = {{180{1'b0}}, stream_data_out_pipe[576-1:180]}; // Shift by 5 words
            4'd6:    shifted_data = {{216{1'b0}}, stream_data_out_pipe[576-1:216]}; // Shift by 6 words
            4'd7:    shifted_data = {{252{1'b0}}, stream_data_out_pipe[576-1:252]}; // Shift by 7 words
            4'd8:    shifted_data = {{288{1'b0}}, stream_data_out_pipe[576-1:288]}; // Shift by 8 words
            4'd9:    shifted_data = {{324{1'b0}}, stream_data_out_pipe[576-1:324]}; // Shift by 9 words
            4'd10:   shifted_data = {{360{1'b0}}, stream_data_out_pipe[576-1:360]}; // Shift by 10 words
            4'd11:   shifted_data = {{396{1'b0}}, stream_data_out_pipe[576-1:396]}; // Shift by 11 words
            4'd12:   shifted_data = {{432{1'b0}}, stream_data_out_pipe[576-1:432]}; // Shift by 12 words
            4'd13:   shifted_data = {{468{1'b0}}, stream_data_out_pipe[576-1:468]}; // Shift by 13 words
            4'd14:   shifted_data = {{504{1'b0}}, stream_data_out_pipe[576-1:504]}; // Shift by 14 words
            4'd15:   shifted_data = {{540{1'b0}}, stream_data_out_pipe[576-1:540]}; // Shift by 15 words
            default: shifted_data = stream_data_out_pipe; // No shift for invalid k
        endcase
    end

genvar gen;
generate for(gen = 0; gen < STREAM_WORDS; gen = gen + 1) begin: GEN_LOOP
	// Select the best match of four bytes to ignore single bit errors
	hello_fpga_cxp_vote data_vote_i
	(	.din				(stream_data_in[gen*36+:36]),	// Data Input
		.corrected_error	(),								// 
		.uncorrected_error	(),								// 
		.dout				(data_vote_out[gen*9+:9]));		// Voted data output
end
endgenerate

initial
begin
	stream_data_out_pipe 					<= {STREAM_WORDS*36{1'b0}};
end

always @(posedge clk)
begin
	if (srst) begin
		stream_data_out_pipe 					<= {STREAM_WORDS*36{1'b0}};
	end else begin
		if (stream_ready_out) begin
			case (state)
				STATE_DATA: 
				begin
					stream_data_out_pipe 				<= stream_data_in;
				end
				
				STATE_EXTRA: 
				begin
					stream_data_out_pipe<=shifted_data;
					//inx = 0;
					//for (i=0;i<STREAM_WORDS;i=i+1) begin
					//	if (i>=stream_k_position_reg) begin
					//		stream_data_out_pipe[inx*36+:36] 	<= stream_data_out_pipe[i*36+:36];
					//		inx = inx + 1;
					//	end
					//end
				end
			endcase
		end
	end
end

always @(posedge clk or negedge clrn)
begin
	if (!clrn) begin
		state 								<= STATE_DATA;
	//	stream_data_out_pipe 					<= {STREAM_WORDS*36{1'b0}};
		stream_valid_out_pipe 					<= 1'b0;
		stream_empty_out_pipe					<= {WIDTH_S{1'b0}};
		stream_empty_int					<= {WIDTH_S{1'b0}};
		stream_k_position_reg				<= {WIDTH_S{1'b0}};
	end else begin
		if (srst) begin	// when sync reset, reset all outputs
			state 								<= STATE_DATA;
		//	stream_data_out_pipe 					<= {STREAM_WORDS*36{1'b0}};
			stream_valid_out_pipe 					<= 1'b0;
			stream_empty_out_pipe					<= {WIDTH_S{1'b0}};
			stream_empty_int					<= {WIDTH_S{1'b0}};
			stream_k_position_reg				<= {WIDTH_S{1'b0}};
		end else begin
			if (stream_ready_out) begin
				stream_valid_out_pipe 					<= 1'b0;
				case (state)
					STATE_DATA: 
					begin
						stream_k_position_reg			<= stream_k_position;
					//	stream_data_out_pipe 				<= stream_data_in;
						stream_empty_int				<= empty_words_next[WIDTH_S-1:0];
						if (stream_valid_in) begin
							stream_valid_out_pipe 			<= 1'b1;
							if ((STREAM_WORDS > 1) && (stream_k_position != zeros_wire)) begin // Detected delimiter
								state 					<= STATE_EXTRA;
								stream_empty_out_pipe		<= (STREAM_WORDS > 1) ? empty_words_k[WIDTH_S-1:0] : 1'b0;
							end else begin
								stream_empty_out_pipe		<= (STREAM_WORDS > 1) ? stream_empty_in : 1'b0;
							end
						end
					end
					
					STATE_EXTRA: // Send the shifted data
					begin
						state 							<= STATE_DATA;
						stream_valid_out_pipe 				<= 1'b1;
						stream_empty_out_pipe				<= (STREAM_WORDS > 1) ? stream_empty_int : 1'b0;
						
					//	inx = 0;
					//	for (i=0;i<STREAM_WORDS;i=i+1) begin
					//		if (i>=stream_k_position_reg) begin
					//			stream_data_out_pipe[inx*36+:36] 	<= stream_data_out_pipe[i*36+:36];
					//			inx = inx + 1;
					//		end
					//	end
					end
				endcase
			end
		end	
	end
end


endmodule

