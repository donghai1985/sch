module aurora_20g_chk_top (
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rst                        ,//(i)

    input             [128       -1:0]      s_axis_tdata                   ,//(o)
    input             [128/8     -1:0]      s_axis_tkeep                   ,//(o)
    input                                   s_axis_tvalid                  ,//(o)
    input                                   s_axis_tlast                   ,//(o)

    output            [31:0]                total_vld_cnt                  ,//(o)
    output            [31:0]                adc_chk_suc_cnt                ,//(o)
    output            [31:0]                adc_chk_err_cnt                ,//(o)
    output            [31:0]                enc_chk_suc_cnt                ,//(o)
    output            [31:0]                enc_chk_err_cnt                 //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam        PKT_CLR_FLAG     =    128'hAABBCCDD_AA55FF00_55AA0001_00000001;
    localparam        ADC_START_FLAG   =    128'hAABBCCDD_AA55FF00_55AA0001_00000002;
    localparam        PKT_END_FLAG     =    128'h5A5ADEAD_0000FFFF_5A5ADEAD_0000FFFF;
     
    function automatic no_chk0(
        input    [127:0]     data
    );begin:aaa
        no_chk0 = ~((data == PKT_END_FLAG) || (data == ADC_START_FLAG) || (data == PKT_CLR_FLAG));
    end
    endfunction

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    head_vld                       ;
    wire              [64         -1:0]     head_data                      ;
    wire                                    adc_vld                        ;
    wire              [128        -1:0]     adc_data                       ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------


// =================================================================================================
// RTL Body
// =================================================================================================

    //---------------------------------------------------------------------
    // aurora_20g_adc_parser Module Inst.
    //---------------------------------------------------------------------     
    aurora_20g_adc_parser #(                                              
        .DATA_WD                   (128                    ),
        .HEAD_WD                   (64                     )       
    )u_aurora_20g_adc_parser( 
        .clk                       (clk                    ),//(i)
        .rst_n                     (rst_n                  ),//(i)
        .cfg_rst                   (cfg_rst                ),//(i)
        .s_axis_tdata              (s_axis_tdata           ),//(i)
        .s_axis_tkeep              (s_axis_tkeep           ),//(i)
        .s_axis_tvalid             (s_axis_tvalid && no_chk0(s_axis_tdata)),//(i)
        .s_axis_tlast              (s_axis_tlast           ),//(i)
        .head_vld                  (head_vld               ),//(o)
        .head_data                 (head_data              ),//(o)
        .adc_vld                   (adc_vld                ),//(o)
        .adc_data                  (adc_data               ) //(o)
    );                                                     
    
    //---------------------------------------------------------------------
    // aurora_20g_adc_chk Module Inst.
    //---------------------------------------------------------------------     
    aurora_20g_adc_chk #(                                              
        .DATA_WD                   (128                    )       
    )u_aurora_20g_adc_chk( 
        .clk                       (clk                    ),//(i)
        .rst_n                     (rst_n                  ),//(i)
        .cfg_rst                   (cfg_rst                ),//(i)
        .adc_vld                   (adc_vld                ),//(i)
        .adc_data                  (adc_data               ),//(i)
        .suc_cnt                   (adc_chk_suc_cnt        ),//(o)
        .err_cnt                   (adc_chk_err_cnt        ) //(o)
    );                                                        

    //---------------------------------------------------------------------
    // aurora_20g_enc_chk Module Inst.
    //---------------------------------------------------------------------     
    aurora_20g_enc_chk #(                                              
        .DATA_WD                   (64                     )       
    )u_aurora_20g_enc_chk( 
        .clk                       (clk                    ),//(i)
        .rst_n                     (rst_n                  ),//(i)
        .cfg_rst                   (cfg_rst                ),//(i)
        .enc_vld                   (head_vld               ),//(i)
        .enc_data                  (head_data              ),//(i)
        .suc_cnt                   (enc_chk_suc_cnt        ),//(o)
        .err_cnt                   (enc_chk_err_cnt        ) //(o)
    );                                                      

    //---------------------------------------------------------------------
    // app_cnt.
    //---------------------------------------------------------------------     
    cmip_app_cnt #(
        .width                     (32                     )
    )u_app_cnt(                                             
        .clk                       (clk                    ),//(i)
        .rst_n                     (rst_n                  ),//(i)
        .clr                       (cfg_rst                ),//(i)
        .vld                       (s_axis_tvalid          ),//(i)
        .cnt                       (total_vld_cnt          ) //(o)
    );


endmodule





