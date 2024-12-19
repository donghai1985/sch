`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/23 17:00:14
// Design Name: 
// Module Name: mfpga_top
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


module mfpga_top #(                                  
	parameter lvds_pairs                = 6       
)(
		//sys io
		input	wire		FPGA_CLK, 			//50M 单板调试时使用该时钟
		//status io
		input	wire		DDR_POWER_GOOD, 
		//power en
		output	wire		VDD33A_EN, 
		output	wire		VDDIO_EN, 
		output	wire		VDDD_EN, 
		output	wire		VDDPLL_EN, 
		output	wire		VTXH_EN, 
		output	wire		VRSTH_EN, 
		//GL3504
		output	wire		GL2504_TEXP0,
		output	wire		GL2504_TEXP1,
		output	wire		GL2504_TEXP2,
		output	wire		GL2504_TEXP3,
		
		output	wire		GL2504_SPI_CLK,		//max 10M
		output	wire		GL2504_SPI_EN,
		output	wire		GL2504_SPI_MOSI,
		input	wire		GL2504_SPI_MISO,
		
		output	wire		GL2504_CLK_REF,		//38M
		output	wire		GL2504_SYS_RST_N,
		
		input	wire		GL2504_TDIG1,		//Digital test pin1
		input	wire		GL2504_TDIG2,		//Digital test pin2
		
		input	wire		GL2504_CLKOUT_P,	//456M
		input	wire		GL2504_CLKOUT_N,
		input	wire [5:0]	GL2504_OUT_P,
		input	wire [5:0]	GL2504_OUT_N,
		//timing if
		input	wire		EDS_CLK_P, 			//100M
		input	wire		EDS_CLK_N, 
		output	wire [3:0]	EDS_DATA_P,
		output	wire [3:0]	EDS_DATA_N,
		
		input	wire		EDS_TC_P,
		input	wire		EDS_TC_N,
		input	wire		EDS_TFG_P,
		input	wire		EDS_TFG_N,
		output	wire		EDS_CC1_P,
		output	wire		EDS_CC1_N,
		output	wire		EDS_CC2_P,
		output	wire		EDS_CC2_N,
		output	wire		EDS_CC3_P,
		output	wire		EDS_CC3_N,
		output	wire		EDS_CC4_P,
		output	wire		EDS_CC4_N,
		//ddr3
		// inout	wire [15:0]	DDR3_A_D, 
		// inout	wire [1:0] 	DDR3_A_DQS_P,
		// inout	wire [1:0] 	DDR3_A_DQS_N,
		// output	wire [1:0]	DDR3_A_DM,
		// output	wire [15:0]	DDR3_A_ADD, 
		// output	wire [2:0]	DDR3_A_BA,
		// output	wire		DDR3_A_CKE, 
		// output	wire		DDR3_A_WE_B, 
		// output	wire		DDR3_A_RAS_B, 
		// output	wire		DDR3_A_CAS_B, 
		// output	wire		DDR3_A_S0_B, 
		// output	wire		DDR3_A_ODT, 
		// output	wire		DDR3_A_RESET_B,   
		// output	wire		DDR3_A_CLK0_P, 
		// output	wire		DDR3_A_CLK0_N,
		//test io
		output	wire		TP3,
		output	wire		TP4,
		output	wire		TP5,
		output	wire		TP6,
		output	wire		TP7,
		output	wire		TP8,
		output	wire		TP9
);

assign		TP2				=	1'b0;
assign		TP3				=	1'b0;
assign		TP4				=	eds_sensor_training_result;
assign		TP5				=	cmd_start_training_vio;
assign		TP6				=	ddr3_init_done;
assign		TP7				=	ddr_ui_clk;
assign		TP8				=	clk_100m;
assign		TP9				=	pll_2_locked;

wire				clk_100m;
wire				clk_200m;
wire				clk_250m;
wire				clk_80m;
wire				clk_38m;
wire				clk_76m;
wire				clk_80m_div_3;
wire				pll_locked;
wire				pll_2_locked;

wire				GL2504_CLKOUT;
wire	[5:0]		GL2504_OUT;

wire	[3:0]		EDS_DATA;

wire				EDS_TC;
wire				EDS_TFG;
wire				EDS_CC1;
wire				EDS_CC2;
wire				EDS_CC3;
wire				EDS_CC4;


reg		[15:0]		rst_cnt;
reg					rst;


wire				complete;			//????????
wire				complete_vio;
wire				ddr_test_ok;

reg		[3:0]		ddr_rst_cnt;
reg					ddr_rst;
wire				ddr3_init_done;

wire				ddr_ui_clk;

wire				ddr_wr_full;
wire				ddr_wr_en;
wire	[127:0]		ddr_wr_data;
wire	[9:0]		ddr_wr_data_count;
wire	[127:0]		ddr_wr_test_data;
wire	[9:0]		ddr_wr_test_data_count;

wire				ddr_rd_en;
wire				ddr_rd_full;
wire	[127:0] 	ddr_rd_data;

wire				ddr3_to_timing_fifo_full;
wire				ddr3_to_timing_fifo_rd_en;
wire	[127:0]		ddr3_to_timing_fifo_rd_data;
wire	[127:0]		ddr3_to_timing_fifo_rd_data_temp;
wire				ddr3_to_timing_fifo_empty;
wire	[12:0]		ddr3_to_timing_fifo_rd_data_count;

wire				eds_sensor_reg_cfg_ok;
wire				eds_sensor_training_done;
wire				eds_sensor_training_result;

wire	[lvds_pairs*12-1:0]		eds_sensor_data;
wire				eds_sensor_data_en;	

wire				eds_power_en;
wire				eds_power_en_vio;
wire 	[1:0]		ADC_depth;						//0:8bit, 2:12bit 默认12bit
wire				eds_frame_en;
wire				eds_frame_en_vio;
wire				down_edge_eds_frame_en_exp;
wire 	[31:0]		texp_time;						//12bit:4*N, < frame_to_frame_time - 200; 8bit:12N,
wire 	[31:0]		frame_to_frame_time;			//默认行频100k, 12bit: 76M/100k = 760, 8bit: 114M/100k = 1140	
wire				cmd_start_training;
wire				cmd_start_training_vio;

wire				test_en;
wire				test_en_vio;

wire				clear_buffer;

wire				EDS_CLK_temp;

lvds_convert lvds_convert_inst(		
		.EDS_DATA_P(EDS_DATA_P),
		.EDS_DATA_N(EDS_DATA_N),
		
		.EDS_TC_P(EDS_TC_P),
		.EDS_TC_N(EDS_TC_N),
		.EDS_TFG_P(EDS_TFG_P),
		.EDS_TFG_N(EDS_TFG_N),
		.EDS_CC1_P(EDS_CC1_P),
		.EDS_CC1_N(EDS_CC1_N),
		.EDS_CC2_P(EDS_CC2_P),
		.EDS_CC2_N(EDS_CC2_N),
		.EDS_CC3_P(EDS_CC3_P),
		.EDS_CC3_N(EDS_CC3_N),
		.EDS_CC4_P(EDS_CC4_P),
		.EDS_CC4_N(EDS_CC4_N),

		.EDS_DATA(EDS_DATA),

		.EDS_TC(EDS_TC),
		.EDS_TFG(EDS_TFG),
		.EDS_CC1(EDS_CC1),
		.EDS_CC2(EDS_CC2),
		.EDS_CC3(EDS_CC3),
		.EDS_CC4(EDS_CC4)
);

// pll_test pll_test_inst(
		// .clk_out1(clk_100m), 
		// .clk_out2(clk_200m),
		// .clk_out3(clk_250m),
		// .reset(1'b0), 
		// .locked(pll_locked), 
		// .clk_in1(FPGA_CLK)
// );

IBUFDS #(
                .DIFF_TERM("TRUE"),  			// Differential Termination
                .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
                .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
           ) IBUFDS_inst(
                .O(EDS_CLK_temp),  		// Buffer output
                .I(EDS_CLK_P), 		// Diff_p buffer input (connect directly to top-level port)
                .IB(EDS_CLK_N)		// Diff_n buffer input (connect directly to top-level port)
        );

pll pll_inst(
		.clk_out1(clk_100m), 
		.clk_out2(clk_200m),
		.clk_out3(clk_80m),
		.clk_out4(clk_80m_div_3),
		.reset(1'b0), 
		.locked(pll_locked), 
		.clk_in1(EDS_CLK_temp)
);

pll_2 pll_2_inst(
		.clk_out1(clk_38m),
		.reset(~pll_locked), 
		.locked(pll_2_locked), 
		.clk_in1(clk_100m)
);


always @(posedge clk_100m or negedge pll_2_locked) begin
	if(~pll_2_locked) begin
		rst 		<= 'd1;
		rst_cnt 	<= 'd0;
	end
	else if(rst_cnt == 'd10000) begin		//100us
		rst_cnt 	<= rst_cnt;
		rst 		<= 'd0;
	end
	else begin
		rst 		<= 'd1;
		rst_cnt 	<= rst_cnt + 1'b1;
	end
end


// always @(posedge ddr_ui_clk or posedge rst) begin
	// if(rst) begin
		// ddr_rst_cnt	<= 'd0;
		// ddr_rst		<= 'b1;
	// end
	// else if(ddr_rst_cnt == 'd4) begin
		// ddr_rst_cnt	<= ddr_rst_cnt;
		// ddr_rst		<= 'b0;
	// end
	// else begin
		// ddr_rst_cnt	<= ddr_rst_cnt + 'd1;
		// ddr_rst		<= 'b1;
	// end
// end


// ddr_test_top_if	ddr_test_top_if(
		// .clk(clk_250m),
		// .rst(rst),
		
		// .ddr_ui_clk(ddr_ui_clk),
		// .ddr3_init_done(ddr3_init_done),
		
		// .eds_frame_en(eds_frame_en),
		
		// .ddr_wr_en(ddr_wr_en),
		// .ddr_wr_data(ddr_wr_test_data),
		// .ddr_wr_data_count(ddr_wr_test_data_count),
		// .ddr_rd_en(ddr_rd_en),
		// .ddr_rd_data(ddr_rd_data),
		
		// .complete_vio(complete_vio),
		// .ddr_test_ok(ddr_test_ok)
// );

vio_1 vio_1_inst(
		.clk(clk_100m),           		// input wire clk
		
		.probe_in0(eds_sensor_reg_cfg_ok),
		.probe_in1(eds_sensor_training_done),
		.probe_in2(eds_sensor_training_result),
		
		.probe_out0(cmd_start_training_vio),	// output wire [0 : 0] probe_out0
		.probe_out1(eds_frame_en_vio),
		.probe_out2(eds_power_en_vio),
		.probe_out3(test_en_vio)

);

eds_sensor_top_if	eds_sensor_top_if(
		.clk(clk_100m),
		.clk_38m(clk_38m),
		.clk_200m(clk_200m),
		.rst(rst),
		
		.eds_power_en(eds_power_en_vio || eds_power_en),
		.ADC_depth(2'd2/*ADC_depth*/),
		.eds_frame_en(eds_frame_en_vio || eds_frame_en),
		.texp_time(/*32'd660*/texp_time),						//12bit:4*N, < frame_to_frame_time - 200; 8bit:12N,
		.frame_to_frame_time(/*32'd1520*/frame_to_frame_time),	//默认行频50k, 12bit: 76M/50k = 1520, 8bit: 114M/50k = 2280
		.test_image_en(test_en || test_en_vio),
		
		.firstframe_del_en(1'b0),
		.chan_num(2'd0),	//0: 0~5	1: 0,2,4	2: 0,3	3: 0
		.training_word(12'd797),	//12bit: 12'd797	8bit: 8'd29
		.cmd_start_training(/*cmd_start_training*/cmd_start_training_vio),
		//power en
		.VDD33A_EN(VDD33A_EN), 
		.VDDIO_EN(VDDIO_EN), 
		.VDDD_EN(VDDD_EN), 
		.VDDPLL_EN(VDDPLL_EN), 
		.VTXH_EN(VTXH_EN), 
		.VRSTH_EN(VRSTH_EN), 
		//spi
		.spi_clk(GL2504_SPI_CLK),
		.spi_cs(GL2504_SPI_EN),
		.spi_mosi(GL2504_SPI_MOSI),
		.spi_miso(GL2504_SPI_MISO),
		//
		.GL2504_TEXP0(GL2504_TEXP0),
		.GL2504_TEXP1(GL2504_TEXP1),
		.GL2504_TEXP2(GL2504_TEXP2),
		.GL2504_TEXP3(GL2504_TEXP3),
		
		.GL2504_CLK_REF(GL2504_CLK_REF),		//38M
		.GL2504_SYS_RST_N(GL2504_SYS_RST_N),
		
		.GL2504_TDIG1(GL2504_TDIG1),			//Digital test pin1
		.GL2504_TDIG2(GL2504_TDIG2),			//Digital test pin2
		
		.GL2504_CLKOUT_P(GL2504_CLKOUT_P),
		.GL2504_CLKOUT_N(GL2504_CLKOUT_N),
		.GL2504_OUT_P(GL2504_OUT_P),
		.GL2504_OUT_N(GL2504_OUT_N),
		
		.reg_cfg_ok(eds_sensor_reg_cfg_ok),
		.training_done(eds_sensor_training_done),
		.training_result(eds_sensor_training_result),
		
		.clk_76m(clk_76m),
		.eds_sensor_data(eds_sensor_data),
		.eds_sensor_data_en(eds_sensor_data_en)
);


reg	eds_power_en_d0;
reg	eds_power_en_d1;
reg eds_frame_en_d0;
reg eds_frame_en_d1;
always @(posedge clk_100m) begin
	eds_power_en_d0	<= eds_power_en_vio || eds_power_en;
	eds_power_en_d1	<= eds_power_en_d0;
    eds_frame_en_d0 <= eds_frame_en_vio || eds_frame_en;
    eds_frame_en_d1 <= eds_frame_en_d0;
end
		
eds_to_ddr3_data_sync esd_to_ddr3_data_sync_inst(
		.rst(rst),
		.clk_76m(clk_76m),
		.eds_power_en(eds_power_en_d1),
		.eds_frame_en(eds_frame_en_d1),
		.clear_buffer(clear_buffer),
		
		.ddr_ui_clk(clk_100m),
		
		.eds_sensor_data(eds_sensor_data),
		.eds_sensor_data_en(eds_sensor_data_en),
		
		.eds_data_wr_en(ddr_rd_en),
		.eds_data_wr_data(ddr_rd_data),
		
		.down_edge_eds_frame_en_exp(down_edge_eds_frame_en_exp)
		
		// .ddr_wr_en(ddr3_to_timing_fifo_rd_en),
		// .ddr_wr_data_count(ddr3_to_timing_fifo_rd_data_count),
		// .ddr_wr_data(ddr3_to_timing_fifo_rd_data)
);


// ddr_fifo_top ddr_fifo_top_inst(
		// .sys_rst				(ddr_rst || (~(eds_power_en || eds_power_en_vio)) || clear_buffer),
		// .rst					(rst					),
		// .clk_250m				(clk_250m				),
		// .clk_200m 				(clk_200m 				),
		// .ui_clk					(ddr_ui_clk				),
		// .ddr_wr_data			(ddr_wr_data/*ddr_wr_test_data*/		),
		// .ddr_wr_en				(ddr_wr_en				),
		// .ddr_wr_data_count		(ddr_wr_data_count/*ddr_wr_test_data_count*/		),
		// .complete				(/*complete*/complete_vio				),
		// .ddr_rd_en				(ddr_rd_en				),
		// .ddr_rd_data			(ddr_rd_data			),
		// .ddr_rd_full 			(ddr3_to_timing_fifo_full/*ddr3_to_timing_test_fifo_full*/			),
		// .init_calib_complete	(ddr3_init_done			),
		// .ddr3_dq				(DDR3_A_D				),
		// .ddr3_dqs_n				(DDR3_A_DQS_N			),
		// .ddr3_dqs_p				(DDR3_A_DQS_P			),
		// .ddr3_addr				(DDR3_A_ADD				),
		// .ddr3_ba				(DDR3_A_BA				),
		// .ddr3_ras_n				(DDR3_A_RAS_B			),
		// .ddr3_cas_n				(DDR3_A_CAS_B			),
		// .ddr3_we_n				(DDR3_A_WE_B			),
		// .ddr3_reset_n			(DDR3_A_RESET_B			),
		// .ddr3_ck_p				(DDR3_A_CLK0_P			),
		// .ddr3_ck_n				(DDR3_A_CLK0_N			),
		// .ddr3_cke				(DDR3_A_CKE				),
		// .ddr3_cs_n				(DDR3_A_S0_B			),
		// .ddr3_dm				(DDR3_A_DM				),
		// .ddr3_odt               (DDR3_A_ODT				)
// );
/*
//////////test
wire		test_rd_en;
wire		test_empty;
wire		ddr3_to_timing_test_fifo_full;
wire [15:0]	test_rd_data;
wire [11:0]	test_rd_data_count;

ila_test	ila_test_inst(
		.clk(clk_200m),
		.probe0(test_rd_en),
		.probe1(test_rd_data),
		.probe2(ddr3_to_timing_test_fifo_full),
		.probe3(test_rd_data_count)
);

assign	test_rd_en = ~test_empty;

ddr3_to_timing_test_fifo		ddr3_to_timing_test_fifo_inst(
		.rst(rst || (~ddr3_init_done)),
		.wr_clk(ddr_ui_clk),
		.rd_clk(clk_200m),
		.din(ddr_rd_data),
		.wr_en(ddr_rd_en),
		.rd_en(test_rd_en),
		.dout(test_rd_data),
		.full(ddr3_to_timing_test_fifo_full),
		.empty(test_empty),
		.rd_data_count(test_rd_data_count)
);
*/

ddr3_to_timing_fifo		ddr3_to_timing_fifo_inst(
		.rst(rst /*|| (~ddr3_init_done) */|| (~(eds_power_en || eds_power_en_vio)) /*|| clear_buffer */|| down_edge_eds_frame_en_exp),
		.wr_clk(clk_100m),
		.rd_clk(clk_80m_div_3),
		.din(ddr_rd_data),
		.wr_en(ddr_rd_en),
		.rd_en(ddr3_to_timing_fifo_rd_en),
		.dout(ddr3_to_timing_fifo_rd_data_temp),
		.full(),
		.empty(ddr3_to_timing_fifo_empty),
		.prog_full_thresh(700),		// input wire [9 : 0] prog_full_thresh
		.prog_full(ddr3_to_timing_fifo_full),
		.rd_data_count(ddr3_to_timing_fifo_rd_data_count)
);

assign	ddr3_to_timing_fifo_rd_data = {ddr3_to_timing_fifo_rd_data_temp[15:0],ddr3_to_timing_fifo_rd_data_temp[31:16],ddr3_to_timing_fifo_rd_data_temp[47:32],ddr3_to_timing_fifo_rd_data_temp[63:48],
									   ddr3_to_timing_fifo_rd_data_temp[79:64],ddr3_to_timing_fifo_rd_data_temp[95:80],ddr3_to_timing_fifo_rd_data_temp[111:96],ddr3_to_timing_fifo_rd_data_temp[127:112]};

timing_top_if	timing_top_if_inst(
		.clk(clk_80m),
		.clk_h(clk_200m),
		.rst(rst),
		
		.to_timing_eds_data({EDS_CC4,EDS_CC3,EDS_CC2,EDS_CC1,EDS_DATA}),
		
		.to_spi_clk(EDS_TC),
		.to_spi_mosi(EDS_TFG),
		
		.clk_div(clk_80m_div_3),
		.rd_en(ddr3_to_timing_fifo_rd_en),
		.rd_data(ddr3_to_timing_fifo_rd_data),
		.rd_data_count(ddr3_to_timing_fifo_rd_data_count),
		
		.eds_power_en_test(eds_power_en_vio),
		.eds_frame_en_test(eds_frame_en_vio),
		
		.clear_buffer(clear_buffer),
		.eds_power_en(eds_power_en),
		.eds_frame_en(eds_frame_en),
		.texp_time(texp_time),
		.frame_to_frame_time(frame_to_frame_time),
		.test_en(test_en)
);

endmodule
