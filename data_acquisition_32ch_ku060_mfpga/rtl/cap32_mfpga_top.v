module cap32_mfpga_top #(
    parameter                               SIM             =  0           ,
    parameter                               DDR3_SIM        =  0           ,
    parameter                               MAX_BLK_SIZE    =  32'd2097152  //1G bits 32'h200000
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

    //sfp serdes
    input                                   SFP0_MGT_REFCLK_C_P            ,//(i)
    input                                   SFP0_MGT_REFCLK_C_N            ,//(i)
    input                                   SFP_MGT_REFCLK_C_P             ,//(i)
    input                                   SFP_MGT_REFCLK_C_N             ,//(i)
//  input                                   FPGA_SFP0_RX_P                 ,//(i)
//  input                                   FPGA_SFP0_RX_N                 ,//(i)
//  output                                  FPGA_SFP0_TX_P                 ,//(o)
//  output                                  FPGA_SFP0_TX_N                 ,//(o)
    input                                   FPGA_SFP1_RX_P                 ,//(i)
    input                                   FPGA_SFP1_RX_N                 ,//(i)
    output                                  FPGA_SFP1_TX_P                 ,//(o)
    output                                  FPGA_SFP1_TX_N                 ,//(o)
//  input                                   FPGA_SFP2_RX_P                 ,//(i)
//  input                                   FPGA_SFP2_RX_N                 ,//(i)
//  output                                  FPGA_SFP2_TX_P                 ,//(o)
//  output                                  FPGA_SFP2_TX_N                 ,//(o)
    input                                   FPGA_SFP3_RX_P                 ,//(i)
    input                                   FPGA_SFP3_RX_N                 ,//(i)
    output                                  FPGA_SFP3_TX_P                 ,//(o)
    output                                  FPGA_SFP3_TX_N                 ,//(o)
    input                                   FPGA_SFP4_RX_P                 ,//(i)
    input                                   FPGA_SFP4_RX_N                 ,//(i)
    output                                  FPGA_SFP4_TX_P                 ,//(o)
    output                                  FPGA_SFP4_TX_N                 ,//(o)
                                                                                  
    input                                   FPGA_SFP0_TX_FAULT_LS          ,//(i) 
    output                                  FPGA_SFP0_TX_DISABLE_LS        ,//(o) 
    input                                   FPGA_SFP0_MOD_DETECT_LS        ,//(i) 
    input                                   FPGA_SFP0_LOS_LS               ,//(i) 
    input                                   FPGA_SFP1_TX_FAULT_LS          ,//(i) 
    output                                  FPGA_SFP1_TX_DISABLE_LS        ,//(o) 
    input                                   FPGA_SFP1_MOD_DETECT_LS        ,//(i) 
    input                                   FPGA_SFP1_LOS_LS               ,//(i) 
    input                                   FPGA_SFP2_TX_FAULT_LS          ,//(i) 
    output                                  FPGA_SFP2_TX_DISABLE_LS        ,//(o) 
    input                                   FPGA_SFP2_MOD_DETECT_LS        ,//(i) 
    input                                   FPGA_SFP2_LOS_LS               ,//(i) 
    input                                   FPGA_SFP3_TX_FAULT_LS          ,//(i) 
    output                                  FPGA_SFP3_TX_DISABLE_LS        ,//(o) 
    input                                   FPGA_SFP3_MOD_DETECT_LS        ,//(i) 
    input                                   FPGA_SFP3_LOS_LS               ,//(i) 
    input                                   FPGA_SFP4_TX_FAULT_LS          ,//(i) 
    output                                  FPGA_SFP4_TX_DISABLE_LS        ,//(o) 
    input                                   FPGA_SFP4_MOD_DETECT_LS        ,//(i) 
    input                                   FPGA_SFP4_LOS_LS               ,//(i) 

    //HMC7044                                                                   
    output                                  HMC7044_SYNC                   ,//(o)
    output                                  HMC7044_1_RESET_LS             ,//(o)
    output                                  HMC7044_1_SLEN_LS              ,//(o)
    output                                  HMC7044_1_SCLK_LS              ,//(o)
    inout                                   HMC7044_1_SDATA_LS             ,//(i)
    input                                   HMC7044_1_GPIO1_LS             ,//(i)
    input                                   HMC7044_1_GPIO2_LS             ,//(i)
    //EEPROM                                                                    
    output                                  EEPROM_CS_B                    ,//(o)
    input                                   EEPROM_SO                      ,//(i)
    output                                  EEPROM_SI                      ,//(o)
    output                                  EEPROM_WP_B                    ,//(o)
    output                                  EEPROM_SCK                     ,//(o)
    //TMP75                                                                      
    inout                                   TMP75_IIC_SDA                  ,//(i)
    output                                  TMP75_IIC_SCL                  ,//(o)
    input                                   TMP75_ALERT                    ,//(i)
    //AD5592
    output                                  AD5592_1_SPI_CS_B              ,//(o)
    output                                  AD5592_1_SPI_CLK               ,//(o)
    output                                  AD5592_1_SPI_MOSI              ,//(o)
    input                                   AD5592_1_SPI_MISO              ,//(i)
    //AD5674
    output                                  AD5674_1_SPI_CLK               ,//(o)
    output                                  AD5674_1_SPI_CS                ,//(o)
    input                                   AD5674_1_SPI_SDO               ,//(i)
    output                                  AD5674_1_SPI_SDI               ,//(o)
    output                                  AD5674_1_SPI_RESET             ,//(o)
    output                                  AD5674_1_SPI_LDAC              ,//(o)
    output                                  AD5674_2_SPI_CLK               ,//(o)
    output                                  AD5674_2_SPI_CS                ,//(o)
    input                                   AD5674_2_SPI_SDO               ,//(i)
    output                                  AD5674_2_SPI_SDI               ,//(o)
    output                                  AD5674_2_SPI_RESET             ,//(o)
    output                                  AD5674_2_SPI_LDAC              ,//(o)
    //MAX5216
    output                                  MAX5216_CS                     ,//(o) 
    output                                  MAX5216_CLR                    ,//(o) 
    output                                  MAX5216_DIN                    ,//(o) 
    output                                  MAX5216_CLK                    ,//(o) 
    //AD7680    
    output                                  AD7680_SCLK                    ,//(o) 
    output                                  AD7680_CS                      ,//(o) 
    input                                   AD7680_DATA                    ,//(i) 
    //TO SFPGA                                                   
    input                                   FPGA_TO_SFPGA_RESERVE0         ,//(i) 
    input                                   FPGA_TO_SFPGA_RESERVE1         ,//(i) 
    input                                   FPGA_TO_SFPGA_RESERVE2         ,//(i) 
    output                                  FPGA_TO_SFPGA_RESERVE3         ,//(i) 
    output                                  FPGA_TO_SFPGA_RESERVE4         ,//(i) 
    input                                   FPGA_TO_SFPGA_RESERVE5         ,//(i)no use
    input                                   FPGA_TO_SFPGA_RESERVE6         ,//(i)no use
    input                                   FPGA_TO_SFPGA_RESERVE7         ,//(i)no use
    output                                  FPGA_TO_SFPGA_RESERVE8         ,//(i)sfpga_rst
    input                                   FPGA_TO_SFPGA_RESERVE9         ,//(i)no use
    //OTHERS
    output                                  VCC12V_FAN_EN                  ,//(o) 
    output                                  HV_EN_LS                       ,//(o) 

    input                                   TIMING_SPI_MCLK_P              ,//(i)
    input                                   TIMING_SPI_MCLK_N              ,//(i)
    input                                   TIMING_SPI_MOSI_P              ,//(i)
    input                                   TIMING_SPI_MOSI_N              ,//(i)
    output                                  TIMING_SPI_SCLK_P              ,//(o)
    output                                  TIMING_SPI_SCLK_N              ,//(o)
    output                                  TIMING_SPI_MISO_P              ,//(o)
    output                                  TIMING_SPI_MISO_N              ,//(o)
    input                                   ENCODE_MCLK_P                  ,//(i)
    input                                   ENCODE_MCLK_N                  ,//(i)
    input                                   ENCODE_MOSI_P                  ,//(i)
    input                                   ENCODE_MOSI_N                  ,//(i)

    //DDR3
    input                                   ddr_clk_p                     ,//(i)
    input                                   ddr_clk_n                     ,//(i)
    inout             [63:0]                ddr3_dq                        ,//(i)
    inout             [7 :0]                ddr3_dqs_n                     ,//(i)
    inout             [7 :0]                ddr3_dqs_p                     ,//(i)
    output            [15:0]                ddr3_addr                      ,//(o)//notice
    output            [2 :0]                ddr3_ba                        ,//(o)
    output                                  ddr3_ras_n                     ,//(o)
    output                                  ddr3_cas_n                     ,//(o)
    output                                  ddr3_we_n                      ,//(o)
    output                                  ddr3_reset_n                   ,//(o)
    output                                  ddr3_ck_p                      ,//(o)
    output                                  ddr3_ck_n                      ,//(o)
    output                                  ddr3_cke                       ,//(o)
    output                                  ddr3_cs_n                      ,//(o)
    output            [7 :0]                ddr3_dm                        ,//(o)
    output                                  ddr3_odt                       ,//(o)
    
    input      [12:0]                       POW_GOOD                        //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                              RST_TIME   =   SIM ? 16'd200 :  16'd2000 ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    FPGA_MASTER_CLOCK               ;
    wire                                    pll_locked                      ;
    wire                                    pll2_locked                     ;
    wire                                    clk_100m                        ;
    wire                                    clk_200m                        ;
    wire                                    clk_125m                        ;
    wire                                    clk_50m                         ;
    wire                                    clk_32m                         ;
    wire                                    clk_128m                        ;
    reg                                     rst                             ;
    reg        [15:0]                       rst_cnt                         ;
    wire                                    hmc7044_config_ok               ;
    wire                                    hmc7044_1_config_ok             ;
    wire                                    auro_user_clk                   ;
    wire                                    auro_rst_n                      ;

    wire       [31:0]                       adc_0_pat_err_cnt               ;
    wire       [31:0]                       adc_1_pat_err_cnt               ;
    wire       [31:0]                       adc_2_pat_err_cnt               ;
    wire       [31:0]                       adc_3_pat_err_cnt               ;
    wire       [31:0]                       adc_4_pat_err_cnt               ;
    wire       [31:0]                       adc_5_pat_err_cnt               ;
    wire       [31:0]                       adc_6_pat_err_cnt               ;
    wire       [31:0]                       adc_7_pat_err_cnt               ;
    wire       [15:0]                       track_num                       ;

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

    wire                                    spi_wr_data_en                   ;
    wire       [23:0]                       spi_wr_data                      ;
    wire                                    head_rd                          ;
    wire       [63 :0]                      head_din                         ;
    wire                                    adc_fifo_rd                      ;
    wire       [511:0]                      adc_fifo_din                     ;
    wire                                    adc_fifo_empty                   ;
    wire       [10:0]                       adc_fifo_data_cnt                ;
    wire       [31 :0]                      adc_fifo_full_cnt                ;
    wire       [17:0]                       xenc_1st                         ;
    wire       [17:0]                       wenc_1st                         ;
    wire       [31:0]                       jp_pos_1st                       ;
    wire       [31:0]                       jp_num                           ;
    wire       [9:0]                        adc_rm_num                       ;
    wire       [9:0]                        enc_rm_num                       ;
    wire       [31:0]                       coe0                             ;
    wire       [31:0]                       coe1                             ;
    wire       [31:0]                       coe2                             ;
    wire       [31:0]                       coe3                             ;
    wire       [31:0]                       coe4                             ;
    wire       [31:0]                       coe5                             ;
    wire       [31:0]                       coe6                             ;
    wire       [31:0]                       coe7                             ;
    wire       [31:0]                       coe8                             ;
    wire       [31:0]                       coe9                             ;
    wire       [31:0]                       coe10                            ;
    wire       [31:0]                       coe11                            ;
    wire       [31:0]                       coe12                            ;
    wire       [31:0]                       coe13                            ;
    wire       [31:0]                       coe14                            ;
    wire       [31:0]                       coe15                            ;
    wire       [31:0]                       coe16                            ;
    wire       [31:0]                       coe17                            ;
    wire       [31:0]                       coe18                            ;
    wire       [31:0]                       coe_dec                          ;
    wire       [17:0]                       fir_xenc_1st                     ;
    wire       [17:0]                       fir_wenc_1st                     ;
    wire       [31:0]                       fir_jp_pos_1st                   ;
    wire       [31:0]                       fir_jp_num                       ;


    wire                                    adc_data_vld                     ;
    wire       [511:0]                      adc_data                         ;
    wire                                    fir_dout_vld                     ;
    wire       [511:0]                      fir_dout                         ;
    wire                                    enc_vld                          ;
    wire       [63:0]                       enc_data                         ;
    wire       [63 :0]                      enc_data1                        ;
    wire       [63 :0]                      enc_data2                        ;
    wire                                    cfg_acc_en                       ;
    wire       [15:0]                       acc_zoom_coe                     ;
    wire                                    acc_ovld                         ;
    wire       [511:0]                      acc_odat                         ;
    wire       [63 :0]                      enc_acc_odat                     ;
    wire                                    remap_en                         ;
    wire                                    map_ovld                         ;
    wire       [511:0]                      map_odat                         ;
    wire       [63 :0]                      enc_map_odat                     ;

    wire                                    ch0_fifo_wr                      ;
    wire       [511:0]                      ch0_fifo_din                     ;
    wire                                    ch0_fifo_full                    ;
    wire       [31:0]                       ch0_fifo_full_cnt                ;



    wire                                    RF_MOD_IN_FIXED                  ;
    wire                                    RF_MOD_IN_VARIABLE               ;
    wire                                    TIMING_SPI_MCLK                  ;
    wire                                    TIMING_SPI_SCLK                  ;
    wire                                    TIMING_SPI_MOSI                  ;
    wire                                    TIMING_SPI_MISO                  ;
    wire                                    ENCODE_MCLK                      ;
    wire                                    ENCODE_MOSI                      ;
    wire                                    slave_wr_en                      ;
    wire       [16-1:0]                     slave_addr                       ;
    wire       [32-1:0]                     slave_wr_data                    ;
    wire                                    slave_rd_en                      ;
    wire                                    slave_rd_vld                     ;
    wire       [32-1:0]                     slave_rd_data                    ;
    wire                                    master_wr_en                     ;
    wire       [16-1:0]                     master_addr                      ;
    wire       [32-1:0]                     master_wr_data                   ;
    wire                                    master_rd_en                     ;
    wire                                    master_rd_vld                    ;
    wire       [32-1:0]                     master_rd_data                   ;

    wire       [32-1:0]                     ddr_rd0_addr                     ;
    wire                                    ddr_rd0_en                       ;
    wire                                    readback0_vld                    ;
    wire                                    readback0_last                   ;
    wire       [32-1:0]                     readback0_data                   ;
    wire       [32-1:0]                     ddr_rd1_addr                     ;
    wire                                    ddr_rd1_en                       ;
    wire                                    readback1_vld                    ;
    wire                                    readback1_last                   ;
    wire       [32-1:0]                     readback1_data                   ;
    wire                                    fir_tap_wr_cmd                   ;
    wire       [32-1:0]                     fir_tap_wr_addr                  ;
    wire                                    fir_tap_wr_vld                   ;
    wire       [32-1:0]                     fir_tap_wr_data                  ;
    wire                                    bias_tap_wr_cmd                  ;
    wire       [32-1:0]                     bias_tap_wr_addr                 ;
    wire                                    bias_tap_wr_vld                  ;
    wire       [32-1:0]                     bias_tap_wr_data                 ;
    
    wire                                    ad5592_1_dac_config_en           ;
    wire       [2:0]                        ad5592_1_dac_channel             ;
    wire       [11:0]                       ad5592_1_dac_data                ;
    wire                                    ad5592_1_adc_config_en           ;
    wire       [7:0]                        ad5592_1_adc_channel             ;
    wire                                    ad5592_1_spi_conf_ok             ;
    wire       [11:0]                       ad5592_1_adc_data_lock           ;
    wire                                    ad5592_1_init                    ;
    wire                                    temp_rd_en                       ;
    wire       [11:0]                       temp_data_lock                   ;
    wire                                    eeprom_w_en                      ;
    wire       [31:0]                       eeprom_w_addr_data               ;
    wire                                    eeprom_r_addr_en                 ;
    wire       [15:0]                       eeprom_r_addr                    ;
    wire       [7:0]                        eeprom_r_data_lock               ;
    wire                                    max5216_din_en                   ;
    wire       [15:0]                       max5216_din                      ;
    wire                                    ad7680_rd_en                     ;
    wire                                    ad7680_dout_en                   ;
    wire       [15:0]                       ad7680_dout                      ;
    wire       [15:0]                       ad7680_dout_lock                 ;
    wire                                    ad5674_trig                      ;
    wire       [4:0]                        ad5674_ch                        ;
    wire       [15:0]                       ad5674_din                       ;
    wire       [23:0]                       ad5674_dout1                     ;
    wire       [23:0]                       ad5674_dout2                     ;
    wire       [23:0]                       ad5674_dout                      ;
    wire       [31:0]                       ad5674_cfg                       ;
    wire                                    vio_hv_en                        ;
    wire                                    spi_hv_en                        ;
    
    wire       [31:0]                       adc_pkt_sop_eop_cnt              ;
    wire       [31:0]                       enc_sop_eop_cnt                  ;
    wire       [31:0]                       enc_sop_eop_clr_cnt              ;
    wire       [31:0]                       enc_vld_cnt                      ;
    wire       [31:0]                       eds_fifo_full_cnt                ;
    wire       [31:0]                       eds_sop_eop_cnt                  ;
    wire       [31:0]                       eds_sop_eop_clr_cnt              ;
    wire       [31:0]                       fbc_sop_eop_cnt                  ;
    wire       [31:0]                       eds_vld_cnt                      ;
    wire       [31:0]                       last_pkt_cnt                     ;
    wire       [31:0]                       buff_clr_cnt                     ;
    wire                                    eds_cpl                          ;
    wire                                    fbc_cpl                          ;
    wire                                    fbc_cpl_en                       ;

    wire       [31:0]                       aurora_cfg                       ;
    wire       [31:0]                       aurora_sts                       ;
    wire       [31:0]                       aurora_soft_err_cnt              ;
    wire       [31:0]                       adc_ctrl0                        ;
    wire       [31:0]                       adc_ctrl1                        ;
    wire       [31:0]                       adc_ctrl2                        ;
    wire       [31:0]                       adc_ctrl3                        ;
    wire                                    adc_enable                       ;
    wire                                    ena_cpl                          ;
    wire                                    fir_en                           ;
    wire                                    encode_flag_test                 ;
    wire                                    encode_local                     ;

    wire       [31:0]                       cfg_time                         ;
    wire                                    time_trig                        ;
    wire                                    eds_fbc_clr_buff                 ;
    wire                                    clear_buffer                     ;
    wire                                    clear_buffer_noeds               ;
    wire                                    pop_end_pkt                      ;
    wire                                    cfg_cpl                          ;
    wire                                    scan_cpl                         ;    
    wire                                    scan_local                       ;
    wire                                    adc_clr_buff                     ;
    wire                                    scan_start_flag                  ;
    wire                                    scan_test_flag                   ;
    wire                                    wafer_zero_flag                  ;
    wire       [31:0]                       tx_adc_chk_suc_cnt               ;
    wire       [31:0]                       tx_adc_chk_err_cnt               ;
    wire       [31:0]                       tx_enc_chk_suc_cnt               ;
    wire       [31:0]                       tx_enc_chk_err_cnt               ;
    wire       [31:0]                       tx_total_vld_cnt                 ;

    wire                                    ddr_test_en                      ;
    wire       [31:0]                       sts_suc_cnt                      ;
    wire       [31:0]                       sts_err_cnt                      ;
    wire                                    sts_err_lock                     ;
    wire                                    ddr3_init_done                   ;
    wire                                    sfpga_rst                        ;
    wire       [31:0]                       fir_tap_vld_cnt                  ;
    wire       [15:0]                       bias_tap_vld_cnt                 ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign        FPGA_SFP0_TX_DISABLE_LS  = FPGA_SFP0_MOD_DETECT_LS ? 1'b1 : 1'b0;
    assign        FPGA_SFP1_TX_DISABLE_LS  = FPGA_SFP1_MOD_DETECT_LS ? 1'b1 : 1'b0;
    assign        FPGA_SFP2_TX_DISABLE_LS  = FPGA_SFP2_MOD_DETECT_LS ? 1'b1 : 1'b0;
    assign        FPGA_SFP3_TX_DISABLE_LS  = FPGA_SFP3_MOD_DETECT_LS ? 1'b1 : 1'b0;
    assign        FPGA_SFP4_TX_DISABLE_LS  = FPGA_SFP4_MOD_DETECT_LS ? 1'b1 : 1'b0;
    assign        VCC12V_FAN_EN            =  1'b1     ;
    assign        HV_EN_LS                 = vio_hv_en  || spi_hv_en;
    assign        FPGA_TO_SFPGA_RESERVE8   = sfpga_rst              ;
