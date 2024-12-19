`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: eds_sensor_reg_cfg
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


module eds_sensor_reg_cfg(
		input	wire		clk,
		input	wire		rst,

		input	wire [1:0]	ADC_depth, 			//0:8bit, 2:12bit
		
		output	wire		spi_cs, 
		output	wire		spi_clk, 
		output	wire		spi_mosi, 
		input	wire		spi_miso,
		
		input	wire		pll_3_locked,
		output	reg			reg_cfg_ok,
		
		output	reg			cmd_start_training_init,
		
		input	wire		wr_addr_data_en,
		input 	wire [23:0]	wr_addr_data,
		input	wire		rd_add_en,
		input 	wire [15:0]	rd_add,
		
		output	wire		rd_data_en,
		output	wire [7:0]	rd_data
		
);

reg			pll_3_locked_reg1;
reg			pll_3_locked_reg2;

reg	[7:0]	cfg_rom_addra;
wire[23:0]	cfg_rom_dout;

reg	[4:0]	cfg_state;
reg	[31:0]	delay_cnt;
wire		spi_cfg_ok;

reg			cfg_data_en;
reg [23:0]	cfg_data;

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		pll_3_locked_reg1	<=	1'b0;
		pll_3_locked_reg2	<=	1'b0;
	end
	else begin
		pll_3_locked_reg1	<=	pll_3_locked;
		pll_3_locked_reg2	<=	pll_3_locked_reg1;
	end
end

eds_7um_12bit_single_line_spi_cfg_rom	eds_7um_12bit_single_line_spi_cfg_rom_inst(
	  .clka(clk),    			// input wire clka
	  .addra(cfg_rom_addra),  	// input wire [7 : 0] addra
	  .douta(cfg_rom_dout)  	// output wire [23 : 0] douta
);

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		cfg_state	<=	'd0;
	end
	else begin
		case(cfg_state)
		5'd0: begin
			if(delay_cnt == 'd500) begin	//5us
				cfg_state	<=	'd1;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd1: begin
			if(cfg_rom_addra == 'd224) begin
				cfg_state	<=	'd16;		//jump spi config2
			end
			else begin
				cfg_state	<=	'd2;
			end
		end
		5'd2: begin
			if(spi_cfg_ok) begin
				cfg_state	<=	'd1;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		
		5'd16: begin
			if(delay_cnt == 'd200000) begin	//2ms
				cfg_state	<=	'd17;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd17: begin
			cfg_state	<=	'd18;
		end
		5'd18: begin
			if(spi_cfg_ok) begin
				cfg_state	<=	'd19;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd19: begin
			if(delay_cnt == 'd200000) begin	//2ms
				cfg_state	<=	'd20;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd20: begin
			if(pll_3_locked_reg2) begin
				cfg_state	<=	'd21;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd21: begin
			if(delay_cnt == 'd10) begin
				cfg_state	<=	'd22;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd22: begin
			cfg_state	<=	cfg_state;
		end
		default: begin
			cfg_state	<=	'd0;
		end
		endcase
	end
end

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		cfg_rom_addra	<=	'd0;
		cfg_data_en		<=	1'b0;
		cfg_data		<=	'd0;
		reg_cfg_ok		<=	1'b0;
		delay_cnt		<=	'd0;
		cmd_start_training_init	<= 1'b0;
	end
	else begin
		case(cfg_state)
		5'd0: begin
			cfg_rom_addra	<=	'd0;
			cfg_data_en		<=	1'b0;
			cfg_data		<=	'd0;
			reg_cfg_ok		<=	1'b0;
			cmd_start_training_init	<= 1'b0;
			if(delay_cnt == 'd500) begin	//5us
				delay_cnt	<=	'd0;
			end
			else begin
				delay_cnt	<=	delay_cnt + 'd1;
			end
		end
		5'd1: begin
			reg_cfg_ok	<=	1'b0;
			delay_cnt	<=	'd0;
			cmd_start_training_init	<= 1'b0;
			if(cfg_rom_addra == 'd224) begin
				cfg_rom_addra	<=	'd0;
				cfg_data_en		<=	1'b0;
				cfg_data		<=	'd0;
			end
			else begin
				cfg_rom_addra	<=	cfg_rom_addra + 'd1;
				cfg_data_en		<=	1'b1;
				if(ADC_depth == 2'd2) begin
					cfg_data		<=	cfg_rom_dout;
				end
				else begin
					if(cfg_rom_addra == 8'd150)
						cfg_data		<=	24'h809618;
					else
						cfg_data		<=	cfg_rom_dout;
				end
			end
		end
		5'd2: begin
			cfg_rom_addra	<=	cfg_rom_addra;
			cfg_data_en		<=	1'b0;
			cfg_data		<=	cfg_data;
			reg_cfg_ok		<=	1'b0;
			delay_cnt		<=	'd0;
			cmd_start_training_init	<= 1'b0;
		end
		
		5'd16: begin
			cfg_rom_addra	<=	'd0;
			cfg_data_en		<=	1'b0;
			cfg_data		<=	'd0;
			reg_cfg_ok		<=	1'b0;
			cmd_start_training_init	<= 1'b0;
			if(delay_cnt == 'd200000) begin	//2ms
				delay_cnt	<=	'd0;
			end
			else begin
				delay_cnt	<=	delay_cnt + 'd1;
			end
		end
		5'd17: begin
			cfg_rom_addra	<=	'd0;
			cfg_data_en		<=	1'b1;
			cfg_data		<=	24'h809901;		//STREAM_EN set 1
			reg_cfg_ok		<=	1'b0;
			delay_cnt		<=	'd0;
			cmd_start_training_init	<= 1'b0;
		end
		5'd18: begin
			cfg_rom_addra	<=	'd0;
			cfg_data_en		<=	1'b0;
			cfg_data		<=	cfg_data;
			reg_cfg_ok		<=	1'b0;
			delay_cnt		<=	'd0;
			cmd_start_training_init	<= 1'b0;
		end
		5'd19: begin
			cfg_rom_addra	<=	'd0;
			cfg_data_en		<=	1'b0;
			cfg_data		<=	'd0;
			reg_cfg_ok		<=	1'b0;
			cmd_start_training_init	<= 1'b0;
			if(delay_cnt == 'd200000) begin	//2ms
				delay_cnt	<=	'd0;
			end
			else begin
				delay_cnt	<=	delay_cnt + 'd1;
			end
		end
		5'd20: begin
			cfg_rom_addra	<=	'd0;
			cfg_data_en		<=	1'b0;
			cfg_data		<=	'd0;
			reg_cfg_ok		<=	1'b1;
			delay_cnt		<=	'd0;
			cmd_start_training_init	<= 1'b0;
		end
		5'd21: begin
			cfg_rom_addra	<=	'd0;
			cfg_data_en		<=	1'b0;
			cfg_data		<=	'd0;
			reg_cfg_ok		<=	1'b1;
			if(delay_cnt == 'd10) begin
				cmd_start_training_init	<= 1'b0;
				delay_cnt		<=	'd0;
			end
			else begin
				cmd_start_training_init	<= 1'b1;
				delay_cnt		<=	delay_cnt + 'd1;
			end
		end
		5'd22: begin
			cfg_rom_addra	<=	'd0;
			cfg_data_en		<=	1'b0;
			cfg_data		<=	'd0;
			reg_cfg_ok		<=	1'b1;
			delay_cnt		<=	'd0;
			cmd_start_training_init	<= 1'b0;
		end
		default: begin
			cfg_rom_addra	<=	'd0;
			cfg_data_en		<=	1'b0;
			cfg_data		<=	'd0;
			reg_cfg_ok		<=	1'b0;
			delay_cnt		<=	'd0;
			cmd_start_training_init	<= 1'b0;
		end
		endcase
	end
end

eds_sensor_spi eds_sensor_spi_inst(
		.clk(clk), 
		.rst_n(~rst),
		.spi_cs(spi_cs), 
		.spi_clk(spi_clk), 		//max 10M
		.spi_mosi(spi_mosi), 
		.spi_miso(spi_miso), 
		
		.spi_cfg_ok(spi_cfg_ok),
		
		.cfg_data_en(cfg_data_en),
		.cfg_data(cfg_data),
		
		.wr_addr_data_en(wr_addr_data_en),
		.wr_addr_data(wr_addr_data),
		.rd_add_en(rd_add_en),
		.rd_add(rd_add),
		.rd_data_en(rd_data_en),
		.rd_data(rd_data)
); 


endmodule
