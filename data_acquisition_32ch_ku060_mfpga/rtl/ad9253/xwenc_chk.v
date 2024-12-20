module xwenc_chk (       
    input                                  sys_clk                                ,//(i)
    input                                  sys_rst_n                              ,//(i)
    input                                  cfg_rst                                ,//(i)
    input                                  enc_vld                                ,//(i)
    input            [17:0]                xenc_din                               ,//(i)
    input            [17:0]                wenc_din                               ,//(i)

    output   reg     [17:0]                xenc_1st                               ,//(o)
    output   reg     [17:0]                wenc_1st                               ,//(o)
    output   reg     [31:0]                jp_pos_1st                             ,//(o)
    output           [31:0]                jp_num                                  //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //--------------------------------------------------------------------------       
    // Defination of Internal Signals       
    //--------------------------------------------------------------------------       
    reg               [47:0]               cnt                                  ;
    reg               [17:0]               xenc_din_d1                          ;
    reg               [17:0]               wenc_din_d1                          ;
    reg               [17:0]               xenc_din_d2                          ;
    reg               [17:0]               wenc_din_d2                          ;
    reg                                    wenc_jp_pos                          ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------


// =================================================================================================
// RTL Body
// =================================================================================================


    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            cnt <= 'd0;
        else if(cfg_rst)
            cnt <= 'd0;
        else if(enc_vld)
            cnt <= cnt + 1'b1;
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            xenc_1st  <=  'd0;
            wenc_1st  <=  'd0;
        end else if(enc_vld && (cnt==48'd0))begin
            xenc_1st  <=  xenc_din;
            wenc_1st  <=  wenc_din;
        end
    end


    always@(posedge sys_clk)begin
        if(enc_vld)begin
            wenc_din_d1 <= wenc_din    ;
            wenc_din_d2 <= wenc_din_d1 ;
        end 
    end

    always@(*)begin
        if(enc_vld && (cnt >= 48'd2))
            if(wenc_din_d1 == wenc_din_d2)
                wenc_jp_pos = 1'b0;
            else if(wenc_din_d1 == (wenc_din_d2+1'b1))
                wenc_jp_pos = 1'b0;
            else if((wenc_din_d1 == 18'd0) && (wenc_din_d2 == 18'd262143))
                wenc_jp_pos = 1'b0;
            else 
                wenc_jp_pos = 1'b1;
        else
                wenc_jp_pos = 1'b0;
    end


    cmip_app_cnt #(
        .width     (32                             )
    )u0_app_cnt(                                     
        .clk       (sys_clk                        ),//(i)
        .rst_n     (sys_rst_n                      ),//(i)
        .clr       (cfg_rst                        ),//(i)
        .vld       (wenc_jp_pos                    ),//(i)
        .cnt       (jp_num                         ) //(o)
    );


    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            jp_pos_1st <= 'd0;
        else if(cfg_rst)
            jp_pos_1st <= 'd0;
        else if((jp_num == 32'd0) && wenc_jp_pos)
            jp_pos_1st <= cnt - 3'd2;
    end



endmodule





















































