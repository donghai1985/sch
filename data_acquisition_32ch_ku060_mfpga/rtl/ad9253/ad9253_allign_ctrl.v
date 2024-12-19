module ad9253_allign_ctrl #(
    parameter                               TEST            =  0001       
)(
    input                                   sys_clk                        ,//(i) 100M
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rdy                        ,//(i)
    input             [8:0]                 vio_dly_cnt                    ,//(i)       
    input             [15:0]                err_cnt                        ,//(i)
    input             [7:0]                 fc_patten                      ,//(i)
    output                                  bit_slip                       ,//(o)
    output   reg      [8:0]                 ctrl_cnt_imp                   ,//(o)
    output   reg      [8:0]                 ctrl_cnt                       ,//(o)
    output                                  en_vtc                         ,//(o)
    output                                  train_cpl                      ,//(o)
    output            [31:0]                pat_err_cnt                     //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    parameter                               MAX_CNT              =    32               ;
    parameter                               PATTEN_TRAIN_TIME    =    48'd100_000000   ;//32:30s 100m:10s == 48'd1000_000000
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------'
    wire                                    soft_rst                       ;
    wire              [31:0]                soft_rst_cnt                   ;
    reg               [3:0]                 sta             =    0         ;
    reg               [9:0]                 timer           =    0         ;
    wire                                    allign_ok                      ;
    reg               [47:0]                cnt1m                          ;
    reg               [31:0]                cnt1s                          ;
    wire                                    pos1s                          ;
    wire                                    pos2s                          ;
    wire                                    pos3s                          ;
    wire                                    pos4s                          ;
    wire                                    pos5s                          ;
    wire                                    pos6s                          ;
    reg               [15:0]                err_cnt_1s      =    0         ;
    reg               [15:0]                err_cnt_3s      =    0         ;
    reg               [15:0]                err_cnt_5s      =    0         ;
    wire              [15:0]                patten_err_cnt                 ;
    wire              [7 :0]                user_dly                       ;
    reg               [7 :0]                user_dly2                      ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            bit_slip         =     (sta   == 4'd2)               ;
    assign            allign_ok        =     (8'hF0 == fc_patten)          ;
    assign            user_dly         =     (cnt1m == PATTEN_TRAIN_TIME) ? 8'd32 : 8'd0;
    //assign            ctrl_cnt_imp     =      ctrl_cnt + user_dly + user_dly2;

    assign            pos1s            =      cnt1s  == 32'd100_000000      ;//1s
    assign            pos2s            =      cnt1s  == 32'd200_000000      ;//1s
    assign            pos3s            =      cnt1s  == 32'd300_000000      ;//1s
    assign            pos4s            =      cnt1s  == 32'd400_000000      ;//1s
    assign            pos5s            =      cnt1s  == 32'd500_000000      ;//1s
    assign            pos6s            =      cnt1s  == 32'd600_000000      ;//1s
    assign            pos7s            =      cnt1s  == 32'd700_000000      ;//1s
    assign            soft_rst         =      patten_err_cnt > 16'h1000     ;
    assign            en_vtc           =      &cnt1s                        ;
    assign            train_cpl        =      (cnt1m == PATTEN_TRAIN_TIME)  ;
    assign            pat_err_cnt      =      {soft_rst_cnt,patten_err_cnt} ;
// =================================================================================================
// RTL Body
// =================================================================================================

    //----------PATTEN_TRAIN-----------------------------------------------------------------//
    always@(posedge clk)begin
        if(soft_rst)
            sta <= 4'd0;
        else if(cfg_rdy)begin
                case(sta)
                4'd0:sta <= 4'd1;
                4'd1:if((~allign_ok) && (ctrl_cnt>9'd450))
                        sta <= 4'd2;
                     else if(allign_ok && (&timer))
                        sta <= 4'd3;
                     else
                        sta <= 4'd1;
                4'd2:   sta <= 4'd0;
                4'd3:if(~allign_ok) 
                        sta <= 4'd0;
                default:sta <= 4'd0;
            endcase
        end else begin
            sta <= 4'd0;
        end
    end

    always@(posedge clk) begin
        if(soft_rst)
            timer <= 'd0;
        else if((timer >= MAX_CNT) && (sta==4'd1) && (~allign_ok))
            timer <= 'd0;
        else if((sta==4'd1)&&(~allign_ok))
            timer <= timer + 1'b1;
        else if((sta==4'd1)&&(allign_ok))
            timer <= timer + 1'b1;
        else 
            timer <= 'd0;
    end

    always @(posedge clk) begin
        if(|vio_dly_cnt || soft_rst)begin
            ctrl_cnt <= 5'd0;
        end else begin
            case(sta)
            4'd0:ctrl_cnt <= ctrl_cnt;
            4'd1:if((timer >= MAX_CNT) && (~allign_ok))
                     ctrl_cnt <= ctrl_cnt + 4'd10;
            4'd2:ctrl_cnt <= 5'd0;
            4'd3:if(~allign_ok) 
                     ctrl_cnt <= ctrl_cnt + 4'd10;
                 else 
                     ctrl_cnt <= ctrl_cnt;
            endcase
        end
    end

    always@(posedge clk)begin
        if(soft_rst)
            cnt1m <= 32'd0;
        else if(cfg_rdy)
            if(cnt1m == PATTEN_TRAIN_TIME)//60s
                cnt1m <= PATTEN_TRAIN_TIME;
            else
                cnt1m <= cnt1m + 32'd1;
        else 
            cnt1m <= 32'd0;
    end

    //----------PATTEN_TRAIN END--------------------------------------------------------------//

    //----------DATA_TRAIN--------------------------------------------------------------------//
    always@(posedge clk)begin
        if(soft_rst)
            cnt1s <= 32'd0;
        else if(pos7s)
            cnt1s <= {32{1'b1}};
        else if(&cnt1s)
            cnt1s <= cnt1s;
        else if(cnt1m == PATTEN_TRAIN_TIME)
            cnt1s <= cnt1s + 32'd1;
        else 
            cnt1s <= 32'd0;
    end

    always@(posedge clk)begin
        if(pos1s)
            err_cnt_1s <= err_cnt;
    end

    always@(posedge clk)begin
        if(pos3s)
            err_cnt_3s <= err_cnt;
    end

    always@(posedge clk)begin
        if(pos5s)
            err_cnt_5s <= err_cnt;
    end

    always@(posedge clk)begin
        if(~(cnt1m == PATTEN_TRAIN_TIME))
            user_dly2 <= 8'd0;
        else if(pos2s && (err_cnt_1s != err_cnt))
            user_dly2 <= user_dly2 + 8'd32;
        else if(pos4s && (err_cnt_3s != err_cnt))
            user_dly2 <= user_dly2 + 8'd32;
        else if(pos6s && (err_cnt_5s != err_cnt))
            user_dly2 <= user_dly2 + 8'd32;
    end
    
    
    always@(posedge clk)begin
        if(soft_rst)
            ctrl_cnt_imp <= 'd0;
        else if(&cnt1s)
            ctrl_cnt_imp <= ctrl_cnt_imp;
        else
            ctrl_cnt_imp <= ctrl_cnt + user_dly + user_dly2;
    end
    //----------DATA_TRAIN END----------------------------------------------------------------//


    //----------ERR DETECT--------------------------------------------------------------------//
    cmip_app_cnt #(
        .width       (16                           )
    )u0_app_cnt(                                   
        .clk         (clk                          ),//(i)
        .rst_n       (1'b1                         ),//(i)
        .clr         (~(cnt1m == PATTEN_TRAIN_TIME)),//(i)
        .vld         (~ allign_ok                  ),//(i)
        .cnt         (patten_err_cnt               ) //(o)
    );


    cmip_app_cnt #(
        .width       (16                           )
    )u1_app_cnt(                                   
        .clk         (clk                          ),//(i)
        .rst_n       (1'b1                         ),//(i)
        .clr         (1'b0                         ),//(i)
        .vld         (soft_rst                     ),//(i)
        .cnt         (soft_rst_cnt                 ) //(o)
    );



endmodule





