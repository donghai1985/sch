// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : axi2ddr_inf.v
// Module         : axi2ddr_inf
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


module axi2ddr_inf #(
    parameter                               FIFO_DPTH       =  1024        ,
    parameter                               AXI_DATA_WD     =  128         ,
    parameter                               AXI_ADDR_WD     =  64          ,
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               DGBCNT_EN       =   1          ,
    parameter                               DGBCNT_WD       =  16          ,
    parameter                               MAX_BLK_SIZE    =  32'h1000    
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
    input                                   axi_clk                        ,//(i)
    input                                   axi_rst_n                      ,//(i)
    input                                   cfg_rst                        ,//(i)

    input             [AXI_ADDR_WD  -1:0]   s_axi_awaddr                   ,//(i)
    input             [ 1:0]                s_axi_awburst                  ,//(i)
    input             [ 3:0]                s_axi_awcache                  ,//(i)
    input             [ 3:0]                s_axi_awid                     ,//(i)
    input             [ 7:0]                s_axi_awlen                    ,//(i)
    input                                   s_axi_awlock                   ,//(i)
    input             [ 2:0]                s_axi_awprot                   ,//(i)
    input             [ 3:0]                s_axi_awqos                    ,//(i)
    input                                   s_axi_awvalid                  ,//(i)
    output                                  s_axi_awready                  ,//(o)
    input             [ 2:0]                s_axi_awsize                   ,//(i)
    input                                   s_axi_awuser                   ,//(i)
    output                                  s_axi_bvalid                   ,//(o)
    input                                   s_axi_bready                   ,//(i)
    output            [ 1:0]                s_axi_bresp                    ,//(o)
    output            [ 3:0]                s_axi_bid                      ,//(o)

    input             [AXI_ADDR_WD  -1:0]   s_axi_araddr                   ,//(i)
    input             [ 1:0]                s_axi_arburst                  ,//(i)
    input             [ 3:0]                s_axi_arcache                  ,//(i)
    input             [ 3:0]                s_axi_arid                     ,//(i)
    input             [ 7:0]                s_axi_arlen                    ,//(i)
    input                                   s_axi_arlock                   ,//(i)
    input             [ 2:0]                s_axi_arprot                   ,//(i)
    input             [ 3:0]                s_axi_arqos                    ,//(i)
    input                                   s_axi_arvalid                  ,//(i)
    output                                  s_axi_arready                  ,//(o)
    input             [ 2:0]                s_axi_arsize                   ,//(i)
    input                                   s_axi_aruser                   ,//(i)
    input                                   s_axi_wvalid                   ,//(i)
    output                                  s_axi_wready                   ,//(o)
    input             [AXI_DATA_WD  /8-1:0] s_axi_wstrb                    ,//(i)
    input             [AXI_DATA_WD    -1:0] s_axi_wdata                    ,//(i)
    input                                   s_axi_wlast                    ,//(i)

    output            [AXI_DATA_WD  -1:0]   s_axi_rdata                    ,//(o)
    output                                  s_axi_rvalid                   ,//(o)
    input                                   s_axi_rready                   ,//(i)
    output                                  s_axi_rlast                    ,//(o)
    output            [ 1:0]                s_axi_rresp                    ,//(o)
    output            [ 3:0]                s_axi_rid                      ,//(o)

    output                                  wr_burst_req                   ,//(o)      
    output            [9:0]                 wr_burst_len                   ,//(o)  
    output            [AXI_ADDR_WD  -1:0]   wr_burst_addr                  ,//(o)    
    input                                   wr_burst_data_req              ,//(i) 
    output            [DDR_DATA_WD  -1:0]   wr_burst_data                  ,//(o)
    input                                   wr_burst_finish                ,//(i)

    input             [DDR_ADDR_WD  -1:0]   avail_addr                     ,//(i) 
    output                                  rd_burst_req                   ,//(o)      
    output            [9:0]                 rd_burst_len                   ,//(o)  
    output            [AXI_ADDR_WD  -1:0]   rd_burst_addr                  ,//(o)    
    input                                   rd_burst_data_valid            ,//(i) 
    input             [DDR_DATA_WD  -1:0]   rd_burst_data                  ,//(o)
    input                                   rd_burst_finish                ,//(i)

    input             [7:0]                 cfg_irq_clr_cnt                ,//(i)
    output                                  rd_8m_irq_en                   ,//(o)
    input                                   rd_8m_irq_clr                  ,//(i)
    output            [DDR_ADDR_WD-1:0]     rd_blk_cnt                     ,//(o)
    output            [DDR_ADDR_WD-1:0]     rd_blk_irq_cnt                 ,//(o)
    output            [31:0]                adc_chk_suc_cnt                ,//(o)
    output            [31:0]                adc_chk_err_cnt                ,//(o)
    output            [31:0]                enc_chk_suc_cnt                ,//(o)
    output            [31:0]                enc_chk_err_cnt                ,//(o)
    output            [31:0]                dr_adc_chk_suc_cnt             ,//(o)
    output            [31:0]                dr_adc_chk_err_cnt             ,//(o)
    output            [31:0]                dr_enc_chk_suc_cnt             ,//(o)
    output            [31:0]                dr_enc_chk_err_cnt              //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    


    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------


    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------



