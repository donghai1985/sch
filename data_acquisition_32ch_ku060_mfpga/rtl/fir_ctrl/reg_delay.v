`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/23
// Design Name: 
// Module Name: reg_delay
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//              reg_delay #(
//                  .DATA_WIDTH             ( DATA_WIDTH            ),
//                  .DELAY_NUM              ( DELAY_NUM             )
//              )reg_delay_inst(
//                  .clk_i                  ( clk_i                 ),
//                  .src_data_i             ( src_data_i            ),
//                  .delay_data_o           ( delay_data_o          )
//              );
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reg_delay #(
    parameter                       DATA_WIDTH = 8      ,
    parameter                       DELAY_NUM  = 2      
)(
    input    wire                   clk_i               ,
    
    input    wire  [DATA_WIDTH-1:0] src_data_i          ,
    output   wire  [DATA_WIDTH-1:0] delay_data_o        
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg  [DATA_WIDTH*DELAY_NUM-1:0] delay_data_temp = 'd0;




//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if(DELAY_NUM==1)begin
    always @(posedge clk_i) begin
        delay_data_temp <= src_data_i;
    end
end
else begin
    always @(posedge clk_i) begin
        delay_data_temp <= {delay_data_temp[DATA_WIDTH*(DELAY_NUM-1)-1:0],src_data_i};
    end
end


assign delay_data_o = delay_data_temp[DATA_WIDTH*DELAY_NUM-1:DATA_WIDTH*(DELAY_NUM-1)];
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

endmodule
