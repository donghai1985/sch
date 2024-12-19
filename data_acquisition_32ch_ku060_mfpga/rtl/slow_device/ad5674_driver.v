module ad5674_driver(                                
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)

    input                                   ad5674_trig                    ,//(i)
    input         [3:0]                     ad5674_cmd                     ,//(i)
    input         [4:0]                     ad5674_ch                      ,//(i)
    input         [15:0]                    ad5674_din                     ,//(i)
    output        [23:0]                    ad5674_dout1                   ,//(o)
    output        [23:0]                    ad5674_dout2                   ,//(o)
    output        [23:0]                    ad5674_dout                    ,//(o)
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
    output                                  AD5674_2_SPI_LDAC               //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------------------
    wire                                    trig1                           ;
    wire                                    trig2                           ;
    wire          [31:0]                    writedata1                      ;
    wire          [31:0]                    writedata2                      ;
    wire          [31:0]                    readdata1                       ;
    wire          [31:0]                    readdata2                       ;
    reg           [4 :0]                    map_ch                          ;
    wire                                    ad5674_trig_dly                 ;
    // -------------------------------------------------------------------------
    // Output
    // -------------------------------------------------------------------------
    assign       AD5674_1_SPI_RESET   =     rst_n                           ;
    assign       AD5674_1_SPI_LDAC    =     1'b0                            ;
    assign       AD5674_2_SPI_RESET   =     rst_n                           ;
    assign       AD5674_2_SPI_LDAC    =     1'b0                            ;
    assign       trig1                =    ~map_ch[4] && ad5674_trig_dly    ;
    assign       trig2                =     map_ch[4] && ad5674_trig_dly    ;
//  assign       writedata1           =    {8'h00,ad5674_din[3:0],4'h0,ad5674_din[11:4],ad5674_cmd,map_ch[3:0]};
//  assign       writedata2           =    {8'h00,ad5674_din[3:0],4'h0,ad5674_din[11:4],ad5674_cmd,map_ch[3:0]};
    assign       writedata1           =    {8'h00,ad5674_din[7:0],ad5674_din[15:8],ad5674_cmd,map_ch[3:0]};
    assign       writedata2           =    {8'h00,ad5674_din[7:0],ad5674_din[15:8],ad5674_cmd,map_ch[3:0]};

    assign       ad5674_dout1         =    {readdata1[7:0],readdata1[15:8],readdata1[23:16]};
    assign       ad5674_dout2         =    {readdata2[7:0],readdata2[15:8],readdata2[23:16]};
    assign       ad5674_dout          =    ~map_ch[4] ? ad5674_dout1 : ad5674_dout2;
// =================================================================================================
// RTL Body
// =================================================================================================

    cmip_bus_delay #(
        .BUS_DELAY            (3                  ),
        .DATA_WDTH            (1                  ),
        .INIT_DATA            (0                  )
    )u_cmip_bus_delay(                              
        .i_clk                (clk                ), 
        .i_rst_n              (rst_n              ), //low valid
        .i_din                (ad5674_trig        ),
        .o_dout               (ad5674_trig_dly    )
    );


    always@(posedge clk)begin
        case(ad5674_ch)         
            5'd15:  map_ch =  5'd0  ;
            5'd14:  map_ch =  5'd1  ;
            5'd13:  map_ch =  5'd2  ;
            5'd12:  map_ch =  5'd3  ;
            5'd4 :  map_ch =  5'd4  ;
            5'd5 :  map_ch =  5'd5  ;
            5'd6 :  map_ch =  5'd6  ;
            5'd7 :  map_ch =  5'd7  ;
            5'd8 :  map_ch =  5'd8  ;
            5'd9 :  map_ch =  5'd9  ;
            5'd10:  map_ch =  5'd10 ;
            5'd11:  map_ch =  5'd11 ;
            5'd2 :  map_ch =  5'd12 ;
            5'd3 :  map_ch =  5'd13 ;
            5'd1 :  map_ch =  5'd14 ;
            5'd0 :  map_ch =  5'd15 ;
            5'd31:  map_ch =  5'd16 ;
            5'd30:  map_ch =  5'd17 ;
            5'd29:  map_ch =  5'd18 ;
            5'd28:  map_ch =  5'd19 ;
            5'd20:  map_ch =  5'd20 ;
            5'd21:  map_ch =  5'd21 ;
            5'd22:  map_ch =  5'd22 ;
            5'd23:  map_ch =  5'd23 ;
            5'd24:  map_ch =  5'd24 ;
            5'd25:  map_ch =  5'd25 ;
            5'd26:  map_ch =  5'd26 ;
            5'd27:  map_ch =  5'd27 ;
            5'd19:  map_ch =  5'd28 ;
            5'd18:  map_ch =  5'd29 ;
            5'd17:  map_ch =  5'd30 ;
            5'd16:  map_ch =  5'd31 ;
        endcase
    end

    //---------------------------------------------------------------------
    // spi_rdwr_bytes Module Inst.
    //---------------------------------------------------------------------     
    spi_rdwr_bytes u0_spi_rdwr_bytes( 
        .clk              (clk                 ),//(i)
        .rst_n            (rst_n               ),//(i)
        .mode             (2'd2                ),//(i)
        .frediv           (3'd15               ),//(i)
        .cs_mode          (2'd0                ),//(i)
        .byte_num         (2'd2                ),//(i)
        .trig             (trig1               ),//(i)
        .finish           (                    ),//(o)
        .writedata        (writedata1          ),//(i)
        .readdata         (readdata1           ),//(o)
        .cs               (AD5674_1_SPI_CS     ),//(o)
        .sck              (AD5674_1_SPI_CLK    ),//(o)
        .mosi             (AD5674_1_SPI_SDI    ),//(o)
        .miso             (AD5674_1_SPI_SDO    ) //(i)
    );                                         

    spi_rdwr_bytes u1_spi_rdwr_bytes( 
        .clk              (clk                 ),//(i)
        .rst_n            (rst_n               ),//(i)
        .mode             (2'd2                ),//(i)
        .frediv           (8'd15               ),//(i)
        .cs_mode          (2'd0                ),//(i)
        .byte_num         (2'd2                ),//(i)
        .trig             (trig2               ),//(i)
        .finish           (                    ),//(o)
        .writedata        (writedata2          ),//(i)
        .readdata         (readdata2           ),//(o)
        .cs               (AD5674_2_SPI_CS     ),//(o)
        .sck              (AD5674_2_SPI_CLK    ),//(o)
        .mosi             (AD5674_2_SPI_SDI    ),//(o)
        .miso             (AD5674_2_SPI_SDO    ) //(i)
    );                                         





endmodule



























