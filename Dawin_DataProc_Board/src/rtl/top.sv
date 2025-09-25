`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/16 10:54:45
// Design Name: 
// Module Name: top
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
`include "proj_define.vh"
`include "XRNIC_define.vh"
module top#
(
	parameter			SIM="FALSE"
)(
input 					sysclk_p,			// 100M
input 					sysclk_n,

`ifdef RDMA_CHANNEL_1
input                   c0_sys_clk_p,		// 200M
input                   c0_sys_clk_n,
output                  c0_ddr4_act_n,
output [16:0]           c0_ddr4_adr,
output [1:0]            c0_ddr4_ba,
output [0:0]            c0_ddr4_bg,
output [0:0]            c0_ddr4_cke,
output [0:0]            c0_ddr4_odt,
output [0:0]            c0_ddr4_cs_n,
output [0:0]            c0_ddr4_ck_t,
output [0:0]            c0_ddr4_ck_c,
output                  c0_ddr4_reset_n,
inout  [7:0]            c0_ddr4_dm_dbi_n,
inout  [63:0]           c0_ddr4_dq,
inout  [7:0]            c0_ddr4_dqs_t,
inout  [7:0]            c0_ddr4_dqs_c,
 
input  [3 :0]   		gt_226_rxp_in,
input  [3 :0]   		gt_226_rxn_in,
output [3 :0]   		gt_226_txp_out,
output [3 :0]   		gt_226_txn_out,
input       			gt_226_ref_clk_p,
input       			gt_226_ref_clk_n,
`endif

`ifdef RDMA_CHANNEL_2
input                   c1_sys_clk_p,		// 200M
input                   c1_sys_clk_n,
output                  c1_ddr4_act_n,
output [16:0]           c1_ddr4_adr,
output [1:0]            c1_ddr4_ba,
output [0:0]            c1_ddr4_bg,
output [0:0]            c1_ddr4_cke,
output [0:0]            c1_ddr4_odt,
output [0:0]            c1_ddr4_cs_n,
output [0:0]            c1_ddr4_ck_t,
output [0:0]            c1_ddr4_ck_c,
output                  c1_ddr4_reset_n,
inout  [7:0]            c1_ddr4_dm_dbi_n,
inout  [63:0]           c1_ddr4_dq,
inout  [7:0]            c1_ddr4_dqs_t,
inout  [7:0]            c1_ddr4_dqs_c,