// =================================================================================================
// RTL Body
// =================================================================================================

    //---------------------------------------------------------------------
    // axi2ddr_wr_inf Inst.
    //---------------------------------------------------------------------     
    axi2ddr_wr_inf #(                                                    
        .FIFO_DPTH                    (FIFO_DPTH                 ),
        .AXI_DATA_WD                  (AXI_DATA_WD               ),
        .AXI_ADDR_WD                  (AXI_ADDR_WD               ),
        .DDR_DATA_WD                  (DDR_DATA_WD               ),
        .DGBCNT_EN                    (DGBCNT_EN                 ),
        .DGBCNT_WD                    (DGBCNT_WD                 )       
    )u_axi2ddr_wr_inf( 
        .ddr_clk                      (ddr_clk                   ),//(i)
        .ddr_rst_n                    (ddr_rst_n                 ),//(i)
        .axi_clk                      (axi_clk                   ),//(i)
        .axi_rst_n                    (axi_rst_n                 ),//(i)
        .cfg_rst                      (cfg_rst                   ),//(i)
        .s_axi_awaddr                 (s_axi_awaddr              ),//(i)
        .s_axi_awburst                (s_axi_awburst             ),//(i)
        .s_axi_awcache                (s_axi_awcache             ),//(i)
        .s_axi_awid                   (s_axi_awid                ),//(i)
        .s_axi_awlen                  (s_axi_awlen               ),//(i)
        .s_axi_awlock                 (s_axi_awlock              ),//(i)
        .s_axi_awprot                 (s_axi_awprot              ),//(i)
        .s_axi_awqos                  (s_axi_awqos               ),//(i)
        .s_axi_awvalid                (s_axi_awvalid             ),//(i)
        .s_axi_awready                (s_axi_awready             ),//(o)
        .s_axi_awsize                 (s_axi_awsize              ),//(i)
        .s_axi_awuser                 (s_axi_awuser              ),//(i)
        .s_axi_bvalid                 (s_axi_bvalid              ),//(o)
        .s_axi_bready                 (s_axi_bready              ),//(i)
        .s_axi_bresp                  (s_axi_bresp               ),//(o)
        .s_axi_bid                    (s_axi_bid                 ),//(o)
        .s_axi_wvalid                 (s_axi_wvalid              ),//(i)
        .s_axi_wready                 (s_axi_wready              ),//(o)
        .s_axi_wstrb                  (s_axi_wstrb               ),//(i)
        .s_axi_wdata                  (s_axi_wdata               ),//(i)
        .s_axi_wlast                  (s_axi_wlast               ),//(i)
//        .rd_burst_req                 (rd_burst_req              ),//(i)
        .wr_burst_req                 (wr_burst_req              ),//(o)
        .wr_burst_len                 (wr_burst_len              ),//(o)
        .wr_burst_addr                (wr_burst_addr             ),//(o)
        .wr_burst_data_req            (wr_burst_data_req         ),//(i)
        .wr_burst_data                (wr_burst_data             ),//(o)
        .wr_burst_finish              (wr_burst_finish           ),//(i)
        .dbg_cnt_clr                  (1'b0                      ),//(i)
        .dbg_axi_awvalid              (                          ) //(o)
    );                                                                   


    //---------------------------------------------------------------------
    // axi2ddr_rd_inf Inst.
    //---------------------------------------------------------------------     
   
    axi2ddr_rd_inf #(                                                    
        .FIFO_DPTH                    (FIFO_DPTH                 ),
        .AXI_DATA_WD                  (AXI_DATA_WD               ),
        .AXI_ADDR_WD                  (AXI_ADDR_WD               ),
        .DDR_DATA_WD                  (DDR_DATA_WD               ),
        .DDR_ADDR_WD                  (DDR_ADDR_WD               ),
        .DGBCNT_EN                    (DGBCNT_EN                 ),
        .DGBCNT_WD                    (DGBCNT_WD                 ),
        .MAX_BLK_SIZE                 (MAX_BLK_SIZE              )     
    )u_axi2ddr_rd_inf( 
        .ddr_clk                      (ddr_clk                   ),//(i)
        .ddr_rst_n                    (ddr_rst_n                 ),//(i)
        .axi_clk                      (axi_clk                   ),//(i)
        .axi_rst_n                    (axi_rst_n                 ),//(i)
        .cfg_rst                      (cfg_rst                   ),//(i)
        .s_axi_araddr                 (s_axi_araddr              ),//(i)
        .s_axi_arburst                (s_axi_arburst             ),//(i)
        .s_axi_arcache                (s_axi_arcache             ),//(i)
        .s_axi_arid                   (s_axi_arid                ),//(i)
        .s_axi_arlen                  (s_axi_arlen               ),//(i)
        .s_axi_arlock                 (s_axi_arlock              ),//(i)
        .s_axi_arprot                 (s_axi_arprot              ),//(i)
        .s_axi_arqos                  (s_axi_arqos               ),//(i)
        .s_axi_arvalid                (s_axi_arvalid             ),//(i)
        .s_axi_arready                (s_axi_arready             ),//(o)
        .s_axi_arsize                 (s_axi_arsize              ),//(i)
        .s_axi_aruser                 (s_axi_aruser              ),//(i)
        .s_axi_rdata                  (s_axi_rdata               ),//(o)
        .s_axi_rvalid                 (s_axi_rvalid              ),//(o)
        .s_axi_rready                 (s_axi_rready              ),//(i)
        .s_axi_rlast                  (s_axi_rlast               ),//(o)
        .s_axi_rresp                  (s_axi_rresp               ),//(o)
        .s_axi_rid                    (s_axi_rid                 ),//(o)
        .avail_addr                   (avail_addr                ),//(i)
        .rd_burst_req                 (rd_burst_req              ),//(o)
        .rd_burst_len                 (rd_burst_len              ),//(o)
        .rd_burst_addr                (rd_burst_addr             ),//(o)
        .rd_burst_data_valid          (rd_burst_data_valid       ),//(i)
        .rd_burst_data                (rd_burst_data             ),//(i)
        .rd_burst_finish              (rd_burst_finish           ),//(i)
		.cfg_irq_clr_cnt              (cfg_irq_clr_cnt           ),//(i)
        .rd_8m_irq_en                 (rd_8m_irq_en              ),//(o)
        .rd_8m_irq_clr                (rd_8m_irq_clr             ),//(i)
        .rd_blk_cnt                   (rd_blk_cnt                ),//(o)
        .rd_blk_irq_cnt               (rd_blk_irq_cnt            ),//(o)
        .adc_chk_suc_cnt              (adc_chk_suc_cnt           ),//(o)
        .adc_chk_err_cnt              (adc_chk_err_cnt           ),//(o)
        .enc_chk_suc_cnt              (enc_chk_suc_cnt           ),//(o)
        .enc_chk_err_cnt              (enc_chk_err_cnt           ),//(o)
        .dr_adc_chk_suc_cnt           (dr_adc_chk_suc_cnt        ),//(o)
        .dr_adc_chk_err_cnt           (dr_adc_chk_err_cnt        ),//(o)
        .dr_enc_chk_suc_cnt           (dr_enc_chk_suc_cnt        ),//(o)
        .dr_enc_chk_err_cnt           (dr_enc_chk_err_cnt        ) //(o)
    );                                                                  




    



endmodule





