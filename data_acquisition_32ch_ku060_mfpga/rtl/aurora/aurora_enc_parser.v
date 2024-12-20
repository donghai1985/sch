module aurora_enc_parser #(
    parameter                               DATA_WD         =    64        ,
    parameter                               DOUT_WD        =     64        ,
    parameter                               FIFO_DEPTH     =     2048       
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rst                        ,//(i)
    input                                   clk_100m                       ,//(i)//32m
    input                                   clk_100m_rst_n                 ,//(i)

    input             [DATA_WD   -1:0]      s_axis_tdata                   ,//(i)
    input             [DATA_WD/8 -1:0]      s_axis_tkeep                   ,//(i)
    input                                   s_axis_tvalid                  ,//(i)
    output                                  s_axis_tready                  ,//(o)
    input                                   s_axis_tlast                   ,//(i)

(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output                                  enc_vld                        ,//(o)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output            [DATA_WD   -1:0]      enc_data                       ,//(o)
    output                                  enc_finish                     ,//(o)
    output            [31:0]                enc_sop_eop_cnt                ,//(o)
    output            [31:0]                enc_sop_eop_clr_cnt            ,//(o)
    output            [15:0]                enc_sop_cnt                    ,//(o)
    output            [15:0]                enc_eop_cnt                    ,//(o)
    output            [31:0]                enc_vld_cnt                     //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                              DIN_WD            =  DATA_WD    ;
    localparam                              RATE              =  DOUT_WD/DIN_WD;
    localparam                              FIFO_ADDR_WD      =  $clog2(FIFO_DEPTH);
    //---------------------------------------------------------------------     
    // Defination of Internal Signals                                           
    //---------------------------------------------------------------------     
    reg               [DATA_WD   -1:0]      s_axis_tdata_d1                 ;
    wire                                    last_flag                       ;
    reg                                     enc_send_en                     ;
    reg                                     enc_send_en_d1                  ;
    wire                                    enc_send_en_pos                 ;
    reg                                     enc_first_drop                  ;

    wire                                    fifo_wr                         ;
    wire              [DIN_WD     -1:0]     fifo_din                        ;
    reg                                     fifo_wr_d1                      ;
    reg               [DIN_WD     -1:0]     fifo_din_d1                     ;
    reg                                     fifo_wr_d2                      ;
    reg               [DIN_WD     -1:0]     fifo_din_d2                     ;
    wire                                    enc_dec_vld                     ;
    wire              [DIN_WD     -1:0]     enc_dec_din                     ;
    wire                                    fifo_full                       ;
    wire              [DOUT_WD    -1:0]     fifo_dout                       ;
    wire                                    fifo_empty                      ;
    reg                                     fifo_rd_pre                     ;
    wire                                    fifo_rd                         ;
    wire              [FIFO_ADDR_WD :0]     fifo_rd_cnt                     ;
    reg               [4            :0]     tlast_cnt                       ;
    wire              [15:0]                enc_sop_clr_cnt                 ;
    wire              [15:0]                enc_eop_clr_cnt                 ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            last_flag      =      s_axis_tvalid && s_axis_tready && s_axis_tlast ;
    assign            fifo_wr        =      s_axis_tvalid && s_axis_tready && enc_send_en  && (~enc_first_drop);
    assign            fifo_din       =      s_axis_tdata                    ;
    assign            s_axis_tready  =      1'b1                            ;
    assign            enc_send_en_pos=     ~enc_send_en_d1 && enc_send_en   ;
    assign            enc_finish     =      enc_send_en_d1 && (~enc_send_en);

    //assign            fifo_rd        =      enc_vld                         ;
    assign            fifo_rd        =      fifo_rd_pre && (~fifo_empty)    ;
    assign            enc_vld        =      fifo_rd                         ;
    assign            enc_data       =      fifo_dout                       ;
    //assign            enc_vld        =     ~fifo_empty                      ;
    assign            enc_sop_eop_cnt      =     {enc_eop_cnt,enc_sop_cnt}          ;
    assign            enc_sop_eop_clr_cnt  =     {enc_eop_clr_cnt,enc_sop_clr_cnt}  ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge clk) begin
        fifo_wr_d1   <=  fifo_wr   ;
        fifo_din_d1  <=  fifo_din  ;
        fifo_wr_d2   <=  fifo_wr_d1   ;
        fifo_din_d2  <=  fifo_din_d1  ;
    end
    

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            s_axis_tdata_d1 <= {DATA_WD{1'b0}};
        else if(s_axis_tvalid && s_axis_tready)
            s_axis_tdata_d1 <= s_axis_tdata;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            enc_first_drop <= 1'b0;
        else if(last_flag)
            enc_first_drop <= 1'b1;
        else if(s_axis_tvalid && s_axis_tready)
            enc_first_drop <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            enc_send_en_d1 <= 1'b0;
        else  
            enc_send_en_d1 <= enc_send_en;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            enc_send_en <= 1'b0;
        end else if(last_flag)begin
            if(s_axis_tdata_d1[31:0] == 32'h55aa_0001 && (s_axis_tdata[31:0] == 32'h0000_0004))
                enc_send_en <= 1'b1;
            else if(s_axis_tdata_d1[31:0] == 32'h55aa_0001 && (s_axis_tdata[31:0] == 32'h0000_0005))
                enc_send_en <= 1'b0;
        end
    end



    aurora_enc_dec #(
        .DATA_WD                (DATA_WD               )        
    )u_aurora_enc_dec(                                          
        .clk                    (clk                   ),//(i)
        .rst_n                  (rst_n                 ),//(i)
        .cfg_rst                (cfg_rst               ),//(i)
                                                        
        .i_vld                  (fifo_wr_d2            ),//(i)
        .i_din                  (fifo_din_d2           ),//(i)
        .o_vld                  (enc_dec_vld           ),//(o)
        .o_din                  (enc_dec_din           ) //(o)
    );


    always @(posedge clk_100m or negedge clk_100m_rst_n) begin
        if(~clk_100m_rst_n)
            fifo_rd_pre <= 1'b0;
        else if(fifo_empty)
            fifo_rd_pre <= 1'b0;
        else if(fifo_rd_cnt >= 10'd256)
            fifo_rd_pre <= 1'b1;
    end

    //---------------------------------------------------------------------
    // cmip_async_fifo.
    //---------------------------------------------------------------------
    cmip_async_fifo #(
        .DPTH                   (FIFO_DEPTH            ),
        .DATA_WDTH              (DATA_WD               ),
        .FWFT                   (1                     )
    )u_cmip_async_fifo(
        .i_wr_clk               (clk                   ),
        .i_rd_clk               (clk_100m              ),
        .i_wr_rst_n             (~cfg_rst && rst_n     ),
        .i_rd_rst_n             (clk_100m_rst_n        ),
        .i_aful_th              (4                     ),
        .i_amty_th              (4                     ),
        .i_wr                   (enc_dec_vld && (~fifo_full) && enc_send_en),
        .i_din                  (enc_dec_din           ),
        .i_rd                   (fifo_rd               ),
        .o_dout                 (fifo_dout             ),
        .o_aful                 (fifo_full             ),
        .o_amty                 (                      ),
        .o_full                 (                      ),
        .o_empty                (fifo_empty            ),
        .o_wr_cnt               (                      ),
        .o_rd_cnt               (fifo_rd_cnt           )
    );


    function automatic [DOUT_WD -1:0] byte_adj(
        input          [DOUT_WD -1:0]     a   
    );begin:abc
        integer i;
        for(i=1;i<=RATE;i=i+1)begin
            byte_adj[i*DIN_WD  -1 -:DIN_WD ] = a[(RATE + 1 - i)*DIN_WD  -1 -: DIN_WD ];
        end
    end
    endfunction




    //---------------------------------------------------------------------
    // app_cnt.
    //---------------------------------------------------------------------
    cmip_app_cnt #(
        .width     (16                             )
    )u0_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (cfg_rst                        ),//(i)
        .vld       (enc_send_en_pos                ),//(i)
        .cnt       (enc_sop_clr_cnt                    ) //(o)
    );

    cmip_app_cnt #(
        .width     (16                             )
    )u1_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (cfg_rst                        ),//(i)
        .vld       (enc_finish                     ),//(i)
        .cnt       (enc_eop_clr_cnt                    ) //(o)
    );

    cmip_app_cnt #(
        .width     (16                             )
    )u2_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (enc_send_en_pos                ),//(i)
        .cnt       (enc_sop_cnt                    ) //(o)
    );

    cmip_app_cnt #(
        .width     (16                             )
    )u3_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (enc_finish                     ),//(i)
        .cnt       (enc_eop_cnt                    ) //(o)
    );



    cmip_app_cnt #(
        .width     (32                             )
    )u4_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (cfg_rst                        ),//(i)
        .vld       (fifo_wr_d2                     ),//(i)
        .cnt       (enc_vld_cnt                    ) //(o)
    );





endmodule





