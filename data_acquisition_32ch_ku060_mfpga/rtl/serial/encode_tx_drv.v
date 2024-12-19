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


module encode_tx_drv #(
    parameter                               TCQ             = 0.1   ,
    parameter                               DATA_WIDTH      = 32    ,
    parameter                               SERIAL_MODE     = 1     
)(
    // clk & rst
    input    wire                           clk_i                   ,
    input    wire                           rst_i                   ,
    input    wire                           clk_200m_i              ,

    input    wire                           encode_en_i             ,
    input    wire   [DATA_WIDTH-1:0]        encode_x_data_i         ,
    input    wire   [DATA_WIDTH-1:0]        encode_w_data_i         ,

    // spi info
    output   wire                           SPI_MCLK                ,
    output   wire   [SERIAL_MODE-1:0]       SPI_MOSI                
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam  [DATA_WIDTH-1:0]        SYNC_WORD       = 32'h55AA0701  ;
localparam                          ENCODE_LENG     = 'd3           ;   // SYNC + Xencode + Wencode

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                             master_wr_flag      = 'd0;
reg                             master_wr_en        = 'd0;
reg     [6-1:0]                 master_wr_cnt       = 'd0;
reg     [DATA_WIDTH-1:0]        master_wr_din       = 'd0;

reg                             encode_en           = 'd0;
reg     [DATA_WIDTH-1:0]        encode_x_data       = 'd0;
reg     [DATA_WIDTH-1:0]        encode_w_data       = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                            tx_data_num_en      ;
wire    [6-1:0]                 tx_data_num         ;

wire                            comm_timeout_rst    ;
wire                            tx_cmd_vld          ;
wire                            tx_ack              ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
serial_tx_v2 #(
    .DATA_WIDTH                 ( DATA_WIDTH                ),
    .SERIAL_MODE                ( SERIAL_MODE               )  // =1\2\4\8
)serial_tx_inst(
    // clk & rst
    .clk_i                      ( clk_i                     ),
    .rst_i                      ( rst_i                     ),
    .clk_200m_i                 ( clk_200m_i                ),

    .tx_data_num_en_i           ( tx_data_num_en            ),
    .tx_data_num_i              ( tx_data_num               ),
    .tx_valid_i                 ( master_wr_en              ),
    .tx_data_i                  ( master_wr_din             ),
    .tx_ack_o                   ( tx_ack                    ),

    .TX_CLK                     ( SPI_MCLK                  ),
    .TX_DOUT                    ( SPI_MOSI                  )
);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) encode_en <= #TCQ encode_en_i;

always @(posedge clk_i)begin
    if(encode_en_i)begin
        encode_x_data <= #TCQ encode_x_data_i;
        encode_w_data <= #TCQ encode_w_data_i;
    end
end 

always @(posedge clk_i) begin
    if(encode_en_i)
        master_wr_flag <= #TCQ 'd1;
    else if(master_wr_cnt == ENCODE_LENG-1)
        master_wr_flag <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(master_wr_flag)
        master_wr_cnt <= #TCQ master_wr_cnt + 1;
    else
        master_wr_cnt <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    case(master_wr_cnt)
        'd0: master_wr_din <= #TCQ SYNC_WORD;
        'd1: master_wr_din <= #TCQ encode_x_data;
        'd2: master_wr_din <= #TCQ encode_w_data;
        default: /*default*/;
    endcase
end

always @(posedge clk_i) master_wr_en <= #TCQ master_wr_flag;

assign tx_data_num_en = master_wr_flag && (master_wr_cnt=='d0);
assign tx_data_num    = ENCODE_LENG-1;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
