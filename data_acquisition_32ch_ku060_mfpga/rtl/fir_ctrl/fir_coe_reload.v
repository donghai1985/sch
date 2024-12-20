// =================================================================================================
// Copyright 2020 - 2030 (c) Semi, Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : fir_coe_reload.v
// Module         : fir
// Function       :  
// Type           : RTL
// =================================================================================================
// End Revision
// =================================================================================================

module fir_coe_reload #(
    parameter     COE_NUM          =        51              ,
    parameter     COE_WDTH         =        29              ,
    parameter     COE_NUM_HALF     =       (COE_NUM+1)/2    
)(
    input                                   cfg_clk         ,//(i)
    input                                   cfg_rst_n       ,//(i)
    input                                   coe_vld         ,//(i)
    input                [COE_WDTH  -1:0]   coe_din         ,//(i)
    input                                   coe_sop         ,//(i)
    input                                   coe_load        ,//(i)
    input                [31:0]             coe_fir_dec     ,//(i)

    input                                   clk             ,//(i)
    input                                   rst_n           ,//(i)
    output  reg          [31:0]             fir_dec         ,//(o)
    output  reg [COE_NUM_HALF*COE_WDTH-1:0] coe_arr          //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    integer                                 i,j                 ;
    genvar                                  gx,gy               ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg              [COE_NUM_HALF-1:0]   sop_pipe                   ;
    reg              [COE_WDTH    -1:0]   coe_din_d1                 ;
    wire                                  coe_load_sync              ;
    reg              [COE_WDTH    -1:0]   cfg_coe  [COE_NUM_HALF-1:0];
    wire    [COE_NUM_HALF*COE_WDTH-1:0]   cfg_coe_arr                ;
    wire    [COE_NUM_HALF*COE_WDTH-1:0]   cfg_coe_arr_sync           ;
    wire             [31            :0]   coe_fir_dec_sync          ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------


// =================================================================================================
// RTL Body
// =================================================================================================



//--------------------coe reload process-------------------------------------------------------------//
    always @(posedge cfg_clk or negedge cfg_rst_n)begin
        if(~cfg_rst_n)begin
            sop_pipe   <= 'd0;
            coe_din_d1 <= 'd0;
        end else begin
            sop_pipe   <= {sop_pipe,coe_sop && coe_vld};
            coe_din_d1 <=  coe_din;
        end
    end


generate for(gx=0;gx<COE_NUM_HALF;gx=gx+1)begin
    always @(posedge cfg_clk)begin
        if(sop_pipe[gx])
            cfg_coe[gx] <= coe_din_d1;
    end
end
endgenerate


generate
    for(gy=0; gy<COE_NUM_HALF;gy=gy+1) begin:PART1
        assign  cfg_coe_arr[COE_WDTH*(gy+1)-1:COE_WDTH*gy] = cfg_coe[gy];
    end
endgenerate



//----------SYNC--------------------------------------------------------------//
    cmip_bit_sync #(                                    
        .DATA_WDTH               (32                   ) 
    )u0_cmip_bit_sync( 
        .i_dst_clk               (clk                  ),//(i)
        .i_din                   (coe_fir_dec          ),//(i)
        .o_dout                  (coe_fir_dec_sync     ) //(o)
    );                                                 


    cmip_bit_sync #(                                    
        .DATA_WDTH               (COE_NUM_HALF*COE_WDTH) 
    )u1_cmip_bit_sync( 
        .i_dst_clk               (clk                  ),//(i)
        .i_din                   (cfg_coe_arr          ),//(i)
        .o_dout                  (cfg_coe_arr_sync     ) //(o)
    );                                                 

    cmip_pulse_sync u_cmip_pulse_sync(
        .i_src_clk               (cfg_clk              ),//(i)
        .i_src_rst_n             (cfg_rst_n            ),//(i)
        .i_dst_clk               (clk                  ),//(i)
        .i_dst_rst_n             (rst_n                ),//(i)
        .i_pulse                 (coe_load             ),//(i)
        .o_pulse                 (coe_load_sync        ) //(o)
    );


    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            fir_dec <= 'd0;
        end else if(coe_load_sync)begin
            fir_dec <= coe_fir_dec_sync;
            coe_arr <= cfg_coe_arr_sync;
        end
    end


endmodule    













    