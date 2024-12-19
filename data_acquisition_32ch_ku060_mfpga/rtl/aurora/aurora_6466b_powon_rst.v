module aurora_6466b_powon_rst #(
    parameter                               TIMES         =      512       ,
    parameter                               SIM_ENABLE    =        0         
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   soft_rst                       ,//(i)
    output     reg                          pma_init                       ,//(o)
    output     reg                          reset_pb                        //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                             REAL_TIMES      =   SIM_ENABLE ?   TIMES : 4096  ;
    localparam                             CBT_WD          =   $clog2(REAL_TIMES)           ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg       [CBT_WD       -1:0]          cnt                              ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------

// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            cnt <= {CBT_WD{1'b0}};
        else if(soft_rst)
            cnt <= {CBT_WD{1'b0}};
        else if(&cnt)
            cnt <= cnt;
        else
            cnt <= cnt + 1'b1;
    
    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            pma_init <= 1'b1;
        else if(soft_rst)
            pma_init <= 1'b1;
        else if(cnt[CBT_WD-1])
            pma_init <= 1'b0;
            
            

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            reset_pb <= 1'b1;
        else if(soft_rst)
            reset_pb <= 1'b1;
        else if(&cnt)
            reset_pb <= 1'b0;


endmodule


    




