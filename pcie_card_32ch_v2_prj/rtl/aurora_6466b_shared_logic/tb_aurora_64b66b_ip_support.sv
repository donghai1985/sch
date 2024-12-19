// =================================================================================================
// Copyright(C) 2020  All rights reserved.                                                          
// =================================================================================================
//                                                                                                  
// =================================================================================================
// Module         : tb_aurora_64b66b_ip_support                                                                              
// Function       : testbench (File is generate by python.)                                         
// Type           : RTL                                                                             
// -------------------------------------------------------------------------------------------------
// Update History :                                                                                 
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents                                                
// 0.1.0      2023/10/24   holt             Create new                                                      
//                                                                                                  
// =================================================================================================
                                                                                                    
`timescale 1ns / 1ps                                                                                
                                                                                                    
module tb_aurora_64b66b_ip_support();                                                                                        
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal Parameter Definition                                                                
    // -------------------------------------------------------------------------                    
                                                                                                  
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal signal definition                                                                   
    // -------------------------------------------------------------------------                    
    reg         [0:127]                               s_axi_tx_tdata                                    ;
    reg         [0:15]                                s_axi_tx_tkeep                                    ;
    reg                                               s_axi_tx_tlast                                    ;
    reg                                               s_axi_tx_tvalid                                   ;
    wire                                              s_axi_tx_tready                                   ;
    wire        [0:127]                               m_axi_rx_tdata                                    ;
    wire        [0:15]                                m_axi_rx_tkeep                                    ;
    wire                                              m_axi_rx_tlast                                    ;
    wire                                              m_axi_rx_tvalid                                   ;
    reg         [0:1]                                 rxp                                               ;
    reg         [0:1]                                 rxn                                               ;
    wire        [0:1]                                 txp                                               ;
    wire        [0:1]                                 txn                                               ;
    wire                                              hard_err                                          ;
    wire                                              soft_err                                          ;
    wire                                              channel_up                                        ;
    wire        [0:1]                                 lane_up                                           ;
    wire                                              user_clk_out                                      ;
    wire                                              sync_clk_out                                      ;
    reg                                               reset_pb                                          ;
    reg                                               gt_rxcdrovrden_in                                 ;
    reg                                               power_down                                        ;
    reg         [2:0]                                 loopback                                          ;
    reg                                               pma_init                                          ;
    wire        [15:0]                                gt0_drpdo                                         ;
    wire                                              gt0_drprdy                                        ;
    wire        [15:0]                                gt1_drpdo                                         ;
    wire                                              gt1_drprdy                                        ;
    reg         [8:0]                                 gt0_drpaddr                                       ;
    reg         [15:0]                                gt0_drpdi                                         ;
    reg                                               gt0_drpen                                         ;
    reg                                               gt0_drpwe                                         ;
    reg         [8:0]                                 gt1_drpaddr                                       ;
    reg         [15:0]                                gt1_drpdi                                         ;
    reg                                               gt1_drpen                                         ;
    reg                                               gt1_drpwe                                         ;
    reg                                               init_clk                                          ;
    wire                                              link_reset_out                                    ;
    wire                                              gt_pll_lock                                       ;
    wire                                              sys_reset_out                                     ;
    reg                                               gt_refclk1_p                                      ;
    reg                                               gt_refclk1_n                                      ;
    wire                                              bufg_gt_clr_out                                   ;
    wire                                              mmcm_not_locked_out                               ;
    wire                                              tx_out_clk                                        ;
                                                                                                  
                                                                                                    
// =================================================================================================
// RTL Body                                                                                         
// =================================================================================================
                                                                                                    
aurora_64b66b_ip_support u_aurora_64b66b_ip_support( 
    .s_axi_tx_tdata                                   (s_axi_tx_tdata                                   ),//(i)
    .s_axi_tx_tkeep                                   (s_axi_tx_tkeep                                   ),//(i)
    .s_axi_tx_tlast                                   (s_axi_tx_tlast                                   ),//(i)
    .s_axi_tx_tvalid                                  (s_axi_tx_tvalid                                  ),//(i)
    .s_axi_tx_tready                                  (s_axi_tx_tready                                  ),//(o)
    .m_axi_rx_tdata                                   (m_axi_rx_tdata                                   ),//(o)
    .m_axi_rx_tkeep                                   (m_axi_rx_tkeep                                   ),//(o)
    .m_axi_rx_tlast                                   (m_axi_rx_tlast                                   ),//(o)
    .m_axi_rx_tvalid                                  (m_axi_rx_tvalid                                  ),//(o)
    .rxp                                              (rxp                                              ),//(i)
    .rxn                                              (rxn                                              ),//(i)
    .txp                                              (txp                                              ),//(o)
    .txn                                              (txn                                              ),//(o)
    .hard_err                                         (hard_err                                         ),//(o)
    .soft_err                                         (soft_err                                         ),//(o)
    .channel_up                                       (channel_up                                       ),//(o)
    .lane_up                                          (lane_up                                          ),//(o)
    .user_clk_out                                     (user_clk_out                                     ),//(o)
    .sync_clk_out                                     (sync_clk_out                                     ),//(o)
    .reset_pb                                         (reset_pb                                         ),//(i)
    .gt_rxcdrovrden_in                                (gt_rxcdrovrden_in                                ),//(i)
    .power_down                                       (power_down                                       ),//(i)
    .loopback                                         (loopback                                         ),//(i)
    .pma_init                                         (pma_init                                         ),//(i)
    .gt0_drpdo                                        (gt0_drpdo                                        ),//(o)
    .gt0_drprdy                                       (gt0_drprdy                                       ),//(o)
    .gt1_drpdo                                        (gt1_drpdo                                        ),//(o)
    .gt1_drprdy                                       (gt1_drprdy                                       ),//(o)
    .gt0_drpaddr                                      (gt0_drpaddr                                      ),//(i)
    .gt0_drpdi                                        (gt0_drpdi                                        ),//(i)
    .gt0_drpen                                        (gt0_drpen                                        ),//(i)
    .gt0_drpwe                                        (gt0_drpwe                                        ),//(i)
    .gt1_drpaddr                                      (gt1_drpaddr                                      ),//(i)
    .gt1_drpdi                                        (gt1_drpdi                                        ),//(i)
    .gt1_drpen                                        (gt1_drpen                                        ),//(i)
    .gt1_drpwe                                        (gt1_drpwe                                        ),//(i)
    .init_clk                                         (init_clk                                         ),//(i)
    .link_reset_out                                   (link_reset_out                                   ),//(o)
    .gt_pll_lock                                      (gt_pll_lock                                      ),//(o)
    .sys_reset_out                                    (sys_reset_out                                    ),//(o)
    .gt_refclk1_p                                     (gt_refclk1_p                                     ),//(i)
    .gt_refclk1_n                                     (gt_refclk1_n                                     ),//(i)
    .bufg_gt_clr_out                                  (bufg_gt_clr_out                                  ),//(o)
    .mmcm_not_locked_out                              (mmcm_not_locked_out                              ),//(o)
    .tx_out_clk                                       (tx_out_clk                                       ) //(o)
);                                                                                                             
                                                                                                    
                                                                                                    
                                                                                                    
// task signal initial                                                                              
task signal_initial;                                                                                
begin                                                                                               
    s_axi_tx_tdata                          =   0 ;
    s_axi_tx_tkeep                          =   0 ;
    s_axi_tx_tlast                          =   0 ;
    s_axi_tx_tvalid                         =   0 ;
    rxp                                     =   0 ;
    rxn                                     =   0 ;
    reset_pb                                =   0 ;
    gt_rxcdrovrden_in                       =   0 ;
    power_down                              =   0 ;
    loopback                                =   0 ;
    pma_init                                =   0 ;
    gt0_drpaddr                             =   0 ;
    gt0_drpdi                               =   0 ;
    gt0_drpen                               =   0 ;
    gt0_drpwe                               =   0 ;
    gt1_drpaddr                             =   0 ;
    gt1_drpdi                               =   0 ;
    gt1_drpen                               =   0 ;
    gt1_drpwe                               =   0 ;
    init_clk                                =   0 ;
    gt_refclk1_p                            =   0 ;
    gt_refclk1_n                            =   0 ;
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
                                                                                                    
task rst_start;                                                                                     
begin                                                                                               
    #40;
    @(posedge init_clk                      );
    @(posedge gt_refclk1_p                  );
    @(posedge gt_refclk1_n                  );
    #40;
    @(posedge init_clk                      );
    @(posedge gt_refclk1_p                  );
    @(posedge gt_refclk1_n                  );
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
// initial                                                                                          
initial begin                                                                                       
    signal_initial();                                                                               
    rst_start();                                                                                    
                                                                                                    
    #10000;                                                                                         
    $stop;                                                                                          
end                                                                                                 
                                                                                                    
    always #10    init_clk              = ~ init_clk            ;
    always #10    gt_refclk1_p          = ~ gt_refclk1_p        ;
    always #10    gt_refclk1_n          = ~ gt_refclk1_n        ;
                                                                                                  
                                                                                                    
endmodule                                                                                           
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
