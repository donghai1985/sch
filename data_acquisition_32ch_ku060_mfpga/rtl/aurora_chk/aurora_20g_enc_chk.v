module aurora_20g_enc_chk  #(
    parameter                               DATA_WD        =    64        
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rst                        ,//(i)

    input                                   enc_vld                        ,//(i)
    input             [DATA_WD    -1:0]     enc_data                       ,//(i)
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
    reg               [15:0]                pkt_cnt                        ;
    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire                                    suc_vld                        ;
    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire                                    err_vld                        ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            cmp_data_comb  =      {pkt_cnt,48'hBBBB_CCCC_DDDD}   ;
    assign            suc_vld        =      enc_vld && (enc_data[15:0]  == pkt_cnt);
    assign            err_vld        =      enc_vld && (enc_data[15:0]  != pkt_cnt);
// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)
            pkt_cnt   <= 16'd0;
        else if(cfg_rst)
            pkt_cnt   <= 16'd0;
        else if(enc_vld)
            pkt_cnt   <= pkt_cnt   + 1'b1;
    end


    //---------------------------------------------------------------------
    // app_cnt.
    //---------------------------------------------------------------------     
    cmip_app_cnt #(
        .width   (32                )
    )u0_app_cnt(                        
        .clk     (clk               ),//(i)
        .rst_n   (rst_n             ),//(i)
        .clr     (cfg_rst           ),//(i)
        .vld     (suc_vld           ),//(i)
        .cnt     (suc_cnt           ) //(o)
    );

    cmip_app_cnt #(
        .width   (32                )
    )u1_app_cnt(                        
        .clk     (clk               ),//(i)
        .rst_n   (rst_n             ),//(i)
        .clr     (cfg_rst           ),//(i)
        .vld     (err_vld           ),//(i)
        .cnt     (err_cnt           ) //(o)
    );






endmodule





