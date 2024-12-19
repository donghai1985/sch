// =================================================================================================
// Copyright 2020 - 2030 (c) Semi, Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : fir_coe_reload.v
// Module         : fir
// Function       :  
// Type           : RTL
// =================================================================================================
// End Revision
// =================================================================================================

module fir_coe_inf_conv #(
    parameter     COE_NUM          =        51                         ,
    parameter     COE_WDTH         =        29                         ,
    parameter     COE_NUM_HALF     =       (COE_NUM+1)/2               
)(           
    input                                   cfg_clk                    ,//(i)
    input                                   cfg_rst_n                  ,//(i)
    input                                   fir_en                     ,//(i)
    input                                   readback0_vld              ,//(o)
    input                                   readback0_last             ,//(o)
    input                [32-1:0]           readback0_data             ,//(o)
    output                                  coe_vld                    ,//(i)
    output                                  coe_sop                    ,//(i)
    output               [COE_WDTH  -1:0]   coe_din                    ,//(i)
    output    reg        [32-1:0]           coe_fir_dec                 //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg                                     readback0_vld_d1           ;
    wire                                    readback0_vld_pos          ;
    reg                                     readback0_vld_pos_d1       ;
    reg                                     readback0_vld_pos_d2       ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign        readback0_vld_pos  =     ~readback0_vld_d1 && readback0_vld;
    assign        coe_vld            =      readback0_vld                    ;
    assign        coe_sop            =      readback0_vld_pos_d2             ;//coe_vld_d2
    assign        coe_din            =      readback0_data                   ;
//  assign        coe_din            =      byte_adj(readback0_data)         ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge cfg_clk or negedge cfg_rst_n)begin
        if(~cfg_rst_n)
            coe_fir_dec <= 32'd0;
        else if(~fir_en)
            coe_fir_dec <= 32'd0;
        else if(readback0_vld_pos_d1)
            coe_fir_dec <= coe_din;
    end


    always @(posedge cfg_clk or negedge cfg_rst_n)begin
        if(~cfg_rst_n)begin
            readback0_vld_d1      <= 1'b0;
            readback0_vld_pos_d1  <= 1'b0;
            readback0_vld_pos_d2  <= 1'b0;
        end else begin
            readback0_vld_d1      <= readback0_vld       ;
            readback0_vld_pos_d1  <= readback0_vld_pos   ;
            readback0_vld_pos_d2  <= readback0_vld_pos_d1;
        end
    end



    function automatic [32 -1:0] byte_adj(
        input          [32 -1:0]     a   
    );begin:abc
        integer i;
        for(i=1;i<=4;i=i+1)begin
            byte_adj[i*8 -1 -:8] = a[(4 + 1 - i)*8 -1 -: 8];
        end
    end
    endfunction





endmodule    













    