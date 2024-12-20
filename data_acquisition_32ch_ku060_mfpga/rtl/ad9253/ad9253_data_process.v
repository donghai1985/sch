module ad9253_data_process #(
    parameter                              DPTH              =      4096          ,
    parameter                              DATA_WDTH         =      512           ,
    parameter                              ADDR_WDTH         =      $clog2(DPTH)  
)(       
    input                                  sys_clk                                ,//(i) 32m 
    input                                  sys_rst_n                              ,//(i)
    input                                  enc_vld                                ,//(i)
    input             [63:0]               enc_din                                ,//(i)

    input             [15:0]               adc_1_data                             ,//(i)
    input             [15:0]               adc_2_data                             ,//(i)
    input             [15:0]               adc_3_data                             ,//(i)
    input             [15:0]               adc_4_data                             ,//(i)
    input             [15:0]               adc_5_data                             ,//(i)
    input             [15:0]               adc_6_data                             ,//(i)
    input             [15:0]               adc_7_data                             ,//(i)
    input             [15:0]               adc_8_data                             ,//(i)
    input             [15:0]               adc_9_data                             ,//(i)
    input             [15:0]               adc_10_data                            ,//(i)
    input             [15:0]               adc_11_data                            ,//(i)
    input             [15:0]               adc_12_data                            ,//(i)
    input             [15:0]               adc_13_data                            ,//(i)
    input             [15:0]               adc_14_data                            ,//(i)
    input             [15:0]               adc_15_data                            ,//(i)
    input             [15:0]               adc_16_data                            ,//(i)
    input             [15:0]               adc_17_data                            ,//(i)
    input             [15:0]               adc_18_data                            ,//(i)
    input             [15:0]               adc_19_data                            ,//(i)
    input             [15:0]               adc_20_data                            ,//(i)
    input             [15:0]               adc_21_data                            ,//(i)
    input             [15:0]               adc_22_data                            ,//(i)
    input             [15:0]               adc_23_data                            ,//(i)
    input             [15:0]               adc_24_data                            ,//(i)
    input             [15:0]               adc_25_data                            ,//(i)
    input             [15:0]               adc_26_data                            ,//(i)
    input             [15:0]               adc_27_data                            ,//(i)
    input             [15:0]               adc_28_data                            ,//(i)
    input             [15:0]               adc_29_data                            ,//(i)
    input             [15:0]               adc_30_data                            ,//(i)
    input             [15:0]               adc_31_data                            ,//(i)
    input             [15:0]               adc_32_data                            ,//(i)

    input             [9:0]                adc_rm_num                             ,//(i)
    input             [9:0]                enc_rm_num                             ,//(i)
    input                                  encode_local                           ,//(i)
    input                                  scan_local                             ,//(i)
    input                                  scan_start_flag                        ,//(i)
    input                                  scan_test_flag                         ,//(i)
    output                                 scan_cpl                               ,//(o)
    input                                  cfg_rst                                ,//(i)
    output                                 adc_clr_buff                           ,//(o)
    output                                 adc_data_vld                           ,//(o)
    output            [DATA_WDTH-1:0]      adc_data                               ,//(o)
    output            [63:0]               enc_data                               ,//(o)
    output            [31 :0]              adc_fifo_full_cnt                      ,//(o)
    output            [17:0]               xenc_1st                               ,//(o)
    output            [17:0]               wenc_1st                               ,//(o)
    output            [31:0]               jp_pos_1st                             ,//(o)
    output            [31:0]               jp_num                                  //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //--------------------------------------------------------------------------       
    // Defination of Internal Signals       
    //--------------------------------------------------------------------------       
    wire                                   encode_local_sync                      ; 
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   scan_local_sync                        ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   scan_start_flag_sync                   ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   scan_test_flag_sync                    ;
    wire                                   cfg_rst_n_sync                         ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   wr_en                                  ;
    wire                                   wr_en_neg                              ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   fifo_wr                                ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire              [DATA_WDTH-1:0]      fifo_din                               ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   fifo_full                              ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   fifo_empty                             ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   enc_fifo_wr                            ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire              [63:0]               enc_fifo_din                           ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   enc_fifo_full                          ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                   enc_fifo_empty                         ;

    reg               [15:0]               enc_test_data                          ;
    reg               [15:0]               adc_test_data0                         ;
    wire              [15:0]               adc_test_data1                         ;
    wire              [15:0]               adc_test_data2                         ;
    wire              [15:0]               adc_test_data3                         ;
    wire              [63:0]               adc_test_data                          ;
    wire              [63:0]               adc_1_4_data                           ;
    wire              [63:0]               adc_5_8_data                           ;
    wire              [63:0]               adc_9_12_data                          ;
    wire              [63:0]               adc_13_16_data                         ;
    wire              [63:0]               adc_17_20_data                         ;
    wire              [63:0]               adc_21_24_data                         ;
    wire              [63:0]               adc_25_28_data                         ;
    wire              [63:0]               adc_29_32_data                         ;
    wire              [17:0]               wenc                                   ;
    wire              [17:0]               xenc                                   ;
    wire                                   acc_flag                               ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            fifo_wr        =     wr_en                                  ;
    assign            adc_data_vld   =    (~fifo_empty) && (~enc_fifo_empty)      ;
    assign            adc_test_data1 =     adc_test_data0 + 2'd1                  ;
    assign            adc_test_data2 =     adc_test_data0 + 2'd2                  ;
    assign            adc_test_data3 =     adc_test_data0 + 2'd3                  ;
    assign            adc_test_data  =    {adc_test_data3,adc_test_data2,adc_test_data1,adc_test_data0};
    assign            adc_1_4_data   =    {adc_4_data,adc_3_data,adc_2_data,adc_1_data};
    assign            adc_5_8_data   =    {adc_8_data,adc_7_data,adc_6_data,adc_5_data};
    assign            adc_9_12_data  =    {adc_12_data,adc_11_data,adc_10_data,adc_9_data};
    assign            adc_13_16_data =    {adc_16_data,adc_15_data,adc_14_data,adc_13_data};
    assign            adc_17_20_data =    {adc_20_data,adc_19_data,adc_18_data,adc_17_data};
    assign            adc_21_24_data =    {adc_24_data,adc_23_data,adc_22_data,adc_21_data};
    assign            adc_25_28_data =    {adc_28_data,adc_27_data,adc_26_data,adc_25_data};
    assign            adc_29_32_data =    {adc_32_data,adc_31_data,adc_30_data,adc_29_data};
//  assign            wr_en          =     scan_start_flag_sync || scan_test_flag_sync || scan_local_sync ;
    assign            wr_en          =     scan_start_flag_sync || scan_local_sync ;
    assign            fifo_din       =     scan_local_sync ? {8{adc_test_data}}     : 
                                          {adc_29_32_data,adc_25_28_data,adc_21_24_data,adc_17_20_data,
                                           adc_13_16_data,adc_9_12_data,adc_5_8_data,adc_1_4_data};

    assign            xenc           =     enc_din[17:0]                                          ;
    assign            wenc           =     enc_din[49:32]                                         ;
    assign            acc_flag       =     enc_din[58]                                            ;
    assign            enc_fifo_wr    =     encode_local_sync ? wr_en : (scan_local_sync || enc_vld);
    assign            enc_fifo_din   =    (encode_local_sync ||scan_local_sync) ? {12'b0,2'b0,enc_test_data,2'b0,enc_test_data,enc_test_data} : 
                                                             {acc_flag,11'b0,wenc,xenc,enc_test_data}      ;
// =================================================================================================
// RTL Body
// =================================================================================================

    cmip_bit_sync #(                                    
        .DATA_WDTH               (1                    ) 
    )u0_cmip_bit_sync( 
        .i_dst_clk               (sys_clk              ),//(i)
        .i_din                   (scan_local           ),//(i)
        .o_dout                  (scan_local_sync      ) //(o)
    );                                                 

    cmip_bit_sync #(                                    
        .DATA_WDTH               (1                    ) 
    )u1_cmip_bit_sync( 
        .i_dst_clk               (sys_clk              ),//(i)
        .i_din                   (scan_start_flag      ),//(i)
        .o_dout                  (scan_start_flag_sync ) //(o)
    );                                                 

    cmip_bit_sync #(                                    
        .DATA_WDTH               (1                    ) 
    )u2_cmip_bit_sync( 
        .i_dst_clk               (sys_clk              ),//(i)
        .i_din                   (scan_test_flag       ),//(i)
        .o_dout                  (scan_test_flag_sync  ) //(o)
    );                                                 

    cmip_bit_sync #(                                    
        .DATA_WDTH               (1                    ) 
    )u3_cmip_bit_sync( 
        .i_dst_clk               (sys_clk              ),//(i)
        .i_din                   (encode_local         ),//(i)
        .o_dout                  (encode_local_sync    ) //(o)
    );                                                 

