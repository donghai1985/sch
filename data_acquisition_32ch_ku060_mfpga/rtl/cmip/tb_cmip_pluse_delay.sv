// =================================================================================================
// Copyright(C) 2020  All rights reserved.                                                          
// =================================================================================================
//                                                                                                  
// =================================================================================================
// Module         : tb_cmip_pluse_delay                                                                              
// Function       : testbench (File is generate by python.)                                         
// Type           : RTL                                                                             
// -------------------------------------------------------------------------------------------------
// Update History :                                                                                 
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents                                                
// 0.1.0      2024/05/15   holt             Create new                                                      
//                                                                                                  
// =================================================================================================
                                                                                                    
`timescale 1ns / 1ps                                                                                
                                                                                                    
module tb_cmip_pluse_delay();                                                                                        
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal Parameter Definition                                                                
    // -------------------------------------------------------------------------                    
    parameter                                         TIMES                        =              8'd255;
    parameter                                         HOLD_CLK                     =                  10;
                                                                                                  
                                                                                                    
    // -------------------------------------------------------------------------                    
    // Internal signal definition                                                                   
    // -------------------------------------------------------------------------                    
    reg                                               i_clk                                             ;
    reg                                               i_rst_n                                           ;
    reg                                               i_sig                                             ;
    wire                                              o_pluse                                           ;
                                                                                                  
                                                                                                    
// =================================================================================================
// RTL Body                                                                                         
// =================================================================================================
                                                                                                    
cmip_pluse_delay #(                                                                                               
    .TIMES                                            (TIMES                                            ),
    .HOLD_CLK                                         (HOLD_CLK                                         )       
)u_cmip_pluse_delay( 
    .i_clk                                            (i_clk                                            ),//(i)
    .i_rst_n                                          (i_rst_n                                          ),//(i)
    .i_sig                                            (i_sig                                            ),//(i)
    .o_pluse                                          (o_pluse                                          ) //(o)
);                                                                                                 
                                                                                                    
                                                                                                    
                                                                                                    
// task signal initial                                                                              
task signal_initial;                                                                                
begin                                                                                               
    i_clk                                   =   0 ;
    i_rst_n                                 =   0 ;
    i_sig                                   =   0 ;
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
                                                                                                    
task rst_start;                                                                                     
begin                                                                                               
    #40;
    i_rst_n                                 =   0 ;
    @(posedge i_clk                         );
    #40;
    i_rst_n                                 =   1 ;
    @(posedge i_clk                         );
                                                                                                  
end                                                                                                 
endtask                                                                                             
                                                                                                    
// initial                                                                                          
initial begin                                                                                       
    signal_initial();                                                                               
    rst_start();          
    #400;                                                                          
    @(posedge i_clk);
    i_sig  =1;
    @(posedge i_clk);
    i_sig  =0;
    @(posedge i_clk);
    
    #10000;                                                                                         
    $stop;                                                                                          
end                                                                                                 
                                                                                                    
    always #10    i_clk                 = ~ i_clk               ;
                                                                                                  
                                                                                                    
endmodule                                                                                           
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
                                                                                                    
