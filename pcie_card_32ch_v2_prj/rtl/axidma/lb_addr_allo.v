// =================================================================================================
// Copyright 2020 - 2030 (c) Cygnus Semi, Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : lb_addr_allo.v
// Module         : lb_addr_allo
// Function       :    localbus address allocation
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2020/03/03   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================

module lb_addr_allo#(
    parameter                               LB_DATA_WDTH    =  32          ,
    parameter                               LB_ADDR_WDTH    =  32          ,
    parameter                               SLAVE_NUM       =  4           
)(
    input                                   lb_clk                         ,//(i)
    input                                   lb_rst_n                       ,//(i)
    input                                   lb_wreq                        ,//(i)
    input             [LB_ADDR_WDTH-1:0]    lb_waddr                       ,//(i)
    input             [LB_DATA_WDTH-1:0]    lb_wdata                       ,//(i)
    output   reg                            lb_wack                        ,//(o)
    input                                   lb_rreq                        ,//(i)
    input             [LB_ADDR_WDTH-1:0]    lb_raddr                       ,//(i)
    output   reg      [LB_DATA_WDTH-1:0]    lb_rdata                       ,//(o)
    output   reg                            lb_rack                        ,//(o)
                                                                  
    input             [SLAVE_NUM-1   :0]    lb_wack_slv                    , // (i)
    input             [SLAVE_NUM-1   :0]    lb_rack_slv                    , // (i)
    input   [LB_DATA_WDTH*SLAVE_NUM -1:0]   lb_rdata_slv                     // (i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire    [LB_DATA_WDTH -1:0]             rdata_arr[SLAVE_NUM-1:0]       ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    genvar    i;
    generate
        for(i=0; i<SLAVE_NUM;i=i+1) begin:PART1
           assign rdata_arr[i]  =  lb_rdata_slv[LB_DATA_WDTH*(i+1)-1:LB_DATA_WDTH*(i)];
        end
    endgenerate


// =================================================================================================
// RTL Body
// =================================================================================================
    integer k;
    always @(negedge lb_rst_n or posedge lb_clk)
        if (lb_rst_n == 0) begin
            lb_wack  <= 1'd0;
            lb_rack  <= 1'd0;
            lb_rdata <= {LB_ADDR_WDTH{1'd0}};
        end else begin
            lb_wack  <= | lb_wack_slv  ;
            lb_rack  <= | lb_rack_slv  ;
            for(k=0;k<SLAVE_NUM;k=k+1)
            begin
                if(lb_rack_slv[SLAVE_NUM-k-1] == 1'b1)         
                    lb_rdata <= rdata_arr[SLAVE_NUM-k-1] ; 
            end   
        end

endmodule





