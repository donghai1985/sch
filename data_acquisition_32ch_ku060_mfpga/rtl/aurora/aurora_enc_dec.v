module aurora_enc_dec #(
    parameter                               DATA_WD         =    64        
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rst                        ,//(i)

    input                                   i_vld                          ,//(i)
    input             [DATA_WD   -1:0]      i_din                          ,//(i)
    output  reg                             o_vld                          ,//(o)
    output  reg       [DATA_WD   -1:0]      o_din                           //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //---------------------------------------------------------------------     
    // Defination of Internal Signals                                           
    //---------------------------------------------------------------------     
    reg               [7           :0]      cnt                             ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    //assign            last_flag      =      s_axis_tvalid && s_axis_tready && s_axis_tlast ;

// =================================================================================================
// RTL Body
// =================================================================================================


    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            cnt <= 8'd0;
        else if(cfg_rst)
            cnt <= 8'd0;
        else if(i_vld && cnt==8'd24)
            cnt <= 8'd0;
        else if(i_vld)
            cnt <= cnt + 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            o_vld <=          1'b0  ;
            o_din <= {DATA_WD{1'b0}};
        end else if(i_vld && (cnt==8'd0 || cnt==8'd3 || cnt==8'd6 || cnt==8'd9 || cnt==8'd12 || cnt==8'd15 || cnt==8'd18 || cnt==8'd21))begin
            o_vld <=          1'b1  ;
            o_din <=          i_din ;
        end else begin
            o_vld <=          1'b0  ;
            o_din <=          o_din ;
        end
    end

    //---------------------------------------------------------------------
    // app_cnt.
    //---------------------------------------------------------------------



endmodule





