`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/29
// Design Name: 
// Module Name: arbitrate_bpsi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// `define FBC_UDP_OFF


module arbitrate_bpsi #(
    parameter                               TCQ                 = 0.1   ,
    parameter        [8*20-1:0]             MFPGA_VERSION       = "PCG1_TimingM_v1.1   "
)(
    // clk & rst
    input    wire                           clk_i                       ,
    input    wire                           rst_i                       ,

    // ddr readback
    input    wire                           readback_vld_i              ,
    input    wire                           readback_last_i             ,
    input    wire    [32-1:0]               readback_data_i             ,

    // slave comm
    input    wire                           slave_tx_ack_i              ,
    output   wire                           slave_tx_byte_num_en_o      ,
    output   wire   [15:0]                  slave_tx_byte_num_o         ,
    output   wire                           slave_tx_byte_en_o          ,
    output   wire   [ 7:0]                  slave_tx_byte_o             

);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam          [16-1:0]                READBACK_TYPE               = 'h1002;

localparam                                  ARBITRATE_NUM               = 2;    // control arbitrate channel
genvar i;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                 [ARBITRATE_NUM-1:0]     arbitrate                   = 'd1;
reg                 [ARBITRATE_NUM-1:0]     arbitr_que                  = 'd0;
reg                                         arbitr_result_d0            = 'd0;
reg                                         arbitr_result_d1            = 'd0;
reg                 [11-1:0]                slave_tx_cnt                = 'd0;
reg                 [ 8-1:0]                slave_tx_byte               = 'd0;
reg                                         slave_tx_byte_en            = 'd0;
reg                 [16-1:0]                slave_tx_byte_num           = 'd0;

// ddr readback channel
reg                 [11-1:0]                ddr_readback_cnt            = 'd0;
reg                 [11-1:0]                ddr_readback_num            = 'd0;
reg                                         ddr_readback_st             = 'd0;
reg                                         ddr_readback_ready          = 'd0;
reg                                         readback_tx_finish          = 'd0;
reg                 [2-1:0]                 readback_tx_cnt             = 'd0;  // 4byte --> 1byte
reg                                         slave_tx_empty              = 'd0;
reg                                         first_rd_flag               = 'd0;
reg                 [32-1:0]                readback_rd_data_temp       = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                [ARBITRATE_NUM-1:0]     arbitr_irq          ;
wire                [ARBITRATE_NUM-1:0]     arbitr_result       ;

wire                                        ddr_readback_rd_en  ;
wire                                        ddr_readback_rd_vld ;
wire                [32-1:0]                ddr_readback_rd_data;
wire                                        ddr_readback_empty  ;
wire                                        readback_tx_en      ;
wire                [8-1:0]                 readback_tx_data    ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
xpm_sync_fifo #(
    .ECC_MODE                   ( "no_ecc"                      ),
    .FIFO_MEMORY_TYPE           ( "block"                       ),
    .READ_MODE                  ( "std"                         ),
    .FIFO_WRITE_DEPTH           ( 2048                          ),
    .PROG_FULL_THRESH           ( 128                           ),
    .WRITE_DATA_WIDTH           ( 32                            ),
    .READ_DATA_WIDTH            ( 32                            ),
    .USE_ADV_FEATURES           ( "1000"                        )
)mem_vout_buffer_fifo_inst (
    .wr_clk_i                   ( clk_i                         ),
    .rst_i                      ( rst_i                         ), // synchronous to wr_clk
    .wr_en_i                    ( readback_vld_i                ),
    .wr_data_i                  ( readback_data_i               ),
    .fifo_full_o                ( ddr_readback_full             ),

    .rd_en_i                    ( ddr_readback_rd_en            ),
    .fifo_rd_vld_o              ( ddr_readback_rd_vld           ),
    .fifo_rd_data_o             ( ddr_readback_rd_data          ),
    .fifo_empty_o               ( ddr_readback_empty            )
);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

wire          ddr_readback_irq ;
// generate new arbitrate enable
// ddr readback
always @(posedge clk_i) begin
    if(rst_i)
        ddr_readback_cnt <= #TCQ 'd0;
    else if(readback_last_i)
        ddr_readback_cnt <= #TCQ 'd0;
    else if(readback_vld_i)
        ddr_readback_cnt <= #TCQ ddr_readback_cnt + 1;
end

always @(posedge clk_i) begin
    if(readback_last_i)
        ddr_readback_num <= #TCQ ddr_readback_cnt + 1;
