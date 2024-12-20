module track_gen (       
    input                                  sys_clk                                ,//(i)
    input                                  sys_rst_n                              ,//(i)
    input                                  soft_rst_sync                          ,//(i)
    input                                  fir_en                                 ,//(i)
    input                                  fir_din_vld                            ,//(i)
    input            [63:0]                enc_din                                ,//(i)

    input                                  cfg_clk                                ,//(i)
    input                                  cfg_rst_n                              ,//(i)
    input                                  soft_rst                               ,//(i)
    output                                 track_pos                              ,//(o)
    output   reg     [15:0]                track_num                               //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //--------------------------------------------------------------------------       
    // Defination of Internal Signals       
    //--------------------------------------------------------------------------       
    reg               [2:0]                cnt                                  ;
    reg               [17:0]               wenc_lock                            ;
    reg                                    track_cmp                            ;
    wire              [17:0]               wenc_cur                             ;

    reg                                    track_cmp_d1                         ;
    reg                                    track_cmp_d2                         ;
    reg                                    track_cmp_d3                         ;
    wire                                   track_all_pos                        ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            wenc_cur      =     enc_din[51:34]                        ;
    //assign            track_cmp     =     fir_en && fir_din_vld && (wenc_cur >= wenc_lock);
    //assign            track_cmp     =     (cnt>=3'd1) && fir_din_vld && (wenc_cur >= wenc_lock);
    assign            track_all_pos =     ~track_cmp_d3 && track_cmp_d2         ;
    assign            track_pos     =     track_all_pos && (track_num != 16'd0) ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(~sys_rst_n)
            track_cmp <= 1'b1;
        else if(soft_rst_sync)
            track_cmp <= 1'b1;
        else if(fir_en && fir_din_vld && (cnt>=3'd1))
            track_cmp <= (wenc_cur >= wenc_lock) ? 1'b1 : 1'b0;
        else
            track_cmp <= track_cmp;
    end



    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            cnt <= 3'd0;
        else if(soft_rst_sync)
            cnt <= 3'd0;
        else if(&cnt)
            cnt <= cnt;
        else if(fir_din_vld && fir_en)
            cnt <= cnt + 1'b1;
    end


    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            wenc_lock <= 18'd0;
        else if(soft_rst_sync)
            wenc_lock <= 18'd0;
        else if(cnt==8'd0 && fir_din_vld)
            wenc_lock <= (enc_din[51:34] == 18'd0) ? 18'd1 : enc_din[51:34];
    end


    always@(posedge cfg_clk or negedge cfg_rst_n)begin
        if(!cfg_rst_n)begin
            track_cmp_d1 <= 1'b1;
            track_cmp_d2 <= 1'b1;
            track_cmp_d3 <= 1'b1;
        end else if(soft_rst)begin
            track_cmp_d1 <= 1'b1;
            track_cmp_d2 <= 1'b1;
            track_cmp_d3 <= 1'b1;
        end else begin
            track_cmp_d1 <= track_cmp   ;
            track_cmp_d2 <= track_cmp_d1;
            track_cmp_d3 <= track_cmp_d2;
        end
    end


    always@(posedge cfg_clk or negedge cfg_rst_n)begin
        if(!cfg_rst_n) 
            track_num <= 16'd0;
        else if(soft_rst)
            track_num <= 16'd0;
        else if(track_all_pos)  
            track_num <= track_num + 1'd1;
    end




endmodule





















































