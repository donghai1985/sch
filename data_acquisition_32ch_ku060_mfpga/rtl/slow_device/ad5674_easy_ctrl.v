module ad5674_easy_ctrl (
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    
    input                                   bias_tap_wr_cmd                ,//(o)
    input         [32-1:0]                  bias_tap_wr_addr               ,//(o)
    input                                   bias_tap_wr_vld                ,//(o)
    input         [32-1:0]                  bias_tap_wr_data               ,//(o)

    input                                   ch0_ad5674_trig                ,//(i)
    input         [3:0]                     ch0_ad5674_cmd                 ,//(i)
    input         [4:0]                     ch0_ad5674_ch                  ,//(i)
    input         [15:0]                    ch0_ad5674_din                 ,//(i)

    output                                  ad5674_trig                    ,//(o)
    output        [3:0]                     ad5674_cmd                     ,//(o)
    output        [4:0]                     ad5674_ch                      ,//(o)
    output        [15:0]                    ad5674_din                      //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg           [12:0]                    cnt_10ms                       ;
    wire                                    ad5674_cm_trig_pos             ;
    
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                    ch1_ad5674_trig                ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire          [3:0]                     ch1_ad5674_cmd                 ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg           [4:0]                     ch1_ad5674_ch                  ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire          [15:0]                    ch1_ad5674_din                 ;
    
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                    bias_tap_wr_cmd_pos            ;
    reg           [15:0]                    mem_high   [31:0]              ;
    reg           [15:0]                    mem_low    [31:0]              ;
    wire          [4:0]                     rd_cnt                         ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg           [4:0]                     wr_cnt                         ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg                                     auto_cfg_en                    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign        ad5674_cm_trig_pos   =     bias_tap_wr_vld && (wr_cnt==5'd15);
    assign        ch1_ad5674_trig      =     cnt_10ms == 16'd5             ;
    assign        ch1_ad5674_cmd       =     4'h3                          ;
    assign        rd_cnt               =     ch1_ad5674_ch[4:1]            ;
    assign        ch1_ad5674_din       =     ch1_ad5674_ch[0] ? mem_low[rd_cnt] : mem_high[rd_cnt];
    
    assign        ad5674_trig          =     auto_cfg_en ? ch1_ad5674_trig : ch0_ad5674_trig ;
    assign        ad5674_cmd           =     auto_cfg_en ? ch1_ad5674_cmd  : ch0_ad5674_cmd  ;
    assign        ad5674_ch            =     auto_cfg_en ? ch1_ad5674_ch   : ch0_ad5674_ch   ;
    assign        ad5674_din           =     auto_cfg_en ? ch1_ad5674_din  : ch0_ad5674_din  ;
    
// =================================================================================================
// RTL Body
// =================================================================================================

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            cnt_10ms <= 16'd0;
        else if(ad5674_cm_trig_pos)
            cnt_10ms <= 16'd0;
        else if((&ch1_ad5674_ch) && (&cnt_10ms))
            cnt_10ms <= cnt_10ms;
        else
            cnt_10ms <= cnt_10ms + 1'b1;
    end

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            ch1_ad5674_ch <= 5'd0;
        else if(ad5674_cm_trig_pos)
            ch1_ad5674_ch <= 5'd0;
        else if(&ch1_ad5674_ch)
            ch1_ad5674_ch <= ch1_ad5674_ch;
        else if(&cnt_10ms)           //   65536 / 100000 /8 = 0.08192ms == 82us 
            ch1_ad5674_ch <= ch1_ad5674_ch + 1'b1;
    end


    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            auto_cfg_en <= 1'd0;
        else if(ad5674_cm_trig_pos)
            auto_cfg_en <= 1'd1;
        else if((&ch1_ad5674_ch) && (&cnt_10ms))
            auto_cfg_en <= 1'd0;
    end

//--------------------------------------------------------------------//

    cmip_edge_sync #(                                          
        .RISE                    (1                    ),
        .PIPELINE                (1                    )       
    )u_cmip_edge_sync( 
        .i_clk                   (clk                  ),//(i)
        .i_rst_n                 (rst_n                ),//(i)
        .i_sig                   (bias_tap_wr_cmd      ),//(i)
        .o_edge                  (bias_tap_wr_cmd_pos  ) //(o)
    );                                                       
    
    

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            wr_cnt <= 'd0;
        else if(bias_tap_wr_cmd_pos)
            wr_cnt <= 'd0;
        else if(bias_tap_wr_vld)
            wr_cnt <= wr_cnt + 1'b1;
    end
        

    always@(posedge clk) begin
        if(bias_tap_wr_vld)begin
            mem_high[wr_cnt] <= bias_tap_wr_data[31:16];
            mem_low [wr_cnt] <= bias_tap_wr_data[15: 0];
        end
    end















endmodule





