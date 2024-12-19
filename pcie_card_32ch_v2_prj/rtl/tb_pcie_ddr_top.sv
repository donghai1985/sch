// =================================================================================================
// Copyright(C) 2020  All rights reserved.                                                          
// =================================================================================================
//                                                                                                  
// =================================================================================================
// Module         : tb_pcie_ddr_top                                                                              
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
                                                                                                    
module tb_pcie_ddr_top();                                                                                        
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal Parameter Definition                                                                
    // -------------------------------------------------------------------------                    
    parameter                                         TEST                         =                  16;
                                                                                                  
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal signal definition                                                                   
    // -------------------------------------------------------------------------                    
    reg                                               sys_clk                                           ;
    wire                                              sys_clk_p                                         ;
    wire                                              sys_clk_n                                         ;
    reg                                               c0_sys_clk                                        ;
    wire                                              c0_sys_clk_p                                      ;
    wire                                              c0_sys_clk_n                                      ;
    reg                                               sys_rst_n                                         ;
    reg         [1:0]                                 pcie_mgt_rxn                                      ;
    reg         [1:0]                                 pcie_mgt_rxp                                      ;
    wire        [1:0]                                 pcie_mgt_txn                                      ;
    wire        [1:0]                                 pcie_mgt_txp                                      ;
    reg                                               pcie_ref_clk_n                                    ;
    reg                                               pcie_ref_clk_p                                    ;
    reg                                               pcie_rst_n                                        ;
    wire                                              init_calib_cpl                                    ;
    wire                                              lnk_up_led                                        ;
    reg                                               gt_refclk1_p                                      ;
    reg                                               gt_refclk1_n                                      ;
    reg         [1:0]                                 c0_rxp                                            ;
    reg         [1:0]                                 c0_rxn                                            ;
    wire        [1:0]                                 c0_txp                                            ;
    wire        [1:0]                                 c0_txn                                            ;
    reg                                               c1_rxp                                            ;
    reg                                               c1_rxn                                            ;
    wire                                              c1_txp                                            ;
    wire                                              c1_txn                                            ;
    wire        [16: 0]                               c0_ddr4_adr                                       ;
    wire        [1 : 0]                               c0_ddr4_ba                                        ;
    wire        [0 : 0]                               c0_ddr4_cke                                       ;
    wire        [0 : 0]                               c0_ddr4_cs_n                                      ;
    wire        [7 : 0]                               c0_ddr4_dm_n                                      ;
    wire        [63: 0]                               c0_ddr4_dq                                        ;
    wire        [7 : 0]                               c0_ddr4_dqs_c                                     ;
    wire        [7 : 0]                               c0_ddr4_dqs_t                                     ;
    wire        [0 : 0]                               c0_ddr4_odt                                       ;
    wire        [1 : 0]                               c0_ddr4_bg                                        ;
    wire                                              c0_ddr4_reset_n                                   ;
    wire                                              c0_ddr4_act_n                                     ;
    wire        [0 : 0]                               c0_ddr4_ck_c                                      ;
    wire        [0 : 0]                               c0_ddr4_ck_t                                      ;
                                                                                                  
                                                                                                    
// =================================================================================================
// RTL Body                                                                                         
// =================================================================================================
                                                                                                    
pcie_ddr_top #(                                                                                               
    .TEST                                             (TEST                                             ),
    .SIM                                              (1                                                )       
)u_pcie_ddr_top( 
    .sys_clk_p                                        (sys_clk_p                                        ),//(i)
    .sys_clk_n                                        (sys_clk_n                                        ),//(i)
    .c0_sys_clk_p                                     (c0_sys_clk_p                                     ),//(i)
    .c0_sys_clk_n                                     (c0_sys_clk_n                                     ),//(i)
    .sys_rst_n                                        (sys_rst_n                                        ),//(i)
    .pcie_mgt_rxn                                     (pcie_mgt_rxn                                     ),//(i)
    .pcie_mgt_rxp                                     (pcie_mgt_rxp                                     ),//(i)
    .pcie_mgt_txn                                     (pcie_mgt_txn                                     ),//(o)
    .pcie_mgt_txp                                     (pcie_mgt_txp                                     ),//(o)
    .pcie_ref_clk_n                                   (pcie_ref_clk_n                                   ),//(i)
    .pcie_ref_clk_p                                   (pcie_ref_clk_p                                   ),//(i)
    .pcie_rst_n                                       (pcie_rst_n                                       ),//(i)
    .init_calib_cpl                                   (init_calib_cpl                                   ),//(o)
    .lnk_up_led                                       (lnk_up_led                                       ),//(o)
    .gt_refclk1_p                                     (gt_refclk1_p                                     ),//(i)
    .gt_refclk1_n                                     (gt_refclk1_n                                     ),//(i)
    .c0_rxp                                           (c0_txp                                           ),//(i)
    .c0_rxn                                           (c0_txn                                           ),//(i)
    .c0_txp                                           (c0_txp                                           ),//(o)
    .c0_txn                                           (c0_txn                                           ),//(o)
    // .c1_rxp                                           (c1_txp                                           ),//(i)
    // .c1_rxn                                           (c1_txn                                           ),//(i)
    // .c1_txp                                           (c1_txp                                           ),//(o)
    // .c1_txn                                           (c1_txn                                           ),//(o)
    .c0_ddr4_adr                                      (c0_ddr4_adr                                      ),//(o)
    .c0_ddr4_ba                                       (c0_ddr4_ba                                       ),//(o)
    .c0_ddr4_cke                                      (c0_ddr4_cke                                      ),//(o)
    .c0_ddr4_cs_n                                     (c0_ddr4_cs_n                                     ),//(o)
    .c0_ddr4_dm_n                                     (c0_ddr4_dm_n                                     ),//(i)
    .c0_ddr4_dq                                       (c0_ddr4_dq                                       ),//(i)
    .c0_ddr4_dqs_c                                    (c0_ddr4_dqs_c                                    ),//(i)
    .c0_ddr4_dqs_t                                    (c0_ddr4_dqs_t                                    ),//(i)
    .c0_ddr4_odt                                      (c0_ddr4_odt                                      ),//(o) 
    .c0_ddr4_bg                                       (c0_ddr4_bg                                       ),//(o) 
    .c0_ddr4_reset_n                                  (c0_ddr4_reset_n                                  ),//(o) 
    .c0_ddr4_act_n                                    (c0_ddr4_act_n                                    ),//(o)
    .c0_ddr4_ck_c                                     (c0_ddr4_ck_c                                     ),//(o)
    .c0_ddr4_ck_t                                     (c0_ddr4_ck_t                                     ) //(o)
);                                                                                                 