input  [3 :0]   		gt_227_rxp_in,
input  [3 :0]   		gt_227_rxn_in,
output [3 :0]   		gt_227_txp_out,
output [3 :0]   		gt_227_txn_out,
input       			gt_227_ref_clk_p,
input       			gt_227_ref_clk_n,
`endif

input					cha_fan_fg,
output logic			cha_fan_pwm,
output logic			cha_fan_pwren,

output					TMP75_IIC_SCL,
inout					TMP75_IIC_SDA,

output					CHA_QSFP2_RESETL,
output					CHA_QSFP3_RESETL,
output					CHA_QSFP2_LPMODE_1V8,
output					CHA_QSFP3_LPMODE_1V8,
output					CHA_QSFP2_MODSELL,
output					CHA_QSFP3_MODSELL,

output					CHA_QSFP4_RESETL,
output					CHA_QSFP5_RESETL,
output					CHA_QSFP4_LPMODE_1V8,
output					CHA_QSFP5_LPMODE_1V8,
output					CHA_QSFP4_MODSELL,
output					CHA_QSFP5_MODSELL


    );
    assign CHA_QSFP2_RESETL=1'b1;
    assign CHA_QSFP3_RESETL=1'b1;
    assign CHA_QSFP2_LPMODE_1V8=1'b0;
    assign CHA_QSFP3_LPMODE_1V8=1'b0;
    assign CHA_QSFP2_MODSELL=1'b0;
    assign CHA_QSFP3_MODSELL=1'b0;
    
    assign CHA_QSFP4_RESETL=1'b1;
    assign CHA_QSFP5_RESETL=1'b1;
    assign CHA_QSFP4_LPMODE_1V8=1'b0;
    assign CHA_QSFP5_LPMODE_1V8=1'b0;
    assign CHA_QSFP4_MODSELL=1'b0;
    assign CHA_QSFP5_MODSELL=1'b0;
    
    
    localparam C_AXIS_DATA_WIDTH=512;
    localparam DDR_C_AXI_ADDR_WIDTH=33;
    
    logic				rst;
    logic [15:0]		cnt;
    logic 				sysclk_100;
    logic				sysclk_200;
    logic				sysclk_300;
    logic				clk_wiz_locked;

    
    logic	[11:0]		temp_data;
    logic	[11:0]		temp_data_reg;
    logic				temp_data_vld;
    
    logic	[3:0]		IMC_NUM;
    logic	[3:0]		track_num_per_IMC;
	logic				TDI_sim_start;
	logic				TDI_sim_start_auto;
	logic	[31:0]		sim_track_valid_line_cnt;
	logic	[31:0]		sim_track_total_line_cnt;
	logic	[31:0]		sim_part_valid_line_cnt;
	logic	[31:0]		eth_interval_cnt;
	logic	[15:0]		track_num_per_wafer;
	logic				info_enable;
	logic				part_num;
	logic				first_part_flag;
	
	logic				db_write_enable_1;
	logic				db_write_enable_2;
	
	logic                               			TDI_m_axis_tready_0;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			TDI_m_axis_tdata_0;
	logic                               			TDI_m_axis_tvalid_0;
	logic                               			TDI_m_axis_tlast_0;
	
	logic                               			TDI_m_axis_tready_1;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			TDI_m_axis_tdata_1;
	logic                               			TDI_m_axis_tvalid_1;
	logic                               			TDI_m_axis_tlast_1;
	
	logic											TDI_m_fifo_prog_full;
	
	logic                               			INFO_m_axis_tready;
	logic  	[C_AXIS_DATA_WIDTH-1 : 0]    			INFO_m_axis_tdata;
	logic 	[C_AXIS_DATA_WIDTH/8-1:0]    			INFO_m_axis_tkeep;
	logic                               			INFO_m_axis_tvalid;
	logic                               			INFO_m_axis_tlast;
	logic											INFO_m_fifo_prog_full;
	
	logic											TDI_max_speed_mode;
	
	
	
	
    
   /* IBUFDS #(
      .DIFF_TERM("FALSE"),       // Differential Termination
      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
   ) IBUFDS_inst (
      .O(sysclk),  // Buffer output
      .I(sysclk_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(sysclk_n) // Diff_n buffer input (connect directly to top-level port)
   );*/
   
   	
   
   	clk_wiz_0 clk_wiz_0
   	(
		.clk_out1	(sysclk_100),     // output clk_out1
		.clk_out2	(sysclk_200),
		.clk_out3	(sysclk_300),
		.locked		(clk_wiz_locked),
    	.clk_in1_p	(sysclk_p),    // input clk_in1_p
    	.clk_in1_n	(sysclk_n)
    );   
    
    rst_gen
    #(
    	.SIM						(SIM)
    ) rst_gen
   	(
        .sysclk_100                 (sysclk_100),
        .clk_wiz_locked             (clk_wiz_locked),
        .rst                        (rst)
   	);

   	assign cha_fan_pwren=1;
    
    /*always@(posedge sysclk)
    	if(cnt==2499)		cnt<=0;
    	else				cnt<=cnt+1;
    
    always@(posedge sysclk)
    	if(cnt==2499)		cha_fan_pwm<=!cha_fan_pwm;*/

generate
if(SIM=="FALSE") begin    
	
   	
    TMP75 TMP75_inst(
		.clk				(sysclk_100),
		.rst				(rst),
		.TEMP_SCL			(TMP75_IIC_SCL),
		.TEMP_SDA			(TMP75_IIC_SDA),
		
		.TEMP_RD_en			(1 ),
		
		.TEMP_DATA			(temp_data),
		.TEMP_DATA_reg		(temp_data_reg),
		.TEMP_DATA_en		(temp_data_vld)
	);
    
    FAN_CTR_module FAN_CTR_module
    (
    	.i_clk 				(sysclk_100),
    	.i_rst_n			(1),
    	.i_TEMP_DATA		(temp_data),
    	.i_TEMP_DATA_en		(temp_data_vld),
    	.o_fan_pwren		(cha_fan_pwm)
    );

    vio_TDI_sim_param vio_TDI_sim_param (
	  .clk							(sysclk_200),                // input wire clk
	  .probe_out0					(sim_part_valid_line_cnt),	// output wire [31 : 0] probe_out0
	  .probe_out1					(sim_track_valid_line_cnt),  // output wire [31 : 0] probe_out0
	  .probe_out2					(sim_track_total_line_cnt),  // output wire [31 : 0] probe_out1
	  .probe_out3					(TDI_sim_start),
	  .probe_out4					(TDI_sim_start_auto),
	  .probe_out5					(track_num_per_IMC),
	  .probe_out6					(info_enable),
	  .probe_out7					(IMC_NUM),
	  .probe_out8					(eth_interval_cnt),
	  .probe_out9					(TDI_max_speed_mode),
	  .probe_out10					(track_num_per_wafer)
	);

end
else begin
	assign sim_part_valid_line_cnt=`SIM_PART_LINE;
	assign sim_track_valid_line_cnt=`SIM_TRACK_VALID_LINE;
	assign sim_track_total_line_cnt=`SIM_TRACK_LINE_CNT;
	assign track_num_per_IMC=`SIM_TRACK_PER_IMC;
	assign info_enable='h1;
	assign IMC_NUM=`SIM_IMC_NUM;
	assign eth_interval_cnt=32'h1;
	assign track_num_per_wafer=16'd80;
