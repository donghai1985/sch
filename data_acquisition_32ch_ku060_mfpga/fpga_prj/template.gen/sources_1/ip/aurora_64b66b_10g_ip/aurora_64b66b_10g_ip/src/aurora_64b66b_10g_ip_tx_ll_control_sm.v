 ///////////////////////////////////////////////////////////////////////////////
 //
 // Project:  Aurora 64B/66B
 // Company:  Xilinx
 //
 //
 //
 // (c) Copyright 2008 - 2009 Xilinx, Inc. All rights reserved.
 //
 // This file contains confidential and proprietary information
 // of Xilinx, Inc. and is protected under U.S. and
 // international copyright and other intellectual property
 // laws.
 //
 // DISCLAIMER
 // This disclaimer is not a license and does not grant any
 // rights to the materials distributed herewith. Except as
 // otherwise provided in a valid license issued to you by
 // Xilinx, and to the maximum extent permitted by applicable
 // law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
 // WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
 // AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
 // BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
 // INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
 // (2) Xilinx shall not be liable (whether in contract or tort,
 // including negligence, or under any other theory of
 // liability) for any loss or damage of any kind or nature
 // related to, arising under or in connection with these
 // materials, including for any direct, or any indirect,
 // special, incidental, or consequential loss or damage
 // (including loss of data, profits, goodwill, or any type of
 // loss or damage suffered as a result of any action brought
 // by a third party) even if such damage or loss was
 // reasonably foreseeable or Xilinx had been advised of the
 // possibility of the same.
 //
 // CRITICAL APPLICATIONS
 // Xilinx products are not designed or intended to be fail-
 // safe, or for use in any application requiring fail-safe
 // performance, such as life-support or safety devices or
 // systems, Class III medical devices, nuclear facilities,
 // applications related to the deployment of airbags, or any
 // other applications that could lead to death, personal
 // injury, or severe property or environmental damage
 // (individually and collectively, "Critical
 // Applications"). Customer assumes the sole risk and
 // liability of any use of Xilinx products in Critical
 // Applications, subject only to applicable laws and
 // regulations governing limitations on product liability.
 //
 // THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
 // PART OF THIS FILE AT ALL TIMES.
 
 //
 ///////////////////////////////////////////////////////////////////////////////
 //
 //  TX_LL_CONTROL_SM
 //
 //
 //  Description: This module provides the transmitter state machine
 //               control logic to connect the LocalLink interface to
 //               the Aurora Channel
 //
 //
 //
 //
 ///////////////////////////////////////////////////////////////////////////////
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module  aurora_64b66b_10g_ip_TX_LL_CONTROL_SM
 (
     // LocalLink Interface
     TX_SRC_RDY_N,
     TX_SOF_N,
     TX_EOF_N,
     TX_REM,
     TX_DST_RDY_N,

 
     
     // Clock Compensation Interface
     DO_CC,
 
     // Global Logic Interface
     CHANNEL_UP,
 
     // TX_LL Control Module Interface
 
 
     // Aurora Lane Interface
     GEN_SEP,
     GEN_SEP7,
     SEP_NB,
     GEN_CC,
 
 
 
 
     // GTX Interface
     TXDATAVALID_IN,
 
     // System Interface
     USER_CLK
 
 );
 
 `define DLY #1
 
 
 
 //***********************************Port Declarations*******************************
 
 
     // LocalLink Interface
       input                    TX_SRC_RDY_N; 
       input                    TX_SOF_N; 
       input                    TX_EOF_N; 
       input         [0:2]      TX_REM; 
       output                   TX_DST_RDY_N; 
 
 
 
 
 
     // Clock Compensation Interface
       input                    DO_CC; 
 
 
     // Global Logic Interface
       input                    CHANNEL_UP; 
 
     // TX_LL Control Module Interface
 
     // Aurora Lane Interface
       output                   GEN_SEP; 
       output                   GEN_SEP7; 
       output        [0:2]      SEP_NB; 
       output                   GEN_CC; 
 
     // GTX Interface
       input                    TXDATAVALID_IN; 
     // System Interface
       input                    USER_CLK; 
 
 
 
 //**************************External Register Declarations****************************
 
       reg                      GEN_SEP; 
       reg                      GEN_SEP7; 
       reg           [0:2]      SEP_NB; 
 
 
 
 
 //**************************Internal Register Declarations****************************
 
       reg                      do_cc_r = 1'b0; 
       reg                      do_cc_r2 = 1'b0; 
       reg                      extend_cc_r;
 
       reg                      tx_dst_rdy_n_r; 
       reg           [0:2]      tx_rem_r; 
       reg                      gen_cc_r; 
 
     // Data state registers
       reg                      idle_r; 
       reg                      sof_to_data_r; 
       reg                      data_r; 
       reg                      data_to_eof_1_r; 
       reg                      data_to_eof_2_r; 
       reg                      eof_r; 
       reg                      sof_to_eof_1_r; 
       reg                      sof_to_eof_2_r; 
       reg                      sof_and_eof_r; 
 
       reg           [0:2]      gen_sep_nb_r; 
       reg                      gen_sep_r; 
       reg                      gen_sep7_r; 
     
 
 
       reg                      datavalid_in_r; 
       reg                      datavalid_in_r2; 
     reg                      txeof_txdv_coincide_r;
 //*********************************Wire Declarations**********************************
 
       wire                     next_idle_c; 
       wire                     next_sof_to_data_c; 
       wire                     next_data_c; 
       wire                     next_data_to_eof_1_c; 
       wire                     next_data_to_eof_2_c; 
       wire                     next_eof_c; 
       wire                     next_sof_to_eof_1_c; 
       wire                     next_sof_to_eof_2_c; 
       wire                     next_sof_and_eof_c; 
 
 
       wire                     tx_dst_rdy_n_c; 
       wire                     do_sof_c; 
       wire                     do_eof_c; 
       wire                     channel_full_c; 
       wire                     pdu_ok_c; 
       wire                     gen_sep_c; 
       wire                     gen_sep7_c; 
       wire                     eof_with_datavalid_c; 
 
       wire          [0:2]      gen_sep_nb_c; 
 //*********************************Main Body of Code**********************************
 
 
     //___________________________Clock Compensation________________________________
 
 
     // DO_CC signal has to be extended for one more cycle when TXDATAVALID_IN  
     // coincides with DO_CC occurance
     // extend_cc_r extends the pulse by one cycle during TXDATAVALID_IN cycle
 
     always @(posedge USER_CLK)
         if(!TXDATAVALID_IN & DO_CC)
               extend_cc_r <=  `DLY    1'b1;
         else if(!DO_CC)
               extend_cc_r <=  `DLY    1'b0;
 
     always @(posedge USER_CLK)
               do_cc_r <=  `DLY    DO_CC | extend_cc_r;
 
     always @(posedge USER_CLK)
               do_cc_r2 <= `DLY do_cc_r;
 
     // SOF requests are valid when TX_SRC_RDY_N, TX_DST_RDY_N and TX_SOF_N are all asserted
     assign  do_sof_c                =   !TX_SRC_RDY_N &
                                         !TX_DST_RDY_N &
                                         !TX_SOF_N;
 
     // EOF requests are valid when TX_SRC_RDY_N, TX_DST_RDY_N and TX_EOF_N are all asserted
     assign  do_eof_c                =   !TX_SRC_RDY_N &
                                         !TX_DST_RDY_N &
                                         !TX_EOF_N;

     // Freeze the Control state machine when CC. NFCs & UFCs must also be handled here.  
     assign  pdu_ok_c                =   !do_cc_r; 
     
 
     // The aurora channel is 'full' if there is more than enough data to fit into
     // a channel that is already carrying an SOF and an EOF character.
     assign  channel_full_c          =   (!TX_EOF_N & (TX_REM == 3'h0));
     //_____________________________Control State Machine__________________________________
 
     // The Control state machine handles the encapsulation and transmission of user
     // data.  It can use the channel when there is no CC, NFC message, UFC header,
     // UFC message or remote NFC request. 
 
     // State Registers
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)
         begin
             idle_r              <=  `DLY    1'b1;
             sof_to_data_r       <=  `DLY    1'b0;
             data_r              <=  `DLY    1'b0;
             data_to_eof_1_r     <=  `DLY    1'b0;
             data_to_eof_2_r     <=  `DLY    1'b0;
             eof_r               <=  `DLY    1'b0;
             sof_to_eof_1_r      <=  `DLY    1'b0;
             sof_to_eof_2_r      <=  `DLY    1'b0;
             sof_and_eof_r       <=  `DLY    1'b0;
         end
         else if(pdu_ok_c)
         begin
             idle_r              <=  `DLY    next_idle_c;
             sof_to_data_r       <=  `DLY    next_sof_to_data_c;
             data_r              <=  `DLY    next_data_c;
             data_to_eof_1_r     <=  `DLY    next_data_to_eof_1_c;
             data_to_eof_2_r     <=  `DLY    next_data_to_eof_2_c;
             eof_r               <=  `DLY    next_eof_c;
             sof_to_eof_1_r      <=  `DLY    next_sof_to_eof_1_c;
             sof_to_eof_2_r      <=  `DLY    next_sof_to_eof_2_c;
             sof_and_eof_r       <=  `DLY    next_sof_and_eof_c;
         end
 
 
 
     // Next State Logic
 
     // Default state. Remains in idle_r till TX_SOF_N is asserted along with
     // TX_SRC_RDY_N & TX_DST_RDY_N
     // When no frame is available to the channel, the states return back to
     // this state
     assign  next_idle_c             =   (idle_r & !do_sof_c) |
                                         (data_to_eof_2_r & !do_sof_c) |
                                         (eof_r & !do_sof_c )             |
                                         (sof_to_eof_2_r & !do_sof_c)     |
                                         (sof_and_eof_r & !do_sof_c);
 
     // sof_to_data_r state is set when TX_SOF_N from LocalLink interface is asserted
     // and TX_EOF_N is not asserted
     assign  next_sof_to_data_c      =   (idle_r & do_sof_c & !do_eof_c) |
                                         (data_to_eof_2_r & do_sof_c & !do_eof_c) |
                                         (eof_r & do_sof_c & !do_eof_c) |
                                         (sof_to_eof_2_r & do_sof_c & !do_eof_c) |
                                         (sof_and_eof_r & do_sof_c & !do_eof_c);
 
     // data_r state is set when only data is being given through the LocalLink
     // during this state the frame data does not have both TX_SOF_N & TX_EOF_N
     // deasserted
     assign  next_data_c             =   (sof_to_data_r & !do_eof_c) |
                                         (data_r & !do_eof_c);
 
     // data_to_eof_1_r state is set when the incoming data beat has TX_EOF_N
     // asserted and data beat is completely filled with data
     // i.e TX_EOF_N is asserted & TX_REM is all 0's indicating all 8 bytes of
     // data are valid
     assign  next_data_to_eof_1_c    =   (sof_to_data_r & do_eof_c & channel_full_c)|
                                         (data_r & do_eof_c & channel_full_c);
 
     // data_to_eof_2_r state is a registered state of data_to_eof_1_r
     assign  next_data_to_eof_2_c    =   data_to_eof_1_r;
 
     // eof_r state is set when the incoming data has data which is < 8bytes
     // i.e TX_REM > 0 & TX_EOF_N asserted
     assign  next_eof_c              =   (sof_to_data_r & do_eof_c & !channel_full_c)|
                                         (data_r & do_eof_c & !channel_full_c);
 
     // sof_to_eof_1_r state is set when the incoming frame is a single cycle frame
     // In a single cycle frame both TX_SOF_N & TX_EOF_N are asserted
     // Also the channel should be full TX_REM = 0
     assign  next_sof_to_eof_1_c     =   (idle_r & do_sof_c & do_eof_c & channel_full_c)|
                                         (data_to_eof_2_r & do_sof_c & do_eof_c & channel_full_c)|
                                         (eof_r & do_sof_c & do_eof_c & channel_full_c)|
                                         (sof_to_eof_2_r & do_sof_c & do_eof_c & channel_full_c)|
                                         (sof_and_eof_r & do_sof_c & do_eof_c & channel_full_c);
 
     // sof_to_eof_2_r is a registered state of sof_to_eof_1_r
     assign  next_sof_to_eof_2_c     =   sof_to_eof_1_r;
 
     // sof_and_eof_r state is set when the incoming frame is a single cycle frame
     // In a single cycle frame both TX_SOF_N & TX_EOF_N are asserted
     // Here the channel is not full TX_REM > 0
     // TX_REM > 0 is the key difference between the previous state & this state
     assign  next_sof_and_eof_c      =   (idle_r & do_sof_c & do_eof_c & !channel_full_c)|
                                         (data_to_eof_2_r & do_sof_c & do_eof_c & !channel_full_c)|
                                         (eof_r & do_sof_c & do_eof_c & !channel_full_c)|
                                         (sof_to_eof_2_r & do_sof_c & do_eof_c & !channel_full_c)|
                                         (sof_and_eof_r & do_sof_c & do_eof_c & !channel_full_c);
 
 
     // TXDATAVALID_IN signal is registered for delay in the data flow 
     always @(posedge USER_CLK)
     begin
           datavalid_in_r     <=  `DLY  TXDATAVALID_IN;
           datavalid_in_r2    <=  `DLY  datavalid_in_r;
     end

     //  TX_DST_RDY  is the critical path in this module.  It must be deasserted 
     // whenever an event occurs that prevents the pdu state machine from using the
     // Aurora channel to transmit PDUs.
     assign  tx_dst_rdy_n_c  =   (next_data_to_eof_1_c & pdu_ok_c) |
                                 DO_CC | do_cc_r  |
                                 (next_sof_to_eof_1_c & pdu_ok_c) |
                                 
                                 (sof_to_eof_1_r & !pdu_ok_c)|
 			        (data_to_eof_1_r & !pdu_ok_c);
 
     always @(posedge USER_CLK)
       gen_cc_r <= `DLY |(GEN_CC);
 
     always @(posedge USER_CLK)
         if(!CHANNEL_UP)     tx_dst_rdy_n_r    <=  `DLY    1'b1;
         else                tx_dst_rdy_n_r    <=  `DLY    tx_dst_rdy_n_c  |!TXDATAVALID_IN |txeof_txdv_coincide_r | (gen_cc_r & |(gen_sep_c)) | (((|gen_sep_c)|(|gen_sep7_c)) & !datavalid_in_r);
 
     assign TX_DST_RDY_N = tx_dst_rdy_n_r  ;
 
     // logic to extend tx_dst_rdy when eof coincides with TXDV
     always @(posedge USER_CLK)
         if(!CHANNEL_UP) 
            txeof_txdv_coincide_r <= `DLY 1'b0;
         else if(!TX_EOF_N & !TXDATAVALID_IN & (TX_REM == 3'h0))
            txeof_txdv_coincide_r <= `DLY 1'b1;
         else
            txeof_txdv_coincide_r <= `DLY 1'b0;
 
 
     // Drive the GEN_SEP/GEN_SEP7 signal when in an EOF state with the PDU state machine active.
     always @(posedge USER_CLK)
         if(!CHANNEL_UP) 
         begin
                         GEN_SEP     <=  `DLY    1'b0;
                         GEN_SEP7    <=  `DLY    1'b0;
         end
         else if (gen_sep_c & gen_sep_nb_c == {1{3'h0}} & !datavalid_in_r)     
                         GEN_SEP     <=  `DLY    gen_sep_c;  
         else if (gen_sep_r & gen_sep_nb_r == {1{3'h0}} & !datavalid_in_r2)
                         GEN_SEP     <=  `DLY    gen_sep_r;
     // Additional states to latch GEN_SEP when datavalid  & CC coincides
         else if (gen_sep_r & gen_sep_nb_r == {1{3'h0}} & GEN_CC)
                         GEN_SEP     <=  `DLY    gen_sep_r;
         else
         begin
                         GEN_SEP     <=  `DLY    gen_sep_c;
                         GEN_SEP7    <=  `DLY    gen_sep7_c;
 
         end
 
     assign eof_with_datavalid_c  =  (!datavalid_in_r & !TX_EOF_N & !TX_DST_RDY_N);      
 
     assign gen_sep_c      =  ((next_eof_c | next_sof_and_eof_c | data_to_eof_1_r |
                                                   sof_to_eof_1_r) & pdu_ok_c & (gen_sep_nb_c != {1{3'h7}})) |
                               (eof_with_datavalid_c & (gen_sep_nb_c != {1{3'h7}}));
 
     assign gen_sep7_c     =  ((next_eof_c | next_sof_and_eof_c) & pdu_ok_c & (gen_sep_nb_c == {1{3'h7}})) |
                               (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
     //assign gen_sep7_c     =  ((next_eof_c | next_sof_and_eof_c | data_to_eof_1_r |
     //                                              sof_to_eof_2_r) & pdu_ok_c & (gen_sep_nb_c == {1{3'h7}})) |
     //                          (eof_with_datavalid_c & (gen_sep_nb_c == {1{3'h7}}));
 
     assign gen_sep_nb_c   = (eof_r & TX_REM == {1{3'h0}} & channel_full_c) ? 3'h0 : (eof_with_datavalid_c) ? TX_REM :(!TX_DST_RDY_N) ? TX_REM : 3'h0;
 
     // We generate the gen_sep_nb_c signal based on the REM signal and the EOF signal.
 
     always @(posedge USER_CLK)
     begin
         if(datavalid_in_r & datavalid_in_r2 & !(|GEN_CC))
             gen_sep_r   <= `DLY 1'b0;
         else if(!datavalid_in_r)
             gen_sep_r   <= `DLY gen_sep_c;
     end
 
     always @(posedge USER_CLK)
     begin
             gen_sep_nb_r <= `DLY gen_sep_nb_c;
     end
 
     always @(posedge USER_CLK)
     begin
         if(!datavalid_in_r2)
             gen_sep7_r   <= `DLY gen_sep7_r;
         else
             gen_sep7_r   <= `DLY gen_sep7_c;
     end
 
 
     // Assign gen_sep_nb to SEP_NB port
     always @(posedge USER_CLK)
     begin
         if(!datavalid_in_r)
             SEP_NB   <=  `DLY    gen_sep_nb_r;
         else
             SEP_NB   <=  `DLY    gen_sep_nb_c;
     end      
 
 
     // The flops for the GEN_CC signal are replicated for timing and instantiated to allow us
     // to set their value reliably on powerup.
     FDR gen_cc_flop_0_i
     (
         .D(do_cc_r),
         .C(USER_CLK),
         .R(~CHANNEL_UP),
         .Q(GEN_CC )
     );
 
 
 
  
 
 
 
 endmodule
 
