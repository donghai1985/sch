// =================================================================================================
// Copyright 2020 - 2030 (c) Semi, Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : myip_cdma_cfg.v
// Module         : myip_cdma_cfg
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2020/01/10   NTEW)wang.qh     Create new
// =================================================================================================
// End Revision
// =================================================================================================

module myip_cdma_cfg#(
    parameter                               LB_BASE_ADDR   =  32'h40000   ,
    parameter                               LB_DATA_WDTH   =  32          ,
    parameter                               LB_ADDR_WDTH   =  32          ,
    parameter                               DGBCNT_WDTH    =  32           
)(

    input                                   lb_rst_n                      , //(i)
    input                                   lb_clk                        , //(i)
    input                                   lb_wreq                       , //(i)
    input             [LB_ADDR_WDTH-1:0]    lb_waddr                      , //(i)
    input             [LB_DATA_WDTH-1:0]    lb_wdata                      , //(i)
    output   reg                            lb_wack                       , //(o)
    input                                   lb_rreq                       , //(i)
    input             [LB_ADDR_WDTH-1:0]    lb_raddr                      , //(i)
    output   reg      [LB_DATA_WDTH-1:0]    lb_rdata                      , //(o)
    output   reg                            lb_rack                       , //(o)
	
    output   reg                            dbg_cnt_clr                   ,//(i)
    input             [DGBCNT_WDTH-1:0]     dbg_axi_awvalid               ,//(o)
    input             [DGBCNT_WDTH-1:0]     dbg_axi_bvalid                ,//(o)
    input             [DGBCNT_WDTH-1:0]     dbg_axi_wvalid                ,//(o)
    input             [DGBCNT_WDTH-1:0]     dbg_axi_wlast                 ,//(o)
    input             [DGBCNT_WDTH-1:0]     dbg_axi_wr_err_cnt            ,//(o)
    input                                   dbg_axi_wr_err                ,//(o)
    input             [DGBCNT_WDTH-1:0]     dbg_axi_arvalid               ,//(o)
    input             [DGBCNT_WDTH-1:0]     dbg_axi_rvalid                ,//(o)
    input             [DGBCNT_WDTH-1:0]     dbg_axi_rlast                 ,//(o)
    input             [DGBCNT_WDTH-1:0]     dbg_axi_rd_err_cnt            ,//(o)
    input                                   dbg_axi_rd_err                ,//(o)    	
	
    
    input             [LB_DATA_WDTH-1:0]    i_reg0                        , // (i) 16'h0020     
    input             [LB_DATA_WDTH-1:0]    i_reg1                        , // (i) 16'h0024     
    input             [LB_DATA_WDTH-1:0]    i_reg2                        , // (i) 16'h0028     
    input             [LB_DATA_WDTH-1:0]    i_reg3                        , // (i) 16'h002C     
    input             [LB_DATA_WDTH-1:0]    i_reg4                        , // (i) 16'h0030     
    input             [LB_DATA_WDTH-1:0]    i_reg5                        , // (i) 16'h0034     
    input             [LB_DATA_WDTH-1:0]    i_reg6                        , // (i) 16'h0038     
    input             [LB_DATA_WDTH-1:0]    i_reg7                        , // (i) 16'h003C     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg0                        , // (o) 16'h0040     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg1                        , // (o) 16'h0044     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg2                        , // (o) 16'h0048     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg3                        , // (o) 16'h004C     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg4                        , // (o) 16'h0050     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg5                        , // (o) 16'h0054     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg6                        , // (o) 16'h0058     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg7                        , // (o) 16'h005C     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg8                        , // (o) 16'h0060     
    output   reg      [LB_DATA_WDTH-1:0]    o_reg9                        , // (o) 16'h0064     
    output   reg      [LB_DATA_WDTH-1:0]    o_rega                        , // (o) 16'h0068     
    output   reg      [LB_DATA_WDTH-1:0]    o_regb                          // (o) 16'h006C     


);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam       TEST_REG        =      32'h2023_0310                  ;

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire     [LB_ADDR_WDTH-1:0]          base_addr                        ;
    assign   base_addr         =         LB_BASE_ADDR                     ;
    assign   lb_wreq_s    = (lb_waddr[LB_ADDR_WDTH-1:8] == base_addr[LB_ADDR_WDTH-1:8]) ? lb_wreq : 1'b0;
    assign   lb_rreq_s    = (lb_raddr[LB_ADDR_WDTH-1:8] == base_addr[LB_ADDR_WDTH-1:8]) ? lb_rreq : 1'b0;


    // =================================================================================================
    // RTL Body
    // =================================================================================================

    //---------------------------------------------------------------------
    // localbus write or read.
    //---------------------------------------------------------------------    
    
    // processor write interface
    always @(posedge lb_clk or negedge lb_rst_n)
        if(lb_rst_n==1'b0)
            lb_wack <= 1'b0;
        else
            lb_wack <= lb_wreq_s;   


    always @(posedge lb_clk or negedge lb_rst_n)
        if(lb_rst_n==1'b0)begin
            o_reg0          <=       32'h3000_0000         ;
            o_reg1          <=       {LB_DATA_WDTH{1'b0}}  ;
            o_reg2          <=       {LB_DATA_WDTH{1'b0}}  ;
            o_reg3          <=        32'd255              ;//burst_len
            o_reg4          <=       {LB_DATA_WDTH{1'b0}}  ;
            o_reg5          <=       {LB_DATA_WDTH{1'b0}}  ;
            o_reg6          <=       {LB_DATA_WDTH{1'b0}}  ;
            o_reg7          <=       {LB_DATA_WDTH{1'b0}}  ;
            o_reg8          <=       {LB_DATA_WDTH{1'b0}}  ;
            o_reg9          <=       {LB_DATA_WDTH{1'b0}}  ;
            o_rega          <=       {LB_DATA_WDTH{1'b0}}  ;
            o_regb          <=       {LB_DATA_WDTH{1'b0}}  ;
			dbg_cnt_clr     <=        1'b0                 ; 
        end else if(lb_wreq_s)begin    
            case(lb_waddr[7:0])
                8'h40  :  o_reg0          <=       lb_wdata              ;  
                8'h44  :  o_reg1          <=       lb_wdata              ;  
                8'h48  :  o_reg2          <=       lb_wdata              ;  
                8'h4C  :  o_reg3          <=       lb_wdata              ;  
                8'h50  :  o_reg4          <=       lb_wdata              ;  
                8'h54  :  o_reg5          <=       lb_wdata              ;  
                8'h58  :  o_reg6          <=       lb_wdata              ;  
                8'h5C  :  o_reg7          <=       lb_wdata              ;  
                8'h60  :  o_reg8          <=       lb_wdata              ;  
                8'h64  :  o_reg9          <=       lb_wdata              ;  
                8'h68  :  o_rega          <=       lb_wdata              ;  
                8'h6C  :  o_regb          <=       lb_wdata              ;  
				
				8'h80  :  dbg_cnt_clr     <=       lb_wdata[0]           ;  
				
            endcase
        end
    
    
    // processor read interface
    always @(posedge lb_clk or negedge lb_rst_n)
        if (lb_rst_n == 0) 
            lb_rack <= 'd0;
        else
            lb_rack <= lb_rreq_s;

    
    always @(posedge lb_clk or negedge lb_rst_n)
        if(lb_rst_n==1'b0)begin
            lb_rdata <= {LB_DATA_WDTH{1'b0}};
        end else if(lb_rreq_s) begin
            case(lb_waddr[7:0])
                8'h00  :  lb_rdata       <=       TEST_REG               ; 			

                8'h20  :  lb_rdata       <=       i_reg0                 ;
                8'h24  :  lb_rdata       <=       i_reg1                 ;
                8'h28  :  lb_rdata       <=       i_reg2                 ;
                8'h2C  :  lb_rdata       <=       i_reg3                 ;
                8'h30  :  lb_rdata       <=       i_reg4                 ;
                8'h34  :  lb_rdata       <=       i_reg5                 ;
                8'h38  :  lb_rdata       <=       i_reg6                 ;
                8'h3C  :  lb_rdata       <=       i_reg7                 ;
                
                8'h40  :  lb_rdata       <=       o_reg0                 ;
                8'h44  :  lb_rdata       <=       o_reg1                 ;
                8'h48  :  lb_rdata       <=       o_reg2                 ;
                8'h4C  :  lb_rdata       <=       o_reg3                 ;
                8'h50  :  lb_rdata       <=       o_reg4                 ;
                8'h54  :  lb_rdata       <=       o_reg5                 ;
                8'h58  :  lb_rdata       <=       o_reg6                 ;
                8'h5C  :  lb_rdata       <=       o_reg7                 ;
                8'h60  :  lb_rdata       <=       o_reg8                 ;
                8'h64  :  lb_rdata       <=       o_reg9                 ;
                8'h68  :  lb_rdata       <=       o_rega                 ;
                8'h6C  :  lb_rdata       <=       o_regb                 ;

                8'h80  :  lb_rdata       <=       dbg_cnt_clr            ;
                8'h84  :  lb_rdata       <=       dbg_axi_awvalid        ;
                8'h88  :  lb_rdata       <=       dbg_axi_bvalid         ;
                8'h8C  :  lb_rdata       <=       dbg_axi_wvalid         ;
                8'h90  :  lb_rdata       <=       dbg_axi_wlast          ;
                8'h94  :  lb_rdata       <=       dbg_axi_wr_err_cnt     ;
                8'h98  :  lb_rdata       <=       dbg_axi_wr_err         ;
                8'h9C  :  lb_rdata       <=       dbg_axi_arvalid        ;
                8'hA0  :  lb_rdata       <=       dbg_axi_rvalid         ;
                8'hA4  :  lb_rdata       <=       dbg_axi_rlast          ;
                8'hA8  :  lb_rdata       <=       dbg_axi_rd_err_cnt     ;
                8'hAC  :  lb_rdata       <=       dbg_axi_rd_err         ;


                default:  lb_rdata       <=       {LB_DATA_WDTH{1'b0}}  ;
            endcase
        end
    
    //---------------------------------------------------------------------
    // relaod coefficient axis.
    //---------------------------------------------------------------------    









endmodule