myddr_sim_tb_top u_myddr_sim_tb_top(
    .c0_ddr4_adr                  (c0_ddr4_adr          ),//(o)
    .c0_ddr4_ba                   (c0_ddr4_ba           ),//(o)
    .c0_ddr4_cke                  (c0_ddr4_cke          ),//(o)
    .c0_ddr4_cs_n                 (c0_ddr4_cs_n         ),//(o)
    .c0_ddr4_dm_dbi_n             (c0_ddr4_dm_n         ),//(i)
    .c0_ddr4_dq                   (c0_ddr4_dq           ),//(i)
    .c0_ddr4_dqs_c                (c0_ddr4_dqs_c        ),//(i)
    .c0_ddr4_dqs_t                (c0_ddr4_dqs_t        ),//(i)
    .c0_ddr4_odt                  (c0_ddr4_odt          ),//(o)
    .c0_ddr4_bg                   (c0_ddr4_bg           ),//(o)
    .c0_ddr4_reset_n              (c0_ddr4_reset_n      ),//(o)
    .c0_ddr4_act_n                (c0_ddr4_act_n        ),//(o)
    .c0_ddr4_ck_c                 (c0_ddr4_ck_c         ),//(o)
    .c0_ddr4_ck_t                 (c0_ddr4_ck_t         ),//(o)
    .c0_init_calib_complete       (init_calib_cpl       ) //(i)
);


                                                                                                    
defparam   u_pcie_ddr_top.u_axi2ddr_top.DDR3_SIM = 0;                                                                                                        
                                                                                                    
// task signal initial                                                                              
task signal_initial;                                                                                
begin                                                                                               
    sys_clk                                 =   0 ;
    c0_sys_clk                            =   0 ;
    sys_rst_n                               =   0 ;
    pcie_mgt_rxn                            =   0 ;
    pcie_mgt_rxp                            =   0 ;
    pcie_ref_clk_n                          =   0 ;
    pcie_ref_clk_p                          =   0 ;
    pcie_rst_n                              =   0 ;
    gt_refclk1_p                            =   0 ;
    gt_refclk1_n                            =   0 ;
    c0_rxp                                  =   0 ;
    c0_rxn                                  =   0 ;
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
                                                                                                    
task rst_start;                                                                                     
begin                                                                                               
    #40;
    sys_rst_n                               =   0 ;
    pcie_rst_n                              =   0 ;
    @(posedge sys_clk                       );
    @(posedge gt_refclk1_p                  );
    @(posedge gt_refclk1_n                  );
    #40;
    sys_rst_n                               =   1 ;
    pcie_rst_n                              =   1 ;
    @(posedge sys_clk                       );
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
                                                                                                    
    always #2     sys_clk               = ~ sys_clk             ;
    always #1.6   c0_sys_clk          = ~ c0_sys_clk        ;
    always #10    gt_refclk1_p          = ~ gt_refclk1_p        ;
    always #10    gt_refclk1_n          = ~ gt_refclk1_n        ;

    assign        sys_clk_p             =   sys_clk             ;
    assign        sys_clk_n             = ~ sys_clk             ;

    assign        c0_sys_clk_p        =   c0_sys_clk        ;
    assign        c0_sys_clk_n        = ~ c0_sys_clk        ;
                                                                                                  
                                                                                                    
endmodule                                                                                           
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
