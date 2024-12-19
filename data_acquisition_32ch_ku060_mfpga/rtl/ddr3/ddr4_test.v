
 
module ddr4_test #(
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               DDR3_SIM        =  0           ,
    parameter                               MAX_BLK_SIZE    =  32'd33554432,//16G bits 32'h200000

    parameter                               BURST_LEN       =  16          ,
    parameter                               BASE_ADDR       =  32'h0000     
)(
    input                                   clk_p                          ,//(i)   
    input                                   clk_n                          ,//(i)   
    input                                   sys_rst                        ,//(i)   

    output                                  sts_err_lock                   ,//(o)
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
    output                                  ddr3_odt                        //(o)

);
 
    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
//    localparam                              PILPE_LEN       =  8           ;

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    ddr_clk                        ;
    wire                                    ddr_rst_n                      ;
    wire                                    cfg_rst                        ;
    wire                                    cfg_test_en                    ;
    wire              [31:0]                sts_suc_cnt                    ;
    wire              [31:0]                sts_err_cnt                    ;
    wire                                    init_calib_complete            ;
    wire                                    clk                            ;
    wire                                    clk_100m                       ;
    wire                                    mmcm_locked                    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------

 
// =================================================================================================
// RTL Body
// =================================================================================================
/*
    clk_wiz_diff u_clk_wiz(
        .clk_out1                    (clk_100m               ), 
        .clk_out2                    (                       ), 
        .reset                       (1'b0                   ),   
        .locked                      (mmcm_locked            ), 
        .clk_in1_p                   (clk_p                  ),
        .clk_in1_n                   (clk_n                  ) 
    );  
*/

/*
    IBUFDS #(
        .DIFF_TERM                   ("TRUE"   ),  // Differential Termination
        .IBUF_LOW_PWR                ("TRUE"   ),  // Low power="TRUE", Highest performance="FALSE" 
        .IOSTANDARD                  ("DEFAULT")   // Specify the input I/O standard
    )FPGA_MASTER_inst(
        .O                           (clk                    ),   
        .I                           (clk_p                  ), 
        .IB                          (clk_n                  )  
    );
    
   BUFG BUFG_inst(
      .O(clk_100m), // 1-bit output: Clock output.
      .I(clk     )  // 1-bit input: Clock input.
   );
*/



/*
    ddr_test_vio u_ddr_test_vio (
        .clk                         (clk_100m               ),
        .probe_in0                   (sts_err_cnt            ),
        .probe_in1                   (sts_suc_cnt            ),
        .probe_in2                   (init_calib_complete    ),
        .probe_out0                  (cfg_test_en            ) 
    );
*/

    ddr_wrrd_test_top #(                                              
        .DDR_DATA_WD                 (DDR_DATA_WD            ),
        .DDR_ADDR_WD                 (DDR_ADDR_WD            ),
        .DDR3_SIM                    (DDR3_SIM               ),
        .MAX_BLK_SIZE                (MAX_BLK_SIZE           ),
        .BURST_LEN                   (BURST_LEN              ),
        .BASE_ADDR                   (BASE_ADDR              )       
    )u_ddr_wrrd_test_top( 
        .sys_clk_p                   (clk_p                  ),//(i)
        .sys_clk_n                   (clk_n                  ),//(i)
        .sys_rst_n                   (~sys_rst               ),//(i)
        .ddr_clk                     (ddr_clk                ),//(o)
        .ddr_rst_n                   (ddr_rst_n              ),//(o)
        .cfg_rst                     (1'b0                   ),//(i)
        .cfg_test_en                 (cfg_test_en            ),//(i)
        .sts_suc_cnt                 (sts_suc_cnt            ),//(o)
        .sts_err_cnt                 (sts_err_cnt            ),//(o)
        .sts_err_lock                (sts_err_lock           ),//(o)
        // .c0_ddr4_adr                 (ddr4_a                 ),//(o)
        // .c0_ddr4_ba                  (ddr4_ba                ),//(o)
        // .c0_ddr4_cke                 (ddr4_cke               ),//(o)
        // .c0_ddr4_cs_n                (ddr4_cs                ),//(o)
        // .c0_ddr4_dm_dbi_n            (ddr4_dm                ),//(io)
        // .c0_ddr4_dq                  (ddr4_d                 ),//(io)
        // .c0_ddr4_dqs_c               (ddr4_dqs_n             ),//(io)
        // .c0_ddr4_dqs_t               (ddr4_dqs_p             ),//(io)
        // .c0_ddr4_odt                 (ddr4_odt               ),//(o)
        // .c0_ddr4_bg                  (ddr4_bg                ),//(o)
        // .c0_ddr4_reset_n             (ddr4_reset             ),//(o)
        // .c0_ddr4_act_n               (ddr4_act               ),//(o)
        // .c0_ddr4_ck_c                (ddr4_ck_n              ),//(o)
        // .c0_ddr4_ck_t                (ddr4_ck_p              ),//(o)
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
 
 
 
 
 