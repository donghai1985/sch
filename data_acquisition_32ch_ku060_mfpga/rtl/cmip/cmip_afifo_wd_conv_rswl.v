// =================================================================================================
// Copyright(C) 2020  All rights reserved.                                                          
// =================================================================================================
//                                                                                                  
// =================================================================================================
// Module         : cmip_afifo_wd_conv_rswl                                                                              
// Function       : cmip_afifo_wd_conv_rswl (File is generate by python.)                                         
// Type           : RTL                                                                             
// -------------------------------------------------------------------------------------------------
// Update History :                                                                                 
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents                                                
// 0.1.0      2023/10/10   holt             Create new                                                      
//                                                                                                  
// =================================================================================================
module cmip_afifo_wd_conv_rswl #(
    parameter               DPTH           =       32                           , 
    parameter               WR_DATA_WD     =       512                          , 
    parameter               RD_DATA_WD     =       128                          , 
    parameter               FWFT           =       1                            , 
    parameter               ADDR_WD        =       $clog2(DPTH)                   
)(
//wr_clk//
    input                                          i_wr_clk                     ,
    input                                          i_wr_rst_n                   ,
    input                                          i_wr                         ,
    input                   [WR_DATA_WD -1:0]      i_din                        ,
    output                                         o_full                       ,
    output                  [ADDR_WD      :0]      o_wr_cnt                     ,
//rd_clk//
    input                                          i_rd_clk                     ,
    input                                          i_rd_rst_n                   ,
    input                                          i_rd                         ,
    output   reg            [RD_DATA_WD -1:0]      o_dout                       ,
    output                                         o_empty                      ,
    output   reg            [ADDR_WD    +1:0]      o_rd_cnt                      
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // ------------------------------------------------------------------------- 
    localparam               RATE           =       WR_DATA_WD/RD_DATA_WD       ;
    localparam               RATE_BITS      =       $clog2(RATE)                ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    integer                                         i                           ;
    wire                                            fifo_rd                     ;
    wire                                            fifo_empty                  ;
    wire                    [WR_DATA_WD -1:0]       fifo_dout                   ;
    wire                    [ADDR_WD      :0]       fifo_rd_cnt                 ;
    reg                     [RATE       -1:0]       rd_flag                     ;
    reg                     [RATE_BITS  -1:0]       rd_num                      ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign                   fifo_rd       =        ~fifo_empty && rd_flag == {{RATE{1'b0}},1'b1} && i_rd ;
    assign                   o_empty       =        ~(|rd_flag) || fifo_empty   ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge i_rd_clk or negedge i_rd_rst_n)
        if(~i_rd_rst_n)
            rd_flag <= {RATE{1'b1}};
        else if(~fifo_empty && rd_flag == {{RATE{1'b0}},1'b1} && i_rd)//fifo_rd
            rd_flag <= {RATE{1'b1}};
        // else if(~fifo_empty && rd_flag == {RATE{1'b0}})
        //     rd_flag <= {RATE{1'b1}};
        else if(i_rd)
            rd_flag <= rd_flag >> 1'b1 ;

    always@(*)begin
        o_dout = {RATE_BITS{1'b0}};
        for(i=0;i<RATE;i=i+1)begin
            if(rd_flag[i]==1'b1)
                o_dout = fifo_dout[(RATE-i)*RD_DATA_WD-1-:RD_DATA_WD];
        end
    end

    always@(*)begin
        rd_num = {RATE_BITS{1'b0}};
        for(i=0;i<RATE;i=i+1)begin
            if(rd_flag[i]==1'b1)
                rd_num = rd_num + 1'b1;
        end
    end

    always@(*)begin
        if(fifo_empty || fifo_rd_cnt[ADDR_WD-1:0]=={ADDR_WD{1'b0}})
            o_rd_cnt = rd_num;
        else 
            o_rd_cnt =  {fifo_rd_cnt[ADDR_WD-1:0],{RATE_BITS{1'b0}}} - {1'b1,{RATE_BITS{1'b0}}} + rd_num;
    end
    // -------------------------------------------------------------------------
    // cmip_async_mem_fifo Module Inst.
    // -------------------------------------------------------------------------
    cmip_async_fifo #(
        .DPTH                   (DPTH            ),
        .DATA_WDTH              (WR_DATA_WD      ),
        .ADDR_WDTH              (ADDR_WD         ),
        .FWFT                   (FWFT            )
    )u_cmip_async_fifo(
        .i_wr_clk               ( i_wr_clk       ),
        .i_rd_clk               ( i_rd_clk       ),
        .i_wr_rst_n             ( i_wr_rst_n     ),
        .i_rd_rst_n             ( i_rd_rst_n     ),
        .i_aful_th              ( 4              ),
        .i_amty_th              ( 4              ),
        .i_wr                   ( i_wr           ),
        .i_din                  ( i_din          ),
        .i_rd                   ( fifo_rd        ),
        .o_dout                 ( fifo_dout      ),
        .o_aful                 ( o_full         ),
        .o_amty                 (                ),
        .o_full                 (                ),
        .o_empty                ( fifo_empty     ),
        .o_ovfl_int             (                ),
        .o_unfl_int             (                ),
        .o_wr_cnt               ( o_wr_cnt       ),
        .o_rd_cnt               ( fifo_rd_cnt    )
    );




















endmodule










