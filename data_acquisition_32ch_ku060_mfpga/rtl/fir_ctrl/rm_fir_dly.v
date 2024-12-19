module rm_fir_dly #(
    parameter                              DATA_WD           =      512         ,
    parameter                              HEAD_WD           =      64          ,
    parameter                              BUS_DELAY         =      32            
)(       
    input                                  clk                                  ,//(i)
    input                                  rst_n                                ,//(i)
    input                                  cfg_rst                              ,//(i)
    input                                  fir_en                               ,//(i)
    input                                  fir_ivld                             ,//(i)
    input             [DATA_WD     -1:0]   fir_idat                             ,//(i)
    input             [HEAD_WD     -1:0]   enc_idat                             ,//(i)

    output  reg                            fir_ovld                             ,//(o)
    output  reg       [DATA_WD     -1:0]   fir_odat                             ,//(o)
    output  reg       [HEAD_WD     -1:0]   enc_odat                              //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //--------------------------------------------------------------------------       
    // Defination of Internal Signals       
    //--------------------------------------------------------------------------   
    genvar                                 gi                                   ;
    wire                                   enable                               ;
    reg               [7:0]                cnt                                  ;
    reg               [HEAD_WD     -1:0]   end_arr   [BUS_DELAY -1:0]           ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            enable    =        (cnt == BUS_DELAY)                     ;

// =================================================================================================
// RTL Body
// =================================================================================================

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt <= 16'd0;
        else if(cfg_rst)
            cnt <= 16'd0;
        else if(enable)
            cnt <= cnt;
        else if(fir_ivld)
            cnt <= cnt + 1'b1;
    end

    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            end_arr[0] <= {HEAD_WD{1'b0}};
        else if(fir_ivld)
            end_arr[0] <= enc_idat       ;

generate for(gi=1;gi<BUS_DELAY;gi=gi+1)begin
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            end_arr[gi] <= {HEAD_WD{1'b0}};
        else if(fir_ivld)
            end_arr[gi] <= end_arr[gi-1];
end
endgenerate




always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        fir_ovld  <= 1'b0;           
        fir_odat  <= {DATA_WD{1'b0}};
        enc_odat  <= {HEAD_WD{1'b0}};
    end else if(~fir_en)begin
        fir_ovld  <= fir_ivld               ;  
        fir_odat  <= fir_idat               ;  
        enc_odat  <= enc_idat               ;  
    end else if(enable)begin
        fir_ovld  <= fir_ivld               ;  
        fir_odat  <= fir_idat               ;  
        enc_odat  <= end_arr[BUS_DELAY -1]  ;  
    end else begin
        fir_ovld  <= 1'b0;           
        fir_odat  <= {DATA_WD{1'b0}};
        enc_odat  <= {HEAD_WD{1'b0}};
    end
end




endmodule





















































