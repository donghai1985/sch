// =================================================================================================
// Copyright 2020 - 2030 (c) Semi, Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : filter_fir_imp.v
// Module         : fir
// Function       :  
// Type           : RTL
// =================================================================================================
// End Revision
// =================================================================================================

`define     SYNTH      

module filter_fir_imp #(
    parameter     COE_NUM          =        51              ,
    parameter     COE_WDTH         =        29              ,
    parameter     COE_NUM_HALF     =       (COE_NUM+1)/2    ,
    parameter     XDATA_WDTH       =        14              ,
    parameter     YDATA_WDTH       =        14              
)(
    input                                   bypass          ,//(i)
    input     [COE_NUM_HALF*COE_WDTH-1:0]   coe_arr         ,//(i)
    input                                   clk             ,//(i)
    input                                   rst_n           ,//(i)
    input                                   xvld            ,//(i)
    input                [XDATA_WDTH-1:0]   xin             ,//(i)
    input                [15:0]             xin_16b         ,//(i)
    output                                  yvld            ,//(o)
    output               [YDATA_WDTH-1:0]   yout             //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
//  localparam    COE_NUM_HALF    =         (COE_NUM+1)/2       ;
    localparam    COE_IS_ODD      =   2*COE_NUM_HALF - COE_NUM  ;
    localparam    ADD_TIMES       =         COE_NUM_HALF/4      ;
    localparam    XMULTI_WDTH     =   COE_WDTH + XDATA_WDTH + 1 ;
    localparam    XMULTI_SUM_WDTH =   COE_WDTH + XDATA_WDTH + $clog2(COE_NUM) ;
    integer                                 i,j                 ;
    genvar                                  gx,gy,gz            ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg              [COE_NUM_HALF-1:0]   sop_pipe                   ;
    reg              [COE_WDTH    -1:0]   coe_din_d1                 ;
    wire                                  coe_load_sync              ;
    reg              [COE_WDTH    -1:0]   cfg_coe  [COE_NUM_HALF-1:0];
    wire             [COE_WDTH    -1:0]   sync_coe [COE_NUM_HALF-1:0];
    wire             [COE_WDTH    -1:0]   coe [COE_NUM_HALF-1:0];

    reg              [XDATA_WDTH  -1:0]   xnum[COE_NUM     -1:0];
    reg              [XDATA_WDTH    :0]   xadd[COE_NUM_HALF-1:0];
    wire             [XMULTI_WDTH -1:0]   xmulti[COE_NUM_HALF-1:0];
    reg              [XMULTI_SUM_WDTH-1:0]xmulti_add[ADD_TIMES-1:0];
    reg              [XMULTI_SUM_WDTH-1:0]xmulti_add_sum1        ;
    reg              [XMULTI_SUM_WDTH-1:0]xmulti_add_sum2        ;
    reg              [XMULTI_SUM_WDTH-1:0]xmulti_add_sum2_d1     ;
    reg              [YDATA_WDTH-1:0]     fir_yout               ;
    wire             [YDATA_WDTH-1:0]     dir_yout               ;
    wire                                  sync_bypass            ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            yout =  sync_bypass ? dir_yout : fir_yout  ;

// =================================================================================================
// RTL Body
// =================================================================================================
    generate
        for(gz=0; gz<COE_NUM_HALF;gz=gz+1) begin
            assign  coe[gz] = coe_arr[COE_WDTH*(gz+1)-1:COE_WDTH*gz];
        end
    endgenerate
    

`ifdef  SYNTH
//--------------------fir process--------------------------------------------------------------------//
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            xnum[0] <= {XDATA_WDTH{1'b0}};
        else if(xvld)
            xnum[0] <= xin              ;

genvar   gi;
generate for(gi=1;gi<COE_NUM;gi=gi+1)begin
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            xnum[gi] <= {XDATA_WDTH{1'b0}};
        else if(xvld)
            xnum[gi] <= xnum[gi-1];
end
endgenerate

genvar   gj;
generate for(gj=0;gj<COE_NUM_HALF;gj=gj+1)begin
    if(gj < COE_NUM_HALF-1)begin
        always @(posedge clk or negedge rst_n)
            if(!rst_n)
                xadd[gj] <= {XDATA_WDTH{1'b0}};
            else
                xadd[gj] <= xnum[gj] + xnum[COE_NUM - 1 -gj];
    end else if(gj==COE_NUM_HALF-1) begin
        always @(posedge clk or negedge rst_n)
            if(!rst_n)
                xadd[gj] <= {XDATA_WDTH{1'b0}};
            else
                xadd[gj] <= COE_IS_ODD ? xnum[gj] : (xnum[gj] + xnum[COE_NUM - 1 -gj]);
    end
end
endgenerate
           
genvar   gk;
generate for(gk=0;gk<COE_NUM_HALF;gk=gk+1)begin
    myip_mac #(
        .A_WDTH         (XDATA_WDTH + 1  ),
        .A_SIGNED       (0               ),
        .B_WDTH         (COE_WDTH        ),
        .B_SIGNED       (0               ),
        .C_WDTH         (8               ),
        .BUS_DELAY      (1               )
    )u0_myip_mac(                          
        .clk            (clk             ),//(i)
        .rst_n          (rst_n           ),//(i)
        .a              (xadd[gk]        ),//(i)
        .b              (coe[gk]         ),//(i)
        .c              (8'b0            ),//(i)
        .sum            (xmulti[gk]      ) //(o)
    );
end
endgenerate


generate for(gx=0;gx<ADD_TIMES;gx=gx+1)begin
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            xmulti_add[gx] <= {XMULTI_WDTH{1'b0}};
        else  
            xmulti_add[gx] <= xmulti[4*gx] + xmulti[4*gx+1] + xmulti[4*gx+2] + xmulti[4*gx+3];
end
endgenerate

    
    always @(*) begin
        xmulti_add_sum1    = 'd0    ;
        for (i = 0; i < ADD_TIMES ; i = i + 1) begin
            xmulti_add_sum1 = xmulti_add_sum1 + xmulti_add[i]    ;
        end
    end

    always @(*) begin
        xmulti_add_sum2    = 'd0    ;
        for (j = 4*ADD_TIMES; j < COE_NUM_HALF ; j = j + 1) begin
            xmulti_add_sum2 = xmulti_add_sum2 + xmulti[j]    ;
        end
    end
    
    always@(posedge clk)begin
        xmulti_add_sum2_d1 <= xmulti_add_sum2;//xmulti_add_sum2_d1
    end


    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            fir_yout <= {YDATA_WDTH{1'b0}};
        else
            //fir_yout <= (xmulti_add_sum1 + xmulti_add_sum2_d1) >>> 32;//pay attention.
            fir_yout <= (xmulti_add_sum1 + xmulti_add_sum2_d1) >> 28;//pay attention.
    end

`endif
    // -------------------------------------------------------------------------
    // cmip_bus_delay Module Inst.
    // -------------------------------------------------------------------------
    cmip_bus_delay #(                                
        .BUS_DELAY          (5                      ),
        .DATA_WDTH          (1                      )
    )u0_cmip_bus_delay(                              
        .i_clk              (clk                    ),//(i)
        .i_rst_n            (rst_n                  ),//(i)
        .i_din              (xvld                   ),//(i)
        .o_dout             (yvld                   ) //(o)
    );  

    cmip_bus_delay #(                                
        .BUS_DELAY          (5                      ),
        .DATA_WDTH          (YDATA_WDTH             )
    )u1_cmip_bus_delay(                              
        .i_clk              (clk                    ),//(i)
        .i_rst_n            (rst_n                  ),//(i)
        .i_din              (xin_16b                ),//(i)
        .o_dout             (dir_yout               ) //(o)
    );  

    cmip_bit_sync #(                                 
        .DATA_WDTH          (1                      ) 
    )u_cmip_bit_sync(   
        .i_dst_clk          (clk                    ),//(i)
        .i_din              (bypass                 ),//(i)
        .o_dout             (sync_bypass            ) //(o)
    );                                              






endmodule    













    