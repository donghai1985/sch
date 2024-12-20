module bitslip #(
    parameter                               DATA_WD          =        8    
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   slip                           ,//(i)
    input             [DATA_WD-1:0]         din                            ,//(i)
    output   reg      [DATA_WD-1:0]         dout                            //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------'
    reg               [DATA_WD-1:0]         din_d1                         ;
    reg               [DATA_WD-1:0]         din_d2                         ;
    wire              [2*DATA_WD-1:0]       din_merge                      ;
    reg               [5:0]                 cnt                            ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            din_merge        =    {din_d2,din_d1}                ;

// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            din_d1 <= {DATA_WD{1'b0}};
            din_d2 <= {DATA_WD{1'b0}};
        end else begin  
            din_d1 <= din   ;
            din_d2 <= din_d1;
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)
            cnt <= 6'd0;
        else if((cnt == DATA_WD - 1) && slip)
            cnt <= 6'd0;
        else if(slip)
            cnt <= cnt + 1'b1;
    end

    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)
            dout <= {DATA_WD{1'b0}};
        else 
            dout <= din_merge >> cnt;
    end




endmodule





