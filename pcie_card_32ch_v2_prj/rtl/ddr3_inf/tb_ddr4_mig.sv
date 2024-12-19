// =================================================================================================
// Copyright(C) 2020  All rights reserved.                                                          
// =================================================================================================
//                                                                                                  
// =================================================================================================
// Module         : tb_ddr4_mig                                                                              
// Function       : testbench (File is generate by python.)                                         
// Type           : RTL                                                                             
// -------------------------------------------------------------------------------------------------
// Update History :                                                                                 
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents                                                
// 0.1.0      2023/10/21   holt             Create new                                                      
//                                                                                                  
// =================================================================================================
                                                                                                    
`timescale 1ns / 1ps                                                                                
                                                                                                    
module tb_ddr4_mig();                                                                                        
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal Parameter Definition                                                                
    // -------------------------------------------------------------------------                    
                                                                                                  
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal signal definition                                                                   
    // -------------------------------------------------------------------------                    
    wire                                              c0_init_calib_complete                            ;
    wire                                              dbg_clk                                           ;
    reg                                               c0_sys_clk_p                                      ;
    reg                                               c0_sys_clk_n                                      ;
    wire        [511 : 0]                             dbg_bus                                           ;
    wire        [16 : 0]                              c0_ddr4_adr                                       ;
    wire        [1 : 0]                               c0_ddr4_ba                                        ;
    wire        [0 : 0]                               c0_ddr4_cke                                       ;
    wire        [0 : 0]                               c0_ddr4_cs_n                                      ;
    wire        [0 : 0]                               c0_ddr4_dm_dbi_n                                  ;
    wire        [7 : 0]                               c0_ddr4_dq                                        ;
    wire        [0 : 0]                               c0_ddr4_dqs_c                                     ;
    wire        [0 : 0]                               c0_ddr4_dqs_t                                     ;
    wire        [0 : 0]                               c0_ddr4_odt                                       ;
    wire        [0 : 0]                               c0_ddr4_bg                                        ;
    wire                                              c0_ddr4_reset_n                                   ;
    wire                                              c0_ddr4_act_n                                     ;
    wire        [0 : 0]                               c0_ddr4_ck_c                                      ;
    wire        [0 : 0]                               c0_ddr4_ck_t                                      ;
    wire                                              c0_ddr4_ui_clk                                    ;
    wire                                              c0_ddr4_ui_clk_sync_rst                           ;
    reg                                               c0_ddr4_app_en                                    ;
    reg                                               c0_ddr4_app_hi_pri                                ;
    reg                                               c0_ddr4_app_wdf_end                               ;
    reg                                               c0_ddr4_app_wdf_wren                              ;
    wire                                              c0_ddr4_app_rd_data_end                           ;
    wire                                              c0_ddr4_app_rd_data_valid                         ;
    wire                                              c0_ddr4_app_rdy                                   ;
    wire                                              c0_ddr4_app_wdf_rdy                               ;
    reg         [27 : 0]                              c0_ddr4_app_addr                                  ;
    reg         [2 : 0]                               c0_ddr4_app_cmd                                   ;
    reg         [63 : 0]                              c0_ddr4_app_wdf_data                              ;
    reg         [7 : 0]                               c0_ddr4_app_wdf_mask                              ;
    wire        [63 : 0]                              c0_ddr4_app_rd_data                               ;
    reg                                               sys_rst                                           ;
                                                                                                  
                                                                                                    
// =================================================================================================
// RTL Body                                                                                         
// =================================================================================================
                                                                                                    
ddr4_mig u_ddr4_mig( 
    .c0_init_calib_complete                           (c0_init_calib_complete                           ),//(o)
    .dbg_clk                                          (dbg_clk                                          ),//(o)
    .c0_sys_clk_p                                     (c0_sys_clk_p                                     ),//(i)
    .c0_sys_clk_n                                     (c0_sys_clk_n                                     ),//(i)
    .dbg_bus                                          (dbg_bus                                          ),//(o)
    .c0_ddr4_adr                                      (c0_ddr4_adr                                      ),//(o)
    .c0_ddr4_ba                                       (c0_ddr4_ba                                       ),//(o)
    .c0_ddr4_cke                                      (c0_ddr4_cke                                      ),//(o)
    .c0_ddr4_cs_n                                     (c0_ddr4_cs_n                                     ),//(o)
    .c0_ddr4_dm_dbi_n                                 (c0_ddr4_dm_dbi_n                                 ),//(io)
    .c0_ddr4_dq                                       (c0_ddr4_dq                                       ),//(io)
    .c0_ddr4_dqs_c                                    (c0_ddr4_dqs_c                                    ),//(io)
    .c0_ddr4_dqs_t                                    (c0_ddr4_dqs_t                                    ),//(io)
    .c0_ddr4_odt                                      (c0_ddr4_odt                                      ),//(o)
    .c0_ddr4_bg                                       (c0_ddr4_bg                                       ),//(o)
    .c0_ddr4_reset_n                                  (c0_ddr4_reset_n                                  ),//(o)
    .c0_ddr4_act_n                                    (c0_ddr4_act_n                                    ),//(o)
    .c0_ddr4_ck_c                                     (c0_ddr4_ck_c                                     ),//(o)
    .c0_ddr4_ck_t                                     (c0_ddr4_ck_t                                     ),//(o)
    .c0_ddr4_ui_clk                                   (c0_ddr4_ui_clk                                   ),//(o)
    .c0_ddr4_ui_clk_sync_rst                          (c0_ddr4_ui_clk_sync_rst                          ),//(o)
    .c0_ddr4_app_en                                   (c0_ddr4_app_en                                   ),//(i)
    .c0_ddr4_app_hi_pri                               (c0_ddr4_app_hi_pri                               ),//(i)
    .c0_ddr4_app_wdf_end                              (c0_ddr4_app_wdf_end                              ),//(i)
    .c0_ddr4_app_wdf_wren                             (c0_ddr4_app_wdf_wren                             ),//(i)
    .c0_ddr4_app_rd_data_end                          (c0_ddr4_app_rd_data_end                          ),//(o)
    .c0_ddr4_app_rd_data_valid                        (c0_ddr4_app_rd_data_valid                        ),//(o)
    .c0_ddr4_app_rdy                                  (c0_ddr4_app_rdy                                  ),//(o)
    .c0_ddr4_app_wdf_rdy                              (c0_ddr4_app_wdf_rdy                              ),//(o)
    .c0_ddr4_app_addr                                 (c0_ddr4_app_addr                                 ),//(i)
    .c0_ddr4_app_cmd                                  (c0_ddr4_app_cmd                                  ),//(i)
    .c0_ddr4_app_wdf_data                             (c0_ddr4_app_wdf_data                             ),//(i)
    .c0_ddr4_app_wdf_mask                             (c0_ddr4_app_wdf_mask                             ),//(i)
    .c0_ddr4_app_rd_data                              (c0_ddr4_app_rd_data                              ),//(o)
    .sys_rst                                          (sys_rst                                          ) //(i)
);                                                                                                 
                                                                                                    
                                                                                                    
                                                                                                    
// task signal initial                                                                              
task signal_initial;                                                                                
begin                                                                                               
    c0_sys_clk_p                            =   0 ;
    c0_sys_clk_n                            =   0 ;
    c0_ddr4_dm_dbi_n                        =   0 ;
    c0_ddr4_dq                              =   0 ;
    c0_ddr4_dqs_c                           =   0 ;
    c0_ddr4_dqs_t                           =   0 ;
    c0_ddr4_app_en                          =   0 ;
    c0_ddr4_app_hi_pri                      =   0 ;
    c0_ddr4_app_wdf_end                     =   0 ;
    c0_ddr4_app_wdf_wren                    =   0 ;
    c0_ddr4_app_addr                        =   0 ;
    c0_ddr4_app_cmd                         =   0 ;
    c0_ddr4_app_wdf_data                    =   0 ;
    c0_ddr4_app_wdf_mask                    =   0 ;
    sys_rst                                 =   0 ;
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
                                                                                                    
task rst_start;                                                                                     
begin                                                                                               
    #40;
    sys_rst                                 =   1 ;
    @(posedge c0_sys_clk_p                  );
    @(posedge c0_sys_clk_n                  );
    #40;
    sys_rst                                 =   0 ;
    @(posedge c0_sys_clk_p                  );
    @(posedge c0_sys_clk_n                  );
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
// initial                                                                                          
initial begin                                                                                       
    signal_initial();                                                                               
    rst_start();                                                                                    
                                                                                                    
    #10000;                                                                                         
    $stop;                                                                                          
end                                                                                                 
                                                                                                    
    always #10    c0_sys_clk_p          = ~ c0_sys_clk_p        ;
    always #10    c0_sys_clk_n          = ~ c0_sys_clk_n        ;
                                                                                                  
                                                                                                    
endmodule                                                                                           
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
