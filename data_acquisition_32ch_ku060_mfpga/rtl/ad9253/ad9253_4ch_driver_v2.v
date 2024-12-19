module ad9253_4ch_driver_v2 #(
    parameter                              IODELAY_GROUP_NAME1    =    "delay1"   ,
    parameter                              IODELAY_GROUP_NAME2    =    "delay2"     
)(       
    input                                  sys_clk                                ,//(i) 100m
    input                                  sys_rst                                ,//(i)
    input                                  spi_wr_data_en                         ,//(i)
    input             [23:0]               spi_wr_data                            ,//(i)
    input                                  clk_200m                               ,//(i)
    input                                  clk                                    ,//(i)
    input                                  clk_div                                ,//(i)

    input                                  sync_in                                ,//(i)
    output                                 adc_0_data_clk                         ,//(o)
    output            [15:0]               adc_0_a_data                           ,//(o)
    output            [15:0]               adc_0_b_data                           ,//(o)
    output            [15:0]               adc_0_c_data                           ,//(o)
    output            [15:0]               adc_0_d_data                           ,//(o)
    output                                 adc_1_data_clk                         ,//(o)
    output            [15:0]               adc_1_a_data                           ,//(o)
    output            [15:0]               adc_1_b_data                           ,//(o)
    output            [15:0]               adc_1_c_data                           ,//(o)
    output            [15:0]               adc_1_d_data                           ,//(o)
    output                                 adc_2_data_clk                         ,//(o)
    output            [15:0]               adc_2_a_data                           ,//(o)
    output            [15:0]               adc_2_b_data                           ,//(o)
    output            [15:0]               adc_2_c_data                           ,//(o)
    output            [15:0]               adc_2_d_data                           ,//(o)
    output                                 adc_3_data_clk                         ,//(o)
    output            [15:0]               adc_3_a_data                           ,//(o)
    output            [15:0]               adc_3_b_data                           ,//(o)
    output            [15:0]               adc_3_c_data                           ,//(o)
    output            [15:0]               adc_3_d_data                           ,//(o)
    output            [31:0]               adc_0_pat_err_cnt                      ,//(o)
    output            [31:0]               adc_1_pat_err_cnt                      ,//(o)
    output            [31:0]               adc_2_pat_err_cnt                      ,//(o)
    output            [31:0]               adc_3_pat_err_cnt                      ,//(o)

    input                                  ADC_0_D0_A_P                           ,//(i)
    input                                  ADC_0_D0_A_N                           ,//(i)
    input                                  ADC_0_D1_A_P                           ,//(i)
    input                                  ADC_0_D1_A_N                           ,//(i)
    input                                  ADC_0_D0_B_P                           ,//(i)
    input                                  ADC_0_D0_B_N                           ,//(i)
    input                                  ADC_0_D1_B_P                           ,//(i)
    input                                  ADC_0_D1_B_N                           ,//(i)
    input                                  ADC_0_D0_C_P                           ,//(i)
    input                                  ADC_0_D0_C_N                           ,//(i)
    input                                  ADC_0_D1_C_P                           ,//(i)
    input                                  ADC_0_D1_C_N                           ,//(i)
    input                                  ADC_0_D0_D_P                           ,//(i)
    input                                  ADC_0_D0_D_N                           ,//(i)
    input                                  ADC_0_D1_D_P                           ,//(i)
    input                                  ADC_0_D1_D_N                           ,//(i)
    input                                  ADC_0_FCO_P                            ,//(i)
    input                                  ADC_0_FCO_N                            ,//(i)
    input                                  ADC_0_DCO_P                            ,//(i)
    input                                  ADC_0_DCO_N                            ,//(i)
    output                                 ADC_0_SPI_CLK                          ,//(o)
    inout                                  ADC_0_SPI_SDIO                         ,//(i)
    output                                 ADC_0_SPI_CSB                          ,//(o)
    output                                 ADC_0_SYNC                             ,//(o)
    output                                 ADC_0_PDWN                             ,//(o)

    input                                  ADC_1_D0_A_P                           ,//(i)
    input                                  ADC_1_D0_A_N                           ,//(i)
    input                                  ADC_1_D1_A_P                           ,//(i)
    input                                  ADC_1_D1_A_N                           ,//(i)
    input                                  ADC_1_D0_B_P                           ,//(i)
    input                                  ADC_1_D0_B_N                           ,//(i)
    input                                  ADC_1_D1_B_P                           ,//(i)
    input                                  ADC_1_D1_B_N                           ,//(i)
    input                                  ADC_1_D0_C_P                           ,//(i)
    input                                  ADC_1_D0_C_N                           ,//(i)
    input                                  ADC_1_D1_C_P                           ,//(i)
    input                                  ADC_1_D1_C_N                           ,//(i)
    input                                  ADC_1_D0_D_P                           ,//(i)
    input                                  ADC_1_D0_D_N                           ,//(i)
    input                                  ADC_1_D1_D_P                           ,//(i)
    input                                  ADC_1_D1_D_N                           ,//(i)
    input                                  ADC_1_FCO_P                            ,//(i)
    input                                  ADC_1_FCO_N                            ,//(i)
    input                                  ADC_1_DCO_P                            ,//(i)
    input                                  ADC_1_DCO_N                            ,//(i)
    output                                 ADC_1_SPI_CLK                          ,//(o)
    inout                                  ADC_1_SPI_SDIO                         ,//(i)
    output                                 ADC_1_SPI_CSB                          ,//(o)
    output                                 ADC_1_SYNC                             ,//(o)
    output                                 ADC_1_PDWN                             ,//(o)

    input                                  ADC_2_D0_A_P                           ,//(i)
    input                                  ADC_2_D0_A_N                           ,//(i)
    input                                  ADC_2_D1_A_P                           ,//(i)
    input                                  ADC_2_D1_A_N                           ,//(i)
    input                                  ADC_2_D0_B_P                           ,//(i)
    input                                  ADC_2_D0_B_N                           ,//(i)
    input                                  ADC_2_D1_B_P                           ,//(i)
    input                                  ADC_2_D1_B_N                           ,//(i)
    input                                  ADC_2_D0_C_P                           ,//(i)
    input                                  ADC_2_D0_C_N                           ,//(i)
    input                                  ADC_2_D1_C_P                           ,//(i)
    input                                  ADC_2_D1_C_N                           ,//(i)
    input                                  ADC_2_D0_D_P                           ,//(i)
    input                                  ADC_2_D0_D_N                           ,//(i)
    input                                  ADC_2_D1_D_P                           ,//(i)
    input                                  ADC_2_D1_D_N                           ,//(i)
    input                                  ADC_2_FCO_P                            ,//(i)
    input                                  ADC_2_FCO_N                            ,//(i)
    input                                  ADC_2_DCO_P                            ,//(i)
    input                                  ADC_2_DCO_N                            ,//(i)
    output                                 ADC_2_SPI_CLK                          ,//(o)
    inout                                  ADC_2_SPI_SDIO                         ,//(i)
    output                                 ADC_2_SPI_CSB                          ,//(o)
    output                                 ADC_2_SYNC                             ,//(o)
    output                                 ADC_2_PDWN                             ,//(o)

    input                                  ADC_3_D0_A_P                           ,//(i)
    input                                  ADC_3_D0_A_N                           ,//(i)
    input                                  ADC_3_D1_A_P                           ,//(i)
    input                                  ADC_3_D1_A_N                           ,//(i)
    input                                  ADC_3_D0_B_P                           ,//(i)
    input                                  ADC_3_D0_B_N                           ,//(i)
    input                                  ADC_3_D1_B_P                           ,//(i)
    input                                  ADC_3_D1_B_N                           ,//(i)
    input                                  ADC_3_D0_C_P                           ,//(i)
    input                                  ADC_3_D0_C_N                           ,//(i)
    input                                  ADC_3_D1_C_P                           ,//(i)
    input                                  ADC_3_D1_C_N                           ,//(i)
    input                                  ADC_3_D0_D_P                           ,//(i)
    input                                  ADC_3_D0_D_N                           ,//(i)
    input                                  ADC_3_D1_D_P                           ,//(i)
    input                                  ADC_3_D1_D_N                           ,//(i)
    input                                  ADC_3_FCO_P                            ,//(i)
    input                                  ADC_3_FCO_N                            ,//(i)
    input                                  ADC_3_DCO_P                            ,//(i)
    input                                  ADC_3_DCO_N                            ,//(i)
    output                                 ADC_3_SPI_CLK                          ,//(o)
    inout                                  ADC_3_SPI_SDIO                         ,//(i)
    output                                 ADC_3_SPI_CSB                          ,//(o)
    output                                 ADC_3_SYNC                             ,//(o)
    output                                 ADC_3_PDWN                              //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    //localparam                             IDLE     =    4'h00                    ;

    //---------------------------------------------------------------------       
    // Defination of Internal Signals       
    //---------------------------------------------------------------------       
    wire                                   idelay1_rdy                             ;
    wire                                   idelay2_rdy                             ;


    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------




// =================================================================================================
// RTL Body
// =================================================================================================
    (* IODELAY_GROUP = IODELAY_GROUP_NAME1 *)
    IDELAYCTRL #(
        .SIM_DEVICE("ULTRASCALE")  // Set the device version for simulation functionality (ULTRASCALE)
     )IDELAYCTRL_inst1(    
        .RDY   (idelay1_rdy   ), // 1-bit output: Ready output
        .REFCLK(clk_200m      ), // 1-bit input: Reference clock input
        .RST   (sys_rst       )  // 1-bit input: Active high reset input
    );
    
    (* IODELAY_GROUP = IODELAY_GROUP_NAME2 *)
    IDELAYCTRL #(
        .SIM_DEVICE("ULTRASCALE")  // Set the device version for simulation functionality (ULTRASCALE)
     )IDELAYCTRL_inst2(    
        .RDY   (idelay2_rdy   ), // 1-bit output: Ready output
        .REFCLK(clk_200m      ), // 1-bit input: Reference clock input
        .RST   (sys_rst       )  // 1-bit input: Active high reset input
    );

    // -------------------------------------------------------------------------
    // ad9253_allign_ctrl  Module Inst.
    // -------------------------------------------------------------------------
    ad9253_driver_v2 #(
        .IODELAY_GROUP_NAME      (IODELAY_GROUP_NAME1)
    )u0_ad9253_driver(       
        .sys_clk                 (sys_clk          ),//(i) 100m
        .sys_rst                 (sys_rst          ),//(i)
        .spi_wr_data_en          (spi_wr_data_en   ),//(i)
        .spi_wr_data             (spi_wr_data      ),//(i)
        .clk_200m                (clk_200m         ),//(i)
        // .clk                     (clk              ),//(i)
        // .clk_div                 (clk_div          ),//(i)
        .mmcm_clk_div            (clk_div          ),//(i)
                                                           
        .sync_in                 (sync_in          ),//(i)
        .idelay_rdy              (idelay1_rdy      ),//(i)
        .adc_0_data_clk          (adc_0_data_clk   ),//(o)
        .adc_0_a_data            (adc_0_a_data     ),//(o)
        .adc_0_b_data            (adc_0_b_data     ),//(o)
        .adc_0_c_data            (adc_0_c_data     ),//(o)
        .adc_0_d_data            (adc_0_d_data     ),//(o)
        .pat_err_cnt             (adc_0_pat_err_cnt),//(o)
                                                         
        .ADC_0_D0_A_P            (ADC_0_D0_A_P     ),//(i)
        .ADC_0_D0_A_N            (ADC_0_D0_A_N     ),//(i)
        .ADC_0_D1_A_P            (ADC_0_D1_A_P     ),//(i)
        .ADC_0_D1_A_N            (ADC_0_D1_A_N     ),//(i)
        .ADC_0_D0_B_P            (ADC_0_D0_B_P     ),//(i)
        .ADC_0_D0_B_N            (ADC_0_D0_B_N     ),//(i)
        .ADC_0_D1_B_P            (ADC_0_D1_B_P     ),//(i)
        .ADC_0_D1_B_N            (ADC_0_D1_B_N     ),//(i)
        .ADC_0_D0_C_P            (ADC_0_D0_C_P     ),//(i)
        .ADC_0_D0_C_N            (ADC_0_D0_C_N     ),//(i)
        .ADC_0_D1_C_P            (ADC_0_D1_C_P     ),//(i)
        .ADC_0_D1_C_N            (ADC_0_D1_C_N     ),//(i)
        .ADC_0_D0_D_P            (ADC_0_D0_D_P     ),//(i)
        .ADC_0_D0_D_N            (ADC_0_D0_D_N     ),//(i)
        .ADC_0_D1_D_P            (ADC_0_D1_D_P     ),//(i)
        .ADC_0_D1_D_N            (ADC_0_D1_D_N     ),//(i)
        .ADC_0_FCO_P             (ADC_0_FCO_P      ),//(i)
        .ADC_0_FCO_N             (ADC_0_FCO_N      ),//(i)
        .ADC_0_DCO_P             (ADC_0_DCO_P      ),//(i)
        .ADC_0_DCO_N             (ADC_0_DCO_N      ),//(i)
        .ADC_0_SPI_CLK           (ADC_0_SPI_CLK    ),//(o)
        .ADC_0_SPI_SDIO          (ADC_0_SPI_SDIO   ),//(i)
        .ADC_0_SPI_CSB           (ADC_0_SPI_CSB    ),//(o)
        .ADC_0_SYNC              (ADC_0_SYNC       ),//(o)
        .ADC_0_PDWN              (ADC_0_PDWN       ) //(o)
    );


    ad9253_driver_v2 #(
        .IODELAY_GROUP_NAME      (IODELAY_GROUP_NAME1)
    )u1_ad9253_driver(       
        .sys_clk                 (sys_clk          ),//(i) 100m
        .sys_rst                 (sys_rst          ),//(i)
        .spi_wr_data_en          (spi_wr_data_en   ),//(i)
        .spi_wr_data             (spi_wr_data      ),//(i)
        .clk_200m                (clk_200m         ),//(i)
        // .clk                     (clk              ),//(i)
        // .clk_div                 (clk_div          ),//(i)
        .mmcm_clk_div            (clk_div          ),//(i)
                                                           
        .sync_in                 (sync_in          ),//(i)
        .idelay_rdy              (idelay1_rdy      ),//(i)
        .adc_0_data_clk          (adc_1_data_clk   ),//(o)
        .adc_0_a_data            (adc_1_a_data     ),//(o)
        .adc_0_b_data            (adc_1_b_data     ),//(o)
        .adc_0_c_data            (adc_1_c_data     ),//(o)
        .adc_0_d_data            (adc_1_d_data     ),//(o)
        .pat_err_cnt             (adc_1_pat_err_cnt),//(o)
                                                      
        .ADC_0_D0_A_P            (ADC_1_D0_A_P     ),//(i)
        .ADC_0_D0_A_N            (ADC_1_D0_A_N     ),//(i)
        .ADC_0_D1_A_P            (ADC_1_D1_A_P     ),//(i)
        .ADC_0_D1_A_N            (ADC_1_D1_A_N     ),//(i)
        .ADC_0_D0_B_P            (ADC_1_D0_B_P     ),//(i)
        .ADC_0_D0_B_N            (ADC_1_D0_B_N     ),//(i)
        .ADC_0_D1_B_P            (ADC_1_D1_B_P     ),//(i)
        .ADC_0_D1_B_N            (ADC_1_D1_B_N     ),//(i)
        .ADC_0_D0_C_P            (ADC_1_D0_C_P     ),//(i)
        .ADC_0_D0_C_N            (ADC_1_D0_C_N     ),//(i)
        .ADC_0_D1_C_P            (ADC_1_D1_C_P     ),//(i)
        .ADC_0_D1_C_N            (ADC_1_D1_C_N     ),//(i)
        .ADC_0_D0_D_P            (ADC_1_D0_D_P     ),//(i)
        .ADC_0_D0_D_N            (ADC_1_D0_D_N     ),//(i)
        .ADC_0_D1_D_P            (ADC_1_D1_D_P     ),//(i)
        .ADC_0_D1_D_N            (ADC_1_D1_D_N     ),//(i)
        .ADC_0_FCO_P             (ADC_1_FCO_P      ),//(i)
        .ADC_0_FCO_N             (ADC_1_FCO_N      ),//(i)
        .ADC_0_DCO_P             (ADC_1_DCO_P      ),//(i)
        .ADC_0_DCO_N             (ADC_1_DCO_N      ),//(i)
        .ADC_0_SPI_CLK           (ADC_1_SPI_CLK    ),//(o)
        .ADC_0_SPI_SDIO          (ADC_1_SPI_SDIO   ),//(i)
        .ADC_0_SPI_CSB           (ADC_1_SPI_CSB    ),//(o)
        .ADC_0_SYNC              (ADC_1_SYNC       ),//(o)
        .ADC_0_PDWN              (ADC_1_PDWN       ) //(o)
    );


    ad9253_driver_v2 #(
        .IODELAY_GROUP_NAME      (IODELAY_GROUP_NAME2)
    )u2_ad9253_driver(       
        .sys_clk                 (sys_clk          ),//(i) 100m
        .sys_rst                 (sys_rst          ),//(i)
        .spi_wr_data_en          (spi_wr_data_en   ),//(i)
        .spi_wr_data             (spi_wr_data      ),//(i)
        .clk_200m                (clk_200m         ),//(i)
        // .clk                     (clk              ),//(i)
        // .clk_div                 (clk_div          ),//(i)
        .mmcm_clk_div            (clk_div          ),//(i)
                                                           
        .sync_in                 (sync_in          ),//(i)
        .idelay_rdy              (idelay2_rdy      ),//(i)
        .adc_0_data_clk          (adc_2_data_clk   ),//(o)
        .adc_0_a_data            (adc_2_a_data     ),//(o)
        .adc_0_b_data            (adc_2_b_data     ),//(o)
        .adc_0_c_data            (adc_2_c_data     ),//(o)
        .adc_0_d_data            (adc_2_d_data     ),//(o)
        .pat_err_cnt             (adc_2_pat_err_cnt),//(o)
                                                      
        .ADC_0_D0_A_P            (ADC_2_D0_A_P     ),//(i)
        .ADC_0_D0_A_N            (ADC_2_D0_A_N     ),//(i)
        .ADC_0_D1_A_P            (ADC_2_D1_A_P     ),//(i)
        .ADC_0_D1_A_N            (ADC_2_D1_A_N     ),//(i)
        .ADC_0_D0_B_P            (ADC_2_D0_B_P     ),//(i)
        .ADC_0_D0_B_N            (ADC_2_D0_B_N     ),//(i)
        .ADC_0_D1_B_P            (ADC_2_D1_B_P     ),//(i)
        .ADC_0_D1_B_N            (ADC_2_D1_B_N     ),//(i)
        .ADC_0_D0_C_P            (ADC_2_D0_C_P     ),//(i)
        .ADC_0_D0_C_N            (ADC_2_D0_C_N     ),//(i)
        .ADC_0_D1_C_P            (ADC_2_D1_C_P     ),//(i)
        .ADC_0_D1_C_N            (ADC_2_D1_C_N     ),//(i)
        .ADC_0_D0_D_P            (ADC_2_D0_D_P     ),//(i)
        .ADC_0_D0_D_N            (ADC_2_D0_D_N     ),//(i)
        .ADC_0_D1_D_P            (ADC_2_D1_D_P     ),//(i)
        .ADC_0_D1_D_N            (ADC_2_D1_D_N     ),//(i)
        .ADC_0_FCO_P             (ADC_2_FCO_P      ),//(i)
        .ADC_0_FCO_N             (ADC_2_FCO_N      ),//(i)
        .ADC_0_DCO_P             (ADC_2_DCO_P      ),//(i)
        .ADC_0_DCO_N             (ADC_2_DCO_N      ),//(i)
        .ADC_0_SPI_CLK           (ADC_2_SPI_CLK    ),//(o)
        .ADC_0_SPI_SDIO          (ADC_2_SPI_SDIO   ),//(i)
        .ADC_0_SPI_CSB           (ADC_2_SPI_CSB    ),//(o)
        .ADC_0_SYNC              (ADC_2_SYNC       ),//(o)
        .ADC_0_PDWN              (ADC_2_PDWN       ) //(o)
    );

    ad9253_driver_v2 #(
        .IODELAY_GROUP_NAME      (IODELAY_GROUP_NAME2)
    )u3_ad9253_driver(       
        .sys_clk                 (sys_clk          ),//(i) 100m
        .sys_rst                 (sys_rst          ),//(i)
        .spi_wr_data_en          (spi_wr_data_en   ),//(i)
        .spi_wr_data             (spi_wr_data      ),//(i)
        .clk_200m                (clk_200m         ),//(i)
        // .clk                     (clk              ),//(i)
        // .clk_div                 (clk_div          ),//(i)
        .mmcm_clk_div            (clk_div          ),//(i)
                                                           
        .sync_in                 (sync_in          ),//(i)
        .idelay_rdy              (idelay2_rdy      ),//(i)
        .adc_0_data_clk          (adc_3_data_clk   ),//(o)
        .adc_0_a_data            (adc_3_a_data     ),//(o)
        .adc_0_b_data            (adc_3_b_data     ),//(o)
        .adc_0_c_data            (adc_3_c_data     ),//(o)
        .adc_0_d_data            (adc_3_d_data     ),//(o)
        .pat_err_cnt             (adc_3_pat_err_cnt),//(o)
                                                     
        .ADC_0_D0_A_P            (ADC_3_D0_A_P     ),//(i)
        .ADC_0_D0_A_N            (ADC_3_D0_A_N     ),//(i)
        .ADC_0_D1_A_P            (ADC_3_D1_A_P     ),//(i)
        .ADC_0_D1_A_N            (ADC_3_D1_A_N     ),//(i)
        .ADC_0_D0_B_P            (ADC_3_D0_B_P     ),//(i)
        .ADC_0_D0_B_N            (ADC_3_D0_B_N     ),//(i)
        .ADC_0_D1_B_P            (ADC_3_D1_B_P     ),//(i)
        .ADC_0_D1_B_N            (ADC_3_D1_B_N     ),//(i)
        .ADC_0_D0_C_P            (ADC_3_D0_C_P     ),//(i)
        .ADC_0_D0_C_N            (ADC_3_D0_C_N     ),//(i)
        .ADC_0_D1_C_P            (ADC_3_D1_C_P     ),//(i)
        .ADC_0_D1_C_N            (ADC_3_D1_C_N     ),//(i)
        .ADC_0_D0_D_P            (ADC_3_D0_D_P     ),//(i)
        .ADC_0_D0_D_N            (ADC_3_D0_D_N     ),//(i)
        .ADC_0_D1_D_P            (ADC_3_D1_D_P     ),//(i)
        .ADC_0_D1_D_N            (ADC_3_D1_D_N     ),//(i)
        .ADC_0_FCO_P             (ADC_3_FCO_P      ),//(i)
        .ADC_0_FCO_N             (ADC_3_FCO_N      ),//(i)
        .ADC_0_DCO_P             (ADC_3_DCO_P      ),//(i)
        .ADC_0_DCO_N             (ADC_3_DCO_N      ),//(i)
        .ADC_0_SPI_CLK           (ADC_3_SPI_CLK    ),//(o)
        .ADC_0_SPI_SDIO          (ADC_3_SPI_SDIO   ),//(i)
        .ADC_0_SPI_CSB           (ADC_3_SPI_CSB    ),//(o)
        .ADC_0_SYNC              (ADC_3_SYNC       ),//(o)
        .ADC_0_PDWN              (ADC_3_PDWN       ) //(o)
    );







endmodule





















































