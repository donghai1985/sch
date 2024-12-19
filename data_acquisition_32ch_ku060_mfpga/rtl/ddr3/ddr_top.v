// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : ddr_sch_top.v
// Module         : ddr_sch_top
// Function       : 
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2023/11/16   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================


module ddr_top #(
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               DDR3_SIM        =  1           ,
    parameter                               MAX_BLK_SIZE    =  32'd2097152 ,//1G bits 32'h200000

    parameter                               FIFO_DPTH       =  2048        ,
    parameter                               FIFO_ADDR_WD    =  $clog2(FIFO_DPTH),
    parameter                               WR_DATA_WD      =  64          ,
    parameter                               RD_DATA_WD      =  64          ,
    parameter                               BURST_LEN       =  16          ,
    parameter                               BASE_ADDR       =  32'h0000     
)(
    input                                   sim_ddr_clk                    ,//(i)
    input                                   sys_clk_p                      ,//(i)
    input                                   sys_clk_n                      ,//(i)
    input                                   sys_rst_n                      ,//(i)
    output                                  ddr_clk                        ,//(i)
    output                                  ddr_rst_n                      ,//(i)
    input                                   cfg_rst                        ,//(i)
    input                                   cfg_test_en                    ,//(i)
    output            [31:0]                sts_suc_cnt                    ,//(o)
    output            [31:0]                sts_err_cnt                    ,//(o)
    output                                  sts_err_lock                   ,//(o)

    input                                   wr_clk                         ,//(i)
    input                                   wr_rst_n                       ,//(i)
    input                                   ch0_fifo_wr                    ,//(i)
    input             [WR_DATA_WD   -1:0]   ch0_fifo_din                   ,//(i)
    output                                  ch0_fifo_full                  ,//(o)
    output            [31:0]                ch0_fifo_full_cnt              ,//(o)
    input                                   rd_clk                         ,//(i)
    input                                   rd_rst_n                       ,//(i)
    input                                   ch0_fifo_rd                    ,//(i)
    output            [RD_DATA_WD-1:0]      ch0_fifo_dout                  ,//(o)
    output                                  ch0_fifo_empty                 ,//(o)

    input                                   fir_clk                        ,//(i)
    input                                   fir_rst_n                      ,//(i)
    input                                   ddr_rd0_en                     ,//(i)
    input               [32-1:0]            ddr_rd0_addr                   ,//(i)
    input                                   ddr_rd1_en                     ,//(i)
    input               [32-1:0]            ddr_rd1_addr                   ,//(i)
    output                                  readback0_vld                  ,//(o)
    output                                  readback0_last                 ,//(o)
    output              [32-1:0]            readback0_data                 ,//(o)
    output                                  readback1_vld                  ,//(o)
    output                                  readback1_last                 ,//(o)
    output              [32-1:0]            readback1_data                 ,//(o)
                                                                                
    input                                   fir_tap_wr_cmd                 ,//(i)
    input               [32-1:0]            fir_tap_wr_addr                ,//(i)
    input                                   fir_tap_wr_vld                 ,//(i)
    input               [32-1:0]            fir_tap_wr_data                ,//(i)


    inout             [63:0]                ddr3_dq                        ,//(i)
    inout             [7 :0]                ddr3_dqs_n                     ,//(i)
    inout             [7 :0]                ddr3_dqs_p                     ,//(i)
    output            [15:0]                ddr3_addr                      ,//(o)//notice
    output            [2 :0]                ddr3_ba                        ,//(o)
    output                                  ddr3_ras_n                     ,//(o)
    output                                  ddr3_cas_n                     ,//(o)
    output                                  ddr3_we_n                      ,//(o)
    output                                  ddr3_reset_n                   ,//(o)
    output                                  ddr3_ck_p                      ,//(o)
    output                                  ddr3_ck_n                      ,//(o)
    output                                  ddr3_cke                       ,//(o)
    output                                  ddr3_cs_n                      ,//(o)
    output            [7 :0]                ddr3_dm                        ,//(o)
    output                                  ddr3_odt                       ,//(o)
    output                                  init_calib_complete             //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    // wire                                    ddr_clk                           ;
    // wire                                    ddr_rst_n                         ;
    wire                                    ch0_wr_burst_req                  ;
    wire        [9:0]                       ch0_wr_burst_len                  ;
    wire        [DDR_ADDR_WD  -1:0]         ch0_wr_burst_addr                 ;
    wire                                    ch0_wr_burst_data_req             ;
    wire        [DDR_DATA_WD  -1:0]         ch0_wr_burst_data                 ;
    wire                                    ch0_wr_burst_finish               ;
    wire                                    ch0_rd_burst_req                  ;
    wire        [9:0]                       ch0_rd_burst_len                  ;
    wire        [DDR_ADDR_WD  -1:0]         ch0_rd_burst_addr                 ;
    wire                                    ch0_rd_burst_data_valid           ;
    wire        [DDR_DATA_WD  -1:0]         ch0_rd_burst_data                 ;
    wire                                    ch0_rd_burst_finish               ;
    wire        [31:0]                      ch0_rd_blk_cnt                    ;

    wire                                    ch1_wr_burst_req                  ;
    wire        [9:0]                       ch1_wr_burst_len                  ;
    wire        [DDR_ADDR_WD  -1:0]         ch1_wr_burst_addr                 ;
    wire                                    ch1_wr_burst_data_req             ;
    wire        [DDR_DATA_WD  -1:0]         ch1_wr_burst_data                 ;
    wire                                    ch1_wr_burst_finish               ;
    wire                                    ch1_rd_burst_req                  ;
    wire        [9:0]                       ch1_rd_burst_len                  ;
    wire        [DDR_ADDR_WD  -1:0]         ch1_rd_burst_addr                 ;
    wire                                    ch1_rd_burst_data_valid           ;
    wire        [DDR_DATA_WD  -1:0]         ch1_rd_burst_data                 ;
    wire                                    ch1_rd_burst_finish               ;
    wire        [31:0]                      ch1_rd_blk_cnt                    ;

    wire                                    ch2_wr_burst_req                  ;
    wire        [9:0]                       ch2_wr_burst_len                  ;
    wire        [DDR_ADDR_WD  -1:0]         ch2_wr_burst_addr                 ;
    wire                                    ch2_wr_burst_data_req             ;
    wire        [DDR_DATA_WD  -1:0]         ch2_wr_burst_data                 ;
    wire                                    ch2_wr_burst_finish               ;
    wire                                    ch2_rd_burst_req                  ;
    wire        [9:0]                       ch2_rd_burst_len                  ;
    wire        [DDR_ADDR_WD  -1:0]         ch2_rd_burst_addr                 ;
    wire                                    ch2_rd_burst_data_valid           ;
    wire        [DDR_DATA_WD  -1:0]         ch2_rd_burst_data                 ;
    wire                                    ch2_rd_burst_finish               ;
    wire        [31:0]                      ch2_rd_blk_cnt                    ;//no use

    reg         [DDR_ADDR_WD  -1:0]         ch0_rd_avail_addr                 ;
    reg         [DDR_ADDR_WD  -1:0]         ch1_rd_avail_addr                 ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------



// =================================================================================================
// RTL Body
// =================================================================================================
/*
    //---------------------------------------------------------------------
    // fifo2ddr_wr_burst Module Inst.
    //---------------------------------------------------------------------     
    fifo2ddr_wr_burst #(                                                            
        .FIFO_DEPTH                        (FIFO_DPTH                        ),
        .FIFO_ADDR_WD                      (FIFO_ADDR_WD                     ),
        .WR_DATA_WD                        (WR_DATA_WD                       ),
        .DDR_ADDR_WD                       (DDR_ADDR_WD                      ),
        .DDR_DATA_WD                       (DDR_DATA_WD                      ),
        .BURST_LEN                         (BURST_LEN                        ),
        .BASE_ADDR                         (BASE_ADDR                        ),
        .MAX_BLK_SIZE                      (MAX_BLK_SIZE                     )  
    )u0_fifo2ddr_wr_burst( 
        .ddr_clk                           (ddr_clk                          ),//(i)
        .ddr_rst_n                         (ddr_rst_n                        ),//(i)
        .wr_clk                            (wr_clk                           ),//(i)
        .wr_rst_n                          (wr_rst_n                         ),//(i)
        .cfg_rst                           (cfg_rst                          ),//(i)
        .fifo_wr                           (ch0_fifo_wr                      ),//(i)
        .fifo_din                          (ch0_fifo_din                     ),//(i)
        .fifo_full                         (ch0_fifo_full                    ),//(o)
        .fifo_full_cnt                     (ch0_fifo_full_cnt                ),//(o)
        .wr_burst_req                      (ch0_wr_burst_req                 ),//(o)
        .wr_burst_len                      (ch0_wr_burst_len                 ),//(o)
        .wr_burst_addr                     (ch0_wr_burst_addr                ),//(o)
        .wr_burst_data_req                 (ch0_wr_burst_data_req            ),//(i)
        .wr_burst_data                     (ch0_wr_burst_data                ),//(o)
        .wr_burst_finish                   (ch0_wr_burst_finish              ),//(i)
        .wr_blk_cnt                        (                                 ) //(o)
    );                                                                              

    //---------------------------------------------------------------------
    // ddr2fifo_rd_burst Module Inst.
    //---------------------------------------------------------------------     
    ddr2fifo_rd_burst #(                                                             
        .FIFO_DPTH                         (FIFO_DPTH                        ),
        .RD_DATA_WD                        (RD_DATA_WD                       ),
        .DDR_DATA_WD                       (DDR_DATA_WD                      ),
        .DDR_ADDR_WD                       (DDR_ADDR_WD                      ),
        .BURST_LEN                         (BURST_LEN                        ),
        .BASE_ADDR                         (BASE_ADDR                        ),
        .MAX_BLK_SIZE                      (MAX_BLK_SIZE                     )       
    )u0_ddr2fifo_rd_burst( 
        .ddr_clk                           (ddr_clk                          ),//(i)
        .ddr_rst_n                         (ddr_rst_n                        ),//(i)
        .rd_clk                            (rd_clk                           ),//(i)
        .rd_rst_n                          (rd_rst_n                         ),//(i)
        .cfg_rst                           (cfg_rst                          ),//(i)
        .dat_fifo_rd                       (ch0_fifo_rd                      ),//(i)
        .dat_fifo_dout                     (ch0_fifo_dout                    ),//(o)
        .dat_fifo_empty                    (ch0_fifo_empty                   ),//(o)
        .rd_avail_addr                     (ch0_rd_avail_addr                ),//(i)
        .rd_burst_req                      (ch0_rd_burst_req                 ),//(o)
        .rd_burst_len                      (ch0_rd_burst_len                 ),//(o)
        .rd_burst_addr                     (ch0_rd_burst_addr                ),//(o)
        .rd_burst_data_valid               (ch0_rd_burst_data_valid          ),//(i)
        .rd_burst_data                     (ch0_rd_burst_data                ),//(i)
        .rd_burst_finish                   (ch0_rd_burst_finish              ),//(i)
        .rd_blk_cnt                        (ch0_rd_blk_cnt                   ) //(o)
    );                                                                               

    //---------------------------------------------------------------------
    // Avail Addr Calc.
    //---------------------------------------------------------------------     
    always@(posedge ddr_clk or negedge ddr_rst_n)begin
        if(~ddr_rst_n)
            ch0_rd_avail_addr <= 'd0;
        else if(ch0_wr_burst_finish && ch0_rd_burst_finish)
            ch0_rd_avail_addr <= ch0_rd_avail_addr;
        else if(ch0_wr_burst_finish)
            ch0_rd_avail_addr <= ch0_rd_avail_addr + BURST_LEN;
        else if(ch0_rd_burst_finish)
            ch0_rd_avail_addr <= ch0_rd_avail_addr - BURST_LEN;
    end
*/


    ddr_wrrd_fir_coe #(                                                                
        .FIFO_DPTH                         (32                               ),
        .WR_DATA_WD                        (32                               ),
        .RD_DATA_WD                        (32                               ),
        .DDR_DATA_WD                       (DDR_DATA_WD                      ),
        .DDR_ADDR_WD                       (DDR_ADDR_WD                      ),
        .MAX_BLK_SIZE                      (32'h20000                        ),
        .BURST_LEN                         (8                                ),
        .BASE_ADDR                         (32'h000000                       )       
    )u_ddr_wrrd_fir_coe( 
        .ddr_clk                           (ddr_clk                          ),//(i)
        .ddr_rst_n                         (ddr_rst_n                        ),//(i)
        .wr_clk                            (fir_clk                          ),//(i)
        .wr_rst_n                          (fir_rst_n                        ),//(i)
        .rd_clk                            (fir_clk                          ),//(i)
        .rd_rst_n                          (fir_rst_n                        ),//(i)
        .cfg_rst                           (cfg_rst                          ),//(i)
        .ddr_rd0_en                        (ddr_rd0_en                       ),//(i)
        .ddr_rd0_addr                      (ddr_rd0_addr                     ),//(i)
        .ddr_rd1_en                        (ddr_rd1_en                       ),//(i)
        .ddr_rd1_addr                      (ddr_rd1_addr                     ),//(i)
        .readback0_vld                     (readback0_vld                    ),//(o)
        .readback0_last                    (readback0_last                   ),//(o)
        .readback0_data                    (readback0_data                   ),//(o)
        .readback1_vld                     (readback1_vld                    ),//(o)
        .readback1_last                    (readback1_last                   ),//(o)
        .readback1_data                    (readback1_data                   ),//(o)
        .fir_tap_wr_cmd                    (fir_tap_wr_cmd                   ),//(i)
        .fir_tap_wr_addr                   (fir_tap_wr_addr                  ),//(i)
        .fir_tap_wr_vld                    (fir_tap_wr_vld                   ),//(i)
        .fir_tap_wr_data                   (fir_tap_wr_data                  ),//(i)
        .wr_burst_req                      (ch1_wr_burst_req                 ),//(o)
        .wr_burst_len                      (ch1_wr_burst_len                 ),//(o)
        .wr_burst_addr                     (ch1_wr_burst_addr                ),//(o)
        .wr_burst_data_req                 (ch1_wr_burst_data_req            ),//(i)
        .wr_burst_data                     (ch1_wr_burst_data                ),//(o)
        .wr_burst_finish                   (ch1_wr_burst_finish              ),//(i)
        .rd_burst_req                      (ch1_rd_burst_req                 ),//(o)
        .rd_burst_len                      (ch1_rd_burst_len                 ),//(o)
        .rd_burst_addr                     (ch1_rd_burst_addr                ),//(o)
        .rd_burst_data_valid               (ch1_rd_burst_data_valid          ),//(i)
        .rd_burst_data                     (ch1_rd_burst_data                ),//(i)
        .rd_burst_finish                   (ch1_rd_burst_finish              ) //(i)
    );                                                                              




    //---------------------------------------------------------------------
    // ddr_wrrd_test Module Inst.
    //---------------------------------------------------------------------     
    ddr_wrrd_test #(                                                                
        .DDR_ADDR_WD                       (DDR_ADDR_WD                      ),
        .DDR_DATA_WD                       (DDR_DATA_WD                      ),
        .BASE_ADDR                         (BASE_ADDR                        ),
        .MAX_BLK_SIZE                      (MAX_BLK_SIZE                     )       
    )u_ddr_wrrd_test( 
        .ddr_clk                           (ddr_clk                          ),//(i)
        .ddr_rst_n                         (ddr_rst_n                        ),//(i)
        .cfg_rst                           (cfg_rst                          ),//(i)
        .cfg_test_en                       (cfg_test_en                      ),//(i)
        .cfg_burst_len                     (10'd16                           ),//(i)
        .sts_suc_cnt                       (sts_suc_cnt                      ),//(o)
        .sts_err_cnt                       (sts_err_cnt                      ),//(o)
        .sts_err_lock                      (sts_err_lock                     ),//(o)
        .wr_burst_req                      (ch2_wr_burst_req                 ),//(o)
        .wr_burst_len                      (ch2_wr_burst_len                 ),//(o)
        .wr_burst_addr                     (ch2_wr_burst_addr                ),//(o)
        .wr_burst_data_req                 (ch2_wr_burst_data_req            ),//(i)
        .wr_burst_data                     (ch2_wr_burst_data                ),//(o)
        .wr_burst_finish                   (ch2_wr_burst_finish              ),//(i)
        .rd_burst_req                      (ch2_rd_burst_req                 ),//(o)
        .rd_burst_len                      (ch2_rd_burst_len                 ),//(o)
        .rd_burst_addr                     (ch2_rd_burst_addr                ),//(o)
        .rd_burst_data_valid               (ch2_rd_burst_data_valid          ),//(i)
        .rd_burst_data                     (ch2_rd_burst_data                ),//(i)
        .rd_burst_finish                   (ch2_rd_burst_finish              ) //(i)
    );                                                                               

    //---------------------------------------------------------------------
    // ddr_sch_top Module Inst.
    //---------------------------------------------------------------------     
    ddr_sch_top #(                                                                
        .DDR_DATA_WD                       (DDR_DATA_WD                      ),
        .DDR_ADDR_WD                       (DDR_ADDR_WD                      ),
        .DDR3_SIM                          (DDR3_SIM                         ),
        .MAX_BLK_SIZE                      (MAX_BLK_SIZE                     )       
    )u_ddr_sch_top( 
        .sim_ddr_clk                       (sim_ddr_clk                      ),//(i)
        .sys_clk_p                         (sys_clk_p                        ),//(i)
        .sys_clk_n                         (sys_clk_n                        ),//(i)
        .sys_rst_n                         (sys_rst_n                        ),//(i)
        .ddr_clk                           (ddr_clk                          ),//(o)
        .ddr_rst_n                         (ddr_rst_n                        ),//(o)
        .cfg_rst                           (cfg_rst                          ),//(i)
        .ch0_wr_burst_req                  (ch0_wr_burst_req                 ),//(i)
        .ch0_wr_burst_len                  (ch0_wr_burst_len                 ),//(i)
        .ch0_wr_burst_addr                 (ch0_wr_burst_addr                ),//(i)
        .ch0_wr_burst_data_req             (ch0_wr_burst_data_req            ),//(o)
        .ch0_wr_burst_data                 (ch0_wr_burst_data                ),//(i)
        .ch0_wr_burst_finish               (ch0_wr_burst_finish              ),//(o)
        .ch1_wr_burst_req                  (ch1_wr_burst_req                 ),//(i)
        .ch1_wr_burst_len                  (ch1_wr_burst_len                 ),//(i)
        .ch1_wr_burst_addr                 (ch1_wr_burst_addr                ),//(i)
        .ch1_wr_burst_data_req             (ch1_wr_burst_data_req            ),//(o)
        .ch1_wr_burst_data                 (ch1_wr_burst_data                ),//(i)
        .ch1_wr_burst_finish               (ch1_wr_burst_finish              ),//(o)
        .ch2_wr_burst_req                  (ch2_wr_burst_req                 ),//(i)
        .ch2_wr_burst_len                  (ch2_wr_burst_len                 ),//(i)
        .ch2_wr_burst_addr                 (ch2_wr_burst_addr                ),//(i)
        .ch2_wr_burst_data_req             (ch2_wr_burst_data_req            ),//(o)
        .ch2_wr_burst_data                 (ch2_wr_burst_data                ),//(i)
        .ch2_wr_burst_finish               (ch2_wr_burst_finish              ),//(o)
        .ch0_rd_burst_req                  (ch0_rd_burst_req                 ),//(i)
        .ch0_rd_burst_len                  (ch0_rd_burst_len                 ),//(i)
        .ch0_rd_burst_addr                 (ch0_rd_burst_addr                ),//(i)
        .ch0_rd_burst_data_valid           (ch0_rd_burst_data_valid          ),//(o)
        .ch0_rd_burst_data                 (ch0_rd_burst_data                ),//(o)
        .ch0_rd_burst_finish               (ch0_rd_burst_finish              ),//(o)
        .ch1_rd_burst_req                  (ch1_rd_burst_req                 ),//(i)
        .ch1_rd_burst_len                  (ch1_rd_burst_len                 ),//(i)
        .ch1_rd_burst_addr                 (ch1_rd_burst_addr                ),//(i)
        .ch1_rd_burst_data_valid           (ch1_rd_burst_data_valid          ),//(o)
        .ch1_rd_burst_data                 (ch1_rd_burst_data                ),//(o)
        .ch1_rd_burst_finish               (ch1_rd_burst_finish              ),//(o)
        .ch2_rd_burst_req                  (ch2_rd_burst_req                 ),//(i)
        .ch2_rd_burst_len                  (ch2_rd_burst_len                 ),//(i)
        .ch2_rd_burst_addr                 (ch2_rd_burst_addr                ),//(i)
        .ch2_rd_burst_data_valid           (ch2_rd_burst_data_valid          ),//(o)
        .ch2_rd_burst_data                 (ch2_rd_burst_data                ),//(o)
        .ch2_rd_burst_finish               (ch2_rd_burst_finish              ),//(o)
        .ddr3_dq                           (ddr3_dq                          ),//(io)
        .ddr3_dqs_n                        (ddr3_dqs_n                       ),//(io)
        .ddr3_dqs_p                        (ddr3_dqs_p                       ),//(io)
        .ddr3_addr                         (ddr3_addr                        ),//(o)
        .ddr3_ba                           (ddr3_ba                          ),//(o)
        .ddr3_ras_n                        (ddr3_ras_n                       ),//(o)
        .ddr3_cas_n                        (ddr3_cas_n                       ),//(o)
        .ddr3_we_n                         (ddr3_we_n                        ),//(o)
        .ddr3_reset_n                      (ddr3_reset_n                     ),//(o)
        .ddr3_ck_p                         (ddr3_ck_p                        ),//(o)
        .ddr3_ck_n                         (ddr3_ck_n                        ),//(o)
        .ddr3_cke                          (ddr3_cke                         ),//(o)
        .ddr3_cs_n                         (ddr3_cs_n                        ),//(o)
        .ddr3_dm                           (ddr3_dm                          ),//(o)
        .ddr3_odt                          (ddr3_odt                         ),//(o)
        .init_calib_complete               (init_calib_complete              ) //(o)
    );                                                                              









endmodule

























