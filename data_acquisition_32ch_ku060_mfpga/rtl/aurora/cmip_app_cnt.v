// =================================================================================================
// Copyright(C) 2021 All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : app_cnt.v
// Module         : app_cnt
// Function       : FPGA RTL Top module
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2020/02/03   NTEW)wang.qiuhua Create new
//
// =================================================================================================
// End Revision
// =================================================================================================

module cmip_app_cnt #(
  parameter width = 16
)(
   input                   clk  ,  // (i) FPGA sys clock
   input                   rst_n,  // (i) FPGA sys reset(High-active)
   input                   clr  ,  // (i) FPGA sys clear(High-active)
   input                   vld  ,  // (i) FPGA sys valid(High-active)
   output reg [width-1:0]  cnt     // (o) FPGA count

);

// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge clk or negedge rst_n)
       if(~rst_n)
          cnt <= 'd0;
       else if(clr)
          cnt <= 'd0;
       else	if(vld)  
          cnt <= cnt +1'b1;
       else
          cnt <= cnt;
    

endmodule





