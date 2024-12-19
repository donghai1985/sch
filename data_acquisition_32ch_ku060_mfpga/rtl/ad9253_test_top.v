module ad9253_test_top #(
    parameter                               TEST        =      16           
)(
    input                                   FPGA_RESET                     ,//(i) 
    input                                   FPGA_MASTER_CLOCK_P            ,//(i)
    input                                   FPGA_MASTER_CLOCK_N            ,//(i)
                    
    //adc1                    
    input                                   ADC_1_4_D0_A_P                 ,//(i)
    input                                   ADC_1_4_D0_A_N                 ,//(i)
    input                                   ADC_1_4_D1_A_P                 ,//(i)
    input                                   ADC_1_4_D1_A_N                 ,//(i)
    input                                   ADC_1_4_D0_B_P                 ,//(i)
    input                                   ADC_1_4_D0_B_N                 ,//(i)
    input                                   ADC_1_4_D1_B_P                 ,//(i)
    input                                   ADC_1_4_D1_B_N                 ,//(i)
    input                                   ADC_1_4_D0_C_P                 ,//(i)
    input                                   ADC_1_4_D0_C_N                 ,//(i)
    input                                   ADC_1_4_D1_C_P                 ,//(i)
    input                                   ADC_1_4_D1_C_N                 ,//(i)
    input                                   ADC_1_4_D0_D_P                 ,//(i)
    input                                   ADC_1_4_D0_D_N                 ,//(i)
    input                                   ADC_1_4_D1_D_P                 ,//(i)
    input                                   ADC_1_4_D1_D_N                 ,//(i)
    input                                   ADC_1_4_FCO_P                  ,//(i)
    input                                   ADC_1_4_FCO_N                  ,//(i)
    input                                   ADC_1_4_DCO_P                  ,//(i)
    input                                   ADC_1_4_DCO_N                  ,//(i)
    output                                  ADC_1_4_SPI_CLK                ,//(o)
    inout                                   ADC_1_4_SPI_SDIO               ,//(i)
    output                                  ADC_1_4_SPI_CSB                ,//(o)
    output                                  ADC_1_4_SYNC                   ,//(o)
    output                                  ADC_1_4_PDWN                   ,//(o)
    //adc2                    
    input                                   ADC_5_8_D0_A_P                 ,//(i)
    input                                   ADC_5_8_D0_A_N                 ,//(i)
    input                                   ADC_5_8_D1_A_P                 ,//(i)
    input                                   ADC_5_8_D1_A_N                 ,//(i)
    input                                   ADC_5_8_D0_B_P                 ,//(i)
    input                                   ADC_5_8_D0_B_N                 ,//(i)
    input                                   ADC_5_8_D1_B_P                 ,//(i)
    input                                   ADC_5_8_D1_B_N                 ,//(i)
    input                                   ADC_5_8_D0_C_P                 ,//(i)
    input                                   ADC_5_8_D0_C_N                 ,//(i)
    input                                   ADC_5_8_D1_C_P                 ,//(i)
    input                                   ADC_5_8_D1_C_N                 ,//(i)
    input                                   ADC_5_8_D0_D_P                 ,//(i)
    input                                   ADC_5_8_D0_D_N                 ,//(i)
    input                                   ADC_5_8_D1_D_P                 ,//(i)
    input                                   ADC_5_8_D1_D_N                 ,//(i)
    input                                   ADC_5_8_FCO_P                  ,//(i)
    input                                   ADC_5_8_FCO_N                  ,//(i)
    input                                   ADC_5_8_DCO_P                  ,//(i)
    input                                   ADC_5_8_DCO_N                  ,//(i)
    output                                  ADC_5_8_SPI_CLK                ,//(o)
    inout                                   ADC_5_8_SPI_SDIO               ,//(i)
    output                                  ADC_5_8_SPI_CSB                ,//(o)
    output                                  ADC_5_8_SYNC                   ,//(o)
    output                                  ADC_5_8_PDWN                   ,//(o)
    //adc3                    
    input                                   ADC_9_12_D0_A_P                 ,//(i)
    input                                   ADC_9_12_D0_A_N                 ,//(i)
    input                                   ADC_9_12_D1_A_P                 ,//(i)
    input                                   ADC_9_12_D1_A_N                 ,//(i)
    input                                   ADC_9_12_D0_B_P                 ,//(i)
    input                                   ADC_9_12_D0_B_N                 ,//(i)
    input                                   ADC_9_12_D1_B_P                 ,//(i)
    input                                   ADC_9_12_D1_B_N                 ,//(i)
    input                                   ADC_9_12_D0_C_P                 ,//(i)
    input                                   ADC_9_12_D0_C_N                 ,//(i)
    input                                   ADC_9_12_D1_C_P                 ,//(i)
    input                                   ADC_9_12_D1_C_N                 ,//(i)
    input                                   ADC_9_12_D0_D_P                 ,//(i)
    input                                   ADC_9_12_D0_D_N                 ,//(i)
    input                                   ADC_9_12_D1_D_P                 ,//(i)
    input                                   ADC_9_12_D1_D_N                 ,//(i)
    input                                   ADC_9_12_FCO_P                  ,//(i)
    input                                   ADC_9_12_FCO_N                  ,//(i)
    input                                   ADC_9_12_DCO_P                  ,//(i)
    input                                   ADC_9_12_DCO_N                  ,//(i)
    output                                  ADC_9_12_SPI_CLK                ,//(o)
    inout                                   ADC_9_12_SPI_SDIO               ,//(i)
    output                                  ADC_9_12_SPI_CSB                ,//(o)
    output                                  ADC_9_12_SYNC                   ,//(o)
    output                                  ADC_9_12_PDWN                   ,//(o)
    //adc4                    
    input                                   ADC_13_16_D0_A_P                ,//(i)
    input                                   ADC_13_16_D0_A_N                ,//(i)
    input                                   ADC_13_16_D1_A_P                ,//(i)
    input                                   ADC_13_16_D1_A_N                ,//(i)
    input                                   ADC_13_16_D0_B_P                ,//(i)
    input                                   ADC_13_16_D0_B_N                ,//(i)
    input                                   ADC_13_16_D1_B_P                ,//(i)
    input                                   ADC_13_16_D1_B_N                ,//(i)
    input                                   ADC_13_16_D0_C_P                ,//(i)
    input                                   ADC_13_16_D0_C_N                ,//(i)
    input                                   ADC_13_16_D1_C_P                ,//(i)
    input                                   ADC_13_16_D1_C_N                ,//(i)
    input                                   ADC_13_16_D0_D_P                ,//(i)
    input                                   ADC_13_16_D0_D_N                ,//(i)
    input                                   ADC_13_16_D1_D_P                ,//(i)
    input                                   ADC_13_16_D1_D_N                ,//(i)
    input                                   ADC_13_16_FCO_P                 ,//(i)
    input                                   ADC_13_16_FCO_N                 ,//(i)
    input                                   ADC_13_16_DCO_P                 ,//(i)
    input                                   ADC_13_16_DCO_N                 ,//(i)
    output                                  ADC_13_16_SPI_CLK               ,//(o)
    inout                                   ADC_13_16_SPI_SDIO              ,//(i)
    output                                  ADC_13_16_SPI_CSB               ,//(o)
    output                                  ADC_13_16_SYNC                  ,//(o)
    output                                  ADC_13_16_PDWN                  ,//(o)
    //adc5                    
    input                                   ADC_17_20_D0_A_P                ,//(i)
    input                                   ADC_17_20_D0_A_N                ,//(i)
    input                                   ADC_17_20_D1_A_P                ,//(i)
    input                                   ADC_17_20_D1_A_N                ,//(i)
    input                                   ADC_17_20_D0_B_P                ,//(i)
    input                                   ADC_17_20_D0_B_N                ,//(i)
    input                                   ADC_17_20_D1_B_P                ,//(i)
    input                                   ADC_17_20_D1_B_N                ,//(i)
    input                                   ADC_17_20_D0_C_P                ,//(i)
    input                                   ADC_17_20_D0_C_N                ,//(i)
    input                                   ADC_17_20_D1_C_P                ,//(i)
    input                                   ADC_17_20_D1_C_N                ,//(i)
    input                                   ADC_17_20_D0_D_P                ,//(i)
    input                                   ADC_17_20_D0_D_N                ,//(i)
    input                                   ADC_17_20_D1_D_P                ,//(i)
    input                                   ADC_17_20_D1_D_N                ,//(i)
    input                                   ADC_17_20_FCO_P                 ,//(i)
    input                                   ADC_17_20_FCO_N                 ,//(i)
    input                                   ADC_17_20_DCO_P                 ,//(i)
    input                                   ADC_17_20_DCO_N                 ,//(i)
    output                                  ADC_17_20_SPI_CLK               ,//(o)
    inout                                   ADC_17_20_SPI_SDIO              ,//(i)
    output                                  ADC_17_20_SPI_CSB               ,//(o)
    output                                  ADC_17_20_SYNC                  ,//(o)
    output                                  ADC_17_20_PDWN                  ,//(o)
    //adc6                    
    input                                   ADC_21_24_D0_A_P                ,//(i)
    input                                   ADC_21_24_D0_A_N                ,//(i)
    input                                   ADC_21_24_D1_A_P                ,//(i)
    input                                   ADC_21_24_D1_A_N                ,//(i)
    input                                   ADC_21_24_D0_B_P                ,//(i)
    input                                   ADC_21_24_D0_B_N                ,//(i)
    input                                   ADC_21_24_D1_B_P                ,//(i)
    input                                   ADC_21_24_D1_B_N                ,//(i)
    input                                   ADC_21_24_D0_C_P                ,//(i)
    input                                   ADC_21_24_D0_C_N                ,//(i)
    input                                   ADC_21_24_D1_C_P                ,//(i)
    input                                   ADC_21_24_D1_C_N                ,//(i)
    input                                   ADC_21_24_D0_D_P                ,//(i)
    input                                   ADC_21_24_D0_D_N                ,//(i)
    input                                   ADC_21_24_D1_D_P                ,//(i)
    input                                   ADC_21_24_D1_D_N                ,//(i)
    input                                   ADC_21_24_FCO_P                 ,//(i)
    input                                   ADC_21_24_FCO_N                 ,//(i)
    input                                   ADC_21_24_DCO_P                 ,//(i)
    input                                   ADC_21_24_DCO_N                 ,//(i)
    output                                  ADC_21_24_SPI_CLK               ,//(o)
    inout                                   ADC_21_24_SPI_SDIO              ,//(i)
    output                                  ADC_21_24_SPI_CSB               ,//(o)
    output                                  ADC_21_24_SYNC                  ,//(o)
    output                                  ADC_21_24_PDWN                  ,//(o)
    //adc7                    
    input                                   ADC_25_28_D0_A_P                ,//(i)
    input                                   ADC_25_28_D0_A_N                ,//(i)
    input                                   ADC_25_28_D1_A_P                ,//(i)
    input                                   ADC_25_28_D1_A_N                ,//(i)
    input                                   ADC_25_28_D0_B_P                ,//(i)
    input                                   ADC_25_28_D0_B_N                ,//(i)
    input                                   ADC_25_28_D1_B_P                ,//(i)
    input                                   ADC_25_28_D1_B_N                ,//(i)
    input                                   ADC_25_28_D0_C_P                ,//(i)
    input                                   ADC_25_28_D0_C_N                ,//(i)
    input                                   ADC_25_28_D1_C_P                ,//(i)
    input                                   ADC_25_28_D1_C_N                ,//(i)
    input                                   ADC_25_28_D0_D_P                ,//(i)
    input                                   ADC_25_28_D0_D_N                ,//(i)
    input                                   ADC_25_28_D1_D_P                ,//(i)
    input                                   ADC_25_28_D1_D_N                ,//(i)
    input                                   ADC_25_28_FCO_P                 ,//(i)
    input                                   ADC_25_28_FCO_N                 ,//(i)
    input                                   ADC_25_28_DCO_P                 ,//(i)
    input                                   ADC_25_28_DCO_N                 ,//(i)
    output                                  ADC_25_28_SPI_CLK               ,//(o)
    inout                                   ADC_25_28_SPI_SDIO              ,//(i)
    output                                  ADC_25_28_SPI_CSB               ,//(o)
    output                                  ADC_25_28_SYNC                  ,//(o)
    output                                  ADC_25_28_PDWN                  ,//(o)
    //adc8                    
    input                                   ADC_29_32_D0_A_P                ,//(i)
    input                                   ADC_29_32_D0_A_N                ,//(i)
    input                                   ADC_29_32_D1_A_P                ,//(i)
    input                                   ADC_29_32_D1_A_N                ,//(i)
    input                                   ADC_29_32_D0_B_P                ,//(i)
    input                                   ADC_29_32_D0_B_N                ,//(i)
    input                                   ADC_29_32_D1_B_P                ,//(i)
    input                                   ADC_29_32_D1_B_N                ,//(i)
    input                                   ADC_29_32_D0_C_P                ,//(i)
    input                                   ADC_29_32_D0_C_N                ,//(i)
    input                                   ADC_29_32_D1_C_P                ,//(i)
    input                                   ADC_29_32_D1_C_N                ,//(i)
    input                                   ADC_29_32_D0_D_P                ,//(i)
    input                                   ADC_29_32_D0_D_N                ,//(i)
    input                                   ADC_29_32_D1_D_P                ,//(i)
    input                                   ADC_29_32_D1_D_N                ,//(i)
    input                                   ADC_29_32_FCO_P                 ,//(i)
    input                                   ADC_29_32_FCO_N                 ,//(i)
    input                                   ADC_29_32_DCO_P                 ,//(i)
    input                                   ADC_29_32_DCO_N                 ,//(i)
    output                                  ADC_29_32_SPI_CLK               ,//(o)
    inout                                   ADC_29_32_SPI_SDIO              ,//(i)
    output                                  ADC_29_32_SPI_CSB               ,//(o)
    output                                  ADC_29_32_SYNC                  ,//(o)
    output                                  ADC_29_32_PDWN                  ,//(o)

    //AD5674              
    output                                  AD5674_1_SPI_CLK                ,//(o)
    output                                  AD5674_1_SPI_CS                 ,//(o)
    input                                   AD5674_1_SPI_SDO                ,//(i)
    output                                  AD5674_1_SPI_SDI                ,//(o)
    output                                  AD5674_1_SPI_RESET              ,//(o)
    output                                  AD5674_1_SPI_LDAC               ,//(o)
    output                                  AD5674_2_SPI_CLK                ,//(o)
    output                                  AD5674_2_SPI_CS                 ,//(o)
    input                                   AD5674_2_SPI_SDO                ,//(i)
    output                                  AD5674_2_SPI_SDI                ,//(o)
    output                                  AD5674_2_SPI_RESET              ,//(o)
    output                                  AD5674_2_SPI_LDAC               ,//(o)
    //MAX5216 
    output                                  MAX5216_CS                     ,//(o) 
    output                                  MAX5216_CLR                    ,//(o) 
    output                                  MAX5216_DIN                    ,//(o) 
    output                                  MAX5216_CLK                    ,//(o) 
    //ad5592
    output                                  AD5592_1_SPI_CS_B               ,//(o)
    output                                  AD5592_1_SPI_CLK                ,//(o)
    output                                  AD5592_1_SPI_MOSI               ,//(o)
    input                                   AD5592_1_SPI_MISO               ,//(i)
    output                                  HV_EN_LS                        ,//(o)
    //HMC7044                                                                   
    output                                  HMC7044_SYNC                    ,//(o)
    output                                  HMC7044_1_RESET_LS              ,//(o)
    output                                  HMC7044_1_SLEN_LS               ,//(o)
    output                                  HMC7044_1_SCLK_LS               ,//(o)
    inout                                   HMC7044_1_SDATA_LS              ,//(i)
    input                                   HMC7044_1_GPIO1_LS              ,//(i)
    input                                   HMC7044_1_GPIO2_LS              ,//(i)
    
    input      [12:0]                       POW_GOOD                         //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                      FPGA_MASTER_CLOCK              ;
    wire                                      pll_locked                     ;
    wire                                      clk_100m                       ;
    wire                                      clk_200m                       ;
    wire                                      clk_32m                        ;
    wire                                      clk_256m                       ;
    reg                                       rst                            ;
    reg        [15:0]                         rst_cnt                        ;
    wire                                      hmc7044_config_ok              ;

                                            wire                  adc_1_4_data_clk;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_1_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_2_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_3_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_4_data;
                                            wire                  adc_5_8_data_clk;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_5_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_6_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_7_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_8_data;
                                            wire                  adc_9_12_data_clk;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_9_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_10_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_11_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_12_data;
                                            wire                  adc_13_16_data_clk;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_13_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_14_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_15_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_16_data;
                                            wire                  adc_17_20_data_clk;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_17_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_18_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_19_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_20_data;
                                            wire                  adc_21_24_data_clk;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_21_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_22_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_23_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_24_data;
                                            wire                  adc_25_28_data_clk;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_25_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_26_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_27_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_28_data;
                                            wire                  adc_29_32_data_clk;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_29_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_30_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_31_data;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire    [15:0]        adc_32_data;

    wire                                  ad5674_trig                    ;
    wire        [4:0]                     ad5674_ch                      ;
    wire        [11:0]                    ad5674_din                     ;

    wire                                  ad5674_cm_trig                 ;
    wire        [11:0]                    ad5674_cm_din                  ;

    wire        [23:0]                    ad5674_dout1                   ;
    wire        [23:0]                    ad5674_dout2                   ;
    wire                                  spi_wr_data_en                 ;
    wire        [23:0]                    spi_wr_data                    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    //assign            m_axis_tkeep   =     {(DATA_WD/8){1'b1}}             ;

// =================================================================================================
// RTL Body
// =================================================================================================

    IBUFDS FPGA_MASTER_inst(
        .O(FPGA_MASTER_CLOCK   ),   // Buffer output
        .I(FPGA_MASTER_CLOCK_P ),   // Diff_p buffer input (connect directly to top-level port)
        .IB(FPGA_MASTER_CLOCK_N)    // Diff_n buffer input (connect directly to top-level port)
    );

    pll pll_inst(
        .clk_out1(clk_100m), 
        .clk_out2(clk_200m),
        .clk_out3(        ),
        .clk_out4(        ),
        .reset (FPGA_RESET), 
        .locked(pll_locked), 
        .clk_in1(FPGA_MASTER_CLOCK)
    );

    pll2 pll_inst1(
        .clk_out1(clk_32m ), 
        .clk_out2(clk_256m),
        .reset(~pll_locked), 
        .locked(          ), 
        .clk_in1(clk_100m )
    );

    always @(posedge clk_100m or negedge pll_locked) begin
        if(!pll_locked) begin
            rst         <= 'd1;
            rst_cnt     <= 'd0;
        //end else if(rst_cnt == 'd2000) begin        //100us
        end else if(&rst_cnt) begin        //100us
            rst_cnt     <= rst_cnt;
            rst         <= 'd0;
        end else begin
            rst         <= 'd1;
            rst_cnt     <= rst_cnt + 1'b1;
        end
    end


    // -------------------------------------------------------------------------
    // hmc7044 Module Inst.
    // -------------------------------------------------------------------------
    //低VCO频率范围:2150M~2880M//高VCO频率范围:2650M~3550M//保证频率范围 :2400M~3200M
    hmc7044_config #( 
        .CLKOUT0_DIV      (12'd100                 ), 
        .CLKOUT1_DIV      (12'd100                 ),
        .CLKOUT2_DIV      (12'd32                  ),//
        .CLKOUT3_DIV      (12'd32                  ),//
        .CLKOUT4_DIV      (12'd100                 ),
        .CLKOUT5_DIV      (12'd100                 ),
        .CLKOUT6_DIV      (12'd100                 ),
        .CLKOUT7_DIV      (12'd100                 ),
        .CLKOUT8_DIV      (12'd100                 ),
        .CLKOUT9_DIV      (12'd100                 ),
        .CLKOUT10_DIV     (12'd100                 ),
        .CLKOUT11_DIV     (12'd100                 ),
        .CLKOUT12_DIV     (12'd100                 ),
        .CLKOUT13_DIV     (12'd100                 ),
        .VCO_L_H          (2'b01                  ),//2'b01:high VCO 2'b10:low VCO
        .CHANNEL_EN       (8'b1100_1111           ),
        .PLL2_R2          (12'd1                  ),
        .PLL2_N2          (12'd32                 ),
        .CLKEN            (14'b110000_11111111    )
    )hmc7044_config_inst1(                  
        .clk              (clk_100m               ),
        .rst              (rst                    ),
        .sync_in          (1'b0                   ),
        .HMC7044_SEN      (HMC7044_1_SLEN_LS      ),
        .HMC7044_SCLK     (HMC7044_1_SCLK_LS      ),
        .HMC7044_SDATA    (HMC7044_1_SDATA_LS     ),
        .HMC7044_RESET    (HMC7044_1_RESET_LS     ),
        .HMC7044_SYNC     (                       ),
        .HMC7044_GPIO1    (HMC7044_1_GPIO1_LS     ),
        .HMC7044_GPIO2    (HMC7044_1_GPIO2_LS     ),
        .HMC7044_GPIO3    (HMC7044_1_GPIO3_LS     ),
        .HMC7044_GPIO4    (HMC7044_1_GPIO4_LS     ),
        .hmc7044_config_ok(hmc7044_config_ok      )
     );

    // -------------------------------------------------------------------------
    // ad9253_4ch_driver Module Inst.
    // -------------------------------------------------------------------------
    // -------------------------------------------------------------------------
    // ad9253_4ch_driver Module Inst.
    // -------------------------------------------------------------------------
    ad9253_4ch_driver_v2 #(
         .IODELAY_GROUP_NAME1          ("delay1"                       ),
         .IODELAY_GROUP_NAME2          ("delay2"                       )  
    )u0_ad9253_4ch_driver(       
        .sys_clk                       (clk_100m                       ),//(i) 
        .sys_rst                       (~hmc7044_config_ok             ),//(i)
        .spi_wr_data_en                (spi_wr_data_en                 ),//(i)
        .spi_wr_data                   (spi_wr_data                    ),//(i)
        .clk_200m                      (clk_200m                       ),//(i)
        .clk                           (clk_256m                       ),//(i)
        .clk_div                       (clk_32m                        ),//(i)
    
        .sync_in                       (1'b0                           ),//(i)
        .adc_0_data_clk                (adc_1_4_data_clk               ),//(o)
        .adc_0_a_data                  (adc_1_data                     ),//(o)
        .adc_0_b_data                  (adc_2_data                     ),//(o)
        .adc_0_c_data                  (adc_3_data                     ),//(o)
        .adc_0_d_data                  (adc_4_data                     ),//(o)
        .adc_1_data_clk                (adc_5_8_data_clk               ),//(o)
        .adc_1_a_data                  (adc_5_data                     ),//(o)
        .adc_1_b_data                  (adc_6_data                     ),//(o)
        .adc_1_c_data                  (adc_7_data                     ),//(o)
        .adc_1_d_data                  (adc_8_data                     ),//(o)
        .adc_2_data_clk                (adc_9_12_data_clk              ),//(o)
        .adc_2_a_data                  (adc_9_data                     ),//(o)
        .adc_2_b_data                  (adc_10_data                    ),//(o)
        .adc_2_c_data                  (adc_11_data                    ),//(o)
        .adc_2_d_data                  (adc_12_data                    ),//(o)
        .adc_3_data_clk                (adc_13_16_data_clk             ),//(o)
        .adc_3_a_data                  (adc_13_data                    ),//(o)
        .adc_3_b_data                  (adc_14_data                    ),//(o)
        .adc_3_c_data                  (adc_15_data                    ),//(o)
        .adc_3_d_data                  (adc_16_data                    ),//(o)
    
        .ADC_0_D0_A_P                  (ADC_1_4_D0_A_P                 ),//(i)
        .ADC_0_D0_A_N                  (ADC_1_4_D0_A_N                 ),//(i)
        .ADC_0_D1_A_P                  (ADC_1_4_D1_A_P                 ),//(i)
        .ADC_0_D1_A_N                  (ADC_1_4_D1_A_N                 ),//(i)
        .ADC_0_D0_B_P                  (ADC_1_4_D0_B_P                 ),//(i)
        .ADC_0_D0_B_N                  (ADC_1_4_D0_B_N                 ),//(i)
        .ADC_0_D1_B_P                  (ADC_1_4_D1_B_P                 ),//(i)
        .ADC_0_D1_B_N                  (ADC_1_4_D1_B_N                 ),//(i)
        .ADC_0_D0_C_P                  (ADC_1_4_D0_C_P                 ),//(i)
        .ADC_0_D0_C_N                  (ADC_1_4_D0_C_N                 ),//(i)
        .ADC_0_D1_C_P                  (ADC_1_4_D1_C_P                 ),//(i)
        .ADC_0_D1_C_N                  (ADC_1_4_D1_C_N                 ),//(i)
        .ADC_0_D0_D_P                  (ADC_1_4_D0_D_P                 ),//(i)
        .ADC_0_D0_D_N                  (ADC_1_4_D0_D_N                 ),//(i)
        .ADC_0_D1_D_P                  (ADC_1_4_D1_D_P                 ),//(i)
        .ADC_0_D1_D_N                  (ADC_1_4_D1_D_N                 ),//(i)
        .ADC_0_FCO_P                   (ADC_1_4_FCO_P                  ),//(i)
        .ADC_0_FCO_N                   (ADC_1_4_FCO_N                  ),//(i)
        .ADC_0_DCO_P                   (ADC_1_4_DCO_P                  ),//(i)
        .ADC_0_DCO_N                   (ADC_1_4_DCO_N                  ),//(i)
        .ADC_0_SPI_CLK                 (ADC_1_4_SPI_CLK                ),//(o)
        .ADC_0_SPI_SDIO                (ADC_1_4_SPI_SDIO               ),//(i)
        .ADC_0_SPI_CSB                 (ADC_1_4_SPI_CSB                ),//(o)
        .ADC_0_SYNC                    (ADC_1_4_SYNC                   ),//(o)
        .ADC_0_PDWN                    (ADC_1_4_PDWN                   ),//(o)
    
        .ADC_1_D0_A_P                  (ADC_5_8_D0_A_P                 ),//(i)
        .ADC_1_D0_A_N                  (ADC_5_8_D0_A_N                 ),//(i)
        .ADC_1_D1_A_P                  (ADC_5_8_D1_A_P                 ),//(i)
        .ADC_1_D1_A_N                  (ADC_5_8_D1_A_N                 ),//(i)
        .ADC_1_D0_B_P                  (ADC_5_8_D0_B_P                 ),//(i)
        .ADC_1_D0_B_N                  (ADC_5_8_D0_B_N                 ),//(i)
        .ADC_1_D1_B_P                  (ADC_5_8_D1_B_P                 ),//(i)
        .ADC_1_D1_B_N                  (ADC_5_8_D1_B_N                 ),//(i)
        .ADC_1_D0_C_P                  (ADC_5_8_D0_C_P                 ),//(i)
        .ADC_1_D0_C_N                  (ADC_5_8_D0_C_N                 ),//(i)
        .ADC_1_D1_C_P                  (ADC_5_8_D1_C_P                 ),//(i)
        .ADC_1_D1_C_N                  (ADC_5_8_D1_C_N                 ),//(i)
        .ADC_1_D0_D_P                  (ADC_5_8_D0_D_P                 ),//(i)
        .ADC_1_D0_D_N                  (ADC_5_8_D0_D_N                 ),//(i)
        .ADC_1_D1_D_P                  (ADC_5_8_D1_D_P                 ),//(i)
        .ADC_1_D1_D_N                  (ADC_5_8_D1_D_N                 ),//(i)
        .ADC_1_FCO_P                   (ADC_5_8_FCO_P                  ),//(i)
        .ADC_1_FCO_N                   (ADC_5_8_FCO_N                  ),//(i)
        .ADC_1_DCO_P                   (ADC_5_8_DCO_P                  ),//(i)
        .ADC_1_DCO_N                   (ADC_5_8_DCO_N                  ),//(i)
        .ADC_1_SPI_CLK                 (ADC_5_8_SPI_CLK                ),//(o)
        .ADC_1_SPI_SDIO                (ADC_5_8_SPI_SDIO               ),//(i)
        .ADC_1_SPI_CSB                 (ADC_5_8_SPI_CSB                ),//(o)
        .ADC_1_SYNC                    (ADC_5_8_SYNC                   ),//(o)
        .ADC_1_PDWN                    (ADC_5_8_PDWN                   ),//(o)
    
        .ADC_2_D0_A_P                  (ADC_9_12_D0_A_P                ),//(i)
        .ADC_2_D0_A_N                  (ADC_9_12_D0_A_N                ),//(i)
        .ADC_2_D1_A_P                  (ADC_9_12_D1_A_P                ),//(i)
        .ADC_2_D1_A_N                  (ADC_9_12_D1_A_N                ),//(i)
        .ADC_2_D0_B_P                  (ADC_9_12_D0_B_P                ),//(i)
        .ADC_2_D0_B_N                  (ADC_9_12_D0_B_N                ),//(i)
        .ADC_2_D1_B_P                  (ADC_9_12_D1_B_P                ),//(i)
        .ADC_2_D1_B_N                  (ADC_9_12_D1_B_N                ),//(i)
        .ADC_2_D0_C_P                  (ADC_9_12_D0_C_P                ),//(i)
        .ADC_2_D0_C_N                  (ADC_9_12_D0_C_N                ),//(i)
        .ADC_2_D1_C_P                  (ADC_9_12_D1_C_P                ),//(i)
        .ADC_2_D1_C_N                  (ADC_9_12_D1_C_N                ),//(i)
        .ADC_2_D0_D_P                  (ADC_9_12_D0_D_P                ),//(i)
        .ADC_2_D0_D_N                  (ADC_9_12_D0_D_N                ),//(i)
        .ADC_2_D1_D_P                  (ADC_9_12_D1_D_P                ),//(i)
        .ADC_2_D1_D_N                  (ADC_9_12_D1_D_N                ),//(i)
        .ADC_2_FCO_P                   (ADC_9_12_FCO_P                 ),//(i)
        .ADC_2_FCO_N                   (ADC_9_12_FCO_N                 ),//(i)
        .ADC_2_DCO_P                   (ADC_9_12_DCO_P                 ),//(i)
        .ADC_2_DCO_N                   (ADC_9_12_DCO_N                 ),//(i)
        .ADC_2_SPI_CLK                 (ADC_9_12_SPI_CLK               ),//(o)
        .ADC_2_SPI_SDIO                (ADC_9_12_SPI_SDIO              ),//(i)
        .ADC_2_SPI_CSB                 (ADC_9_12_SPI_CSB               ),//(o)
        .ADC_2_SYNC                    (ADC_9_12_SYNC                  ),//(o)
        .ADC_2_PDWN                    (ADC_9_12_PDWN                  ),//(o)
    
        .ADC_3_D0_A_P                  (ADC_13_16_D0_A_P               ),//(i)
        .ADC_3_D0_A_N                  (ADC_13_16_D0_A_N               ),//(i)
        .ADC_3_D1_A_P                  (ADC_13_16_D1_A_P               ),//(i)
        .ADC_3_D1_A_N                  (ADC_13_16_D1_A_N               ),//(i)
        .ADC_3_D0_B_P                  (ADC_13_16_D0_B_P               ),//(i)
        .ADC_3_D0_B_N                  (ADC_13_16_D0_B_N               ),//(i)
        .ADC_3_D1_B_P                  (ADC_13_16_D1_B_P               ),//(i)
        .ADC_3_D1_B_N                  (ADC_13_16_D1_B_N               ),//(i)
        .ADC_3_D0_C_P                  (ADC_13_16_D0_C_P               ),//(i)
        .ADC_3_D0_C_N                  (ADC_13_16_D0_C_N               ),//(i)
        .ADC_3_D1_C_P                  (ADC_13_16_D1_C_P               ),//(i)
        .ADC_3_D1_C_N                  (ADC_13_16_D1_C_N               ),//(i)
        .ADC_3_D0_D_P                  (ADC_13_16_D0_D_P               ),//(i)
        .ADC_3_D0_D_N                  (ADC_13_16_D0_D_N               ),//(i)
        .ADC_3_D1_D_P                  (ADC_13_16_D1_D_P               ),//(i)
        .ADC_3_D1_D_N                  (ADC_13_16_D1_D_N               ),//(i)
        .ADC_3_FCO_P                   (ADC_13_16_FCO_P                ),//(i)
        .ADC_3_FCO_N                   (ADC_13_16_FCO_N                ),//(i)
        .ADC_3_DCO_P                   (ADC_13_16_DCO_P                ),//(i)
        .ADC_3_DCO_N                   (ADC_13_16_DCO_N                ),//(i)
        .ADC_3_SPI_CLK                 (ADC_13_16_SPI_CLK              ),//(o)
        .ADC_3_SPI_SDIO                (ADC_13_16_SPI_SDIO             ),//(i)
        .ADC_3_SPI_CSB                 (ADC_13_16_SPI_CSB              ),//(o)
        .ADC_3_SYNC                    (ADC_13_16_SYNC                 ),//(o)
        .ADC_3_PDWN                    (ADC_13_16_PDWN                 ) //(o)
    );


    ad9253_4ch_driver_v2 #(
         .IODELAY_GROUP_NAME1          ("delay3"                       ),
         .IODELAY_GROUP_NAME2          ("delay4"                       )  
    )u1_ad9253_4ch_driver(       
        .sys_clk                       (clk_100m                       ),//(i) 
        .sys_rst                       (~hmc7044_config_ok             ),//(i)
        .spi_wr_data_en                (spi_wr_data_en                 ),//(i)
        .spi_wr_data                   (spi_wr_data                    ),//(i)
        .clk_200m                      (clk_200m                       ),//(i)
        .clk                           (clk_256m                       ),//(i)
        .clk_div                       (clk_32m                        ),//(i)

        .sync_in                       (sync_in                        ),//(i)
        .adc_0_data_clk                (adc_17_20_data_clk             ),//(o)
        .adc_0_a_data                  (adc_17_data                    ),//(o)
        .adc_0_b_data                  (adc_18_data                    ),//(o)
        .adc_0_c_data                  (adc_19_data                    ),//(o)
        .adc_0_d_data                  (adc_20_data                    ),//(o)
        .adc_1_data_clk                (adc_21_24_data_clk             ),//(o)
        .adc_1_a_data                  (adc_21_data                    ),//(o)
        .adc_1_b_data                  (adc_22_data                    ),//(o)
        .adc_1_c_data                  (adc_23_data                    ),//(o)
        .adc_1_d_data                  (adc_24_data                    ),//(o)
        .adc_2_data_clk                (adc_25_28_data_clk             ),//(o)
        .adc_2_a_data                  (adc_25_data                    ),//(o)
        .adc_2_b_data                  (adc_26_data                    ),//(o)
        .adc_2_c_data                  (adc_27_data                    ),//(o)
        .adc_2_d_data                  (adc_28_data                    ),//(o)
        .adc_3_data_clk                (adc_29_32_data_clk             ),//(o)
        .adc_3_a_data                  (adc_29_data                    ),//(o)
        .adc_3_b_data                  (adc_30_data                    ),//(o)
        .adc_3_c_data                  (adc_31_data                    ),//(o)
        .adc_3_d_data                  (adc_32_data                    ),//(o)
    
        .ADC_0_D0_A_P                  (ADC_17_20_D0_A_P               ),//(i)
        .ADC_0_D0_A_N                  (ADC_17_20_D0_A_N               ),//(i)
        .ADC_0_D1_A_P                  (ADC_17_20_D1_A_P               ),//(i)
        .ADC_0_D1_A_N                  (ADC_17_20_D1_A_N               ),//(i)
        .ADC_0_D0_B_P                  (ADC_17_20_D0_B_P               ),//(i)
        .ADC_0_D0_B_N                  (ADC_17_20_D0_B_N               ),//(i)
        .ADC_0_D1_B_P                  (ADC_17_20_D1_B_P               ),//(i)
        .ADC_0_D1_B_N                  (ADC_17_20_D1_B_N               ),//(i)
        .ADC_0_D0_C_P                  (ADC_17_20_D0_C_P               ),//(i)
        .ADC_0_D0_C_N                  (ADC_17_20_D0_C_N               ),//(i)
        .ADC_0_D1_C_P                  (ADC_17_20_D1_C_P               ),//(i)
        .ADC_0_D1_C_N                  (ADC_17_20_D1_C_N               ),//(i)
        .ADC_0_D0_D_P                  (ADC_17_20_D0_D_P               ),//(i)
        .ADC_0_D0_D_N                  (ADC_17_20_D0_D_N               ),//(i)
        .ADC_0_D1_D_P                  (ADC_17_20_D1_D_P               ),//(i)
        .ADC_0_D1_D_N                  (ADC_17_20_D1_D_N               ),//(i)
        .ADC_0_FCO_P                   (ADC_17_20_FCO_P                ),//(i)
        .ADC_0_FCO_N                   (ADC_17_20_FCO_N                ),//(i)
        .ADC_0_DCO_P                   (ADC_17_20_DCO_P                ),//(i)
        .ADC_0_DCO_N                   (ADC_17_20_DCO_N                ),//(i)
        .ADC_0_SPI_CLK                 (ADC_17_20_SPI_CLK              ),//(o)
        .ADC_0_SPI_SDIO                (ADC_17_20_SPI_SDIO             ),//(i)
        .ADC_0_SPI_CSB                 (ADC_17_20_SPI_CSB              ),//(o)
        .ADC_0_SYNC                    (ADC_17_20_SYNC                 ),//(o)
        .ADC_0_PDWN                    (ADC_17_20_PDWN                 ),//(o)
    
        .ADC_1_D0_A_P                  (ADC_21_24_D0_A_P               ),//(i)
        .ADC_1_D0_A_N                  (ADC_21_24_D0_A_N               ),//(i)
        .ADC_1_D1_A_P                  (ADC_21_24_D1_A_P               ),//(i)
        .ADC_1_D1_A_N                  (ADC_21_24_D1_A_N               ),//(i)
        .ADC_1_D0_B_P                  (ADC_21_24_D0_B_P               ),//(i)
        .ADC_1_D0_B_N                  (ADC_21_24_D0_B_N               ),//(i)
        .ADC_1_D1_B_P                  (ADC_21_24_D1_B_P               ),//(i)
        .ADC_1_D1_B_N                  (ADC_21_24_D1_B_N               ),//(i)
        .ADC_1_D0_C_P                  (ADC_21_24_D0_C_P               ),//(i)
        .ADC_1_D0_C_N                  (ADC_21_24_D0_C_N               ),//(i)
        .ADC_1_D1_C_P                  (ADC_21_24_D1_C_P               ),//(i)
        .ADC_1_D1_C_N                  (ADC_21_24_D1_C_N               ),//(i)
        .ADC_1_D0_D_P                  (ADC_21_24_D0_D_P               ),//(i)
        .ADC_1_D0_D_N                  (ADC_21_24_D0_D_N               ),//(i)
        .ADC_1_D1_D_P                  (ADC_21_24_D1_D_P               ),//(i)
        .ADC_1_D1_D_N                  (ADC_21_24_D1_D_N               ),//(i)
        .ADC_1_FCO_P                   (ADC_21_24_FCO_P                ),//(i)
        .ADC_1_FCO_N                   (ADC_21_24_FCO_N                ),//(i)
        .ADC_1_DCO_P                   (ADC_21_24_DCO_P                ),//(i)
        .ADC_1_DCO_N                   (ADC_21_24_DCO_N                ),//(i)
        .ADC_1_SPI_CLK                 (ADC_21_24_SPI_CLK              ),//(o)
        .ADC_1_SPI_SDIO                (ADC_21_24_SPI_SDIO             ),//(i)
        .ADC_1_SPI_CSB                 (ADC_21_24_SPI_CSB              ),//(o)
        .ADC_1_SYNC                    (ADC_21_24_SYNC                 ),//(o)
        .ADC_1_PDWN                    (ADC_21_24_PDWN                 ),//(o)
    
        .ADC_2_D0_A_P                  (ADC_25_28_D0_A_P               ),//(i)
        .ADC_2_D0_A_N                  (ADC_25_28_D0_A_N               ),//(i)
        .ADC_2_D1_A_P                  (ADC_25_28_D1_A_P               ),//(i)
        .ADC_2_D1_A_N                  (ADC_25_28_D1_A_N               ),//(i)
        .ADC_2_D0_B_P                  (ADC_25_28_D0_B_P               ),//(i)
        .ADC_2_D0_B_N                  (ADC_25_28_D0_B_N               ),//(i)
        .ADC_2_D1_B_P                  (ADC_25_28_D1_B_P               ),//(i)
        .ADC_2_D1_B_N                  (ADC_25_28_D1_B_N               ),//(i)
        .ADC_2_D0_C_P                  (ADC_25_28_D0_C_P               ),//(i)
        .ADC_2_D0_C_N                  (ADC_25_28_D0_C_N               ),//(i)
        .ADC_2_D1_C_P                  (ADC_25_28_D1_C_P               ),//(i)
        .ADC_2_D1_C_N                  (ADC_25_28_D1_C_N               ),//(i)
        .ADC_2_D0_D_P                  (ADC_25_28_D0_D_P               ),//(i)
        .ADC_2_D0_D_N                  (ADC_25_28_D0_D_N               ),//(i)
        .ADC_2_D1_D_P                  (ADC_25_28_D1_D_P               ),//(i)
        .ADC_2_D1_D_N                  (ADC_25_28_D1_D_N               ),//(i)
        .ADC_2_FCO_P                   (ADC_25_28_FCO_P                ),//(i)
        .ADC_2_FCO_N                   (ADC_25_28_FCO_N                ),//(i)
        .ADC_2_DCO_P                   (ADC_25_28_DCO_P                ),//(i)
        .ADC_2_DCO_N                   (ADC_25_28_DCO_N                ),//(i)
        .ADC_2_SPI_CLK                 (ADC_25_28_SPI_CLK              ),//(o)
        .ADC_2_SPI_SDIO                (ADC_25_28_SPI_SDIO             ),//(i)
        .ADC_2_SPI_CSB                 (ADC_25_28_SPI_CSB              ),//(o)
        .ADC_2_SYNC                    (ADC_25_28_SYNC                 ),//(o)
        .ADC_2_PDWN                    (ADC_25_28_PDWN                 ),//(o)
    
        .ADC_3_D0_A_P                  (ADC_29_32_D0_A_P               ),//(i)
        .ADC_3_D0_A_N                  (ADC_29_32_D0_A_N               ),//(i)
        .ADC_3_D1_A_P                  (ADC_29_32_D1_A_P               ),//(i)
        .ADC_3_D1_A_N                  (ADC_29_32_D1_A_N               ),//(i)
        .ADC_3_D0_B_P                  (ADC_29_32_D0_B_P               ),//(i)
        .ADC_3_D0_B_N                  (ADC_29_32_D0_B_N               ),//(i)
        .ADC_3_D1_B_P                  (ADC_29_32_D1_B_P               ),//(i)
        .ADC_3_D1_B_N                  (ADC_29_32_D1_B_N               ),//(i)
        .ADC_3_D0_C_P                  (ADC_29_32_D0_C_P               ),//(i)
        .ADC_3_D0_C_N                  (ADC_29_32_D0_C_N               ),//(i)
        .ADC_3_D1_C_P                  (ADC_29_32_D1_C_P               ),//(i)
        .ADC_3_D1_C_N                  (ADC_29_32_D1_C_N               ),//(i)
        .ADC_3_D0_D_P                  (ADC_29_32_D0_D_P               ),//(i)
        .ADC_3_D0_D_N                  (ADC_29_32_D0_D_N               ),//(i)
        .ADC_3_D1_D_P                  (ADC_29_32_D1_D_P               ),//(i)
        .ADC_3_D1_D_N                  (ADC_29_32_D1_D_N               ),//(i)
        .ADC_3_FCO_P                   (ADC_29_32_FCO_P                ),//(i)
        .ADC_3_FCO_N                   (ADC_29_32_FCO_N                ),//(i)
        .ADC_3_DCO_P                   (ADC_29_32_DCO_P                ),//(i)
        .ADC_3_DCO_N                   (ADC_29_32_DCO_N                ),//(i)
        .ADC_3_SPI_CLK                 (ADC_29_32_SPI_CLK              ),//(o)
        .ADC_3_SPI_SDIO                (ADC_29_32_SPI_SDIO             ),//(i)
        .ADC_3_SPI_CSB                 (ADC_29_32_SPI_CSB              ),//(o)
        .ADC_3_SYNC                    (ADC_29_32_SYNC                 ),//(o)
        .ADC_3_PDWN                    (ADC_29_32_PDWN                 ) //(o)
    );


    // -------------------------------------------------------------------------
    // ad5592_config Module Inst.
    // -------------------------------------------------------------------------
    wire                ad5592_1_dac_config_en;
    wire    [2:0]       ad5592_1_dac_channel;
    wire    [11:0]      ad5592_1_dac_data;
    wire                ad5592_1_adc_config_en;
    wire    [7:0]       ad5592_1_adc_channel;
    wire                ad5592_1_spi_conf_ok;
    wire                ad5592_1_init;
    wire                ad5592_1_adc_data_en;
    wire    [11:0]      ad5592_1_adc_data;
    wire                HV_en_vio;
    wire                max5216_din_en   ;
    wire    [15:0]      max5216_din      ;
    assign              HV_EN_LS    =     HV_en_vio;

    vio_ad5592 u_vio_ad5592 (
        .clk        (clk_100m                ), 
        .probe_out0 (spi_wr_data_en          ), 
        .probe_out1 (ad5592_1_dac_channel    ), 
        .probe_out2 (spi_wr_data             ), 
        .probe_out3 (HV_en_vio               ),
        .probe_out4 (max5216_din_en          ), 
        .probe_out5 (max5216_din             )  
    );
    

    ad5592_config #(
        .ADC_IO_REG    (16'b0010000010000011 ),        //ADC:IO0,IO1,IO7
        .DAC_IO_REG    (16'b0010100001111100 )        //DAC:IO2,IO3,IO4,IO5,IO6
    )ad5592_config_inst1(
        .clk          (clk_100m              ),
        .rst          (rst                   ),
        .dac_config_en(ad5592_1_dac_config_en),
        .dac_channel  (ad5592_1_dac_channel  ),
        .dac_data     (ad5592_1_dac_data     ),
        .adc_config_en(ad5592_1_adc_config_en),
        .adc_channel  (ad5592_1_adc_channel  ),
        
        .spi_csn      (AD5592_1_SPI_CS_B     ),
        .spi_clk      (AD5592_1_SPI_CLK      ),
        .spi_mosi     (AD5592_1_SPI_MOSI     ),
        .spi_miso     (AD5592_1_SPI_MISO     ),
        .spi_conf_ok  (ad5592_1_spi_conf_ok  ),
        .init         (ad5592_1_init         ),
        .adc_data_en  (ad5592_1_adc_data_en  ),
        .adc_data     (ad5592_1_adc_data     )    
    );







    // -------------------------------------------------------------------------
    // ad5674_driver Module Inst.
    // -------------------------------------------------------------------------
    vio_ad5674 u_vio_ad5674 (
        .clk                 (clk_100m             ),// input wire clk
        .probe_out0          (ad5674_cm_trig       ),// output wire [0 : 0] probe_out0
        .probe_out1          (ad5674_cm_din        ) // output wire [11: 0] probe_out1
    );
    
    
    ad5674_easy_ctrl u_ad5674_easy_ctrl( 
        .clk                 (clk_100m             ),//(i)
        .rst_n               (~rst                 ),//(i)
        .ad5674_cm_trig      (ad5674_cm_trig       ),//(i)
        .ad5674_cm_din       (ad5674_cm_din        ),//(i)
        .ad5674_trig         (ad5674_trig          ),//(o)
        .ad5674_ch           (ad5674_ch            ),//(o)
        .ad5674_din          (ad5674_din           ) //(o)
    );                                             

    ad5674_driver  u_ad5674_driver( 
        .clk                 (clk_100m             ),//(i)
        .rst_n               (~rst                 ),//(i)
        .ad5674_trig         (ad5674_trig          ),//(i)
        .ad5674_ch           (ad5674_ch            ),//(i)
        .ad5674_din          (ad5674_din           ),//(i)
        .ad5674_dout1        (ad5674_dout1         ),//(o)
        .ad5674_dout2        (ad5674_dout2         ),//(o)
        .AD5674_1_SPI_CLK    (AD5674_1_SPI_CLK     ),//(o)
        .AD5674_1_SPI_CS     (AD5674_1_SPI_CS      ),//(o)
        .AD5674_1_SPI_SDO    (AD5674_1_SPI_SDO     ),//(i)
        .AD5674_1_SPI_SDI    (AD5674_1_SPI_SDI     ),//(o)
        .AD5674_1_SPI_RESET  (AD5674_1_SPI_RESET   ),//(o)
        .AD5674_1_SPI_LDAC   (AD5674_1_SPI_LDAC    ),//(o)
        .AD5674_2_SPI_CLK    (AD5674_2_SPI_CLK     ),//(o)
        .AD5674_2_SPI_CS     (AD5674_2_SPI_CS      ),//(o)
        .AD5674_2_SPI_SDO    (AD5674_1_SPI_SDO     ),//(i)
        .AD5674_2_SPI_SDI    (AD5674_2_SPI_SDI     ),//(o)
        .AD5674_2_SPI_RESET  (AD5674_2_SPI_RESET   ),//(o)
        .AD5674_2_SPI_LDAC   (AD5674_2_SPI_LDAC    ) //(o)
    );                                             
  

    // -------------------------------------------------------------------------
    // max5216_spi_if Module Inst.
    // -------------------------------------------------------------------------
    max5216_spi_if max5216_spi_if_inst(
        .clk           (clk_100m               ),//(i) 
        .rst           (rst                    ),//(i)
        .data_in_en    (max5216_din_en         ),//(i)
        .data_in       (max5216_din            ),//(i)
        .spi_csn       (MAX5216_CS             ),//(o)
        .spi_clk       (MAX5216_CLK            ),//(o)//max 50M
        .spi_mosi      (MAX5216_DIN            ),//(o)
        .clr_n         (MAX5216_CLR            ),//(o)
        .spi_ok        (                       ) //(o)
    );










endmodule





