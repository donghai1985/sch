module enc_acc_chg #(
    parameter                              DATA_WD           =      512         ,
    parameter                              HEAD_WD           =      64          
)(       
    input                                  clk                                  ,//(i)
    input                                  rst_n                                ,//(i)
    input                                  cfg_rst                              ,//(i)
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
    reg               [15:0]               cnt                                  ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------

// =================================================================================================
// RTL Body
// =================================================================================================

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt <= 16'd0;
        else if(cfg_rst)
            cnt <= 16'd0;
        else if(fir_ivld)
            cnt <= cnt + 1'b1;
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            fir_ovld  <= 1'b0;           
            fir_odat  <= {DATA_WD{1'b0}};
            enc_odat  <= {HEAD_WD{1'b0}};
        end else begin
            fir_ovld  <= fir_ivld;           
            fir_odat  <= fir_idat;
            enc_odat  <= {enc_idat[HEAD_WD-1:16],cnt};
        end
    end



endmodule





















