// =================================================================================================
// RTL Body
// =================================================================================================

    IBUFDS FPGA_MASTER_inst(
        .O(FPGA_MASTER_CLOCK   ),   // Buffer output
        .I(FPGA_MASTER_CLOCK_P ),   // Diff_p buffer input (connect directly to top-level port)
        .IB(FPGA_MASTER_CLOCK_N)    // Diff_n buffer input (connect directly to top-level port)
    );

    pll pll_inst(
        .clk_out1(clk_100m         ), 
        .clk_out2(clk_200m         ),
        .clk_out3(clk_50m          ),
        .clk_out4(clk_125m         ),
        .reset   (FPGA_RESET       ), 
        .locked  (pll_locked       ), 
        .clk_in1 (FPGA_MASTER_CLOCK)
    );

    pll2 pll_inst1(
        .clk_out1(clk_32m          ), 
        .clk_out2(clk_128m         ),
        .reset   (~pll_locked      ), 
        .locked  (pll2_locked      ), 
        .clk_in1 (clk_100m         )
    );


  always@(posedge clk_100m or negedge pll_locked)begin
      if(!pll_locked) begin
          rst         <= 1'b1;
          rst_cnt     <= 'd0;
        end else if(rst_cnt == RST_TIME) begin        //100us
            rst_cnt     <= rst_cnt;
            rst         <= 1'b0;
        end else begin
            rst         <= 'd1;
            rst_cnt     <= rst_cnt + 1'b1;
        end
    end

    cmip_arst_sync #(                                                          
        .PIPE_NUM                      (4                              )       
    )u_cmip_arst_sync(                                                
        .i_dst_clk                     (auro_user_clk                  ),//(i)
        .i_src_rst_n                   (hmc7044_config_ok              ),//(i)
        .o_dst_rst_n                   (auro_rst_n                     ) //(o)
    );                                                                   

    // -------------------------------------------------------------------------
    // ad9253_4ch_driver Module Inst.
    // -------------------------------------------------------------------------
    vio_spi_cfg u_vio_spi_cfg (
        .clk                          (clk_100m                        ), 
        .probe_out0                   (spi_wr_data_en                  ), 
        .probe_out1                   (spi_wr_data                     )  
    );
    

    ad9253_4ch_driver_v2 #(
         .IODELAY_GROUP_NAME1          ("delay1"                       ),
         .IODELAY_GROUP_NAME2          ("delay2"                       )  
    )u0_ad9253_4ch_driver(       
        .sys_clk                       (clk_100m                       ),//(i) 
        .sys_rst                       (~hmc7044_config_ok             ),//(i)
        .spi_wr_data_en                (spi_wr_data_en                 ),//(i)
        .spi_wr_data                   (spi_wr_data                    ),//(i)
        .clk_200m                      (clk_200m                       ),//(i)
        .clk                           (clk_128m                       ),//(i)
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
        .adc_0_pat_err_cnt             (adc_0_pat_err_cnt              ),//(o)
        .adc_1_pat_err_cnt             (adc_1_pat_err_cnt              ),//(o)
        .adc_2_pat_err_cnt             (adc_2_pat_err_cnt              ),//(o)
        .adc_3_pat_err_cnt             (adc_3_pat_err_cnt              ),//(o)
    
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
        .clk                           (clk_128m                       ),//(i)
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
        .adc_0_pat_err_cnt             (adc_4_pat_err_cnt              ),//(o)
        .adc_1_pat_err_cnt             (adc_5_pat_err_cnt              ),//(o)
        .adc_2_pat_err_cnt             (adc_6_pat_err_cnt              ),//(o)
        .adc_3_pat_err_cnt             (adc_7_pat_err_cnt              ),//(o)


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


    ad9253_data_process #(                                                          
        .DATA_WDTH                     (512                            )
    )u_ad9253_data_process( 
        .sys_clk                       (clk_32m                        ),//(i)
        .sys_rst_n                     (hmc7044_config_ok              ),//(i)
        .enc_vld                       (enc_vld                        ),//(i)
        .enc_din                       (enc_data                       ),//(i)
        .adc_1_data                    (adc_1_data                     ),//(i)
        .adc_2_data                    (adc_2_data                     ),//(i)
        .adc_3_data                    (adc_3_data                     ),//(i)
        .adc_4_data                    (adc_4_data                     ),//(i)
        .adc_5_data                    (adc_5_data                     ),//(i)
        .adc_6_data                    (adc_6_data                     ),//(i)
        .adc_7_data                    (adc_7_data                     ),//(i)
        .adc_8_data                    (adc_8_data                     ),//(i)
        .adc_9_data                    (adc_9_data                     ),//(i)
        .adc_10_data                   (adc_10_data                    ),//(i)
        .adc_11_data                   (adc_11_data                    ),//(i)
        .adc_12_data                   (adc_12_data                    ),//(i)
        .adc_13_data                   (adc_13_data                    ),//(i)
        .adc_14_data                   (adc_14_data                    ),//(i)
        .adc_15_data                   (adc_15_data                    ),//(i)
        .adc_16_data                   (adc_16_data                    ),//(i)
        .adc_17_data                   (adc_17_data                    ),//(i)
        .adc_18_data                   (adc_18_data                    ),//(i)
        .adc_19_data                   (adc_19_data                    ),//(i)
        .adc_20_data                   (adc_20_data                    ),//(i)
        .adc_21_data                   (adc_21_data                    ),//(i)
        .adc_22_data                   (adc_22_data                    ),//(i)
        .adc_23_data                   (adc_23_data                    ),//(i)
        .adc_24_data                   (adc_24_data                    ),//(i)
        .adc_25_data                   (adc_25_data                    ),//(i)
        .adc_26_data                   (adc_26_data                    ),//(i)
        .adc_27_data                   (adc_27_data                    ),//(i)
        .adc_28_data                   (adc_28_data                    ),//(i)
        .adc_29_data                   (adc_29_data                    ),//(i)
        .adc_30_data                   (adc_30_data                    ),//(i)
        .adc_31_data                   (adc_31_data                    ),//(i)
        .adc_32_data                   (adc_32_data                    ),//(i)
        
        .adc_rm_num                    (adc_rm_num                     ),//(i)
        .enc_rm_num                    (enc_rm_num                     ),//(i)
        .encode_local                  (encode_local                   ),//(i)
        .scan_local                    (scan_local                     ),//(i)
        .scan_start_flag               (scan_start_flag                ),//(i)
        .scan_test_flag                (scan_test_flag                 ),//(i)
        .scan_cpl                      (scan_cpl                       ),//(o)
        .adc_clr_buff                  (adc_clr_buff                   ),//(o)
        .cfg_rst                       (clear_buffer                   ),//(i)
        .adc_data_vld                  (adc_data_vld                   ),//(o)
        .adc_data                      (adc_data                       ),//(o)
        .enc_data                      (enc_data1                      ),//(o)
        .adc_fifo_full_cnt             (adc_fifo_full_cnt              ),//(o)
        .xenc_1st                      (xenc_1st                       ),//(o)
        .wenc_1st                      (wenc_1st                       ),//(o)
        .jp_pos_1st                    (jp_pos_1st                     ),//(o)
        .jp_num                        (jp_num                         ) //(o)

    );                                                                        


    acc_calc u_acc_calc(                                                     
        .clk                           (clk_32m                        ),//(i)
        .rst_n                         (hmc7044_config_ok              ),//(i)
        .cfg_rst                       (cfg_rst                        ),//(i)
        .cfg_acc_en                    (cfg_acc_en                     ),//(i)
        .acc_zoom_coe                  (acc_zoom_coe                   ),//(i)
        .acc_ivld                      (adc_data_vld                   ),//(i)
        .acc_idat                      (adc_data                       ),//(i)
        .enc_idat                      (enc_data1                      ),//(i)
        .acc_ovld                      (acc_ovld                       ),//(o)
        .acc_odat                      (acc_odat                       ),//(o)
        .enc_odat                      (enc_acc_odat                   ) //(o)
    );                                                               

    adc_remap u_adc_remap(                                                     
        .clk                           (clk_32m                        ),//(i)
        .rst_n                         (hmc7044_config_ok              ),//(i)
        .cfg_rst                       (cfg_rst                        ),//(i)
        .remap_en                      (remap_en                       ),//(i)
        .map_ivld                      (acc_ovld                       ),//(i)
        .map_idat                      (acc_odat                       ),//(i)
        .enc_idat                      (enc_acc_odat                   ),//(i)
        .map_ovld                      (map_ovld                       ),//(o)
        .map_odat                      (map_odat                       ),//(o)
        .enc_odat                      (enc_map_odat                   ) //(o)
    );                                                               


    fir_process #(                                                          
        .DATA_WDTH                     (512                            )
    )u_fir_process( 
        .cfg_clk                       (clk_100m                       ),//(i)
        .cfg_rst_n                     (hmc7044_config_ok              ),//(i)
        .soft_rst                      (clear_buffer                   ),//(i)
        .fir_en                        (fir_en                         ),//(i)
        .scan_start                    (scan_start_flag                ),//(i)
        .encode_flag                   (encode_flag_test               ),//(i)
        .ddr_rd0_en                    (ddr_rd0_en                     ),//(i)
        .ddr_rd0_addr                  (ddr_rd0_addr                   ),//(i)
        .readback0_vld                 (readback0_vld                  ),//(o)
        .readback0_last                (readback0_last                 ),//(o)
        .readback0_data                (readback0_data                 ),//(o)
        .track_num                     (track_num                      ),//(o)

        .sys_clk                       (clk_32m                        ),//(i)
        .sys_rst_n                     (hmc7044_config_ok              ),//(i)
        .fir_din_vld                   (map_ovld                       ),//(i)
        .fir_din                       (map_odat                       ),//(i)
        .enc_din                       (enc_map_odat                   ),//(i)
        .fir_dout_vld                  (fir_dout_vld                   ),//(o)
        .fir_dout                      (fir_dout                       ),//(o)
        .enc_dout                      (enc_data2                      ),//(o)

        .fir_xenc_1st                  (fir_xenc_1st                   ),//(o)
        .fir_wenc_1st                  (fir_wenc_1st                   ),//(o)
        .fir_jp_pos_1st                (fir_jp_pos_1st                 ),//(o)
        .fir_jp_num                    (fir_jp_num                     ),//(o)
        .coe0                          (coe0                           ),//(o)
        .coe1                          (coe1                           ),//(o)
        .coe2                          (coe2                           ),//(o)
        .coe3                          (coe3                           ),//(o)
        .coe4                          (coe4                           ),//(o)
        .coe5                          (coe5                           ),//(o)
        .coe6                          (coe6                           ),//(o)
        .coe7                          (coe7                           ),//(o)
        .coe8                          (coe8                           ),//(o)
        .coe9                          (coe9                           ),//(o)
        .coe10                         (coe10                          ),//(o)
        .coe11                         (coe11                          ),//(o)
        .coe12                         (coe12                          ),//(o)
        .coe13                         (coe13                          ),//(o)
        .coe14                         (coe14                          ),//(o)
        .coe15                         (coe15                          ),//(o)
        .coe16                         (coe16                          ),//(o)
        .coe17                         (coe17                          ),//(o)
        .coe18                         (coe18                          ),//(o)
        .coe_dec                       (coe_dec                        ) //(o)
    );                                                                 
    
    
    // -------------------------------------------------------------------------
    // adc2auro_bridge  Module Inst.
    // -------------------------------------------------------------------------
    adc2auro_bridge #(                                                         
        .FIFO_DPTH                     (1024                          ),
        .WR_DATA_WD                    (512                           ),
        .RD_DATA_WD                    (128                           ),
        .HEAD_WD                       (64                            )       
    )u_adc2auro_bridge( 
        .wr_clk                        (clk_32m                       ),//(i)
        .wr_rst_n                      (hmc7044_config_ok             ),//(i)
        .cfg_rst                       (clear_buffer                  ),//(i)
        .fir_vld                       (fir_dout_vld                  ),//(i)
        .fir_din                       (fir_dout                      ),//(i)
        .enc_din                       (enc_data2                     ),//(i)
        .rd_clk                        (auro_user_clk                 ),//(i)
        .rd_rst_n                      (auro_rst_n                    ),//(i)
        .adc_fifo_rd                   (adc_fifo_rd                   ),//(i)
        .adc_fifo_din                  (adc_fifo_din                  ),//(o)
        .adc_fifo_empty                (adc_fifo_empty                ),//(o)
        .head_rd                       (head_rd                       ),//(i)
        .head_din                      (head_din                      ) //(o)
    );                                                                       

    //-----------------------------------------------------------------------------------
    // serial_slave_drv Module Inst.                                                    
    //-----------------------------------------------------------------------------------
    IBUFDS U0_IBUFDS(.O(TIMING_SPI_MCLK),.I(TIMING_SPI_MCLK_P),.IB(TIMING_SPI_MCLK_N));
    IBUFDS U1_IBUFDS(.O(TIMING_SPI_MOSI),.I(TIMING_SPI_MOSI_P),.IB(TIMING_SPI_MOSI_N));
    OBUFDS U0_OBUFDS(.O(TIMING_SPI_SCLK_P),.OB(TIMING_SPI_SCLK_N),.I(TIMING_SPI_SCLK));
    OBUFDS U1_OBUFDS(.O(TIMING_SPI_MISO_P),.OB(TIMING_SPI_MISO_N),.I(TIMING_SPI_MISO));
    IBUFDS U2_IBUFDS(.O(ENCODE_MCLK),.I(ENCODE_MCLK_P),.IB(ENCODE_MCLK_N));
    IBUFDS U3_IBUFDS(.O(ENCODE_MOSI),.I(ENCODE_MOSI_P),.IB(ENCODE_MOSI_N));



    serial_slave_drv #(
        .DATA_WIDTH                    (32                             ),
        .ADDR_WIDTH                    (16                             ),
        .CMD_WIDTH                     (8                              ),
        .SERIAL_MODE                   (1                              )
    )u_serial_slave_drv(
        .clk_i                         (clk_100m                       ),
        .rst_i                         (~hmc7044_config_ok             ),
        .clk_200m_i                    (clk_200m                       ),
        .slave_wr_en_o                 (slave_wr_en                    ), 
        .slave_addr_o                  (slave_addr                     ),
        .slave_wr_data_o               (slave_wr_data                  ),
        .slave_rd_en_o                 (slave_rd_en                    ),
        .slave_rd_vld_i                (slave_rd_vld                   ),
        .slave_rd_data_i               (slave_rd_data                  ),

        .SPI_MCLK                      (TIMING_SPI_MCLK                ),
        .SPI_MOSI                      (TIMING_SPI_MOSI                ),
        .SPI_SCLK                      (TIMING_SPI_SCLK                ),
        .SPI_MISO                      (TIMING_SPI_MISO                )
    );


    encode_rx_drv encode_rx_drv_inst(
        .clk_i                         (clk_100m                       ),
        .rst_i                         (~hmc7044_config_ok             ),
        .clk_200m_i                    (clk_200m                       ),
        .encode_zero_flag_o            (wafer_zero_flag                ),
        .scan_start_flag_o             (scan_start_flag                ),
        .scan_tset_flag_o              (scan_test_flag                 ),
        .SPI_MCLK                      (ENCODE_MCLK                    ),
        .SPI_MOSI                      (ENCODE_MOSI                    )
    );


    //-----------------------------------------------------------------------------------
    // spi_reg_map Module Inst.                                                    
    //-----------------------------------------------------------------------------------
    spi_reg_map #(
        .DATA_WIDTH                    ( 32                            ),
        .ADDR_WIDTH                    ( 16                            )
    )u_spi_reg_map(                                            
        .clk_i                         (clk_100m                       ),
        .rst_i                         (~hmc7044_config_ok             ),
        .slave_wr_en_i                 (slave_wr_en                    ),
        .slave_addr_i                  (slave_addr                     ),
        .slave_wr_data_i               (slave_wr_data                  ),
        .slave_rd_en_i                 (slave_rd_en                    ),
        .slave_rd_vld_o                (slave_rd_vld                   ),
        .slave_rd_data_o               (slave_rd_data                  ),
                                                                               
        .adc_lock                      (scan_cpl                       ),//(i)
        .eds_lock                      (eds_cpl                        ),//(i)
        .fbc_lock                      (fbc_cpl                        ),//(i)
        .i_rega0                       (32'h1234_ABCD                  ),//(i) 16'h0040   pop_clr_cnt   
        .i_rega1                       (enc_sop_eop_clr_cnt            ),//(i) 16'h0044     
        .i_rega2                       (enc_vld_cnt                    ),//(i) 16'h0048     
        .i_rega3                       (32'h1234_ABCD                  ),//(i) 16'h004C     
        .i_rega4                       (eds_fifo_full_cnt              ),//(i) 16'h0050   eop_cnt
        .i_rega5                       (eds_sop_eop_clr_cnt            ),//(i) 16'h0054   sop_cnt
        .i_rega6                       (eds_vld_cnt                    ),//(i) 16'h0058   vld_cnt
        .i_rega7                       (adc_pkt_sop_eop_cnt            ),//(i) 16'h005C     
        .i_regb0                       (adc_fifo_full_cnt              ),//(i) 16'h0060     
        .i_regb1                       (track_num                      ),//(i) 16'h0064     
        .i_regb2                       (aurora_sts                     ),//(i) 16'h0068     
        .i_regb3                       (aurora_soft_err_cnt            ),//(i) 16'h006C     
        .i_regb4                       (tx_adc_chk_suc_cnt             ),//(i) 16'h0070     
        .i_regb5                       (tx_adc_chk_err_cnt             ),//(i) 16'h0074     
        .i_regb6                       (tx_enc_chk_suc_cnt             ),//(i) 16'h0078     
        .i_regb7                       (tx_enc_chk_err_cnt             ),//(i) 16'h007C     
        .i_regc0                       (fir_xenc_1st                   ),//(i) 16'h0080     
        .i_regc1                       (fir_wenc_1st                   ),//(i) 16'h0084     
        //.i_regc2                       (fir_jp_pos_1st                 ),//(i) 16'h0088     
        //.i_regc3                       (fir_jp_num                     ),//(i) 16'h008C     
        .i_regc2                       (fir_tap_vld_cnt                ),//(i) 16'h0088     fir_tap_vld_cnt
        .i_regc3                       (bias_tap_vld_cnt               ),//(i) 16'h008C     
        .i_regc4                       (xenc_1st                       ),//(i) 16'h0090     
        .i_regc5                       (wenc_1st                       ),//(i) 16'h0094     
        .i_regc6                       (jp_pos_1st                     ),//(i) 16'h0098     
        .i_regc7                       (jp_num                         ),//(i) 16'h009C     

        .i_reg0140                     (temp_data_lock                 ),//(i)
        .i_reg0144                     (eeprom_r_data_lock             ),//(i)
        .i_reg0148                     (ad7680_dout_lock               ),//(i)
        .i_reg014C                     (ad5674_dout                    ),//(i)
        .i_reg0150                     (sts_suc_cnt                    ),//(i)
        .i_reg0154                     (sts_err_cnt                    ),//(i)
        .i_reg0158                     (sts_err_lock                   ),//(i)
        .i_reg015C                     ({ddr3_init_done,hmc7044_config_ok}),//(i)
        .i_reg0160                     (ad5674_dout1                   ),//(i)
        .i_reg0164                     (ad5674_dout2                   ),//(i)
        .i_reg0168                     ({16'd0,fir_tap_vld_cnt[15:0] } ),//(i)
        .i_reg016C                     ({16'd0,fir_tap_vld_cnt[31:16]} ),//(i)
        .i_reg0170                     (32'd0                          ),//(i)
        .i_reg0174                     (32'd0                          ),//(i)
        .i_reg0178                     (32'd0                          ),//(i)
        .i_reg017C                     (32'd0                          ),//(i)
        .i_reg0180                     (adc_0_pat_err_cnt              ),//(i)
        .i_reg0184                     (adc_1_pat_err_cnt              ),//(i)
        .i_reg0188                     (adc_2_pat_err_cnt              ),//(i)
        .i_reg018C                     (adc_3_pat_err_cnt              ),//(i)
        .i_reg0190                     (adc_4_pat_err_cnt              ),//(i)
        .i_reg0194                     (adc_5_pat_err_cnt              ),//(i)
        .i_reg0198                     (adc_6_pat_err_cnt              ),//(i)
        .i_reg019C                     (adc_7_pat_err_cnt              ),//(i)

        .i_reg01A0                     (coe0                           ),//(i)
        .i_reg01A4                     (coe1                           ),//(i)
        .i_reg01A8                     (coe2                           ),//(i)
        .i_reg01AC                     (coe3                           ),//(i)
        .i_reg01B0                     (coe4                           ),//(i)
        .i_reg01B4                     (coe5                           ),//(i)
        .i_reg01B8                     (coe6                           ),//(i)
        .i_reg01BC                     (coe7                           ),//(i)
        .i_reg01C0                     (coe8                           ),//(i)
        .i_reg01C4                     (coe9                           ),//(i)
        .i_reg01C8                     (coe10                          ),//(i)
        .i_reg01CC                     (coe11                          ),//(i)
        .i_reg01D0                     (coe12                          ),//(i)
        .i_reg01D4                     (coe13                          ),//(i)
        .i_reg01D8                     (coe14                          ),//(i)
        .i_reg01DC                     (coe15                          ),//(i)
        .i_reg01E0                     (coe16                          ),//(i)
        .i_reg01E4                     (coe17                          ),//(i)
        .i_reg01E8                     (coe18                          ),//(i)
        .i_reg01EC                     (coe_dec                        ),//(i)
        .i_reg01F0                     (32'd0                          ),//(i)
        .i_reg01F4                     (32'd0                          ),//(i)
        .i_reg01F8                     (32'd0                          ),//(i)
        .i_reg01FC                     (32'd0                          ),//(i)

        .i_reg0220                     (last_pkt_cnt                   ),//(i) 16'h0240     
        .i_reg0224                     (buff_clr_cnt                   ),//(i) 16'h0244     
        .i_reg0228                     (enc_sop_eop_cnt                ),//(i) 16'h0248     
        .i_reg022C                     (eds_sop_eop_cnt                ),//(i) 16'h024C     
        .i_reg0230                     (fbc_sop_eop_cnt                ),//(i) 16'h0250     
        .i_reg0234                     (32'd0                          ),//(i) 16'h0254     
        .i_reg0238                     (32'd0                          ),//(i) 16'h0258     
        .i_reg023C                     (32'd0                          ),//(i) 16'h025C     
        .i_reg0240                     (32'd0                          ),//(i) 16'h0240     
        .i_reg0244                     (32'd0                          ),//(i) 16'h0244     
        .i_reg0248                     (32'd0                          ),//(i) 16'h0248     
        .i_reg024C                     (32'd0                          ),//(i) 16'h024C     
        .i_reg0250                     (32'd0                          ),//(i) 16'h0250     
        .i_reg0254                     (32'd0                          ),//(i) 16'h0254     
        .i_reg0258                     (32'd0                          ),//(i) 16'h0258     
        .i_reg025C                     (32'd0                          ),//(i) 16'h025C     
        .i_reg0260                     (32'd0                          ),//(i) 16'h0260     
        .i_reg0264                     (32'd0                          ),//(i) 16'h0264     
        .i_reg0268                     (32'd0                          ),//(i) 16'h0268     
        .i_reg026C                     (32'd0                          ),//(i) 16'h026C     
        .i_reg0270                     (32'd0                          ),//(i) 16'h0270     
        .i_reg0274                     (32'd0                          ),//(i) 16'h0274     
        .i_reg0278                     (32'd0                          ),//(i) 16'h0278     
        .i_reg027C                     (32'd0                          ),//(i) 16'h027C     
        .i_reg0280                     (adc_0_pat_err_cnt              ),//(i) 16'h0280     
        .i_reg0284                     (adc_1_pat_err_cnt              ),//(i) 16'h0284     
        .i_reg0288                     (adc_2_pat_err_cnt              ),//(i) 16'h0288     
        .i_reg028C                     (adc_3_pat_err_cnt              ),//(i) 16'h028C     
        .i_reg0290                     (adc_4_pat_err_cnt              ),//(i) 16'h0290     
        .i_reg0294                     (adc_5_pat_err_cnt              ),//(i) 16'h0294     
        .i_reg0298                     (adc_6_pat_err_cnt              ),//(i) 16'h0298     
        .i_reg029C                     (adc_7_pat_err_cnt              ),//(i) 16'h029C     


        .o_rega0                       (                               ),//(o) 16'h00A0     
        .o_rega1                       (                               ),//(o) 16'h00A4     
        .o_rega2                       (                               ),//(o) 16'h00A8     
        .o_rega3                       (aurora_cfg                     ),//(o) 16'h00AC     
        .o_rega4                       (adc_ctrl0                      ),//(o) 16'h00B0     
        .o_rega5                       (adc_ctrl1                      ),//(o) 16'h00B4     
        .o_rega6                       (adc_ctrl2                      ),//(o) 16'h00B8     
        .o_rega7                       (adc_ctrl3                      ),//(o) 16'h00BC     
        .o_regb0                       (cfg_acc_en                     ),//(o) 16'h00C0     
        .o_regb1                       (acc_zoom_coe                   ),//(o) 16'h00C4     
        .o_regb2                       (remap_en                       ),//(o) 16'h00C8     
        .o_regb3                       (ad5674_cfg                     ),//(o) 16'h00CC     
        .o_regb4                       (adc_rm_num                     ),//(o) 16'h00D0     
        .o_regb5                       (enc_rm_num                     ),//(o) 16'h00D4     
        .o_regb6                       (ad5592_1_adc_config_en         ),//(o) 16'h00D8     
        .o_regb7                       (ad5592_1_adc_channel           ),//(o) 16'h00DC   	
        .o_regc0                       (ad5592_1_dac_config_en         ),//(o) 16'h00E0     
        .o_regc1                       (ad5592_1_dac_channel           ),//(o) 16'h00E4     
        .o_regc2                       (ad5592_1_dac_data              ),//(o) 16'h00E8     
        .o_regc3                       ({sfpga_rst,ddr_test_en}        ),//(o) 16'h00EC     
        .o_regc4                       ({ad7680_rd_en,temp_rd_en}      ),//(o) 16'h00F0     
        .o_regc5                       ({eeprom_r_addr_en,eeprom_w_en }),//(o) 16'h00F4     
        .o_regc6                       (eeprom_w_addr_data             ),//(o) 16'h00F8     
        .o_regc7                       (eeprom_r_addr                  ),//(o) 16'h00FC     
        .ad5674_trig                   (ad5674_trig                    ),//(o) 16'h00CC WR
        .hv_en                         (spi_hv_en                      ),//(o) 16'h0020
        .hv_pmt_trig                   (max5216_din_en                 ),//(o) 16'h001C WR
        .hv_pmt_data                   (max5216_din                    ),//(o) 16'h001C
        .debug_info                    (                               )
    );

//  assign   adc_enable        =        adc_ctrl0[3];    //16'h00B0    
//  assign   ena_cpl           =        adc_ctrl0[0];    //16'h00B0    
    assign   adc_enable        =        1'b1        ;    //16'h00B0    
    assign   ena_cpl           =        1'b1        ;    //16'h00B0    
    assign   fir_en            =        adc_ctrl0[1];    //16'h00B0    
    assign   fbc_cpl_en        =        adc_ctrl3[0];    //16'h00BC    


    assign   scan_local        =        adc_ctrl1[0];    //16'h00B4    
    assign   encode_local      =        adc_ctrl1[1];    //16'h00B4    
    assign   encode_flag_test  =        adc_ctrl1[2];    //16'h00B4    
    assign   clear_buffer      =        adc_ctrl1[7] || adc_clr_buff || eds_fbc_clr_buff || adc_ctrl2[0];  
    assign   clear_buffer_noeds=        adc_ctrl1[7] || adc_clr_buff                     || adc_ctrl2[0];  
    assign   cfg_cpl           =        adc_ctrl1[8];  




    //-----------------------------------------------------------------------------------
    // sfpga_inf_top Module Inst.                                                    
    //-----------------------------------------------------------------------------------
    sfpga_inf_top #(                                                          
        .SIM                           (SIM                            )       
    )u_sfpga_inf_top( 
        .clk_100m                      (clk_100m                       ),//(i)
        .rst_100m                      (~hmc7044_config_ok             ),//(i)
        .sfpga_rst                     (sfpga_rst  || fbc_cpl          ),//(i)
        .fir_tap_vld_cnt               (fir_tap_vld_cnt                ),//(o)
        .bias_tap_vld_cnt              (bias_tap_vld_cnt               ),//(o)
        
        .ddr_rd_addr                   (ddr_rd1_addr                   ),//(o)
        .ddr_rd_en                     (ddr_rd1_en                     ),//(o)
        .readback_vld                  (readback1_vld                  ),//(i)
        .readback_last                 (readback1_last                 ),//(i)
        .readback_data                 (readback1_data                 ),//(i)
        .fir_tap_wr_cmd                (fir_tap_wr_cmd                 ),//(o)
        .fir_tap_wr_addr               (fir_tap_wr_addr                ),//(o)
        .fir_tap_wr_vld                (fir_tap_wr_vld                 ),//(o)
        .fir_tap_wr_data               (fir_tap_wr_data                ),//(o)
        .bias_tap_wr_cmd               (bias_tap_wr_cmd                ),//(o)
        .bias_tap_wr_addr              (bias_tap_wr_addr               ),//(o)
        .bias_tap_wr_vld               (bias_tap_wr_vld                ),//(o)
        .bias_tap_wr_data              (bias_tap_wr_data               ),//(o)
        
        .SLAVE_MSG_CLK                 (FPGA_TO_SFPGA_RESERVE0         ),//(i)
        .SLAVE_MSG_TX_FSX              (FPGA_TO_SFPGA_RESERVE3         ),//(o)
        .SLAVE_MSG_TX                  (FPGA_TO_SFPGA_RESERVE4         ),//(o)
        .SLAVE_MSG_RX_FSX              (FPGA_TO_SFPGA_RESERVE1         ),//(i)
        .SLAVE_MSG_RX                  (FPGA_TO_SFPGA_RESERVE2         ) //(i)
    );                                                                       

    //-----------------------------------------------------------------------------------
    // ddr_top Module Inst.                                                    
    //-----------------------------------------------------------------------------------
    ddr_top #(                                                                            
        .DDR_DATA_WD                   (512                            ),
        .DDR_ADDR_WD                   (32                             ),
        .DDR3_SIM                      (DDR3_SIM                       ),
        .MAX_BLK_SIZE                  (MAX_BLK_SIZE                   ),
        .FIFO_DPTH                     (2048                           ),
        .WR_DATA_WD                    (512                            ),
        .RD_DATA_WD                    (128                            ),//aurora
        .BURST_LEN                     (64                             ),
        .BASE_ADDR                     (32'h0000_0000                  )       
    )u_ddr_top( 
        .sim_ddr_clk                   (clk_125m                       ),//(i)
        .sys_clk_p                     (ddr_clk_p                      ),//(i)
        .sys_clk_n                     (ddr_clk_n                      ),//(i)
        .sys_rst_n                     (pll_locked                     ),//(i)
        .ddr_clk                       (ddr_clk                        ),//(o)
        .ddr_rst_n                     (ddr_rst_n                      ),//(o)
        .cfg_rst                       (clear_buffer_noeds || sfpga_rst),//(i)
        .cfg_test_en                   (ddr_test_en                    ),//(i)
        .sts_suc_cnt                   (sts_suc_cnt                    ),//(o)
        .sts_err_cnt                   (sts_err_cnt                    ),//(o)
        .sts_err_lock                  (sts_err_lock                   ),//(o)
        .wr_clk                        (clk_32m                        ),//(i)
        .wr_rst_n                      (hmc7044_config_ok              ),//(i)
        .ch0_fifo_wr                   ('d0       /*ch0_fifo_wr       */),//(i)
        .ch0_fifo_din                  ('d0       /*ch0_fifo_din      */),//(i)
        .ch0_fifo_full                 (          /*ch0_fifo_full     */),//(o)
        .ch0_fifo_full_cnt             (          /*ch0_fifo_full_cnt */),//(o)
        .rd_clk                        (auro_user_clk                   ),//(i)
        .rd_rst_n                      (auro_rst_n                      ),//(i)
        .ch0_fifo_rd                   (1'b0      /*adc_fifo_rd   */    ),//(i)
        .ch0_fifo_dout                 (          /*adc_fifo_din  */    ),//(o)
        .ch0_fifo_empty                (          /*adc_fifo_empty*/    ),//(o)

        .fir_clk                       (clk_100m                       ),//(i)
        .fir_rst_n                     (hmc7044_config_ok              ),//(i)
        .ddr_rd0_en                    (ddr_rd0_en                     ),//(i)
        .ddr_rd0_addr                  (ddr_rd0_addr                   ),//(i)
        .ddr_rd1_en                    (ddr_rd1_en                     ),//(i)
        .ddr_rd1_addr                  (ddr_rd1_addr                   ),//(i)
        .readback0_vld                 (readback0_vld                  ),//(o)
        .readback0_last                (readback0_last                 ),//(o)
        .readback0_data                (readback0_data                 ),//(o)
        .readback1_vld                 (readback1_vld                  ),//(o)
        .readback1_last                (readback1_last                 ),//(o)
        .readback1_data                (readback1_data                 ),//(o)
        .fir_tap_wr_cmd                (fir_tap_wr_cmd                 ),//(i)
        .fir_tap_wr_addr               (fir_tap_wr_addr                ),//(i)
        .fir_tap_wr_vld                (fir_tap_wr_vld                 ),//(i)
        .fir_tap_wr_data               (fir_tap_wr_data                ),//(i)


        .ddr3_dq                       (ddr3_dq                        ),//(io)
        .ddr3_dqs_n                    (ddr3_dqs_n                     ),//(io)
        .ddr3_dqs_p                    (ddr3_dqs_p                     ),//(io)
        .ddr3_addr                     (ddr3_addr                      ),//(o)
        .ddr3_ba                       (ddr3_ba                        ),//(o)
        .ddr3_ras_n                    (ddr3_ras_n                     ),//(o)
        .ddr3_cas_n                    (ddr3_cas_n                     ),//(o)
        .ddr3_we_n                     (ddr3_we_n                      ),//(o)
        .ddr3_reset_n                  (ddr3_reset_n                   ),//(o)
        .ddr3_ck_p                     (ddr3_ck_p                      ),//(o)
        .ddr3_ck_n                     (ddr3_ck_n                      ),//(o)
        .ddr3_cke                      (ddr3_cke                       ),//(o)
        .ddr3_cs_n                     (ddr3_cs_n                      ),//(o)
        .ddr3_dm                       (ddr3_dm                        ),//(o)
        .ddr3_odt                      (ddr3_odt                       ),//(o)
        .init_calib_complete           (ddr3_init_done                 ) //(o)
    );                                                                      


    //-----------------------------------------------------------------------------------
    // aurora_inf_top Module Inst.                                                    
    //-----------------------------------------------------------------------------------
    aurora_inf_top #(                                                          
        .DATA_WD                       (128                            ),
        .ADC_CNT_WD                    ( 11                            ),
        .HEAD_WD                       ( 64                            ),
        .CFG_WD                        ( 32                            ),
        .SIM                           (SIM                            )        
    )u_aurora_inf_top( 
        //.mmcm_locked                   (hmc7044_config_ok              ),//(i)
        .mmcm_locked                   (pll_locked                     ),//(i)
        .init_clk                      (clk_100m                       ),//(i)
        .clk_32m                       (clk_32m                        ),//(i) 32M
        .enc_vld                       (enc_vld                        ),//(o)
        .enc_data                      (enc_data                       ),//(o)

        .rst_n                         (auro_rst_n                     ),//(i) user_clk  notice~
        .user_clk                      (auro_user_clk                  ),//(o)
        .cfg_rst                       (clear_buffer                   ),//(i)
        .eds_fbc_clr_buff              (eds_fbc_clr_buff               ),//(i)
        .ena_cpl                       (ena_cpl                        ),//(i)
        .cfg_cpl                       (cfg_cpl                        ),//(i)
        .adc_cpl                       (scan_cpl                       ),//(i) 
        .eds_cpl                       (eds_cpl                        ),//(o)
        .fbc_cpl                       (fbc_cpl                        ),//(o)
        .fbc_cpl_en                    (fbc_cpl_en                     ),//(i)
        .pop_end_pkt                   (pop_end_pkt                    ),//(o)
        .channel_up                    (                               ),//(o)
        .channel_up1                   (                               ),//(o)
        .adc_enable                    (adc_enable                     ),//(i)
        .head_rd                       (head_rd                        ),//(i) 
        .head_din                      (head_din                       ),//(o) 
        .adc_fifo_rd                   (adc_fifo_rd                    ),//(o)
        .adc_fifo_din                  (adc_fifo_din                   ),//(i)
        .adc_fifo_empty                (adc_fifo_empty                 ),//(i)
        .adc_fifo_data_cnt             (16'd8                          ),//(i)
        .gt_refclk1_p                  (SFP_MGT_REFCLK_C_P             ),//(i)
        .gt_refclk1_n                  (SFP_MGT_REFCLK_C_N             ),//(i)
        .gt_refclk2_p                  (SFP0_MGT_REFCLK_C_P            ),//(i)
        .gt_refclk2_n                  (SFP0_MGT_REFCLK_C_N            ),//(i)
        .rxp                           ({FPGA_SFP4_RX_P,FPGA_SFP3_RX_P}),//(i)
        .rxn                           ({FPGA_SFP4_RX_N,FPGA_SFP3_RX_N}),//(i)
        .txp                           ({FPGA_SFP4_TX_P,FPGA_SFP3_TX_P}),//(o)
        .txn                           ({FPGA_SFP4_TX_N,FPGA_SFP3_TX_N}),//(o)
        .rxp1                          ({FPGA_SFP1_RX_P}               ),//(i)
        .rxn1                          ({FPGA_SFP1_RX_N}               ),//(i)
        .txp1                          ({FPGA_SFP1_TX_P}               ),//(o)
        .txn1                          ({FPGA_SFP1_TX_N}               ),//(o)
        .adc_pkt_sop_eop_cnt           (adc_pkt_sop_eop_cnt            ),//(o)
        .enc_sop_eop_cnt               (enc_sop_eop_cnt                ),//(o)
        .enc_sop_eop_clr_cnt           (enc_sop_eop_clr_cnt            ),//(o)
        .enc_vld_cnt                   (enc_vld_cnt                    ),//(o)
        .eds_fifo_full_cnt             (eds_fifo_full_cnt              ),//(o)
        .eds_sop_eop_cnt               (eds_sop_eop_cnt                ),//(o)
        .eds_sop_eop_clr_cnt           (eds_sop_eop_clr_cnt            ),//(o)
        .fbc_sop_eop_cnt               (fbc_sop_eop_cnt                ),//(o)
        .eds_vld_cnt                   (eds_vld_cnt                    ),//(o)
        .last_pkt_cnt                  (last_pkt_cnt                   ),//(o)
        .buff_clr_cnt                  (buff_clr_cnt                   ),//(o)
        .aurora_cfg                    (aurora_cfg                     ),//(i)
        .aurora_sts                    (aurora_sts                     ),//(o)
        .aurora_soft_err_cnt           (aurora_soft_err_cnt            ),//(o)
        
        .tx_total_vld_cnt              (tx_total_vld_cnt               ),//(o)
        .tx_adc_chk_suc_cnt            (tx_adc_chk_suc_cnt             ),//(o)
        .tx_adc_chk_err_cnt            (tx_adc_chk_err_cnt             ),//(o)
        .tx_enc_chk_suc_cnt            (tx_enc_chk_suc_cnt             ),//(o)
        .tx_enc_chk_err_cnt            (tx_enc_chk_err_cnt             ) //(o)
    ); 



    // -------------------------------------------------------------------------
    // slow_device_top Module Inst.
    // -------------------------------------------------------------------------
    slow_device_top #(                                                 
        .TEST                          (0                              )       
    )u_slow_device_top(                                                       
        .clk_100m                      (clk_100m                       ),//(i)
        .rst                           (rst                            ),//(i)
        .HMC7044_SYNC                  (HMC7044_SYNC                   ),//(o)
        .HMC7044_1_RESET_LS            (HMC7044_1_RESET_LS             ),//(o)
        .HMC7044_1_SLEN_LS             (HMC7044_1_SLEN_LS              ),//(o)
        .HMC7044_1_SCLK_LS             (HMC7044_1_SCLK_LS              ),//(o)
        .HMC7044_1_SDATA_LS            (HMC7044_1_SDATA_LS             ),//(io)
        .HMC7044_1_GPIO1_LS            (HMC7044_1_GPIO1_LS             ),//(i)
        .HMC7044_1_GPIO2_LS            (HMC7044_1_GPIO2_LS             ),//(i)
        .EEPROM_CS_B                   (EEPROM_CS_B                    ),//(o)
        .EEPROM_SO                     (EEPROM_SO                      ),//(i)
        .EEPROM_SI                     (EEPROM_SI                      ),//(o)
        .EEPROM_WP_B                   (EEPROM_WP_B                    ),//(o)
        .EEPROM_SCK                    (EEPROM_SCK                     ),//(o)
        .TMP75_IIC_SDA                 (TMP75_IIC_SDA                  ),//(io)
        .TMP75_IIC_SCL                 (TMP75_IIC_SCL                  ),//(o)
        .TMP75_ALERT                   (TMP75_ALERT                    ),//(i)
        .AD5592_1_SPI_CS_B             (AD5592_1_SPI_CS_B              ),//(o)
        .AD5592_1_SPI_CLK              (AD5592_1_SPI_CLK               ),//(o)
        .AD5592_1_SPI_MOSI             (AD5592_1_SPI_MOSI              ),//(o)
        .AD5592_1_SPI_MISO             (AD5592_1_SPI_MISO              ),//(i)
        .MAX5216_CS                    (MAX5216_CS                     ),//(o) 
        .MAX5216_CLR                   (MAX5216_CLR                    ),//(o) 
        .MAX5216_DIN                   (MAX5216_DIN                    ),//(o) 
        .MAX5216_CLK                   (MAX5216_CLK                    ),//(o) 
        .AD7680_SCLK                   (AD7680_SCLK                    ),//(o) 
        .AD7680_CS                     (AD7680_CS                      ),//(o) 
        .AD7680_DATA                   (AD7680_DATA                    ),//(i) 
        .AD5674_1_SPI_CLK              (AD5674_1_SPI_CLK               ),//(o)
        .AD5674_1_SPI_CS               (AD5674_1_SPI_CS                ),//(o)
        .AD5674_1_SPI_SDO              (AD5674_1_SPI_SDO               ),//(i)
        .AD5674_1_SPI_SDI              (AD5674_1_SPI_SDI               ),//(o)
        .AD5674_1_SPI_RESET            (AD5674_1_SPI_RESET             ),//(o)
        .AD5674_1_SPI_LDAC             (AD5674_1_SPI_LDAC              ),//(o)
        .AD5674_2_SPI_CLK              (AD5674_2_SPI_CLK               ),//(o)
        .AD5674_2_SPI_CS               (AD5674_2_SPI_CS                ),//(o)
        .AD5674_2_SPI_SDO              (AD5674_2_SPI_SDO               ),//(i)
        .AD5674_2_SPI_SDI              (AD5674_2_SPI_SDI               ),//(o)
        .AD5674_2_SPI_RESET            (AD5674_2_SPI_RESET             ),//(o)
        .AD5674_2_SPI_LDAC             (AD5674_2_SPI_LDAC              ),//(o)


        .hmc7044_1_config_ok           (hmc7044_1_config_ok            ),//(o)
        .ad5592_1_dac_config_en        (ad5592_1_dac_config_en         ),//(i)
        .ad5592_1_dac_channel          (ad5592_1_dac_channel           ),//(i)
        .ad5592_1_dac_data             (ad5592_1_dac_data              ),//(i)
        .ad5592_1_adc_config_en        (ad5592_1_adc_config_en         ),//(i)
        .ad5592_1_adc_channel          (ad5592_1_adc_channel           ),//(i)
        .ad5592_1_spi_conf_ok          (ad5592_1_spi_conf_ok           ),//(o)
        .ad5592_1_adc_data_lock        (ad5592_1_adc_data_lock         ),//(o)
        .ad5592_1_init                 (ad5592_1_init                  ),//(o)
        .temp_rd_en                    (temp_rd_en                     ),//(i)
        .temp_data_lock                (temp_data_lock                 ),//(o)
        .eeprom_w_en                   (eeprom_w_en                    ),//(i)
        .eeprom_w_addr_data            (eeprom_w_addr_data             ),//(i)
        .eeprom_r_addr_en              (eeprom_r_addr_en               ),//(i)
        .eeprom_r_addr                 (eeprom_r_addr                  ),//(i)
        .eeprom_r_data_lock            (eeprom_r_data_lock             ),//(o)
        .max5216_din_en                (max5216_din_en                 ),//(i)
        .max5216_din                   (max5216_din                    ),//(i)
        .ad7680_rd_en                  (ad7680_rd_en                   ),//(i)
        .ad7680_dout_en                (ad7680_dout_en                 ),//(o)
        .ad7680_dout                   (ad7680_dout                    ),//(o)
        .ad7680_dout_lock              (ad7680_dout_lock               ),//(o)

        .bias_tap_wr_cmd               (bias_tap_wr_cmd                ),//(i)
        .bias_tap_wr_addr              (bias_tap_wr_addr               ),//(i)
        .bias_tap_wr_vld               (bias_tap_wr_vld                ),//(i)
        .bias_tap_wr_data              (bias_tap_wr_data               ),//(i)
        .ch0_ad5674_trig               (ad5674_trig                    ),//(i)
        .ch0_ad5674_cmd                (ad5674_cfg[31:24]              ),//(i)
        .ch0_ad5674_ch                 (ad5674_cfg[23:16]              ),//(i)
        .ch0_ad5674_din                (ad5674_cfg[15:0]               ),//(i)
        .ad5674_dout1                  (ad5674_dout1                   ),//(o) //nouse
        .ad5674_dout2                  (ad5674_dout2                   ),//(o) //nouse
        .ad5674_dout                   (ad5674_dout                    ),//(o) 
        .vio_hv_en                     (vio_hv_en                      ) //(o)
    );                                                                        


    // -------------------------------------------------------------------------
    // SIM Module Inst.
    // -------------------------------------------------------------------------
generate if(SIM == 0)begin
    assign            hmc7044_config_ok   =     hmc7044_1_config_ok        ;
end else begin
    assign            hmc7044_config_ok     =     ~rst                     ;
end
endgenerate












endmodule



















