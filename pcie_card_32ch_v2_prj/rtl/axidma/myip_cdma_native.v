// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : myip_cdma_native.v
// Module         : myip_cdma_native
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2022/12/14   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================

module myip_cdma_native #(
    parameter                               LB_BASE_ADDR    =  32'h40000   ,
    parameter                               LB_DATA_WDTH    =  32          ,
    parameter                               LB_ADDR_WDTH    =  32          ,
    parameter                               DGBCNT_WDTH     =  32          ,     
    parameter                               FIFO_DPTH       =  64          ,
    parameter                               AXI_DATA_WDTH   =  32          ,
    parameter                               AXI_ADDR_WDTH   =  64          ,
    parameter                               LEN_WDTH        =  32          
)(
    input                                   axi_clk                        ,//(i)
    input                                   axi_rst_n                      ,//(i)

    input                                   lb_rst_n                       ,//(i)
    input                                   lb_clk                         ,//(i)
    input                                   lb_wreq                        ,//(i)
    input             [LB_ADDR_WDTH-1:0]    lb_waddr                       ,//(i)
    input             [LB_DATA_WDTH-1:0]    lb_wdata                       ,//(i)
    output                                  lb_wack                        ,//(o)
    input                                   lb_rreq                        ,//(i)
    input             [LB_ADDR_WDTH-1:0]    lb_raddr                       ,//(i)
    output            [LB_DATA_WDTH-1:0]    lb_rdata                       ,//(o)
    output                                  lb_rack                        ,//(o)
    output                                  wirq                           ,//(o)
    output                                  rirq                           ,//(o)

    output            [AXI_ADDR_WDTH-1:0]   m_axi_awaddr                   ,//(o)
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
    output            [AXI_DATA_WDTH/8-1:0] m_axi_wstrb                    ,//(o)
    output            [AXI_DATA_WDTH-1:0]   m_axi_wdata                    ,//(o)
    output                                  m_axi_wlast                    ,//(o)


    output            [AXI_ADDR_WDTH-1:0]   m_axi_araddr                   ,//(o)
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
    input             [AXI_DATA_WDTH-1:0]   m_axi_rdata                    ,//(i)
    input                                   m_axi_rvalid                   ,//(i)
    output                                  m_axi_rready                   ,//(o)
    input                                   m_axi_rlast                    ,//(i)
    input             [ 1:0]                m_axi_rresp                    ,//(i)
    input             [ 3:0]                m_axi_rid                       //(i)



);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire          [LB_DATA_WDTH-1:0]    i_reg0                             ; // (i) 16'h0020     
    wire          [LB_DATA_WDTH-1:0]    i_reg1                             ; // (i) 16'h0024     
    wire          [LB_DATA_WDTH-1:0]    i_reg2                             ; // (i) 16'h0028     
    wire          [LB_DATA_WDTH-1:0]    i_reg3                             ; // (i) 16'h002C     
    wire          [LB_DATA_WDTH-1:0]    i_reg4                             ; // (i) 16'h0030     
    wire          [LB_DATA_WDTH-1:0]    i_reg5                             ; // (i) 16'h0034     
    wire          [LB_DATA_WDTH-1:0]    i_reg6                             ; // (i) 16'h0038     
    wire          [LB_DATA_WDTH-1:0]    i_reg7                             ; // (i) 16'h003C     
    wire          [LB_DATA_WDTH-1:0]    o_reg0                             ; // (o) 16'h0040     
    wire          [LB_DATA_WDTH-1:0]    o_reg1                             ; // (o) 16'h0044     
    wire          [LB_DATA_WDTH-1:0]    o_reg2                             ; // (o) 16'h0048     
    wire          [LB_DATA_WDTH-1:0]    o_reg3                             ; // (o) 16'h004C     
    wire          [LB_DATA_WDTH-1:0]    o_reg4                             ; // (o) 16'h0050     
    wire          [LB_DATA_WDTH-1:0]    o_reg5                             ; // (o) 16'h0054     
    wire          [LB_DATA_WDTH-1:0]    o_reg6                             ; // (o) 16'h0058     
    wire          [LB_DATA_WDTH-1:0]    o_reg7                             ; // (o) 16'h005C     
    wire          [LB_DATA_WDTH-1:0]    o_reg8                             ; // (o) 16'h0060     
    wire          [LB_DATA_WDTH-1:0]    o_reg9                             ; // (o) 16'h0064     
    wire          [LB_DATA_WDTH-1:0]    o_rega                             ; // (o) 16'h0068     
    wire          [LB_DATA_WDTH-1:0]    o_regb                             ; // (o) 16'h006C     


    wire                                cfg_wsoft_rst                      ;
    wire                                cfg_wstart                         ;
    wire                                cfg_widle                          ;
    wire          [LEN_WDTH -1:0]       cfg_wr_times                       ;
    wire          [AXI_ADDR_WDTH-1:0]   cfg_base_waddr                     ;
    wire          [LEN_WDTH -1:0]       cfg_wlen                           ;
    wire          [7:0]                 cfg_wburst_len                     ;
    wire                                cfg_wirq_en                        ;
    wire                                cfg_wirq_clr                       ;

    wire                                wstart_vld                         ;
    wire                                wstart_rdy                         ;
    wire          [AXI_ADDR_WDTH-1:0]   waddr                              ;
    wire          [7:0]                 wburst_len                         ;


    wire                                cfg_rsoft_rst                      ;
    wire                                cfg_rstart                         ;
    wire                                cfg_ridle                          ;
    wire          [LEN_WDTH -1:0]       cfg_rd_times                       ;
    wire          [AXI_ADDR_WDTH-1:0]   cfg_base_raddr                     ;
    wire          [LEN_WDTH -1:0]       cfg_rlen                           ;
    wire          [7:0]                 cfg_rburst_len                     ;
    wire                                cfg_rirq_en                        ;
    wire                                cfg_rirq_clr                       ;

    wire                                rstart_vld                         ;
    wire                                rstart_rdy                         ;
    wire          [AXI_ADDR_WDTH-1:0]   raddr                              ;
    wire          [7:0]                 rburst_len                         ;

    wire                                fifo_wr                            ;//(i)
    wire          [AXI_DATA_WDTH-1:0]   fifo_din                           ;//(i)
    wire                                fifo_full                          ;//(o)
    wire                                fifo_rd                            ;//(i)
    wire          [AXI_DATA_WDTH-1:0]   fifo_dout                          ;//(o)
    wire                                fifo_empty                         ;//(o)

    wire                                err_irq                            ;
    reg           [1:0]                 err_sts                            ;
    reg                                 start_d1                           ;
    reg                                 start_d2                           ;
    wire                                start_pos                          ;

    wire                                dbg_cnt_clr                        ;//(i)
    wire          [DGBCNT_WDTH-1:0]     dbg_axi_awvalid                    ;//(o)
    wire          [DGBCNT_WDTH-1:0]     dbg_axi_bvalid                     ;//(o)
    wire          [DGBCNT_WDTH-1:0]     dbg_axi_wvalid                     ;//(o)
    wire          [DGBCNT_WDTH-1:0]     dbg_axi_wlast                      ;//(o)
    wire          [DGBCNT_WDTH-1:0]     dbg_axi_wr_err_cnt                 ;//(o)
    wire                                dbg_axi_wr_err                     ;//(o)
    wire          [DGBCNT_WDTH-1:0]     dbg_axi_arvalid                    ;//(o)
    wire          [DGBCNT_WDTH-1:0]     dbg_axi_rvalid                     ;//(o)
    wire          [DGBCNT_WDTH-1:0]     dbg_axi_rlast                      ;//(o)
    wire          [DGBCNT_WDTH-1:0]     dbg_axi_rd_err_cnt                 ;//(o)
    wire                                dbg_axi_rd_err                     ;//(o)


    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign        cfg_base_waddr =           {o_reg1,o_reg0}                 ;//8'h44 8'h40
    assign        cfg_wlen       =                 o_reg2                    ;//8'h48
    assign        cfg_wburst_len =                 o_reg3[7:0]               ;//8'h4C
    assign        cfg_wstart     =                   o_reg4[0]               ;//8'h50
    assign        cfg_wsoft_rst  =                   o_reg4[1]               ;//
    assign        cfg_wirq_en    =                   o_reg4[8]               ;//
    assign        cfg_wirq_clr   =                   o_reg4[9]               ;//
                                                                              //
    assign        i_reg0         =      {32'd0,err_sts,err_irq,rirq,cfg_ridle,wirq,cfg_widle};//8'h20
    assign        i_reg1         =                    cfg_wr_times           ;//8'h24

    assign        cfg_base_raddr =           {o_reg7,o_reg6}                 ;//8'h5C 8'h58
    assign        cfg_rlen       =                 o_reg2                    ;//8'h48
    assign        cfg_rburst_len =                 o_reg3[7:0]               ;//8'h4C
    assign        cfg_rstart     =                   o_reg4[0]               ;//8'h50
    assign        cfg_rsoft_rst  =                   o_reg4[1]               ;//
    assign        cfg_rirq_en    =                   o_reg4[10]              ;//
    assign        cfg_rirq_clr   =                   o_reg4[11]              ;//
    assign        cfg_errirq_en  =                   o_reg4[12]              ;//ERR INT
    assign        cfg_errirq_clr =                   o_reg4[13]              ;//
                                                                              //
    assign        i_reg4         =          {30'd0,rirq,cfg_ridle}           ;//8'h30
    assign        i_reg5         =                    cfg_rd_times           ;//8'h34


//    wire                                fifo_wr                            ;//(i)
//    wire          [AXI_DATA_WDTH-1:0]   fifo_din                           ;//(i)
//    wire                                fifo_full                          ;//(o)
//    wire                                fifo_rd                            ;//(i)
//    wire          [AXI_DATA_WDTH-1:0]   fifo_dout                          ;//(i)
//    wire                                fifo_empty                         ;//(o)
    
    assign        fifo_wr        =       fifo_rd                             ;
    assign        fifo_din       =       fifo_dout                           ;
    assign        fifo_rd        =      (~fifo_empty) && (~fifo_full)        ;
    assign        start_pos      =      start_d1 && (~start_d2)              ;
    assign        err_irq        =      |err_sts                             ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge lb_clk or negedge lb_rst_n)
        if(!lb_rst_n)begin
            start_d1  <= 1'b0;
            start_d2  <= 1'b0;
        end else begin
            start_d1  <= cfg_wstart;
            start_d2  <= start_d1;
        end
         
    always@(posedge lb_clk or negedge lb_rst_n)
        if(!lb_rst_n)begin
            err_sts   <= 2'b00;
        end else if(cfg_errirq_clr)begin
            err_sts   <= 2'b00;
        end else if(~(cfg_widle && cfg_ridle) && start_pos && cfg_errirq_en) begin
            err_sts   <= 2'b10;
        end else if((cfg_wlen==32'd0) && start_pos && (cfg_widle && cfg_ridle)) begin
            err_sts   <= 2'b01;
        end



    myip_cdma_cfg #(
        .LB_BASE_ADDR                   (LB_BASE_ADDR            ),
        .LB_DATA_WDTH                   (LB_DATA_WDTH            ),
        .LB_ADDR_WDTH                   (LB_ADDR_WDTH            )
    )u_myip_cdma_cfg(
        .lb_rst_n                       (lb_rst_n                ), //(i)
        .lb_clk                         (lb_clk                  ), //(i)
        .lb_wreq                        (lb_wreq                 ), //(i)
        .lb_waddr                       (lb_waddr                ), //(i)
        .lb_wdata                       (lb_wdata                ), //(i)
        .lb_wack                        (lb_wack                 ), //(o)
        .lb_rreq                        (lb_rreq                 ), //(i)
        .lb_raddr                       (lb_raddr                ), //(i)
        .lb_rdata                       (lb_rdata                ), //(o)
        .lb_rack                        (lb_rack                 ), //(o)

        .dbg_cnt_clr                    (dbg_cnt_clr             ),//(i)
        .dbg_axi_awvalid                (dbg_axi_awvalid         ),//(o)
        .dbg_axi_bvalid                 (dbg_axi_bvalid          ),//(o)
        .dbg_axi_wvalid                 (dbg_axi_wvalid          ),//(o)
        .dbg_axi_wlast                  (dbg_axi_wlast           ),//(o)
        .dbg_axi_wr_err_cnt             (dbg_axi_wr_err_cnt      ),//(o)
        .dbg_axi_wr_err                 (dbg_axi_wr_err          ),//(o)
        .dbg_axi_arvalid                (dbg_axi_arvalid         ),//(o)
        .dbg_axi_rvalid                 (dbg_axi_rvalid          ),//(o)
        .dbg_axi_rlast                  (dbg_axi_rlast           ),//(o)
        .dbg_axi_rd_err_cnt             (dbg_axi_rd_err_cnt      ),//(o)
        .dbg_axi_rd_err                 (dbg_axi_rd_err          ),//(o)    	

        .i_reg0                         (i_reg0                  ), // (i) 16'h0020     
        .i_reg1                         (i_reg1                  ), // (i) 16'h0024     
        .i_reg2                         (i_reg2                  ), // (i) 16'h0028     
        .i_reg3                         (i_reg3                  ), // (i) 16'h002C     
        .i_reg4                         (i_reg4                  ), // (i) 16'h0030     
        .i_reg5                         (i_reg5                  ), // (i) 16'h0034     
        .i_reg6                         (i_reg6                  ), // (i) 16'h0038     
        .i_reg7                         (i_reg7                  ), // (i) 16'h003C     
        .o_reg0                         (o_reg0                  ), // (o) 16'h0040     
        .o_reg1                         (o_reg1                  ), // (o) 16'h0044     
        .o_reg2                         (o_reg2                  ), // (o) 16'h0048     
        .o_reg3                         (o_reg3                  ), // (o) 16'h004C     
        .o_reg4                         (o_reg4                  ), // (o) 16'h0050     
        .o_reg5                         (o_reg5                  ), // (o) 16'h0054     
        .o_reg6                         (o_reg6                  ), // (o) 16'h0058     
        .o_reg7                         (o_reg7                  ), // (o) 16'h005C     
        .o_reg8                         (o_reg8                  ), // (o) 16'h0060     
        .o_reg9                         (o_reg9                  ), // (o) 16'h0064     
        .o_rega                         (o_rega                  ), // (o) 16'h0068     
        .o_regb                         (o_regb                  )  // (o) 16'h006C     
    );




    axidma_wr_fsm #(
        .LEN_WDTH                       (LEN_WDTH                ),
        .DATA_WDTH                      (AXI_DATA_WDTH           ),
        .ADDR_WDTH                      (AXI_ADDR_WDTH           )
    )u_axidma_wr_fsm(                   
        .sys_clk                        (axi_clk                 ),//(i)
        .sys_rst_n                      (axi_rst_n               ),//(i)
        .cfg_wburst_len                 (cfg_wburst_len          ),//(i)
        .cfg_wsoft_rst                  (cfg_wsoft_rst           ),//(i)
        .cfg_wstart                     (cfg_wstart              ),//(i)
        .cfg_waddr                      (cfg_base_waddr          ),//(i)
        .cfg_wlen                       (cfg_wlen                ),//(i)
        .cfg_widle                      (cfg_widle               ),//(o)
        .cfg_wr_times                   (cfg_wr_times            ),//(o)
        .cfg_wirq_en                    (cfg_wirq_en             ),//(i)
        .cfg_wirq_clr                   (cfg_wirq_clr            ),//(i)
        .wirq                           (wirq                    ),//(o)

        .wstart_vld                     (wstart_vld              ),//(i)
        .wstart_rdy                     (wstart_rdy              ),//(o)
        .waddr                          (waddr                   ),//(i)
        .wburst_len                     (wburst_len              ) //(i)
    );



    axidma_rd_fsm #(
        .LEN_WDTH                       (LEN_WDTH                ),
        .DATA_WDTH                      (AXI_DATA_WDTH           ),
        .ADDR_WDTH                      (AXI_ADDR_WDTH           )
    )u_axidma_rd_fsm(                                                   
        .sys_clk                        (axi_clk                 ),//(i)
        .sys_rst_n                      (axi_rst_n               ),//(i)
        .cfg_rburst_len                 (cfg_rburst_len          ),//(i)
        .cfg_rsoft_rst                  (cfg_rsoft_rst           ),//(i)
        .cfg_rstart                     (cfg_rstart              ),//(i)
        .cfg_raddr                      (cfg_base_raddr          ),//(i)
        .cfg_rlen                       (cfg_rlen                ),//(i)
        .cfg_ridle                      (cfg_ridle               ),//(o)
        .cfg_rd_times                   (cfg_rd_times            ),//(o)
        .cfg_rirq_en                    (cfg_rirq_en             ),//(i)
        .cfg_rirq_clr                   (cfg_rirq_clr            ),//(i)
        .rirq                           (rirq                    ),//(o)

        .rstart_vld                     (rstart_vld              ),//(i)
        .rstart_rdy                     (rstart_rdy              ),//(o)
        .raddr                          (raddr                   ),//(i)
        .rburst_len                     (rburst_len              ) //(i)
    );



    fifo2axi_native #(
        .FIFO_DPTH                      (FIFO_DPTH               ),
        .DATA_WDTH                      (AXI_DATA_WDTH           ),
        .ADDR_WDTH                      (AXI_ADDR_WDTH           ),
		.DGBCNT_EN                      (1                       ),
		.DGBCNT_WDTH                    (DGBCNT_WDTH             )
    )u_fifo2axi_native(                                                 
        .sys_clk                        (axi_clk                 ),//(i)
        .sys_rst_n                      (axi_rst_n               ),//(i)
        .axi_clk                        (axi_clk                 ),//(i)
        .axi_rst_n                      (axi_rst_n               ),//(i)
        .fifo_wr                        (fifo_wr                 ),//(i)
        .fifo_din                       (fifo_din                ),//(i)
        .fifo_full                      (fifo_full               ),//(o)
        .wsoft_rst                      (cfg_wsoft_rst           ),//(i)
        .wstart_vld                     (wstart_vld              ),//(i)
        .wstart_rdy                     (wstart_rdy              ),//(o)
        .waddr                          (waddr                   ),//(i)
        .wburst_len                     (wburst_len              ),//(i)
                                                                 
        .m_axi_awaddr                   (m_axi_awaddr            ),//(o)
        .m_axi_awburst                  (m_axi_awburst           ),//(o)
        .m_axi_awcache                  (m_axi_awcache           ),//(o)
        .m_axi_awid                     (m_axi_awid              ),//(o)
        .m_axi_awlen                    (m_axi_awlen             ),//(o)
        .m_axi_awlock                   (m_axi_awlock            ),//(o)
        .m_axi_awprot                   (m_axi_awprot            ),//(o)
        .m_axi_awqos                    (m_axi_awqos             ),//(o)
        .m_axi_awvalid                  (m_axi_awvalid           ),//(o)
        .m_axi_awready                  (m_axi_awready           ),//(i)
        .m_axi_awsize                   (m_axi_awsize            ),//(o)
        .m_axi_awuser                   (m_axi_awuser            ),//(o)
        .m_axi_bvalid                   (m_axi_bvalid            ),//(i)
        .m_axi_bready                   (m_axi_bready            ),//(o)
        .m_axi_bresp                    (m_axi_bresp             ),//(i)
        .m_axi_bid                      (m_axi_bid               ),//(i)
        .m_axi_wvalid                   (m_axi_wvalid            ),//(o)
        .m_axi_wready                   (m_axi_wready            ),//(i)
        .m_axi_wstrb                    (m_axi_wstrb             ),//(o)
        .m_axi_wdata                    (m_axi_wdata             ),//(o)
        .m_axi_wlast                    (m_axi_wlast             ),//(o)
                                                                 
        .fifo_rd                        (fifo_rd                 ),//(i)
        .fifo_dout                      (fifo_dout               ),//(i)
        .fifo_empty                     (fifo_empty              ),//(o)
        .rsoft_rst                      (cfg_rsoft_rst           ),//(i)
        .rstart_vld                     (rstart_vld              ),//(i)
        .rstart_rdy                     (rstart_rdy              ),//(o)
        .raddr                          (raddr                   ),//(i)
        .rburst_len                     (rburst_len              ),//(i)
                                                                 
        .m_axi_araddr                   (m_axi_araddr            ),//(o)
        .m_axi_arburst                  (m_axi_arburst           ),//(o)
        .m_axi_arcache                  (m_axi_arcache           ),//(o)
        .m_axi_arid                     (m_axi_arid              ),//(o)
        .m_axi_arlen                    (m_axi_arlen             ),//(o)
        .m_axi_arlock                   (m_axi_arlock            ),//(o)
        .m_axi_arprot                   (m_axi_arprot            ),//(o)
        .m_axi_arqos                    (m_axi_arqos             ),//(o)
        .m_axi_arvalid                  (m_axi_arvalid           ),//(o)
        .m_axi_arready                  (m_axi_arready           ),//(i)
        .m_axi_arsize                   (m_axi_arsize            ),//(o)
        .m_axi_aruser                   (m_axi_aruser            ),//(o)
        .m_axi_rdata                    (m_axi_rdata             ),//(i)
        .m_axi_rvalid                   (m_axi_rvalid            ),//(i)
        .m_axi_rready                   (m_axi_rready            ),//(o)
        .m_axi_rlast                    (m_axi_rlast             ),//(i)
        .m_axi_rresp                    (m_axi_rresp             ),//(i)
        .m_axi_rid                      (m_axi_rid               ),//(i)
		
        .dbg_cnt_clr                    (dbg_cnt_clr             ),//(i)
        .dbg_axi_awvalid                (dbg_axi_awvalid         ),//(o)
        .dbg_axi_bvalid                 (dbg_axi_bvalid          ),//(o)
        .dbg_axi_wvalid                 (dbg_axi_wvalid          ),//(o)
        .dbg_axi_wlast                  (dbg_axi_wlast           ),//(o)
        .dbg_axi_wr_err_cnt             (dbg_axi_wr_err_cnt      ),//(o)
        .dbg_axi_wr_err                 (dbg_axi_wr_err          ),//(o)
        .dbg_axi_arvalid                (dbg_axi_arvalid         ),//(o)
        .dbg_axi_rvalid                 (dbg_axi_rvalid          ),//(o)
        .dbg_axi_rlast                  (dbg_axi_rlast           ),//(o)
        .dbg_axi_rd_err_cnt             (dbg_axi_rd_err_cnt      ),//(o)
        .dbg_axi_rd_err                 (dbg_axi_rd_err          ) //(o)
    );












endmodule
































































