`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/20 18:16:32
// Design Name: 
// Module Name: FAN_CTR_module
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


module FAN_CTR_module(
    input   wire                        i_clk                                   ,
    input   wire                        i_rst_n                                 ,
    
    input   wire    [11:0]              i_TEMP_DATA                             ,
    input   wire                        i_TEMP_DATA_en                          ,
    
    output  wire                        o_fan_pwren 
);
//=================================================================================
parameter   FRE_CLK_20K        = 'd5000;// clk 100M      100M/100K
//parameter   FAN_zhankongbi      = 'd20000;
reg     [31:0]  FAN_zhankongbi;
//=================================================================================
reg     rst_n_reg1;
reg     rst_n_reg2;
reg     rst_n_reg3;
always@(posedge i_clk)
begin
    rst_n_reg1  <= i_rst_n;
    rst_n_reg2  <= rst_n_reg1;
    rst_n_reg3  <= rst_n_reg2;
end

reg     TEMP_DATA_en_reg1;
reg     TEMP_DATA_en_reg2;
reg     TEMP_DATA_en_reg3;
always@(posedge i_clk)
begin
    TEMP_DATA_en_reg1  <= i_TEMP_DATA_en;
    TEMP_DATA_en_reg2  <= TEMP_DATA_en_reg1;
    TEMP_DATA_en_reg3  <= TEMP_DATA_en_reg2;
end

reg [11:0]     TEMP_DATA_reg1;
reg [11:0]     TEMP_DATA_reg2;
reg [11:0]     TEMP_DATA_reg3;
always@(posedge i_clk)
begin
    TEMP_DATA_reg1  <= i_TEMP_DATA;
    TEMP_DATA_reg2  <= TEMP_DATA_reg1;
    TEMP_DATA_reg3  <= TEMP_DATA_reg2;
end
//===================================================================================
reg     [11:0] TEMP_DATA_reg;
always@(posedge i_clk)
begin
    if(rst_n_reg3 == 'd0)
        TEMP_DATA_reg   <= 'd0;
    else if(TEMP_DATA_en_reg3)
        TEMP_DATA_reg   <= TEMP_DATA_reg3;
    else
        TEMP_DATA_reg   <= TEMP_DATA_reg;
end

always@(posedge i_clk)
begin
    if(rst_n_reg3 == 'd0)
        FAN_zhankongbi  <= 'd1000;
    else if(TEMP_DATA_reg[11] == 'd0 && TEMP_DATA_reg[10:4] >= 'd100) 
        FAN_zhankongbi  <= 'd5000;
    else if(TEMP_DATA_reg[11] == 'd0 && TEMP_DATA_reg[10:4] >= 'd90) 
        FAN_zhankongbi  <= 'd4500;
    else if(TEMP_DATA_reg[11] == 'd0 && TEMP_DATA_reg[10:4] >= 'd80) 
        FAN_zhankongbi  <= 'd4000;
    else if(TEMP_DATA_reg[11] == 'd0 && TEMP_DATA_reg[10:4] >= 'd70) 
        FAN_zhankongbi  <= 'd3500;
    else if(TEMP_DATA_reg[11] == 'd0 && TEMP_DATA_reg[10:4] >= 'd60) 
        FAN_zhankongbi  <= 'd3000;
    else if(TEMP_DATA_reg[11] == 'd0 && TEMP_DATA_reg[10:4] >= 'd50) 
        FAN_zhankongbi  <= 'd2500;
    else if(TEMP_DATA_reg[11] == 'd0 && TEMP_DATA_reg[10:4] >= 'd40) 
        FAN_zhankongbi  <= 'd2000;
    else if(TEMP_DATA_reg[11] == 'd0 && TEMP_DATA_reg[10:4] >= 'd30) 
        FAN_zhankongbi  <= 'd1500;
    else 
        FAN_zhankongbi  <= 'd1000;
end
//===================================================================================
reg     [31:0]  cnt;
always@(posedge i_clk)
begin
    if(rst_n_reg3 == 'd0)
        cnt     <= 'd0;
    else if(cnt >= (FRE_CLK_20K - 1'b1))
        cnt     <= 'd0;
    else
        cnt     <= cnt + 1'b1;
end

reg     fan_pwren;
always@(posedge i_clk)
begin
    if(rst_n_reg3 == 'd0)
        fan_pwren   <= 'd1;
    else if(cnt >= (FAN_zhankongbi-1))
        fan_pwren   <= 'd0;
    else
        fan_pwren   <= 'd1; 
end

assign  o_fan_pwren = fan_pwren;


endmodule