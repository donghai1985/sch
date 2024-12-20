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


module ddr_wrrd_test_top  #(
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               DDR3_SIM        =  1           ,
    parameter                               MAX_BLK_SIZE    =  32'd2097152 ,//1G bits 32'h200000

    parameter                               BURST_LEN       =  16          ,
    parameter                               BASE_ADDR       =  32'h0000     
)(
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

    // output            [16: 0]               c0_ddr4_adr                    ,//(o)
    // output            [1 : 0]               c0_ddr4_ba                     ,//(o)
    // output            [0 : 0]               c0_ddr4_cke                    ,//(o)
    // output            [0 : 0]               c0_ddr4_cs_n                   ,//(o)
    // inout             [7 : 0]               c0_ddr4_dm_dbi_n               ,//(i)
    // inout             [63: 0]               c0_ddr4_dq                     ,//(i)
    // inout             [7 : 0]               c0_ddr4_dqs_c                  ,//(i)
    // inout             [7 : 0]               c0_ddr4_dqs_t                  ,//(i)
    // output            [0 : 0]               c0_ddr4_odt                    ,//(o)
    // output            [0 : 0]               c0_ddr4_bg                     ,//(o)
    // output                                  c0_ddr4_reset_n                ,//(o)
    // output                                  c0_ddr4_act_n                  ,//(o)
    // output            [0 : 0]               c0_ddr4_ck_c                   ,//(o)
    // output            [0 : 0]               c0_ddr4_ck_t                   ,//(o)

    inout             [63:0]                ddr3_dq                        ,//(io)
    inout             [7:0]                 ddr3_dqs_n                     ,//(io)
    inout             [7:0]                 ddr3_dqs_p                     ,//(io)
    output            [15:0]                ddr3_addr                      ,//(o)
    output            [2:0]                 ddr3_ba                        ,//(o)
    output                                  ddr3_ras_n                     ,//(o)
    output                                  ddr3_cas_n                     ,//(o)
    output                                  ddr3_we_n                      ,//(o)
    output                                  ddr3_reset_n                   ,//(o)
    output                                  ddr3_ck_p                      ,//(o)
    output                                  ddr3_ck_n                      ,//(o)
    output                                  ddr3_cke                       ,//(o)
    output                                  ddr3_cs_n                      ,//(o)
    output            [7:0]                 ddr3_dm                        ,//(o)
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

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------



// =================================================================================================
// RTL Body
// =================================================================================================

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
        .sys_clk_p                         (sys_clk_p                        ),//(i)
        .sys_clk_n                         (sys_clk_n                        ),//(i)
        //.clk_ref                           (clk_ref                          ),//(i)
        //.sys_rst_n                         (sys_rst_n                        ),//(i)
        .ddr_clk                           (ddr_clk                          ),//(o)
        .ddr_rst_n                         (ddr_rst_n                        ),//(o)
        .cfg_rst                           (cfg_rst                          ),//(i)
        .ch0_wr_burst_req                  ('b0                              ),//(i)
        .ch0_wr_burst_len                  ('b0                              ),//(i)
        .ch0_wr_burst_addr                 ('b0                              ),//(i)
        .ch0_wr_burst_data_req             (                                 ),//(o)
        .ch0_wr_burst_data                 ('b0                              ),//(i)
        .ch0_wr_burst_finish               (                                 ),//(o)
        .ch1_wr_burst_req                  ('b0                              ),//(i)
        .ch1_wr_burst_len                  ('b0                              ),//(i)
        .ch1_wr_burst_addr                 ('b0                              ),//(i)
        .ch1_wr_burst_data_req             (                                 ),//(o)
        .ch1_wr_burst_data                 ('b0                              ),//(i)
        .ch1_wr_burst_finish               (                                 ),//(o)
        .ch2_wr_burst_req                  (ch2_wr_burst_req                 ),//(i)
        .ch2_wr_burst_len                  (ch2_wr_burst_len                 ),//(i)
        .ch2_wr_burst_addr                 (ch2_wr_burst_addr                ),//(i)
        .ch2_wr_burst_data_req             (ch2_wr_burst_data_req            ),//(o)
        .ch2_wr_burst_data                 (ch2_wr_burst_data                ),//(i)
        .ch2_wr_burst_finish               (ch2_wr_burst_finish              ),//(o)
        .ch0_rd_burst_req                  (                                 ),//(o)
        .ch0_rd_burst_len                  (                                 ),//(o)
        .ch0_rd_burst_addr                 (                                 ),//(o)
        .ch0_rd_burst_data_valid           ('d0                              ),//(i)
        .ch0_rd_burst_data                 ('d0                              ),//(i)
        .ch0_rd_burst_finish               ('d0                              ),//(i)
        .ch1_rd_burst_req                  (                                 ),//(o)
        .ch1_rd_burst_len                  (                                 ),//(o)
        .ch1_rd_burst_addr                 (                                 ),//(o)
        .ch1_rd_burst_data_valid           ('d0                              ),//(i)
        .ch1_rd_burst_data                 ('d0                              ),//(i)
        .ch1_rd_burst_finish               ('d0                              ),//(i)
        .ch2_rd_burst_req                  (ch2_rd_burst_req                 ),//(o)
        .ch2_rd_burst_len                  (ch2_rd_burst_len                 ),//(o)
        .ch2_rd_burst_addr                 (ch2_rd_burst_addr                ),//(o)
        .ch2_rd_burst_data_valid           (ch2_rd_burst_data_valid          ),//(i)
        .ch2_rd_burst_data                 (ch2_rd_burst_data                ),//(i)
        .ch2_rd_burst_finish               (ch2_rd_burst_finish              ),//(i)

        // .c0_ddr4_adr                       (c0_ddr4_adr                      ),//(o)
        // .c0_ddr4_ba                        (c0_ddr4_ba                       ),//(o)
        // .c0_ddr4_cke                       (c0_ddr4_cke                      ),//(o)
        // .c0_ddr4_cs_n                      (c0_ddr4_cs_n                     ),//(o)
        // .c0_ddr4_dm_dbi_n                  (c0_ddr4_dm_dbi_n                 ),//(i)
        // .c0_ddr4_dq                        (c0_ddr4_dq                       ),//(i)
        // .c0_ddr4_dqs_c                     (c0_ddr4_dqs_c                    ),//(i)
        // .c0_ddr4_dqs_t                     (c0_ddr4_dqs_t                    ),//(i)
        // .c0_ddr4_odt                       (c0_ddr4_odt                      ),//(o)
        // .c0_ddr4_bg                        (c0_ddr4_bg                       ),//(o)
        // .c0_ddr4_reset_n                   (c0_ddr4_reset_n                  ),//(o)
        // .c0_ddr4_act_n                     (c0_ddr4_act_n                    ),//(o)
        // .c0_ddr4_ck_c                      (c0_ddr4_ck_c                     ),//(o)
        // .c0_ddr4_ck_t                      (c0_ddr4_ck_t                     ),//(o)
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

