end
endgenerate

//	ila_0 ila_0 (
//		.clk				(sysclk_100), // input wire clk
//		.probe0				(temp_data_vld),
//		.probe1				(temp_data),
//		.probe2				(cha_fan_pwm)
//	);

    
    TDI_data_proc_top TDI_data_proc_top
   	(
   		.clk							(sysclk_200					),
   		.clk_300						(sysclk_300					),
   		.rst							(rst						),
   		.TDI_sim_start					(TDI_sim_start				),
   		.TDI_sim_start_auto				(TDI_sim_start_auto			),
   		.db_write_enable				(db_write_enable_1 && db_write_enable_2),
   		.TDI_max_speed_mode				(TDI_max_speed_mode			),
   		
   		
   		.TDI_axis_tdata_0				(TDI_m_axis_tdata_0 		),
   		.TDI_axis_tvalid_0 				(TDI_m_axis_tvalid_0 		),
   		.TDI_axis_tready_0				(TDI_m_axis_tready_0 		),
   		.TDI_axis_tlast_0 				(TDI_m_axis_tlast_0 		),
   		
   		.TDI_axis_tdata_1				(TDI_m_axis_tdata_1 		),
   		.TDI_axis_tvalid_1 				(TDI_m_axis_tvalid_1 		),
   		.TDI_axis_tready_1				(TDI_m_axis_tready_1 		),
   		.TDI_axis_tlast_1 				(TDI_m_axis_tlast_1 		),
   		
   		.TDI_fifo_prog_full				(TDI_m_fifo_prog_full		),
   		
   		.sim_part_valid_line_cnt		(sim_part_valid_line_cnt	),
   		.sim_track_valid_line_cnt		(sim_track_valid_line_cnt	),
   		.sim_track_total_line_cnt		(sim_track_total_line_cnt	),
   		
   		.TDI_trigger					(TDI_trigger				),
   		.track_tlast					(track_tlast				),
   		.part_num						(part_num					),
   		.first_part_flag				(first_part_flag			)
   	);

   INFO_data_sim INFO_data_sim
   	(
   		.clk							(sysclk_200					),
   		.rst							(rst						),
   		
   		.TDI_trigger					(TDI_trigger				),
   		.track_tlast					(track_tlast				),
   		
   		.INFO_axis_tdata				(INFO_m_axis_tdata 			),
   		.INFO_axis_tvalid 				(INFO_m_axis_tvalid 		),
   		.INFO_axis_tready				(INFO_m_axis_tready 		),
   		.INFO_axis_tlast 				(INFO_m_axis_tlast 			),
   		.INFO_fifo_prog_full			(INFO_m_fifo_prog_full		),

   		.sim_track_valid_line_cnt		(sim_track_valid_line_cnt	),
   		.sim_track_total_line_cnt		(sim_track_total_line_cnt	)

   	);	
   	
