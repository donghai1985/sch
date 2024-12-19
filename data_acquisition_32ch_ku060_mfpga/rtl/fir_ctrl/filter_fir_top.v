// =================================================================================================
// Copyright 2020 - 2030 (c) Semi, Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : filter_fir_top.v
// Module         : fir
// Function       :  
// Type           : RTL
// =================================================================================================
// End Revision
// =================================================================================================

module filter_fir_top #(
    parameter     COE_NUM          =        51              ,
    parameter     COE_WDTH         =        29              ,
    parameter     COE_NUM_HALF     =       (COE_NUM+1)/2    ,
    parameter     XDATA_WDTH       =        14              ,
    parameter     YDATA_WDTH       =        14              
)(
    input                                   cfg_clk         ,//(i)
    input                                   cfg_rst_n       ,//(i)
    input                                   coe_vld         ,//(i)
    input                [COE_WDTH  -1:0]   coe_din         ,//(i)
    input                                   coe_sop         ,//(i)
    input                                   coe_load        ,//(i)
    input                                   bypass          ,//(i)
                                                                  
    input                                   clk             ,//(i)
    input                                   rst_n           ,//(i)
    input                                   xvld            ,//(i)
    input                [XDATA_WDTH-1:0]   xin             ,//(i)
    output                                  yvld            ,//(o)
    output               [YDATA_WDTH-1:0]   yout             //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire      [COE_NUM_HALF*COE_WDTH-1:0]   coe_arr               ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------


// =================================================================================================
// RTL Body
// =================================================================================================


    // -------------------------------------------------------------------------
    // fir_coe_reload Module Inst.
    // -------------------------------------------------------------------------
    fir_coe_reload #(                                         
        .COE_NUM              (COE_NUM                ),
        .COE_WDTH             (COE_WDTH               ),
        .COE_NUM_HALF         (COE_NUM_HALF           )       
    )u_fir_coe_reload( 
        .cfg_clk              (cfg_clk                ),//(i)
        .cfg_rst_n            (cfg_rst_n              ),//(i)
        .coe_vld              (coe_vld                ),//(i)
        .coe_din              (coe_din                ),//(i)
        .coe_sop              (coe_sop                ),//(i)
        .coe_load             (coe_load               ),//(i)
        .clk                  (clk                    ),//(i)
        .rst_n                (rst_n                  ),//(i)
        .coe_arr              (coe_arr                ) //(o)
    );                                                 
     
    // -------------------------------------------------------------------------
    // filter_fir_imp Module Inst.
    // -------------------------------------------------------------------------
    filter_fir_imp #(                                  
        .COE_NUM              (COE_NUM                ),
        .COE_WDTH             (COE_WDTH               ),
        .COE_NUM_HALF         (COE_NUM_HALF           ),
        .XDATA_WDTH           (XDATA_WDTH             ),
        .YDATA_WDTH           (YDATA_WDTH             ) 
    )u_filter_fir_imp( 
        .bypass               (bypass                 ),//(i)
        .coe_arr              (coe_arr                ),//(i)
        .clk                  (clk                    ),//(i)
        .rst_n                (rst_n                  ),//(i)
        .xvld                 (xvld                   ),//(i)
        .xin                  (xin                    ),//(i)
        .yvld                 (yvld                   ),//(o)
        .yout                 (yout                   ) //(o)
    );                                                   
     




endmodule    













    