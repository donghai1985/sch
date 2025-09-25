 
 
////------------------------------------------------------------------------------
////  (c) Copyright 2013 Xilinx, Inc. All rights reserved.
////
////  This file contains confidential and proprietary information
////  of Xilinx, Inc. and is protected under U.S. and
////  international copyright and other intellectual property
////  laws.
////
////  DISCLAIMER
////  This disclaimer is not a license and does not grant any
////  rights to the materials distributed herewith. Except as
////  otherwise provided in a valid license issued to you by
////  Xilinx, and to the maximum extent permitted by applicable
////  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
////  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
////  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
////  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
////  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
////  (2) Xilinx shall not be liable (whether in contract or tort,
////  including negligence, or under any other theory of
////  liability) for any loss or damage of any kind or nature
////  related to, arising under or in connection with these
////  materials, including for any direct, or any indirect,
////  special, incidental, or consequential loss or damage
////  (including loss of data, profits, goodwill, or any type of
////  loss or damage suffered as a result of any action brought
////  by a third party) even if such damage or loss was
////  reasonably foreseeable or Xilinx had been advised of the
////  possibility of the same.
////
////  CRITICAL APPLICATIONS
////  Xilinx products are not designed or intended to be fail-
////  safe, or for use in any application requiring fail-safe
////  performance, such as life-support or safety devices or
////  systems, Class III medical devices, nuclear facilities,
////  applications related to the deployment of airbags, or any
////  other applications that could lead to death, personal
////  injury, or severe property or environmental damage
////  (individually and collectively, "Critical
////  Applications"). Customer assumes the sole risk and
////  liability of any use of Xilinx products in Critical
////  Applications, subject only to applicable laws and
////  regulations governing limitations on product liability.
////
////  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
////  PART OF THIS FILE AT ALL TIMES.
////------------------------------------------------------------------------------

