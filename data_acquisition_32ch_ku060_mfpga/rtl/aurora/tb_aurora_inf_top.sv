// =================================================================================================
// Copyright(C) 2020  All rights reserved.                                                          
// =================================================================================================
//                                                                                                  
// =================================================================================================
// Module         : tb_aurora_inf_top                                                                              
// Function       : testbench (File is generate by python.)                                         
// Type           : RTL                                                                             
// -------------------------------------------------------------------------------------------------
// Update History :                                                                                 
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents                                                
// 0.1.0      2023/11/01   holt             Create new                                                      
//                                                                                                  
// =================================================================================================
                                                                                                    
`timescale 1ns / 1ps                                                                                
                                                                                                    
module tb_aurora_inf_top();                                                                                        
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal Parameter Definition                                                                
    // -------------------------------------------------------------------------                    
    parameter                                         DATA_WD                      =                 128;
    parameter                                         ADC_CNT_WD                   =                  11;
    parameter                                         HEAD_WD                      =                  64;
    parameter                                         CFG_WD                       =                  32;
                                                                                                  
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal signal definition                                                                   
    // -------------------------------------------------------------------------                    
    reg                                               rst_n                                             ;
    reg                                               init_clk                                          ;
    wire                                              user_clk                                          ;
    reg                                               cfg_rst                                           ;
    reg                                               cfg_cpl                                           ;
    wire                                              channel_up                                        ;
    wire                                              channel_up1                                       ;
    reg                                               adc_enable                                        ;
    wire                                              adc_fifo_rd                                       ;
    reg         [DATA_WD    -1:0]                     adc_fifo_din                                      ;
    reg                                               adc_fifo_empty                                    ;
    reg         [ADC_CNT_WD -1:0]                     adc_fifo_data_cnt                                 ;
    reg                                               gt_refclk1_p                                      ;
    reg                                               gt_refclk1_n                                      ;
    reg         [0:1]                                 rxp                                               ;
    reg         [0:1]                                 rxn                                               ;
    wire        [0:1]                                 txp                                               ;
    wire        [0:1]                                 txn                                               ;
    reg                                               rxp1                                              ;
    reg                                               rxn1                                              ;
    wire                                              txp1                                              ;
    wire                                              txn1                                              ;
    wire        [15:0]                                pkt_sop_cnt                                       ;
    wire        [15:0]                                pkt_eop_cnt                                       ;
                                                                                                  
                                                                                                    
// =================================================================================================
// RTL Body                                                                                         
// =================================================================================================
                                                                                                    
aurora_inf_top #(                                                                                               
    .DATA_WD                                          (DATA_WD                                          ),
    .ADC_CNT_WD                                       (ADC_CNT_WD                                       ),
    .HEAD_WD                                          (HEAD_WD                                          ),
    .CFG_WD                                           (CFG_WD                                           )       
)u_aurora_inf_top( 
    .rst_n                                            (rst_n                                            ),//(i)
    .init_clk                                         (init_clk                                         ),//(i)
    .user_clk                                         (user_clk                                         ),//(o)
    .cfg_rst                                          (cfg_rst                                          ),//(i)
    .cfg_cpl                                          (cfg_cpl                                          ),//(i)
    .channel_up                                       (channel_up                                       ),//(o)
    .channel_up1                                      (channel_up1                                      ),//(o)
    .adc_enable                                       (adc_enable                                       ),//(i)
    .adc_fifo_rd                                      (adc_fifo_rd                                      ),//(o)
    .adc_fifo_din                                     (adc_fifo_din                                     ),//(i)
    .adc_fifo_empty                                   (adc_fifo_empty                                   ),//(i)
    .adc_fifo_data_cnt                                (adc_fifo_data_cnt                                ),//(i)
    .gt_refclk1_p                                     (gt_refclk1_p                                     ),//(i)
    .gt_refclk1_n                                     (gt_refclk1_n                                     ),//(i)
    .rxp                                              (rxp                                              ),//(i)
    .rxn                                              (rxn                                              ),//(i)
    .txp                                              (txp                                              ),//(o)
    .txn                                              (txn                                              ),//(o)
    .rxp1                                             (rxp1                                             ),//(i)
    .rxn1                                             (rxn1                                             ),//(i)
    .txp1                                             (txp1                                             ),//(o)
    .txn1                                             (txn1                                             ),//(o)
    .pkt_sop_cnt                                      (pkt_sop_cnt                                      ),//(o)
    .pkt_eop_cnt                                      (pkt_eop_cnt                                      ) //(o)
);                                                                                                 
                                                                                                    
                                                                                                    
                                                                                                    
// task signal initial                                                                              
task signal_initial;                                                                                
begin                                                                                               
    rst_n                                   =   0 ;
    init_clk                                =   0 ;
    cfg_rst                                 =   0 ;
    cfg_cpl                                 =   0 ;
    adc_enable                              =   0 ;
    adc_fifo_din                            =   0 ;
    adc_fifo_empty                          =   0 ;
    adc_fifo_data_cnt                       =   0 ;
    gt_refclk1_p                            =   0 ;
    gt_refclk1_n                            =   0 ;
    rxp                                     =   0 ;
    rxn                                     =   0 ;
    rxp1                                    =   0 ;
    rxn1                                    =   0 ;
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
                                                                                                    
task rst_start;                                                                                     
begin                                                                                               
    #40;
    rst_n                                   =   0 ;
    cfg_rst                                 =   1 ;
    @(posedge init_clk                      );
    @(posedge gt_refclk1_p                  );
    @(posedge gt_refclk1_n                  );
    #40;
    rst_n                                   =   1 ;
    cfg_rst                                 =   0 ;
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
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
