// =================================================================================================
// Copyright(C) 2020  All rights reserved.                                                          
// =================================================================================================
//                                                                                                  
// =================================================================================================
// Module         : tb_aurora_8b10b_ip_support                                                                              
// Function       : testbench (File is generate by python.)                                         
// Type           : RTL                                                                             
// -------------------------------------------------------------------------------------------------
// Update History :                                                                                 
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents                                                
// 0.1.0      2023/09/23   holt             Create new                                                      
//                                                                                                  
// =================================================================================================
                                                                                                    
`timescale 1ns / 1ps                                                                                
                                                                                                    
module tb_aurora_8b10b_ip_support();                                                                                        
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal Parameter Definition                                                                
    // -------------------------------------------------------------------------                    
                                                                                                  
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal signal definition                                                                   
    // -------------------------------------------------------------------------                    
    reg         [31:0]                                s_axi_tx_tdata                                    ;
    reg         [3:0]                                 s_axi_tx_tkeep                                    ;
    reg                                               s_axi_tx_tvalid                                   ;
    reg                                               s_axi_tx_tlast                                    ;
    wire                                              s_axi_tx_tready                                   ;
    wire        [31:0]                                m_axi_rx_tdata                                    ;
    wire        [3:0]                                 m_axi_rx_tkeep                                    ;
    wire                                              m_axi_rx_tvalid                                   ;
    wire                                              m_axi_rx_tlast                                    ;
    reg                                               rxp                                               ;
    reg                                               rxn                                               ;
    wire                                              txp                                               ;
    wire                                              txn                                               ;
    reg                                               gt_refclk1                                        ;
    wire                                              frame_err                                         ;
    wire                                              hard_err                                          ;
    wire                                              soft_err                                          ;
    wire                                              lane_up                                           ;
    wire                                              channel_up                                        ;
    wire                                              user_clk_out                                      ;
    reg                                               gt_reset                                          ;
    reg                                               reset                                             ;
    reg                                               power_down                                        ;
    reg         [2:0]                                 loopback                                          ;
    wire                                              tx_lock                                           ;
    reg                                               init_clk                                          ;
    wire                                              init_clk_out                                      ;
    wire                                              tx_resetdone_out                                  ;
    wire                                              rx_resetdone_out                                  ;
    wire                                              link_reset_out                                    ;
    wire                                              sys_reset_out                                     ;
    reg                                               drpclk_in                                         ;
    reg         [8:0]                                 drpaddr_in                                        ;
    reg                                               drpen_in                                          ;
    reg         [15:0]                                drpdi_in                                          ;
    wire                                              drprdy_out                                        ;
    wire        [15:0]                                drpdo_out                                         ;
    reg                                               drpwe_in                                          ;
    wire                                              pll_not_locked_out                                ;
                                                                                                  
                                                                                                    
// =================================================================================================
// RTL Body                                                                                         
// =================================================================================================
                                                                                                    
aurora_8b10b_ip_support u_aurora_8b10b_ip_support( 
    .s_axi_tx_tdata                                   (s_axi_tx_tdata                                   ),//(i)
    .s_axi_tx_tkeep                                   (s_axi_tx_tkeep                                   ),//(i)
    .s_axi_tx_tvalid                                  (s_axi_tx_tvalid                                  ),//(i)
    .s_axi_tx_tlast                                   (s_axi_tx_tlast                                   ),//(i)
    .s_axi_tx_tready                                  (s_axi_tx_tready                                  ),//(o)
    .m_axi_rx_tdata                                   (m_axi_rx_tdata                                   ),//(o)
    .m_axi_rx_tkeep                                   (m_axi_rx_tkeep                                   ),//(o)
    .m_axi_rx_tvalid                                  (m_axi_rx_tvalid                                  ),//(o)
    .m_axi_rx_tlast                                   (m_axi_rx_tlast                                   ),//(o)
    .rxp                                              (rxp                                              ),//(i)
    .rxn                                              (rxn                                              ),//(i)
    .txp                                              (txp                                              ),//(o)
    .txn                                              (txn                                              ),//(o)
    .gt_refclk1                                       (gt_refclk1                                       ),//(i)
    .frame_err                                        (frame_err                                        ),//(o)
    .hard_err                                         (hard_err                                         ),//(o)
    .soft_err                                         (soft_err                                         ),//(o)
    .lane_up                                          (lane_up                                          ),//(o)
    .channel_up                                       (channel_up                                       ),//(o)
    .user_clk_out                                     (user_clk_out                                     ),//(o)
    .gt_reset                                         (gt_reset                                         ),//(i)
    .reset                                            (reset                                            ),//(i)
    .power_down                                       (power_down                                       ),//(i)
    .loopback                                         (loopback                                         ),//(i)
    .tx_lock                                          (tx_lock                                          ),//(o)
    .init_clk                                         (init_clk                                         ),//(i)
    .init_clk_out                                     (init_clk_out                                     ),//(o)
    .tx_resetdone_out                                 (tx_resetdone_out                                 ),//(o)
    .rx_resetdone_out                                 (rx_resetdone_out                                 ),//(o)
    .link_reset_out                                   (link_reset_out                                   ),//(o)
    .sys_reset_out                                    (sys_reset_out                                    ),//(o)
    .drpclk_in                                        (drpclk_in                                        ),//(i)
    .drpaddr_in                                       (drpaddr_in                                       ),//(i)
    .drpen_in                                         (drpen_in                                         ),//(i)
    .drpdi_in                                         (drpdi_in                                         ),//(i)
    .drprdy_out                                       (drprdy_out                                       ),//(o)
    .drpdo_out                                        (drpdo_out                                        ),//(o)
    .drpwe_in                                         (drpwe_in                                         ),//(i)
    .pll_not_locked_out                               (pll_not_locked_out                               ) //(o)
);                                                                                                             
                                                                                                    
                                                                                                    
                                                                                                    
// task signal initial                                                                              
task signal_initial;                                                                                
begin                                                                                               
    s_axi_tx_tdata                          =   0 ;
    s_axi_tx_tkeep                          =   0 ;
    s_axi_tx_tvalid                         =   0 ;
    s_axi_tx_tlast                          =   0 ;
    rxp                                     =   0 ;
    rxn                                     =   0 ;
    gt_refclk1                              =   0 ;
    gt_reset                                =   0 ;
    reset                                   =   0 ;
    power_down                              =   0 ;
    loopback                                =   0 ;
    init_clk                                =   0 ;
    drpclk_in                               =   0 ;
    drpaddr_in                              =   0 ;
    drpen_in                                =   0 ;
    drpdi_in                                =   0 ;
    drpwe_in                                =   0 ;
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
                                                                                                    
task rst_start;                                                                                     
begin                                                                                               
    #40;
    @(posedge gt_refclk1                    );
    @(posedge init_clk                      );
    @(posedge drpclk_in                     );
    #40;
    @(posedge gt_refclk1                    );
    @(posedge init_clk                      );
    @(posedge drpclk_in                     );
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
// initial                                                                                          
initial begin                                                                                       
    signal_initial();                                                                               
    rst_start();                                                                                    
                                                                                                    
    #10000;                                                                                         
    $stop;                                                                                          
end                                                                                                 
                                                                                                    
    always #10    gt_refclk1            = ~ gt_refclk1          ;
    always #10    init_clk              = ~ init_clk            ;
    always #10    drpclk_in             = ~ drpclk_in           ;
                                                                                                  
                                                                                                    
endmodule                                                                                           
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
