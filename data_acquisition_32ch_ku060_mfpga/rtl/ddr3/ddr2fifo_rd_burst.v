// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : ddr2fifo_rd_burst.v
// Module         : ddr2fifo_rd_burst
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


module ddr2fifo_rd_burst #(
    parameter                               FIFO_DPTH       =  1024        ,
    parameter                               FIFO_ADDR_WD    =  $clog2(FIFO_DPTH),
    parameter                               RD_DATA_WD      =  128         ,
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               BURST_LEN       =  16          ,
    parameter                               BASE_ADDR       =  32'h0000    ,
    parameter                               MAX_BLK_SIZE    =  32'h1000    
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
    input                                   rd_clk                         ,//(i)
    input                                   rd_rst_n                       ,//(i)
    input                                   cfg_rst                        ,//(i)

    input                                   dat_fifo_rd                    ,//(i)
    output            [RD_DATA_WD-1:0]      dat_fifo_dout                  ,//(o)
    output                                  dat_fifo_empty                 ,//(o)
    output            [FIFO_ADDR_WD-1:0]    dat_rd_cnt                     ,//(o)

    input             [DDR_ADDR_WD  -1:0]   rd_avail_addr                  ,//(i) 
    output                                  rd_burst_req                   ,//(o)      
    output            [9:0]                 rd_burst_len                   ,//(o)  
    output            [DDR_ADDR_WD  -1:0]   rd_burst_addr                  ,//(o)    
    input                                   rd_burst_data_valid            ,//(i) 
    input             [DDR_DATA_WD  -1:0]   rd_burst_data                  ,//(o)
    input                                   rd_burst_finish                ,//(i)
    output   reg      [DDR_ADDR_WD-1:0]     rd_blk_cnt                     ,//(o)
    output   reg      [DDR_ADDR_WD-1:0]     rd_glb_blk_cnt                  //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam                              RATE              =  DDR_DATA_WD/RD_DATA_WD;
    localparam                              RATE_BITS         =  $clog2(RATE)      ;
    localparam                              MAX_BLK_SIZE_M1   =  MAX_BLK_SIZE - 1  ; 

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    dat_fifo_wr                     ;
    wire              [DDR_DATA_WD-1:0]     dat_fifo_din                    ;
    wire                                    dat_fifo_full                   ;
    reg                                     pkt_rep_req_lock                ;
    reg                                     ddr_cfg_rst_d1                  ;   
    reg                                     ddr_cfg_rst_d2                  ;
    reg                                     rd_cfg_rst_d1                   ;   
    reg                                     rd_cfg_rst_d2                   ;     
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            dat_fifo_wr   =      rd_burst_data_valid              ;//ddr_clk
    assign            dat_fifo_din  =      byte_adj(rd_burst_data)          ;//ddr_clk
    //assign            dat_fifo_din  =      rd_burst_data                    ;//ddr_clk


    assign            rd_burst_req     =  ~dat_fifo_full && (rd_avail_addr >= BURST_LEN);//ddr_clk //notice
    assign            rd_burst_len     =   BURST_LEN                        ;//ddr_clk
    //assign            rd_burst_addr    =   BASE_ADDR + {rd_blk_cnt,3'd0}    ;//ddr_clk
    assign            rd_burst_addr   =    BASE_ADDR + {(rd_glb_blk_cnt & MAX_BLK_SIZE_M1),3'd0}    ;

// =================================================================================================
// RTL Body
// ================================================================================================
    always@(posedge ddr_clk)begin
        ddr_cfg_rst_d1 <= cfg_rst   ;
        ddr_cfg_rst_d2 <= ddr_cfg_rst_d1;
    end

    always@(posedge rd_clk)begin
        rd_cfg_rst_d1 <= cfg_rst   ;
        rd_cfg_rst_d2 <= rd_cfg_rst_d1;
    end

    //notice:1 block == 512bits
    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            rd_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(ddr_cfg_rst_d2)
            rd_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(rd_burst_finish && (rd_blk_cnt >= MAX_BLK_SIZE - BURST_LEN))
            rd_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(rd_burst_finish)
            rd_blk_cnt <= rd_blk_cnt + BURST_LEN;
    end



    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            rd_glb_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(ddr_cfg_rst_d2)
            rd_glb_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(rd_burst_finish)
            rd_glb_blk_cnt <= rd_glb_blk_cnt + BURST_LEN;
    end
    

    afifo_w512r128 u_afifo_w512r128(
        .rst          (~ddr_rst_n || ddr_cfg_rst_d2 ),
        .wr_clk       (ddr_clk                      ),
        .rd_clk       (rd_clk                       ),
        .din          (dat_fifo_din                 ),
        .wr_en        (dat_fifo_wr                  ),
        .rd_en        (dat_fifo_rd                  ),
        .dout         (dat_fifo_dout                ),
        .full         (dat_fifo_full                ),
        .empty        (dat_fifo_empty               ),
        .wr_rst_busy  (                             ),
        .rd_rst_busy  (                             ),
        .rd_data_count(dat_rd_cnt                   )
    );


/*
    cmip_afifo_wd_conv_rswl #(
        .DPTH         (FIFO_DPTH                  ),
        .WR_DATA_WD   (DDR_DATA_WD                ),
        .RD_DATA_WD   (RD_DATA_WD                 ),
        .FWFT         (1                          )
    )u_rd_dat_fifo(          
        .i_rd_clk     (rd_clk                     ),
        .i_wr_clk     (ddr_clk                    ),
        .i_rd_rst_n   (rd_rst_n   && (~rd_cfg_rst_d2)   ),
        .i_wr_rst_n   (ddr_rst_n  && (~ddr_cfg_rst_d2)   ),
        .i_wr         (dat_fifo_wr                ),
        .i_din        (dat_fifo_din               ),
        .i_rd         (dat_fifo_rd                ),
        .o_dout       (dat_fifo_dout              ),
        .o_full       (dat_fifo_full              ),
        .o_empty      (dat_fifo_empty             ),
        .o_wr_cnt     (                           ),
        .o_rd_cnt     (dat_rd_cnt                 )
    );
*/


    function automatic [DDR_DATA_WD -1:0] byte_adj(
        input          [DDR_DATA_WD -1:0]     a   
    );begin:abc
        integer i;
        for(i=1;i<=RATE;i=i+1)begin
            byte_adj[i*RD_DATA_WD -1 -:RD_DATA_WD] = a[(RATE + 1 - i)*RD_DATA_WD -1 -: RD_DATA_WD];
        end
    end
    endfunction








endmodule





