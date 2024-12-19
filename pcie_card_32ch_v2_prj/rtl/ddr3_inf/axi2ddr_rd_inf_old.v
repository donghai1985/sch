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


module axi2ddr_rd_inf #(
    parameter                               FIFO_DPTH       =  1024        ,
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

(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output                                  rd_burst_req                   ,//(o)      
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output            [9:0]                 rd_burst_len                   ,//(o)  
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output            [AXI_ADDR_WD  -1:0]   rd_burst_addr                  ,//(o)    
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input                                   rd_burst_data_valid            ,//(i) 
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input             [DDR_DATA_WD  -1:0]   rd_burst_data                  ,//(o)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input                                   rd_burst_finish                ,//(i)

    input                                   dbg_cnt_clr                    ,//(i)
    output            [DGBCNT_WD  -1:0]     dbg_axi_arvalid                 //(o)

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
    wire              [8          -1:0]     rlast_fifo_dout                 ;
    wire                                    rlast_fifo_empty                ;
    wire                                    rlast_fifo_wr_chk               ;
    reg                                     rlast_fifo_wr_chk_d1            ;
    wire                                    rlast_fifo_wr                   ;

    wire                                    dat_fifo_wr                     ;
    wire              [DDR_DATA_WD-1:0]     dat_fifo_din                    ;
    wire                                    dat_fifo_rd                     ;
    wire              [AXI_DATA_WD-1:0]     dat_fifo_dout                   ;
    wire                                    dat_fifo_full                   ;
    wire                                    dat_fifo_empty                  ;
    reg               [7:0]                 rd_cnt                          ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            cmd_fifo_wr   =      s_axi_arvalid && s_axi_arready   ;//axi_clk
    assign            cmd_fifo_din  =      {s_axi_araddr,s_axi_arlen}       ;//axi_clk
    assign            s_axi_arready =      ~cmd_fifo_full                   ;//axi_clk
    assign            cmd_fifo_rd   =       rd_burst_finish                 ;//ddr_clk

    assign            dat_fifo_wr   =      rd_burst_data_valid              ;//ddr_clk
    assign            dat_fifo_din  =      byte_adj(rd_burst_data)          ;//ddr_clk
    assign            s_axi_rvalid  =     ~dat_fifo_empty                   ;//axi_clk
    assign            dat_fifo_rd   =      s_axi_rvalid && s_axi_rready     ;//axi_clk

    assign            rd_burst_req     =  ~cmd_fifo_empty                   ;//ddr_clk //notice
    assign            rd_burst_len     =  (cmd_fifo_dout[7:0] + 1'b1)>> RATE_BITS;//ddr_clk
    assign            rd_burst_addr    =   cmd_fifo_dout[CMD_FIFO_WD-1:8] >> 3  ;//ddr_clk
    assign            s_axi_rdata      =   dat_fifo_dout                    ;//axi_clk
    assign            s_axi_rlast      =   ~rlast_fifo_empty && (rd_cnt == rlast_fifo_dout) ;//axi_clk
    assign            s_axi_rresp      =   2'b0                             ;//axi_clk
    assign            s_axi_rid        =   4'b0                             ;//axi_clk
    assign            rlast_fifo_wr_chk=   rd_burst_req && (~cmd_fifo_rd)   ;
    assign            rlast_fifo_wr    =   ~rlast_fifo_wr_chk_d1 && rlast_fifo_wr_chk;

// =================================================================================================
// RTL Body
// ================================================================================================

    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)
            rd_cnt <= 8'd0;
        else if(cfg_rst)
            rd_cnt <= 8'd0;
        else if(s_axi_rlast && dat_fifo_rd)
            rd_cnt <= 8'd0;
        else if(dat_fifo_rd)
            rd_cnt <= rd_cnt + 1'b1;
    end

    always@(posedge ddr_clk)begin
            rlast_fifo_wr_chk_d1 <= rlast_fifo_wr_chk;
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

    rd_dat_fifo u_rd_dat_fifo (
        .wr_clk       (ddr_clk                    ),
        .wr_rst       (~ddr_rst_n || cfg_rst      ),
        .rd_clk       (axi_clk                    ),
        .rd_rst       (~axi_rst_n || cfg_rst      ),
        .din          (dat_fifo_din               ),
        .wr_en        (dat_fifo_wr                ),
        .rd_en        (dat_fifo_rd                ),
        .dout         (dat_fifo_dout              ),
        .full         (dat_fifo_full              ),
        .empty        (dat_fifo_empty             ) 
    );

    rlast_fifo u_rlast_fifo (
        .wr_clk       (ddr_clk                    ),
        .wr_rst       (~ddr_rst_n || cfg_rst      ),
        .rd_clk       (axi_clk                    ),
        .rd_rst       (~axi_rst_n || cfg_rst      ),
        .din          (cmd_fifo_dout[7:0]         ),//rd_burst_len
        .wr_en        (rlast_fifo_wr              ),
        .rd_en        (s_axi_rlast && dat_fifo_rd ),
        .dout         (rlast_fifo_dout            ),
        .full         (                           ),
        .empty        (rlast_fifo_empty           ) 
    );


/*
    cmip_async_fifo #(
        .DPTH         (32                         ),
        .DATA_WDTH    (CMD_FIFO_WD                ),
        .FWFT         (1                          )
    )u_cmd_fifo(          
        .i_rd_clk     (axi_clk                    ),
        .i_wr_clk     (ddr_clk                    ),
        .i_rd_rst_n   (axi_rst_n && (~cfg_rst)    ),
        .i_wr_rst_n   (ddr_rst_n && (~cfg_rst)    ),
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
    
    cmip_afifo_wd_conv_rswl #(
        .DPTH         (DAT_FIFO_DP                ),
        .WR_DATA_WD   (DDR_DATA_WD                ),
        .RD_DATA_WD   (AXI_DATA_WD                ),
        .FWFT         (1                          )
    )u_rd_dat_fifo(          
        .i_rd_clk     (axi_clk                    ),
        .i_wr_clk     (ddr_clk                    ),
        .i_rd_rst_n   (axi_rst_n  && (~cfg_rst)   ),
        .i_wr_rst_n   (ddr_rst_n  && (~cfg_rst)   ),
        .i_wr         (dat_fifo_wr                ),
        .i_din        (dat_fifo_din               ),
        .i_rd         (dat_fifo_rd                ),
        .o_dout       (dat_fifo_dout              ),
        .o_full       (dat_fifo_full              ),
        .o_empty      (dat_fifo_empty             ),
        .o_wr_cnt     (                           ),
        .o_rd_cnt     (                           )
    );

    cmip_async_fifo #(
        .DPTH         (32                         ),
        .DATA_WDTH    (8                          ),
        .FWFT         (1                          )
    )u_rlast_fifo(          
        .i_rd_clk     (axi_clk                    ),
        .i_wr_clk     (ddr_clk                    ),
        .i_rd_rst_n   (axi_rst_n && (~cfg_rst)    ),
        .i_wr_rst_n   (ddr_rst_n && (~cfg_rst)    ),
        .i_aful_th    (4                          ),
        .i_amty_th    (0                          ),
        .i_wr         (rlast_fifo_wr              ),
        .i_din        (cmd_fifo_dout[7:0]         ),
        .i_rd         (s_axi_rlast && dat_fifo_rd ),
        .o_dout       (rlast_fifo_dout            ),
        .o_aful       (                           ),
        .o_amty       (                           ),
        .o_full       (                           ),
        .o_empty      (rlast_fifo_empty           ),
        .o_ovfl_int   (                           ),
        .o_unfl_int   (                           ),
        .o_wr_cnt     (                           ),
        .o_rd_cnt     (                           )
    );
*/

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





