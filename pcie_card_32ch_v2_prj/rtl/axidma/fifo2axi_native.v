// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : fifo2axi_native.v
// Module         : fifo2axi_native
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2020/01/10   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================

module fifo2axi_native #(
    parameter                               FIFO_DPTH   =  128             ,
    parameter                               DATA_WDTH   =  32              ,
    parameter                               ADDR_WDTH   =  32              ,
    parameter                               DGBCNT_EN   =   1              ,
    parameter                               DGBCNT_WDTH =  16              
)(
    input                                   sys_clk                        ,//(i)
    input                                   sys_rst_n                      ,//(i)
    input                                   axi_clk                        ,//(i)
    input                                   axi_rst_n                      ,//(i)

    // fifo wr ----> axi wr
    input                                   fifo_wr                        ,//(i)
    input             [DATA_WDTH-1:0]       fifo_din                       ,//(i)
    output                                  fifo_full                      ,//(o)

    input                                   wsoft_rst                      ,//(i)
    input                                   wstart_vld                     ,//(i)
    output                                  wstart_rdy                     ,//(o)
    input             [ADDR_WDTH-1:0]       waddr                          ,//(i)
    input             [7:0]                 wburst_len                     ,//(i)

    output            [ADDR_WDTH-1:0]       m_axi_awaddr                   ,//(o)
    output            [ 1:0]                m_axi_awburst                  ,//(o)
    output            [ 3:0]                m_axi_awcache                  ,//(o)
    output            [ 3:0]                m_axi_awid                     ,//(o)
    output            [ 7:0]                m_axi_awlen                    ,//(o)
    output                                  m_axi_awlock                   ,//(o)
    output            [ 2:0]                m_axi_awprot                   ,//(o)
    output            [ 3:0]                m_axi_awqos                    ,//(o)
    output                                  m_axi_awvalid                  ,//(o)
    input                                   m_axi_awready                  ,//(i)
    output            [ 2:0]                m_axi_awsize                   ,//(o)
    output                                  m_axi_awuser                   ,//(o)
    input                                   m_axi_bvalid                   ,//(i)
    output                                  m_axi_bready                   ,//(o)
    input             [ 1:0]                m_axi_bresp                    ,//(i)
    input             [ 3:0]                m_axi_bid                      ,//(i)

    output                                  m_axi_wvalid                   ,//(o)
    input                                   m_axi_wready                   ,//(i)
    output            [DATA_WDTH/8-1:0]     m_axi_wstrb                    ,//(o)
    output            [DATA_WDTH-1:0]       m_axi_wdata                    ,//(o)
    output                                  m_axi_wlast                    ,//(o)

    // fifo rd <---- axi rd
    input                                   fifo_rd                        ,//(i)
    output            [DATA_WDTH-1:0]       fifo_dout                      ,//(i)
    output                                  fifo_empty                     ,//(o)

    input                                   rsoft_rst                      ,//(i)
    input                                   rstart_vld                     ,//(i)
    output                                  rstart_rdy                     ,//(o)
    input             [ADDR_WDTH-1:0]       raddr                          ,//(i)
    input             [7:0]                 rburst_len                     ,//(i)

    output            [ADDR_WDTH-1:0]       m_axi_araddr                   ,//(o)
    output            [ 1:0]                m_axi_arburst                  ,//(o)
    output            [ 3:0]                m_axi_arcache                  ,//(o)
    output            [ 3:0]                m_axi_arid                     ,//(o)
    output            [ 7:0]                m_axi_arlen                    ,//(o)
    output                                  m_axi_arlock                   ,//(o)
    output            [ 2:0]                m_axi_arprot                   ,//(o)
    output            [ 3:0]                m_axi_arqos                    ,//(o)
    output                                  m_axi_arvalid                  ,//(o)
    input                                   m_axi_arready                  ,//(i)
    output            [ 2:0]                m_axi_arsize                   ,//(o)
    output                                  m_axi_aruser                   ,//(o)

    input             [DATA_WDTH-1:0]       m_axi_rdata                    ,//(i)
    input                                   m_axi_rvalid                   ,//(i)
    output                                  m_axi_rready                   ,//(o)
    input                                   m_axi_rlast                    ,//(i)
    input             [ 1:0]                m_axi_rresp                    ,//(i)
    input             [ 3:0]                m_axi_rid                      ,//(i)

    input                                   dbg_cnt_clr                    ,//(i)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_awvalid                ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_bvalid                 ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_wvalid                 ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_wlast                  ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_wr_err_cnt             ,//(o)
    output                                  dbg_axi_wr_err                 ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_arvalid                ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_rvalid                 ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_rlast                  ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_rd_err_cnt             ,//(o)
    output                                  dbg_axi_rd_err                  //(o)

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
//    assign          fifo_wr          =     vga_en_d2                         ;




// =================================================================================================
// RTL Body
// =================================================================================================
    axi_wr_native #(
        .FIFO_DPTH                      (FIFO_DPTH         ),
        .DATA_WDTH                      (DATA_WDTH         ),
        .ADDR_WDTH                      (ADDR_WDTH         ),
		.DGBCNT_EN                      (DGBCNT_EN         ),
		.DGBCNT_WDTH                    (DGBCNT_WDTH       )
    )u_axi_wr_native(                                           
        .sys_clk                        (sys_clk           ),//(i)
        .sys_rst_n                      (sys_rst_n         ),//(i)
        .axi_clk                        (axi_clk           ),//(i)
        .axi_rst_n                      (axi_rst_n         ),//(i)
        .fifo_wr                        (fifo_wr           ),//(i)
        .fifo_din                       (fifo_din          ),//(i)
        .fifo_full                      (fifo_full         ),//(o)
        .wsoft_rst                      (wsoft_rst         ),//(i)
        .wstart_vld                     (wstart_vld        ),//(i)
        .wstart_rdy                     (wstart_rdy        ),//(o)
        .waddr                          (waddr             ),//(i)
        .wburst_len                     (wburst_len        ),//(i)
                                                           
        .m_axi_awaddr                   (m_axi_awaddr      ),//(o)
        .m_axi_awburst                  (m_axi_awburst     ),//(o)
        .m_axi_awcache                  (m_axi_awcache     ),//(o)
        .m_axi_awid                     (m_axi_awid        ),//(o)
        .m_axi_awlen                    (m_axi_awlen       ),//(o)
        .m_axi_awlock                   (m_axi_awlock      ),//(o)
        .m_axi_awprot                   (m_axi_awprot      ),//(o)
        .m_axi_awqos                    (m_axi_awqos       ),//(o)
        .m_axi_awvalid                  (m_axi_awvalid     ),//(o)
        .m_axi_awready                  (m_axi_awready     ),//(i)
        .m_axi_awsize                   (m_axi_awsize      ),//(o)
        .m_axi_awuser                   (m_axi_awuser      ),//(o)
        .m_axi_bvalid                   (m_axi_bvalid      ),//(i)
        .m_axi_bready                   (m_axi_bready      ),//(o)
        .m_axi_bresp                    (m_axi_bresp       ),//(i)
        .m_axi_bid                      (m_axi_bid         ),//(i)
        .m_axi_wvalid                   (m_axi_wvalid      ),//(o)
        .m_axi_wready                   (m_axi_wready      ),//(i)
        .m_axi_wstrb                    (m_axi_wstrb       ),//(o)
        .m_axi_wdata                    (m_axi_wdata       ),//(o)
        .m_axi_wlast                    (m_axi_wlast       ),//(o)

        .dbg_cnt_clr                    (dbg_cnt_clr       ),//(i)
        .dbg_axi_awvalid                (dbg_axi_awvalid   ),//(o)
        .dbg_axi_bvalid                 (dbg_axi_bvalid    ),//(o)
        .dbg_axi_wvalid                 (dbg_axi_wvalid    ),//(o)
        .dbg_axi_wlast                  (dbg_axi_wlast     ),//(o)
        .dbg_axi_wr_err_cnt             (dbg_axi_wr_err_cnt),//(o)
        .dbg_axi_wr_err                 (dbg_axi_wr_err    ) //(o)
    );


    axi_rd_native #(
        .FIFO_DPTH                      (FIFO_DPTH         ),
        .DATA_WDTH                      (DATA_WDTH         ),
        .ADDR_WDTH                      (ADDR_WDTH         ),
		.DGBCNT_EN                      (DGBCNT_EN         ),
		.DGBCNT_WDTH                    (DGBCNT_WDTH       )
    )u_axi_rd_native(                                      
        .sys_clk                        (sys_clk           ),//(i)
        .sys_rst_n                      (sys_rst_n         ),//(i)
        .axi_clk                        (axi_clk           ),//(i)
        .axi_rst_n                      (axi_rst_n         ),//(i)
        .fifo_rd                        (fifo_rd           ),//(i)
        .fifo_dout                      (fifo_dout         ),//(i)
        .fifo_empty                     (fifo_empty        ),//(o)
        .rsoft_rst                      (rsoft_rst         ),//(i)
        .rstart_vld                     (rstart_vld        ),//(i)
        .rstart_rdy                     (rstart_rdy        ),//(o)
        .raddr                          (raddr             ),//(i)
        .rburst_len                     (rburst_len        ),//(i)
                                                           
        .m_axi_araddr                   (m_axi_araddr      ),//(o)
        .m_axi_arburst                  (m_axi_arburst     ),//(o)
        .m_axi_arcache                  (m_axi_arcache     ),//(o)
        .m_axi_arid                     (m_axi_arid        ),//(o)
        .m_axi_arlen                    (m_axi_arlen       ),//(o)
        .m_axi_arlock                   (m_axi_arlock      ),//(o)
        .m_axi_arprot                   (m_axi_arprot      ),//(o)
        .m_axi_arqos                    (m_axi_arqos       ),//(o)
        .m_axi_arvalid                  (m_axi_arvalid     ),//(o)
        .m_axi_arready                  (m_axi_arready     ),//(i)
        .m_axi_arsize                   (m_axi_arsize      ),//(o)
        .m_axi_aruser                   (m_axi_aruser      ),//(o)
        .m_axi_rdata                    (m_axi_rdata       ),//(i)
        .m_axi_rvalid                   (m_axi_rvalid      ),//(i)
        .m_axi_rready                   (m_axi_rready      ),//(o)
        .m_axi_rlast                    (m_axi_rlast       ),//(i)
        .m_axi_rresp                    (m_axi_rresp       ),//(i)
        .m_axi_rid                      (m_axi_rid         ),//(i)

        .dbg_cnt_clr                    (dbg_cnt_clr       ),//(i)
        .dbg_axi_arvalid                (dbg_axi_arvalid   ),//(o)
        .dbg_axi_rvalid                 (dbg_axi_rvalid    ),//(o)
        .dbg_axi_rlast                  (dbg_axi_rlast     ),//(o)
        .dbg_axi_rd_err_cnt             (dbg_axi_rd_err_cnt),//(o)
        .dbg_axi_rd_err                 (dbg_axi_rd_err    ) //(o)
    );



endmodule





