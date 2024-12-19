module ddr_512b_chk_top (
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rst                        ,//(i)

    input             [512       -1:0]      s_axis_tdata                   ,//(o)
    input                                   s_axis_tvalid                  ,//(o)

    output            [31:0]                adc_chk_suc_cnt                ,//(o)
    output            [31:0]                adc_chk_err_cnt                ,//(o)
    output            [31:0]                enc_chk_suc_cnt                ,//(o)
    output            [31:0]                enc_chk_err_cnt                 //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam        PKT_END_FLAG     =    128'h5A5ADEAD_0000FFFF_5A5ADEAD_0000FFFF;
 
    function automatic no_chk0(
        input    [511:0]     data
    );begin:aaa
        no_chk0 = ~((data[127:0] == PKT_END_FLAG) || (data[255:128] == PKT_END_FLAG) || (data[383:256] == PKT_END_FLAG) || (data[511:384] == PKT_END_FLAG));
    end
    endfunction


    function automatic no_chk1(
        input    [63:0]     data
    );begin:aaa
        no_chk1 = ~((data[63:0] == 64'h5A5ADEAD_0000FFFF));
    end
    endfunction
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    head_vld                       ;
    wire              [64         -1:0]     head_data                      ;
    wire                                    adc_vld                        ;
    wire              [512        -1:0]     adc_data                       ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------


// =================================================================================================
// RTL Body
// =================================================================================================

    //---------------------------------------------------------------------
    // ddr_20g_adc_parser Module Inst.
    //---------------------------------------------------------------------     
    ddr_512b_adc_parser #(                                              
        .DATA_WD                   (512                    ),
        .HEAD_WD                   (64                     )       
    )u_ddr_20g_adc_parser( 
        .clk                       (clk                    ),//(i)
        .rst_n                     (rst_n                  ),//(i)
        .cfg_rst                   (cfg_rst                ),//(i)
        .s_axis_tdata              (s_axis_tdata           ),//(i)
        .s_axis_tvalid             (s_axis_tvalid          ),//(i)
        .head_vld                  (head_vld               ),//(o)
        .head_data                 (head_data              ),//(o)
        .adc_vld                   (adc_vld                ),//(o)
        .adc_data                  (adc_data               ) //(o)
    );                                                     
    
    //---------------------------------------------------------------------
    // ddr_20g_adc_chk Module Inst.
    //---------------------------------------------------------------------     
    ddr_512b_adc_chk #(                                              
        .DATA_WD                   (512                    )       
    )u_ddr_20g_adc_chk( 
        .clk                       (clk                    ),//(i)
        .rst_n                     (rst_n                  ),//(i)
        .cfg_rst                   (cfg_rst                ),//(i)
        .adc_vld                   (adc_vld && no_chk0(adc_data)),//(i)
        .adc_data                  (adc_data               ),//(i)
        .suc_cnt                   (adc_chk_suc_cnt        ),//(o)
        .err_cnt                   (adc_chk_err_cnt        ) //(o)
    );                                                        

    //---------------------------------------------------------------------
    // ddr_20g_enc_chk Module Inst.
    //---------------------------------------------------------------------     
    ddr_512b_enc_chk #(                                              
        .DATA_WD                   (64                     )       
    )u_ddr_20g_enc_chk( 
        .clk                       (clk                    ),//(i)
        .rst_n                     (rst_n                  ),//(i)
        .cfg_rst                   (cfg_rst                ),//(i)
        .enc_vld                   (head_vld  && no_chk1(head_data)),//(i)
        .enc_data                  (head_data              ),//(i)
        .suc_cnt                   (enc_chk_suc_cnt        ),//(o)
        .err_cnt                   (enc_chk_err_cnt        ) //(o)
    );                                                      




endmodule





