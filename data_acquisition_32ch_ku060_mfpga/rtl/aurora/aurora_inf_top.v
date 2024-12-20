module aurora_inf_top #(
    parameter                               DATA_WD        =    128        ,
    parameter                               ADC_CNT_WD     =    11         ,
    parameter                               HEAD_WD        =    64         ,
    parameter                               CFG_WD         =    32         ,
    parameter                               SIM            =     0         
)(
    input                                   mmcm_locked                    ,//(i)
    input                                   init_clk                       ,//(i) 100M
    input                                   clk_32m                        ,//(i) 32M
    output                                  enc_vld                        ,//(o)
    output            [64         -1:0]     enc_data                       ,//(o)

    input                                   rst_n                          ,//(i) user_clk
    output                                  user_clk                       ,//(o)
    input                                   cfg_rst                        ,//(i)
    output                                  eds_fbc_clr_buff               ,//(o)
    input                                   ena_cpl                        ,//(i)
    input                                   adc_cpl                        ,//(i)
    input                                   cfg_cpl                        ,//(i)
    output                                  eds_cpl                        ,//(o)
    output                                  fbc_cpl                        ,//(o)
    input                                   fbc_cpl_en                     ,//(i)
    output                                  pop_end_pkt                    ,//(o)
    output                                  channel_up                     ,//(o)
    output                                  channel_up1                    ,//(o)
    input                                   adc_enable                     ,//(i)

    output                                  head_rd                        ,//(i) 
    input             [63:0]                head_din                       ,//(o) 
    output                                  adc_fifo_rd                    ,//(o)
    input             [DATA_WD    -1:0]     adc_fifo_din                   ,//(i)
    input                                   adc_fifo_empty                 ,//(i)
    input             [ADC_CNT_WD -1:0]     adc_fifo_data_cnt              ,//(i)

    input                                   gt_refclk1_p                   ,//(i)
    input                                   gt_refclk1_n                   ,//(i)
    input                                   gt_refclk2_p                   ,//(i)
    input                                   gt_refclk2_n                   ,//(i)
    input             [0:1]                 rxp                            ,//(i) 
    input             [0:1]                 rxn                            ,//(i) 
    output            [0:1]                 txp                            ,//(o) 
    output            [0:1]                 txn                            ,//(o)
    input                                   rxp1                           ,//(i)
    input                                   rxn1                           ,//(i)
    output                                  txp1                           ,//(o)
    output                                  txn1                           ,//(o)

    //debug signals
    output            [31:0]                adc_pkt_sop_eop_cnt            ,//(o)
    output            [31:0]                enc_sop_eop_cnt                ,//(o)
    output            [31:0]                enc_sop_eop_clr_cnt            ,//(o)
    output            [31:0]                enc_vld_cnt                    ,//(o)
    output            [31:0]                eds_fifo_full_cnt              ,//(o)
    output            [31:0]                eds_sop_eop_cnt                ,//(o)
    output            [31:0]                eds_sop_eop_clr_cnt            ,//(o)
    output            [31:0]                fbc_sop_eop_cnt                ,//(o)
    output            [31:0]                eds_vld_cnt                    ,//(o)
    output            [31:0]                last_pkt_cnt                   ,//(o)
    output            [31:0]                buff_clr_cnt                   ,//(o)
    input             [31:0]                aurora_cfg                     ,//(i)
    output            [31:0]                aurora_sts                     ,//(o)
    output            [31:0]                aurora_soft_err_cnt            ,//(o)

    output            [31:0]                tx_total_vld_cnt               ,//(o)
    output            [31:0]                tx_adc_chk_suc_cnt             ,//(o)
    output            [31:0]                tx_adc_chk_err_cnt             ,//(o)
    output            [31:0]                tx_enc_chk_suc_cnt             ,//(o)
    output            [31:0]                tx_enc_chk_err_cnt              //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    //localparam                              DATA_WD_HALF   =      DATA_WD / 2    ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    pma_init                       ; 
    wire                                    reset_pb                       ; 
    wire                                    link_reset_out                 ; 
    wire                                    gt_pll_lock                    ;
    wire                                    sys_reset_out                  ; 
    wire                                    mmcm_not_locked_out            ;
    wire                                    auro_soft_rst                  ;
    wire               [2:0]                loopback                       ;
    wire               [2:0]                loopback1                      ;
    wire                                    power_down                     ;
    wire                                    hard_err                       ;
    wire                                    soft_err                       ;
    wire                                    hard_err1                      ;
    wire                                    soft_err1                      ;
    wire                                    ch_sel                         ;
    reg                                     adc_en_d1                      ;
    reg                                     adc_en_d2                      ;
    reg                                     cfg_rst_d1                     ;
    reg                                     cfg_rst_d2                     ;
    reg                                     cfg_rst_d3                     ;
    reg                                     cfg_rst_d4                     ;
    wire                                    eds_clr_buff                   ;
    wire                                    fbc_clr_buff                   ;


(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg                [127:0]              s_axi_tx_tdata                 ;
                                        reg                [15:0]               s_axi_tx_tkeep                 ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg                                     s_axi_tx_tlast                 ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg                                     s_axi_tx_tvalid                ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                    s_axi_tx_tready                ;
    wire               [127:0]              m_axi_rx_tdata                 ;
    wire               [15:0]               m_axi_rx_tkeep                 ;
    wire                                    m_axi_rx_tlast                 ;
    wire                                    m_axi_rx_tvalid                ;
    wire               [63:0]               s_axi_tx1_tdata                ;
    wire               [7 :0]               s_axi_tx1_tkeep                ;
    wire                                    s_axi_tx1_tlast                ;
    wire                                    s_axi_tx1_tvalid               ;
    wire                                    s_axi_tx1_tready               ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire               [63:0]               m_axi_rx1_tdata                ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire               [7 :0]               m_axi_rx1_tkeep                ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                    m_axi_rx1_tlast                ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                    m_axi_rx1_tvalid               ;

    wire               [127:0]              adc_m_axis_tdata               ;
    wire               [15 :0]              adc_m_axis_tkeep               ;
    wire                                    adc_m_axis_tvalid              ;
    wire                                    adc_m_axis_tready              ;
    wire                                    adc_m_axis_tlast               ;
    wire               [127:0]              eds_m_axis_tdata               ;
    wire               [15 :0]              eds_m_axis_tkeep               ;
    wire                                    eds_m_axis_tvalid              ;
    wire                                    eds_m_axis_tready              ;
    wire                                    eds_m_axis_tlast               ;
    wire                                    eds_finish                     ; 
    wire                                    eds_send_en                    ;
    wire               [127:0]              pop_m_axis_tdata               ;
    wire               [15 :0]              pop_m_axis_tkeep               ;
    wire                                    pop_m_axis_tvalid              ;
    wire                                    pop_m_axis_tready              ;
    wire                                    pop_m_axis_tlast               ;
    wire                                    pop_en                         ;

    wire               [63 :0]              enc_m_axis_tdata               ;
    wire               [7  :0]              enc_m_axis_tkeep               ;
    wire                                    enc_m_axis_tvalid              ;
    wire                                    enc_m_axis_tready              ;
    wire                                    enc_m_axis_tlast               ;
    wire                                    enc_finish                     ; 
    wire                                    enc_send_en                    ; 

    wire               [15 :0]              enc_sop_cnt                    ;
    wire               [15 :0]              enc_eop_cnt                    ;
    wire               [15:0]               soft_err_cnt                   ;
    wire               [15:0]               soft_err_cnt1                  ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign             adc_m_axis_tready  =  (~pop_en  && adc_en_d2) ? s_axi_tx_tready    : 1'b0              ;
    assign             eds_m_axis_tready  =  (~pop_en  && adc_en_d2) ? 1'b0               : s_axi_tx_tready   ;
    assign             pop_m_axis_tready  =    pop_en                ? s_axi_tx_tready    : 1'b0              ;

    assign             aurora_sts         =   {32'd0,link_reset_out,sys_reset_out,hard_err1,hard_err,mmcm_not_locked_out,gt_pll_lock,channel_up1,channel_up};
    assign             loopback           =   aurora_cfg[3:0]             ;
    assign             loopback1          =   aurora_cfg[7:4]             ;
    assign             auro_soft_rst      =   aurora_cfg[31]              ;
    assign             power_down         =   aurora_cfg[30]              ;
    assign             aurora_soft_err_cnt=  {soft_err_cnt1,soft_err_cnt} ;
    assign             eds_fbc_clr_buff   =   eds_clr_buff || fbc_clr_buff;
// =================================================================================================
// RTL Body
// =================================================================================================
    always@(*)begin
        if(pop_en)begin
            s_axi_tx_tdata     =    pop_m_axis_tdata  ;
            s_axi_tx_tkeep     =    pop_m_axis_tkeep  ;
            s_axi_tx_tlast     =    pop_m_axis_tlast  ;
            s_axi_tx_tvalid    =    pop_m_axis_tvalid ;
        end else if(adc_en_d2)begin
            s_axi_tx_tdata     =    adc_m_axis_tdata  ;
            s_axi_tx_tkeep     =    adc_m_axis_tkeep  ;
            s_axi_tx_tlast     =    adc_m_axis_tlast  ;
            s_axi_tx_tvalid    =    adc_m_axis_tvalid ;
        end else if(~adc_en_d2) begin
            s_axi_tx_tdata     =    eds_m_axis_tdata  ;
            s_axi_tx_tkeep     =    eds_m_axis_tkeep  ;
            s_axi_tx_tlast     =    eds_m_axis_tlast  ;
            s_axi_tx_tvalid    =    eds_m_axis_tvalid ;
        end else begin
            s_axi_tx_tdata     =    adc_m_axis_tdata  ;
            s_axi_tx_tkeep     =    adc_m_axis_tkeep  ;
            s_axi_tx_tlast     =    adc_m_axis_tlast  ;
            s_axi_tx_tvalid    =    adc_m_axis_tvalid ;
        end
    end
   


    always@(posedge user_clk or negedge rst_n) begin
        if(~rst_n)begin
            adc_en_d1   <= 1'b0;
            adc_en_d2   <= 1'b0;
            cfg_rst_d1  <= 1'b0;
            cfg_rst_d2  <= 1'b0;
            cfg_rst_d3  <= 1'b0;
            cfg_rst_d4  <= 1'b0;
        end else begin
            //adc_en_d1   <= adc_enable && (~eds_send_en);
            adc_en_d1   <= ~eds_send_en;
            adc_en_d2   <= adc_en_d1   ;
            cfg_rst_d1  <= cfg_rst     ;
            cfg_rst_d2  <= cfg_rst_d1  ;
            cfg_rst_d3  <= cfg_rst_d2  ;
            cfg_rst_d4  <= cfg_rst_d3  ;
        end
    end


    aurora_6466b_powon_rst #(                                                          
        .TIMES                         (512                    ),
        .SIM_ENABLE                    (SIM                    )       
    )u_aurora_6466b_powon_rst( 
        .clk                           (init_clk               ),//(i)
        .rst_n                         (mmcm_locked            ),//(i)
        .soft_rst                      (auro_soft_rst          ),//(i)
        .pma_init                      (pma_init               ),//(o)
        .reset_pb                      (reset_pb               ) //(o)
    );                                                          

    aurora_64b66b_20g_ip_support u_aurora_64b66b_20g_ip_support( 
        .s_axi_tx_tdata                (s_axi_tx_tdata         ),//(i)
        .s_axi_tx_tkeep                (s_axi_tx_tkeep         ),//(i)
        .s_axi_tx_tlast                (s_axi_tx_tlast         ),//(i)
        .s_axi_tx_tvalid               (s_axi_tx_tvalid        ),//(i)
        .s_axi_tx_tready               (s_axi_tx_tready        ),//(o)
        .m_axi_rx_tdata                (m_axi_rx_tdata         ),//(o)
        .m_axi_rx_tkeep                (m_axi_rx_tkeep         ),//(o)
        .m_axi_rx_tlast                (m_axi_rx_tlast         ),//(o)
        .m_axi_rx_tvalid               (m_axi_rx_tvalid        ),//(o)
        .s_axi_tx1_tdata               (s_axi_tx1_tdata        ),//(i)
        .s_axi_tx1_tkeep               (s_axi_tx1_tkeep        ),//(i)
        .s_axi_tx1_tlast               (s_axi_tx1_tlast        ),//(i)
        .s_axi_tx1_tvalid              (s_axi_tx1_tvalid       ),//(i)
        .s_axi_tx1_tready              (s_axi_tx1_tready       ),//(o)
        .m_axi_rx1_tdata               (m_axi_rx1_tdata        ),//(o)
        .m_axi_rx1_tkeep               (m_axi_rx1_tkeep        ),//(o)
        .m_axi_rx1_tlast               (m_axi_rx1_tlast        ),//(o)
        .m_axi_rx1_tvalid              (m_axi_rx1_tvalid       ),//(o)
        .rxp                           (rxp                    ),//(i)
        .rxn                           (rxn                    ),//(i)
        .txp                           (txp                    ),//(o)
        .txn                           (txn                    ),//(o)
        .rxp1                          (rxp1                   ),//(i)
        .rxn1                          (rxn1                   ),//(i)
        .txp1                          (txp1                   ),//(o)
        .txn1                          (txn1                   ),//(o)
        .hard_err                      (hard_err               ),//(o)
        .soft_err                      (soft_err               ),//(o)
        .hard_err1                     (hard_err1              ),//(o)
        .soft_err1                     (soft_err1              ),//(o)
        .channel_up                    (channel_up             ),//(o)
        .channel_up1                   (channel_up1            ),//(o)
        .lane_up                       (                       ),//(o)
        .user_clk_out                  (user_clk               ),//(o)
        .sync_clk_out                  (                       ),//(o)
        .reset_pb                      (reset_pb               ),//(i)
        .gt_rxcdrovrden_in             (1'b0                   ),//(i)
        .power_down                    (1'b0                   ),//(i)
        .loopback                      (loopback               ),//(i)
        .loopback1                     (loopback1              ),//(i)
        .pma_init                      (pma_init               ),//(i)
        .gt0_drpdo                     (                       ),//(o)
        .gt0_drprdy                    (                       ),//(o)
        .gt1_drpdo                     (                       ),//(o)
        .gt1_drprdy                    (                       ),//(o)
        .gt0_drpaddr                   ('d0                    ),//(i)
        .gt0_drpdi                     ('d0                    ),//(i)
        .gt0_drpen                     ('d0                    ),//(i)
        .gt0_drpwe                     ('d0                    ),//(i)
        .gt1_drpaddr                   ('d0                    ),//(i)
        .gt1_drpdi                     ('d0                    ),//(i)
        .gt1_drpen                     ('d0                    ),//(i)
        .gt1_drpwe                     ('d0                    ),//(i)

        .init_clk                      (init_clk               ),//(i)
        .link_reset_out                (link_reset_out         ),//(o)
        .gt_pll_lock                   (gt_pll_lock            ),//(o)
        .sys_reset_out                 (sys_reset_out          ),//(o)
        .gt_refclk1_p                  (gt_refclk1_p           ),//(i)
        .gt_refclk1_n                  (gt_refclk1_n           ),//(i)
        //.gt_refclk2_p                  (gt_refclk2_p           ),//(i)
        //.gt_refclk2_n                  (gt_refclk2_n           ),//(i)
        .mmcm_not_locked_out           (mmcm_not_locked_out    ),//(o)
        .tx_out_clk                    (                       ) //(o)
    );                                                           

    //---------------------------------------------------------------------
    // aurora_adc_send_imp.
    //---------------------------------------------------------------------
    aurora_adc_send #(                                                 
        .DATA_WD                       (DATA_WD                ),
        .ADC_CNT_WD                    (ADC_CNT_WD             ), 
        .HEAD_WD                       (HEAD_WD                ),
        .CFG_WD                        (CFG_WD                 ) 
    )u_aurora_adc_send(                                         
        .clk                           (user_clk               ),//(i)
        .rst_n                         (rst_n                  ),//(i)
        .cfg_rst                       (cfg_rst_d4             ),//(i)
        .adc_fifo_rd                   (adc_fifo_rd            ),//(o)
        .adc_fifo_din                  (adc_fifo_din           ),//(i)
        .adc_fifo_empty                (adc_fifo_empty         ),//(i)
        .adc_fifo_data_cnt             (adc_fifo_data_cnt      ),//(i)
        //.head_rd                       (head_rd                ),//(o)
        //.head_din                      ({head_cnt,head_din[47:0]}),//(i)
        .head_rd                       (head_rd                ),//(o)
        .head_din                      (head_din               ),//(i)
        .m_axis_tdata                  (adc_m_axis_tdata       ),//(o)
        .m_axis_tkeep                  (adc_m_axis_tkeep       ),//(o)
        .m_axis_tvalid                 (adc_m_axis_tvalid      ),//(o)
        .m_axis_tready                 (adc_m_axis_tready      ),//(i)
        .m_axis_tlast                  (adc_m_axis_tlast       ),//(o)
        .m_axis_tuser                  (                       ),//(o)
        .pkt_sop_eop_cnt               (adc_pkt_sop_eop_cnt    ),//(o)
        .pkt_sop_cnt                   (                       ),//(o)
        .pkt_eop_cnt                   (                       ) //(o)
    );        

    //---------------------------------------------------------------------
    // aurora_20g_chk_top Module Inst.
    //---------------------------------------------------------------------   
    aurora_20g_chk_top u0_aurora_20g_chk_top(                          
        .clk                           (user_clk                       ),//(i)
        .rst_n                         (rst_n                          ),//(i)
        .cfg_rst                       (cfg_rst_d4                     ),//(i)
        .s_axis_tdata                  (adc_m_axis_tdata               ),//(i)
        .s_axis_tkeep                  (adc_m_axis_tkeep               ),//(i)
        .s_axis_tvalid                 (adc_m_axis_tvalid && adc_m_axis_tready),//(i)
        .s_axis_tlast                  (adc_m_axis_tlast               ),//(i)
        .total_vld_cnt                 (tx_total_vld_cnt               ),//(o)
        .adc_chk_suc_cnt               (tx_adc_chk_suc_cnt             ),//(o)
        .adc_chk_err_cnt               (tx_adc_chk_err_cnt             ),//(o)
        .enc_chk_suc_cnt               (tx_enc_chk_suc_cnt             ),//(o)
        .enc_chk_err_cnt               (tx_enc_chk_err_cnt             ) //(o)
    );  

    //---------------------------------------------------------------------
    // aurora_eds_parser Module Inst.  
    //---------------------------------------------------------------------
    aurora_eds_fbc_parser #(                                                  
        .DATA_WD                       (64                     ),
        .DOUT_WD                       (128                    ),
        .FIFO_DEPTH                    (512                    )       
    )u_aurora_eds_fbc_parser( 
        .clk                           (user_clk               ),//(i)
        .rst_n                         (rst_n                  ),//(i)
        .cfg_rst                       (cfg_rst_d4             ),//(i)
        .s_axis_tdata                  (m_axi_rx1_tdata        ),//(i)
        .s_axis_tkeep                  (m_axi_rx1_tkeep        ),//(i)
        .s_axis_tvalid                 (m_axi_rx1_tvalid       ),//(i)
        .s_axis_tready                 (                       ),//(o)
        .s_axis_tlast                  (m_axi_rx1_tlast        ),//(i)
        .m_axis_tdata                  (eds_m_axis_tdata       ),//(o)
        .m_axis_tkeep                  (eds_m_axis_tkeep       ),//(o)
        .m_axis_tvalid                 (eds_m_axis_tvalid      ),//(o)
        .m_axis_tready                 (eds_m_axis_tready      ),//(i)
        .m_axis_tlast                  (eds_m_axis_tlast       ),//(o)
        .eds_send_en                   (eds_send_en            ),//(o)
        .eds_finish                    (eds_finish             ),//(o)
        .eds_cpl                       (eds_cpl                ),//(o)
        .fbc_cpl                       (fbc_cpl                ),//(o)
        .eds_fifo_full_cnt             (eds_fifo_full_cnt      ),//(o)
        .eds_sop_eop_cnt               (eds_sop_eop_cnt        ),//(o)
        .eds_sop_eop_clr_cnt           (eds_sop_eop_clr_cnt    ),//(o)
        .fbc_sop_eop_cnt               (fbc_sop_eop_cnt        ),//(o)
        .eds_vld_cnt                   (eds_vld_cnt            ) //(o)
    );                                                             

    cmip_pluse_delay #(                                    
        .TIMES                         (32'd15000000           ), //100ms
        .HOLD_CLK                      (40                     )  
    )u0_cmip_pluse_delay(      
        .i_clk                         (user_clk               ),//(i)
        .i_rst_n                       (rst_n                  ),//(i)
        .i_sig                         (eds_cpl                ),//(i)
        .o_pluse                       (eds_clr_buff           ) //(o)
    );                                                          
    
    cmip_pluse_delay #(                                    
        .TIMES                         (32'd300000000          ), //2s
        .HOLD_CLK                      (40                     )  
    )u1_cmip_pluse_delay(      
        .i_clk                         (user_clk               ),//(i)
        .i_rst_n                       (rst_n                  ),//(i)
        .i_sig                         (fbc_cpl && fbc_cpl_en  ),//(i)
        .o_pluse                       (fbc_clr_buff           ) //(o)
    );                                                          
    //---------------------------------------------------------------------
    // aurora_pop_clr Module Inst. Just For Test.
    //---------------------------------------------------------------------
    aurora_pop_clr #(                                                  
        .DATA_WD                       (128                    )     
    )u_aurora_pop_clr( 
        .clk                           (user_clk               ),//(i)
        .rst_n                         (rst_n                  ),//(i)
        .cfg_rst                       (cfg_rst_d4             ),//(i)
        .ena_cpl                       (ena_cpl                ),//(i)
        .eds_cpl                       (eds_finish             ),//(i)
        .adc_cpl                       (adc_cpl                ),//(i)
        .cfg_cpl                       (cfg_cpl                ),//(i)
        .pop_en                        (pop_en                 ),//(o)
        .pop_end_pkt                   (pop_end_pkt            ),//(o)
        .m_axis_tdata                  (pop_m_axis_tdata       ),//(o)
        .m_axis_tkeep                  (pop_m_axis_tkeep       ),//(o)
        .m_axis_tvalid                 (pop_m_axis_tvalid      ),//(o)
        .m_axis_tready                 (pop_m_axis_tready      ),//(i)
        .m_axis_tlast                  (pop_m_axis_tlast       ),//(o)
        .last_pkt_cnt                  (last_pkt_cnt           ),//(o)
        .buff_clr_cnt                  (buff_clr_cnt           ) //(o)
    );                                                         


    //---------------------------------------------------------------------
    // aurora_enc_parser Module Inst.  
    //---------------------------------------------------------------------
    aurora_enc_parser  u_aurora_enc_parser(                                             
        .clk                           (user_clk               ),//(i)
        .rst_n                         (rst_n                  ),//(i)
        .cfg_rst                       (cfg_rst_d4             ),//(i)
        .clk_100m                      (clk_32m                ),//(i)
        .clk_100m_rst_n                (mmcm_locked            ),//(i)

        .s_axis_tdata                  (m_axi_rx1_tdata        ),//(i)
        .s_axis_tkeep                  (m_axi_rx1_tkeep        ),//(i)
        .s_axis_tvalid                 (m_axi_rx1_tvalid       ),//(i)
        .s_axis_tready                 (                       ),//(o)
        .s_axis_tlast                  (m_axi_rx1_tlast        ),//(i)
        .enc_vld                       (enc_vld                ),//(o)
        .enc_data                      (enc_data               ),//(o)
        .enc_sop_eop_cnt               (enc_sop_eop_cnt        ),//(o)
        .enc_sop_eop_clr_cnt           (enc_sop_eop_clr_cnt    ),//(o)
        .enc_sop_cnt                   (enc_sop_cnt            ),//(o)
        .enc_eop_cnt                   (enc_eop_cnt            ),//(o)
        .enc_vld_cnt                   (enc_vld_cnt            ) //(o)
    );                                                                



    //---------------------------------------------------------------------
    // Debug Signals.  
    //---------------------------------------------------------------------
    cmip_app_cnt #(
        .width     (16                             )
    )u0_app_cnt(                                     
        .clk       (user_clk                       ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (soft_err                       ),//(i)
        .cnt       (soft_err_cnt                   ) //(o)
    );
    
    cmip_app_cnt #(
        .width     (16                             )
    )u1_app_cnt(                                     
        .clk       (user_clk                       ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (soft_err1                      ),//(i)
        .cnt       (soft_err_cnt1                  ) //(o)
    );




endmodule





