`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: eds_sensor_spi
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


module eds_sensor_spi(
		input	wire		clk,
		input	wire		rst_n,

		output	reg			spi_cs, 
		output	reg			spi_clk, 
		output	reg			spi_mosi, 
		input	wire		spi_miso,
		
		output	reg			spi_cfg_ok,
		
		input	wire		cfg_data_en,
		input 	wire [23:0]	cfg_data,
		
		input	wire		wr_addr_data_en,
		input 	wire [23:0]	wr_addr_data,
		input	wire		rd_add_en,
		input 	wire [15:0]	rd_add,
		
		output	reg			rd_data_en,
		output	reg	 [7:0]	rd_data
		
);

reg	[4:0]	state;
reg [3:0]	spi_counter;
reg [5:0]	spi_clk_cnt;
reg [15:0]	delay_cnt;

reg [23:0]	cfg_data_temp;

always @(posedge clk or negedge rst_n)begin
	if(rst_n == 1'b0) begin	
		spi_counter <= 'd0;
	end
	else if(spi_cs ==1'b0) begin
		spi_counter <= 'd0;
	end
	else if(spi_counter == 'd9) begin
		spi_counter <= 'd0;
	end
	else begin
		spi_counter <= spi_counter + 'd1;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0) begin
		state	<=	'd0;
	end
	else begin
		case(state)
		5'd0: begin
			if(cfg_data_en) begin
				state	<=	'd1;
			end
			else if(wr_addr_data_en) begin
				state	<=	'd1;
			end
			else if(rd_add_en) begin
				state	<=	'd16;
			end
			else begin
				state	<=	'd0;
			end
		end
		5'd1: begin
			if((spi_counter == 'd9) && (spi_clk_cnt == 'd23)) begin
				state	<=	'd2;
			end
			else begin
				state	<=	state;
			end
		end
		5'd2: begin
			if(spi_counter == 'd4) begin
				state	<=	'd3;
			end
			else begin
				state	<=	state;
			end
		end
		5'd3: begin
			if(delay_cnt == 'd100) begin
				state	<=	'd0;
			end
			else begin
				state	<=	state;
			end
		end
		
		5'd16: begin
			if((spi_counter == 'd9) && (spi_clk_cnt == 'd15)) begin
				state	<=	'd17;
			end
			else begin
				state	<=	state;
			end
		end
		5'd17: begin
			if((spi_counter == 'd9) && (spi_clk_cnt == 'd23)) begin
				state	<=	'd18;
			end
			else begin
				state	<=	state;
			end
		end
		5'd18: begin
			if(spi_counter == 'd4) begin
				state	<=	'd19;
			end
			else begin
				state	<=	state;
			end
		end
		5'd19: begin
			if(delay_cnt == 'd100) begin
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

always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0) begin
		spi_cs			<=	1'b0;
		spi_clk			<=	1'b0;
		spi_mosi		<=	1'b0;
		
		spi_clk_cnt		<=	6'd0;
		cfg_data_temp  	<=  'd0;

		spi_cfg_ok		<=	1'b0;
		rd_data_en 		<=  1'b0;
		rd_data			<=	'd0;
		delay_cnt		<=	'd0;
	end
	else begin
		case(state)
		5'd0: begin
			spi_clk			<=	1'b0;
			
			spi_clk_cnt		<=	6'd0;

			spi_cfg_ok		<=	1'b0;
			rd_data_en 		<=  1'b0;
			delay_cnt		<=	'd0;
			rd_data			<=	rd_data;
			if(cfg_data_en) begin
				spi_cs			<=	1'b1;
				spi_mosi		<=	cfg_data[23];
				cfg_data_temp	<=	{cfg_data[22:0],cfg_data[23]};
			end
			else if(wr_addr_data_en) begin
				spi_cs			<=	1'b1;
				spi_mosi		<=	wr_addr_data[23];
				cfg_data_temp	<=	{wr_addr_data[22:0],wr_addr_data[23]};
			end
			else if(rd_add_en) begin
				spi_cs			<=	1'b1;
				rd_data			<=	'd0;
				spi_mosi		<=	rd_add[15];
				cfg_data_temp	<=	{rd_add[14:0],8'd0,rd_add[15]};
			end
			else begin
				spi_cs			<=	1'b0;
				spi_mosi		<=	1'b0;
				cfg_data_temp	<=	'd0;
			end
		end
		5'd1: begin
			spi_cs			<=	1'b1;

			spi_cfg_ok		<=	1'b0;
			rd_data_en 		<=  1'b0;
			rd_data			<=	rd_data;
			delay_cnt		<=	'd0;
			if(spi_counter == 'd4) begin
				spi_clk			<=	1'b1;
				spi_clk_cnt		<=	spi_clk_cnt;
				spi_mosi		<=	spi_mosi;
				cfg_data_temp	<=	cfg_data_temp;
			end
			else if((spi_counter == 'd9) && (spi_clk_cnt == 'd23)) begin
				spi_clk			<=	1'b0;
				spi_clk_cnt		<=	'd0;
				spi_mosi		<=	1'b0;
				cfg_data_temp	<=	'd0;
			end
			else if(spi_counter == 'd9) begin
				spi_clk			<=	1'b0;
				spi_clk_cnt		<=	spi_clk_cnt + 6'd1;
				spi_mosi		<=	cfg_data_temp[23];
				cfg_data_temp	<=	{cfg_data_temp[22:0],cfg_data_temp[23]};
			end
			else begin
				spi_clk			<=	spi_clk;
				spi_clk_cnt		<=	spi_clk_cnt;
				spi_mosi		<=	spi_mosi;
				cfg_data_temp	<=	cfg_data_temp;
			end
		end
		5'd2: begin
			spi_clk			<=	1'b0;
			spi_mosi		<=	spi_mosi;
			
			spi_clk_cnt		<=	6'd0;
			cfg_data_temp  	<=  'd0;

			spi_cfg_ok		<=	1'b0;
			rd_data_en 		<=  1'b0;
			rd_data			<=	rd_data;
			delay_cnt		<=	'd0;
			if(spi_counter == 'd4) begin
				spi_cs			<=	1'b0;
			end
			else begin
				spi_cs			<=	1'b1;
			end
		end
		5'd3: begin
			spi_cs			<=	1'b0;
			spi_clk			<=	1'b0;
			spi_mosi		<=	1'b0;
			
			spi_clk_cnt		<=	6'd0;
			cfg_data_temp  	<=  'd0;

			rd_data_en 		<=  1'b0;
			rd_data			<=	rd_data;
			if(delay_cnt == 'd100) begin
				delay_cnt		<=	'd0;
				spi_cfg_ok		<=	1'b1;
			end
			else begin
				delay_cnt		<=	delay_cnt + 'd1;
				spi_cfg_ok		<=	1'b0;
			end
		end
		
		5'd16: begin
			spi_cs			<=	1'b1;

			spi_cfg_ok		<=	1'b0;
			rd_data_en 		<=  1'b0;
			rd_data			<=	'd0;
			delay_cnt		<=	'd0;
			if(spi_counter == 'd4) begin
				spi_clk			<=	1'b1;
				spi_clk_cnt		<=	spi_clk_cnt;
				spi_mosi		<=	spi_mosi;
				cfg_data_temp	<=	cfg_data_temp;
			end
			else if(spi_counter == 'd9) begin
				spi_clk			<=	1'b0;
				spi_clk_cnt		<=	spi_clk_cnt + 6'd1;
				spi_mosi		<=	cfg_data_temp[23];
				cfg_data_temp	<=	{cfg_data_temp[22:0],cfg_data_temp[23]};
			end
			else begin
				spi_clk			<=	spi_clk;
				spi_clk_cnt		<=	spi_clk_cnt;
				spi_mosi		<=	spi_mosi;
				cfg_data_temp	<=	cfg_data_temp;
			end
		end
		5'd17: begin
			spi_cs			<=	1'b1;
			spi_mosi		<=	1'b0;
			
			cfg_data_temp	<=	'd0;
			
			spi_cfg_ok		<=	1'b0;
			rd_data_en 		<=  1'b0;
			delay_cnt		<=	'd0;
			if(spi_counter == 'd4) begin
				spi_clk			<=	1'b1;
				spi_clk_cnt		<=	spi_clk_cnt;
				rd_data			<=	{rd_data[6:0],spi_miso};
			end
			else if((spi_counter == 'd9) && (spi_clk_cnt == 'd23)) begin
				spi_clk			<=	1'b0;
				spi_clk_cnt		<=	'd0;
				rd_data			<=	rd_data;
			end
			else if(spi_counter == 'd9) begin
				spi_clk			<=	1'b0;
				spi_clk_cnt		<=	spi_clk_cnt + 6'd1;
				rd_data			<=	rd_data;
			end
			else begin
				spi_clk			<=	spi_clk;
				spi_clk_cnt		<=	spi_clk_cnt;
				rd_data			<=	rd_data;
			end
		end
		5'd18: begin
			spi_clk			<=	1'b0;
			spi_mosi		<=	1'b0;
			
			spi_clk_cnt		<=	6'd0;
			cfg_data_temp  	<=  'd0;

			spi_cfg_ok		<=	1'b0;
			rd_data_en 		<=  1'b0;
			rd_data			<=	rd_data;
			delay_cnt		<=	'd0;
			if(spi_counter == 'd4) begin
				spi_cs			<=	1'b0;
			end
			else begin
				spi_cs			<=	1'b1;
			end
		end
		5'd19: begin
			spi_cs			<=	1'b0;
			spi_clk			<=	1'b0;
			spi_mosi		<=	1'b0;
			
			spi_clk_cnt		<=	6'd0;
			cfg_data_temp  	<=  'd0;
			rd_data			<=	rd_data;
			if(delay_cnt == 'd100) begin
				delay_cnt		<=	'd0;
				spi_cfg_ok		<=	1'b1;
				rd_data_en 		<=  1'b1;
			end
			else begin
				delay_cnt		<=	delay_cnt + 'd1;
				spi_cfg_ok		<=	1'b0;
				rd_data_en 		<=  1'b0;
			end
		end
		default: begin
			spi_cs			<=	1'b0;
			spi_clk			<=	1'b0;
			spi_mosi		<=	1'b0;
			
			spi_clk_cnt		<=	6'd0;
			cfg_data_temp  	<=  'd0;

			spi_cfg_ok		<=	1'b0;
			rd_data_en 		<=  1'b0;
			rd_data			<=	'd0;
			delay_cnt		<=	'd0;
		end
		endcase
	end
end


endmodule
