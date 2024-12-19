// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : axi_rd_native.v
// Module         : axi_rd_native
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

module axi_rd_native #(
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

    input                                   fifo_rd                        ,//(i)
    output            [DATA_WDTH-1:0]       fifo_dout                      ,//(i)
    output                                  fifo_empty                     ,//(o)

    input                                   rsoft_rst                      ,//(i)
    input                                   rstart_vld                     ,//(i)
    output  reg                             rstart_rdy                     ,//(o)
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
    reg                                    arvalid                         ;
    wire                                   ovfl_int                        ;
    wire                                   fifo_wr                         ;
    wire             [DATA_WDTH-1:0]       fifo_din                        ;
    wire                                   fifo_full                       ;
    wire                                   rsoft_rst_wr_sync               ;
    wire                                   rsoft_rst_rd_sync               ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
//    assign          fifo_wr          =     vga_en_d2                         ;




// =================================================================================================
// RTL Body
// =================================================================================================
    cmip_bit_sync #(
        .DATA_WDTH    (1                 )
    )u0_cmip_bit_sync(   
        .i_dst_clk    (sys_clk           ),
        .i_din        (rsoft_rst         ),
        .o_dout       (rsoft_rst_rd_sync )
    );

    cmip_bit_sync #(
        .DATA_WDTH    (1                 )
    )u1_cmip_bit_sync(   
        .i_dst_clk    (axi_clk           ),
        .i_din        (rsoft_rst         ),
        .o_dout       (rsoft_rst_wr_sync )
    );


    //axi arvalid
    always@(posedge axi_clk or negedge axi_rst_n)
        if(~axi_rst_n) begin
            arvalid <= 1'b0;
        end else if(rsoft_rst_wr_sync) begin
            arvalid <= 1'b0;
        end else if(rstart_rdy && rstart_vld) begin
            arvalid <= 1'b1;
        end else if(m_axi_arready)begin
            arvalid <= 1'b0;
        end


    assign   m_axi_araddr         =   raddr                               ;
    assign   m_axi_arburst        =   2'b01                               ;
    assign   m_axi_arcache        =   4'b011                              ;
    assign   m_axi_arid           =   4'b0                                ;
    assign   m_axi_arlen          =   rburst_len                          ;
    assign   m_axi_arlock         =   1'b0                                ;
    assign   m_axi_arprot         =   3'b0                                ;
    assign   m_axi_arqos          =   4'b0                                ;
    assign   m_axi_arvalid        =   arvalid                             ;
    assign   m_axi_arsize         = ( DATA_WDTH == 512 ) ? 3'b110 :
                                    ( DATA_WDTH == 256 ) ? 3'b101 :
                                    ( DATA_WDTH == 128 ) ? 3'b100 :
                                    ( DATA_WDTH ==  64 ) ? 3'b011 :
                                    ( DATA_WDTH ==  32 ) ? 3'b010 : 3'b001;
    assign   m_axi_aruser         =   1'b0                                ;


    assign   m_axi_rready         =   ~fifo_full  ||  rsoft_rst_wr_sync   ;
    assign   fifo_wr              =  m_axi_rready && (~fifo_full)  && m_axi_rvalid        ;
    assign   fifo_din             =  m_axi_rdata                          ;

    //axi m_axi_bvalid
    always@(posedge axi_clk or negedge axi_rst_n)
        if(~axi_rst_n) begin
            rstart_rdy <= 1'b1;
        end else if(rsoft_rst_wr_sync) begin
            rstart_rdy <= 1'b1;
        end else if(rstart_rdy && rstart_vld) begin
            rstart_rdy <= 1'b0;
        end else if(m_axi_rready && m_axi_rlast && m_axi_rvalid)begin
            rstart_rdy <= 1'b1;
        end

    //---------------------------------------------------------------------
    // cmip_async_fifo Inst.
    //---------------------------------------------------------------------     
    cmip_async_fifo #(
        .DPTH         (FIFO_DPTH      ),
        .DATA_WDTH    (DATA_WDTH      ),
        .FWFT         (1              )
        )
    u_cmip_async_fifo(
        .i_wr_clk     ( axi_clk       ),
        .i_rd_clk     ( sys_clk       ),
        .i_wr_rst_n   ( axi_rst_n & (~rsoft_rst_wr_sync) ),
        .i_rd_rst_n   ( sys_rst_n & (~rsoft_rst_rd_sync) ),
        .i_aful_th    ( 4             ),
        .i_amty_th    ( 0             ),
        .i_wr         ( fifo_wr       ),
        .i_din        ( fifo_din      ),
        .i_rd         ( fifo_rd       ),
        .o_dout       ( fifo_dout     ),
        .o_aful       ( fifo_full     ),
        .o_amty       (               ),
        .o_full       (               ),
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
        .i_vld        (m_axi_arvalid && m_axi_arready),//(i) 
        .o_cnt        (dbg_axi_arvalid               ) //(o) 
    );
    
    cmip_app_cnt #(
        .WDTH         (DGBCNT_WDTH)
    )u1_cnt(          
        .i_clk        (axi_clk    ),//(i) 
        .i_rst_n      (axi_rst_n  ),//(i) 
        .i_clr        (dbg_cnt_clr),//(i) 
        .i_vld        (m_axi_rvalid && m_axi_rready  ),//(i) 
        .o_cnt        (dbg_axi_rvalid                ) //(o) 
    );

    cmip_app_cnt #(
        .WDTH         (DGBCNT_WDTH)
    )u3_cnt(          
        .i_clk        (axi_clk    ),//(i) 
        .i_rst_n      (axi_rst_n  ),//(i) 
        .i_clr        (dbg_cnt_clr),//(i) 
        .i_vld        (m_axi_rvalid && m_axi_rready && m_axi_rlast ),//(i) 
        .o_cnt        (dbg_axi_rlast                 ) //(o) 
    );

    cmip_app_cnt #(
        .WDTH         (DGBCNT_WDTH)
    )u4_cnt(          
        .i_clk        (axi_clk    ),//(i) 
        .i_rst_n      (axi_rst_n  ),//(i) 
        .i_clr        (dbg_cnt_clr),//(i) 
        .i_vld        (dbg_axi_rd_err     ),//(i) 
        .o_cnt        (dbg_axi_rd_err_cnt ) //(o) 
    );

    assign             dbg_axi_rd_err   =   m_axi_rvalid && m_axi_rready && (|m_axi_rresp);
    



end
endgenerate




endmodule





