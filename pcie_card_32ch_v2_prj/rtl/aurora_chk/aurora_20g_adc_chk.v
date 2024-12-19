module aurora_20g_adc_chk #(
    parameter                               DATA_WD        =    128        
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rst                        ,//(i)

    input                                   adc_vld                        ,//(i)
    input             [DATA_WD    -1:0]     adc_data                       ,//(i)
    output            [31:0]                suc_cnt                        ,//(o)
    output            [31:0]                err_cnt                         //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire              [DATA_WD    -1:0]     cmp_data_comb                  ;
    reg               [15:0]                cmp_data0                      ;
    wire              [15:0]                cmp_data1                      ;
    wire              [15:0]                cmp_data2                      ;
    wire              [15:0]                cmp_data3                      ;
    reg               [2 :0]                cnt                            ;
    wire                                    suc_vld                        ;
    wire                                    err_vld                        ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            cmp_data1      =      cmp_data0 + 2'd1               ; 
    assign            cmp_data2      =      cmp_data0 + 2'd2               ; 
    assign            cmp_data3      =      cmp_data0 + 2'd3               ; 
    assign            cmp_data_comb  =      {cmp_data3,cmp_data2,cmp_data1,cmp_data0,cmp_data3,cmp_data2,cmp_data1,cmp_data0};
    assign            suc_vld        =      adc_vld && (adc_data == cmp_data_comb);
    assign            err_vld        =      adc_vld && (adc_data != cmp_data_comb);
// =================================================================================================
// RTL Body
// =================================================================================================

    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)
            cnt <= 3'd0;
        else if(cfg_rst)
            cnt <= 3'd0;
        else if(adc_vld && (cnt==3'd3))
            cnt <= 3'd0;
        else if(adc_vld)
            cnt <= cnt + 3'd1;
    end


    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)
            cmp_data0 <= 16'd0;
        else if(cfg_rst)
            cmp_data0 <= 16'd0;
        else if(adc_vld && (cnt==3'd3))
            cmp_data0 <= cmp_data0 + 3'd4;
    end


    //---------------------------------------------------------------------
    // app_cnt.
    //---------------------------------------------------------------------     
    cmip_app_cnt #(
        .WDTH     (32                )
    )u0_app_cnt(                        
        .i_clk       (clk               ),//(i)
        .i_rst_n     (rst_n             ),//(i)
        .i_clr       (cfg_rst           ),//(i)
        .i_vld       (suc_vld           ),//(i)
        .o_cnt       (suc_cnt           ) //(o)
    );

    cmip_app_cnt #(
        .WDTH     (32                )
    )u1_app_cnt(                        
        .i_clk      (clk               ),//(i)
        .i_rst_n    (rst_n             ),//(i)
        .i_clr      (cfg_rst           ),//(i)
        .i_vld      (err_vld           ),//(i)
        .o_cnt      (err_cnt           ) //(o)
    );






endmodule





