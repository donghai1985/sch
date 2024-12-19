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
// 0.1.0      2023/09/28   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================


module axi2ddr_wr_inf #(
    parameter                               FIFO_DPTH       =  128         ,
    parameter                               AXI_DATA_WD     =  128         ,
    parameter                               AXI_ADDR_WD     =  64          ,
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DGBCNT_EN       =   1          ,
    parameter                               DGBCNT_WD       =  16          
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
    input                                   axi_clk                        ,//(i)
    input                                   axi_rst_n                      ,//(i)
    input                                   cfg_rst                        ,//(i)

    input             [AXI_ADDR_WD  -1:0]   s_axi_awaddr                   ,//(i)
    input             [ 1:0]                s_axi_awburst                  ,//(i)
    input             [ 3:0]                s_axi_awcache                  ,//(i)
    input             [ 3:0]                s_axi_awid                     ,//(i)
    input             [ 7:0]                s_axi_awlen                    ,//(i)
    input                                   s_axi_awlock                   ,//(i)
    input             [ 2:0]                s_axi_awprot                   ,//(i)
    input             [ 3:0]                s_axi_awqos                    ,//(i)
    input                                   s_axi_awvalid                  ,//(i)
    output                                  s_axi_awready                  ,//(o)
    input             [ 2:0]                s_axi_awsize                   ,//(i)
    input                                   s_axi_awuser                   ,//(i)
    input                                   s_axi_wvalid                   ,//(i)
    output                                  s_axi_wready                   ,//(o)
    input             [AXI_DATA_WD  /8-1:0] s_axi_wstrb                    ,//(i)
    input             [AXI_DATA_WD    -1:0] s_axi_wdata                    ,//(i)
    input                                   s_axi_wlast                    ,//(i)

    output   reg                            s_axi_bvalid                   ,//(o)
    input                                   s_axi_bready                   ,//(i)
    output            [ 1:0]                s_axi_bresp                    ,//(o)
    output            [ 3:0]                s_axi_bid                      ,//(o)