end

assign ddr_readback_irq = readback_last_i;


// generate arbitrate enable , alwaye modify when arbitrate channel add.
assign arbitr_irq   = {  1'b0
                        ,ddr_readback_irq };

assign arbitr_result    = arbitr_que & arbitrate;

// arbitrate trigger
generate
    for(i=0;i<ARBITRATE_NUM;i=i+1)begin
        always @(posedge clk_i) begin
            if(arbitr_irq[i])
                arbitr_que[i] <= #TCQ 1'b1;
            else if(slave_tx_ack_i && arbitr_result[i])
                arbitr_que[i] <= #TCQ 1'b0;
        end
    end
endgenerate

// check arbitrate
always @(posedge clk_i) begin
    if(rst_i)
        arbitrate <= #TCQ 'd1;
    else if(arbitr_result=='d0)
        arbitrate <= #TCQ {arbitrate[ARBITRATE_NUM-2:0],arbitrate[ARBITRATE_NUM-1]};
    else 
        arbitrate <= #TCQ arbitrate;
end

// readback fifo out 4byte --> arbitrate tx 1byte
always @(posedge clk_i) begin
    if(~arbitr_result[0])
        ddr_readback_st <= #TCQ 'd0;
    else if(arbitr_result[0] && slave_tx_byte_num_en_o)
        ddr_readback_st <= #TCQ 'd1;
    else if(slave_tx_cnt == slave_tx_byte_num-1)
        ddr_readback_st <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(~ddr_readback_st)
        ddr_readback_ready <= #TCQ 'd0;
    else 
        ddr_readback_ready <= #TCQ ~ddr_readback_empty;
end

always @(posedge clk_i) begin
    if(~ddr_readback_st)
        readback_tx_finish <= #TCQ 'd1;
    else if(ddr_readback_rd_en)
        readback_tx_finish <= #TCQ 'd0;
    else if(readback_tx_en && (readback_tx_cnt==1))
        readback_tx_finish <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    if(ddr_readback_rd_vld)
        first_rd_flag <= #TCQ 'd1;
    else if(slave_tx_empty)
        first_rd_flag <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(~ddr_readback_st)
        readback_tx_cnt <= #TCQ 'd0;
    else if(readback_tx_en)
        readback_tx_cnt <= #TCQ readback_tx_cnt + 1;
end

assign ddr_readback_rd_en = ddr_readback_ready && readback_tx_finish && ((~first_rd_flag)^readback_tx_en);

always @(posedge clk_i) begin
    if(~ddr_readback_st)
        slave_tx_empty <= #TCQ 'd1;
    else if(ddr_readback_rd_vld)
        slave_tx_empty <= #TCQ 'd0;
    else if(readback_tx_cnt==3 && readback_tx_en && ~ddr_readback_ready)
        slave_tx_empty <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    if(ddr_readback_rd_vld)
        readback_rd_data_temp <= #TCQ ddr_readback_rd_data;
    else if(readback_tx_en)
        readback_rd_data_temp <= #TCQ {readback_rd_data_temp[23:0],8'd0};
end


assign readback_tx_en   = ~slave_tx_empty && ddr_readback_st;
assign readback_tx_data = readback_rd_data_temp[31:24];


// slave control code
always @(posedge clk_i) begin
    if(arbitr_result[0])begin
        if(readback_tx_en)
            slave_tx_cnt <= #TCQ slave_tx_cnt + 1;
    end
    else begin
        slave_tx_cnt <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    if(arbitr_result[0])begin
        slave_tx_byte_en <= #TCQ readback_tx_en;
        slave_tx_byte    <= #TCQ readback_tx_data;
    end
    else 
        slave_tx_byte_en = 'd0;
end

always @(posedge clk_i) begin
    if(arbitr_result[0])
        slave_tx_byte_num <= #TCQ {ddr_readback_num,2'b0};
end

always @(posedge clk_i) begin
    arbitr_result_d0 <= #TCQ |arbitr_result;
    arbitr_result_d1 <= #TCQ arbitr_result_d0;
end

assign slave_tx_byte_num_en_o = arbitr_result_d0 && (~arbitr_result_d1);
assign slave_tx_byte_num_o    = slave_tx_byte_num;
assign slave_tx_byte_en_o     = slave_tx_byte_en;
assign slave_tx_byte_o        = slave_tx_byte;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
