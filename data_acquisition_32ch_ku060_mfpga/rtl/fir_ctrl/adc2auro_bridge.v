module adc2auro_bridge #(
    parameter                              FIFO_DPTH         =      1024          ,
    parameter                              WR_DATA_WD        =      512           ,
    parameter                              RD_DATA_WD        =      128           ,
    parameter                              HEAD_WD           =      64            
)(       
    input                                  wr_clk                                 ,//(i)
    input                                  wr_rst_n                               ,//(i)
    input                                  cfg_rst                                ,//(i)
    input                                  fir_vld                                ,//(i)
    input             [WR_DATA_WD  -1:0]   fir_din                                ,//(i)
    input             [HEAD_WD     -1:0]   enc_din                                ,//(i)

    input                                  rd_clk                                 ,//(i)
    input                                  rd_rst_n                               ,//(i)
    input                                  adc_fifo_rd                            ,//(i)
    output            [RD_DATA_WD  -1:0]   adc_fifo_din                           ,//(o)
    output                                 adc_fifo_empty                         ,//(o)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input                                  head_rd                                ,//(i)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output            [HEAD_WD     -1:0]   head_din                                //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //--------------------------------------------------------------------------       
    // Defination of Internal Signals       
    //--------------------------------------------------------------------------       
    wire                                   wr_cfg_rst_d1                          ;
    wire                                   wr_cfg_rst_d2                          ;
    wire                                   rd_cfg_rst_d1                          ;
    wire                                   rd_cfg_rst_d2                          ;
    wire                                   fifo1_empty                            ;
    wire                                   fifo2_empty                            ;
    wire                                   fir_ovld                               ;
    wire              [WR_DATA_WD  -1:0]   fir_odat                               ;
    wire              [HEAD_WD     -1:0]   enc_odat                               ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            adc_fifo_empty    =  fifo1_empty || fifo2_empty             ;


// =================================================================================================
// RTL Body
// =================================================================================================

/*
    always@(posedge wr_clk)begin
        wr_cfg_rst_d1 <= cfg_rst   ;
        wr_cfg_rst_d2 <= wr_cfg_rst_d1;
    end

    always@(posedge rd_clk)begin
        rd_cfg_rst_d1 <= cfg_rst   ;
        rd_cfg_rst_d2 <= rd_cfg_rst_d1;
    end
*/


    cmip_bit_sync_imp #(                                  
        .DATA_WDTH        (1                         ),
        .BUS_DELAY        (4                         )
    )u0_cmip_bit_sync(                               
        .i_dst_clk        (wr_clk                    ),//(i)
        .i_din            (cfg_rst                   ),//(i)
        .o_dout           (wr_cfg_rst_d2             ) //(o)
    );                                               
                                                     
    cmip_bit_sync_imp #(                                  
        .DATA_WDTH        (1                         ),
        .BUS_DELAY        (4                         )
    )u1_cmip_bit_sync(                               
        .i_dst_clk        (rd_clk                    ),//(i)
        .i_din            (cfg_rst                   ),//(i)
        .o_dout           (rd_cfg_rst_d2             ) //(o)
    );                                               



    // -------------------------------------------------------------------------
    // enc_acc_chg Module Inst.
    // -------------------------------------------------------------------------
    enc_acc_chg #(                                        
        .DATA_WD          (WR_DATA_WD                ),
        .HEAD_WD          (HEAD_WD                   )       
    )u_enc_acc_chg( 
        .clk              (wr_clk                    ),//(i)
        .rst_n            (wr_rst_n                  ),//(i)
        .cfg_rst          (wr_cfg_rst_d2             ),//(i)
        .fir_ivld         (fir_vld                   ),//(i)
        .fir_idat         (fir_din                   ),//(i)
        .enc_idat         (enc_din                   ),//(i)
        .fir_ovld         (fir_ovld                  ),//(o)
        .fir_odat         (fir_odat                  ),//(o)
        .enc_odat         (enc_odat                  ) //(o)
    );                                                      

    // -------------------------------------------------------------------------
    // cmip_afifo_wd_conv_rswl Module Inst.
    // -------------------------------------------------------------------------
    cmip_afifo_wd_conv_rswl #(
        .DPTH            (FIFO_DPTH                  ),
        .WR_DATA_WD      (WR_DATA_WD                 ),
        .RD_DATA_WD      (RD_DATA_WD                 ),
        .FWFT            (1                          )
    )u_adc_fifo(             
        .i_rd_clk        (rd_clk                     ),
        .i_wr_clk        (wr_clk                     ),
        .i_rd_rst_n      (rd_rst_n && (~rd_cfg_rst_d2)),
        .i_wr_rst_n      (wr_rst_n && (~wr_cfg_rst_d2)),
        .i_wr            (fir_ovld                    ),
        .i_din           (fir_odat                    ),
        .i_rd            (adc_fifo_rd                ),
        .o_dout          (adc_fifo_din               ),
        .o_full          (                           ),
        .o_empty         (fifo1_empty                ),
        .o_wr_cnt        (                           ),
        .o_rd_cnt        (                           )
    );


    // -------------------------------------------------------------------------
    // cmip_async_fifo Module Inst.
    // -------------------------------------------------------------------------
    cmip_async_fifo #(                                  
        .DPTH            (FIFO_DPTH                  ),
        .DATA_WDTH       (HEAD_WD                    ),
        .FWFT            (1                          )       
    )u_enc_fifo(      
        .i_rd_clk        (rd_clk                     ),
        .i_wr_clk        (wr_clk                     ),
        .i_rd_rst_n      (rd_rst_n  && (~rd_cfg_rst_d2)),
        .i_wr_rst_n      (wr_rst_n  && (~wr_cfg_rst_d2)),
        
        .i_aful_th       (4                          ),//(i)
        .i_amty_th       (4                          ),//(i)
        .i_wr            (fir_ovld                   ),//(i)
        .i_din           (enc_odat                   ),//(i)
        .i_rd            (head_rd                    ),//(i)
        .o_dout          (head_din                   ),//(o)
        .o_aful          (                           ),//(o)
        .o_amty          (                           ),//(o)
        .o_full          (                           ),//(o)
        .o_empty         (fifo2_empty                ) //(o)
    );                                               







endmodule





















































