module ad5674_easy_ctrl (
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   ad5674_cm_trig                 ,//(i)
    input         [11:0]                    ad5674_cm_din                  ,//(i)
    output                                  ad5674_trig                    ,//(i)
    output  reg   [4:0]                     ad5674_ch                      ,//(i)
    output        [11:0]                    ad5674_din                      //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg           [15:0]                    cnt_10ms                       ;
    wire                                    ad5674_cm_trig_pos             ;
    reg                                     ad5674_cm_trig_d1     =   0    ;
    reg                                     ad5674_cm_trig_d2     =   0    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign        ad5674_cm_trig_pos   =    ~ad5674_cm_trig_d2 && ad5674_cm_trig_d1;
    assign        ad5674_trig          =     cnt_10ms == 16'd5             ;
    assign        ad5674_din           =     ad5674_cm_din                 ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge clk)begin
        ad5674_cm_trig_d1 <= ad5674_cm_trig;
        ad5674_cm_trig_d2 <= ad5674_cm_trig_d1;
    end


    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            cnt_10ms <= 16'd0;
        else if(ad5674_cm_trig_pos)
            cnt_10ms <= 16'd0;
        else if((&ad5674_ch) && (&cnt_10ms))
            cnt_10ms <= cnt_10ms;
        else
            cnt_10ms <= cnt_10ms + 1'b1;
    end

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            ad5674_ch <= 5'd0;
        else if(ad5674_cm_trig_pos)
            ad5674_ch <= 5'd0;
        else if(&ad5674_ch)
            ad5674_ch <= ad5674_ch;
        else if(&cnt_10ms)
            ad5674_ch <= ad5674_ch + 1'b1;
    end



endmodule





