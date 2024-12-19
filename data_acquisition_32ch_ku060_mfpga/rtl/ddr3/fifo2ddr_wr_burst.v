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


module fifo2ddr_wr_burst #(
    parameter                               FIFO_DEPTH      =  2048              ,
    parameter                               FIFO_ADDR_WD    =  $clog2(FIFO_DEPTH),
    parameter                               WR_DATA_WD      =  128               ,
    parameter                               DDR_ADDR_WD     =  32                ,
    parameter                               DDR_DATA_WD     =  512               ,
    parameter                               BURST_LEN       =  16                ,
    parameter                               BASE_ADDR       =  32'h0000          ,
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
    output    reg     [DDR_ADDR_WD-1:0]     wr_blk_cnt                     ,//(o)
    output    reg     [DDR_ADDR_WD-1:0]     wr_glb_blk_cnt                  //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam                              RATE              =  DDR_DATA_WD/WR_DATA_WD;
    localparam                              RATE_BITS         =  $clog2(RATE)      ;
    localparam                              MAX_BLK_SIZE_M1   =  MAX_BLK_SIZE - 1  ;        
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire              [DDR_DATA_WD-1:0]     fifo_dout                       ;
    wire                                    fifo_empty                      ;
    wire                                    fifo_rd                         ;
    wire              [FIFO_ADDR_WD :0]     fifo_rd_cnt                     ;
    reg                                     ddr_cfg_rst_d1                  ;   
    reg                                     ddr_cfg_rst_d2                  ;
    reg                                     wr_cfg_rst_d1                   ;   
    reg                                     wr_cfg_rst_d2                   ;     

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            wr_burst_req    =   ~fifo_empty && ((fifo_rd_cnt[FIFO_ADDR_WD-1:0] >= BURST_LEN) );
    assign            wr_burst_len    =    BURST_LEN                        ;
//    assign            wr_burst_addr   =    BASE_ADDR + {wr_blk_cnt,3'd0}    ;
    assign            wr_burst_addr   =    BASE_ADDR + {(wr_glb_blk_cnt & MAX_BLK_SIZE_M1),3'd0}    ;
    assign            fifo_rd         =    wr_burst_data_req                ;
    assign            wr_burst_data   =    byte_adj(fifo_dout)              ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge ddr_clk)begin
        ddr_cfg_rst_d1 <= cfg_rst   ;
        ddr_cfg_rst_d2 <= ddr_cfg_rst_d1;
    end

    always@(posedge wr_clk)begin
        wr_cfg_rst_d1 <= cfg_rst   ;
        wr_cfg_rst_d2 <= wr_cfg_rst_d1;
    end

    //notice:1 block == 512bits
    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            wr_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(ddr_cfg_rst_d2)
            wr_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(wr_burst_finish && (wr_blk_cnt >= MAX_BLK_SIZE - BURST_LEN))
            wr_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(wr_burst_finish)
            wr_blk_cnt <= wr_blk_cnt + BURST_LEN;
    end

    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            wr_glb_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(ddr_cfg_rst_d2)
            wr_glb_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(wr_burst_finish)
            wr_glb_blk_cnt <= wr_glb_blk_cnt + BURST_LEN;
    end


    
    
    afifo_w512r512 u_afifo_w512r512(
        .rst                    (~wr_rst_n || wr_cfg_rst_d2   ),
        .wr_clk                 (wr_clk                       ),
        .rd_clk                 (ddr_clk                      ),
        .din                    (fifo_din                     ),
        .wr_en                  (fifo_wr                      ),
        .rd_en                  (fifo_rd                      ),
        .dout                   (fifo_dout                    ),
        .full                   (fifo_full                    ),
        .empty                  (fifo_empty                   ),
        .wr_rst_busy            (                             ),
        .rd_rst_busy            (                             ),
        .rd_data_count          (fifo_rd_cnt                  )
    );

/*
    cmip_afifo_wd_conv_wsrl #(                         
        .DPTH                   (FIFO_DEPTH             ),
        .WR_DATA_WD             (WR_DATA_WD             ),
        .RD_DATA_WD             (DDR_DATA_WD            ),
        .FWFT                   (1                      )
    )u_cmip_afifo_wd_conv_wsrl(    
        .i_wr_clk               (wr_clk                 ),//(i)
        .i_wr_rst_n             (~wr_cfg_rst_d2 && wr_rst_n   ),//(i)
        .i_wr                   (fifo_wr && (~fifo_full)),//(i)
        .i_din                  (fifo_din               ),//(i)
        .o_full                 (fifo_full              ),//(o)
        .o_wr_cnt               (                       ),//(o)
        .i_rd_clk               (ddr_clk                ),//(i)
        .i_rd_rst_n             (~ddr_cfg_rst_d2 && ddr_rst_n  ),//(i)
        .i_rd                   (fifo_rd                ),//(i)
        .o_dout                 (fifo_dout              ),//(o)
        .o_empty                (fifo_empty             ),//(o)
        .o_rd_cnt               (fifo_rd_cnt            ) //(o)
    );                                                       
*/

    cmip_app_cnt #(
        .width                  (32                )
    )u0_cnt(          
        .clk                    (wr_clk            ),//(i) 
        .rst_n                  (wr_rst_n          ),//(i) 
        .clr                    (wr_cfg_rst_d2     ),//(i) 
        .vld                    (fifo_full         ),//(i) 
        .cnt                    (fifo_full_cnt     ) //(o) 
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





