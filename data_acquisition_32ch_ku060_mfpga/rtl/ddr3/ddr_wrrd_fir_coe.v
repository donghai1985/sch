module ddr_wrrd_fir_coe  #(
    parameter                               FIFO_DPTH       =  32                ,
    parameter                               FIFO_ADDR_WD    =  $clog2(FIFO_DPTH) ,
    parameter                               WR_DATA_WD      =  32                ,
    parameter                               RD_DATA_WD      =  32                ,
    parameter                               DDR_DATA_WD     =  512               ,
    parameter                               DDR_ADDR_WD     =  32                ,
    parameter                               MAX_BLK_SIZE    =  32'h20000         ,//8MB
    parameter                               BURST_LEN       =  8                 ,
    parameter                               BASE_ADDR       =  32'h0000           
)(   
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
    input                                   wr_clk                         ,//(i)
    input                                   wr_rst_n                       ,//(i)
    input                                   rd_clk                         ,//(i)
    input                                   rd_rst_n                       ,//(i)
    input                                   cfg_rst                        ,//(i)

    input                                   ddr_rd0_en                     ,//(i)
    input               [32-1:0]            ddr_rd0_addr                   ,//(i)
    input                                   ddr_rd1_en                     ,//(i)
    input               [32-1:0]            ddr_rd1_addr                   ,//(i)
    output                                  readback0_vld                  ,//(o)
    output                                  readback0_last                 ,//(o)
    output              [32-1:0]            readback0_data                 ,//(o)
    output                                  readback1_vld                  ,//(o)
    output                                  readback1_last                 ,//(o)
    output              [32-1:0]            readback1_data                 ,//(o)
                                                                                
    input                                   fir_tap_wr_cmd                 ,//(i)
    input               [32-1:0]            fir_tap_wr_addr                ,//(i)
    input                                   fir_tap_wr_vld                 ,//(i)
    input               [32-1:0]            fir_tap_wr_data                ,//(i)

    output                                  wr_burst_req                   ,//(o)      
    output            [9:0]                 wr_burst_len                   ,//(o)  
    output            [DDR_ADDR_WD  -1:0]   wr_burst_addr                  ,//(o)    
    input                                   wr_burst_data_req              ,//(i) 
    output            [DDR_DATA_WD  -1:0]   wr_burst_data                  ,//(o)
    input                                   wr_burst_finish                ,//(i)

    output                                  rd_burst_req                   ,//(o)      
    output            [9:0]                 rd_burst_len                   ,//(o)  
    output            [DDR_ADDR_WD  -1:0]   rd_burst_addr                  ,//(o)    
    input                                   rd_burst_data_valid            ,//(i) 
    input             [DDR_DATA_WD  -1:0]   rd_burst_data                  ,//(o)
    input                                   rd_burst_finish                 //(i)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    // wire                                    ch2_wr_burst_req                  ;
    // wire        [9:0]                       ch2_wr_burst_len                  ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------



// =================================================================================================
// RTL Body
// =================================================================================================
    //---------------------------------------------------------------------
    // fifo2ddr_wr_burst Module Inst.
    //---------------------------------------------------------------------     
    fircoe_wr_burst #(                                                            
        .FIFO_DEPTH                        (FIFO_DPTH                        ),
        .FIFO_ADDR_WD                      (FIFO_ADDR_WD                     ),
        .WR_DATA_WD                        (WR_DATA_WD                       ),
        .DDR_ADDR_WD                       (DDR_ADDR_WD                      ),
        .DDR_DATA_WD                       (DDR_DATA_WD                      ),
        .BURST_LEN                         (BURST_LEN                        ),
        .BASE_ADDR                         (BASE_ADDR                        ),
        .MAX_BLK_SIZE                      (MAX_BLK_SIZE                     )  
    )u_fircoe_wr_burst( 
        .ddr_clk                           (ddr_clk                          ),//(i)
        .ddr_rst_n                         (ddr_rst_n                        ),//(i)
        .wr_clk                            (wr_clk                           ),//(i)
        .wr_rst_n                          (wr_rst_n                         ),//(i)
        .cfg_rst                           (cfg_rst                          ),//(i)

        .fir_tap_wr_cmd                    (fir_tap_wr_cmd                   ),//(i)
        .fir_tap_wr_addr                   (fir_tap_wr_addr                  ),//(i)
        .fir_tap_wr_vld                    (fir_tap_wr_vld                   ),//(i)
        .fir_tap_wr_data                   (fir_tap_wr_data                  ),//(i)

        .wr_burst_req                      (wr_burst_req                     ),//(o)
        .wr_burst_len                      (wr_burst_len                     ),//(o)
        .wr_burst_addr                     (wr_burst_addr                    ),//(o)
        .wr_burst_data_req                 (wr_burst_data_req                ),//(i)
        .wr_burst_data                     (wr_burst_data                    ),//(o)
        .wr_burst_finish                   (wr_burst_finish                  ) //(i)
    );                                                                              

    //---------------------------------------------------------------------
    // ddr2fifo_rd_burst Module Inst.
    //---------------------------------------------------------------------     
    fircoe_rd_burst #(                                                             
        .FIFO_DPTH                         (FIFO_DPTH                        ),
        .RD_DATA_WD                        (RD_DATA_WD                       ),
        .DDR_DATA_WD                       (DDR_DATA_WD                      ),
        .DDR_ADDR_WD                       (DDR_ADDR_WD                      ),
        .BURST_LEN                         (2                                ),
        .BASE_ADDR                         (BASE_ADDR                        ),
        .MAX_BLK_SIZE                      (MAX_BLK_SIZE                     )       
    )u_fircoe_rd_burst( 
        .ddr_clk                           (ddr_clk                          ),//(i)
        .ddr_rst_n                         (ddr_rst_n                        ),//(i)
        .rd_clk                            (rd_clk                           ),//(i)
        .rd_rst_n                          (rd_rst_n                         ),//(i)
        .cfg_rst                           (cfg_rst                          ),//(i)

        .ddr_rd0_en                        (ddr_rd0_en                       ),//(i)
        .ddr_rd0_addr                      (ddr_rd0_addr                     ),//(i)
        .ddr_rd1_en                        (ddr_rd1_en                       ),//(i)
        .ddr_rd1_addr                      (ddr_rd1_addr                     ),//(i)
        .readback0_vld                     (readback0_vld                    ),//(o)
        .readback0_last                    (readback0_last                   ),//(o)
        .readback0_data                    (readback0_data                   ),//(o)
        .readback1_vld                     (readback1_vld                    ),//(o)
        .readback1_last                    (readback1_last                   ),//(o)
        .readback1_data                    (readback1_data                   ),//(o)

        .rd_burst_req                      (rd_burst_req                     ),//(o)
        .rd_burst_len                      (rd_burst_len                     ),//(o)
        .rd_burst_addr                     (rd_burst_addr                    ),//(o)
        .rd_burst_data_valid               (rd_burst_data_valid              ),//(i)
        .rd_burst_data                     (rd_burst_data                    ),//(i)
        .rd_burst_finish                   (rd_burst_finish                  ) //(i)
    );                                                                               











endmodule

























