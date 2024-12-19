// =================================================================================================
// Copyright 2020 - 2030 (c) Semi, Inc. All rights reserved.
// =================================================================================================
// File Name      : name.v
// Module         : name
// Function       :                      
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2023/01/05   Holt             Create new
//
// =================================================================================================
// End Revision
// =================================================================================================
 
module jtag2lb_top #(
    parameter                               DATA_WIDTH          =       32 ,
    parameter                               ADDR_WIDTH          =       16 ,
    parameter                               SIM                 =        0
)(
    input                                   axil_clk                       ,//(i)
    input                                   axil_rst_n                     ,//(i)

    input                                   slave_wr_en                    ,//(i)
    input           [ADDR_WIDTH-1:0]        slave_addr                     ,//(i)
    input           [DATA_WIDTH-1:0]        slave_wr_data                  ,//(i)
    input                                   slave_rd_en                    ,//(i)
    output                                  slave_rd_vld                   ,//(o)
    output          [DATA_WIDTH-1:0]        slave_rd_data                  ,//(o)

    output                                  master_wr_en                   ,//(o)
    output          [ADDR_WIDTH-1:0]        master_addr                    ,//(o)
    output          [DATA_WIDTH-1:0]        master_wr_data                 ,//(o)
    output                                  master_rd_en                   ,//(o)
    input                                   master_rd_vld                  ,//(i)
    input           [DATA_WIDTH-1:0]        master_rd_data                  //(i)

);
 
    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    parameter                               AXI_ADDRESS_WIDTH     =      32;

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire              [31 : 0]              m_axil_awaddr                  ;
    wire              [2 : 0]               m_axil_awprot                  ;
    wire                                    m_axil_awvalid                 ;
    wire                                    m_axil_awready                 ;
    wire              [31 : 0]              m_axil_wdata                   ;
    wire              [3 : 0]               m_axil_wstrb                   ;
    wire                                    m_axil_wvalid                  ;
    wire                                    m_axil_wready                  ;
    wire              [1 : 0]               m_axil_bresp                   ;
    wire                                    m_axil_bvalid                  ;
    wire                                    m_axil_bready                  ;
    wire              [31 : 0]              m_axil_araddr                  ;
    wire              [2 : 0]               m_axil_arprot                  ;
    wire                                    m_axil_arvalid                 ;
    wire                                    m_axil_arready                 ;
    wire              [31 : 0]              m_axil_rdata                   ;
    wire              [1 : 0]               m_axil_rresp                   ;
    wire                                    m_axil_rvalid                  ;
    wire                                    m_axil_rready                  ;

    wire                                    up_wreq                        ;
    wire        [(AXI_ADDRESS_WIDTH-1):0]   up_waddr                       ;
    wire        [31:0]                      up_wdata                       ;
    reg                                     up_wack                        ;
    wire                                    up_rreq                        ;
    wire        [(AXI_ADDRESS_WIDTH-1):0]   up_raddr                       ;
    wire        [31:0]                      up_rdata                       ;
    reg                                     up_rack                        ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign       master_wr_en      =     slave_wr_en  ?  1'b1         : up_wreq;            
    assign       master_addr       =    (slave_wr_en || slave_rd_en)  ? slave_addr : (up_wreq ? up_waddr : up_raddr );      
    assign       master_wr_data    =     slave_wr_en  ? slave_wr_data : up_wdata;        
    assign       master_rd_en      =     slave_rd_en  ?  1'b1         : up_rreq ;       
    assign       slave_rd_vld      =     up_rack ? 1'b0: master_rd_vld ;  
    assign       slave_rd_data     =     master_rd_data                ;
    assign       up_rdata          =     master_rd_data                ;
 
// =================================================================================================
// RTL Body
// =================================================================================================
    // -------------------------------------------------------------------------
    // jtag_axi_ip Module Inst.
    // -------------------------------------------------------------------------
