// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : fifo2ddr_wr_burst.v
// Module         : fifo2ddr_wr_burst
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


module fifo2ddr_wr_burst_c1 #(
    parameter                               FIFO_DEPTH      =  2048         ,
    parameter                               FIFO_ADDR_WD    =  $clog2(FIFO_DEPTH),                 
    parameter                               WR_DATA_WD      =  128         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               BURST_LEN       =  16          ,
    parameter                               BASE_ADDR       =  32'h0000    ,
    parameter                               MAX_BLK_SIZE    =  32'h1000    
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
    input                                   wr_clk                         ,//(i)
    input                                   wr_rst_n                       ,//(i)
    input                                   cfg_rst                        ,//(i)

    input                                   fifo_wr                        ,//(i)
    input             [WR_DATA_WD   -1:0]   fifo_din                       ,//(i)
    output                                  fifo_full                      ,//(o)
    output            [31:0]                fifo_full_cnt                  ,//(o)

    output                                  wr_burst_req                   ,//(o)      
    output            [9:0]                 wr_burst_len                   ,//(o)  
    output            [DDR_ADDR_WD  -1:0]   wr_burst_addr                  ,//(o)    
    input                                   wr_burst_data_req              ,//(i) 
    output            [DDR_DATA_WD  -1:0]   wr_burst_data                  ,//(o)
    input                                   wr_burst_finish                ,//(i)
    output    reg     [DDR_ADDR_WD-1:0]     blk_cnt                        ,//(i)
    output    reg                           wr_8m_irq_en                   ,//(o)
    input                                   wr_8m_irq_clr                   //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam                              RATE              =  DDR_DATA_WD/WR_DATA_WD;
    localparam                              RATE_BITS         =  $clog2(RATE)      ;
    localparam                              IRQ_SIZE          =  32'd131072;//32'd131072;//8MB  128//SIM
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire              [DDR_DATA_WD-1:0]     fifo_dout                       ;
    wire                                    fifo_empty                      ;
    wire                                    fifo_rd                         ;
    wire              [FIFO_ADDR_WD :0]     fifo_rd_cnt                     ;
    //reg               [DDR_ADDR_WD-1:0]     blk_cnt                         ;
    reg               [DDR_ADDR_WD-1:0]     blk_irq_cnt                     ;
    reg                                     wr_burst_finish_d1              ;
    wire                                    irq_trig                        ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    //assign            wr_burst_req    =   ~fifo_empty && ((fifo_rd_cnt[FIFO_ADDR_WD-1:0] >= BURST_LEN) || (fifo_rd_cnt[FIFO_ADDR_WD:0] == {1'b1,{FIFO_ADDR_WD{1'b0}}}));
    assign            wr_burst_req    =   ~fifo_empty && ((fifo_rd_cnt[FIFO_ADDR_WD-1:0] >= BURST_LEN) );
    assign            wr_burst_len    =    BURST_LEN                        ;
    assign            wr_burst_addr   =    BASE_ADDR + {blk_cnt,3'd0}       ;
    assign            fifo_rd         =    wr_burst_data_req                ;
    assign            wr_burst_data   =    byte_adj(fifo_dout)              ;
    assign            irq_trig        =    wr_burst_finish_d1 && (blk_irq_cnt == IRQ_SIZE);//8MB
// =================================================================================================
// RTL Body
// =================================================================================================
    //notice:1 block == 512bits
    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(cfg_rst)
            blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(wr_burst_finish && (blk_cnt >= MAX_BLK_SIZE - BURST_LEN))
            blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(wr_burst_finish)
            blk_cnt <= blk_cnt + BURST_LEN;
    end

    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            blk_irq_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(cfg_rst)
            blk_irq_cnt <= {DDR_ADDR_WD{1'b0}};
        else if((blk_irq_cnt == IRQ_SIZE) && wr_burst_finish)
            blk_irq_cnt <= BURST_LEN;
        else if(wr_burst_finish)
            blk_irq_cnt <= blk_irq_cnt + BURST_LEN;
    end
    
    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            wr_burst_finish_d1 <= 1'b0;
        else
            wr_burst_finish_d1 <= wr_burst_finish;
    end
    
    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            wr_8m_irq_en <= 1'b0;
        else if(irq_trig)
            wr_8m_irq_en <= 1'b1;
        else if(wr_8m_irq_clr)
            wr_8m_irq_en <= 1'b0;
    end    
    
/*
    wr_dat_fifo u_wr_dat_fifo (
        .wr_clk       (wr_clk                 ),
        .wr_rst       (~wr_rst_n || cfg_rst   ),
        .rd_clk       (ddr_clk                ),
        .rd_rst       (~ddr_rst_n || cfg_rst  ),
        .din          (fifo_din               ),
        .wr_en        (fifo_wr && (~fifo_full)),
        .rd_en        (fifo_rd                ),
        .dout         (fifo_dout              ),
        .full         (fifo_full              ),
        .empty        (fifo_empty             ),
        .rd_data_count(fifo_rd_cnt            )
    );
*/

    cmip_afifo_wd_conv_wsrl #(                         
        .DPTH                   (FIFO_DEPTH             ),
        .WR_DATA_WD             (WR_DATA_WD             ),
        .RD_DATA_WD             (DDR_DATA_WD            ),
        .FWFT                   (1                      )
    )u_cmip_afifo_wd_conv_wsrl(    
        .i_wr_clk               (wr_clk                 ),//(i)
        .i_wr_rst_n             (~cfg_rst && wr_rst_n   ),//(i)
        .i_wr                   (fifo_wr && (~fifo_full)),//(i)
        .i_din                  (fifo_din               ),//(i)
        .o_full                 (fifo_full              ),//(o)
        .o_wr_cnt               (                       ),//(o)
        .i_rd_clk               (ddr_clk                ),//(i)
        .i_rd_rst_n             (~cfg_rst && ddr_rst_n  ),//(i)
        .i_rd                   (fifo_rd                ),//(i)
        .o_dout                 (fifo_dout              ),//(o)
        .o_empty                (fifo_empty             ),//(o)
        .o_rd_cnt               (fifo_rd_cnt            ) //(o)
    );                                                       


    cmip_app_cnt #(
        .WDTH                   (32                )
    )u_cnt(          
        .i_clk                  (wr_clk            ),//(i) 
        .i_rst_n                (wr_rst_n          ),//(i) 
        .i_clr                  (cfg_rst           ),//(i) 
        .i_vld                  (fifo_full         ),//(i) 
        .o_cnt                  (fifo_full_cnt     ) //(o) 
    );



    function automatic [DDR_DATA_WD -1:0] byte_adj(
        input          [DDR_DATA_WD -1:0]     a   
    );begin:abc
        integer i;
        for(i=1;i<=RATE;i=i+1)begin
            byte_adj[i*WR_DATA_WD  -1 -:WR_DATA_WD ] = a[(RATE + 1 - i)*WR_DATA_WD  -1 -: WR_DATA_WD ];
        end
    end
    endfunction


endmodule





