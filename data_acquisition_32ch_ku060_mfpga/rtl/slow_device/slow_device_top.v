module slow_device_top #(
    parameter                               TEST        =      16           
)(
    input                                   clk_100m                       ,//(i)
    input                                   rst                            ,//(i)
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
    //MAX5216 
    output                                  MAX5216_CS                     ,//(o) 
    output                                  MAX5216_CLR                    ,//(o) 
    output                                  MAX5216_DIN                    ,//(o) 
    output                                  MAX5216_CLK                    ,//(o) 
    //AD7680              
    output                                  AD7680_SCLK                    ,//(o) 
    output                                  AD7680_CS                      ,//(o) 
    input                                   AD7680_DATA                    ,//(i) 
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

    output                                  hmc7044_1_config_ok            ,//(o)
    input                                   ad5592_1_dac_config_en         ,//(i)
    input               [2:0]               ad5592_1_dac_channel           ,//(i)
    input               [11:0]              ad5592_1_dac_data              ,//(i)
    input                                   ad5592_1_adc_config_en         ,//(i)
    input               [7:0]               ad5592_1_adc_channel           ,//(i)
    output                                  ad5592_1_spi_conf_ok           ,//(o)
    output   reg        [11:0]              ad5592_1_adc_data_lock         ,//(o)
    output                                  ad5592_1_init                  ,//(o)
    input                                   temp_rd_en                     ,//(i)
    output   reg        [11:0]              temp_data_lock                 ,//(o)
    input                                   eeprom_w_en                    ,//(i)
    input               [31:0]              eeprom_w_addr_data             ,//(i)
    input                                   eeprom_r_addr_en               ,//(i)
    input               [15:0]              eeprom_r_addr                  ,//(i)
    output   reg        [7:0]               eeprom_r_data_lock             ,//(o)

    input                                   max5216_din_en                 ,//(i)
    input               [15:0]              max5216_din                    ,//(i)
    input                                   ad7680_rd_en                   ,//(i)
    output                                  ad7680_dout_en                 ,//(o)
    output              [15:0]              ad7680_dout                    ,//(o)
    output   reg        [15:0]              ad7680_dout_lock               ,//(o)
    

    input                                   bias_tap_wr_cmd                ,//(i)
    input         [32-1:0]                  bias_tap_wr_addr               ,//(i)
    input                                   bias_tap_wr_vld                ,//(i)
    input         [32-1:0]                  bias_tap_wr_data               ,//(i)
    input                                   ch0_ad5674_trig                ,//(i)
    input         [3:0]                     ch0_ad5674_cmd                 ,//(i)
    input         [4:0]                     ch0_ad5674_ch                  ,//(i)
    input         [15:0]                    ch0_ad5674_din                 ,//(i)
    
    output        [23:0]                    ad5674_dout1                   ,//(o)
    output        [23:0]                    ad5674_dout2                   ,//(o)
    output        [23:0]                    ad5674_dout                    ,//(o)
    
    output                                  vio_hv_en                       //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                      vio_ad5592_1_dac_config_en     ;
    wire                [2:0]                 vio_ad5592_1_dac_channel       ;
    wire                [11:0]                vio_ad5592_1_dac_data          ;
    wire                                      ad5592_1_adc_data_en           ;
    wire                [11:0]                ad5592_1_adc_data              ;
    wire                                      temp_data_en                   ;
    wire                [11:0]                temp_data                      ;
    wire                                      eeprom_r_data_en               ;
    wire                [7:0]                 eeprom_r_data                  ;

    wire                                      vio_max5216_din_en             ;//(i)
    wire                [15:0]                vio_max5216_din                ;//(i)
    wire                                      vio_ad7680_rd_en               ;//(i)

    wire                                      ad5674_trig                    ;
    wire                [3:0]                 ad5674_cmd                     ;
    wire                [4:0]                 ad5674_ch                      ;
    wire                [15:0]                ad5674_din                     ;
    
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    //assign            m_axis_tkeep   =     {(DATA_WD/8){1'b1}}             ;

// =================================================================================================
// RTL Body
// =================================================================================================


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
        .VCO_L_H          (2'b01                   ),//2'b01:high VCO 2'b10:low VCO
        .CHANNEL_EN       (8'b1100_1111            ),
        .PLL2_R2          (12'd1                   ),
        .PLL2_N2          (12'd32                  ),
        .CLKEN            (14'b110000_11111111     )
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
        .hmc7044_config_ok(hmc7044_1_config_ok    )
     );

    // -------------------------------------------------------------------------
    // ad5592 Module Inst.
    // -------------------------------------------------------------------------
//  vio_ad5592 u_vio_ad5592 (
//      .clk           (clk_100m                  ),// input wire clk
//      .probe_out0    (vio_ad5592_1_dac_config_en),// output wire [0 : 0] probe_out0
//      .probe_out1    (vio_ad5592_1_dac_channel  ),// output wire [2 : 0] probe_out1
//      .probe_out2    (vio_ad5592_1_dac_data     ) // output wire [11: 0] probe_out2
//  );
    
    
    ad5592_config #(
        .ADC_IO_REG    (16'b0010000010000011   ),    //ADC:IO0,IO1,IO7
        .DAC_IO_REG    (16'b0010100001111100   )     //DAC:IO2,IO3,IO4,IO5,IO6
    ) ad5592_config_inst1(
        .clk           (clk_100m               ),
        .rst           (rst                    ),
        .dac_config_en (ad5592_1_dac_config_en || vio_ad5592_1_dac_config_en),
        .dac_channel   (ad5592_1_dac_channel   +  vio_ad5592_1_dac_channel  ),
        .dac_data      (ad5592_1_dac_data      +  vio_ad5592_1_dac_data     ),
        .adc_config_en (ad5592_1_adc_config_en ),
        .adc_channel   (ad5592_1_adc_channel   ),
        .spi_csn       (AD5592_1_SPI_CS_B      ),
        .spi_clk       (AD5592_1_SPI_CLK       ),
        .spi_mosi      (AD5592_1_SPI_MOSI      ),
        .spi_miso      (AD5592_1_SPI_MISO      ),
        .spi_conf_ok   (ad5592_1_spi_conf_ok   ),
        .init          (ad5592_1_init          ),
        .adc_data_en   (ad5592_1_adc_data_en   ),
        .adc_data      (ad5592_1_adc_data      )    
    );

    always@(posedge clk_100m or posedge rst)begin
        if(rst)
            ad5592_1_adc_data_lock <= 'd0;
        else if(ad5592_1_adc_data_en)
            ad5592_1_adc_data_lock <= ad5592_1_adc_data;
    end

    // -------------------------------------------------------------------------
    // eeprom Module Inst.
    // -------------------------------------------------------------------------
    tmp75 tmp75_inst(
        .clk           (clk_100m               ),
        .rst           (rst                    ),
        .TEMP_SCL      (TMP75_IIC_SCL          ),
        .TEMP_SDA      (TMP75_IIC_SDA          ),
        .TEMP_RD_en    (temp_rd_en             ),
        .TEMP_DATA     (temp_data              ),
        .TEMP_DATA_en  (temp_data_en           )
    );
    
    always@(posedge clk_100m or posedge rst)begin
        if(rst)
            temp_data_lock <= 'd0;
        else if(temp_data_en)
            temp_data_lock <= temp_data;
    end

    // -------------------------------------------------------------------------
    // eeprom Module Inst.
    // -------------------------------------------------------------------------
    eeprom eeprom_inst(
        .clk           (clk_100m               ), 
        .rst           (rst                    ),
        .addr_data_w   (eeprom_w_addr_data     ),
        .addr_data_w_en(eeprom_w_en            ),
        .addr_r        (eeprom_r_addr          ),
        .addr_r_en     (eeprom_r_addr_en       ),
        .data_r        (eeprom_r_data          ),
        .data_r_en     (eeprom_r_data_en       ),
        .spi_cs        (EEPROM_CS_B            ),
        .spi_sck       (EEPROM_SCK             ),
        .spi_dout      (EEPROM_SI              ),
        .spi_din       (EEPROM_SO              ),
        .eeprom_wp_n   (EEPROM_WP_B            ),
        .eeprom_hold_n (                       ),
        .spi_ok        (                       )
    );


    always@(posedge clk_100m or posedge rst)begin
        if(rst)
            eeprom_r_data_lock <= 'd0;
        else if(eeprom_r_data_en)
            eeprom_r_data_lock <= eeprom_r_data;
    end



    // -------------------------------------------------------------------------
    // max5216_spi_if Module Inst.
    // -------------------------------------------------------------------------
    max5216_spi_if max5216_spi_if_inst(
        .clk           (clk_100m               ),//(i) 
        .rst           (rst                    ),//(i)
        .data_in_en    (max5216_din_en || vio_max5216_din_en),//(i)
        .data_in       (max5216_din     + vio_max5216_din   ),//(i)
        .spi_csn       (MAX5216_CS             ),//(o)
        .spi_clk       (MAX5216_CLK            ),//(o)//max 50M
        .spi_mosi      (MAX5216_DIN            ),//(o)
        .clr_n         (MAX5216_CLR            ),//(o)
        .spi_ok        (                       ) //(o)
    );

    // -------------------------------------------------------------------------
    // ad7680_spi_if Module Inst.
    // -------------------------------------------------------------------------
    ad7680_spi_if u_ad7680_spi_if( 
        .clk           (clk_100m               ),//(i)
        .rst           (rst                    ),//(i)
        .adc_rd_en     (ad7680_rd_en||vio_ad7680_rd_en),//(i)
        .spi_csn       (AD7680_CS              ),//(o)
        .spi_clk       (AD7680_SCLK            ),//(o)
        .spi_miso      (AD7680_DATA            ),//(i)
        .data_out_en   (ad7680_dout_en         ),//(o)
        .data_out      (ad7680_dout            ) //(o)
    );                                                  

    always@(posedge clk_100m or posedge rst)begin
        if(rst)
            ad7680_dout_lock <= 'd0;
        else if(ad7680_dout_en)
            ad7680_dout_lock <= ad7680_dout;
    end




    // -------------------------------------------------------------------------
    // ad5674_driver Module Inst.
    // -------------------------------------------------------------------------
    wire                                   ad5674_cm_trig                 ;
    wire         [11:0]                    ad5674_cm_din                  ;

//  vio_ad5674 u_vio_ad5674(
//      .clk                 (clk_100m             ),  // input wire clk
//      .probe_in0           (ad7680_dout_lock     ),  // input wire [15 : 0] probe_in0
//      .probe_out0          (ad5674_cm_trig       ),  // output wire [0 : 0] probe_out0
//      .probe_out1          (ad5674_cm_din        ),  // output wire [11 : 0] probe_out1
//      .probe_out2          (vio_max5216_din_en   ),  // output wire [0 : 0] probe_out2
//      .probe_out3          (vio_max5216_din      ),  // output wire [15 : 0] probe_out3
//      .probe_out4          (vio_ad7680_rd_en     ),  // output wire [0 : 0] probe_out4
//      .probe_out5          (vio_hv_en            )   // output wire [0 : 0] probe_out5
//  );



    ad5674_easy_ctrl u_ad5674_easy_ctrl( 
        .clk                 (clk_100m             ),//(i)
        .rst_n               (~rst                 ),//(i)
        .bias_tap_wr_cmd     (bias_tap_wr_cmd      ),//(o)
        .bias_tap_wr_addr    (bias_tap_wr_addr     ),//(o)
        .bias_tap_wr_vld     (bias_tap_wr_vld      ),//(o)
        .bias_tap_wr_data    (bias_tap_wr_data     ),//(o)

        .ch0_ad5674_trig     (ch0_ad5674_trig      ),//(i)
        .ch0_ad5674_cmd      (ch0_ad5674_cmd       ),//(i)
        .ch0_ad5674_ch       (ch0_ad5674_ch        ),//(i)
        .ch0_ad5674_din      (ch0_ad5674_din       ),//(i)

        .ad5674_trig         (ad5674_trig          ),//(o)
        .ad5674_cmd          (ad5674_cmd           ),//(o)
        .ad5674_ch           (ad5674_ch            ),//(o)
        .ad5674_din          (ad5674_din           ) //(o)
    );                                             

    
    ad5674_driver  u_ad5674_driver( 
        .clk                 (clk_100m             ),//(i)
        .rst_n               (~rst                 ),//(i)
        .ad5674_trig         (ad5674_trig          ),//(i)
        .ad5674_cmd          (ad5674_cmd           ),//(i)
        .ad5674_ch           (ad5674_ch            ),//(i)
        .ad5674_din          (ad5674_din           ),//(i)
        .ad5674_dout1        (ad5674_dout1         ),//(o)
        .ad5674_dout2        (ad5674_dout2         ),//(o)
        .ad5674_dout         (ad5674_dout          ),//(o)
        .AD5674_1_SPI_CLK    (AD5674_1_SPI_CLK     ),//(o)
        .AD5674_1_SPI_CS     (AD5674_1_SPI_CS      ),//(o)
        .AD5674_1_SPI_SDO    (AD5674_1_SPI_SDO     ),//(i)
        .AD5674_1_SPI_SDI    (AD5674_1_SPI_SDI     ),//(o)
        .AD5674_1_SPI_RESET  (AD5674_1_SPI_RESET   ),//(o)
        .AD5674_1_SPI_LDAC   (AD5674_1_SPI_LDAC    ),//(o)
        .AD5674_2_SPI_CLK    (AD5674_2_SPI_CLK     ),//(o)
        .AD5674_2_SPI_CS     (AD5674_2_SPI_CS      ),//(o)
        .AD5674_2_SPI_SDO    (AD5674_2_SPI_SDO     ),//(i)
        .AD5674_2_SPI_SDI    (AD5674_2_SPI_SDI     ),//(o)
        .AD5674_2_SPI_RESET  (AD5674_2_SPI_RESET   ),//(o)
        .AD5674_2_SPI_LDAC   (AD5674_2_SPI_LDAC    ) //(o)
    );                                             
  




endmodule





