`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/20 10:30:26
// Design Name: 
// Module Name: cmac_usplus_top
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


module cmac_usplus_top
#(
	parameter BANK=226
)(
    input  [3 :0]   gt_rxp_in,
    input  [3 :0]   gt_rxn_in,
    output [3 :0]   gt_txp_out,
    output [3 :0]   gt_txn_out,

    input  wire     send_continuous_pkts,
    input  wire     lbus_tx_rx_restart_in,
    output wire     tx_done_led,
    output wire     tx_busy_led,

    output wire     rx_gt_locked_led,
    output wire     rx_aligned_led,
    output wire     rx_done_led,
    output wire     rx_data_fail_led,
    output wire     rx_busy_led,

    input  wire     sys_reset,
    output			gt_reset_out,

    input  wire     gt_ref_clk_p,
    input  wire     gt_ref_clk_n,
    input  wire     init_clk,
    
    output             			tx_usr_axis_tready, 
    input              			tx_usr_axis_tvalid,
    input  		[511:0]    		tx_usr_axis_tdata,
    input             			tx_usr_axis_tlast,
    input  		[63:0]     		tx_usr_axis_tkeep,
    output						tx_clk,
    
    output              		rx_usr_axis_tvalid,
    output  	[511:0]    		rx_usr_axis_tdata,
    output             			rx_usr_axis_tlast,
    output  	[63:0]     		rx_usr_axis_tkeep,
    output						rx_clk,
    
    (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *) output logic [7:0]	stat_rx_pause_req,
    
    (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *) output logic [31:0]	cmac_tx_pkt_cnt=0,
    (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *) output logic	[31:0]	cmac_rx_pkt_cnt=0
    
);

  wire [11 :0]    gt_loopback_in;

  //// For other GT loopback options please change the value appropriately
  //// For example, for Near End PMA loopback for 4 Lanes update the gt_loopback_in = {4{3'b010}};
  //// For more information and settings on loopback, refer GT Transceivers user guide

  assign gt_loopback_in  = {4{3'b000}};

  wire            gt_ref_clk_out;
  wire            usr_rx_reset;
  wire            rx_axis_tvalid;
  wire [511:0]    rx_axis_tdata;
  wire            rx_axis_tlast;
  wire [63:0]     rx_axis_tkeep;
  wire            rx_axis_tuser;

  (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)wire            tx_axis_tready;
 (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *) wire            tx_axis_tvalid;
  wire [511:0]    tx_axis_tdata;
  (* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)wire            tx_axis_tlast;
  wire [63:0]     tx_axis_tkeep;
  wire            tx_axis_tuser;
  wire            tx_ovfout;
  wire            tx_unfout;
  wire [55:0]     tx_preamblein;
  wire            usr_tx_reset;
  wire            rxusrclk2;
  wire            stat_rx_aligned;
  wire            stat_rx_aligned_err;
  wire [2:0]      stat_rx_bad_code;
  wire [2:0]      stat_rx_bad_fcs;
  wire            stat_rx_bad_preamble;
  wire            stat_rx_bad_sfd;
  wire            stat_rx_bip_err_0;
  wire            stat_rx_bip_err_1;
  wire            stat_rx_bip_err_10;
  wire            stat_rx_bip_err_11;
  wire            stat_rx_bip_err_12;
  wire            stat_rx_bip_err_13;
  wire            stat_rx_bip_err_14;
  wire            stat_rx_bip_err_15;
  wire            stat_rx_bip_err_16;
  wire            stat_rx_bip_err_17;
  wire            stat_rx_bip_err_18;
  wire            stat_rx_bip_err_19;
  wire            stat_rx_bip_err_2;
  wire            stat_rx_bip_err_3;
  wire            stat_rx_bip_err_4;
  wire            stat_rx_bip_err_5;
  wire            stat_rx_bip_err_6;
  wire            stat_rx_bip_err_7;
  wire            stat_rx_bip_err_8;
  wire            stat_rx_bip_err_9;
  wire [19:0]     stat_rx_block_lock;
  wire            stat_rx_broadcast;
  wire [2:0]      stat_rx_fragment;
  wire [1:0]      stat_rx_framing_err_0;
  wire [1:0]      stat_rx_framing_err_1;
  wire [1:0]      stat_rx_framing_err_10;
  wire [1:0]      stat_rx_framing_err_11;
  wire [1:0]      stat_rx_framing_err_12;
  wire [1:0]      stat_rx_framing_err_13;
  wire [1:0]      stat_rx_framing_err_14;
  wire [1:0]      stat_rx_framing_err_15;
  wire [1:0]      stat_rx_framing_err_16;
  wire [1:0]      stat_rx_framing_err_17;
  wire [1:0]      stat_rx_framing_err_18;
  wire [1:0]      stat_rx_framing_err_19;
  wire [1:0]      stat_rx_framing_err_2;
  wire [1:0]      stat_rx_framing_err_3;
  wire [1:0]      stat_rx_framing_err_4;
  wire [1:0]      stat_rx_framing_err_5;
  wire [1:0]      stat_rx_framing_err_6;
  wire [1:0]      stat_rx_framing_err_7;
  wire [1:0]      stat_rx_framing_err_8;
  wire [1:0]      stat_rx_framing_err_9;
  wire            stat_rx_framing_err_valid_0;
  wire            stat_rx_framing_err_valid_1;
  wire            stat_rx_framing_err_valid_10;
  wire            stat_rx_framing_err_valid_11;
  wire            stat_rx_framing_err_valid_12;
  wire            stat_rx_framing_err_valid_13;
  wire            stat_rx_framing_err_valid_14;
  wire            stat_rx_framing_err_valid_15;
  wire            stat_rx_framing_err_valid_16;
  wire            stat_rx_framing_err_valid_17;
  wire            stat_rx_framing_err_valid_18;
  wire            stat_rx_framing_err_valid_19;
  wire            stat_rx_framing_err_valid_2;
  wire            stat_rx_framing_err_valid_3;
  wire            stat_rx_framing_err_valid_4;
  wire            stat_rx_framing_err_valid_5;
  wire            stat_rx_framing_err_valid_6;
  wire            stat_rx_framing_err_valid_7;
  wire            stat_rx_framing_err_valid_8;
  wire            stat_rx_framing_err_valid_9;
  wire            stat_rx_got_signal_os;
  wire            stat_rx_hi_ber;
  wire            stat_rx_inrangeerr;
  wire            stat_rx_internal_local_fault;
  wire            stat_rx_jabber;
  wire            stat_rx_local_fault;
  wire [19:0]     stat_rx_mf_err;
  wire [19:0]     stat_rx_mf_len_err;
  wire [19:0]     stat_rx_mf_repeat_err;
  wire            stat_rx_misaligned;
  wire            stat_rx_multicast;
  wire            stat_rx_oversize;
  wire            stat_rx_packet_1024_1518_bytes;
  wire            stat_rx_packet_128_255_bytes;
  wire            stat_rx_packet_1519_1522_bytes;
  wire            stat_rx_packet_1523_1548_bytes;
  wire            stat_rx_packet_1549_2047_bytes;
  wire            stat_rx_packet_2048_4095_bytes;
  wire            stat_rx_packet_256_511_bytes;
  wire            stat_rx_packet_4096_8191_bytes;
  wire            stat_rx_packet_512_1023_bytes;
  wire            stat_rx_packet_64_bytes;
  wire            stat_rx_packet_65_127_bytes;
  wire            stat_rx_packet_8192_9215_bytes;
  wire            stat_rx_packet_bad_fcs;
  wire            stat_rx_packet_large;
  wire [2:0]      stat_rx_packet_small;
  wire            stat_rx_received_local_fault;
  wire            stat_rx_remote_fault;
  wire            stat_rx_status;
  wire [2:0]      stat_rx_stomped_fcs;
  wire [19:0]     stat_rx_synced;
  wire [19:0]     stat_rx_synced_err;
  wire [2:0]      stat_rx_test_pattern_mismatch;
  wire            stat_rx_toolong;
  wire [6:0]      stat_rx_total_bytes;
  wire [13:0]     stat_rx_total_good_bytes;
  wire            stat_rx_total_good_packets;
  wire [2:0]      stat_rx_total_packets;
  wire            stat_rx_truncated;
  wire [2:0]      stat_rx_undersize;
  wire            stat_rx_unicast;
  wire            stat_rx_vlan;
  wire [19:0]     stat_rx_pcsl_demuxed;
  wire [4:0]      stat_rx_pcsl_number_0;
  wire [4:0]      stat_rx_pcsl_number_1;
  wire [4:0]      stat_rx_pcsl_number_10;
  wire [4:0]      stat_rx_pcsl_number_11;
  wire [4:0]      stat_rx_pcsl_number_12;
  wire [4:0]      stat_rx_pcsl_number_13;
  wire [4:0]      stat_rx_pcsl_number_14;
  wire [4:0]      stat_rx_pcsl_number_15;
  wire [4:0]      stat_rx_pcsl_number_16;
  wire [4:0]      stat_rx_pcsl_number_17;
  wire [4:0]      stat_rx_pcsl_number_18;
  wire [4:0]      stat_rx_pcsl_number_19;
  wire [4:0]      stat_rx_pcsl_number_2;
  wire [4:0]      stat_rx_pcsl_number_3;
  wire [4:0]      stat_rx_pcsl_number_4;
  wire [4:0]      stat_rx_pcsl_number_5;
  wire [4:0]      stat_rx_pcsl_number_6;
  wire [4:0]      stat_rx_pcsl_number_7;
  wire [4:0]      stat_rx_pcsl_number_8;
  wire [4:0]      stat_rx_pcsl_number_9;
  wire            stat_tx_bad_fcs;
  wire            stat_tx_broadcast;
  wire            stat_tx_frame_error;
  wire            stat_tx_local_fault;
  wire            stat_tx_multicast;
  wire            stat_tx_packet_1024_1518_bytes;
  wire            stat_tx_packet_128_255_bytes;
  wire            stat_tx_packet_1519_1522_bytes;
  wire            stat_tx_packet_1523_1548_bytes;
  wire            stat_tx_packet_1549_2047_bytes;
  wire            stat_tx_packet_2048_4095_bytes;
  wire            stat_tx_packet_256_511_bytes;
  wire            stat_tx_packet_4096_8191_bytes;
  wire            stat_tx_packet_512_1023_bytes;
  wire            stat_tx_packet_64_bytes;
  wire            stat_tx_packet_65_127_bytes;
  wire            stat_tx_packet_8192_9215_bytes;
  wire            stat_tx_packet_large;
  wire            stat_tx_packet_small;
  wire [5:0]      stat_tx_total_bytes;
  wire [13:0]     stat_tx_total_good_bytes;
  wire            stat_tx_total_good_packets;
  wire            stat_tx_total_packets;
  wire            stat_tx_unicast;
  wire            stat_tx_vlan;

  wire [7:0]      rx_otn_bip8_0;
  wire [7:0]      rx_otn_bip8_1;
  wire [7:0]      rx_otn_bip8_2;
  wire [7:0]      rx_otn_bip8_3;
  wire [7:0]      rx_otn_bip8_4;
  wire [65:0]     rx_otn_data_0;
  wire [65:0]     rx_otn_data_1;
  wire [65:0]     rx_otn_data_2;
  wire [65:0]     rx_otn_data_3;
  wire [65:0]     rx_otn_data_4;
  wire            rx_otn_ena;
  wire            rx_otn_lane0;
  wire            rx_otn_vlmarker;
  wire [55:0]     rx_preambleout;


  wire            ctl_rx_enable;
  wire            ctl_rx_force_resync;
  wire            ctl_rx_test_pattern;
  wire            ctl_tx_enable;
  wire            ctl_tx_test_pattern;
  wire            ctl_tx_send_idle;
  wire            ctl_tx_send_rfi;
  wire            ctl_tx_send_lfi;
  wire            rx_reset;
  wire            tx_reset;
  wire [3 :0]     gt_rxrecclkout;
  wire [3 :0]     gt_powergoodout;
  wire            gtwiz_reset_tx_datapath;
  wire            gtwiz_reset_rx_datapath;
  wire            txusrclk2;
  
  /*	rx pause BANK 	*/
	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)	logic [15:0]	stat_rx_pause_quanta0;
	
	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)	logic [7:0]		stat_rx_pause_valid;
	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)	logic 			stat_rx_user_pause;
	(* MARK_DEBUG="true" *)(* DONT_TOUCH = "true" *)	logic 			stat_rx_pause;
//	logic	tx_usr_axis_tready_config;
//	logic	tx_usr_axis_tvalid_config;

	assign gtwiz_reset_tx_datapath    = 1'b0;
	assign gtwiz_reset_rx_datapath    = 1'b0;
	assign tx_clk=txusrclk2;
	assign gt_reset_out=usr_rx_reset | usr_tx_reset;
	
//	assign tx_usr_axis_tready=tx_usr_axis_tready_config && (!stat_rx_pause_req[0]);
//	assign tx_usr_axis_tvalid_config=tx_usr_axis_tvalid && (!stat_rx_pause_req[0]);

//generate
//if(BANK==226) begin
cmac_usplus cmac_usplus_226
(
    .gt_rxp_in                            	(gt_rxp_in),
    .gt_rxn_in                            	(gt_rxn_in),
    .gt_txp_out                           	(gt_txp_out),
    .gt_txn_out                           	(gt_txn_out),
    .gt_txusrclk2                         	(txusrclk2),
    .gt_loopback_in                       	(gt_loopback_in),
    .gt_rxrecclkout                       	(gt_rxrecclkout),
    .gt_powergoodout                      	(gt_powergoodout),
    .gtwiz_reset_tx_datapath              	(gtwiz_reset_tx_datapath),
    .gtwiz_reset_rx_datapath              	(gtwiz_reset_rx_datapath),
    .ctl_tx_rsfec_enable					(1),                                    // input wire ctl_tx_rsfec_enable
  	.ctl_rx_rsfec_enable					(1),                                    // input wire ctl_rx_rsfec_enable
  	.ctl_rx_rsfec_enable_correction			(1),              // input wire ctl_rx_rsfec_enable_correction
  	.ctl_rx_rsfec_enable_indication			(1),              // input wire ctl_rx_rsfec_enable_indication
    .sys_reset                            	(sys_reset),
    .gt_ref_clk_p                         	(gt_ref_clk_p),
    .gt_ref_clk_n                         	(gt_ref_clk_n),
    .init_clk                             	(init_clk),
    .gt_ref_clk_out                       	(gt_ref_clk_out),

    .rx_axis_tvalid                       	(rx_axis_tvalid),
    .rx_axis_tdata                        	(rx_axis_tdata),
    .rx_axis_tkeep                        	(rx_axis_tkeep),
    .rx_axis_tlast                        	(rx_axis_tlast),
    .rx_axis_tuser                        	(rx_axis_tuser),
    .rx_otn_bip8_0                        	(rx_otn_bip8_0),
    .rx_otn_bip8_1                        	(rx_otn_bip8_1),
    .rx_otn_bip8_2                        	(rx_otn_bip8_2),
    .rx_otn_bip8_3                        	(rx_otn_bip8_3),
    .rx_otn_bip8_4                        	(rx_otn_bip8_4),
    .rx_otn_data_0                        	(rx_otn_data_0),
    .rx_otn_data_1                        	(rx_otn_data_1),
    .rx_otn_data_2                        	(rx_otn_data_2),
    .rx_otn_data_3                        	(rx_otn_data_3),
    .rx_otn_data_4                        	(rx_otn_data_4),
    .rx_otn_ena                           	(rx_otn_ena),
    .rx_otn_lane0                         	(rx_otn_lane0),
    .rx_otn_vlmarker                      	(rx_otn_vlmarker),
    .rx_preambleout                       	(rx_preambleout),
    .usr_rx_reset                         	(usr_rx_reset),
    .gt_rxusrclk2                         	(rxusrclk2),
    .stat_rx_aligned                      	(stat_rx_aligned),
    .stat_rx_aligned_err                  	(stat_rx_aligned_err),
    .stat_rx_bad_code                     	(stat_rx_bad_code),
    .stat_rx_bad_fcs                      	(stat_rx_bad_fcs),
    .stat_rx_bad_preamble                 	(stat_rx_bad_preamble),
    .stat_rx_bad_sfd                      	(stat_rx_bad_sfd),
    .stat_rx_bip_err_0                    	(stat_rx_bip_err_0),
    .stat_rx_bip_err_1                    	(stat_rx_bip_err_1),
    .stat_rx_bip_err_10                   	(stat_rx_bip_err_10),
    .stat_rx_bip_err_11                   	(stat_rx_bip_err_11),
    .stat_rx_bip_err_12                   	(stat_rx_bip_err_12),
    .stat_rx_bip_err_13                   	(stat_rx_bip_err_13),
    .stat_rx_bip_err_14                   	(stat_rx_bip_err_14),
    .stat_rx_bip_err_15                   	(stat_rx_bip_err_15),
    .stat_rx_bip_err_16                   	(stat_rx_bip_err_16),
    .stat_rx_bip_err_17                   	(stat_rx_bip_err_17),
    .stat_rx_bip_err_18                   	(stat_rx_bip_err_18),
    .stat_rx_bip_err_19                   	(stat_rx_bip_err_19),
    .stat_rx_bip_err_2                    	(stat_rx_bip_err_2),
    .stat_rx_bip_err_3                    	(stat_rx_bip_err_3),
    .stat_rx_bip_err_4                    	(stat_rx_bip_err_4),
    .stat_rx_bip_err_5                    	(stat_rx_bip_err_5),
    .stat_rx_bip_err_6                    	(stat_rx_bip_err_6),
    .stat_rx_bip_err_7                    	(stat_rx_bip_err_7),
    .stat_rx_bip_err_8                    	(stat_rx_bip_err_8),
    .stat_rx_bip_err_9                    	(stat_rx_bip_err_9),
    .stat_rx_block_lock                   	(stat_rx_block_lock),
    .stat_rx_broadcast                    	(stat_rx_broadcast),
    .stat_rx_fragment                     	(stat_rx_fragment),
    .stat_rx_framing_err_0                	(stat_rx_framing_err_0),
    .stat_rx_framing_err_1                	(stat_rx_framing_err_1),
    .stat_rx_framing_err_10               	(stat_rx_framing_err_10),
    .stat_rx_framing_err_11               	(stat_rx_framing_err_11),
    .stat_rx_framing_err_12               	(stat_rx_framing_err_12),
    .stat_rx_framing_err_13               	(stat_rx_framing_err_13),
    .stat_rx_framing_err_14               	(stat_rx_framing_err_14),
    .stat_rx_framing_err_15               	(stat_rx_framing_err_15),
    .stat_rx_framing_err_16               	(stat_rx_framing_err_16),
    .stat_rx_framing_err_17               	(stat_rx_framing_err_17),
    .stat_rx_framing_err_18               	(stat_rx_framing_err_18),
    .stat_rx_framing_err_19               	(stat_rx_framing_err_19),
    .stat_rx_framing_err_2                	(stat_rx_framing_err_2),
    .stat_rx_framing_err_3                	(stat_rx_framing_err_3),
    .stat_rx_framing_err_4                	(stat_rx_framing_err_4),
    .stat_rx_framing_err_5                	(stat_rx_framing_err_5),
    .stat_rx_framing_err_6                	(stat_rx_framing_err_6),
    .stat_rx_framing_err_7                	(stat_rx_framing_err_7),
    .stat_rx_framing_err_8                	(stat_rx_framing_err_8),
    .stat_rx_framing_err_9                	(stat_rx_framing_err_9),
    .stat_rx_framing_err_valid_0          	(stat_rx_framing_err_valid_0),
    .stat_rx_framing_err_valid_1          	(stat_rx_framing_err_valid_1),
    .stat_rx_framing_err_valid_10         	(stat_rx_framing_err_valid_10),
    .stat_rx_framing_err_valid_11         	(stat_rx_framing_err_valid_11),
    .stat_rx_framing_err_valid_12         	(stat_rx_framing_err_valid_12),
    .stat_rx_framing_err_valid_13         	(stat_rx_framing_err_valid_13),
    .stat_rx_framing_err_valid_14         	(stat_rx_framing_err_valid_14),
    .stat_rx_framing_err_valid_15         	(stat_rx_framing_err_valid_15),
    .stat_rx_framing_err_valid_16         	(stat_rx_framing_err_valid_16),
    .stat_rx_framing_err_valid_17         	(stat_rx_framing_err_valid_17),
    .stat_rx_framing_err_valid_18         	(stat_rx_framing_err_valid_18),
    .stat_rx_framing_err_valid_19         	(stat_rx_framing_err_valid_19),
    .stat_rx_framing_err_valid_2          	(stat_rx_framing_err_valid_2),
    .stat_rx_framing_err_valid_3          	(stat_rx_framing_err_valid_3),
    .stat_rx_framing_err_valid_4          	(stat_rx_framing_err_valid_4),
    .stat_rx_framing_err_valid_5          	(stat_rx_framing_err_valid_5),
    .stat_rx_framing_err_valid_6          	(stat_rx_framing_err_valid_6),
    .stat_rx_framing_err_valid_7          	(stat_rx_framing_err_valid_7),
    .stat_rx_framing_err_valid_8          	(stat_rx_framing_err_valid_8),
    .stat_rx_framing_err_valid_9          	(stat_rx_framing_err_valid_9),
    .stat_rx_got_signal_os                	(stat_rx_got_signal_os),
    .stat_rx_hi_ber                       	(stat_rx_hi_ber),
    .stat_rx_inrangeerr                   	(stat_rx_inrangeerr),
    .stat_rx_internal_local_fault         	(stat_rx_internal_local_fault),
    .stat_rx_jabber                       	(stat_rx_jabber),
    .stat_rx_local_fault                  	(stat_rx_local_fault),
    .stat_rx_mf_err                       	(stat_rx_mf_err),
    .stat_rx_mf_len_err                   	(stat_rx_mf_len_err),
    .stat_rx_mf_repeat_err                	(stat_rx_mf_repeat_err),
    .stat_rx_misaligned                   	(stat_rx_misaligned),
    .stat_rx_multicast                    	(stat_rx_multicast),
    .stat_rx_oversize                     	(stat_rx_oversize),
    .stat_rx_packet_1024_1518_bytes       	(stat_rx_packet_1024_1518_bytes),
    .stat_rx_packet_128_255_bytes         	(stat_rx_packet_128_255_bytes),
    .stat_rx_packet_1519_1522_bytes       	(stat_rx_packet_1519_1522_bytes),
    .stat_rx_packet_1523_1548_bytes       	(stat_rx_packet_1523_1548_bytes),
    .stat_rx_packet_1549_2047_bytes       	(stat_rx_packet_1549_2047_bytes),
    .stat_rx_packet_2048_4095_bytes       	(stat_rx_packet_2048_4095_bytes),
    .stat_rx_packet_256_511_bytes         	(stat_rx_packet_256_511_bytes),
    .stat_rx_packet_4096_8191_bytes       	(stat_rx_packet_4096_8191_bytes),
    .stat_rx_packet_512_1023_bytes        	(stat_rx_packet_512_1023_bytes),
    .stat_rx_packet_64_bytes              	(stat_rx_packet_64_bytes),
    .stat_rx_packet_65_127_bytes          	(stat_rx_packet_65_127_bytes),
    .stat_rx_packet_8192_9215_bytes       	(stat_rx_packet_8192_9215_bytes),
    .stat_rx_packet_bad_fcs               	(stat_rx_packet_bad_fcs),
    .stat_rx_packet_large                 	(stat_rx_packet_large),
    .stat_rx_packet_small                 	(stat_rx_packet_small),
    
/*	RX PAUSE FRAME */
	.stat_rx_pause							(stat_rx_pause			),                                                // output wire stat_rx_pause
	.stat_rx_pause_quanta0					(stat_rx_pause_quanta0	),                                // output wire [15 : 0] stat_rx_pause_quanta0
	.stat_rx_pause_quanta1					(),                                						// output wire [15 : 0] stat_rx_pause_quanta1
	.stat_rx_pause_quanta2					(),                                						// output wire [15 : 0] stat_rx_pause_quanta2
	.stat_rx_pause_quanta3					(),                                						// output wire [15 : 0] stat_rx_pause_quanta3
	.stat_rx_pause_quanta4					(),                                						// output wire [15 : 0] stat_rx_pause_quanta4
	.stat_rx_pause_quanta5					(),                                						// output wire [15 : 0] stat_rx_pause_quanta5
	.stat_rx_pause_quanta6					(),                                						// output wire [15 : 0] stat_rx_pause_quanta6
	.stat_rx_pause_quanta7					(),                                						// output wire [15 : 0] stat_rx_pause_quanta7
	.stat_rx_pause_quanta8					(),                                						// output wire [15 : 0] stat_rx_pause_quanta8
	.stat_rx_pause_req						(stat_rx_pause_req		),                                        // output wire [8 : 0] stat_rx_pause_req
	.stat_rx_pause_valid					(stat_rx_pause_valid	),                                    // output wire [8 : 0] stat_rx_pause_valid
	.stat_rx_user_pause						(stat_rx_user_pause		),                                      // output wire stat_rx_user_pause
	.ctl_rx_check_etype_gcp					(1'b1					),                              // input wire ctl_rx_check_etype_gcp
	.ctl_rx_check_etype_gpp					(1'b1					),                              // input wire ctl_rx_check_etype_gpp
	.ctl_rx_check_etype_pcp					(1'b1					),                              // input wire ctl_rx_check_etype_pcp
	.ctl_rx_check_etype_ppp					(1'b1					),                              // input wire ctl_rx_check_etype_ppp
	.ctl_rx_check_mcast_gcp					(1'b0					),                              // input wire ctl_rx_check_mcast_gcp
	.ctl_rx_check_mcast_gpp					(1'b0					),                              // input wire ctl_rx_check_mcast_gpp
	.ctl_rx_check_mcast_pcp					(1'b0					),                              // input wire ctl_rx_check_mcast_pcp
	.ctl_rx_check_mcast_ppp					(1'b0					),                              // input wire ctl_rx_check_mcast_ppp
	.ctl_rx_check_opcode_gcp				(1'b1					),                            // input wire ctl_rx_check_opcode_gcp
	.ctl_rx_check_opcode_gpp				(1'b1					),                            // input wire ctl_rx_check_opcode_gpp
	.ctl_rx_check_opcode_pcp				(1'b1					),                            // input wire ctl_rx_check_opcode_pcp
	.ctl_rx_check_opcode_ppp				(1'b1					),                            // input wire ctl_rx_check_opcode_ppp
	.ctl_rx_check_sa_gcp					(1'b0					),                                    // input wire ctl_rx_check_sa_gcp
	.ctl_rx_check_sa_gpp					(1'b0					),                                    // input wire ctl_rx_check_sa_gpp
	.ctl_rx_check_sa_pcp					(1'b0					),                                    // input wire ctl_rx_check_sa_pcp
	.ctl_rx_check_sa_ppp					(1'b0					),                                    // input wire ctl_rx_check_sa_ppp
	.ctl_rx_check_ucast_gcp					(1'b0					),                              // input wire ctl_rx_check_ucast_gcp
	.ctl_rx_check_ucast_gpp					(1'b0					),                              // input wire ctl_rx_check_ucast_gpp
	.ctl_rx_check_ucast_pcp					(1'b0					),                              // input wire ctl_rx_check_ucast_pcp
	.ctl_rx_check_ucast_ppp					(1'b0					),                              // input wire ctl_rx_check_ucast_ppp
	.ctl_rx_enable_gcp						(1'b1					),                                        // input wire ctl_rx_enable_gcp
	.ctl_rx_enable_gpp						(1'b1					),                                        // input wire ctl_rx_enable_gpp
	.ctl_rx_enable_pcp						(1'b1					),                                        // input wire ctl_rx_enable_pcp
	.ctl_rx_enable_ppp						(1'b1					),                                        // input wire ctl_rx_enable_ppp
	.ctl_rx_pause_ack						(9'h0					),                                          // input wire [8 : 0] ctl_rx_pause_ack
	.ctl_rx_pause_enable					(9'h1					),                                    // input wire [8 : 0] ctl_rx_pause_enable    
/****************************/				

    .ctl_rx_enable                        	(ctl_rx_enable),
    .ctl_rx_force_resync                  	(ctl_rx_force_resync),
    .ctl_rx_test_pattern                  	(ctl_rx_test_pattern),
    .core_rx_reset                        	(1'b0),
    .rx_clk                               	(txusrclk2),
    .stat_rx_received_local_fault         	(stat_rx_received_local_fault),
    .stat_rx_remote_fault                 	(stat_rx_remote_fault),
    .stat_rx_status                       	(stat_rx_status),
    .stat_rx_stomped_fcs                  	(stat_rx_stomped_fcs),
    .stat_rx_synced                       	(stat_rx_synced),
    .stat_rx_synced_err                   	(stat_rx_synced_err),
    .stat_rx_test_pattern_mismatch        	(stat_rx_test_pattern_mismatch),
    .stat_rx_toolong                      	(stat_rx_toolong),
    .stat_rx_total_bytes                  	(stat_rx_total_bytes),
    .stat_rx_total_good_bytes             	(stat_rx_total_good_bytes),
    .stat_rx_total_good_packets           	(stat_rx_total_good_packets),
    .stat_rx_total_packets                	(stat_rx_total_packets),
    .stat_rx_truncated                    	(stat_rx_truncated),
    .stat_rx_undersize                    	(stat_rx_undersize),
    .stat_rx_unicast                      	(stat_rx_unicast),
    .stat_rx_vlan                         	(stat_rx_vlan),
    .stat_rx_pcsl_demuxed                 	(stat_rx_pcsl_demuxed),
    .stat_rx_pcsl_number_0                	(stat_rx_pcsl_number_0),
    .stat_rx_pcsl_number_1                	(stat_rx_pcsl_number_1),
    .stat_rx_pcsl_number_10               	(stat_rx_pcsl_number_10),
    .stat_rx_pcsl_number_11               	(stat_rx_pcsl_number_11),
    .stat_rx_pcsl_number_12               	(stat_rx_pcsl_number_12),
    .stat_rx_pcsl_number_13               	(stat_rx_pcsl_number_13),
    .stat_rx_pcsl_number_14               	(stat_rx_pcsl_number_14),
    .stat_rx_pcsl_number_15               	(stat_rx_pcsl_number_15),
    .stat_rx_pcsl_number_16               	(stat_rx_pcsl_number_16),
    .stat_rx_pcsl_number_17               	(stat_rx_pcsl_number_17),
    .stat_rx_pcsl_number_18               	(stat_rx_pcsl_number_18),
    .stat_rx_pcsl_number_19               	(stat_rx_pcsl_number_19),
    .stat_rx_pcsl_number_2                	(stat_rx_pcsl_number_2),
    .stat_rx_pcsl_number_3                	(stat_rx_pcsl_number_3),
    .stat_rx_pcsl_number_4                	(stat_rx_pcsl_number_4),
    .stat_rx_pcsl_number_5                	(stat_rx_pcsl_number_5),
    .stat_rx_pcsl_number_6                	(stat_rx_pcsl_number_6),
    .stat_rx_pcsl_number_7                	(stat_rx_pcsl_number_7),
    .stat_rx_pcsl_number_8                	(stat_rx_pcsl_number_8),
    .stat_rx_pcsl_number_9                	(stat_rx_pcsl_number_9),
    .stat_tx_bad_fcs                      	(stat_tx_bad_fcs),
    .stat_tx_broadcast                    	(stat_tx_broadcast),
    .stat_tx_frame_error                  	(stat_tx_frame_error),
    .stat_tx_local_fault                  	(stat_tx_local_fault),
    .stat_tx_multicast                    	(stat_tx_multicast),
    .stat_tx_packet_1024_1518_bytes       	(stat_tx_packet_1024_1518_bytes),
    .stat_tx_packet_128_255_bytes         	(stat_tx_packet_128_255_bytes),
    .stat_tx_packet_1519_1522_bytes       	(stat_tx_packet_1519_1522_bytes),
    .stat_tx_packet_1523_1548_bytes       	(stat_tx_packet_1523_1548_bytes),
    .stat_tx_packet_1549_2047_bytes       	(stat_tx_packet_1549_2047_bytes),
    .stat_tx_packet_2048_4095_bytes       	(stat_tx_packet_2048_4095_bytes),
    .stat_tx_packet_256_511_bytes         	(stat_tx_packet_256_511_bytes),
    .stat_tx_packet_4096_8191_bytes       	(stat_tx_packet_4096_8191_bytes),
    .stat_tx_packet_512_1023_bytes        	(stat_tx_packet_512_1023_bytes),
    .stat_tx_packet_64_bytes              	(stat_tx_packet_64_bytes),
    .stat_tx_packet_65_127_bytes          	(stat_tx_packet_65_127_bytes),
    .stat_tx_packet_8192_9215_bytes       	(stat_tx_packet_8192_9215_bytes),
    .stat_tx_packet_large                 	(stat_tx_packet_large),
    .stat_tx_packet_small                 	(stat_tx_packet_small),
    .stat_tx_total_bytes                  	(stat_tx_total_bytes),
    .stat_tx_total_good_bytes             	(stat_tx_total_good_bytes),
    .stat_tx_total_good_packets           	(stat_tx_total_good_packets),
    .stat_tx_total_packets                	(stat_tx_total_packets),
    .stat_tx_unicast                      	(stat_tx_unicast),
    .stat_tx_vlan                         	(stat_tx_vlan),


    .ctl_tx_enable                        	(ctl_tx_enable),
    .ctl_tx_test_pattern                  	(ctl_tx_test_pattern),
    .ctl_tx_send_idle                     	(ctl_tx_send_idle),
    .ctl_tx_send_rfi                      	(ctl_tx_send_rfi),
    .ctl_tx_send_lfi                      	(ctl_tx_send_lfi),
    .core_tx_reset                        	(1'b0),
    .tx_axis_tready                       	(tx_axis_tready),
    .tx_axis_tvalid                       	(tx_axis_tvalid),
    .tx_axis_tdata                        	(tx_axis_tdata),
    .tx_axis_tkeep                        	(tx_axis_tkeep),
    .tx_axis_tlast                        	(tx_axis_tlast),
    .tx_axis_tuser                        	(tx_axis_tuser),
    .tx_ovfout                            	(tx_ovfout),
    .tx_unfout                            	(tx_unfout),
    .tx_preamblein                        	(tx_preamblein),
    .usr_tx_reset                         	(usr_tx_reset),


    .core_drp_reset                       	(1'b0),
    .drp_clk                              	(1'b0),
    .drp_addr                             	(10'b0),
    .drp_di                               	(16'b0),
    .drp_en                               	(1'b0),
    .drp_do                               	(),
    .drp_rdy                              	(),
    .drp_we                               	(1'b0)
);

	always_ff@(posedge txusrclk2 or posedge sys_reset)
		if(sys_reset)													cmac_tx_pkt_cnt<=0;
		else if(tx_axis_tready && tx_axis_tvalid && tx_axis_tlast)		cmac_tx_pkt_cnt<=cmac_tx_pkt_cnt+1;

	always_ff@(posedge txusrclk2 or posedge sys_reset)
		if(sys_reset)													cmac_rx_pkt_cnt<=0;
		else if(rx_axis_tvalid && rx_axis_tlast)						cmac_rx_pkt_cnt<=cmac_rx_pkt_cnt+1;

//end
//else if(BANK==227) begin
//cmac_usplus_227 cmac_usplus_227
//(
//    .gt_rxp_in                            (gt_rxp_in),
//    .gt_rxn_in                            (gt_rxn_in),
//    .gt_txp_out                           (gt_txp_out),
//    .gt_txn_out                           (gt_txn_out),
//    .gt_txusrclk2                         (txusrclk2),
//    .gt_loopback_in                       (gt_loopback_in),
//    .gt_rxrecclkout                       (gt_rxrecclkout),
//    .gt_powergoodout                      (gt_powergoodout),
//    .gtwiz_reset_tx_datapath              (gtwiz_reset_tx_datapath),
//    .gtwiz_reset_rx_datapath              (gtwiz_reset_rx_datapath),
//    .sys_reset                            (sys_reset),
//    .gt_ref_clk_p                         (gt_ref_clk_p),
//    .gt_ref_clk_n                         (gt_ref_clk_n),
//    .init_clk                             (init_clk),
//    .gt_ref_clk_out                       (gt_ref_clk_out),

//    .rx_axis_tvalid                       (rx_axis_tvalid),
//    .rx_axis_tdata                        (rx_axis_tdata),
//    .rx_axis_tkeep                        (rx_axis_tkeep),
//    .rx_axis_tlast                        (rx_axis_tlast),
//    .rx_axis_tuser                        (rx_axis_tuser),
//    .rx_otn_bip8_0                        (rx_otn_bip8_0),
//    .rx_otn_bip8_1                        (rx_otn_bip8_1),
//    .rx_otn_bip8_2                        (rx_otn_bip8_2),
//    .rx_otn_bip8_3                        (rx_otn_bip8_3),
//    .rx_otn_bip8_4                        (rx_otn_bip8_4),
//    .rx_otn_data_0                        (rx_otn_data_0),
//    .rx_otn_data_1                        (rx_otn_data_1),
//    .rx_otn_data_2                        (rx_otn_data_2),
//    .rx_otn_data_3                        (rx_otn_data_3),
//    .rx_otn_data_4                        (rx_otn_data_4),
//    .rx_otn_ena                           (rx_otn_ena),
//    .rx_otn_lane0                         (rx_otn_lane0),
//    .rx_otn_vlmarker                      (rx_otn_vlmarker),
//    .rx_preambleout                       (rx_preambleout),
//    .usr_rx_reset                         (usr_rx_reset),
//    .gt_rxusrclk2                         (rxusrclk2),
//    .stat_rx_aligned                      (stat_rx_aligned),
//    .stat_rx_aligned_err                  (stat_rx_aligned_err),
//    .stat_rx_bad_code                     (stat_rx_bad_code),
//    .stat_rx_bad_fcs                      (stat_rx_bad_fcs),
//    .stat_rx_bad_preamble                 (stat_rx_bad_preamble),
//    .stat_rx_bad_sfd                      (stat_rx_bad_sfd),
//    .stat_rx_bip_err_0                    (stat_rx_bip_err_0),
//    .stat_rx_bip_err_1                    (stat_rx_bip_err_1),
//    .stat_rx_bip_err_10                   (stat_rx_bip_err_10),
//    .stat_rx_bip_err_11                   (stat_rx_bip_err_11),
//    .stat_rx_bip_err_12                   (stat_rx_bip_err_12),
//    .stat_rx_bip_err_13                   (stat_rx_bip_err_13),
//    .stat_rx_bip_err_14                   (stat_rx_bip_err_14),
//    .stat_rx_bip_err_15                   (stat_rx_bip_err_15),
//    .stat_rx_bip_err_16                   (stat_rx_bip_err_16),
//    .stat_rx_bip_err_17                   (stat_rx_bip_err_17),
//    .stat_rx_bip_err_18                   (stat_rx_bip_err_18),
//    .stat_rx_bip_err_19                   (stat_rx_bip_err_19),
//    .stat_rx_bip_err_2                    (stat_rx_bip_err_2),
//    .stat_rx_bip_err_3                    (stat_rx_bip_err_3),
//    .stat_rx_bip_err_4                    (stat_rx_bip_err_4),
//    .stat_rx_bip_err_5                    (stat_rx_bip_err_5),
//    .stat_rx_bip_err_6                    (stat_rx_bip_err_6),
//    .stat_rx_bip_err_7                    (stat_rx_bip_err_7),
//    .stat_rx_bip_err_8                    (stat_rx_bip_err_8),
//    .stat_rx_bip_err_9                    (stat_rx_bip_err_9),
//    .stat_rx_block_lock                   (stat_rx_block_lock),
//    .stat_rx_broadcast                    (stat_rx_broadcast),
//    .stat_rx_fragment                     (stat_rx_fragment),
//    .stat_rx_framing_err_0                (stat_rx_framing_err_0),
//    .stat_rx_framing_err_1                (stat_rx_framing_err_1),
//    .stat_rx_framing_err_10               (stat_rx_framing_err_10),
//    .stat_rx_framing_err_11               (stat_rx_framing_err_11),
//    .stat_rx_framing_err_12               (stat_rx_framing_err_12),
//    .stat_rx_framing_err_13               (stat_rx_framing_err_13),
//    .stat_rx_framing_err_14               (stat_rx_framing_err_14),
//    .stat_rx_framing_err_15               (stat_rx_framing_err_15),
//    .stat_rx_framing_err_16               (stat_rx_framing_err_16),
//    .stat_rx_framing_err_17               (stat_rx_framing_err_17),
//    .stat_rx_framing_err_18               (stat_rx_framing_err_18),
//    .stat_rx_framing_err_19               (stat_rx_framing_err_19),
//    .stat_rx_framing_err_2                (stat_rx_framing_err_2),
//    .stat_rx_framing_err_3                (stat_rx_framing_err_3),
//    .stat_rx_framing_err_4                (stat_rx_framing_err_4),
//    .stat_rx_framing_err_5                (stat_rx_framing_err_5),
//    .stat_rx_framing_err_6                (stat_rx_framing_err_6),
//    .stat_rx_framing_err_7                (stat_rx_framing_err_7),
//    .stat_rx_framing_err_8                (stat_rx_framing_err_8),
//    .stat_rx_framing_err_9                (stat_rx_framing_err_9),
//    .stat_rx_framing_err_valid_0          (stat_rx_framing_err_valid_0),
//    .stat_rx_framing_err_valid_1          (stat_rx_framing_err_valid_1),
//    .stat_rx_framing_err_valid_10         (stat_rx_framing_err_valid_10),
//    .stat_rx_framing_err_valid_11         (stat_rx_framing_err_valid_11),
//    .stat_rx_framing_err_valid_12         (stat_rx_framing_err_valid_12),
//    .stat_rx_framing_err_valid_13         (stat_rx_framing_err_valid_13),
//    .stat_rx_framing_err_valid_14         (stat_rx_framing_err_valid_14),
//    .stat_rx_framing_err_valid_15         (stat_rx_framing_err_valid_15),
//    .stat_rx_framing_err_valid_16         (stat_rx_framing_err_valid_16),
//    .stat_rx_framing_err_valid_17         (stat_rx_framing_err_valid_17),
//    .stat_rx_framing_err_valid_18         (stat_rx_framing_err_valid_18),
//    .stat_rx_framing_err_valid_19         (stat_rx_framing_err_valid_19),
//    .stat_rx_framing_err_valid_2          (stat_rx_framing_err_valid_2),
//    .stat_rx_framing_err_valid_3          (stat_rx_framing_err_valid_3),
//    .stat_rx_framing_err_valid_4          (stat_rx_framing_err_valid_4),
//    .stat_rx_framing_err_valid_5          (stat_rx_framing_err_valid_5),
//    .stat_rx_framing_err_valid_6          (stat_rx_framing_err_valid_6),
//    .stat_rx_framing_err_valid_7          (stat_rx_framing_err_valid_7),
//    .stat_rx_framing_err_valid_8          (stat_rx_framing_err_valid_8),
//    .stat_rx_framing_err_valid_9          (stat_rx_framing_err_valid_9),
//    .stat_rx_got_signal_os                (stat_rx_got_signal_os),
//    .stat_rx_hi_ber                       (stat_rx_hi_ber),
//    .stat_rx_inrangeerr                   (stat_rx_inrangeerr),
//    .stat_rx_internal_local_fault         (stat_rx_internal_local_fault),
//    .stat_rx_jabber                       (stat_rx_jabber),
//    .stat_rx_local_fault                  (stat_rx_local_fault),
//    .stat_rx_mf_err                       (stat_rx_mf_err),
//    .stat_rx_mf_len_err                   (stat_rx_mf_len_err),
//    .stat_rx_mf_repeat_err                (stat_rx_mf_repeat_err),
//    .stat_rx_misaligned                   (stat_rx_misaligned),
//    .stat_rx_multicast                    (stat_rx_multicast),
//    .stat_rx_oversize                     (stat_rx_oversize),
//    .stat_rx_packet_1024_1518_bytes       (stat_rx_packet_1024_1518_bytes),
//    .stat_rx_packet_128_255_bytes         (stat_rx_packet_128_255_bytes),
//    .stat_rx_packet_1519_1522_bytes       (stat_rx_packet_1519_1522_bytes),
//    .stat_rx_packet_1523_1548_bytes       (stat_rx_packet_1523_1548_bytes),
//    .stat_rx_packet_1549_2047_bytes       (stat_rx_packet_1549_2047_bytes),
//    .stat_rx_packet_2048_4095_bytes       (stat_rx_packet_2048_4095_bytes),
//    .stat_rx_packet_256_511_bytes         (stat_rx_packet_256_511_bytes),
//    .stat_rx_packet_4096_8191_bytes       (stat_rx_packet_4096_8191_bytes),
//    .stat_rx_packet_512_1023_bytes        (stat_rx_packet_512_1023_bytes),
//    .stat_rx_packet_64_bytes              (stat_rx_packet_64_bytes),
//    .stat_rx_packet_65_127_bytes          (stat_rx_packet_65_127_bytes),
//    .stat_rx_packet_8192_9215_bytes       (stat_rx_packet_8192_9215_bytes),
//    .stat_rx_packet_bad_fcs               (stat_rx_packet_bad_fcs),
//    .stat_rx_packet_large                 (stat_rx_packet_large),
//    .stat_rx_packet_small                 (stat_rx_packet_small),
//    .ctl_rx_enable                        (ctl_rx_enable),
//    .ctl_rx_force_resync                  (ctl_rx_force_resync),
//    .ctl_rx_test_pattern                  (ctl_rx_test_pattern),
//    .core_rx_reset                        (1'b0),
//    .rx_clk                               (txusrclk2),
//    .stat_rx_received_local_fault         (stat_rx_received_local_fault),
//    .stat_rx_remote_fault                 (stat_rx_remote_fault),
//    .stat_rx_status                       (stat_rx_status),
//    .stat_rx_stomped_fcs                  (stat_rx_stomped_fcs),
//    .stat_rx_synced                       (stat_rx_synced),
//    .stat_rx_synced_err                   (stat_rx_synced_err),
//    .stat_rx_test_pattern_mismatch        (stat_rx_test_pattern_mismatch),
//    .stat_rx_toolong                      (stat_rx_toolong),
//    .stat_rx_total_bytes                  (stat_rx_total_bytes),
//    .stat_rx_total_good_bytes             (stat_rx_total_good_bytes),
//    .stat_rx_total_good_packets           (stat_rx_total_good_packets),
//    .stat_rx_total_packets                (stat_rx_total_packets),
//    .stat_rx_truncated                    (stat_rx_truncated),
//    .stat_rx_undersize                    (stat_rx_undersize),
//    .stat_rx_unicast                      (stat_rx_unicast),
//    .stat_rx_vlan                         (stat_rx_vlan),
//    .stat_rx_pcsl_demuxed                 (stat_rx_pcsl_demuxed),
//    .stat_rx_pcsl_number_0                (stat_rx_pcsl_number_0),
//    .stat_rx_pcsl_number_1                (stat_rx_pcsl_number_1),
//    .stat_rx_pcsl_number_10               (stat_rx_pcsl_number_10),
//    .stat_rx_pcsl_number_11               (stat_rx_pcsl_number_11),
//    .stat_rx_pcsl_number_12               (stat_rx_pcsl_number_12),
//    .stat_rx_pcsl_number_13               (stat_rx_pcsl_number_13),
//    .stat_rx_pcsl_number_14               (stat_rx_pcsl_number_14),
//    .stat_rx_pcsl_number_15               (stat_rx_pcsl_number_15),
//    .stat_rx_pcsl_number_16               (stat_rx_pcsl_number_16),
//    .stat_rx_pcsl_number_17               (stat_rx_pcsl_number_17),
//    .stat_rx_pcsl_number_18               (stat_rx_pcsl_number_18),
//    .stat_rx_pcsl_number_19               (stat_rx_pcsl_number_19),
//    .stat_rx_pcsl_number_2                (stat_rx_pcsl_number_2),
//    .stat_rx_pcsl_number_3                (stat_rx_pcsl_number_3),
//    .stat_rx_pcsl_number_4                (stat_rx_pcsl_number_4),
//    .stat_rx_pcsl_number_5                (stat_rx_pcsl_number_5),
//    .stat_rx_pcsl_number_6                (stat_rx_pcsl_number_6),
//    .stat_rx_pcsl_number_7                (stat_rx_pcsl_number_7),
//    .stat_rx_pcsl_number_8                (stat_rx_pcsl_number_8),
//    .stat_rx_pcsl_number_9                (stat_rx_pcsl_number_9),
//    .stat_tx_bad_fcs                      (stat_tx_bad_fcs),
//    .stat_tx_broadcast                    (stat_tx_broadcast),
//    .stat_tx_frame_error                  (stat_tx_frame_error),
//    .stat_tx_local_fault                  (stat_tx_local_fault),
//    .stat_tx_multicast                    (stat_tx_multicast),
//    .stat_tx_packet_1024_1518_bytes       (stat_tx_packet_1024_1518_bytes),
//    .stat_tx_packet_128_255_bytes         (stat_tx_packet_128_255_bytes),
//    .stat_tx_packet_1519_1522_bytes       (stat_tx_packet_1519_1522_bytes),
//    .stat_tx_packet_1523_1548_bytes       (stat_tx_packet_1523_1548_bytes),
//    .stat_tx_packet_1549_2047_bytes       (stat_tx_packet_1549_2047_bytes),
//    .stat_tx_packet_2048_4095_bytes       (stat_tx_packet_2048_4095_bytes),
//    .stat_tx_packet_256_511_bytes         (stat_tx_packet_256_511_bytes),
//    .stat_tx_packet_4096_8191_bytes       (stat_tx_packet_4096_8191_bytes),
//    .stat_tx_packet_512_1023_bytes        (stat_tx_packet_512_1023_bytes),
//    .stat_tx_packet_64_bytes              (stat_tx_packet_64_bytes),
//    .stat_tx_packet_65_127_bytes          (stat_tx_packet_65_127_bytes),
//    .stat_tx_packet_8192_9215_bytes       (stat_tx_packet_8192_9215_bytes),
//    .stat_tx_packet_large                 (stat_tx_packet_large),
//    .stat_tx_packet_small                 (stat_tx_packet_small),
//    .stat_tx_total_bytes                  (stat_tx_total_bytes),
//    .stat_tx_total_good_bytes             (stat_tx_total_good_bytes),
//    .stat_tx_total_good_packets           (stat_tx_total_good_packets),
//    .stat_tx_total_packets                (stat_tx_total_packets),
//    .stat_tx_unicast                      (stat_tx_unicast),
//    .stat_tx_vlan                         (stat_tx_vlan),


//    .ctl_tx_enable                        (ctl_tx_enable),
//    .ctl_tx_test_pattern                  (ctl_tx_test_pattern),
//    .ctl_tx_send_idle                     (ctl_tx_send_idle),
//    .ctl_tx_send_rfi                      (ctl_tx_send_rfi),
//    .ctl_tx_send_lfi                      (ctl_tx_send_lfi),
//    .core_tx_reset                        (1'b0),
//    .tx_axis_tready                       (tx_axis_tready),
//    .tx_axis_tvalid                       (tx_axis_tvalid),
//    .tx_axis_tdata                        (tx_axis_tdata),
//    .tx_axis_tkeep                        (tx_axis_tkeep),
//    .tx_axis_tlast                        (tx_axis_tlast),
//    .tx_axis_tuser                        (tx_axis_tuser),
//    .tx_ovfout                            (tx_ovfout),
//    .tx_unfout                            (tx_unfout),
//    .tx_preamblein                        (tx_preamblein),
//    .usr_tx_reset                         (usr_tx_reset),


//    .core_drp_reset                       (1'b0),
//    .drp_clk                              (1'b0),
//    .drp_addr                             (10'b0),
//    .drp_di                               (16'b0),
//    .drp_en                               (1'b0),
//    .drp_do                               (),
//    .drp_rdy                              (),
//    .drp_we                               (1'b0)
//);
//end
//endgenerate

cmac_usplus_config cmac_usplus_config  
(
    .gen_mon_clk                          (txusrclk2),
    .usr_tx_reset                         (usr_tx_reset),
    .usr_rx_reset                         (usr_rx_reset),
    .sys_reset                            (sys_reset),
    .send_continuous_pkts                 (send_continuous_pkts),
    .lbus_tx_rx_restart_in                (lbus_tx_rx_restart_in),
    .tx_axis_tready                       (tx_axis_tready),
    .tx_axis_tvalid                       (tx_axis_tvalid),
    .tx_axis_tdata                        (tx_axis_tdata),
    .tx_axis_tkeep                        (tx_axis_tkeep),
    .tx_axis_tlast                        (tx_axis_tlast),
    .tx_axis_tuser                        (tx_axis_tuser),
    .rx_axis_tvalid                       (rx_axis_tvalid),
    .rx_axis_tdata                        (rx_axis_tdata),
    .rx_axis_tkeep                        (rx_axis_tkeep),
    .rx_axis_tlast                        (rx_axis_tlast),
    .rx_axis_tuser                        (rx_axis_tuser),
    .tx_ovfout                            (tx_ovfout),
    .tx_unfout                            (tx_unfout),
    .tx_preamblein                        (tx_preamblein),
    .rx_preambleout                       (rx_preambleout),
    .ctl_tx_enable                        (ctl_tx_enable),
    .stat_rx_aligned_err                  (stat_rx_aligned_err),
    .stat_rx_bad_code                     (stat_rx_bad_code),
    .stat_rx_bad_fcs                      (stat_rx_bad_fcs),
    .stat_rx_bad_preamble                 (stat_rx_bad_preamble),
    .stat_rx_bad_sfd                      (stat_rx_bad_sfd),
    .stat_rx_bip_err_0                    (stat_rx_bip_err_0),
    .stat_rx_bip_err_1                    (stat_rx_bip_err_1),
    .stat_rx_bip_err_10                   (stat_rx_bip_err_10),
    .stat_rx_bip_err_11                   (stat_rx_bip_err_11),
    .stat_rx_bip_err_12                   (stat_rx_bip_err_12),
    .stat_rx_bip_err_13                   (stat_rx_bip_err_13),
    .stat_rx_bip_err_14                   (stat_rx_bip_err_14),
    .stat_rx_bip_err_15                   (stat_rx_bip_err_15),
    .stat_rx_bip_err_16                   (stat_rx_bip_err_16),
    .stat_rx_bip_err_17                   (stat_rx_bip_err_17),
    .stat_rx_bip_err_18                   (stat_rx_bip_err_18),
    .stat_rx_bip_err_19                   (stat_rx_bip_err_19),
    .stat_rx_bip_err_2                    (stat_rx_bip_err_2),
    .stat_rx_bip_err_3                    (stat_rx_bip_err_3),
    .stat_rx_bip_err_4                    (stat_rx_bip_err_4),
    .stat_rx_bip_err_5                    (stat_rx_bip_err_5),
    .stat_rx_bip_err_6                    (stat_rx_bip_err_6),
    .stat_rx_bip_err_7                    (stat_rx_bip_err_7),
    .stat_rx_bip_err_8                    (stat_rx_bip_err_8),
    .stat_rx_bip_err_9                    (stat_rx_bip_err_9),
    .stat_rx_block_lock                   (stat_rx_block_lock),
    .stat_rx_broadcast                    (stat_rx_broadcast),
    .stat_rx_fragment                     (stat_rx_fragment),
    .stat_rx_framing_err_0                (stat_rx_framing_err_0),
    .stat_rx_framing_err_1                (stat_rx_framing_err_1),
    .stat_rx_framing_err_10               (stat_rx_framing_err_10),
    .stat_rx_framing_err_11               (stat_rx_framing_err_11),
    .stat_rx_framing_err_12               (stat_rx_framing_err_12),
    .stat_rx_framing_err_13               (stat_rx_framing_err_13),
    .stat_rx_framing_err_14               (stat_rx_framing_err_14),
    .stat_rx_framing_err_15               (stat_rx_framing_err_15),
    .stat_rx_framing_err_16               (stat_rx_framing_err_16),
    .stat_rx_framing_err_17               (stat_rx_framing_err_17),
    .stat_rx_framing_err_18               (stat_rx_framing_err_18),
    .stat_rx_framing_err_19               (stat_rx_framing_err_19),
    .stat_rx_framing_err_2                (stat_rx_framing_err_2),
    .stat_rx_framing_err_3                (stat_rx_framing_err_3),
    .stat_rx_framing_err_4                (stat_rx_framing_err_4),
    .stat_rx_framing_err_5                (stat_rx_framing_err_5),
    .stat_rx_framing_err_6                (stat_rx_framing_err_6),
    .stat_rx_framing_err_7                (stat_rx_framing_err_7),
    .stat_rx_framing_err_8                (stat_rx_framing_err_8),
    .stat_rx_framing_err_9                (stat_rx_framing_err_9),
    .stat_rx_framing_err_valid_0          (stat_rx_framing_err_valid_0),
    .stat_rx_framing_err_valid_1          (stat_rx_framing_err_valid_1),
    .stat_rx_framing_err_valid_10         (stat_rx_framing_err_valid_10),
    .stat_rx_framing_err_valid_11         (stat_rx_framing_err_valid_11),
    .stat_rx_framing_err_valid_12         (stat_rx_framing_err_valid_12),
    .stat_rx_framing_err_valid_13         (stat_rx_framing_err_valid_13),
    .stat_rx_framing_err_valid_14         (stat_rx_framing_err_valid_14),
    .stat_rx_framing_err_valid_15         (stat_rx_framing_err_valid_15),
    .stat_rx_framing_err_valid_16         (stat_rx_framing_err_valid_16),
    .stat_rx_framing_err_valid_17         (stat_rx_framing_err_valid_17),
    .stat_rx_framing_err_valid_18         (stat_rx_framing_err_valid_18),
    .stat_rx_framing_err_valid_19         (stat_rx_framing_err_valid_19),
    .stat_rx_framing_err_valid_2          (stat_rx_framing_err_valid_2),
    .stat_rx_framing_err_valid_3          (stat_rx_framing_err_valid_3),
    .stat_rx_framing_err_valid_4          (stat_rx_framing_err_valid_4),
    .stat_rx_framing_err_valid_5          (stat_rx_framing_err_valid_5),
    .stat_rx_framing_err_valid_6          (stat_rx_framing_err_valid_6),
    .stat_rx_framing_err_valid_7          (stat_rx_framing_err_valid_7),
    .stat_rx_framing_err_valid_8          (stat_rx_framing_err_valid_8),
    .stat_rx_framing_err_valid_9          (stat_rx_framing_err_valid_9),
    .stat_rx_got_signal_os                (stat_rx_got_signal_os),
    .stat_rx_hi_ber                       (stat_rx_hi_ber),
    .stat_rx_inrangeerr                   (stat_rx_inrangeerr),
    .stat_rx_internal_local_fault         (stat_rx_internal_local_fault),
    .stat_rx_jabber                       (stat_rx_jabber),
    .stat_rx_local_fault                  (stat_rx_local_fault),
    .stat_rx_mf_err                       (stat_rx_mf_err),
    .stat_rx_mf_len_err                   (stat_rx_mf_len_err),
    .stat_rx_mf_repeat_err                (stat_rx_mf_repeat_err),
    .stat_rx_misaligned                   (stat_rx_misaligned),
    .stat_rx_multicast                    (stat_rx_multicast),
    .stat_rx_oversize                     (stat_rx_oversize),
    .stat_rx_packet_1024_1518_bytes       (stat_rx_packet_1024_1518_bytes),
    .stat_rx_packet_128_255_bytes         (stat_rx_packet_128_255_bytes),
    .stat_rx_packet_1519_1522_bytes       (stat_rx_packet_1519_1522_bytes),
    .stat_rx_packet_1523_1548_bytes       (stat_rx_packet_1523_1548_bytes),
    .stat_rx_packet_1549_2047_bytes       (stat_rx_packet_1549_2047_bytes),
    .stat_rx_packet_2048_4095_bytes       (stat_rx_packet_2048_4095_bytes),
    .stat_rx_packet_256_511_bytes         (stat_rx_packet_256_511_bytes),
    .stat_rx_packet_4096_8191_bytes       (stat_rx_packet_4096_8191_bytes),
    .stat_rx_packet_512_1023_bytes        (stat_rx_packet_512_1023_bytes),
    .stat_rx_packet_64_bytes              (stat_rx_packet_64_bytes),
    .stat_rx_packet_65_127_bytes          (stat_rx_packet_65_127_bytes),
    .stat_rx_packet_8192_9215_bytes       (stat_rx_packet_8192_9215_bytes),
    .stat_rx_packet_bad_fcs               (stat_rx_packet_bad_fcs),
    .stat_rx_packet_large                 (stat_rx_packet_large),
    .stat_rx_packet_small                 (stat_rx_packet_small),
    .stat_rx_received_local_fault         (stat_rx_received_local_fault),
    .stat_rx_remote_fault                 (stat_rx_remote_fault),
    .stat_rx_status                       (stat_rx_status),
    .stat_rx_stomped_fcs                  (stat_rx_stomped_fcs),
    .stat_rx_synced                       (stat_rx_synced),
    .stat_rx_synced_err                   (stat_rx_synced_err),
    .stat_rx_test_pattern_mismatch        (stat_rx_test_pattern_mismatch),
    .stat_rx_toolong                      (stat_rx_toolong),
    .stat_rx_total_bytes                  (stat_rx_total_bytes),
    .stat_rx_total_good_bytes             (stat_rx_total_good_bytes),
    .stat_rx_total_good_packets           (stat_rx_total_good_packets),
    .stat_rx_total_packets                (stat_rx_total_packets),
    .stat_rx_truncated                    (stat_rx_truncated),
    .stat_rx_undersize                    (stat_rx_undersize),
    .stat_rx_unicast                      (stat_rx_unicast),
    .stat_rx_vlan                         (stat_rx_vlan),
    .stat_rx_pcsl_demuxed                 (stat_rx_pcsl_demuxed),
    .stat_rx_pcsl_number_0                (stat_rx_pcsl_number_0),
    .stat_rx_pcsl_number_1                (stat_rx_pcsl_number_1),
    .stat_rx_pcsl_number_10               (stat_rx_pcsl_number_10),
    .stat_rx_pcsl_number_11               (stat_rx_pcsl_number_11),
    .stat_rx_pcsl_number_12               (stat_rx_pcsl_number_12),
    .stat_rx_pcsl_number_13               (stat_rx_pcsl_number_13),
    .stat_rx_pcsl_number_14               (stat_rx_pcsl_number_14),
    .stat_rx_pcsl_number_15               (stat_rx_pcsl_number_15),
    .stat_rx_pcsl_number_16               (stat_rx_pcsl_number_16),
    .stat_rx_pcsl_number_17               (stat_rx_pcsl_number_17),
    .stat_rx_pcsl_number_18               (stat_rx_pcsl_number_18),
    .stat_rx_pcsl_number_19               (stat_rx_pcsl_number_19),
    .stat_rx_pcsl_number_2                (stat_rx_pcsl_number_2),
    .stat_rx_pcsl_number_3                (stat_rx_pcsl_number_3),
    .stat_rx_pcsl_number_4                (stat_rx_pcsl_number_4),
    .stat_rx_pcsl_number_5                (stat_rx_pcsl_number_5),
    .stat_rx_pcsl_number_6                (stat_rx_pcsl_number_6),
    .stat_rx_pcsl_number_7                (stat_rx_pcsl_number_7),
    .stat_rx_pcsl_number_8                (stat_rx_pcsl_number_8),
    .stat_rx_pcsl_number_9                (stat_rx_pcsl_number_9),
    .stat_tx_bad_fcs                      (stat_tx_bad_fcs),
    .stat_rx_aligned                      (stat_rx_aligned),
    .stat_tx_broadcast                    (stat_tx_broadcast),
    .stat_tx_frame_error                  (stat_tx_frame_error),
    .stat_tx_local_fault                  (stat_tx_local_fault),
    .stat_tx_multicast                    (stat_tx_multicast),
    .stat_tx_packet_1024_1518_bytes       (stat_tx_packet_1024_1518_bytes),
    .stat_tx_packet_128_255_bytes         (stat_tx_packet_128_255_bytes),
    .stat_tx_packet_1519_1522_bytes       (stat_tx_packet_1519_1522_bytes),
    .stat_tx_packet_1523_1548_bytes       (stat_tx_packet_1523_1548_bytes),
    .stat_tx_packet_1549_2047_bytes       (stat_tx_packet_1549_2047_bytes),
    .stat_tx_packet_2048_4095_bytes       (stat_tx_packet_2048_4095_bytes),
    .stat_tx_packet_256_511_bytes         (stat_tx_packet_256_511_bytes),
    .stat_tx_packet_4096_8191_bytes       (stat_tx_packet_4096_8191_bytes),
    .stat_tx_packet_512_1023_bytes        (stat_tx_packet_512_1023_bytes),
    .stat_tx_packet_64_bytes              (stat_tx_packet_64_bytes),
    .stat_tx_packet_65_127_bytes          (stat_tx_packet_65_127_bytes),
    .stat_tx_packet_8192_9215_bytes       (stat_tx_packet_8192_9215_bytes),
    .stat_tx_packet_large                 (stat_tx_packet_large),
    .stat_tx_packet_small                 (stat_tx_packet_small),
    .stat_tx_total_bytes                  (stat_tx_total_bytes),
    .stat_tx_total_good_bytes             (stat_tx_total_good_bytes),
    .stat_tx_total_good_packets           (stat_tx_total_good_packets),
    .stat_tx_total_packets                (stat_tx_total_packets),
    .stat_tx_unicast                      (stat_tx_unicast),
    .stat_tx_vlan                         (stat_tx_vlan),
    .ctl_rx_enable                        (ctl_rx_enable),
    .ctl_rx_force_resync                  (ctl_rx_force_resync),
    .ctl_rx_test_pattern                  (ctl_rx_test_pattern),
    .ctl_tx_test_pattern                  (ctl_tx_test_pattern),
    .ctl_tx_send_idle                     (ctl_tx_send_idle),
    .ctl_tx_send_rfi                      (ctl_tx_send_rfi),
    .ctl_tx_send_lfi                      (ctl_tx_send_lfi),
    .rx_reset                             (rx_reset),
    .tx_reset                             (tx_reset),
    .gt_rxrecclkout                       (gt_rxrecclkout),
    .tx_done_led                          (tx_done_led),
    .tx_busy_led                          (tx_busy_led),
    .rx_gt_locked_led                     (rx_gt_locked_led),
    .rx_aligned_led                       (rx_aligned_led),
    .rx_done_led                          (rx_done_led),
    .rx_data_fail_led                     (rx_data_fail_led),
    .rx_busy_led                          (rx_busy_led),
    .tx_usr_axis_tready                   (tx_usr_axis_tready),
    .tx_usr_axis_tvalid                   (tx_usr_axis_tvalid),
    .tx_usr_axis_tdata                    (tx_usr_axis_tdata),
    .tx_usr_axis_tkeep                    (tx_usr_axis_tkeep),
    .tx_usr_axis_tlast                    (tx_usr_axis_tlast),
    .rx_usr_axis_tvalid                   (rx_usr_axis_tvalid),
    .rx_usr_axis_tdata                    (rx_usr_axis_tdata),
    .rx_usr_axis_tkeep                    (rx_usr_axis_tkeep),
    .rx_usr_axis_tlast                    (rx_usr_axis_tlast)
);

//ila_cmac ila_cmac (
//	.clk		(txusrclk2), // input wire clk
//	.probe0		(stat_rx_aligned), // input wire [0:0]  probe0  
//	.probe1		(tx_axis_tready), // input wire [0:0]  probe1 
//	.probe2		(tx_axis_tvalid), // input wire [0:0]  probe2 
//	.probe3		(tx_axis_tdata), // input wire [511:0]  probe3 
//	.probe4		(tx_axis_tkeep), // input wire [63:0]  probe4 
//	.probe5		(tx_axis_tlast), // input wire [0:0]  probe5 
//	.probe6		(rx_axis_tready), // input wire [0:0]  probe6 
//	.probe7		(rx_axis_tvalid), // input wire [0:0]  probe7 
//	.probe8		(rx_axis_tdata), // input wire [511:0]  probe8 
//	.probe9		(rx_axis_tkeep), // input wire [63:0]  probe9 
//	.probe10	(rx_axis_tlast) // input wire [0:0]  probe10
//);
    
endmodule