//  cmip_arst_sync #(                                          
//      .PIPE_NUM                (4                    )       
//  )u_cmip_arst_sync( 
//      .i_dst_clk               (sys_clk              ),//(i)
//      .i_src_rst_n             (~cfg_rst             ),//(i)
//      .o_dst_rst_n             (cfg_rst_n_sync       ) //(o)
//  );                                                   

    cmip_bit_sync_imp #(                                    
        .DATA_WDTH               (1                    ),
        .BUS_DELAY               (3                    )
    )u_cmip_bit_sync( 
        .i_dst_clk               (sys_clk              ),//(i)
        .i_din                   (~cfg_rst             ),//(i)
        .o_dout                  (cfg_rst_n_sync       ) //(o)
    );                                                 


    // -------------------------------------------------------------------------
    // rm_head_tap  Module Inst.
    // -------------------------------------------------------------------------
    wire                          fifo_wr_head          ;
    wire                          enc_fifo_wr_head      ;

    rm_head_tap u0_rm_head_tap( 
        .clk                     (sys_clk              ),//(i)
        .rst_n                   (sys_rst_n            ),//(i)
        .cfg_rst                 (~cfg_rst_n_sync      ),//(i)
        .num                     (adc_rm_num           ),//(i)
        .ivld                    (fifo_wr              ),//(i)
        .ovld                    (fifo_wr_head         ) //(o)
    );                                                 

    rm_head_tap u1_rm_head_tap( 
        .clk                     (sys_clk              ),//(i)
        .rst_n                   (sys_rst_n            ),//(i)
        .cfg_rst                 (~cfg_rst_n_sync      ),//(i)
        .num                     (enc_rm_num           ),//(i)
        .ivld                    (enc_fifo_wr          ),//(i)
        .ovld                    (enc_fifo_wr_head     ) //(o)
    );                                                 
    
    // -------------------------------------------------------------------------
    // cmip_sync_reg_fifo  Module Inst.
    // -------------------------------------------------------------------------
    cmip_sync_fifo #(                                          
        //.DPTH                    (8192                 ),
        .DPTH                    (32768                ),
        .DATA_WDTH               (512                  ),
        .FWFT                    (1                    )       
    )u_sync_fifo_data(     
        .i_clk                   (sys_clk              ),//(i)
        .i_rst_n                 (sys_rst_n && cfg_rst_n_sync),//(i)
        .i_aful_th               (5                    ),//(i)
        .i_amty_th               (5                    ),//(i)
        .i_wr                    (fifo_wr_head        ),//(i)
        .i_din                   (fifo_din             ),//(i)
        .i_rd                    (adc_data_vld         ),//(i)
        .o_dout                  (adc_data             ),//(o)
        .o_aful                  (fifo_full            ),//(o)
        .o_amty                  (                     ),//(o)
        .o_full                  (                     ),//(o)
        .o_empty                 (fifo_empty           ),//(o)
        .o_used_cnt              (                     ) //(o)
    );                                                       


    cmip_sync_fifo #(                                          
        .DPTH                    (32768                ),
        .DATA_WDTH               (64                   ),
        .FWFT                    (1                    )       
    )u_sync_fifo_enc(     
        .i_clk                   (sys_clk              ),//(i)
        .i_rst_n                 (sys_rst_n && cfg_rst_n_sync),//(i)
        .i_aful_th               (5                    ),//(i)
        .i_amty_th               (5                    ),//(i)
        .i_wr                    (enc_fifo_wr_head     ),//(i)
        .i_din                   (enc_fifo_din         ),//(i)
        .i_rd                    (adc_data_vld         ),//(i)
        .o_dout                  (enc_data             ),//(o)
        .o_aful                  (enc_fifo_full        ),//(o)
        .o_amty                  (                     ),//(o)
        .o_full                  (                     ),//(o)
        .o_empty                 (enc_fifo_empty       ),//(o)
        .o_used_cnt              (                     ) //(o)
    );                                                       

    //-----------ctrl logic--------------------------------------------------------------------//
    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(~sys_rst_n)
            adc_test_data0 <= 16'b0;
        else if(~cfg_rst_n_sync)
            adc_test_data0 <= 16'b0;
        else if(wr_en)
            adc_test_data0 <= adc_test_data0 + 3'd4;
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(~sys_rst_n)
            enc_test_data <= 16'b0;
        else if(~cfg_rst_n_sync)
            enc_test_data <= 16'b0;
        else if(enc_fifo_wr_head)
            enc_test_data <= enc_test_data + 1'b1;
    end

    // -------------------------------------------------------------------------
    // cmip_app_cnt  Module Inst.
    // -------------------------------------------------------------------------
    wire   [15:0]  w_adc_fifo_full_cnt;
    wire   [15:0]  w_enc_fifo_full_cnt;

    cmip_app_cnt #(
        .width     (16                           )
    )u0_app_cnt(                                   
        .clk       (sys_clk                      ),//(i)
        .rst_n     (sys_rst_n                    ),//(i)
        .clr       (~cfg_rst_n_sync              ),//(i)
        .vld       (fifo_full                    ),//(i)
        .cnt       (w_adc_fifo_full_cnt          ) //(o)
    );

    cmip_app_cnt #(
        .width     (16                           )
    )u1_app_cnt(                                   
        .clk       (sys_clk                      ),//(i)
        .rst_n     (sys_rst_n                    ),//(i)
        .clr       (~cfg_rst_n_sync              ),//(i)
        .vld       (enc_fifo_full                ),//(i)
        .cnt       (w_enc_fifo_full_cnt          ) //(o)
    );

    assign            adc_fifo_full_cnt = {w_adc_fifo_full_cnt,w_enc_fifo_full_cnt};




    cmip_edge_sync #(                                    
        .RISE          (0                        ),
        .PIPELINE      (2                        )       
    )u1_cmip_edge_sync(
        .i_clk         (sys_clk                  ),//(i)
        .i_rst_n       (sys_rst_n                ),//(i)
        .i_sig         (wr_en                    ),//(i)
        .o_edge        (wr_en_neg                ) //(o)
    );                                                 

    cmip_pluse_delay #(                                    
        //.TIMES         (32'd3200000              ), //100ms
        //.TIMES         (32'd1600000              ), //50ms
        .TIMES         (32'd1440000              ), //45ms
        .HOLD_CLK      (10                       )  
    )u0_cmip_pluse_delay(      
        .i_clk         (sys_clk                  ),//(i)
        .i_rst_n       (sys_rst_n                ),//(i)
        .i_sig         (wr_en_neg                ),//(i)
        .o_pluse       (adc_clr_buff             ) //(o)
    );                                           

    cmip_pluse_delay #(                                    
        .TIMES         (8'd255                   ), 
        .HOLD_CLK      (10                       )  
    )u1_cmip_pluse_delay(      
        .i_clk         (sys_clk                  ),//(i)
        .i_rst_n       (sys_rst_n                ),//(i)
        .i_sig         (wr_en_neg                ),//(i)
        .o_pluse       (scan_cpl                 ) //(o)
    );                                           



    // -------------------------------------------------------------------------
    // xwenc_chk  Module Inst.
    // -------------------------------------------------------------------------
    xwenc_chk  u_xwenc_chk(       
        .sys_clk       (sys_clk                  ),//(i)
        .sys_rst_n     (sys_rst_n                ),//(i)
        .cfg_rst       (~cfg_rst_n_sync          ),//(i)
        .enc_vld       (enc_vld                  ),//(i)
        .xenc_din      (xenc                     ),//(i)
        .wenc_din      (wenc                     ),//(i)
                                                 
        .xenc_1st      (xenc_1st                 ),//(o)
        .wenc_1st      (wenc_1st                 ),//(o)
        .jp_pos_1st    (jp_pos_1st               ),//(o)
        .jp_num        (jp_num                   ) //(o)
    );




endmodule





















































