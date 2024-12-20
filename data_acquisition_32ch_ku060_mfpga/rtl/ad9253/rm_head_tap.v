module rm_head_tap (       
    input                                  clk                                  ,//(i)
    input                                  rst_n                                ,//(i)
    input                                  cfg_rst                              ,//(i)
    input             [9:0]                num                                  ,//(i)
    input                                  ivld                                 ,//(i)
    output                                 ovld                                  //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //--------------------------------------------------------------------------       
    // Defination of Internal Signals       
    //--------------------------------------------------------------------------       
    reg               [15:0]               cnt                                  ;
    reg               [9:0]                num_d1                               ;
    reg               [9:0]                num_d2                               ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            ovld     =           ivld && (num_d2==cnt)                   ;

// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            num_d1 <= 'd0;
            num_d2 <= 'd0;
        end else begin
            num_d1 <= num;
            num_d2 <= num_d1;
        end
    end


    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt <= 16'd0;
        else if(cfg_rst)
            cnt <= 16'd0;
        else if(num_d2==cnt)
            cnt <= cnt;
        else if(ivld)
            cnt <= cnt + 1'b1;
    end





endmodule





















































