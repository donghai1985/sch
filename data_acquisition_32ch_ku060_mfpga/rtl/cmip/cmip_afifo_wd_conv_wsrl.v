module cmip_afifo_wd_conv_wsrl #(
    parameter               DPTH           =       32                           , 
    parameter               WR_DATA_WD     =       128                          , 
    parameter               RD_DATA_WD     =       512                          , 
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
    output                  [RD_DATA_WD -1:0]      o_dout                       ,
    output                                         o_empty                      ,
    output                  [ADDR_WD      :0]      o_rd_cnt                      
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // ------------------------------------------------------------------------- 
    localparam               RATE           =       RD_DATA_WD/WR_DATA_WD       ;
    localparam               RATE_BITS      =       $clog2(RATE)                ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg                                             i_wr_d1                     ;
    wire                                            fifo_wr                     ;
    reg                     [RD_DATA_WD -1:0]       fifo_din                    ;
//    wire                    [ADDR_WD    -1:0]       fifo_wr_cnt                 ;//no use
    reg                     [RATE       -1:0]       wr_flag                     ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign                   fifo_wr       =        &wr_flag                    ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge i_wr_clk or negedge i_wr_rst_n)
        if(~i_wr_rst_n)
            wr_flag <= {RATE{1'b0}};
        else if(fifo_wr && i_wr)
            wr_flag <=  1'b1 ;
        else if(fifo_wr)
            wr_flag <= {RATE{1'b0}};
        else if(i_wr)
            wr_flag <= {wr_flag,1'b1};
            //wr_flag <= {wr_flag[RATE-2:0],1'b1};

    always@(posedge i_wr_clk or negedge i_wr_rst_n)
        if(~i_wr_rst_n)
            fifo_din <= {RD_DATA_WD{1'b0}};
        else if(i_wr)
            //fifo_din <=  {fifo_din[RD_DATA_WD-WR_DATA_WD-1:0],i_din} ;
            fifo_din <=  {fifo_din,i_din} ;

    // -------------------------------------------------------------------------
    // cmip_async_mem_fifo Module Inst.
    // -------------------------------------------------------------------------
    cmip_async_fifo #(
        .DPTH                   (DPTH            ),
        .DATA_WDTH              (RD_DATA_WD      ),
        .ADDR_WDTH              (ADDR_WD         ),
        .FWFT                   (FWFT            )
    )u_cmip_async_fifo(
        .i_wr_clk               ( i_wr_clk       ),
        .i_rd_clk               ( i_rd_clk       ),
        .i_wr_rst_n             ( i_wr_rst_n     ),
        .i_rd_rst_n             ( i_rd_rst_n     ),
        .i_aful_th              ( 4              ),
        .i_amty_th              ( 4              ),
        .i_wr                   ( fifo_wr        ),
        .i_din                  ( fifo_din       ),
        .i_rd                   ( i_rd           ),
        .o_dout                 ( o_dout         ),
        .o_aful                 ( o_full         ),
        .o_amty                 (                ),
        .o_full                 (                ),
        .o_empty                ( o_empty        ),
        .o_ovfl_int             (                ),
        .o_unfl_int             (                ),
        .o_wr_cnt               ( o_wr_cnt       ),
        .o_rd_cnt               ( o_rd_cnt       )
    );




















endmodule










