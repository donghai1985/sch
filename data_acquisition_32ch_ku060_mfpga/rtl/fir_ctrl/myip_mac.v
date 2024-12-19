module myip_mac #(
    parameter                               A_WDTH          =   8          ,
    parameter                               A_SIGNED        =   1          ,
    parameter                               B_WDTH          =   8          ,
    parameter                               B_SIGNED        =   1          ,
    parameter                               C_WDTH          =   8          ,
    parameter                               SUM_WDTH        =  A_WDTH + B_WDTH ,
    parameter                               BUS_DELAY       =   1           
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input             [A_WDTH        -1:0]  a                              ,//(i)
    input             [B_WDTH        -1:0]  b                              ,//(i)
    input             [C_WDTH        -1:0]  c                              ,//(i)
    output            [SUM_WDTH      -1:0]  sum                             //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
(* use_dsp = "yes" *)wire              [SUM_WDTH     -1:0]   sum_res                            ;
    wire              [SUM_WDTH     -1:0]   sum_pip_data                       ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------

    


// =================================================================================================
// RTL Body
// =================================================================================================

generate if((A_SIGNED==1)&&(B_SIGNED==1)) begin
    assign    sum_res   =   $signed(a) * $signed(b) + $signed(c) ;
end else if((A_SIGNED==0)&&(B_SIGNED==0))begin
    //assign    sum_res   =   a * b + c;
    assign    sum_res   =   a * b  ;
end else if((A_SIGNED==0)&&(B_SIGNED==1))begin
    assign    sum_res   =   a * $signed(b) + $signed(c) ;
end else if((A_SIGNED==0)&&(B_SIGNED==1))begin
    assign    sum_res   =   $signed(a) * b + $signed(c) ;
end else begin
    assign    sum_res   =   a * b + c;
end
endgenerate



    //---------------------------------------------------------------------
    // pipeline
    //---------------------------------------------------------------------     
generate if(BUS_DELAY==0) begin
    assign      sum_pip_data    =     sum_res           ;
end else begin
    cmip_bus_delay #(                                
        .BUS_DELAY          (BUS_DELAY              ),
        .DATA_WDTH          (SUM_WDTH               )
    )u_cmip_bus_delay(                              
        .i_clk              (clk                    ),//(i)
        .i_rst_n            (rst_n                  ),//(i)
        .i_din              (sum_res                ),//(i)
        .o_dout             (sum_pip_data           ) //(o)
    );  
end
endgenerate


    assign      sum     =     sum_pip_data           ;





endmodule





