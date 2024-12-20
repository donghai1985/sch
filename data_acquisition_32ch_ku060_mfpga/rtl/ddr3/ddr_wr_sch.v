// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : ddr_wr_sch.v
// Module         : ddr_wr_sch
// Function       : 
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2023/09/28   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================


module ddr_wr_sch #(
    parameter                               DDR_ADDR_WD     =  16          ,
    parameter                               DDR_DATA_WD     =  512         
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)

    input                                   ddr_burst_idle                 ,//(i)     
    input                                   ch0_wr_burst_req               ,//(i)      
    input             [9:0]                 ch0_wr_burst_len               ,//(i)  
    input             [DDR_ADDR_WD  -1:0]   ch0_wr_burst_addr              ,//(i)    
    output                                  ch0_wr_burst_data_req          ,//(o) 
    input             [DDR_DATA_WD  -1:0]   ch0_wr_burst_data              ,//(i)
    output                                  ch0_wr_burst_finish            ,//(i)

    input                                   ch1_wr_burst_req               ,//(i)
    input             [9:0]                 ch1_wr_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch1_wr_burst_addr              ,//(i)
    output                                  ch1_wr_burst_data_req          ,//(o)
    input             [DDR_DATA_WD  -1:0]   ch1_wr_burst_data              ,//(i)
    output                                  ch1_wr_burst_finish            ,//(i)

    input                                   ch2_wr_burst_req               ,//(i)
    input             [9:0]                 ch2_wr_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch2_wr_burst_addr              ,//(i)
    output                                  ch2_wr_burst_data_req          ,//(o)
    input             [DDR_DATA_WD  -1:0]   ch2_wr_burst_data              ,//(i)
    output                                  ch2_wr_burst_finish            ,//(i)

    input                                   ch3_wr_burst_req               ,//(i)
    input             [9:0]                 ch3_wr_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch3_wr_burst_addr              ,//(i)
    output                                  ch3_wr_burst_data_req          ,//(o)
    input             [DDR_DATA_WD  -1:0]   ch3_wr_burst_data              ,//(i)
    output                                  ch3_wr_burst_finish            ,//(i)

    output                                  wr_burst_req                   ,//(o)
    output  reg       [9:0]                 wr_burst_len                   ,//(o)
    output  reg       [DDR_ADDR_WD  -1:0]   wr_burst_addr                  ,//(o)
    input                                   wr_burst_data_req              ,//(i)
    output  reg       [DDR_DATA_WD  -1:0]   wr_burst_data                  ,//(o)
    input                                   wr_burst_finish                 //(i)


);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    


    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire              [3:0]                 sch_req                        ;
    wire                                    sch_vld                        ;
    wire              [3:0]                 sch_gnt                        ;
    wire              [1:0]                 sch_idx                        ;
    reg               [1:0]                 sch_idx_lock                   ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign   sch_req                =   {ch3_wr_burst_req,ch2_wr_burst_req,ch1_wr_burst_req,ch0_wr_burst_req};
    assign   wr_burst_req           =    sch_vld                           ;
    assign   ch0_wr_burst_data_req  =   (sch_idx_lock == 2'd0) ? wr_burst_data_req : 1'b0;
    assign   ch1_wr_burst_data_req  =   (sch_idx_lock == 2'd1) ? wr_burst_data_req : 1'b0;
    assign   ch2_wr_burst_data_req  =   (sch_idx_lock == 2'd2) ? wr_burst_data_req : 1'b0;
    assign   ch3_wr_burst_data_req  =   (sch_idx_lock == 2'd3) ? wr_burst_data_req : 1'b0;
    assign   ch0_wr_burst_finish    =   (sch_idx_lock == 2'd0) ? wr_burst_finish   : 1'b0;
    assign   ch1_wr_burst_finish    =   (sch_idx_lock == 2'd1) ? wr_burst_finish   : 1'b0;
    assign   ch2_wr_burst_finish    =   (sch_idx_lock == 2'd2) ? wr_burst_finish   : 1'b0;
    assign   ch3_wr_burst_finish    =   (sch_idx_lock == 2'd3) ? wr_burst_finish   : 1'b0;
// =================================================================================================
// RTL Body
// =================================================================================================

    //---------------------------------------------------------------------
    // axi2ddr_wr_inf Inst.
    //---------------------------------------------------------------------     
    cmip_rr_sch #(                                           
        .FLOP_OUT                 (1                               ),
        .REQ_WDTH                 (4                               ),
        .IDX_WDTH                 (2                               )       
    )u_cmip_rr_sch(            
        .i_clk                    (ddr_clk                         ),//(i)
        .i_rst_n                  (ddr_rst_n                       ),//(i)
        .i_rdy                    (ddr_burst_idle && (~sch_vld)    ),//(i)
        .i_req                    (sch_req                         ),//(i)
        .o_gnt_vld                (sch_vld                         ),//(o)
        .o_gnt                    (sch_gnt                         ),//(o)
        .o_gnt_idx                (sch_idx                         ) //(o)
    );                                                    

    always@(*)begin
        case(sch_idx)
        2'd0:begin
            wr_burst_len  = ch0_wr_burst_len ;
            wr_burst_addr = ch0_wr_burst_addr;
        end
        2'd1:begin
            wr_burst_len  = ch1_wr_burst_len ;
            wr_burst_addr = ch1_wr_burst_addr;
        end
        2'd2:begin
            wr_burst_len  = ch2_wr_burst_len ;
            wr_burst_addr = ch2_wr_burst_addr;
        end
        2'd3:begin
            wr_burst_len  = ch3_wr_burst_len ;
            wr_burst_addr = ch3_wr_burst_addr;
        end
        endcase
    end

    always@(posedge ddr_clk or negedge ddr_rst_n)begin
        if(~ddr_rst_n)
            sch_idx_lock <= 2'b0;
        else if(sch_vld)
            sch_idx_lock <= sch_idx;
    end

    always@(*)begin
        case(sch_idx_lock)
        2'd0:begin
            wr_burst_data  = ch0_wr_burst_data ;
        end
        2'd1:begin
            wr_burst_data  = ch1_wr_burst_data ;
        end
        2'd2:begin
            wr_burst_data  = ch2_wr_burst_data ;
        end
        2'd3:begin
            wr_burst_data  = ch3_wr_burst_data ;
        end
        endcase
    end



endmodule





