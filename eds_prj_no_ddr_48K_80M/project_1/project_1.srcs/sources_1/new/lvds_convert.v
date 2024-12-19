`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: lvds_convert
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


module lvds_convert(
		//timing if
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
		
		input	wire [3:0]	EDS_DATA,
		
		output	wire		EDS_TC,
		output	wire		EDS_TFG,
		input	wire		EDS_CC1,
		input	wire		EDS_CC2,
		input	wire		EDS_CC3,
		input	wire		EDS_CC4
		
);

OBUFDS #(
			.IOSTANDARD("DEFAULT"), 	// Specify the output I/O standard
			.SLEW("SLOW")           	// Specify the output slew rate
		) EDS_DATA0_inst(
			.O(EDS_DATA_P[0]),			// Diff_p output (connect directly to top-level port)
			.OB(EDS_DATA_N[0]), 		// Diff_n output (connect directly to top-level port)
			.I(EDS_DATA[0])				// Buffer input
		);

OBUFDS #(
			.IOSTANDARD("DEFAULT"), 	// Specify the output I/O standard
			.SLEW("SLOW")           	// Specify the output slew rate
		) EDS_DATA1_inst(
			.O(EDS_DATA_P[1]),			// Diff_p output (connect directly to top-level port)
			.OB(EDS_DATA_N[1]), 		// Diff_n output (connect directly to top-level port)
			.I(EDS_DATA[1])				// Buffer input
		);

OBUFDS #(
			.IOSTANDARD("DEFAULT"), 	// Specify the output I/O standard
			.SLEW("SLOW")           	// Specify the output slew rate
		) EDS_DATA2_inst(
			.O(EDS_DATA_P[2]),			// Diff_p output (connect directly to top-level port)
			.OB(EDS_DATA_N[2]), 		// Diff_n output (connect directly to top-level port)
			.I(EDS_DATA[2])				// Buffer input
		);

OBUFDS #(
			.IOSTANDARD("DEFAULT"), 	// Specify the output I/O standard
			.SLEW("SLOW")           	// Specify the output slew rate
		) EDS_DATA3_inst(
			.O(EDS_DATA_P[3]),			// Diff_p output (connect directly to top-level port)
			.OB(EDS_DATA_N[3]), 		// Diff_n output (connect directly to top-level port)
			.I(EDS_DATA[3])				// Buffer input
		);

IBUFDS #(
			.DIFF_TERM("TRUE"),			// Differential Termination
			.IBUF_LOW_PWR("TRUE"), 		// Low power="TRUE", Highest performance="FALSE" 
			.IOSTANDARD("DEFAULT") 		// Specify the input I/O standard
		) EDS_TC_inst(
			.O(EDS_TC),  				// Buffer output
			.I(EDS_TC_P),  				// Diff_p buffer input (connect directly to top-level port)
			.IB(EDS_TC_N) 				// Diff_n buffer input (connect directly to top-level port)
		);

IBUFDS #(
			.DIFF_TERM("TRUE"),			// Differential Termination
			.IBUF_LOW_PWR("TRUE"), 		// Low power="TRUE", Highest performance="FALSE" 
			.IOSTANDARD("DEFAULT") 		// Specify the input I/O standard
		) EDS_TFG_inst(
			.O(EDS_TFG),  				// Buffer output
			.I(EDS_TFG_P),  			// Diff_p buffer input (connect directly to top-level port)
			.IB(EDS_TFG_N) 				// Diff_n buffer input (connect directly to top-level port)
		);

OBUFDS #(
			.IOSTANDARD("DEFAULT"), 	// Specify the output I/O standard
			.SLEW("SLOW")           	// Specify the output slew rate
		) EDS_CC1_inst(
			.O(EDS_CC1_P),			// Diff_p output (connect directly to top-level port)
			.OB(EDS_CC1_N), 		// Diff_n output (connect directly to top-level port)
			.I(EDS_CC1)				// Buffer input
		);

OBUFDS #(
			.IOSTANDARD("DEFAULT"), 	// Specify the output I/O standard
			.SLEW("SLOW")           	// Specify the output slew rate
		) EDS_CC2_inst(
			.O(EDS_CC2_P),			// Diff_p output (connect directly to top-level port)
			.OB(EDS_CC2_N), 		// Diff_n output (connect directly to top-level port)
			.I(EDS_CC2)				// Buffer input
		);

OBUFDS #(
			.IOSTANDARD("DEFAULT"), 	// Specify the output I/O standard
			.SLEW("SLOW")           	// Specify the output slew rate
		) EDS_CC3_inst(
			.O(EDS_CC3_P),			// Diff_p output (connect directly to top-level port)
			.OB(EDS_CC3_N), 		// Diff_n output (connect directly to top-level port)
			.I(EDS_CC3)				// Buffer input
		);

OBUFDS #(
			.IOSTANDARD("DEFAULT"), 	// Specify the output I/O standard
			.SLEW("SLOW")           	// Specify the output slew rate
		) EDS_CC4_inst(
			.O(EDS_CC4_P),			// Diff_p output (connect directly to top-level port)
			.OB(EDS_CC4_N), 		// Diff_n output (connect directly to top-level port)
			.I(EDS_CC4)				// Buffer input
		);


endmodule
