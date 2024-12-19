`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: eds_sensor_top_if
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


module eds_sensor_top_if #(                                  
	parameter lvds_pairs                = 6       
)(
		input	wire		clk,		//100M
		input	wire		clk_38m,
		input	wire		clk_200m,
		input	wire		rst,

		input	wire		eds_power_en,
		input 	wire [1:0]	ADC_depth,						//0:8bit, 2:12bit 默认12bit
		input	wire		eds_frame_en,
		input	wire [31:0]	texp_time,						//12bit:4*N, < frame_to_frame_time - 200; 8bit:12N,
		input	wire [31:0]	frame_to_frame_time,			//默认行频100k, 12bit: 76M/100k = 760, 8bit: 114M/100k = 1140
		input	wire		test_image_en,
		
		input	wire		firstframe_del_en,
		input	wire [11:0]	training_word,  
		input	wire [1:0]	chan_num,						//0: 0~5	1: 0,2,4	2: 0,3	3: 0
		input	wire		cmd_start_training,
		//power en
		output	wire		VDD33A_EN, 
		output	wire		VDDIO_EN, 
		output	wire		VDDD_EN, 
		output	wire		VDDPLL_EN, 
		output	wire		VTXH_EN, 
		output	wire		VRSTH_EN, 
		//spi
		output	wire		spi_clk,
		output	wire		spi_cs,
		output	wire		spi_mosi,
		input	wire		spi_miso,
		
		output	wire		GL2504_TEXP0,
		output	wire		GL2504_TEXP1,
		output	wire		GL2504_TEXP2,
		output	wire		GL2504_TEXP3,
		
		output	wire		GL2504_CLK_REF,		//38M
		output	wire		GL2504_SYS_RST_N,
		
		input	wire		GL2504_TDIG1,		//Digital test pin1
		input	wire		GL2504_TDIG2,		//Digital test pin2
		
		input	wire		GL2504_CLKOUT_P,	//456M
		input	wire		GL2504_CLKOUT_N,
		input	wire [5:0]	GL2504_OUT_P,
		input	wire [5:0]	GL2504_OUT_N,
		
		output	wire		reg_cfg_ok,
		output	wire		training_done,
		output	wire		training_result,
		
		output	wire		clk_76m,
		output	wire						eds_sensor_data_en,
		output	wire [lvds_pairs*12-1:0]	eds_sensor_data
);

wire			GL2504_CLKOUT;

wire			pll_3_locked;

wire			clk_152m;
wire			clk_228m;

wire			wr_addr_data_en;
wire [23:0]		wr_addr_data;
wire			rd_add_en;
wire [15:0]		rd_add;

wire			rd_data_en;
wire [7:0]		rd_data;

wire			cmd_start_training_init;

 /* 200 MHz = 78 ps, at 300 MHz = 52 ps, and at 400 MHz = 39 ps. */
(* IODELAY_GROUP =  "GROUP" *) IDELAYCTRL u_idelayctrl_inst(
		.RDY            (),
		.REFCLK         (clk_200m),
		.RST            (rst)
);


// vio_eds_spi_test vio_eds_spi_test_inst(
		// .clk(clk),           			// input wire clk
		// .probe_in0(rd_data_en),  		// input wire [0 : 0] probe_in0
		// .probe_in1(rd_data),			// input wire [7 : 0] probe_in1
		// .probe_in2(reg_cfg_ok),			// input wire [0 : 0] probe_in2
		
		// .probe_out0(wr_addr_data_en),	// output wire [0 : 0] probe_out0
		// .probe_out1(wr_addr_data),		// output wire [23 : 0] probe_out1
		// .probe_out2(rd_add_en), 		// output wire [0 : 0] probe_out2
		// .probe_out3(rd_add)				// output wire [15 : 0] probe_out3
// );

pll_3 pll_3_inst(
		.clk_out1(GL2504_CLKOUT),
		.clk_out2(clk_76m), 
		.clk_out3(clk_152m),
		.clk_out4(clk_228m),
		.reset(rst), 
		.locked(pll_3_locked), 
		.clk_in1_p(GL2504_CLKOUT_P),
		.clk_in1_n(GL2504_CLKOUT_N)
);

eds_sensor_controller	eds_sensor_controller_inst(
		.clk(clk),
		.clk_38m(clk_38m),
		.clk_228m(clk_228m),
		.rst(rst),
		
		.eds_power_en(eds_power_en),
		.ADC_depth(ADC_depth),
		.eds_frame_en(eds_frame_en),
		.texp_time(texp_time),
		.frame_to_frame_time(frame_to_frame_time),
		.training_done(training_done),
		
		.VDD33A_EN(VDD33A_EN), 
		.VDDIO_EN(VDDIO_EN), 
		.VDDD_EN(VDDD_EN), 
		.VDDPLL_EN(VDDPLL_EN), 
		.VTXH_EN(VTXH_EN), 
		.VRSTH_EN(VRSTH_EN),

		.GL2504_TEXP0(GL2504_TEXP0),
		.GL2504_TEXP1(GL2504_TEXP1),
		.GL2504_TEXP2(GL2504_TEXP2),
		.GL2504_TEXP3(GL2504_TEXP3),

		.GL2504_CLK_REF(GL2504_CLK_REF),
		.GL2504_SYS_RST_N(GL2504_SYS_RST_N)
);

eds_sensor_reg_cfg eds_sensor_reg_cfg_inst(
		.clk(clk), 
		.rst(~GL2504_SYS_RST_N),
		
		.ADC_depth(ADC_depth),
		
		.spi_cs(spi_cs), 
		.spi_clk(spi_clk), 		//max 10M
		.spi_mosi(spi_mosi), 
		.spi_miso(spi_miso), 
		
		.pll_3_locked(pll_3_locked),
		.reg_cfg_ok(reg_cfg_ok),
		
		.cmd_start_training_init(cmd_start_training_init),
		
		.wr_addr_data_en(wr_addr_data_en),
		.wr_addr_data(wr_addr_data),
		.rd_add_en(rd_add_en),
		.rd_add(rd_add),
		.rd_data_en(rd_data_en),
		.rd_data(rd_data)
); 

image_rx #(         
		.lvds_pairs(lvds_pairs) 
    ) image_rx_inst( 
		.clk_rxg					(clk_76m),
		.clk_rxg_x2					(clk_152m),
		.clk_ddr					(GL2504_CLKOUT),
		.rst_rx						(~GL2504_SYS_RST_N || ~pll_3_locked),
		.clk_sys					(clk),
		.rst_sys					(~GL2504_SYS_RST_N),
		
		.eds_frame_en				(eds_frame_en),
		.ADC_depth					(ADC_depth),
		.firstframe_del_en			(firstframe_del_en),
		
		.sensor_data_p				(GL2504_OUT_P),
		.sensor_data_n				(GL2504_OUT_N), 
		.chan_num                   (chan_num),
		.training_word				(training_word),
		.cmd_start_training			(cmd_start_training || cmd_start_training_init),
		.test_image_en				(test_image_en),
		.lval_out			        (eds_sensor_data_en),
		.data_out			        (eds_sensor_data),
		.training_done				(training_done),
		.training_result			(training_result)
); 




endmodule
