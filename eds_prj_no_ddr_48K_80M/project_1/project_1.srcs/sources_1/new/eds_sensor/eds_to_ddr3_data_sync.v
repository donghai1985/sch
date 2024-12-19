`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: eds_to_ddr3_data_sync
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


module eds_to_ddr3_data_sync#(                                  
	parameter lvds_pairs                = 6       
)(
		input	wire		clk_76m,		//76M
		input	wire		ddr_ui_clk,
		input	wire		rst,
		
		input	wire		eds_power_en,
		input	wire		eds_frame_en,
		input	wire		clear_buffer,

		input	wire						eds_sensor_data_en,
		input	wire [lvds_pairs*12-1:0]	eds_sensor_data,
		
		output	reg			eds_data_wr_en,
		output	reg  [127:0]eds_data_wr_data,
		
		output	reg			down_edge_eds_frame_en_exp
		
		// input	wire		ddr_wr_en,
		// output	wire [127:0]ddr_wr_data,
		// output	wire [11:0]	ddr_wr_data_count
);

localparam		LENGTH	=	9'd44;		//	352/8=44

reg				eds_data_fifo_rd_en_0;
reg				eds_data_fifo_rd_en_1;
reg				eds_data_fifo_rd_en_2;
reg				eds_data_fifo_rd_en_3;
reg				eds_data_fifo_rd_en_4;
reg				eds_data_fifo_rd_en_5;

wire [127:0]	eds_data_fifo_dout_0;
wire [127:0]	eds_data_fifo_dout_1;
wire [127:0]	eds_data_fifo_dout_2;
wire [127:0]	eds_data_fifo_dout_3;
wire [127:0]	eds_data_fifo_dout_4;
wire [127:0]	eds_data_fifo_dout_5;

wire [8:0]		eds_data_fifo_rd_count_0;

// reg				eds_data_wr_en;
// reg  [127:0]	eds_data_wr_data;

wire [127:0]	ddr_wr_data_temp;

reg				eds_power_en_reg1;
reg				eds_power_en_reg2;
reg				eds_frame_en_reg1;
reg				eds_frame_en_reg2;
reg				clear_buffer_reg1;
reg				clear_buffer_reg2;
wire			down_edge_eds_frame_en;

reg	[15:0]		down_edge_eds_frame_en_exp_cnt;

reg	[3:0]		state;
reg	[15:0]		data_cnt;



always @(posedge ddr_ui_clk or posedge rst)
begin
	if(rst) begin
		eds_power_en_reg1	<=	1'b0;
		eds_power_en_reg2	<=	1'b0;
		eds_frame_en_reg1	<=	1'b0;
		eds_frame_en_reg2	<=	1'b0;
		clear_buffer_reg1	<=	1'b0;
		clear_buffer_reg2	<=	1'b0;
	end
	else begin
		eds_power_en_reg1	<=	eds_power_en;
		eds_power_en_reg2	<=	eds_power_en_reg1;
		eds_frame_en_reg1	<=	eds_frame_en;
		eds_frame_en_reg2	<=	eds_frame_en_reg1;
		clear_buffer_reg1	<=	clear_buffer;
		clear_buffer_reg2	<=	clear_buffer_reg1;
	end
end

assign	down_edge_eds_frame_en = (~eds_frame_en_reg1) && eds_frame_en_reg2;

always @(posedge ddr_ui_clk or posedge rst)
begin
	if(rst) begin
		down_edge_eds_frame_en_exp		<=	1'b0;
		down_edge_eds_frame_en_exp_cnt	<=	'd0;
	end
	else if(down_edge_eds_frame_en) begin
		down_edge_eds_frame_en_exp		<=	1'b1;
		down_edge_eds_frame_en_exp_cnt	<=	'd0;
	end
	else if(down_edge_eds_frame_en_exp_cnt == 'd50) begin
		down_edge_eds_frame_en_exp		<=	1'b0;
		down_edge_eds_frame_en_exp_cnt	<=	'd0;
	end
	else if(down_edge_eds_frame_en_exp) begin
		down_edge_eds_frame_en_exp		<=	1'b1;
		down_edge_eds_frame_en_exp_cnt	<=	down_edge_eds_frame_en_exp_cnt + 1'd1;
	end
	else begin
		down_edge_eds_frame_en_exp		<=	1'b0;
		down_edge_eds_frame_en_exp_cnt	<=	'd0;
	end
end
		

eds_data_fifo	eds_data_fifo_inst0(
		.rst(rst || (~eds_power_en_reg2) || clear_buffer_reg2 || down_edge_eds_frame_en_exp),
		.wr_clk(clk_76m),
		.rd_clk(ddr_ui_clk),
		.din({4'd0,eds_sensor_data[11:0]}),
		.wr_en(eds_sensor_data_en),
		.rd_en(eds_data_fifo_rd_en_0),
		.dout(eds_data_fifo_dout_0),
		.full(),
		.empty(),
		.rd_data_count(eds_data_fifo_rd_count_0)
);

eds_data_fifo	eds_data_fifo_inst1(
		.rst(rst || (~eds_power_en_reg2) || clear_buffer_reg2 || down_edge_eds_frame_en_exp),
		.wr_clk(clk_76m),
		.rd_clk(ddr_ui_clk),
		.din({4'd0,eds_sensor_data[23:12]}),
		.wr_en(eds_sensor_data_en),
		.rd_en(eds_data_fifo_rd_en_1),
		.dout(eds_data_fifo_dout_1),
		.full(),
		.empty(),
		.rd_data_count()
);

eds_data_fifo	eds_data_fifo_inst2(
		.rst(rst || (~eds_power_en_reg2) || clear_buffer_reg2 || down_edge_eds_frame_en_exp),
		.wr_clk(clk_76m),
		.rd_clk(ddr_ui_clk),
		.din({4'd0,eds_sensor_data[35:24]}),
		.wr_en(eds_sensor_data_en),
		.rd_en(eds_data_fifo_rd_en_2),
		.dout(eds_data_fifo_dout_2),
		.full(),
		.empty(),
		.rd_data_count()
);

eds_data_fifo	eds_data_fifo_inst3(
		.rst(rst || (~eds_power_en_reg2) || clear_buffer_reg2 || down_edge_eds_frame_en_exp),
		.wr_clk(clk_76m),
		.rd_clk(ddr_ui_clk),
		.din({4'd0,eds_sensor_data[47:36]}),
		.wr_en(eds_sensor_data_en),
		.rd_en(eds_data_fifo_rd_en_3),
		.dout(eds_data_fifo_dout_3),
		.full(),
		.empty(),
		.rd_data_count()
);

eds_data_fifo	eds_data_fifo_inst4(
		.rst(rst || (~eds_power_en_reg2) || clear_buffer_reg2 || down_edge_eds_frame_en_exp),
		.wr_clk(clk_76m),
		.rd_clk(ddr_ui_clk),
		.din({4'd0,eds_sensor_data[59:48]}),
		.wr_en(eds_sensor_data_en),
		.rd_en(eds_data_fifo_rd_en_4),
		.dout(eds_data_fifo_dout_4),
		.full(),
		.empty(),
		.rd_data_count()
);

eds_data_fifo	eds_data_fifo_inst5(
		.rst(rst || (~eds_power_en_reg2) || clear_buffer_reg2 || down_edge_eds_frame_en_exp),
		.wr_clk(clk_76m),
		.rd_clk(ddr_ui_clk),
		.din({4'd0,eds_sensor_data[71:60]}),
		.wr_en(eds_sensor_data_en),
		.rd_en(eds_data_fifo_rd_en_5),
		.dout(eds_data_fifo_dout_5),
		.full(),
		.empty(),
		.rd_data_count()
);


always @(posedge ddr_ui_clk or posedge rst)
begin
	if(rst) begin
		state	<=	'd0;
	end
	else if(~eds_power_en_reg2) begin
		state	<=	'd0;
	end
	else if(~eds_frame_en_reg2) begin
		state	<=	'd0;
	end
	else begin
		case(state)
		4'd0: begin
			if(eds_data_fifo_rd_count_0 == LENGTH) begin
				state	<=	state + 1'd1;
			end
			else begin
				state	<=	'd0;
			end
		end
		4'd1: begin
			if(data_cnt == 'd263) begin
				state	<=	'd0;
			end
			else begin
				state	<=	state;
			end
		end
		default: begin
			state	<=	'd0;
		end
		endcase
	end
end

always @(posedge ddr_ui_clk or posedge rst)
begin
	if(rst) begin
		eds_data_fifo_rd_en_0	<=	1'b0;
		eds_data_fifo_rd_en_1	<=	1'b0;
		eds_data_fifo_rd_en_2	<=	1'b0;
		eds_data_fifo_rd_en_3	<=	1'b0;
		eds_data_fifo_rd_en_4	<=	1'b0;
		eds_data_fifo_rd_en_5	<=	1'b0;
		eds_data_wr_en			<=	1'b0;
		eds_data_wr_data		<=	'd0;
		data_cnt				<=	'd0;
	end
	else if(~eds_power_en_reg2) begin
		eds_data_fifo_rd_en_0	<=	1'b0;
		eds_data_fifo_rd_en_1	<=	1'b0;
		eds_data_fifo_rd_en_2	<=	1'b0;
		eds_data_fifo_rd_en_3	<=	1'b0;
		eds_data_fifo_rd_en_4	<=	1'b0;
		eds_data_fifo_rd_en_5	<=	1'b0;
		eds_data_wr_en			<=	1'b0;
		eds_data_wr_data		<=	'd0;
		data_cnt				<=	'd0;
	end
	else if(~eds_frame_en_reg2) begin
		eds_data_fifo_rd_en_0	<=	1'b0;
		eds_data_fifo_rd_en_1	<=	1'b0;
		eds_data_fifo_rd_en_2	<=	1'b0;
		eds_data_fifo_rd_en_3	<=	1'b0;
		eds_data_fifo_rd_en_4	<=	1'b0;
		eds_data_fifo_rd_en_5	<=	1'b0;
		eds_data_wr_en			<=	1'b0;
		eds_data_wr_data		<=	'd0;
		data_cnt				<=	'd0;
	end
	else begin
		case(state)
		4'd0: begin
			eds_data_fifo_rd_en_1	<=	1'b0;
			eds_data_fifo_rd_en_2	<=	1'b0;
			eds_data_fifo_rd_en_3	<=	1'b0;
			eds_data_fifo_rd_en_4	<=	1'b0;
			eds_data_fifo_rd_en_5	<=	1'b0;
			eds_data_wr_en			<=	1'b0;
			eds_data_wr_data		<=	'd0;
			data_cnt				<=	'd0;
			if(eds_data_fifo_rd_count_0 == LENGTH) begin
				eds_data_fifo_rd_en_0	<=	1'b1;
			end
			else begin
				eds_data_fifo_rd_en_0	<=	1'b0;
			end
		end
		4'd1: begin
			eds_data_fifo_rd_en_0	<=	1'b0;
			eds_data_fifo_rd_en_1	<=	1'b0;
			eds_data_fifo_rd_en_2	<=	1'b0;
			eds_data_fifo_rd_en_3	<=	1'b0;
			eds_data_fifo_rd_en_4	<=	1'b0;
			eds_data_fifo_rd_en_5	<=	1'b0;
			data_cnt				<=	data_cnt + 1'd1;
			if(data_cnt == 'd0) begin
				eds_data_fifo_rd_en_0	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	{2'b11,eds_data_fifo_dout_0[125:0]};
			end
			else if(data_cnt < 'd43) begin
				eds_data_fifo_rd_en_0	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_0;
			end
			else if(data_cnt == 'd43) begin
				eds_data_fifo_rd_en_1	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_0;
			end
			else if(data_cnt < 'd87) begin
				eds_data_fifo_rd_en_1	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_1;
			end
			else if(data_cnt == 'd87) begin
				eds_data_fifo_rd_en_2	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_1;
			end
			else if(data_cnt < 'd131) begin
				eds_data_fifo_rd_en_2	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_2;
			end
			else if(data_cnt == 'd131) begin
				eds_data_fifo_rd_en_3	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_2;
			end
			else if(data_cnt < 'd175) begin
				eds_data_fifo_rd_en_3	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_3;
			end
			else if(data_cnt == 'd175) begin
				eds_data_fifo_rd_en_4	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_3;
			end
			else if(data_cnt < 'd219) begin
				eds_data_fifo_rd_en_4	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_4;
			end
			else if(data_cnt == 'd219) begin
				eds_data_fifo_rd_en_5	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_4;
			end
			else if(data_cnt <= 'd255) begin
				eds_data_fifo_rd_en_5	<=	1'b1;
				eds_data_wr_en			<=	1'b1;
				eds_data_wr_data		<=	eds_data_fifo_dout_5;
			end
			else if(data_cnt < 'd263) begin
				eds_data_fifo_rd_en_5	<=	1'b1;
				eds_data_wr_en			<=	1'b0;
				eds_data_wr_data		<=	'd0;
			end
			else begin
				eds_data_wr_en			<=	1'b0;
				eds_data_wr_data		<=	'd0;
			end
		end
		default: begin
			eds_data_fifo_rd_en_0	<=	1'b0;
			eds_data_fifo_rd_en_1	<=	1'b0;
			eds_data_fifo_rd_en_2	<=	1'b0;
			eds_data_fifo_rd_en_3	<=	1'b0;
			eds_data_fifo_rd_en_4	<=	1'b0;
			eds_data_fifo_rd_en_5	<=	1'b0;
			eds_data_wr_en			<=	1'b0;
			eds_data_wr_data		<=	'd0;
			data_cnt				<=	'd0;
		end
		endcase
	end
end

// eds_to_ddr3_fifo eds_to_ddr3_fifo_inst(
		// .rst(rst || (~eds_power_en_reg2) || clear_buffer_reg2),
		// .wr_clk(ddr_ui_clk),
		// .rd_clk(clk_100m_div_3),
		// .din(eds_data_wr_data),
		// .wr_en(eds_data_wr_en),
		// .rd_en(ddr_wr_en),
		// .dout(ddr_wr_data_temp),
		// .full(),
		// .empty(),
		// .rd_data_count(ddr_wr_data_count)
// );

// assign	ddr_wr_data		=	{ddr_wr_data_temp[15:0],ddr_wr_data_temp[31:16],ddr_wr_data_temp[47:32],ddr_wr_data_temp[63:48],
							// ddr_wr_data_temp[79:64],ddr_wr_data_temp[95:80],ddr_wr_data_temp[111:96],ddr_wr_data_temp[127:112]};

// ila_eds_data_wr_data	ila_eds_data_wr_data_inst(
		// .clk(ddr_ui_clk),
		// .probe0(eds_data_wr_en),
		// .probe1(eds_data_wr_data)
// ); 

endmodule
