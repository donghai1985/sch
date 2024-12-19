// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : axi_wr_native.v
// Module         : axi_wr_native
// Function       : 
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


module axi_wr_native #(
    parameter                               FIFO_DPTH   =  32              ,
    parameter                               DATA_WDTH   =  32              ,
    parameter                               ADDR_WDTH   =  32              ,
    parameter                               DGBCNT_EN   =   1              ,
    parameter                               DGBCNT_WDTH =  16              
)(
    input                                   sys_clk                        ,//(i)
    input                                   sys_rst_n                      ,//(i)
    input                                   axi_clk                        ,//(i)
    input                                   axi_rst_n                      ,//(i)

    input                                   fifo_wr                        ,//(i)
    input             [DATA_WDTH-1:0]       fifo_din                       ,//(i)
    output                                  fifo_full                      ,//(o)

    input                                   wsoft_rst                      ,//(i)
    input                                   wstart_vld                     ,//(i)
    output  reg                             wstart_rdy                     ,//(o)
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

    input                                   dbg_cnt_clr                    ,//(i)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_awvalid                ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_bvalid                 ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_wvalid                 ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_wlast                  ,//(o)
    output            [DGBCNT_WDTH-1:0]     dbg_axi_wr_err_cnt             ,//(o)
    output                                  dbg_axi_wr_err                  //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg                                    awvalid                         ;
    reg                                    wvalid                          ;
    wire                                   ovfl_int                        ;
    reg               [8:0]                wr_cnt                          ;
    wire                                   cnt_reach_vld                   ;
    wire                                   fifo_rd                         ;
    wire             [DATA_WDTH-1:0]       fifo_dout                       ;
    wire                                   fifo_empty                      ;
    wire                                   wsoft_rst_wr_sync               ;
    wire                                   wsoft_rst_rd_sync               ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign cnt_reach_vld                    = wr_cnt == (wburst_len+1'b1) ;

// =================================================================================================
// RTL Body
// =================================================================================================
    cmip_bit_sync #(
        .DATA_WDTH    (1                 )
    )u0_cmip_bit_sync(   
        .i_dst_clk    (sys_clk           ),
        .i_din        (wsoft_rst         ),
        .o_dout       (wsoft_rst_wr_sync )
    );

    cmip_bit_sync #(
        .DATA_WDTH    (1                 )
    )u1_cmip_bit_sync(   
        .i_dst_clk    (axi_clk           ),
        .i_din        (wsoft_rst         ),
        .o_dout       (wsoft_rst_rd_sync )
    );

    //axi awvalid
    always@(posedge axi_clk or negedge axi_rst_n)
        if(~axi_rst_n) begin
            awvalid <= 1'b0;
        end else if(wsoft_rst_rd_sync)begin
            awvalid <= 1'b0;
        end else if(wstart_rdy && wstart_vld) begin
            awvalid <= 1'b1;
        end else if(m_axi_awready)begin
            awvalid <= 1'b0;
        end


    assign   m_axi_awaddr         =   waddr                               ;
    assign   m_axi_awburst        =   2'b01                               ;
    assign   m_axi_awcache        =   4'b011                              ;
    assign   m_axi_awid           =   4'b0                                ;
    assign   m_axi_awlen          =   wburst_len                          ;
    assign   m_axi_awlock         =   1'b0                                ;
    assign   m_axi_awprot         =   3'b0                                ;
    assign   m_axi_awqos          =   4'b0                                ;
    assign   m_axi_awvalid        =   awvalid                             ;
    assign   m_axi_awsize         = ( DATA_WDTH == 512 ) ? 3'b110 :
                                    ( DATA_WDTH == 256 ) ? 3'b101 :
                                    ( DATA_WDTH == 128 ) ? 3'b100 :
                                    ( DATA_WDTH ==  64 ) ? 3'b011 :
                                    ( DATA_WDTH ==  32 ) ? 3'b010 : 3'b001;
    assign   m_axi_awuser         =   1'b0                                ;


    //axi wvalid
    always@(posedge axi_clk or negedge axi_rst_n)
        if(~axi_rst_n) begin
            wvalid <= 1'b0;
        end else if(cnt_reach_vld || m_axi_wlast)begin
            wvalid <= 1'b0;
        end else if((~wstart_rdy)) begin
            wvalid <= 1'b1;
        end
       
    //axi wr_cnt
    always@(posedge axi_clk or negedge axi_rst_n)
        if(~axi_rst_n) begin
            wr_cnt <= 9'b0;
        end else if(m_axi_bvalid && m_axi_bready)begin
            wr_cnt <= 9'b0;
        end else if(cnt_reach_vld)begin
            wr_cnt <= wr_cnt;
        //end else if(wvalid && m_axi_wready) begin
        //end else if(fifo_rd) begin
        end else if(m_axi_wvalid && m_axi_wready) begin
            wr_cnt <= wr_cnt + 1'b1;
        end

    assign   m_axi_wvalid         =   wvalid  & (~fifo_empty || wsoft_rst_rd_sync);
    assign   m_axi_wstrb          =   {(DATA_WDTH/8){1'b1}}                       ;
    assign   m_axi_wdata          =   fifo_dout                                   ;
    assign   m_axi_wlast          =   m_axi_wvalid && m_axi_wready && (wr_cnt == wburst_len);
    assign   fifo_rd              =   wvalid && m_axi_wready && (~fifo_empty);

    //axi m_axi_bvalid
    always@(posedge axi_clk or negedge axi_rst_n)
        if(~axi_rst_n) begin
            wstart_rdy <= 1'b1;
        end else if(wstart_rdy && wstart_vld) begin
            wstart_rdy <= 1'b0;
        end else if(m_axi_bvalid && m_axi_bready)begin
            wstart_rdy <= 1'b1;
        end

    assign   m_axi_bready         =   1'b1                                ;
    //s_axi_bid   s_axi_bresp   s_axi_bvalid       // input no use




    //---------------------------------------------------------------------
    // cmip_async_fifo Inst.
    //---------------------------------------------------------------------     
    cmip_async_fifo #(
        .DPTH         (FIFO_DPTH      ),
        .DATA_WDTH    (DATA_WDTH      ),
        .FWFT         (1              )
        )
    u_cmip_async_fifo(
        .i_wr_clk     ( sys_clk       ),
        .i_rd_clk     ( axi_clk       ),
        .i_wr_rst_n   ( sys_rst_n & (~wsoft_rst_wr_sync) ),
        .i_rd_rst_n   ( axi_rst_n & (~wsoft_rst_rd_sync) ),
        .i_aful_th    ( 4             ),
        .i_amty_th    ( 0             ),
        .i_wr         ( fifo_wr       ),
        .i_din        ( fifo_din      ),
        .i_rd         ( fifo_rd       ),
        .o_dout       ( fifo_dout     ),
        .o_aful       ( fifo_full     ),
        .o_amty       (               ),
        .o_full       (               ),
//        .o_full       ( fifo_full     ),
        .o_empty      ( fifo_empty    ),
        .o_ovfl_int   ( ovfl_int      ),
        .o_unfl_int   (               ),
        .o_wr_cnt     (               ),
        .o_rd_cnt     (               )
    );

    //---------------------------------------------------------------------
    // Debug cnt Inst.
    //---------------------------------------------------------------------     
generate if(DGBCNT_EN==1)begin

    cmip_app_cnt #(
        .WDTH         (DGBCNT_WDTH)
    )u0_cnt(          
        .i_clk        (axi_clk    ),//(i) 
        .i_rst_n      (axi_rst_n  ),//(i) 
        .i_clr        (dbg_cnt_clr),//(i) 
        .i_vld        (m_axi_awvalid && m_axi_awready),//(i) 
        .o_cnt        (dbg_axi_awvalid               ) //(o) 
    );
    
    cmip_app_cnt #(
        .WDTH         (DGBCNT_WDTH)
    )u1_cnt(          
        .i_clk        (axi_clk    ),//(i) 
        .i_rst_n      (axi_rst_n  ),//(i) 
        .i_clr        (dbg_cnt_clr),//(i) 
        .i_vld        (m_axi_wvalid && m_axi_wready  ),//(i) 
        .o_cnt        (dbg_axi_wvalid                ) //(o) 
    );
    
    cmip_app_cnt #(
        .WDTH         (DGBCNT_WDTH)
    )u2_cnt(          
        .i_clk        (axi_clk    ),//(i) 
        .i_rst_n      (axi_rst_n  ),//(i) 
        .i_clr        (dbg_cnt_clr),//(i) 
        .i_vld        (m_axi_bvalid && m_axi_bready  ),//(i) 
        .o_cnt        (dbg_axi_bvalid                ) //(o) 
    );

    cmip_app_cnt #(
        .WDTH         (DGBCNT_WDTH)
    )u3_cnt(          
        .i_clk        (axi_clk    ),//(i) 
        .i_rst_n      (axi_rst_n  ),//(i) 
        .i_clr        (dbg_cnt_clr),//(i) 
        .i_vld        (m_axi_wvalid && m_axi_wready && m_axi_wlast ),//(i) 
        .o_cnt        (dbg_axi_wlast                 ) //(o) 
    );

    cmip_app_cnt #(
        .WDTH         (DGBCNT_WDTH)
    )u4_cnt(          
        .i_clk        (axi_clk    ),//(i) 
        .i_rst_n      (axi_rst_n  ),//(i) 
        .i_clr        (dbg_cnt_clr),//(i) 
        .i_vld        (dbg_axi_wr_err    ),//(i) 
        .o_cnt        (dbg_axi_wr_err_cnt) //(o) 
    );
/*
    always@(posedge axi_clk or negedge axi_rst_n)
        if(~axi_rst_n) begin
            dbg_axi_wr_err <= 1'b0;
        end else if(m_axi_awvalid && m_axi_awready) begin
            dbg_axi_wr_err <= 1'b0;
        end else if(m_axi_bvalid && m_axi_bready)begin
            dbg_axi_wr_err <= |m_axi_bresp;
        end
*/
    assign         dbg_axi_wr_err  =   m_axi_bvalid && m_axi_bready && (|m_axi_bresp);


    
end
endgenerate



endmodule





