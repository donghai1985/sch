module cmip_async_fifo #(
    parameter               DPTH                               =       32                           ,   // depth of the async fifo
    parameter               DATA_WDTH                          =       512                          ,   // data width
    parameter               FWFT                               =       1                            ,   //fwft enable
    parameter               ADDR_WDTH                          =       $clog2(DPTH)                     // log2 DPTH
)
(
//wr_clk//
    input                                                              i_wr_clk                     ,   //
    input                                                              i_wr_rst_n                   ,   //
    input                   [ADDR_WDTH:0]                              i_aful_th                    ,   // almost full water line
    input                                                              i_wr                         ,   //
    input                   [DATA_WDTH-1:0]                            i_din                        ,   //

    output                                                             o_aful                       ,   // almost full fc
    output                                                             o_full                       ,   //
    output                                                             o_ovfl_int                   ,   // overflow int
    output                  [ADDR_WDTH:0]                              o_wr_cnt                     ,   // wr_clk data count
    output                  [DATA_WDTH-1:0]                            o_mem_wdata                  ,   //
    output                                                             o_mem_wr                     ,   //
    output                  [ADDR_WDTH-1:0]                            o_mem_waddr                  ,   //
//rd_clk//
    input                                                              i_rd_clk                     ,   //
    input                                                              i_rd_rst_n                   ,   //
    input                                                              i_rd                         ,   //
    input                   [ADDR_WDTH:0]                              i_amty_th                    ,   // almost empty water line
    input                   [DATA_WDTH-1:0]                            i_mem_rdata                  ,   //

    output                                                             o_mem_rd                     ,   //
    output                  [ADDR_WDTH-1:0]                            o_mem_raddr                  ,   //
    output                                                             o_amty                       ,   // almost empty
    output                  [DATA_WDTH-1:0]                            o_dout                       ,   // data output 1 cycle delay
    output                                                             o_empty                      ,   //
    output                                                             o_unfl_int                   ,   // under flow int
    output                  [ADDR_WDTH:0]                              o_rd_cnt                         // rd_clk data count
);


    wire                                      mem_wr      ;
    wire     [ADDR_WDTH-1:0]                  mem_waddr   ;
    wire     [DATA_WDTH-1:0]                  mem_wdata   ;
    wire                                      mem_rd      ;
    wire     [ADDR_WDTH-1:0]                  mem_raddr   ;
    wire     [DATA_WDTH-1:0]                  mem_rdata   ;
 
    cmip_async_mem_fifo #(
        .DPTH         (DPTH        ),
        .DATA_WDTH    (DATA_WDTH   ),
        .ADDR_WDTH    (ADDR_WDTH   ),
        .FWFT         (FWFT        )
        )
    u_cmip_async_mem_fifo
        (
        .i_wr_clk     ( i_wr_clk      ),
        .i_rd_clk     ( i_rd_clk      ),
        .i_wr_rst_n   ( i_wr_rst_n    ),
        .i_rd_rst_n   ( i_rd_rst_n    ),
        .i_aful_th    ( i_aful_th     ),
        .i_amty_th    ( i_amty_th     ),
        .i_wr         ( i_wr          ),
        .i_din        ( i_din         ),
        .i_rd         ( i_rd          ),
        .o_dout       ( o_dout        ),
        .o_aful       ( o_aful        ),
        .o_amty       ( o_amty        ),
        .o_full       ( o_full        ),
        .o_empty      ( o_empty       ),
        .o_ovfl_int   ( o_ovfl_int    ),
        .o_unfl_int   ( o_unfl_int    ),
        .o_wr_cnt     ( o_wr_cnt      ),
        .o_rd_cnt     ( o_rd_cnt      ),
        .o_mem_wr     ( mem_wr        ),
        .o_mem_waddr  ( mem_waddr     ),
        .o_mem_wdata  ( mem_wdata     ),
        .o_mem_rd     ( mem_rd        ),
        .o_mem_raddr  ( mem_raddr     ),
        .i_mem_rdata  ( mem_rdata     )
        );
    
    cmip_1r1w2c_mem_wrapper #(
        .DPTH         (DPTH        ),
        .DATA_WDTH    (DATA_WDTH   ),
        .ADDR_WDTH    (ADDR_WDTH   )
       )
    u_cmip_1r1w2c_mem_wrapper
       (    
        .i_wr_clk       ( i_wr_clk       ),
        .i_rd_clk       ( i_rd_clk       ),
        .i_wr           ( mem_wr         ), //write enable, high active
        .i_waddr        ( mem_waddr      ), 
        .i_wdata        ( mem_wdata      ), 
        .i_rd           ( mem_rd         ), //read enable, high active
        .i_raddr        ( mem_raddr      ), 
        .o_rdata        ( mem_rdata      )   
    );  

endmodule


















































