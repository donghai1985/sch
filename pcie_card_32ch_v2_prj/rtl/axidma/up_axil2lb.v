// =================================================================================================
// Copyright 2020 - 2030 (c) Semi, Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : up_axil2lb.v
// Module         : up_axil2lb
// Function       : 
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

module up_axil2lb#(
    parameter                               LB_DATA_WDTH    =  32          ,
    parameter                               LB_ADDR_WDTH    =  32          ,
    parameter                               SLAVE_NUM       =  4           
)(
    input                                   up_rstn                        ,//(i)
    input                                   up_clk                         ,//(i)
                                                                                 
    input                                   up_axi_awvalid                 ,//(i)
    input             [LB_ADDR_WDTH-1:0]    up_axi_awaddr                  ,//(i)
    output                                  up_axi_awready                 ,//(o)
    input                                   up_axi_wvalid                  ,//(i)
    input             [LB_DATA_WDTH-1:0]    up_axi_wdata                   ,//(i)
    input             [ 3:0]                up_axi_wstrb                   ,//(i)
    output                                  up_axi_wready                  ,//(o)
    output                                  up_axi_bvalid                  ,//(o)
    output            [ 1:0]                up_axi_bresp                   ,//(o)
    input                                   up_axi_bready                  ,//(i)
    input                                   up_axi_arvalid                 ,//(i)
    input             [LB_ADDR_WDTH-1:0]    up_axi_araddr                  ,//(i)
    output                                  up_axi_arready                 ,//(o)
    output                                  up_axi_rvalid                  ,//(o)
    output            [ 1:0]                up_axi_rresp                   ,//(o)
    output            [LB_DATA_WDTH-1:0]    up_axi_rdata                   ,//(o)
    input                                   up_axi_rready                  ,//(i)

    output                                  lb_wreq                        ,//(i)
    output            [LB_ADDR_WDTH-1:0]    lb_waddr                       ,//(i)
    output            [LB_DATA_WDTH-1:0]    lb_wdata                       ,//(i)
    output                                  lb_rreq                        ,//(i)
    output            [LB_ADDR_WDTH-1:0]    lb_raddr                       ,//(i)
    input             [SLAVE_NUM-1   :0]    lb_wack_slv                    ,//(i)
    input             [SLAVE_NUM-1   :0]    lb_rack_slv                    ,//(i)
    input   [LB_DATA_WDTH*SLAVE_NUM -1:0]   lb_rdata_slv                    //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    up_wreq                        ;
    wire              [LB_ADDR_WDTH-1:0]    up_waddr                       ;
    wire              [LB_DATA_WDTH-1:0]    up_wdata                       ;
    wire                                    up_wack                        ;
    wire                                    up_rreq                        ;
    wire              [LB_ADDR_WDTH-1:0]    up_raddr                       ;
    wire              [LB_DATA_WDTH-1:0]    up_rdata                       ;
    wire                                    up_rack                        ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign             lb_wreq       =      up_wreq                        ;
    assign             lb_waddr      =      up_waddr                       ;
    assign             lb_wdata      =      up_wdata                       ;
    assign             lb_rreq       =      up_rreq                        ;
    assign             lb_raddr      =      up_raddr                       ;
// =================================================================================================
// RTL Body
// =================================================================================================
    up_axi #(
        .AXI_ADDRESS_WIDTH              (LB_ADDR_WDTH         )
    )u_up_axi(                                                 
        .up_clk                         (up_clk               ),
        .up_rstn                        (up_rstn             ),
        .up_wreq                        (up_wreq              ),
        .up_waddr                       (up_waddr             ),
        .up_wdata                       (up_wdata             ),
        .up_wack                        (up_wack              ),
        .up_rreq                        (up_rreq              ),
        .up_raddr                       (up_raddr             ),
        .up_rdata                       (up_rdata             ),
        .up_rack                        (up_rack              ),
                                                                  
        .up_axi_awvalid                 (up_axi_awvalid       ),
        .up_axi_awaddr                  (up_axi_awaddr        ),
        .up_axi_awready                 (up_axi_awready       ),
        .up_axi_wvalid                  (up_axi_wvalid        ),
        .up_axi_wdata                   (up_axi_wdata         ),
        .up_axi_wstrb                   (up_axi_wstrb         ),
        .up_axi_wready                  (up_axi_wready        ),
        .up_axi_bvalid                  (up_axi_bvalid        ),
        .up_axi_bresp                   (up_axi_bresp         ),
        .up_axi_bready                  (up_axi_bready        ),
        .up_axi_arvalid                 (up_axi_arvalid       ),
        .up_axi_araddr                  (up_axi_araddr        ),
        .up_axi_arready                 (up_axi_arready       ),
        .up_axi_rvalid                  (up_axi_rvalid        ),
        .up_axi_rresp                   (up_axi_rresp         ),
        .up_axi_rdata                   (up_axi_rdata         ),
        .up_axi_rready                  (up_axi_rready        )
    );


    //---------------------------------------------------------------------
    // lb_addr_allo Inst.
    //---------------------------------------------------------------------     
    lb_addr_allo#(
        .LB_DATA_WDTH                   (LB_DATA_WDTH         ),
        .LB_ADDR_WDTH                   (LB_ADDR_WDTH         ),
        .SLAVE_NUM                      (SLAVE_NUM            )
    )u_lb_addr_allo(                                          
        .lb_clk                         (up_clk               ),//(i)
        .lb_rst_n                       (up_rstn             ),//(i)
        .lb_wreq                        (up_wreq              ),//(i)
        .lb_waddr                       (up_waddr             ),//(i)
        .lb_wdata                       (up_wdata             ),//(i)
        .lb_wack                        (up_wack              ),//(o)
        .lb_rreq                        (up_rreq              ),//(i)
        .lb_raddr                       (up_raddr             ),//(i)
        .lb_rdata                       (up_rdata             ),//(o)
        .lb_rack                        (up_rack              ),//(o)
        .lb_wack_slv                    (lb_wack_slv          ),//(i)
        .lb_rack_slv                    (lb_rack_slv          ),//(i)
        .lb_rdata_slv                   (lb_rdata_slv         ) //(i)
    );









endmodule