`timescale 1ps/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module cmac_usplus_tx_config
   #(
    parameter PKT_NUM      = 1000,    //// 1 to 65535 (Number of packets)
    parameter PKT_SIZE     = 522      //// Min pkt size 64 Bytes; Max pkt size 16000 Bytes
   )
   (
    input  wire            clk,
    input  wire            reset,
    input  wire            sys_reset,

    input  wire            send_continuous_pkts,
    input  wire            stat_rx_aligned,
    input  wire            lbus_tx_rx_restart_in,
    output wire            ctl_tx_enable,
    output wire            ctl_tx_test_pattern,
    output wire            ctl_tx_send_idle,
    output wire            ctl_tx_send_lfi,
    output wire            ctl_tx_send_rfi,
    output wire            tx_reset,                                       //// Used to Reset the CMAC TX Core
    input  wire [3 :0]     gt_rxrecclkout,
    output reg             tx_done_led,
    output reg             tx_busy_led,
    input  wire            stat_tx_bad_fcs,
    input  wire            stat_tx_broadcast,
    input  wire            stat_tx_frame_error,
    input  wire            stat_tx_local_fault,
    input  wire            stat_tx_multicast,
    input  wire            stat_tx_packet_1024_1518_bytes,
    input  wire            stat_tx_packet_128_255_bytes,
    input  wire            stat_tx_packet_1519_1522_bytes,
    input  wire            stat_tx_packet_1523_1548_bytes,
    input  wire            stat_tx_packet_1549_2047_bytes,
    input  wire            stat_tx_packet_2048_4095_bytes,
    input  wire            stat_tx_packet_256_511_bytes,
    input  wire            stat_tx_packet_4096_8191_bytes,
    input  wire            stat_tx_packet_512_1023_bytes,
    input  wire            stat_tx_packet_64_bytes,
    input  wire            stat_tx_packet_65_127_bytes,
    input  wire            stat_tx_packet_8192_9215_bytes,
    input  wire            stat_tx_packet_large,
    input  wire            stat_tx_packet_small,
    input  wire [5:0]      stat_tx_total_bytes,
    input  wire [13:0]     stat_tx_total_good_bytes,
    input  wire            stat_tx_total_good_packets,
    input  wire            stat_tx_total_packets,
    input  wire            stat_tx_unicast,
    input  wire            stat_tx_vlan,

    output wire [55:0]     tx_preamblein,
    input  wire            tx_axis_tready, 
    output              	tx_axis_tvalid,
    output   [511:0]    	tx_axis_tdata,
    output              	tx_axis_tlast,
    output   [63:0]     	tx_axis_tkeep,
    output              	tx_axis_tuser,
    
    output             		tx_usr_axis_tready, 
    input              		tx_usr_axis_tvalid,
    input  		[511:0]    	tx_usr_axis_tdata,
    input             		tx_usr_axis_tlast,
    input  		[63:0]     	tx_usr_axis_tkeep,
                        
    input  wire            tx_ovfout,
    input  wire            tx_unfout,
    
    output reg	[31:0]		number_pkt_tx,
    output reg				tx_fail

    );

    //// Parameters Decleration

    //// pkt_gen States
    localparam STATE_TX_IDLE             = 0;
    localparam STATE_GT_LOCKED           = 1;
    localparam STATE_WAIT_RX_ALIGNED     = 2;
    localparam STATE_PKT_TRANSFER_INIT   = 3;
    localparam STATE_AXIS_TX_ENABLE      = 4;
    localparam STATE_AXIS_TX_HALT        = 5;
    localparam STATE_AXIS_TX_DONE        = 6;
    localparam STATE_WAIT_FOR_RESTART    = 7;

	assign tx_usr_axis_tready=	(tx_prestate==STATE_AXIS_TX_ENABLE)		?	tx_axis_tready:0;
	assign tx_axis_tdata=		(tx_prestate==STATE_AXIS_TX_ENABLE)		?	tx_usr_axis_tdata:0;
	assign tx_axis_tvalid=		(tx_prestate==STATE_AXIS_TX_ENABLE)		?	tx_usr_axis_tvalid:0;
	assign tx_axis_tkeep=		(tx_prestate==STATE_AXIS_TX_ENABLE)		?	tx_usr_axis_tkeep:0;
	assign tx_axis_tlast=		(tx_prestate==STATE_AXIS_TX_ENABLE)		?	tx_usr_axis_tlast:0;

    ////State Registers for TX
    reg  [3:0]     tx_prestate;

    reg  [15:0]    axis_number_pkt_proc;
    reg  [13:0]    axis_pkt_size_proc;
    reg  [63:0]    mty;
    reg  [6:0]     nmty;
    reg  [13:0]    pending_pkt_size;
    reg            tx_restart_rise_edge, first_pkt, pkt_size_64, tx_halt, wait_to_restart;
    reg            tx_done_tmp, tx_done_reg, tx_done_reg_d, tx_fail_reg;
    reg            tx_rdyout_d, tx_ovfout_d, tx_unfout_d;
    reg            tx_restart_1d, tx_restart_2d, tx_restart_3d, tx_restart_4d;

    reg            nxt_sopin0;
    reg  [ 7:0]    tx_payload_1, tx_payload_2, tx_payload_new;
    reg  [128-1:0] payload_16byte,payload_16byte_new;

    reg            stat_rx_aligned_1d, reset_done;
    reg            ctl_tx_enable_r, ctl_tx_send_idle_r, ctl_tx_send_lfi_r, ctl_tx_send_rfi_r, ctl_tx_test_pattern_r;
    reg            init_done,init_cntr_en;
    reg            gt_lock_led, rx_aligned_led, tx_done, tx_core_busy_led;
    reg            tx_gt_locked_led_1d, tx_done_led_1d, tx_core_busy_led_1d;
    reg            tx_gt_locked_led_2d, tx_done_led_2d, tx_core_busy_led_2d;
    reg            tx_gt_locked_led_3d, tx_done_led_3d, tx_core_busy_led_3d;
    reg  [8:0]     init_cntr;

    reg            send_continuous_pkts_1d, send_continuous_pkts_2d, send_continuous_pkts_3d;


    ////----------------------------------------TX Module -----------------------//
    //////////////////////////////////////////////////
    ////registering input signal generation
    //////////////////////////////////////////////////
    always @( posedge clk )
    begin
        if ( reset == 1'b1 )
        begin
            stat_rx_aligned_1d     <= 1'b0;
            reset_done             <= 1'b0;
            tx_rdyout_d            <= 1'b0;
            tx_ovfout_d            <= 1'b0;
            tx_unfout_d            <= 1'b0;
            tx_restart_1d          <= 1'b0;
            tx_restart_2d          <= 1'b0;
            tx_restart_3d          <= 1'b0;
            tx_restart_4d          <= 1'b0;
        end
        else
        begin
            stat_rx_aligned_1d     <= stat_rx_aligned;
            reset_done             <= 1'b1;
            tx_rdyout_d            <= tx_axis_tready;
            tx_ovfout_d            <= tx_ovfout;
            tx_unfout_d            <= tx_unfout;
            tx_restart_1d          <= lbus_tx_rx_restart_in;
            tx_restart_2d          <= tx_restart_1d;
            tx_restart_3d          <= tx_restart_2d;
            tx_restart_4d          <= tx_restart_3d;
        end
    end

    //////////////////////////////////////////////////
    ////generating the tx_restart_rise_edge signal 
    //////////////////////////////////////////////////
    always @( posedge clk )
    begin
        if  ( reset == 1'b1 )
             tx_restart_rise_edge   <= 1'b0;
        else
        begin
            if  (( tx_restart_3d == 1'b1) && ( tx_restart_4d == 1'b0))
                tx_restart_rise_edge  <= 1'b1;
            else 
                tx_restart_rise_edge  <= 1'b0;
        end
    end

    //////////////////////////////////////////////////
    ////State Machine 
    //////////////////////////////////////////////////
    always @( posedge clk )
    begin
        if ( reset == 1'b1 )
        begin
            tx_prestate                       <= STATE_TX_IDLE;
            tx_halt                           <= 1'b0;
            nxt_sopin0                        <= 1'b0;
            payload_16byte                    <= 128'd0;
            payload_16byte_new                <= 128'd0;
            pending_pkt_size                  <= 16'd0;
            tx_done_reg                       <= 1'b0;
            tx_done_tmp                       <= 1'b0;
            tx_done_reg_d                     <= 1'b0;
            tx_payload_1                      <= 8'd0;
            tx_payload_2                      <= 8'd0;
            tx_payload_new                    <= 8'd0;
            number_pkt_tx                     <= 16'd0;
            axis_number_pkt_proc              <= 16'd0;
            axis_pkt_size_proc                <= 14'd0;
            first_pkt                         <= 1'b0;
            pkt_size_64                       <= 1'd0;
            tx_fail_reg                       <= 1'b0;
            ctl_tx_enable_r                   <= 1'b0;
            ctl_tx_send_idle_r                <= 1'b0;
            ctl_tx_send_lfi_r                 <= 1'b0;
            ctl_tx_send_rfi_r                 <= 1'b0;
            ctl_tx_test_pattern_r             <= 1'b0;
            init_done                         <= 1'b0;
            gt_lock_led                       <= 1'b0;
            rx_aligned_led                    <= 1'b0;
            tx_core_busy_led                  <= 1'b0;
            wait_to_restart                   <= 1'b0;
            init_cntr_en                      <= 1'b0;
        end
        else
        begin
        case (tx_prestate)
            STATE_TX_IDLE            :
                                     begin
                                         ctl_tx_enable_r        <= 1'b0;
                                         ctl_tx_send_idle_r     <= 1'b0;
                                         ctl_tx_send_lfi_r      <= 1'b0;
                                         ctl_tx_send_rfi_r      <= 1'b0;
                                         ctl_tx_test_pattern_r  <= 1'b0;
                                         axis_pkt_size_proc     <= 14'd0;
                                         number_pkt_tx          <= 16'd0;
                                         axis_number_pkt_proc   <= 16'd0;
                                         init_done              <= 1'b0;
                                         gt_lock_led            <= 1'b0;
                                         rx_aligned_led         <= 1'b0;
                                         tx_core_busy_led       <= 1'b0;
                                         tx_halt                <= 1'b0;
                                         tx_fail_reg            <= 1'b0;
                                         nxt_sopin0             <= 1'b0;
                                         payload_16byte         <= 128'd0;
                                         payload_16byte_new     <= 128'd0;
                                         tx_done_reg            <= 1'd0;
                                         tx_done_tmp            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         wait_to_restart        <= 1'b0;
                                         init_cntr_en           <= 1'b0;

                                         //// State transition
                                         if  (reset_done == 1'b1)
                                             tx_prestate <= STATE_GT_LOCKED;
                                         else
                                             tx_prestate <= STATE_TX_IDLE;
                                     end
            STATE_GT_LOCKED          :
                                     begin
                                         gt_lock_led            <= 1'b1;
                                         rx_aligned_led         <= 1'b0;
                                         ctl_tx_enable_r        <= 1'b0;
                                         ctl_tx_send_idle_r     <= 1'b0;
                                         ctl_tx_send_lfi_r      <= 1'b0;
                                         ctl_tx_send_rfi_r      <= 1'b1; // Only remote fault is sent when link is down based on IEEE spec
                                         tx_core_busy_led       <= 1'b0;

                                         //// State transition
                                         tx_prestate <= STATE_WAIT_RX_ALIGNED;
                                     end
            STATE_WAIT_RX_ALIGNED    :
                                      begin
                                         wait_to_restart        <= 1'b0;
                                         init_cntr_en           <= 1'b0;
                                         init_done              <= 1'b0;
                                         rx_aligned_led         <= 1'b0;
                                         tx_core_busy_led       <= 1'b0;

                                         //// State transition
                                         if  (stat_rx_aligned_1d == 1'b1)
                                         begin
                                             tx_prestate <= STATE_PKT_TRANSFER_INIT;
                                         end
                                         else
                                             tx_prestate <= STATE_WAIT_RX_ALIGNED;
                                     end
            STATE_PKT_TRANSFER_INIT  : 
                                     begin
                                         wait_to_restart        <= 1'b0;
                                         init_cntr_en           <= 1'b1;
                                         init_done              <= init_cntr[4];
                                         gt_lock_led            <= 1'b1;
                                         rx_aligned_led         <= 1'b1;
                                         tx_core_busy_led       <= 1'b1;
                                         ctl_tx_send_idle_r     <= 1'b0;
                                         ctl_tx_send_lfi_r      <= 1'b0;
                                         ctl_tx_send_rfi_r      <= 1'b0;
                                         ctl_tx_enable_r        <= 1'b1;
                                         number_pkt_tx          <= 16'd0;
                                         axis_number_pkt_proc   <= PKT_NUM - 16'd1;
                                         axis_pkt_size_proc     <= PKT_SIZE;
                                         tx_done_reg            <= 1'd0;
                                         tx_done_tmp            <= 1'd0;
                                         tx_done_reg_d          <= 1'b0;
                                         tx_payload_1           <= 8'd6;
                                         tx_payload_2           <= tx_payload_1 + 8'd1;
                                         tx_payload_new         <= tx_payload_1 + 8'd2;
                                         payload_16byte         <= {16{tx_payload_1}};
                                         payload_16byte_new     <= {16{tx_payload_2}};
                                         pending_pkt_size       <= axis_pkt_size_proc;

                                         if (axis_pkt_size_proc == 14'd64)
                                         begin
                                             first_pkt      <= 1'b0;
                                             pkt_size_64    <= 1'd1;
                                         end
                                         else
                                         begin
                                             first_pkt      <= 1'b1;
                                             pkt_size_64    <= 1'd0;
                                         end

                                         //// State transition
                                         if  (stat_rx_aligned_1d == 1'b0) 
                                             tx_prestate <= STATE_TX_IDLE;
                                         else if  ((init_done == 1'b1) && (tx_rdyout_d == 1'b1) && (tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0))
                                         begin
                                             tx_prestate <= STATE_AXIS_TX_ENABLE;
                                         end
                                         else 
                                             tx_prestate <= STATE_PKT_TRANSFER_INIT;
                                     end
            STATE_AXIS_TX_ENABLE     :
                                     begin
                                        init_cntr_en    <= 1'b0;
                                        init_done       <= 1'b0;
                                        tx_halt         <= 1'b0;
										if(tx_axis_tvalid)
										number_pkt_tx<=number_pkt_tx+1;
										 //// State transition
										 if  (stat_rx_aligned_1d == 1'b0) 
											 tx_prestate <= STATE_TX_IDLE;
										 else if ((tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1))
											 tx_prestate <= STATE_AXIS_TX_HALT;
										 else
											 tx_prestate <= STATE_AXIS_TX_ENABLE;
                                     end
            STATE_AXIS_TX_HALT       :
                                     begin
                                         tx_halt <= 1'b1;
                                         if  ((tx_ovfout_d == 1'b1) || (tx_unfout_d == 1'b1))
                                             tx_fail_reg <= 1'b1;
                                         //// State transition
                                         if  (stat_rx_aligned_1d == 1'b0) 
                                             tx_prestate <= STATE_TX_IDLE;
                                         else if ((tx_ovfout_d == 1'b0) && (tx_unfout_d == 1'b0))
                                             tx_prestate <= STATE_AXIS_TX_ENABLE;
                                         else
                                             tx_prestate <= STATE_AXIS_TX_HALT;
                                     end
            STATE_WAIT_FOR_RESTART   : 
                                    begin
                                         tx_core_busy_led                <= 1'b0;
                                         init_cntr_en                    <= 1'b0;
                                         wait_to_restart                 <= 1'b1;
                                         init_done                       <= 1'b0;
                                         tx_done_reg_d                   <= 1'b0;

                                         //// State transition
                                         if  (stat_rx_aligned_1d == 1'b0)
                                             tx_prestate <= STATE_TX_IDLE;
                                         else if (tx_restart_rise_edge == 1'b1)
                                             tx_prestate <= STATE_PKT_TRANSFER_INIT;
                                         else 
                                             tx_prestate <= STATE_WAIT_FOR_RESTART;
                                     end
            default                  :
                                     begin
                                         init_cntr_en                    <= 1'b0;
                                         wait_to_restart                 <= 1'b0;
                                         ctl_tx_enable_r                 <= 1'b0;
                                         ctl_tx_send_idle_r              <= 1'b0;
                                         ctl_tx_send_lfi_r               <= 1'b0;
                                         ctl_tx_send_rfi_r               <= 1'b0;
                                         ctl_tx_test_pattern_r           <= 1'b0;
                                         tx_payload_1                    <= 8'd0;
                                         tx_payload_2                    <= 8'd0;
                                         tx_payload_new                  <= 8'd0;
                                         axis_pkt_size_proc              <= 14'd0;
                                         number_pkt_tx                   <= 16'd0;
                                         axis_number_pkt_proc            <= 16'd0;
                                         init_done                       <= 1'b0;
                                         gt_lock_led                     <= 1'b0;
                                         rx_aligned_led                  <= 1'b0;
                                         tx_core_busy_led                <= 1'b0;
                                         first_pkt                       <= 1'b0;
                                         pkt_size_64                     <= 1'd0;
                                         tx_halt                         <= 1'b0;
                                         tx_fail_reg                     <= 1'b0;
                                         tx_done_reg                     <= 1'b0;
                                         tx_done_tmp                     <= 1'b0;
                                         payload_16byte                  <= 128'd0;
                                         tx_prestate                     <= STATE_TX_IDLE;
                                     end
            endcase
        end
    end

    //////////////////////////////////////////////////
    ////tx_done signal generation
    //////////////////////////////////////////////////
    always @( posedge clk )
    begin
        if ( reset == 1'b1 )
            tx_done <= 1'b0;
        else
        begin
            if ((tx_restart_rise_edge == 1'b1) && (wait_to_restart == 1'b1))
                tx_done <= 1'b0;
            else if  (tx_done_reg_d == 1'b1)
                tx_done <= 1'b1;
        end
    end    

    //////////////////////////////////////////////////
    ////tx_fail signal generation
    //////////////////////////////////////////////////
    always @( posedge clk )
    begin
        if ( reset == 1'b1 )
            tx_fail <= 1'b0;
        else
        begin
            if  ((tx_restart_rise_edge == 1'b1) && (wait_to_restart == 1'b1))
                tx_fail <= 1'b0;
            else if  (tx_fail_reg == 1'b1)
                tx_fail <= 1'b1;
        end
    end

    //////////////////////////////////////////////////
    ////init_cntr signal generation 
    //////////////////////////////////////////////////
    always @( posedge clk )
    begin
        if ( reset == 1'b1 )
        begin
            init_cntr <= 0;
        end
        else
        begin
            if (init_cntr_en == 1'b1)
               init_cntr <= init_cntr + 1;
            else 
               init_cntr <= 0;
        end
    end
     
    //////////////////////////////////////////////////
    ////Assign TX LED Output ports with ASYN sys_reset
    //////////////////////////////////////////////////
    always @( posedge clk, posedge sys_reset )
    begin
        if ( sys_reset == 1'b1 )
        begin
            tx_done_led          <= 1'b0;
            tx_busy_led          <= 1'b0;
        end
        else
        begin
            tx_done_led          <= tx_done_led_3d;
            tx_busy_led          <= tx_core_busy_led_3d;
        end
    end

    //////////////////////////////////////////////////
    ////Registering the LED ports
    //////////////////////////////////////////////////
    always @( posedge clk )
    begin
        if ( reset == 1'b1 )
        begin
            tx_gt_locked_led_1d     <= 1'b0;
            tx_gt_locked_led_2d     <= 1'b0;
            tx_gt_locked_led_3d     <= 1'b0;
            tx_done_led_1d          <= 1'b0;
            tx_done_led_2d          <= 1'b0;
            tx_done_led_3d          <= 1'b0;
            tx_core_busy_led_1d     <= 1'b0;
            tx_core_busy_led_2d     <= 1'b0;
            tx_core_busy_led_3d     <= 1'b0;
        end
        else
        begin
            tx_gt_locked_led_1d     <= gt_lock_led;
            tx_gt_locked_led_2d     <= tx_gt_locked_led_1d;
            tx_gt_locked_led_3d     <= tx_gt_locked_led_2d;
            tx_done_led_1d          <= tx_done;
            tx_done_led_2d          <= tx_done_led_1d;
            tx_done_led_3d          <= tx_done_led_2d;
            tx_core_busy_led_1d     <= tx_core_busy_led;
            tx_core_busy_led_2d     <= tx_core_busy_led_1d;
            tx_core_busy_led_3d     <= tx_core_busy_led_2d;
        end
    end




assign tx_preamblein                = 56'd0;     //// tx_preamblein is driven as 0

assign ctl_tx_enable                = ctl_tx_enable_r;
assign ctl_tx_send_idle             = ctl_tx_send_idle_r;
assign ctl_tx_send_lfi              = ctl_tx_send_lfi_r;
assign ctl_tx_send_rfi              = ctl_tx_send_rfi_r;
assign ctl_tx_test_pattern          = ctl_tx_test_pattern_r;
assign tx_reset                     = 1'b0;                          //// Used to Reset the CMAC TX Core
 
    ////----------------------------------------END TX Module-----------------------//

endmodule



