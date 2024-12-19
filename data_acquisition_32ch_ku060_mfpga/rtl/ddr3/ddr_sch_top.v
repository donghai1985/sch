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


module ddr_sch_top #(
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               DDR3_SIM        =  1           ,
    parameter                               MAX_BLK_SIZE    =  32'h1000    
)(
    input                                   sim_ddr_clk                    ,//(i)
    input                                   sys_clk_p                      ,//(i)
    input                                   sys_clk_n                      ,//(i)
    input                                   sys_rst_n                      ,//(i)
    output                                  ddr_clk                        ,//(o)
    output                                  ddr_rst_n                      ,//(o)
    input                                   cfg_rst                        ,//(i)
                                                                               
    input                                   ch0_wr_burst_req               ,//(i)
    input             [9:0]                 ch0_wr_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch0_wr_burst_addr              ,//(i)
    output                                  ch0_wr_burst_data_req          ,//(o)
    input             [DDR_DATA_WD  -1:0]   ch0_wr_burst_data              ,//(i)
    output                                  ch0_wr_burst_finish            ,//(o)
                                                                               
    input                                   ch1_wr_burst_req               ,//(i)
    input             [9:0]                 ch1_wr_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch1_wr_burst_addr              ,//(i)
    output                                  ch1_wr_burst_data_req          ,//(o)
    input             [DDR_DATA_WD  -1:0]   ch1_wr_burst_data              ,//(i)
    output                                  ch1_wr_burst_finish            ,//(o)
                                                                               
    input                                   ch2_wr_burst_req               ,//(i)
    input             [9:0]                 ch2_wr_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch2_wr_burst_addr              ,//(i)
    output                                  ch2_wr_burst_data_req          ,//(o)
    input             [DDR_DATA_WD  -1:0]   ch2_wr_burst_data              ,//(i)
    output                                  ch2_wr_burst_finish            ,//(o)
                                                                               
    input                                   ch0_rd_burst_req               ,//(i)
    input             [9:0]                 ch0_rd_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch0_rd_burst_addr              ,//(i)
    output                                  ch0_rd_burst_data_valid        ,//(o)
    output            [DDR_DATA_WD  -1:0]   ch0_rd_burst_data              ,//(o)
    output                                  ch0_rd_burst_finish            ,//(o)
                                                                               
    input                                   ch1_rd_burst_req               ,//(i)
    input             [9:0]                 ch1_rd_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch1_rd_burst_addr              ,//(i)
    output                                  ch1_rd_burst_data_valid        ,//(o)
    output            [DDR_DATA_WD  -1:0]   ch1_rd_burst_data              ,//(o)
    output                                  ch1_rd_burst_finish            ,//(o)
                                                                               
    input                                   ch2_rd_burst_req               ,//(i)
    input             [9:0]                 ch2_rd_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch2_rd_burst_addr              ,//(i)
    output                                  ch2_rd_burst_data_valid        ,//(o)
    output            [DDR_DATA_WD  -1:0]   ch2_rd_burst_data              ,//(o)
    output                                  ch2_rd_burst_finish            ,//(o)

    inout             [63:0]                ddr3_dq                        ,//(i)
    inout             [7:0]                 ddr3_dqs_n                     ,//(i)
    inout             [7:0]                 ddr3_dqs_p                     ,//(i)
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

    output                                  init_calib_complete             //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    cfg_rst_n_sync                    ;
    wire                                    ui_clk                            ;
    wire                                    ui_clk_sync_rst                   ;
    wire                                    wr_burst_req                      ;
    wire        [9:0]                       wr_burst_len                      ;
    wire        [DDR_ADDR_WD  -1:0]         wr_burst_addr                     ;
    wire                                    wr_burst_data_req                 ;
    wire        [DDR_DATA_WD  -1:0]         wr_burst_data                     ;
    wire                                    wr_burst_finish                   ;
    wire                                    rd_burst_req                      ;
    wire        [9:0]                       rd_burst_len                      ;
    wire        [DDR_ADDR_WD  -1:0]         rd_burst_addr                     ;
    wire                                    rd_burst_data_valid               ;
    wire        [DDR_DATA_WD  -1:0]         rd_burst_data                     ;
    wire                                    rd_burst_finish                   ;
    wire                                    burst_finish                      ;
    wire                                    burst_idle                        ;
    
    
    wire        [DDR_ADDR_WD -1:0]          app_addr                          ;
    wire        [2:0]                       app_cmd                           ;
    wire                                    app_en                            ;
    wire        [511:0]                     app_wdf_data                      ;
    wire                                    app_wdf_end                       ;
    wire                                    app_wdf_wren                      ;
    wire        [511:0]                     app_rd_data                       ;
    wire                                    app_rd_data_valid                 ;
    wire                                    app_rdy                           ;
    wire                                    app_wdf_rdy                       ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign      ddr_clk      =              ui_clk                            ;


// =================================================================================================
// RTL Body
// =================================================================================================
    cmip_arst_sync #(                                          
        .PIPE_NUM                (4                    )       
    )u_cmip_arst_sync( 
        .i_dst_clk               (ddr_clk              ),//(i)
        .i_src_rst_n             (~cfg_rst             ),//(i)
        .o_dst_rst_n             (cfg_rst_n_sync       ) //(o)
    );    

    //---------------------------------------------------------------------
    // ddr_rd_sch Inst.
    //---------------------------------------------------------------------     
    ddr_rd_sch #(                                                           
        .DDR_ADDR_WD                        (DDR_ADDR_WD                ),
        .DDR_DATA_WD                        (DDR_DATA_WD                )       
    )u_ddr_rd_sch( 
        .ddr_clk                            (ddr_clk                    ),//(i)
        //.ddr_rst_n                          (ddr_rst_n                  ),//(i)
        .ddr_rst_n                          (ddr_rst_n && cfg_rst_n_sync),//(i)
        .ddr_burst_idle                     (burst_idle                 ),//(i)
        .ch0_rd_burst_req                   (ch0_rd_burst_req           ),//(i)
        .ch0_rd_burst_len                   (ch0_rd_burst_len           ),//(i)
        .ch0_rd_burst_addr                  (ch0_rd_burst_addr          ),//(i)
        .ch0_rd_burst_data_valid            (ch0_rd_burst_data_valid    ),//(o)
        .ch0_rd_burst_data                  (ch0_rd_burst_data          ),//(o)
        .ch0_rd_burst_finish                (ch0_rd_burst_finish        ),//(o)
        .ch1_rd_burst_req                   (ch1_rd_burst_req           ),//(i)
        .ch1_rd_burst_len                   (ch1_rd_burst_len           ),//(i)
        .ch1_rd_burst_addr                  (ch1_rd_burst_addr          ),//(i)
        .ch1_rd_burst_data_valid            (ch1_rd_burst_data_valid    ),//(o)
        .ch1_rd_burst_data                  (ch1_rd_burst_data          ),//(o)
        .ch1_rd_burst_finish                (ch1_rd_burst_finish        ),//(o)
        .ch2_rd_burst_req                   (ch2_rd_burst_req           ),//(i)
        .ch2_rd_burst_len                   (ch2_rd_burst_len           ),//(i)
        .ch2_rd_burst_addr                  (ch2_rd_burst_addr          ),//(i)
        .ch2_rd_burst_data_valid            (ch2_rd_burst_data_valid    ),//(o)
        .ch2_rd_burst_data                  (ch2_rd_burst_data          ),//(o)
        .ch2_rd_burst_finish                (ch2_rd_burst_finish        ),//(o)
        .ch3_rd_burst_req                   ('d0                        ),//(i)
        .ch3_rd_burst_len                   ('d0                        ),//(i)
        .ch3_rd_burst_addr                  ('d0                        ),//(i)
        .ch3_rd_burst_data_valid            (                           ),//(o)
        .ch3_rd_burst_data                  (                           ),//(o)
        .ch3_rd_burst_finish                (                           ),//(o)
        .rd_burst_req                       (rd_burst_req               ),//(o)
        .rd_burst_len                       (rd_burst_len               ),//(o)
        .rd_burst_addr                      (rd_burst_addr              ),//(o)
        .rd_burst_data_valid                (rd_burst_data_valid        ),//(i)
        .rd_burst_data                      (rd_burst_data              ),//(i)
        .rd_burst_finish                    (rd_burst_finish            ) //(i)
    );                                                                  

    //---------------------------------------------------------------------
    // ddr_wr_sch Inst.
    //---------------------------------------------------------------------     
    ddr_wr_sch #(                                                           
        .DDR_ADDR_WD                        (DDR_ADDR_WD                ),
        .DDR_DATA_WD                        (DDR_DATA_WD                )       
    )u_ddr_wr_sch( 
        .ddr_clk                            (ddr_clk                    ),//(i)
        //.ddr_rst_n                          (ddr_rst_n                  ),//(i)
        .ddr_rst_n                          (ddr_rst_n && cfg_rst_n_sync),//(i)
        .ddr_burst_idle                     (burst_idle                 ),//(i)
        .ch0_wr_burst_req                   (ch0_wr_burst_req           ),//(i)
        .ch0_wr_burst_len                   (ch0_wr_burst_len           ),//(i)
        .ch0_wr_burst_addr                  (ch0_wr_burst_addr          ),//(i)
        .ch0_wr_burst_data_req              (ch0_wr_burst_data_req      ),//(o)
        .ch0_wr_burst_data                  (ch0_wr_burst_data          ),//(i)
        .ch0_wr_burst_finish                (ch0_wr_burst_finish        ),//(o)
        .ch1_wr_burst_req                   (ch1_wr_burst_req           ),//(i)
        .ch1_wr_burst_len                   (ch1_wr_burst_len           ),//(i)
        .ch1_wr_burst_addr                  (ch1_wr_burst_addr          ),//(i)
        .ch1_wr_burst_data_req              (ch1_wr_burst_data_req      ),//(o)
        .ch1_wr_burst_data                  (ch1_wr_burst_data          ),//(i)
        .ch1_wr_burst_finish                (ch1_wr_burst_finish        ),//(o)
        .ch2_wr_burst_req                   (ch2_wr_burst_req           ),//(i)
        .ch2_wr_burst_len                   (ch2_wr_burst_len           ),//(i)
        .ch2_wr_burst_addr                  (ch2_wr_burst_addr          ),//(i)
        .ch2_wr_burst_data_req              (ch2_wr_burst_data_req      ),//(o)
        .ch2_wr_burst_data                  (ch2_wr_burst_data          ),//(i)
        .ch2_wr_burst_finish                (ch2_wr_burst_finish        ),//(o)
        .ch3_wr_burst_req                   ('d0                        ),//(i)
        .ch3_wr_burst_len                   ('d0                        ),//(i)
        .ch3_wr_burst_addr                  ('d0                        ),//(i)
        .ch3_wr_burst_data_req              (                           ),//(o)
        .ch3_wr_burst_data                  ('d0                        ),//(i)
        .ch3_wr_burst_finish                (                           ),//(o)

        .wr_burst_req                       (wr_burst_req               ),//(o)
        .wr_burst_len                       (wr_burst_len               ),//(o)
        .wr_burst_addr                      (wr_burst_addr              ),//(o)
        .wr_burst_data_req                  (wr_burst_data_req          ),//(i)
        .wr_burst_data                      (wr_burst_data              ),//(o)
        .wr_burst_finish                    (wr_burst_finish            ) //(i)
    );                                                                           
    //---------------------------------------------------------------------
    // mem_burst Inst.
    //---------------------------------------------------------------------  
     mem_burst_ctrl#(
        .DQ_WIDTH                           (64                         ),
        .MEM_DATA_BITS                      (512                        ),
        .ADDR_WIDTH                         (DDR_ADDR_WD                ),
        .DDR_SIZE                           (MAX_BLK_SIZE               )
    )u_mem_burst(            
        .ddr_rst_i                          (~ddr_rst_n || (~cfg_rst_n_sync)),
        .ddr_clk_i                          (ddr_clk                    ),
                                                                             
        .avail_addr                         (avail_addr                 ),
        .overflow_cnt                       (overflow_cnt               ),
        .rd_ddr_req_i                       (rd_burst_req               ),
        .rd_ddr_len_i                       (rd_burst_len               ),
        .rd_ddr_addr_i                      (rd_burst_addr              ),
        .rd_ddr_data_valid_o                (rd_burst_data_valid        ),
        .rd_ddr_data_o                      (rd_burst_data              ),
        .rd_ddr_finish_o                    (rd_burst_finish            ),
                                                                              
        .wr_ddr_req_i                       (wr_burst_req               ),
        .wr_ddr_len_i                       (wr_burst_len               ),
        .wr_ddr_addr_i                      (wr_burst_addr              ),
        .wr_ddr_data_req_o                  (wr_burst_data_req          ),
        .wr_ddr_data_i                      (wr_burst_data              ),
        .wr_ddr_finish_o                    (wr_burst_finish            ),
        .burst_idle                         (burst_idle                 ),                                                     
        .local_init_done_i                  (init_calib_complete        ),
        .app_addr                           (app_addr                   ),
        .app_cmd                            (app_cmd                    ),
        .app_en                             (app_en                     ),
        .app_wdf_data                       (app_wdf_data               ),
        .app_wdf_end                        (app_wdf_end                ),
        .app_wdf_mask                       (app_wdf_mask               ),
        .app_wdf_wren                       (app_wdf_wren               ),
        .app_rd_data                        (app_rd_data                ),
        .app_rd_data_end                    (app_rd_data_end            ),
        .app_rd_data_valid                  (app_rd_data_valid          ),
        .app_rdy                            (app_rdy                    ),
        .app_wdf_rdy                        (app_wdf_rdy                ),
        .app_sr_req                         (                           ),
        .app_ref_req                        (                           ),
        .app_zq_req                         (                           ),
        .app_sr_active                      (1'b0                       ),
        .app_ref_ack                        (1'b0                       ),
        .app_zq_ack                         (1'b0                       )
    );
    

generate if(DDR3_SIM == 0)begin

    ddr3_mig ddr3_mig_inst(
        .c0_ddr3_addr                       (ddr3_addr                  ),// output [15:0]     ddr3_addr
        .c0_ddr3_ba                         (ddr3_ba                    ),// output [2:0]      ddr3_ba
        .c0_ddr3_cas_n                      (ddr3_cas_n                 ),// output            ddr3_cas_n
        .c0_ddr3_ck_n                       (ddr3_ck_n                  ),// output [0:0]      ddr3_ck_n
        .c0_ddr3_ck_p                       (ddr3_ck_p                  ),// output [0:0]      ddr3_ck_p
        .c0_ddr3_cke                        (ddr3_cke                   ),// output [0:0]      ddr3_cke
        .c0_ddr3_ras_n                      (ddr3_ras_n                 ),// output            ddr3_ras_n
        .c0_ddr3_reset_n                    (ddr3_reset_n               ),// output            ddr3_reset_n
        .c0_ddr3_we_n                       (ddr3_we_n                  ),// output            ddr3_we_n
        .c0_ddr3_dq                         (ddr3_dq                    ),// inout [63:0]      ddr3_dq
        .c0_ddr3_dqs_n                      (ddr3_dqs_n                 ),// inout [7:0]       ddr3_dqs_n
        .c0_ddr3_dqs_p                      (ddr3_dqs_p                 ),// inout [7:0]       ddr3_dqs_p
        .c0_init_calib_complete             (init_calib_complete        ), // output           init_calib_complete
        .c0_ddr3_cs_n                       (ddr3_cs_n                  ),// output [0:0]       ddr3_cs_n
        .c0_ddr3_dm                         (ddr3_dm                    ),// output [7:0]      ddr3_dm
        .c0_ddr3_odt                        (ddr3_odt                   ),// output [0:0]      ddr3_odt
        // Application interface ports             
        .c0_ddr3_app_addr                   (app_addr                   ),// input [29:0]      app_addr
        .c0_ddr3_app_cmd                    (app_cmd                    ),// input [2:0]       app_cmd
        .c0_ddr3_app_en                     (app_en                     ),// input             app_en
        .c0_ddr3_app_wdf_data               (app_wdf_data               ),// input [511:0]     app_wdf_data
        .c0_ddr3_app_wdf_end                (app_wdf_end                ),// input             app_wdf_end
        .c0_ddr3_app_wdf_wren               (app_wdf_wren               ),// input             app_wdf_wren
        .c0_ddr3_app_rd_data                (app_rd_data                ),// output [511:0]    app_rd_data
        .c0_ddr3_app_rd_data_end            (app_rd_data_end            ),// output            app_rd_data_end
        .c0_ddr3_app_rd_data_valid          (app_rd_data_valid          ),// output            app_rd_data_valid
        .c0_ddr3_app_rdy                    (app_rdy                    ),// output            app_rdy
        .c0_ddr3_app_wdf_rdy                (app_wdf_rdy                ),// output            app_wdf_rdy
        .c0_ddr3_app_hi_pri                 ('d0                        ),// input             app_sr_req
        .c0_ddr3_ui_clk                     (ui_clk                     ),// output            ui_clk
        .c0_ddr3_ui_clk_sync_rst            (ui_clk_sync_rst            ),// output            ui_clk_sync_rst
        .c0_ddr3_app_wdf_mask               (64'd0                      ),// input [63:0]      app_wdf_mask
        .c0_sys_clk_p                       (sys_clk_p                  ),// input wire c0_sys_clk_p
        .c0_sys_clk_n                       (sys_clk_n                  ),// input wire c0_sys_clk_n
        .sys_rst                            (~sys_rst_n                 ) // input             sys_rst        Active Low
    );

    // ddr4_mig u_ddr4_mig( 
    //     .c0_init_calib_complete              (init_calib_complete        ),//(o)
    //     .dbg_clk                             (                           ),//(o)
    //     .c0_sys_clk_p                        (sys_clk_p                  ),//(i)
    //     .c0_sys_clk_n                        (sys_clk_n                  ),//(i)
    //     .dbg_bus                             (                           ),//(o)
    //     .c0_ddr4_adr                         (c0_ddr4_adr                ),//(o)
    //     .c0_ddr4_ba                          (c0_ddr4_ba                 ),//(o)
    //     .c0_ddr4_cke                         (c0_ddr4_cke                ),//(o)
    //     .c0_ddr4_cs_n                        (c0_ddr4_cs_n               ),//(o)
    //     .c0_ddr4_dm_dbi_n                    (c0_ddr4_dm_dbi_n           ),//(io)
    //     .c0_ddr4_dq                          (c0_ddr4_dq                 ),//(io)
    //     .c0_ddr4_dqs_c                       (c0_ddr4_dqs_c              ),//(io)
    //     .c0_ddr4_dqs_t                       (c0_ddr4_dqs_t              ),//(io)
    //     .c0_ddr4_odt                         (c0_ddr4_odt                ),//(o)
    //     .c0_ddr4_bg                          (c0_ddr4_bg                 ),//(o)
    //     .c0_ddr4_reset_n                     (c0_ddr4_reset_n            ),//(o)
    //     .c0_ddr4_act_n                       (c0_ddr4_act_n              ),//(o)
    //     .c0_ddr4_ck_c                        (c0_ddr4_ck_c               ),//(o)
    //     .c0_ddr4_ck_t                        (c0_ddr4_ck_t               ),//(o)
    //     .c0_ddr4_ui_clk                      (ui_clk                     ),//(o)
    //     .c0_ddr4_ui_clk_sync_rst             (ui_clk_sync_rst            ),//(o)
    //     .c0_ddr4_app_en                      (app_en                     ),//(i)
    //     .c0_ddr4_app_hi_pri                  (1'b0                       ),//(i)
    //     .c0_ddr4_app_wdf_end                 (app_wdf_end                ),//(i)
    //     .c0_ddr4_app_wdf_wren                (app_wdf_wren               ),//(i)
    //     .c0_ddr4_app_rd_data_end             (app_rd_data_end            ),//(o)
    //     .c0_ddr4_app_rd_data_valid           (app_rd_data_valid          ),//(o)
    //     .c0_ddr4_app_rdy                     (app_rdy                    ),//(o)
    //     .c0_ddr4_app_wdf_rdy                 (app_wdf_rdy                ),//(o)
    //     .c0_ddr4_app_addr                    (app_addr                   ),//(i)//[29:0]
    //     .c0_ddr4_app_cmd                     (app_cmd                    ),//(i)
    //     .c0_ddr4_app_wdf_data                (app_wdf_data               ),//(i)
    //     .c0_ddr4_app_wdf_mask                (64'd0                      ),//(i)
    //     .c0_ddr4_app_rd_data                 (app_rd_data                ),//(o)
    //     .sys_rst                             (sys_rst_n                  ) //(i)
    // );                                                                     


    assign      ddr_rst_n    =             ~ui_clk_sync_rst                   ;

end else begin
    ddr3_ram_model #(
       .ROUTE                                (1                          )
    )u_ddr3_ram_model(
       .app_addr                             (app_addr                   ), 
       .app_cmd                              (app_cmd                    ), 
       .app_en                               (app_en                     ), 
       .app_wdf_data                         (app_wdf_data               ), 
       .app_wdf_end                          (app_wdf_end                ), 
       .app_wdf_wren                         (app_wdf_wren               ), 
       .app_rd_data                          (app_rd_data                ),   
       .app_rd_data_valid                    (app_rd_data_valid          ), 
       .app_rdy                              (app_rdy                    ), 
       .app_wdf_rdy                          (app_wdf_rdy                ), 
                                           
       .sim_ddr_clk                          (sim_ddr_clk                ),                                    
       .clk                                  (ui_clk                     ), 
       .rst_n                                (sys_rst_n                  ),//just for sim
       .init_calib_complete                  (init_calib_complete        ) 
    );
    
    cmip_arst_sync #(                                                            
        .PIPE_NUM                            (4                          )       
    )u_cmip_arst_sync(                                                  
        .i_dst_clk                           (ui_clk                     ),//(i)
        .i_src_rst_n                         (sys_rst_n                  ),//(i)
        .o_dst_rst_n                         (ddr_rst_n                  ) //(o)
    );                                                                     

end
endgenerate
    



endmodule