//    input                                   rd_burst_req                   ,//(i)      
    output                                  wr_burst_req                   ,//(o)      
    output            [9:0]                 wr_burst_len                   ,//(o)  
    output            [AXI_ADDR_WD  -1:0]   wr_burst_addr                  ,//(o)    
    input                                   wr_burst_data_req              ,//(i) 
    output            [DDR_DATA_WD  -1:0]   wr_burst_data                  ,//(o)
    input                                   wr_burst_finish                ,//(i)


    input                                   dbg_cnt_clr                    ,//(i)
    output            [DGBCNT_WD  -1:0]     dbg_axi_awvalid                 //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam                              CMD_FIFO_WD       =  AXI_ADDR_WD   +  8;
    localparam                              DAT_FIFO_DP       =  4096              ;
    localparam                              RATE              =  DDR_DATA_WD/AXI_DATA_WD;
    localparam                              RATE_BITS         =  $clog2(RATE)      ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    cmd_fifo_wr                     ;
    wire              [CMD_FIFO_WD-1:0]     cmd_fifo_din                    ;
    wire                                    cmd_fifo_rd                     ;
    wire              [CMD_FIFO_WD-1:0]     cmd_fifo_dout                   ;
    wire                                    cmd_fifo_full                   ;
    wire                                    cmd_fifo_empty                  ;

    wire                                    dat_fifo_wr                     ;
    wire              [AXI_DATA_WD-1:0]     dat_fifo_din                    ;
    wire                                    dat_fifo_rd                     ;
    wire              [DDR_DATA_WD-1:0]     dat_fifo_dout                   ;
    wire                                    dat_fifo_full                   ;
    wire                                    dat_fifo_empty                  ;
    wire              [9:0]                 dat_fifo_rd_cnt                 ;
    wire              [9:0]                 dat_fifo_rd_cnt_dly             ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            cmd_fifo_wr   =      s_axi_awvalid && s_axi_awready   ;
    assign            cmd_fifo_din  =      {s_axi_awaddr,s_axi_awlen}       ;
    assign            s_axi_awready =      ~cmd_fifo_full                   ;
    assign            cmd_fifo_rd   =      ~cmd_fifo_empty && wr_burst_finish;//notice

    assign            dat_fifo_wr   =      s_axi_wvalid && s_axi_wready     ;
    assign            dat_fifo_din  =      s_axi_wdata                      ;
    assign            s_axi_wready  =     ~dat_fifo_full                    ;
    assign            dat_fifo_rd   =      wr_burst_data_req                ;

    assign            wr_burst_req     =   (~cmd_fifo_empty) && (~dat_fifo_empty) && (dat_fifo_rd_cnt_dly>=wr_burst_len);//notice
    assign            wr_burst_len     =   (cmd_fifo_dout[7:0]+ 1'b1)>> RATE_BITS;
    assign            wr_burst_addr    =   cmd_fifo_dout[CMD_FIFO_WD-1:8] >> 3;
    assign            wr_burst_data    =   byte_adj(dat_fifo_dout)          ;

    assign            s_axi_bresp      =   2'd0                             ;
    assign            s_axi_bid        =   4'd0                             ;




// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge axi_clk or negedge axi_rst_n) begin
        if(~axi_rst_n)
            s_axi_bvalid <= 1'b0;
        else if(s_axi_bvalid && s_axi_bready)
            s_axi_bvalid <= 1'b0;
        else if(s_axi_wlast && dat_fifo_wr)
            s_axi_bvalid <= 1'b1;
    end



    cmd_fifo u_cmd_fifo (
        .wr_clk       (axi_clk                    ),
        .wr_rst       (~axi_rst_n || cfg_rst      ),
        .rd_clk       (ddr_clk                    ),
        .rd_rst       (~ddr_rst_n || cfg_rst      ),
        .din          (cmd_fifo_din               ),
        .wr_en        (cmd_fifo_wr                ),
        .rd_en        (cmd_fifo_rd                ),
        .dout         (cmd_fifo_dout              ),
        .full         (cmd_fifo_full              ),
        .empty        (cmd_fifo_empty             ) 
    );
    
    wr_dat_fifo u_wr_dat_fifo (
        .wr_clk       (axi_clk                    ),
        .wr_rst       (~axi_rst_n || cfg_rst      ),
        .rd_clk       (ddr_clk                    ),
        .rd_rst       (~ddr_rst_n || cfg_rst      ),
        .din          (dat_fifo_din               ),
        .wr_en        (dat_fifo_wr                ),
        .rd_en        (dat_fifo_rd                ),
        .dout         (dat_fifo_dout              ),
        .full         (dat_fifo_full              ),
        .empty        (dat_fifo_empty             ),
        .rd_data_count(dat_fifo_rd_cnt            )
    );

/*
    cmip_async_fifo #(
        .DPTH         (32                         ),
        .DATA_WDTH    (CMD_FIFO_WD                ),
        .FWFT         (1                          )
    )u_cmd_fifo(          
        .i_wr_clk     (axi_clk                    ),
        .i_rd_clk     (ddr_clk                    ),
        .i_wr_rst_n   (axi_rst_n && (~cfg_rst)    ),
        .i_rd_rst_n   (ddr_rst_n && (~cfg_rst)    ),
        .i_aful_th    (4                          ),
        .i_amty_th    (0                          ),
        .i_wr         (cmd_fifo_wr                ),
        .i_din        (cmd_fifo_din               ),
        .i_rd         (cmd_fifo_rd                ),
        .o_dout       (cmd_fifo_dout              ),
        .o_aful       (cmd_fifo_full              ),
        .o_amty       (                           ),
        .o_full       (                           ),
        .o_empty      (cmd_fifo_empty             ),
        .o_ovfl_int   (                           ),
        .o_unfl_int   (                           ),
        .o_wr_cnt     (                           ),
        .o_rd_cnt     (                           )
    );
    
    cmip_afifo_wd_conv_wsrl #(
        .DPTH         (DAT_FIFO_DP                ),
        .WR_DATA_WD   (AXI_DATA_WD                ),
        .RD_DATA_WD   (DDR_DATA_WD                ),
        .FWFT         (1                          )
    )u_wr_dat_fifo(          
        .i_wr_clk     (axi_clk                    ),
        .i_rd_clk     (ddr_clk                    ),
        .i_wr_rst_n   (axi_rst_n                  ),
        .i_rd_rst_n   (ddr_rst_n                  ),
        .i_wr         (dat_fifo_wr                ),
        .i_din        (dat_fifo_din               ),
        .i_rd         (dat_fifo_rd                ),
        .o_dout       (dat_fifo_dout              ),
        .o_full       (dat_fifo_full              ),
        .o_empty      (dat_fifo_empty             ),
        .o_wr_cnt     (                           ),
        .o_rd_cnt     (dat_fifo_rd_cnt            )
    );
*/
    cmip_bus_delay #(
        .BUS_DELAY    (   4                       ),  
        .DATA_WDTH    (   10                      )   
    )u_mip_bus_delay(
        .i_clk        (   ddr_clk                ),  
        .i_rst_n      (   ddr_rst_n              ),  
        .i_din        (   dat_fifo_rd_cnt        ),  
        .o_dout       (   dat_fifo_rd_cnt_dly    )   
    );

    function automatic [DDR_DATA_WD -1:0] byte_adj(
        input          [DDR_DATA_WD -1:0]     a   
    );begin:abc
        integer i;
        for(i=1;i<=RATE;i=i+1)begin
            byte_adj[i*AXI_DATA_WD -1 -:AXI_DATA_WD] = a[(RATE + 1 - i)*AXI_DATA_WD -1 -: AXI_DATA_WD];
        end
    end
    endfunction


endmodule





