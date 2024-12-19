

module cmip_sync_fifo #(
    parameter       DPTH                                =       8                      ,   //
    parameter       DATA_WDTH                           =       32                     ,   //
    parameter       ADDR_WDTH                           =       $clog2(DPTH)           ,   //$clog2(DPTH)
    parameter       FWFT                                =       1                      ,   //
    parameter       XILINX_FIFO                         =       1                 
)(        
    input                                                       i_clk                  ,   //
    input                                                       i_rst_n                ,   //
    input           [ADDR_WDTH:0]                               i_aful_th              ,   //
    input           [ADDR_WDTH:0]                               i_amty_th              ,   //
    input                                                       i_wr                   ,   //
    input           [DATA_WDTH-1:0]                             i_din                  ,   //
    input                                                       i_rd                   ,   //
    output          [DATA_WDTH-1:0]                             o_dout                 ,   //
    output                                                      o_aful                 ,   //
    output                                                      o_amty                 ,   //
    output                                                      o_full                 ,   //
    output                                                      o_empty                ,   //
    output                                                      o_ovfl_int             ,   //
    output                                                      o_unfl_int             ,   //
    output          [ADDR_WDTH:0]                               o_used_cnt                 //
);

generate if(XILINX_FIFO == 0)begin
     //memory signals
     wire                                      mem_wr      ;
     wire     [ADDR_WDTH-1:0]                  mem_waddr   ;
     wire     [DATA_WDTH-1:0]                  mem_wdata   ;
     wire                                      mem_rd      ;
     wire     [ADDR_WDTH-1:0]                  mem_raddr   ;
     wire     [DATA_WDTH-1:0]                  mem_rdata   ;
     
    cmip_sync_mem_fifo #(
        .DPTH         (DPTH        ),
        .DATA_WDTH    (DATA_WDTH   ),
        .ADDR_WDTH    (ADDR_WDTH   ),
        .FWFT         (FWFT        )
        )
    u_cmip_sync_mem_fifo
        (
        .i_clk        ( i_clk         ),
        .i_rst_n      ( i_rst_n       ),
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
        .o_used_cnt   ( o_used_cnt    ),
        .o_mem_wr     ( mem_wr        ),
        .o_mem_waddr  ( mem_waddr     ),
        .o_mem_wdata  ( mem_wdata     ),
        .o_mem_rd     ( mem_rd        ),
        .o_mem_raddr  ( mem_raddr     ),
        .i_mem_rdata  ( mem_rdata     )
        );
    
    //////////////////////////////////////
    //// inst cmn_ip_sync_mem_fifo
    //////////////////////////////////////
    
    cmip_1r1w_mem_wrapper #(
        .DPTH         (DPTH        ),
        .DATA_WDTH    (DATA_WDTH   ),
        .ADDR_WDTH    (ADDR_WDTH   )
       )
    u_cmip_1r1w_mem_wrapper
       (    
        .i_clk          ( i_clk          ),
        .i_wr           ( mem_wr         ), //write enable, high active
        .i_waddr        ( mem_waddr      ), 
        .i_wdata        ( mem_wdata      ), 
        .i_rd           ( mem_rd         ), //read enable, high active
        .i_raddr        ( mem_raddr      ), 
        .o_rdata        ( mem_rdata      )   
    );  
end else begin
    localparam    READ_MODE   =   FWFT  ? "fwft"  :   "std" ;

    xpm_sync_fifo #(                                           
        .ECC_MODE              ("no_ecc"                ),
        .FIFO_MEMORY_TYPE      ("block"                 ),
        .FIFO_READ_LATENCY     (1                       ),
        .READ_MODE             (READ_MODE               ),
        .FIFO_WRITE_DEPTH      (DPTH                    ),
        .FULL_RESET_VALUE      (1                       ),
        .PROG_EMPTY_THRESH     (5                       ),
        .PROG_FULL_THRESH      (DPTH - 5                ),
        .WRITE_DATA_WIDTH      (DATA_WDTH               ),
        .READ_DATA_WIDTH       (DATA_WDTH               ),
        .USE_ADV_FEATURES      ("0707"                  ) 
    )u_xpm_sync_fifo( 
        .wr_clk_i              (i_clk                   ),//(i)
        .rst_i                 (~i_rst_n                ),//(i)
        .wr_en_i               (i_wr                    ),//(i)
        .wr_data_i             (i_din                   ),//(i)
        .fifo_full_o           (o_full                  ),//(o)
        .fifo_almost_full_o    (                        ),//(o)
        .fifo_prog_full_o      (o_aful                  ),//(o)
        .wr_data_count_o       (                        ),//(o)
         
        .rd_en_i               (i_rd                    ),//(i)
        .fifo_rd_vld_o         (                        ),//(o)
        .fifo_rd_data_o        (o_dout                  ),//(o)
        .fifo_empty_o          (o_empty                 ),//(o)
        .fifo_almost_empty_o   (                        ),//(o)
        .fifo_prog_empty_o     (o_amty                  ),//(o)
        .rd_data_count_o       (o_used_cnt              )
    );                                                     
    
    


end
endgenerate


endmodule
