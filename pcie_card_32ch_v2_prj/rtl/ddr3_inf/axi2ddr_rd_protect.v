// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : axi_rd_native.v
// Module         : axi_rd_native
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


module axi2ddr_rd_protect #(
    parameter                               AXI_DATA_WD     =  128         ,
    parameter                               AXI_ADDR_WD     =  64          ,
    parameter                               DGBCNT_EN       =   1          ,
    parameter                               DGBCNT_WD       =  32          
)(
    input                                   axi_clk                        ,//(i)
    input                                   axi_rst_n                      ,//(i)
    input                                   cfg_rst                        ,//(i)

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

    output            [AXI_DATA_WD  -1:0]   s_axi_rdata                    ,//(o)
    output                                  s_axi_rvalid                   ,//(o)
    input                                   s_axi_rready                   ,//(i)
    output                                  s_axi_rlast                    ,//(o)
    output            [ 1:0]                s_axi_rresp                    ,//(o)
    output            [ 3:0]                s_axi_rid                      ,//(o)

    output            [AXI_ADDR_WD  -1:0]   m_axi_araddr                   ,//(o)
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

    input             [AXI_DATA_WD  -1:0]   m_axi_rdata                    ,//(i)
    input                                   m_axi_rvalid                   ,//(i)
    output                                  m_axi_rready                   ,//(o)
    input                                   m_axi_rlast                    ,//(i)
    input             [ 1:0]                m_axi_rresp                    ,//(i)
    input             [ 3:0]                m_axi_rid                      ,//(i)
    output            [DGBCNT_WD  -1:0]     err_rd_cnt                      //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg                                     access_cond                     ;
    wire                                    access_en_pos                   ;
    reg                                     access_en                       ;
    reg                                     err_access_en                   ;

    wire              [AXI_DATA_WD  -1:0]   e_axi_rdata                     ;//(o)
    wire                                    e_axi_rvalid                    ;//(o)
    wire                                    e_axi_rlast                     ;//(o)
    wire              [ 1:0]                e_axi_rresp                     ;//(o)
    wire              [ 3:0]                e_axi_rid                       ;//(o)
    reg               [ 7:0]                e_axi_arlen                     ;
    reg               [ 7:0]                e_rd_cnt                        ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            access_en_pos   =     s_axi_arvalid && s_axi_arready && access_cond;

    assign            m_axi_araddr    =   ( access_en || access_en_pos ) ? s_axi_araddr   : 'd0 ;//(o)
    assign            m_axi_arburst   =   ( access_en || access_en_pos ) ? s_axi_arburst  : 'd0 ;//(o)
    assign            m_axi_arcache   =   ( access_en || access_en_pos ) ? s_axi_arcache  : 'd0 ;//(o)
    assign            m_axi_arid      =   ( access_en || access_en_pos ) ? s_axi_arid     : 'd0 ;//(o)
    assign            m_axi_arlen     =   ( access_en || access_en_pos ) ? s_axi_arlen    : 'd0 ;//(o)
    assign            m_axi_arlock    =   ( access_en || access_en_pos ) ? s_axi_arlock   : 'd0 ;//(o)
    assign            m_axi_arprot    =   ( access_en || access_en_pos ) ? s_axi_arprot   : 'd0 ;//(o)
    assign            m_axi_arqos     =   ( access_en || access_en_pos ) ? s_axi_arqos    : 'd0 ;//(o)
    assign            m_axi_arvalid   =   ( access_en || access_en_pos ) ? s_axi_arvalid  : 'd0 ;//(o)
    assign            s_axi_arready   =   ( access_en || access_en_pos ) ? m_axi_arready  : 'd0 ;//(i)
    assign            m_axi_arsize    =   ( access_en || access_en_pos ) ? s_axi_arsize   : 'd0 ;//(o)
    assign            m_axi_aruser    =   ( access_en || access_en_pos ) ? s_axi_aruser   : 'd0 ;//(o)
    assign            s_axi_rdata     =   ( access_en || access_en_pos ) ? m_axi_rdata    : e_axi_rdata  ;//(i)
    assign            s_axi_rvalid    =   ( access_en || access_en_pos ) ? m_axi_rvalid   : e_axi_rvalid ;//(i)
    assign            m_axi_rready    =   ( access_en || access_en_pos ) ? s_axi_rready   : 'd0 ;//(o)
    assign            s_axi_rlast     =   ( access_en || access_en_pos ) ? m_axi_rlast    : e_axi_rlast ;//(i)
    assign            s_axi_rresp     =   ( access_en || access_en_pos ) ? m_axi_rresp    : e_axi_rresp ;//(i)
    assign            s_axi_rid       =   ( access_en || access_en_pos ) ? m_axi_rid      : e_axi_rid   ;//(i)

    assign            e_axi_rdata     =   {8{16'hDEAD}}               ;
    assign            e_axi_rvalid    =   err_access_en               ;
    assign            e_axi_rlast     =   (e_rd_cnt == e_axi_arlen - 1'b1) || (e_axi_arlen == 3'd0);
    assign            e_axi_rresp     =   2'b0;
    assign            e_axi_rid       =   4'b0;




// =================================================================================================
// RTL Body
// ===============================================================================================
    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)
            access_en <= 1'b0;
        else if(cfg_rst)
            access_en <= 1'b0;
        else if(access_en_pos)
            access_en <= 1'b1;
        else if(s_axi_rlast)
            access_en <= 1'b0;
    end

    always@(*)begin
        if(s_axi_arlen==8'd7 || s_axi_arlen==8'd15)
            access_cond = 1'b1;
        else if(s_axi_arlen==8'd31 || s_axi_arlen==8'd63)
            access_cond = 1'b1;
        else if(s_axi_arlen==8'd128 || s_axi_arlen==8'd255)
            access_cond = 1'b1;
        else if(s_axi_arlen==8'd3)
            access_cond = 1'b1;
        else 
            access_cond = 1'b0;
    end


//--------err acess process------------------------------------------------------------------//
    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)
            err_access_en <= 1'b0;
        else if(cfg_rst)
            err_access_en <= 1'b0;
        else if(s_axi_arvalid && s_axi_arready && (~access_cond))
            err_access_en <= 1'b1;
        else if(s_axi_arvalid && s_axi_arready && s_axi_rlast)
            err_access_en <= 1'b0;
    end

    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)
            e_axi_arlen <= 8'b0;
        else if(cfg_rst)
            e_axi_arlen <= 8'b0;
        else if(s_axi_arvalid && s_axi_arready && (~access_cond))
            e_axi_arlen <= s_axi_arlen;
    end

    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)
            e_rd_cnt <= 8'b0;
        else if(cfg_rst)
            e_rd_cnt <= 8'b0;
        else if(s_axi_arvalid && s_axi_arready && err_access_en)
            e_rd_cnt <= e_rd_cnt + 1'b1;
        else if(s_axi_arvalid && s_axi_arready && s_axi_rlast)
            e_rd_cnt <= 8'b0;
    end



    cmip_app_cnt #(
        .WDTH                   (32                )
    )u_cnt(          
        .i_clk                  (axi_clk            ),//(i) 
        .i_rst_n                (axi_rst_n          ),//(i) 
        .i_clr                  (cfg_rst            ),//(i) 
        .i_vld                  (s_axi_arvalid && s_axi_arready && (~access_cond)),//(i) 
        .o_cnt                  (err_rd_cnt         ) //(o) 
    );









endmodule





