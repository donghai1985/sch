// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : aurora2ddr_wr_burst.v
// Module         : aurora2ddr_wr_burst
// Function       : 
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2023/09/28   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================


module aurora2ddr_wr_burst #(
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               MAX_BLK_SIZE    =  32'h1000    ,
    parameter                               BURST_LEN       =  16           
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
    input                                   c0_user_clk                    ,//(i)
    input                                   c0_user_rst_n                  ,//(i)
    input                                   cfg_rst                        ,//(i)

    input             [127:0]               c0_m_axi_rx_tdata              ,//(i)
    input             [15 :0]               c0_m_axi_rx_tkeep              ,//(i)
    input                                   c0_m_axi_rx_tvalid             ,//(i)
    input                                   c0_m_axi_rx_tlast              ,//(i)

    output                                  ch0_wr_burst_req               ,//(o)
    output            [9:0]                 ch0_wr_burst_len               ,//(o)
    output            [DDR_ADDR_WD  -1:0]   ch0_wr_burst_addr              ,//(o)
    input                                   ch0_wr_burst_data_req          ,//(i)
    output            [DDR_DATA_WD  -1:0]   ch0_wr_burst_data              ,//(o)
    input                                   ch0_wr_burst_finish            ,//(i)
    output                                  ch0_irq_en                     ,//(o)
    input                                   ch0_irq_clr                    ,//(i)

    output            [31 :0]               ch0_blk_cnt                    ,//(o)
    output            [31 :0]               ch0_fifo_full_cnt              ,//(o)
    output            [31 :0]               ch0_irq_trig_cnt               ,//(o)
    output   reg      [31 :0]               ch0_tlast_cnt                   //(o)

   
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam         BASE_ADDR0     =     16'h0000                             ;
    localparam         BASE_ADDR1     =     16'h0000                             ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    ch0_fifo_full                        ;
    wire                                    ch0_tlast_vld                        ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign             ch0_tlast_vld  =     c0_m_axi_rx_tvalid && c0_m_axi_rx_tlast;



// =================================================================================================
// RTL Body
// =================================================================================================

    //---------------------------------------------------------------------
    // fifo2ddr_wr_burst Module Inst.
    //---------------------------------------------------------------------   
    fifo2ddr_wr_burst #(                                                     
        .WR_DATA_WD                         (128                        ),
        .DDR_ADDR_WD                        (DDR_ADDR_WD                ),
        .DDR_DATA_WD                        (DDR_DATA_WD                ),
        .BURST_LEN                          (BURST_LEN                  ),
        .BASE_ADDR                          (BASE_ADDR0                 ),
        .MAX_BLK_SIZE                       (MAX_BLK_SIZE               )       
    )u0_fifo2ddr_wr_burst(                
        .ddr_clk                            (ddr_clk                    ),//(i)
        .ddr_rst_n                          (ddr_rst_n                  ),//(i)
        .wr_clk                             (c0_user_clk                ),//(i)
        .wr_rst_n                           (c0_user_rst_n              ),//(i)
        .cfg_rst                            (cfg_rst                    ),//(i)
        .fifo_wr                            (c0_m_axi_rx_tvalid         ),//(i)
        .fifo_din                           (c0_m_axi_rx_tdata          ),//(i)
        .fifo_full                          (ch0_fifo_full              ),//(o)
        .fifo_full_cnt                      (ch0_fifo_full_cnt          ),//(o)
        .irq_trig_cnt                       (ch0_irq_trig_cnt           ),//(o)
        .wr_burst_req                       (ch0_wr_burst_req           ),//(o)
        .wr_burst_len                       (ch0_wr_burst_len           ),//(o)
        .wr_burst_addr                      (ch0_wr_burst_addr          ),//(o)
        .wr_burst_data_req                  (ch0_wr_burst_data_req      ),//(i)
        .wr_burst_data                      (ch0_wr_burst_data          ),//(o)
        .wr_burst_finish                    (ch0_wr_burst_finish        ),//(i)
        .blk_cnt                            (ch0_blk_cnt                ),//(o)
        .wr_8m_irq_en                       (ch0_irq_en                 ),//(o)
        .wr_8m_irq_clr                      (ch0_irq_clr                ) //(i)
    );                                                                   
    
    
    
    
    
    
    
    //---------------------------------------------------------------------
    // cmip_app_cnt Module Inst.
    //---------------------------------------------------------------------   
    localparam        PKT_END_FLAG     =    128'h5A5ADEAD_0000FFFF_5A5ADEAD_0000FFFF;
    localparam        PKT_OTH_FLAG     =    128'h00112233_44556677_8899AABB_CCDDEEFF;

    function automatic no_chk(
        input    [127:0]     data
    );begin:aaa
        no_chk = ~((data == PKT_END_FLAG) || (data == PKT_OTH_FLAG));
    end
    endfunction

    wire            [31 :0]               ch0_vld_cnt                   ;
    cmip_app_cnt #(
        .WDTH                               (32                         )
    )u2_cnt(                                                            
        .i_clk                              (c0_user_clk                ),//(i) 
        .i_rst_n                            (c0_user_rst_n              ),//(i) 
        .i_clr                              (cfg_rst                    ),//(i) 
        .i_vld                              (c0_m_axi_rx_tvalid && no_chk(c0_m_axi_rx_tdata)),//(i) 
        .o_cnt                              (ch0_vld_cnt                ) //(o) 
    );



    always@(posedge c0_user_clk or negedge c0_user_rst_n)
        if(~c0_user_rst_n)
            ch0_tlast_cnt <= 32'd0;
        else if(c0_m_axi_rx_tvalid && (c0_m_axi_rx_tdata == PKT_END_FLAG) )
            ch0_tlast_cnt <= ch0_vld_cnt;





endmodule





