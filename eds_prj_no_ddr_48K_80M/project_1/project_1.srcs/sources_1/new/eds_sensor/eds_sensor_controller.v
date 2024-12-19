`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: eds_sensor_controller
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


module eds_sensor_controller(
		input	wire		clk,
		input	wire		clk_38m,
		input	wire		clk_228m,
		input	wire		rst,

		input	wire		eds_power_en,
		input	wire [1:0]	ADC_depth, 			//0:8bit, 2:12bit
		input	wire		eds_frame_en,
		input	wire [31:0]	texp_time,
		input	wire [31:0]	frame_to_frame_time,
		input	wire		training_done,
		
		//power en
		output	reg			VDD33A_EN, 
		output	reg			VDDIO_EN, 
		output	reg			VDDD_EN, 
		output	reg			VDDPLL_EN, 
		output	reg			VTXH_EN, 
		output	reg			VRSTH_EN, 
		
		output	wire		GL2504_TEXP0,
		output	wire		GL2504_TEXP1,
		output	wire		GL2504_TEXP2,
		output	wire		GL2504_TEXP3,
		
		output	wire		GL2504_CLK_REF,		//38M
		output	wire		GL2504_SYS_RST_N
		
);

reg			eds_power_en_reg1;
reg			eds_power_en_reg2;

reg	[31:0]	cnt_eds_power;
reg	[3:0]	state_eds_power;
reg			eds_power_ok;
reg			sensor_reset_n_init;
reg			sensor_reset_n_ctr;		//min 2us	ADC_depth发生改变时产生

reg	[1:0]	ADC_depth_temp = 2'd2;
wire		ADC_depth_change_flag;
reg	[31:0]	cnt_sensor_reset_n;

reg			eds_init;

reg			TEXP0_pre;

assign		GL2504_TEXP0		=	TEXP0_pre;
assign		GL2504_TEXP1		=	1'b0;
assign		GL2504_TEXP2		=	1'b0;
assign		GL2504_TEXP3		=	1'b0;

// assign		GL2504_CLK_REF		=	sensor_reset_n_init	?	clk_38m	: 1'b0;
BUFGCE BUFGCE_inst(
		.O(GL2504_CLK_REF),   		// 1-bit output: Clock output
		.CE(sensor_reset_n_init), 	// 1-bit input: Clock enable input for I0
		.I(clk_38m)    				// 1-bit input: Primary clock
);

assign		GL2504_SYS_RST_N	=	sensor_reset_n_init && sensor_reset_n_ctr;


//////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		ADC_depth_temp	<=	2'd2;
	end
	else begin
		ADC_depth_temp	<=	ADC_depth;
	end
end

assign	ADC_depth_change_flag	=	(ADC_depth_temp == ADC_depth)	? 1'b0 : 1'b1;

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		sensor_reset_n_ctr	<=	1'b1;
		cnt_sensor_reset_n	<=	'd0;
	end
	else if(ADC_depth_change_flag) begin
		sensor_reset_n_ctr	<=	1'b0;
		cnt_sensor_reset_n	<=	'd0;
	end
	else if(cnt_sensor_reset_n == 'd500) begin	//5us
		sensor_reset_n_ctr	<=	1'b1;
		cnt_sensor_reset_n	<=	'd0;
	end
	else if(sensor_reset_n_ctr == 1'b0) begin
		sensor_reset_n_ctr	<=	1'b0;
		cnt_sensor_reset_n	<=	cnt_sensor_reset_n + 'd1;
	end
	else begin
		sensor_reset_n_ctr	<=	1'b1;
		cnt_sensor_reset_n	<=	'd0;
	end
end

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		eds_power_en_reg1	<=	1'b0;
		eds_power_en_reg2	<=	1'b0;
	end
	else begin
		eds_power_en_reg1	<=	eds_power_en;
		eds_power_en_reg2	<=	eds_power_en_reg1;
	end
end
//开机自动上电一次后关电，解决第一次上电线阵传感器无数据输出问题
always @(posedge clk or posedge rst)
begin
	if(rst) begin
		state_eds_power	<=	'd0;
	end
	else if(~eds_init) begin
		case(state_eds_power)
		4'd0: begin
			if(cnt_eds_power == 'd3100000) begin
				state_eds_power		<=	state_eds_power + 1'd1;
			end
			else begin
				state_eds_power		<=	4'd0;
			end
		end
		4'd1: begin
			if(training_done) begin
				state_eds_power		<=	state_eds_power + 1'd1;
			end
			else begin
				state_eds_power		<=	state_eds_power;
			end
		end
		4'd2: begin
			if(cnt_eds_power == 'd3100000) begin
				state_eds_power		<=	4'd0;
			end
			else begin
				state_eds_power		<=	state_eds_power;
			end
		end
		default: begin
			state_eds_power		<=	4'd0;
		end
		endcase
	end
	else begin
		case(state_eds_power)
		4'd0: begin
			if(eds_power_en_reg2) begin
				state_eds_power		<=	4'd1;
			end
			else begin
				state_eds_power		<=	4'd0;
			end
		end
		4'd1: begin
			if(cnt_eds_power == 'd3100000) begin
				state_eds_power		<=	4'd2;
			end
			else begin
				state_eds_power		<=	4'd1;
			end
		end
		4'd2: begin
			if(~eds_power_en_reg2) begin
				state_eds_power		<=	4'd3;
			end
			else begin
				state_eds_power		<=	4'd2;
			end
		end
		4'd3: begin
			if(cnt_eds_power == 'd3100000) begin
				state_eds_power		<=	4'd0;
			end
			else begin
				state_eds_power		<=	4'd3;
			end
		end
		default: begin
			state_eds_power		<=	4'd0;
		end
		endcase
	end
end

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		cnt_eds_power		<=	'd0;
		eds_power_ok		<=	1'b0;
		sensor_reset_n_init	<=	1'b0;
		VDD33A_EN			<=	1'b0;
		VDDIO_EN			<=	1'b0;
		VDDD_EN				<=	1'b0;
		VDDPLL_EN			<=	1'b0;
		VTXH_EN				<=	1'b0;
		VRSTH_EN			<=	1'b0;
		eds_init			<=	1'b0;
	end
	else if(~eds_init) begin
		case(state_eds_power)
		4'd0: begin
			eds_power_ok	<=	1'b0;
			eds_init		<=	1'b0;
			if(cnt_eds_power == 'd3100000) begin
				cnt_eds_power		<=	'd0;
			end
			else begin
				cnt_eds_power		<=	cnt_eds_power + 'd1;
			end
			
			if(cnt_eds_power == 'd100) begin	//1us
				VDDIO_EN		<=	1'b1;
			end
			else if(cnt_eds_power == 'd1000000) begin	//10ms
				VDDD_EN			<=	1'b1;
			end
			else if(cnt_eds_power == 'd2000000) begin	//20ms
				VDD33A_EN		<=	1'b1;
				VTXH_EN			<=	1'b1;
				VRSTH_EN		<=	1'b1;
			end
			else if(cnt_eds_power == 'd3000000) begin	//30ms
				VDDPLL_EN		<=	1'b1;
			end
			else if(cnt_eds_power == 'd3100000) begin	//31ms
				sensor_reset_n_init	<=	1'b1;
			end
			else;
		end
		4'd1: begin
			eds_power_ok	<=	1'b0;
			eds_init		<=	1'b0;
			cnt_eds_power	<=	'd0;
		end
		4'd2: begin
			eds_power_ok	<=	1'b0;
			
			if(cnt_eds_power == 'd3100000) begin
				cnt_eds_power		<=	'd0;
				eds_init			<=	1'b1;
			end
			else begin
				cnt_eds_power		<=	cnt_eds_power + 'd1;
				eds_init			<=	1'b0;
			end
			
			if(cnt_eds_power == 'd100) begin	//1us
				sensor_reset_n_init	<=	1'b0;
			end
			else if(cnt_eds_power == 'd1000000) begin	//10ms
				VDDPLL_EN		<=	1'b0;
			end
			else if(cnt_eds_power == 'd2000000) begin	//20ms
				VDD33A_EN		<=	1'b0;
				VTXH_EN			<=	1'b0;
				VRSTH_EN		<=	1'b0;
			end
			else if(cnt_eds_power == 'd3000000) begin	//30ms
				VDDD_EN			<=	1'b0;
			end
			else if(cnt_eds_power == 'd3100000) begin	//31ms
				VDDIO_EN		<=	1'b0;
			end
			else;
		end
		default: begin
			cnt_eds_power		<=	'd0;
			eds_power_ok		<=	1'b0;
			sensor_reset_n_init	<=	1'b0;
			VDD33A_EN			<=	1'b0;
			VDDIO_EN			<=	1'b0;
			VDDD_EN				<=	1'b0;
			VDDPLL_EN			<=	1'b0;
			VTXH_EN				<=	1'b0;
			VRSTH_EN			<=	1'b0;
			eds_init			<=	1'b0;
		end
		endcase
	end
	else begin
		eds_init		<=	1'b1;
		case(state_eds_power)
		4'd0: begin
			cnt_eds_power		<=	'd0;
			eds_power_ok		<=	1'b0;
			sensor_reset_n_init	<=	1'b0;
			VDD33A_EN			<=	1'b0;
			VDDIO_EN			<=	1'b0;
			VDDD_EN				<=	1'b0;
			VDDPLL_EN			<=	1'b0;
			VTXH_EN				<=	1'b0;
			VRSTH_EN			<=	1'b0;
		end
		4'd1: begin
			eds_power_ok	<=	1'b0;

			if(cnt_eds_power == 'd3100000) begin
				cnt_eds_power		<=	'd0;
			end
			else begin
				cnt_eds_power		<=	cnt_eds_power + 'd1;
			end
			
			if(cnt_eds_power == 'd100) begin	//1us
				VDDIO_EN		<=	1'b1;
			end
			else if(cnt_eds_power == 'd1000000) begin	//10ms
				VDDD_EN			<=	1'b1;
			end
			else if(cnt_eds_power == 'd2000000) begin	//20ms
				VDD33A_EN		<=	1'b1;
				VTXH_EN			<=	1'b1;
				VRSTH_EN		<=	1'b1;
			end
			else if(cnt_eds_power == 'd3000000) begin	//30ms
				VDDPLL_EN		<=	1'b1;
			end
			else if(cnt_eds_power == 'd3100000) begin	//31ms
				sensor_reset_n_init	<=	1'b1;
			end
			else;
		end
		4'd2: begin
			if(~eds_power_en_reg2) begin
				eds_power_ok		<=	1'b0;
			end
			else begin
				eds_power_ok		<=	1'd1;
			end
		end
		4'd3: begin
			eds_power_ok	<=	1'b0;

			if(cnt_eds_power == 'd3100000) begin
				cnt_eds_power		<=	'd0;
			end
			else begin
				cnt_eds_power		<=	cnt_eds_power + 'd1;
			end
			
			if(cnt_eds_power == 'd100) begin	//1us
				sensor_reset_n_init	<=	1'b0;
			end
			else if(cnt_eds_power == 'd1000000) begin	//10ms
				VDDPLL_EN		<=	1'b0;
			end
			else if(cnt_eds_power == 'd2000000) begin	//20ms
				VDD33A_EN		<=	1'b0;
				VTXH_EN			<=	1'b0;
				VRSTH_EN		<=	1'b0;
			end
			else if(cnt_eds_power == 'd3000000) begin	//30ms
				VDDD_EN			<=	1'b0;
			end
			else if(cnt_eds_power == 'd3100000) begin	//31ms
				VDDIO_EN		<=	1'b0;
			end
			else;
		end
		default: begin
			cnt_eds_power		<=	'd0;
			eds_power_ok		<=	1'b0;
			sensor_reset_n_init	<=	1'b0;
			VDD33A_EN			<=	1'b0;
			VDDIO_EN			<=	1'b0;
			VDDD_EN				<=	1'b0;
			VDDPLL_EN			<=	1'b0;
			VTXH_EN				<=	1'b0;
			VRSTH_EN			<=	1'b0;
		end
		endcase
	end
end

//////////////////////////////////////////////////////////////////
localparam	fsm_idle 		= 	2'd0, 
			fsm_normal	    = 	2'd1; 

reg [1:0]	fsm_frame_req	=	fsm_idle;

reg			eds_frame_en_reg1;
reg			eds_frame_en_reg2;

wire [2:0]	time_coef;
wire [35:0]	frame_to_frame_time_real;  
wire [35:0]	texp_time_real;  
reg  [35:0]	cnt_frame_time; 

assign		time_coef					=	(ADC_depth == 2'd2)	?	3'd3 : 3'd2;

assign		frame_to_frame_time_real 	= {4'd0,frame_to_frame_time};//frame_to_frame_time * time_coef;
assign		texp_time_real           	= {3'd0,texp_time,1'b0} + {4'd0,texp_time};//texp_time * time_coef;

always @(posedge clk_228m or posedge rst)
begin
	if(rst) begin
		eds_frame_en_reg1	<=	1'b0;
		eds_frame_en_reg2	<=	1'b0;
	end
	else begin
		eds_frame_en_reg1	<=	eds_frame_en;
		eds_frame_en_reg2	<=	eds_frame_en_reg1;
	end
end

always @(posedge clk_228m or posedge rst)
begin
	if(rst) begin 
	    cnt_frame_time           <= 36'd0;
	    TEXP0_pre                <= 1'b0;
		fsm_frame_req			 <=	fsm_idle;
	end
	else begin
		case(fsm_frame_req)
		fsm_idle:begin
			cnt_frame_time    <= 36'd0;
			if(eds_frame_en_reg2)begin
				TEXP0_pre         <= 1'b0;
				fsm_frame_req     <= fsm_normal;
			end
			else begin
				TEXP0_pre         <= 1'b0;
				fsm_frame_req     <= fsm_idle;	
			end
		end
		fsm_normal:begin
		   if(cnt_frame_time == frame_to_frame_time_real - 36'd1)begin
				cnt_frame_time    <= 36'd0;
			    if(~eds_frame_en_reg2)begin
					TEXP0_pre         <= 1'b0;
					fsm_frame_req     <= fsm_idle;
				end
				else;
			end
			else begin
			    if(cnt_frame_time == 'd0) 
					TEXP0_pre       <= 1'b1;
				else if(cnt_frame_time == texp_time_real - 36'd1)begin
					TEXP0_pre    	<= 1'b0;
				end 
				else;
				cnt_frame_time    <= cnt_frame_time + 36'd1; 
			end 
		end
		endcase
	end
end

endmodule