generate if(SIM==0)begin
    jtag_axi_ip u(
        .aclk                   (axil_clk                    ), // input wire aclk                      
        .aresetn                (axil_rst_n                  ), // input wire aresetn                   
        .m_axi_awaddr           (m_axil_awaddr               ), // output wire [31 : 0] m_axi_awaddr    
        .m_axi_awprot           (m_axil_awprot               ), // output wire [2 : 0] m_axi_awprot     
        .m_axi_awvalid          (m_axil_awvalid              ), // output wire m_axi_awvalid            
        .m_axi_awready          (m_axil_awready              ), // input wire m_axi_awready             
        .m_axi_wdata            (m_axil_wdata                ), // output wire [31 : 0] m_axi_wdata     
        .m_axi_wstrb            (m_axil_wstrb                ), // output wire [3 : 0] m_axi_wstrb      
        .m_axi_wvalid           (m_axil_wvalid               ), // output wire m_axi_wvalid             
        .m_axi_wready           (m_axil_wready               ), // input wire m_axi_wready              
        .m_axi_bresp            (m_axil_bresp                ), // input wire [1 : 0] m_axi_bresp       
        .m_axi_bvalid           (m_axil_bvalid               ), // input wire m_axi_bvalid              
        .m_axi_bready           (m_axil_bready               ), // output wire m_axi_bready             
        .m_axi_araddr           (m_axil_araddr               ), // output wire [31 : 0] m_axi_araddr    
        .m_axi_arprot           (m_axil_arprot               ), // output wire [2 : 0] m_axi_arprot     
        .m_axi_arvalid          (m_axil_arvalid              ), // output wire m_axi_arvalid            
        .m_axi_arready          (m_axil_arready              ), // input wire m_axi_arready             
        .m_axi_rdata            (m_axil_rdata                ), // input wire [31 : 0] m_axi_rdata      
        .m_axi_rresp            (m_axil_rresp                ), // input wire [1 : 0] m_axi_rresp       
        .m_axi_rvalid           (m_axil_rvalid               ), // input wire m_axi_rvalid              
        .m_axi_rready           (m_axil_rready               )  // output wire m_axi_rready             
    );
end else begin
    axi_lite_sim_imp  #(32)axil0(
        .s_axi_sim_aclk         (axil_clk                    ),//100M
        .s_axi_sim_aresetn      (axil_rst_n                  ),
        .s_axi_sim_awaddr       (m_axil_awaddr               ),
        .s_axi_sim_awvalid      (m_axil_awvalid              ),
        .s_axi_sim_awready      (m_axil_awready              ),
        .s_axi_sim_wdata        (m_axil_wdata                ),
        .s_axi_sim_wstrb        (m_axil_wstrb                ),
        .s_axi_sim_wvalid       (m_axil_wvalid               ),
        .s_axi_sim_wready       (m_axil_wready               ),
        .s_axi_sim_bresp        (m_axil_bresp                ),
        .s_axi_sim_bvalid       (m_axil_bvalid               ),
        .s_axi_sim_bready       (m_axil_bready               ),
        .s_axi_sim_araddr       (m_axil_araddr               ),
        .s_axi_sim_arvalid      (m_axil_arvalid              ),
        .s_axi_sim_arready      (m_axil_arready              ),
        .s_axi_sim_rdata        (m_axil_rdata                ),
        .s_axi_sim_rresp        (m_axil_rresp                ),
        .s_axi_sim_rvalid       (m_axil_rvalid               ),
        .s_axi_sim_rready       (m_axil_rready               )
    );
    
end
endgenerate
    // -------------------------------------------------------------------------
    // up_axi Module Inst.
    // -------------------------------------------------------------------------
    up_axi #(                                                
        .AXI_ADDRESS_WIDTH      (AXI_ADDRESS_WIDTH           )       
    )u_up_axi(                                                      
        .up_rstn                (axil_rst_n                  ),//(i)
        .up_clk                 (axil_clk                    ),//(i)
        .up_axi_awvalid         (m_axil_awvalid              ),//(i)
        .up_axi_awaddr          (m_axil_awaddr               ),//(i)
        .up_axi_awready         (m_axil_awready              ),//(o)
        .up_axi_wvalid          (m_axil_wvalid               ),//(i)
        .up_axi_wdata           (m_axil_wdata                ),//(i)
        .up_axi_wstrb           (m_axil_wstrb                ),//(i)
        .up_axi_wready          (m_axil_wready               ),//(o)
        .up_axi_bvalid          (m_axil_bvalid               ),//(o)
        .up_axi_bresp           (m_axil_bresp                ),//(o)
        .up_axi_bready          (m_axil_bready               ),//(i)
        .up_axi_arvalid         (m_axil_arvalid              ),//(i)
        .up_axi_araddr          (m_axil_araddr               ),//(i)
        .up_axi_arready         (m_axil_arready              ),//(o)
        .up_axi_rvalid          (m_axil_rvalid               ),//(o)
        .up_axi_rresp           (m_axil_rresp                ),//(o)
        .up_axi_rdata           (m_axil_rdata                ),//(o)
        .up_axi_rready          (m_axil_rready               ),//(i)
        .up_wreq                (up_wreq                     ),//(o)
        .up_waddr               (up_waddr                    ),//(o)
        .up_wdata               (up_wdata                    ),//(o)
        .up_wack                (up_wack                     ),//(i)
        .up_rreq                (up_rreq                     ),//(o)
        .up_raddr               (up_raddr                    ),//(o)
        .up_rdata               (up_rdata                    ),//(i)
        .up_rack                (up_rack                     ) //(i)
    );                                                                  


    // processor write interface
    always @(posedge axil_clk or negedge axil_rst_n)
        if(axil_rst_n==1'b0)begin
            up_wack <= 1'b0;
            up_rack <= 1'b0;
        end else begin
            up_wack <= up_wreq;   
            up_rack <= up_rreq;   
        end





endmodule
 
 
 
 
 