`ifdef	RDMA_CHANNEL_1
    RDMA_proc_top
    #(
        .C_AXI_ADDR_WIDTH               (DDR_C_AXI_ADDR_WIDTH   ),
        .SIM                            (SIM                    ),
        .CHANNEL_NUM                    (0                    	)
    )RDMA_proc_top_0
    (
        .sysclk_100                     (sysclk_100             ),
        .sysclk_200                     (sysclk_200             ),
		.rst							(rst					),
        
        .gt_rxp_in                      (gt_226_rxp_in          ),
        .gt_rxn_in                      (gt_226_rxn_in          ),
        .gt_txp_out                     (gt_226_txp_out         ),
        .gt_txn_out                     (gt_226_txn_out         ),
        .gt_ref_clk_p                   (gt_226_ref_clk_p       ),
        .gt_ref_clk_n                   (gt_226_ref_clk_n       ),
        
        .IMC_NUM						(IMC_NUM				),
        .track_num_per_IMC				(track_num_per_IMC		),
        .sim_part_valid_line_cnt        (sim_part_valid_line_cnt),
        .info_enable                    (info_enable            ),
        .db_write_enable				(db_write_enable_1		),
        .eth_interval_cnt				(eth_interval_cnt		),
        .track_num_per_wafer			(track_num_per_wafer	),
        
        .TDI_trigger					(TDI_trigger			),
        .track_tlast					(track_tlast			),
        .part_num						(part_num				),
   		.first_part_flag				(first_part_flag		),
        
        .TDI_axis_tdata					(TDI_m_axis_tdata_0		),
		.TDI_axis_tvalid				(TDI_m_axis_tvalid_0	),
		.TDI_axis_tready				(TDI_m_axis_tready_0	),
		.TDI_axis_tlast					(TDI_m_axis_tlast_0		),
		.TDI_fifo_prog_full				(TDI_m_fifo_prog_full	),
		
		.INFO_axis_tdata				(INFO_m_axis_tdata 		),
   		.INFO_axis_tvalid 				(INFO_m_axis_tvalid 	),
   		.INFO_axis_tready				(INFO_m_axis_tready 	),
   		.INFO_axis_tlast 				(INFO_m_axis_tlast 		),
   		.INFO_fifo_prog_full			(INFO_m_fifo_prog_full	),
        
        .c_sys_clk_p                    (c0_sys_clk_p           ),
        .c_sys_clk_n                    (c0_sys_clk_n           ),
		
		.c_ddr4_act_n          		     (c0_ddr4_act_n          ),
		.c_ddr4_adr            		     (c0_ddr4_adr            ),
		.c_ddr4_ba             		     (c0_ddr4_ba             ),
		.c_ddr4_bg             		     (c0_ddr4_bg             ),
		.c_ddr4_cke            		     (c0_ddr4_cke            ),
		.c_ddr4_odt            		     (c0_ddr4_odt            ),
		.c_ddr4_cs_n           		     (c0_ddr4_cs_n           ),
		.c_ddr4_ck_t           		     (c0_ddr4_ck_t           ),
		.c_ddr4_ck_c           		     (c0_ddr4_ck_c           ),
		.c_ddr4_reset_n        		     (c0_ddr4_reset_n        ),
		.c_ddr4_dm_dbi_n       		     (c0_ddr4_dm_dbi_n       ),
		.c_ddr4_dq             		     (c0_ddr4_dq             ),
		.c_ddr4_dqs_c          		     (c0_ddr4_dqs_c          ),
		.c_ddr4_dqs_t          		     (c0_ddr4_dqs_t          )

    );
`endif
 
 `ifdef RDMA_CHANNEL_2   
    RDMA_proc_top
    #(
        .C_AXI_ADDR_WIDTH               (DDR_C_AXI_ADDR_WIDTH   ),
        .SIM                            (SIM                    ),
        .CHANNEL_NUM                    (1                    	)
    )RDMA_proc_top_1
    (
        .sysclk_100                     (sysclk_100             ),
        .sysclk_200                     (sysclk_200             ),
		.rst							(rst					),
        
        .gt_rxp_in                      (gt_227_rxp_in          ),
        .gt_rxn_in                      (gt_227_rxn_in          ),
        .gt_txp_out                     (gt_227_txp_out         ),
        .gt_txn_out                     (gt_227_txn_out         ),
        .gt_ref_clk_p                   (gt_227_ref_clk_p       ),
        .gt_ref_clk_n                   (gt_227_ref_clk_n       ),
        
        .IMC_NUM						(IMC_NUM				),
        .track_num_per_IMC				(track_num_per_IMC		),
        .sim_part_valid_line_cnt        (sim_part_valid_line_cnt),
        .info_enable                    ('h0            		),
        .db_write_enable				(db_write_enable_2		),
        .eth_interval_cnt				(eth_interval_cnt		),
        .track_num_per_wafer			(track_num_per_wafer	),
        
        .TDI_trigger					(TDI_trigger			),
        .track_tlast					(track_tlast			),
        .part_num						(part_num				),
   		.first_part_flag				(first_part_flag		),
        
        .TDI_axis_tdata					(TDI_m_axis_tdata_1		),
		.TDI_axis_tvalid				(TDI_m_axis_tvalid_1	),
		.TDI_axis_tready				(TDI_m_axis_tready_1	),
		.TDI_axis_tlast					(TDI_m_axis_tlast_1		),
		.TDI_fifo_prog_full				(TDI_m_fifo_prog_full	),
		
		.INFO_axis_tdata				('h0 					),
   		.INFO_axis_tvalid 				('h0 					),
   		.INFO_axis_tready				( 						),
   		.INFO_axis_tlast 				('h0 					),
   		.INFO_fifo_prog_full			('h0					),
        
        .c_sys_clk_p                    (c1_sys_clk_p           ),
        .c_sys_clk_n                    (c1_sys_clk_n           ),
		
		.c_ddr4_act_n          		     (c1_ddr4_act_n          ),
		.c_ddr4_adr            		     (c1_ddr4_adr            ),
		.c_ddr4_ba             		     (c1_ddr4_ba             ),
		.c_ddr4_bg             		     (c1_ddr4_bg             ),
		.c_ddr4_cke            		     (c1_ddr4_cke            ),
		.c_ddr4_odt            		     (c1_ddr4_odt            ),
		.c_ddr4_cs_n           		     (c1_ddr4_cs_n           ),
		.c_ddr4_ck_t           		     (c1_ddr4_ck_t           ),
		.c_ddr4_ck_c           		     (c1_ddr4_ck_c           ),
		.c_ddr4_reset_n        		     (c1_ddr4_reset_n        ),
		.c_ddr4_dm_dbi_n       		     (c1_ddr4_dm_dbi_n       ),
		.c_ddr4_dq             		     (c1_ddr4_dq             ),
		.c_ddr4_dqs_c          		     (c1_ddr4_dqs_c          ),
		.c_ddr4_dqs_t          		     (c1_ddr4_dqs_t          )

    );
`endif    
    
     
     
	
    
    
    
    /*cmac_usplus_top
	#(
		.BANK		(227)
	)cmac_usplus_top_227
	(
		.gt_rxp_in				(gt_227_rxp_in				),
		.gt_rxn_in				(gt_227_rxn_in				),
		.gt_txp_out				(gt_227_txp_out				),
		.gt_txn_out				(gt_227_txn_out				),
    	.sys_reset 				(rst						),
    	.gt_ref_clk_p			(gt_227_ref_clk_p			),
    	.gt_ref_clk_n			(gt_227_ref_clk_n			),
    	.init_clk				(sysclk_100					)
    
    );*/


    
endmodule
