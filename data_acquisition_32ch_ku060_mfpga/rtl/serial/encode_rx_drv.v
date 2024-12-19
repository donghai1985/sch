`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/12/05
// Design Name: PCG
// Module Name: encode_tx_drv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module encode_rx_drv #(
    parameter                               TCQ             = 0.1   ,
    parameter                               DATA_WIDTH      = 16    ,
    parameter                               SERIAL_MODE     = 1     
)(
    // clk & rst
    input    wire                           clk_i                   ,
    input    wire                           rst_i                   ,
    input    wire                           clk_200m_i              ,

(*mark_debug = "true"*)    output   wire                           encode_zero_flag_o      ,
(*mark_debug = "true"*)    output   wire                           scan_start_flag_o       ,
(*mark_debug = "true"*)    output   wire                           scan_tset_flag_o        ,

    // spi info
    input   wire                            SPI_MCLK                ,
    input   wire    [SERIAL_MODE-1:0]       SPI_MOSI                
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam  [DATA_WIDTH-1:0]        SYNC_WORD_ENCODE        = 'hECDE    ;
localparam  [DATA_WIDTH-1:0]        SYNC_WORD_SCAN_BEGIN    = 'h5A51    ;
localparam  [DATA_WIDTH-1:0]        SYNC_WORD_SCAN_TEST     = 'h5A53    ;
localparam  [DATA_WIDTH-1:0]        SYNC_WORD_SCAN_END      = 'h5A50    ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                             encode_rx_flag      = 'd0;
reg                             scan_start_flag     = 'd0;
reg                             scan_test_flag      = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
(*mark_debug = "true"*)wire                            rx_valid            ;
(*mark_debug = "true"*)wire    [DATA_WIDTH-1:0]        rx_data             ; 

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
serial_rx #(
    .DATA_WIDTH                 ( DATA_WIDTH                ),
    .SERIAL_MODE                ( SERIAL_MODE               )  // =1\2\4\8
)serial_rx_inst(
    // clk & rst
    .clk_i                      ( clk_i                     ),
    .rst_i                      ( rst_i                     ),
    .clk_200m_i                 ( clk_200m_i                ),
    .rx_valid_o                 ( rx_valid                  ),
    .rx_data_o                  ( rx_data                   ),

    .RX_CLK                     ( SPI_MCLK                  ),
    .RX_DIN                     ( SPI_MOSI                  )
);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i)begin
    if(rst_i)
        encode_rx_flag <= #TCQ 'd0;
    else if(rx_valid && rx_data==SYNC_WORD_ENCODE)
        encode_rx_flag <= #TCQ 'd1;
    else 
        encode_rx_flag <= #TCQ 'd0;
end

always @(posedge clk_i)begin
    if(rst_i)
        scan_start_flag <= #TCQ 'd0;
    else if(rx_valid && (rx_data==SYNC_WORD_SCAN_BEGIN || rx_data==SYNC_WORD_SCAN_TEST))
        scan_start_flag <= #TCQ 'd1;
    else if(rx_valid && rx_data==SYNC_WORD_SCAN_END)
        scan_start_flag <= #TCQ 'd0;
end

always @(posedge clk_i)begin
    if(rst_i)
        scan_test_flag <= #TCQ 'd0;
    else if(rx_valid && rx_data==SYNC_WORD_SCAN_TEST)
        scan_test_flag <= #TCQ 'd1;
    else if(rx_valid && rx_data==SYNC_WORD_SCAN_BEGIN)
        scan_test_flag <= #TCQ 'd0;
end

assign encode_zero_flag_o   = encode_rx_flag;
assign scan_start_flag_o    = scan_start_flag;
assign scan_tset_flag_o     = scan_test_flag ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
