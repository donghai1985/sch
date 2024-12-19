//`define SIM

module pcie_ddr_top #(
    parameter                               TEST           =  16           ,
    parameter                               SIM            =   0              
)(
    input                                   sys_clk_p                      ,//(i)
    input                                   sys_clk_n                      ,//(i)
    input                                   sys_rst_n                      ,//(i)
//    input                                   user_rst_n                     ,//(i)

    input             [7:0]                 pcie_mgt_rxn                   ,//(i)
    input             [7:0]                 pcie_mgt_rxp                   ,//(i)
    output            [7:0]                 pcie_mgt_txn                   ,//(o)
    output            [7:0]                 pcie_mgt_txp                   ,//(o)
    input                                   pcie_ref_clk_n                 ,//(i)  
    input                                   pcie_ref_clk_p                 ,//(i)  
    input                                   pcie_rst_n                     ,//(i)
    output            [3:0]                 led                            ,//(o) 
    //output                                  init_calib_cpl                 ,//(o) 
    //output                                  lnk_up_led                     ,//(o) 

    input                                   gt_refclk1_p                   ,//(i)
    input                                   gt_refclk1_n                   ,//(i)    
    input             [1:0]                 c0_rxp                         ,//(i)
    input             [1:0]                 c0_rxn                         ,//(i)
    output            [1:0]                 c0_txp                         ,//(o)
    output            [1:0]                 c0_txn                         ,//(o)
    output            [3:0]                 sfp_tx_disable                 ,//(o)

    // flash interface
    inout             [16-1:4]              FLASH_DATA                     ,//(i)
    output            [27-1:0]              FLASH_ADDR                     ,//(o)
    output                                  FLASH_WE_B                     ,//(o)
    output                                  FLASH_ADV_B                    ,//(o)
    output                                  FLASH_OE_B                     ,//(o)
    input                                   FLASH_WAIT                     ,//(i)

    //ddr4 inf   
    input                                   ddr_sys_clk_p                  ,//(i)   
    input                                   ddr_sys_clk_n                  ,//(i) 
    output                                  ddr4_act                       ,//(i)
    output            [16:0]                ddr4_a                         ,//(o)
    output            [1:0]                 ddr4_ba                        ,//(o)
    output                                  ddr4_bg                        ,//(o)
    output                                  ddr4_ck_n                      ,//(o)
    output                                  ddr4_ck_p                      ,//(o)
    output                                  ddr4_cke                       ,//(o)
    output                                  ddr4_cs                        ,//(o)
    inout             [7:0]                 ddr4_dm                        ,//(i)
    inout             [63:0]                ddr4_d                         ,//(i)
    inout             [7:0]                 ddr4_dqs_n                     ,//(i) 
    inout             [7:0]                 ddr4_dqs_p                     ,//(i) 
    output                                  ddr4_odt                       ,//(o)
    output                                  ddr4_reset                      //(o)  
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    parameter                           AXI_DATA_WD         = 256          ;
    parameter                           AXI_ADDR_WD         =  64          ;
    parameter                           DDR_DATA_WD         = 512          ;
    parameter                           DDR_ADDR_WD         =  32          ;
    parameter                           MAX_BLK_SIZE        = 32'h04000000 ;//(4GB / 64)
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire        [AXI_ADDR_WD-1:0]       m00_axi_araddr                          ;
    wire        [1:0]                   m00_axi_arburst                         ;
    wire        [3:0]                   m00_axi_arcache                         ;
    wire        [3:0]                   m00_axi_arid                            ;
    wire        [7:0]                   m00_axi_arlen                           ;
    wire                                m00_axi_arlock                          ;
    wire        [2:0]                   m00_axi_arprot                          ;
    wire                                m00_axi_arready                         ;
    wire        [2:0]                   m00_axi_arsize                          ;
    wire                                m00_axi_arvalid                         ;
    wire        [AXI_ADDR_WD-1:0]       m00_axi_awaddr                          ;
    wire        [1:0]                   m00_axi_awburst                         ;
    wire        [3:0]                   m00_axi_awcache                         ;
    wire        [3:0]                   m00_axi_awid                            ;
    wire        [7:0]                   m00_axi_awlen                           ;
    wire                                m00_axi_awlock                          ;
    wire        [2:0]                   m00_axi_awprot                          ;
    wire                                m00_axi_awready                         ;
    wire        [2:0]                   m00_axi_awsize                          ;
    wire                                m00_axi_awvalid                         ;
    wire        [3:0]                   m00_axi_bid                             ;
    wire                                m00_axi_bready                          ;
    wire        [1:0]                   m00_axi_bresp                           ;
    wire                                m00_axi_bvalid                          ;
    wire        [AXI_DATA_WD-1:0]       m00_axi_rdata                           ;
    wire        [3:0]                   m00_axi_rid                             ;
    wire                                m00_axi_rlast                           ;
    wire                                m00_axi_rready                          ;
    wire        [1:0]                   m00_axi_rresp                           ;
    wire                                m00_axi_rvalid                          ;
    wire        [AXI_DATA_WD-1:0]       m00_axi_wdata                           ;
    wire                                m00_axi_wlast                           ;
    wire                                m00_axi_wready                          ;
    wire        [AXI_DATA_WD/8 -1:0]    m00_axi_wstrb                           ;
    wire                                m00_axi_wvalid                          ;

    wire        [31:0]                  m00_axil_araddr                         ;
    wire        [2:0]                   m00_axil_arprot                         ;
    wire        [0:0]                   m00_axil_arready                        ;
    wire        [0:0]                   m00_axil_arvalid                        ;
    wire        [31:0]                  m00_axil_awaddr                         ;
    wire        [2:0]                   m00_axil_awprot                         ;
    wire        [0:0]                   m00_axil_awready                        ;
    wire        [0:0]                   m00_axil_awvalid                        ;
    wire        [0:0]                   m00_axil_bready                         ;
    wire        [1:0]                   m00_axil_bresp                          ;
    wire        [0:0]                   m00_axil_bvalid                         ;
    wire        [31:0]                  m00_axil_rdata                          ;
    wire        [0:0]                   m00_axil_rready                         ;
    wire        [1:0]                   m00_axil_rresp                          ;
    wire        [0:0]                   m00_axil_rvalid                         ;
    wire        [31:0]                  m00_axil_wdata                          ;
    wire        [0:0]                   m00_axil_wready                         ;
    wire        [3:0]                   m00_axil_wstrb                          ;
    wire        [0:0]                   m00_axil_wvalid                         ;
    
    wire        [31:0]                  m01_axil_araddr                         ;
    wire        [2:0]                   m01_axil_arprot                         ;
    wire        [0:0]                   m01_axil_arready                        ;
    wire        [0:0]                   m01_axil_arvalid                        ;
    wire        [31:0]                  m01_axil_awaddr                         ;
    wire        [2:0]                   m01_axil_awprot                         ;
    wire        [0:0]                   m01_axil_awready                        ;
    wire        [0:0]                   m01_axil_awvalid                        ;
    wire        [0:0]                   m01_axil_bready                         ;
    wire        [1:0]                   m01_axil_bresp                          ;
    wire        [0:0]                   m01_axil_bvalid                         ;
    wire        [31:0]                  m01_axil_rdata                          ;
    wire        [0:0]                   m01_axil_rready                         ;
    wire        [1:0]                   m01_axil_rresp                          ;
    wire        [0:0]                   m01_axil_rvalid                         ;
    wire        [31:0]                  m01_axil_wdata                          ;
    wire        [0:0]                   m01_axil_wready                         ;
    wire        [3:0]                   m01_axil_wstrb                          ;
    wire        [0:0]                   m01_axil_wvalid                         ;

    wire                                clk_125m                                ;
    wire                                clk_100m                                ;
    wire                                clk_500m                                ;
    wire                                mmcm_locked                             ;
    wire                                aclk                                    ;
    wire                                aresetn                                 ;
    wire                                init_calib_cpl                          ;
    wire                                lnk_up_led                              ;
    wire                                usr_irq_req                             ;
    wire        [1:0]                   usr_irq_ack                             ;
    wire        [31:0]                  o_reg0                                  ;    
    wire                                cfg_rst                                 ;
    wire                                aurora_soft_rst                         ;

    // ------------------------Aurora-------------------------------------------//
    wire                                init_clk                               ;
    wire                                c0_user_clk                            ;
    wire                                c1_user_clk                            ;
    wire                                c0_hard_err                            ;//(o)
    wire                                c0_soft_err                            ;//(o)
    wire        [1:0]                   c0_lane_up                             ;//(o)
    wire                                c1_channel_up                          ;
    wire                                power_down                             ;//(i)
    wire        [7:0]                   loopback                               ;//(i)
    wire                                c0_gt_pll_lock                         ;//(i)
    wire                                c0_gt_qpllclk_quad1                    ;//(i)
    wire                                c0_gt_qpllrefclk_quad1                 ;//(i)
    wire                                c0_gt_to_common_qpllreset              ;//(i)
    wire                                c0_gt_qplllock                         ;//(i)
    wire                                c0_gt_qpllrefclklost                   ;//(i)
    wire                                c0_link_reset_out                      ;//(o)
    wire                                c0_sys_reset_out                       ;//(o)
    wire        [31:0]                  aurora_soft_rst_cnt                    ;
    wire        [31:0]                  aurora_soft_err_cnt                    ;
    wire                                pkt_end_flag                           ;
    wire                                adc_end_flag                           ;
    wire        [ 31:0]                 dbg_cnt_arr                            ;

    wire        [127:0]                 c0_s_axi_tx_tdata                      ;
    wire        [15 :0]                 c0_s_axi_tx_tkeep                      ;
    wire                                c0_s_axi_tx_tvalid                     ;
    wire                                c0_s_axi_tx_tlast                      ;
    wire                                c0_s_axi_tx_tready                     ;
    wire        [127:0]                 c0_m_axi_rx_tdata                      ;
    wire        [15 :0]                 c0_m_axi_rx_tkeep                      ;
    wire                                c0_m_axi_rx_tvalid                     ;
    wire                                c0_m_axi_rx_tlast                      ;
    wire        [31 :0]                 c1_s_axi_tx_tdata                      ;
    wire        [3  :0]                 c1_s_axi_tx_tkeep                      ;
    wire                                c1_s_axi_tx_tvalid                     ;
    wire                                c1_s_axi_tx_tlast                      ;
    wire                                c1_s_axi_tx_tready                     ;
    wire        [31 :0]                 c1_m_axi_rx_tdata                      ;
    wire        [3  :0]                 c1_m_axi_rx_tkeep                      ;
    wire                                c1_m_axi_rx_tvalid                     ;
    wire                                c1_m_axi_rx_tlast                      ;
    wire        [31 :0]                 c0_sts_vld_cnt                         ;
    wire        [31 :0]                 c1_sts_vld_cnt                         ;
    
    wire        [32        -1:0]        cfg_len                                ;
    wire        [32        -1:0]        cfg_mode                               ;
    wire        [32        -1:0]        cfg_trig                               ;
    wire        [32        -1:0]        cfg_times                              ;
    wire        [32        -1:0]        cfg_interval                           ;
    wire                                sts_idle                               ;

    wire                                ddr_clk                                ;//(i)
    wire                                ddr_rst_n                              ;//(i)
    wire                                ch0_wr_burst_req                       ;//(i)
    wire          [9:0]                 ch0_wr_burst_len                       ;//(i)
    wire          [DDR_ADDR_WD  -1:0]   ch0_wr_burst_addr                      ;//(i)
    wire                                ch0_wr_burst_data_req                  ;//(o)
    wire          [DDR_DATA_WD  -1:0]   ch0_wr_burst_data                      ;//(i)
    wire                                ch0_wr_burst_finish                    ;//(i)
    wire                                ch0_irq_en                             ;
    wire                                ch0_irq_clr                            ;
    wire                                ch1_wr_burst_req                       ;//(i)
    wire          [9:0]                 ch1_wr_burst_len                       ;//(i)
    wire          [DDR_ADDR_WD  -1:0]   ch1_wr_burst_addr                      ;//(i)
    wire                                ch1_wr_burst_data_req                  ;//(o)
    wire          [DDR_DATA_WD  -1:0]   ch1_wr_burst_data                      ;//(i)
    wire                                ch1_wr_burst_finish                    ;//(i)
    wire                                ch1_irq_en                             ;
    wire                                ch1_irq_clr                            ;
    wire          [31:0]                ch0_blk_cnt                            ;
    wire          [31:0]                ch1_blk_cnt                            ;
    wire          [31:0]                reg_test                               ;
    wire          [31:0]                cfg_irq_clr_cnt                        ;
    wire          [31:0]                ch0_fifo_full_cnt                      ; 
    wire          [31:0]                ch0_irq_trig_cnt                       ; 
    wire          [31:0]                ch1_fifo_full_cnt                      ;
    wire          [31:0]                ch0_tlast_cnt                          ;
    wire          [31:0]                ch1_tlast_cnt                          ;
    wire          [31:0]                adc_chk_suc_cnt                        ;
    wire          [31:0]                adc_chk_err_cnt                        ;
    wire          [31:0]                enc_chk_suc_cnt                        ;
    wire          [31:0]                enc_chk_err_cnt                        ;
    wire          [31:0]                dw_adc_chk_suc_cnt                     ;
    wire          [31:0]                dw_adc_chk_err_cnt                     ;
    wire          [31:0]                dw_enc_chk_suc_cnt                     ;
    wire          [31:0]                dw_enc_chk_err_cnt                     ; 
    wire          [31:0]                dr_adc_chk_suc_cnt                     ;
    wire          [31:0]                dr_adc_chk_err_cnt                     ;
    wire          [31:0]                dr_enc_chk_suc_cnt                     ;
    wire          [31:0]                dr_enc_chk_err_cnt                     ; 
 
    wire                                rd_8m_irq_en                           ;
    wire          [DDR_ADDR_WD  -1:0]   avail_addr                             ;
    wire          [31:0]                overflow_cnt                           ;
    wire          [DDR_ADDR_WD-1:0]     rd_blk_cnt                             ;
    wire          [DDR_ADDR_WD-1:0]     rd_blk_irq_cnt                         ;
    wire          [31:0]                axi_adc_chk_suc_cnt                    ;
    wire          [31:0]                axi_adc_chk_err_cnt                    ;
    wire          [31:0]                axi_enc_chk_suc_cnt                    ;
    wire          [31:0]                axi_enc_chk_err_cnt                    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign         cfg_rst  =      o_reg0[0] || aurora_soft_rst                ;
    assign         led      =      {~cfg_rst,~c0_channel_up,~init_calib_cpl,~lnk_up_led};

// =================================================================================================
// RTL Body
// =================================================================================================
    //---------------------------------------------------------------------
    // clk_wiz Module Inst.
    //---------------------------------------------------------------------     
    clk_wiz u_clk_wiz(
        .clk_out1                      (init_clk                         ),//50M 
        .clk_out2                      (clk_125m                         ),//156.25M 
        .reset                         ((~sys_rst_n)   || (~lnk_up_led)  ),   
        .locked                        (mmcm_locked                      ), 
        .clk_in1_p                     (sys_clk_p                        ),
        .clk_in1_n                     (sys_clk_n                        )
    );  

    //assign          mmcm_locked     = 1'b1;
    //---------------------------------------------------------------------
    // zynq_sim Module Inst.
    //---------------------------------------------------------------------   
generate if(SIM==1)begin
     zynq_sim u_zynq_sim( 
        .axil_clk                      (aclk                           ),//(o)
        .axil_rst_n                    (aresetn                        ),//(o)
     
        .m00_axil_araddr               (m01_axil_araddr                ),//(o)
    //  .m00_axil_arprot               (m01_axil_arprot                ),//(o)
        .m00_axil_arready              (m01_axil_arready               ),//(i)
        .m00_axil_arvalid              (m01_axil_arvalid               ),//(o)
        .m00_axil_awaddr               (m01_axil_awaddr                ),//(o)
    //  .m00_axil_awprot               (m01_axil_awprot                ),//(o)
        .m00_axil_awready              (m01_axil_awready               ),//(i)
        .m00_axil_awvalid              (m01_axil_awvalid               ),//(o)
        .m00_axil_bready               (m01_axil_bready                ),//(o)
        .m00_axil_bresp                (m01_axil_bresp                 ),//(i)
        .m00_axil_bvalid               (m01_axil_bvalid                ),//(i)
        .m00_axil_rdata                (m01_axil_rdata                 ),//(i)
        .m00_axil_rready               (m01_axil_rready                ),//(o)
        .m00_axil_rresp                (m01_axil_rresp                 ),//(i)
        .m00_axil_rvalid               (m01_axil_rvalid                ),//(i)
        .m00_axil_wdata                (m01_axil_wdata                 ),//(o)
        .m00_axil_wready               (m01_axil_wready                ),//(i)
        .m00_axil_wstrb                (m01_axil_wstrb                 ),//(o)
        .m00_axil_wvalid               (m01_axil_wvalid                ),//(o)

        .m01_axil_araddr               (mb_axilite1_araddr             ),//(o)
    //  .m01_axil_arprot               (mb_axilite1_arprot             ),//(o)
        .m01_axil_arready              (mb_axilite1_arready            ),//(i)
        .m01_axil_arvalid              (mb_axilite1_arvalid            ),//(o)
        .m01_axil_awaddr               (mb_axilite1_awaddr             ),//(o)
    //  .m01_axil_awprot               (mb_axilite1_awprot             ),//(o)
        .m01_axil_awready              (mb_axilite1_awready            ),//(i)
        .m01_axil_awvalid              (mb_axilite1_awvalid            ),//(o)
        .m01_axil_bready               (mb_axilite1_bready             ),//(o)
        .m01_axil_bresp                (mb_axilite1_bresp              ),//(i)
        .m01_axil_bvalid               (mb_axilite1_bvalid             ),//(i)
        .m01_axil_rdata                (mb_axilite1_rdata              ),//(i)
        .m01_axil_rready               (mb_axilite1_rready             ),//(o)
        .m01_axil_rresp                (mb_axilite1_rresp              ),//(i)
        .m01_axil_rvalid               (mb_axilite1_rvalid             ),//(i)
        .m01_axil_wdata                (mb_axilite1_wdata              ),//(o)
        .m01_axil_wready               (mb_axilite1_wready             ),//(i)
        .m01_axil_wstrb                (mb_axilite1_wstrb              ),//(o)
        .m01_axil_wvalid               (mb_axilite1_wvalid             ),//(o)

        .m_axi_clk                     (aclk                           ),
        .m_axi_rst_n                   (aresetn                        ),        
        .m_axi_awaddr                  (m00_axi_awaddr                 ),    
        .m_axi_awburst                 (m00_axi_awburst                ),    
        .m_axi_awcache                 (m00_axi_awcache                ),    
        .m_axi_awid                    (m00_axi_awid                   ),    
        .m_axi_awlen                   (m00_axi_awlen                  ),    
        .m_axi_awlock                  (m00_axi_awlock                 ),    
        .m_axi_awprot                  (m00_axi_awprot                 ),    
        .m_axi_awvalid                 (m00_axi_awvalid                ),    
        .m_axi_awready                 (m00_axi_awready                ),    
        .m_axi_awsize                  (m00_axi_awsize                 ),    
        .m_axi_bvalid                  (m00_axi_bvalid                 ),    
        .m_axi_bready                  (m00_axi_bready                 ),    
        .m_axi_bresp                   (m00_axi_bresp                  ),    
        .m_axi_bid                     (m00_axi_bid                    ),    
        .m_axi_wvalid                  (m00_axi_wvalid                 ),    
        .m_axi_wready                  (m00_axi_wready                 ),    
        .m_axi_wstrb                   (m00_axi_wstrb                  ),    
        .m_axi_wdata                   (m00_axi_wdata                  ),    
        .m_axi_wlast                   (m00_axi_wlast                  ),    
        .m_axi_araddr                  (m00_axi_araddr                 ),    
        .m_axi_arburst                 (m00_axi_arburst                ),    
        .m_axi_arcache                 (m00_axi_arcache                ),    
        .m_axi_arid                    (m00_axi_arid                   ),    
        .m_axi_arlen                   (m00_axi_arlen                  ),    
        .m_axi_arlock                  (m00_axi_arlock                 ),    
        .m_axi_arprot                  (m00_axi_arprot                 ),    
        .m_axi_arvalid                 (m00_axi_arvalid                ),    
        .m_axi_arready                 (m00_axi_arready                ),    
        .m_axi_arsize                  (m00_axi_arsize                 ),    
        .m_axi_rdata                   (m00_axi_rdata                  ),    
        .m_axi_rvalid                  (m00_axi_rvalid                 ),    
        .m_axi_rready                  (m00_axi_rready                 ),
        .m_axi_rlast                   (m00_axi_rlast                  ),
        .m_axi_rresp                   (m00_axi_rresp                  ),
        .m_axi_rid                     (m00_axi_rid                    ),

        .axi_clk                       (aclk                           ),//(i)
        .axi_rst_n                     (aresetn                        ),//(i)        
        .s00_axi_awaddr                (s01_axi_awaddr                 ),//(i)    
        .s00_axi_awburst               (s01_axi_awburst                ),//(i)    
        .s00_axi_awcache               (s01_axi_awcache                ),//(i)    
        .s00_axi_awid                  (s01_axi_awid                   ),//(i)    
        .s00_axi_awlen                 (s01_axi_awlen                  ),//(i)    
        .s00_axi_awlock                (s01_axi_awlock                 ),//(i)    
        .s00_axi_awprot                (s01_axi_awprot                 ),//(i)    
        .s00_axi_awvalid               (s01_axi_awvalid                ),//(i)    
        .s00_axi_awready               (s01_axi_awready                ),//(o)    
        .s00_axi_awsize                (s01_axi_awsize                 ),//(i)    
        .s00_axi_bvalid                (s01_axi_bvalid                 ),//(o)    
        .s00_axi_bready                (s01_axi_bready                 ),//(i)    
        .s00_axi_bresp                 (s01_axi_bresp                  ),//(o)    
        .s00_axi_bid                   (s01_axi_bid                    ),//(o)    
        .s00_axi_wvalid                (s01_axi_wvalid                 ),//(i)    
        .s00_axi_wready                (s01_axi_wready                 ),//(o)    
        .s00_axi_wstrb                 (s01_axi_wstrb                  ),//(i)    
        .s00_axi_wdata                 (s01_axi_wdata                  ),//(i)    
        .s00_axi_wlast                 (s01_axi_wlast                  ),//(i)    
        .s00_axi_araddr                (s01_axi_araddr                 ),//(i)    
        .s00_axi_arburst               (s01_axi_arburst                ),//(i)    
        .s00_axi_arcache               (s01_axi_arcache                ),//(i)    
        .s00_axi_arid                  (s01_axi_arid                   ),//(i)    
        .s00_axi_arlen                 (s01_axi_arlen                  ),//(i)    
        .s00_axi_arlock                (s01_axi_arlock                 ),//(i)    
        .s00_axi_arprot                (s01_axi_arprot                 ),//(i)    
        .s00_axi_arvalid               (s01_axi_arvalid                ),//(i)    
        .s00_axi_arready               (s01_axi_arready                ),//(o)    
        .s00_axi_arsize                (s01_axi_arsize                 ),//(i)    
        .s00_axi_rdata                 (s01_axi_rdata                  ),//(o)    
        .s00_axi_rvalid                (s01_axi_rvalid                 ),//(o)    
        .s00_axi_rready                (s01_axi_rready                 ),//(i)
        .s00_axi_rlast                 (s01_axi_rlast                  ),//(o)
        .s00_axi_rresp                 (s01_axi_rresp                  ),//(o)
        .s00_axi_rid                   (s01_axi_rid                    ),//(o)
                                                                           
        .clk_wiz_locked                (                               ),//(o)
        .pclk_x5                       (                               ),//(o)
        .pclk                          (                               ) //(o)
    );  

end else begin
    //---------------------------------------------------------------------
    // system_wrapper ModuleInst.
    //---------------------------------------------------------------------   
    system_wrapper u_system_wrapper( 
        .aclk                          (aclk                           ),//(o)
        .aresetn                       (aresetn                        ),//(o)
        .lnk_up_led                    (lnk_up_led                     ),//(o)
        .m00_axi_araddr                (m00_axi_araddr                 ),//(o)
        .m00_axi_arburst               (m00_axi_arburst                ),//(o)
        .m00_axi_arcache               (m00_axi_arcache                ),//(o)
        .m00_axi_arid                  (m00_axi_arid                   ),//(o)
        .m00_axi_arlen                 (m00_axi_arlen                  ),//(o)
        .m00_axi_arlock                (m00_axi_arlock                 ),//(o)
        .m00_axi_arprot                (m00_axi_arprot                 ),//(o)
        .m00_axi_arready               (m00_axi_arready                ),//(i)
        .m00_axi_arsize                (m00_axi_arsize                 ),//(o)
        .m00_axi_arvalid               (m00_axi_arvalid                ),//(o)
        .m00_axi_awaddr                (m00_axi_awaddr                 ),//(o)
        .m00_axi_awburst               (m00_axi_awburst                ),//(o)
        .m00_axi_awcache               (m00_axi_awcache                ),//(o)
        .m00_axi_awid                  (m00_axi_awid                   ),//(o)
        .m00_axi_awlen                 (m00_axi_awlen                  ),//(o)
        .m00_axi_awlock                (m00_axi_awlock                 ),//(o)
        .m00_axi_awprot                (m00_axi_awprot                 ),//(o)
        .m00_axi_awready               (1'b0                           ),//(i)
        .m00_axi_awsize                (m00_axi_awsize                 ),//(o)
        .m00_axi_awvalid               (m00_axi_awvalid                ),//(o)
        .m00_axi_bid                   (m00_axi_bid                    ),//(i)
        .m00_axi_bready                (m00_axi_bready                 ),//(o)
        .m00_axi_bresp                 (m00_axi_bresp                  ),//(i)
        .m00_axi_bvalid                (m00_axi_bvalid                 ),//(i)
        .m00_axi_rdata                 (m00_axi_rdata                  ),//(i)
        .m00_axi_rid                   (m00_axi_rid                    ),//(i)
        .m00_axi_rlast                 (m00_axi_rlast                  ),//(i)
        .m00_axi_rready                (m00_axi_rready                 ),//(o)
        .m00_axi_rresp                 (m00_axi_rresp                  ),//(i)
        .m00_axi_rvalid                (m00_axi_rvalid                 ),//(i)
        .m00_axi_wdata                 (m00_axi_wdata                  ),//(o)
        .m00_axi_wlast                 (m00_axi_wlast                  ),//(o)
        .m00_axi_wready                (1'b0                           ),//(i)
        .m00_axi_wstrb                 (m01_axi_wstrb                  ),//(o)
        .m00_axi_wvalid                (m01_axi_wvalid                 ),//(o)

        .m00_axil_araddr               (m00_axil_araddr                ),//(o)
        .m00_axil_arprot               (m00_axil_arprot                ),//(o)
        .m00_axil_arready              (m00_axil_arready               ),//(i)
        .m00_axil_arvalid              (m00_axil_arvalid               ),//(o)
        .m00_axil_awaddr               (m00_axil_awaddr                ),//(o)
        .m00_axil_awprot               (m00_axil_awprot                ),//(o)
        .m00_axil_awready              (m00_axil_awready               ),//(i)
        .m00_axil_awvalid              (m00_axil_awvalid               ),//(o)
        .m00_axil_bready               (m00_axil_bready                ),//(o)
        .m00_axil_bresp                (m00_axil_bresp                 ),//(i)
        .m00_axil_bvalid               (m00_axil_bvalid                ),//(i)
        .m00_axil_rdata                (m00_axil_rdata                 ),//(i)
        .m00_axil_rready               (m00_axil_rready                ),//(o)
        .m00_axil_rresp                (m00_axil_rresp                 ),//(i)
        .m00_axil_rvalid               (m00_axil_rvalid                ),//(i)
        .m00_axil_wdata                (m00_axil_wdata                 ),//(o)
        .m00_axil_wready               (m00_axil_wready                ),//(i)
        .m00_axil_wstrb                (m00_axil_wstrb                 ),//(o)
        .m00_axil_wvalid               (m00_axil_wvalid                ),//(o)

        .m01_axil_araddr               (m01_axil_araddr                ),//(o)
        .m01_axil_arprot               (m01_axil_arprot                ),//(o)
        .m01_axil_arready              (m01_axil_arready               ),//(i)
        .m01_axil_arvalid              (m01_axil_arvalid               ),//(o)
        .m01_axil_awaddr               (m01_axil_awaddr                ),//(o)
        .m01_axil_awprot               (m01_axil_awprot                ),//(o)
        .m01_axil_awready              (m01_axil_awready               ),//(i)
        .m01_axil_awvalid              (m01_axil_awvalid               ),//(o)
        .m01_axil_bready               (m01_axil_bready                ),//(o)
        .m01_axil_bresp                (m01_axil_bresp                 ),//(i)
        .m01_axil_bvalid               (m01_axil_bvalid                ),//(i)
        .m01_axil_rdata                (m01_axil_rdata                 ),//(i)
        .m01_axil_rready               (m01_axil_rready                ),//(o)
        .m01_axil_rresp                (m01_axil_rresp                 ),//(i)
        .m01_axil_rvalid               (m01_axil_rvalid                ),//(i)
        .m01_axil_wdata                (m01_axil_wdata                 ),//(o)
        .m01_axil_wready               (m01_axil_wready                ),//(i)
        .m01_axil_wstrb                (m01_axil_wstrb                 ),//(o)
        .m01_axil_wvalid               (m01_axil_wvalid                ),//(o)
        .pcie_mgt_rxn                  (pcie_mgt_rxn                   ),//(i)
        .pcie_mgt_rxp                  (pcie_mgt_rxp                   ),//(i)
        .pcie_mgt_txn                  (pcie_mgt_txn                   ),//(o)
        .pcie_mgt_txp                  (pcie_mgt_txp                   ),//(o)
        .pcie_ref_clk_n                (pcie_ref_clk_n                 ),//(i)
        .pcie_ref_clk_p                (pcie_ref_clk_p                 ),//(i)
        .pcie_rst_n                    (pcie_rst_n                     ),//(i)
        .usr_irq_ack                   (ch0_irq_clr                    ),//(o)
        .usr_irq_req                   (usr_irq_req                    ) //(i)
    );   
    //assign     usr_irq_req =  ch0_irq_en   || reg_test[0] ;   
    assign     usr_irq_req =  (rd_8m_irq_en || reg_test[0]) && (~reg_test[1]);                                                                  
end
endgenerate

    //---------------------------------------------------------------------
    // axi2ddr_top Module Inst.
    //---------------------------------------------------------------------   
    axi2ddr_top #(                                                           
        .FIFO_DPTH                      (512                            ),
        .AXI_DATA_WD                    (AXI_DATA_WD                    ),
        .AXI_ADDR_WD                    (AXI_ADDR_WD                    ),
        .DDR_DATA_WD                    (512                            ),
        .DDR_ADDR_WD                    (32                             ),
        .MAX_BLK_SIZE                   (MAX_BLK_SIZE                   ),
        .DGBCNT_EN                      (1                              ),
        .DGBCNT_WD                      (16                             )       
    )u_axi2ddr_top(                                                     
        .sys_clk_p                      (ddr_sys_clk_p                  ),//(i)
        .sys_clk_n                      (ddr_sys_clk_n                  ),//(i)
        .sys_rst_n                      (mmcm_locked                    ),//(i)
        .ddr_clk                        (ddr_clk                        ),//(i)pcie clk
        .ddr_rst_n                      (ddr_rst_n                      ),//(i)
        .axi_clk                        (aclk                           ),//(i)pcie clk
        .axi_rst_n                      (aresetn                        ),//(i)
        .cfg_rst                        (cfg_rst                        ),//(i)
        .s_axi_awaddr                   ('d0                            ),//(i)
        .s_axi_awburst                  ('d0                            ),//(i)
        .s_axi_awcache                  ('d0                            ),//(i)
        .s_axi_awid                     ('d0                            ),//(i)
        .s_axi_awlen                    ('d0                            ),//(i)
        .s_axi_awlock                   ('d0                            ),//(i)
        .s_axi_awprot                   ('d0                            ),//(i)
        .s_axi_awqos                    ('d0                            ),//(i)
        .s_axi_awvalid                  ('d0                            ),//(i)
        .s_axi_awready                  (                               ),//(o)
        .s_axi_awsize                   ('d0                            ),//(i)
        .s_axi_awuser                   ('d0                            ),//(i)
        .s_axi_bvalid                   (                               ),//(o)
        .s_axi_bready                   ('d0                            ),//(i)
        .s_axi_bresp                    (                               ),//(o)
        .s_axi_bid                      (                               ),//(o)
        .s_axi_araddr                   (m00_axi_araddr                 ),//(i)
        .s_axi_arburst                  (m00_axi_arburst                ),//(i)
        .s_axi_arcache                  (m00_axi_arcache                ),//(i)
        .s_axi_arid                     (m00_axi_arid                   ),//(i)
        .s_axi_arlen                    (m00_axi_arlen                  ),//(i)
        .s_axi_arlock                   (m00_axi_arlock                 ),//(i)
        .s_axi_arprot                   (m00_axi_arprot                 ),//(i)
        .s_axi_arqos                    (m00_axi_arqos                  ),//(i)
        .s_axi_arvalid                  (m00_axi_arvalid                ),//(i)
        .s_axi_arready                  (m00_axi_arready                ),//(o)
        .s_axi_arsize                   (m00_axi_arsize                 ),//(i)
        .s_axi_aruser                   (m00_axi_aruser                 ),//(i)
        .s_axi_wvalid                   ('d0                            ),//(i)
        .s_axi_wready                   (                               ),//(o)
        .s_axi_wstrb                    ('d0                            ),//(i)
        .s_axi_wdata                    ('d0                            ),//(i)
        .s_axi_wlast                    ('d0                            ),//(i)
        .s_axi_rdata                    (m00_axi_rdata                  ),//(o)
        .s_axi_rvalid                   (m00_axi_rvalid                 ),//(o)
        .s_axi_rready                   (m00_axi_rready                 ),//(i)
        .s_axi_rlast                    (m00_axi_rlast                  ),//(o)
        .s_axi_rresp                    (m00_axi_rresp                  ),//(o)
        .s_axi_rid                      (m00_axi_rid                    ),//(o)
																        
        .ch1_wr_burst_req               (ch0_wr_burst_req               ),//(i)
        .ch1_wr_burst_len               (ch0_wr_burst_len               ),//(i)
        .ch1_wr_burst_addr              (ch0_wr_burst_addr              ),//(i)
        .ch1_wr_burst_data_req          (ch0_wr_burst_data_req          ),//(o)
        .ch1_wr_burst_data              (ch0_wr_burst_data              ),//(i)
        .ch1_wr_burst_finish            (ch0_wr_burst_finish            ),//(o)
        .ch2_wr_burst_req               ('d0                            ),//(i)
        .ch2_wr_burst_len               ('d0                            ),//(i)
        .ch2_wr_burst_addr              ('d0                            ),//(i)
        .ch2_wr_burst_data_req          (                               ),//(o)
        .ch2_wr_burst_data              ('d0                            ),//(i)
        .ch2_wr_burst_finish            (                               ),//(o)
        .ch3_wr_burst_req               ('d0                            ),//(i)
        .ch3_wr_burst_len               ('d0                            ),//(i)
        .ch3_wr_burst_addr              ('d0                            ),//(i)
        .ch3_wr_burst_data_req          (                               ),//(o)
        .ch3_wr_burst_data              ('d0                            ),//(i)
        .ch3_wr_burst_finish            (                               ),//(o)
																        
        .c0_ddr4_adr                    (ddr4_a                         ),//(o)
        .c0_ddr4_ba                     (ddr4_ba                        ),//(o)
        .c0_ddr4_cke                    (ddr4_cke                       ),//(o)
        .c0_ddr4_cs_n                   (ddr4_cs                        ),//(o)
        .c0_ddr4_dm_dbi_n               (ddr4_dm                        ),//(i)
        .c0_ddr4_dq                     (ddr4_d                         ),//(i)
        .c0_ddr4_dqs_c                  (ddr4_dqs_n                     ),//(i)
        .c0_ddr4_dqs_t                  (ddr4_dqs_p                     ),//(i)
        .c0_ddr4_odt                    (ddr4_odt                       ),//(o)
        .c0_ddr4_bg                     (ddr4_bg                        ),//(o)
        .c0_ddr4_reset_n                (ddr4_reset                     ),//(o)
        .c0_ddr4_act_n                  (ddr4_act                       ),//(o)
        .c0_ddr4_ck_c                   (ddr4_ck_n                      ),//(o)
        .c0_ddr4_ck_t                   (ddr4_ck_p                      ),//(o)
		.cfg_irq_clr_cnt                (cfg_irq_clr_cnt                ),//(i)
        .rd_8m_irq_en                   (rd_8m_irq_en                   ),//(o)
        .rd_8m_irq_clr                  (ch0_irq_clr                    ),//(i)
        .avail_addr                     (avail_addr                     ),//(o)
        .rd_blk_cnt                     (rd_blk_cnt                     ),//(o)
        .rd_blk_irq_cnt                 (rd_blk_irq_cnt                 ),//(o)
        .overflow_cnt                   (overflow_cnt                   ),//(o)
        .adc_chk_suc_cnt                (axi_adc_chk_suc_cnt            ),//(o)
        .adc_chk_err_cnt                (axi_adc_chk_err_cnt            ),//(o)
        .enc_chk_suc_cnt                (axi_enc_chk_suc_cnt            ),//(o)
        .enc_chk_err_cnt                (axi_enc_chk_err_cnt            ),//(o)
        .dr_adc_chk_suc_cnt             (dr_adc_chk_suc_cnt             ),//(o)
        .dr_adc_chk_err_cnt             (dr_adc_chk_err_cnt             ),//(o)
        .dr_enc_chk_suc_cnt             (dr_enc_chk_suc_cnt             ),//(o)
        .dr_enc_chk_err_cnt             (dr_enc_chk_err_cnt             ),//(o)
        .init_calib_complete            (init_calib_cpl                 ) //(o)
    );                                                     

    //---------------------------------------------------------------------
    // reg_ctrl Module Inst.
    //---------------------------------------------------------------------   
    reg_ctrl u0_reg_ctrl (             
        .xrst                           (aresetn                        ), // (i)
        .clk                            (aclk                           ), // (i)
                                                                          
        .s_axil_awaddr                  (m01_axil_awaddr                ), // (i) [ 31:0]
        .s_axil_awprot                  (m01_axil_awprot                ), // (i) [  2:0]
        .s_axil_awvalid                 (m01_axil_awvalid               ), // (i)
        .s_axil_awready                 (m01_axil_awready               ), // (o)
        .s_axil_wdata                   (m01_axil_wdata                 ), // (i) [ 31:0]
        .s_axil_wstrb                   (m01_axil_wstrb                 ), // (i) [  3:0]
        .s_axil_wvalid                  (m01_axil_wvalid                ), // (i)
        .s_axil_wready                  (m01_axil_wready                ), // (o)
        .s_axil_bresp                   (m01_axil_bresp                 ), // (o) [  1:0]
        .s_axil_bvalid                  (m01_axil_bvalid                ), // (o)
        .s_axil_bready                  (m01_axil_bready                ), // (i)
        .s_axil_araddr                  (m01_axil_araddr                ), // (i) [ 31:0]
        .s_axil_arprot                  (m01_axil_arprot                ), // (i) [  2:0]
        .s_axil_arvalid                 (m01_axil_arvalid               ), // (i)
        .s_axil_arready                 (m01_axil_arready               ), // (o)
        .s_axil_rdata                   (m01_axil_rdata                 ), // (o) [ 31:0]
        .s_axil_rresp                   (m01_axil_rresp                 ), // (o) [  1:0]
        .s_axil_rvalid                  (m01_axil_rvalid                ), // (o)
        .s_axil_rready                  (m01_axil_rready                ), // (i)
         // User define signal         

        .pkt_end_flag                   (pkt_end_flag                   ),//(i)
        .adc_end_flag                   (adc_end_flag                   ),//(i)
        .dbg_cnt_arr                    (dbg_cnt_arr                    ),//(o)
        .i_regc0                        (dw_adc_chk_suc_cnt             ),//(i) 16'h0020     
        .i_regc1                        (dw_adc_chk_err_cnt             ),//(i) 16'h0024     
        .i_regc2                        (dw_enc_chk_suc_cnt             ),//(i) 16'h0028     
        .i_regc3                        (dw_enc_chk_err_cnt             ),//(i) 16'h002C     
        .i_regc4                        (dr_adc_chk_suc_cnt             ),//(i) 16'h0030     
        .i_regc5                        (dr_adc_chk_err_cnt             ),//(i) 16'h0034     
        .i_regc6                        (dr_enc_chk_suc_cnt             ),//(i) 16'h0038     
        .i_regc7                        (dr_enc_chk_err_cnt             ),//(i) 16'h003C     
                                                                         
        .i_regb0                        (axi_adc_chk_suc_cnt            ),//(i) 16'h0040     
        .i_regb1                        (axi_adc_chk_err_cnt            ),//(i) 16'h0044     
        .i_regb2                        (axi_enc_chk_suc_cnt            ),//(i) 16'h0048     
        .i_regb3                        (axi_enc_chk_err_cnt            ),//(i) 16'h004C     
        .i_regb4                        (adc_chk_suc_cnt                ),//(i) 16'h0050     
        .i_regb5                        (adc_chk_err_cnt                ),//(i) 16'h0054     
        .i_regb6                        (enc_chk_suc_cnt                ),//(i) 16'h0058     
        .i_regb7                        (enc_chk_err_cnt                ),//(i) 16'h005C     
        .i_rega0                        (overflow_cnt                   ),//(i) 16'h0060     
        .i_rega1                        (avail_addr                     ),//(i) 16'h0064     
        .i_rega2                        (ch0_blk_cnt                    ),//(i) 16'h0068     
        .i_rega3                        (rd_blk_cnt                     ),//(i) 16'h006C     
        .i_rega4                        (dbg_cnt_arr                    ),//(i) 16'h0070     
        .i_rega5                        (32'd0                          ),//(i) 16'h0074     
        .i_rega6                        (32'd0                          ),//(i) 16'h0078     
        .i_rega7                        (32'd0                          ),//(i) 16'h007C     
                                                                                     
        .i_reg0                         ({29'd0,c0_lane_up,c0_channel_up,mmcm_locked,init_calib_cpl,lnk_up_led}), // (i) 16'h0080     
        .i_reg1                         ({30'd0,c0_mmcm_not_locked_out,c0_gt_pll_lock,c0_soft_err,c0_hard_err} ), // (i) 16'h0084     
        .i_reg2                         (aurora_soft_err_cnt                               ), // (i) 16'h0088    
        .i_reg3                         (aurora_soft_rst_cnt                               ), // (i) 16'h008C     
        .i_reg4                         (ch0_fifo_full_cnt                                 ), // (i) 16'h0090     
        .i_reg5                         (ch0_tlast_cnt                                     ), // (i) 16'h0094     
        .i_reg6                         (ch0_blk_cnt                                       ), // (i) 16'h0098     
        .i_reg7                         (ch0_irq_trig_cnt                                  ), // (i) 16'h009C     
        .o_reg0                         (o_reg0                            ), // (o) 16'h00A0     cfg_rst
        .o_reg1                         (reg_test                          ), // (o) 16'h00A4     
        .o_reg2                         (cfg_irq_clr_cnt                   ), // (o) 16'h00A8     
        .o_reg3                         (sfp_tx_disable                    ), // (o) 16'h00AC      
        .o_reg4                         (                                  ), // (o) 16'h00B0      
        .o_reg5                         (                                  ), // (o) 16'h00B4      
        .o_reg6                         (                                  ), // (o) 16'h00B8      
        .o_reg7                         (                                  ), // (o) 16'h00BC      
        .o_regb0                        (cfg_len                           ), // (o) 16'h00C0     
        .o_regb1                        (cfg_mode                          ), // (o) 16'h00C4     
        .o_regb2                        (cfg_trig                          ), // (o) 16'h00C8     
        .o_regb3                        (cfg_times                         ), // (o) 16'h00CC      
        .o_regb4                        (loopback                          ), // (o) 16'h00D0      
        .o_regb5                        (cfg_interval                      ), // (o) 16'h00D4      
        .o_regb6                        (                                  ), // (o) 16'h00D8      
        .o_regb7                        (                                  )  // (o) 16'h00DC      
    );

    startup_ctrl_top u_startup_ctrl_top(
        .aclk                           (aclk                   ),//(i) 
        .aresetn                        (aresetn                ),//(i) 
        .s_axil_awaddr                  ({8'h0,m00_axil_awaddr[23:0]}),//(i) 
        .s_axil_awprot                  (m00_axil_awprot        ),//(i) 
        .s_axil_awvalid                 (m00_axil_awvalid       ),//(i) 
        .s_axil_awready                 (m00_axil_awready       ),//(o) 
        .s_axil_wdata                   (m00_axil_wdata         ),//(i) 
        .s_axil_wstrb                   (m00_axil_wstrb         ),//(i) 
        .s_axil_wvalid                  (m00_axil_wvalid        ),//(i) 
        .s_axil_wready                  (m00_axil_wready        ),//(o) 
        .s_axil_bresp                   (m00_axil_bresp         ),//(o) 
        .s_axil_bvalid                  (m00_axil_bvalid        ),//(o) 
        .s_axil_bready                  (m00_axil_bready        ),//(i) 
        .s_axil_araddr                  ({8'h0,m00_axil_araddr[23:0]}),//(i) 
        .s_axil_arprot                  (m00_axil_arprot        ),//(i) 
        .s_axil_arvalid                 (m00_axil_arvalid       ),//(i) 
        .s_axil_arready                 (m00_axil_arready       ),//(o) 
        .s_axil_rdata                   (m00_axil_rdata         ),//(o) 
        .s_axil_rresp                   (m00_axil_rresp         ),//(o) 
        .s_axil_rvalid                  (m00_axil_rvalid        ),//(o) 
        .s_axil_rready                  (m00_axil_rready        ),//(i) 
                                                                       
        .clk_125M                       (clk_125m               ),//(i)
        .clk_125M_rst                   (~mmcm_locked           ),//(i)
        .FLASH_DATA                     (FLASH_DATA             ),//(i)
        .FLASH_ADDR                     (FLASH_ADDR             ),//(o)
        .FLASH_WE_B                     (FLASH_WE_B             ),//(o)
        .FLASH_ADV_B                    (FLASH_ADV_B            ),//(o)
        .FLASH_OE_B                     (FLASH_OE_B             ),//(o)
        .FLASH_CE_B                     (                       ),//(o)
        .FLASH_WAIT                     (FLASH_WAIT             ) //(i)
    );

    //---------------------------------------------------------------------
    // Aurora_6466b_powon_rst Module Inst.
    //---------------------------------------------------------------------  
    aurora_6466b_powon_rst #(                                                          
        .TIMES                         (512                            ),
        .SIM_ENABLE                    (SIM                            )       
    )u_aurora_6466b_powon_rst( 
        .clk                           (init_clk                       ),//(i)
        .rst_n                         (mmcm_locked                    ),//(i)
        .soft_rst                      (1'b0                           ),//(i)
        .pma_init                      (c0_pma_init                    ),//(o)
        .reset_pb                      (c0_reset_pb                    ) //(o)
    );                                                                  

    cmip_pkt_gen_easy #(                                                          
        .DATA_WD                       (128                            ),
        .CFG_WD                        (32                             )       
    )u0_cmip_pkt_gen_easy(        
        .clk                           (c0_user_clk                    ),//(i)
        .rst_n                         (mmcm_locked                    ),//(i)
        .cfg_rst                       (~c0_channel_up   ||  cfg_rst   ),//(i)
        .cfg_len                       (cfg_len                        ),//(i)
        .cfg_mode                      (cfg_mode                       ),//(i)
        .cfg_trig                      (cfg_trig[0]                    ),//(i)
        .cfg_times                     (cfg_times                      ),//(i)
        .cfg_interval                  (cfg_interval                   ),//(i)
        .sts_idle                      (                               ),//(o)
        .sts_vld_cnt                   (c0_sts_vld_cnt                 ),//(o)
        .m_axis_tdata                  (c0_s_axi_tx_tdata              ),//(o)
        .m_axis_tkeep                  (c0_s_axi_tx_tkeep              ),//(o)
        .m_axis_tvalid                 (c0_s_axi_tx_tvalid             ),//(o)
        .m_axis_tready                 (c0_s_axi_tx_tready             ),//(i)
        .m_axis_tlast                  (c0_s_axi_tx_tlast              ),//(o)
        .m_axis_tuser                  (                               ) //(o)
    );                                                                    

    //---------------------------------------------------------------------
    // Aurora Module Inst.
    //---------------------------------------------------------------------   
    aurora_64b66b_ip_support u_aurora_64b66b_ip_support(                          
        .s_axi_tx_tdata                (c0_s_axi_tx_tdata              ),//(i)    
        .s_axi_tx_tkeep                (c0_s_axi_tx_tkeep              ),//(i)    
        .s_axi_tx_tlast                (c0_s_axi_tx_tlast              ),//(i)    
        .s_axi_tx_tvalid               (c0_s_axi_tx_tvalid             ),//(i)    
        .s_axi_tx_tready               (c0_s_axi_tx_tready             ),//(o)    
        .m_axi_rx_tdata                (c0_m_axi_rx_tdata              ),//(o)    
        .m_axi_rx_tkeep                (c0_m_axi_rx_tkeep              ),//(o)    
        .m_axi_rx_tlast                (c0_m_axi_rx_tlast              ),//(o)    
        .m_axi_rx_tvalid               (c0_m_axi_rx_tvalid             ),//(o)    
        .aurora_soft_rst               (aurora_soft_rst                ),//(o)
        .aurora_soft_rst_cnt           (aurora_soft_rst_cnt            ),//(o)
        .aurora_soft_err_cnt           (aurora_soft_err_cnt            ),//(o)
        .pkt_end_flag                  (pkt_end_flag                   ),//(o)
        .adc_end_flag                  (adc_end_flag                   ),//(o)

        .rxp                           (c0_rxp                         ),//(i)    
        .rxn                           (c0_rxn                         ),//(i)    
        .txp                           (c0_txp                         ),//(o)    
        .txn                           (c0_txn                         ),//(o)    
        .hard_err                      (c0_hard_err                    ),//(o)    
        .soft_err                      (c0_soft_err                    ),//(o)    
        .channel_up                    (c0_channel_up                  ),//(o)    
        .lane_up                       (c0_lane_up                     ),//(o)    
        .user_clk_out                  (c0_user_clk                    ),//(o)    
        .sync_clk_out                  (                               ),//(o)    
        .reset_pb                      (c0_reset_pb                    ),//(i)    
        .gt_rxcdrovrden_in             (1'b0                           ),//(i)    
        .power_down                    (1'b0                           ),//(i)    
        .loopback                      (loopback[3:0]                  ),//(i)    
        .pma_init                      (c0_pma_init                    ),//(i)    
        .gt0_drpdo                     (                               ),//(o)    
        .gt0_drprdy                    (                               ),//(o)    
        .gt1_drpdo                     (                               ),//(o)    
        .gt1_drprdy                    (                               ),//(o)    
        .gt0_drpaddr                   ('d0                            ),//(i)    
        .gt0_drpdi                     ('d0                            ),//(i)    
        .gt0_drpen                     ('d0                            ),//(i)    
        .gt0_drpwe                     ('d0                            ),//(i)    
        .gt1_drpaddr                   ('d0                            ),//(i)    
        .gt1_drpdi                     ('d0                            ),//(i)    
        .gt1_drpen                     ('d0                            ),//(i)    
        .gt1_drpwe                     ('d0                            ),//(i)    
        .init_clk                      (init_clk                       ),//(i)    
        .link_reset_out                (c0_link_reset_out              ),//(o)    
        .gt_pll_lock                   (c0_gt_pll_lock                 ),//(o)    
        .sys_reset_out                 (c0_sys_reset_out               ),//(o)    
        .gt_refclk1_p                  (gt_refclk1_p                   ),//(i)    
        .gt_refclk1_n                  (gt_refclk1_n                   ),//(i)    
        .bufg_gt_clr_out               (                               ),//(o)    
        .mmcm_not_locked_out           (c0_mmcm_not_locked_out         ),//(o)    
        .tx_out_clk                    (                               ) //(o)    
    );                                                                            
                                                                                  

 
    //---------------------------------------------------------------------
    // aurora2ddr_wr_burst Module Inst.
    //---------------------------------------------------------------------   
    aurora2ddr_wr_burst #(                                                     
        .DDR_ADDR_WD                   (DDR_ADDR_WD                    ),
        .DDR_DATA_WD                   (DDR_DATA_WD                    ),
        .MAX_BLK_SIZE                  (MAX_BLK_SIZE                   ),
        .BURST_LEN                     (64                             )       
    )u_aurora2ddr_wr_burst( 
        .ddr_clk                       (ddr_clk                        ),//(i)
        .ddr_rst_n                     (ddr_rst_n                      ),//(i)
        .c0_user_clk                   (c0_user_clk                    ),//(i)
        .c0_user_rst_n                 (mmcm_locked                    ),//(i)	
        .cfg_rst                       (~c0_channel_up  || cfg_rst     ),//(i)
        .c0_m_axi_rx_tdata             (c0_m_axi_rx_tdata              ),//(i)
        .c0_m_axi_rx_tkeep             (c0_m_axi_rx_tkeep              ),//(i)
        .c0_m_axi_rx_tvalid            (c0_m_axi_rx_tvalid             ),//(i)
        .c0_m_axi_rx_tlast             (c0_m_axi_rx_tlast              ),//(i)
        .ch0_wr_burst_req              (ch0_wr_burst_req               ),//(o)
        .ch0_wr_burst_len              (ch0_wr_burst_len               ),//(o)
        .ch0_wr_burst_addr             (ch0_wr_burst_addr              ),//(o)
        .ch0_wr_burst_data_req         (ch0_wr_burst_data_req          ),//(i)
        .ch0_wr_burst_data             (ch0_wr_burst_data              ),//(o)
        .ch0_wr_burst_finish           (ch0_wr_burst_finish            ),//(i)
        .ch0_irq_en                    (ch0_irq_en                     ),//(o)
        .ch0_irq_clr                   (1'b0                           ),//(i)
        .ch0_blk_cnt                   (ch0_blk_cnt                    ),//(o)
        .ch0_fifo_full_cnt             (ch0_fifo_full_cnt              ),//(o)
        .ch0_irq_trig_cnt              (ch0_irq_trig_cnt               ),//(o)
        .ch0_tlast_cnt                 (ch0_tlast_cnt                  ) //(o)
    );                                                                         


    //---------------------------------------------------------------------
    // aurora2ddr_wr_burst Module Inst.
    //---------------------------------------------------------------------   
    aurora_20g_chk_top u_aurora_20g_chk_top(                          
        .clk                           (c0_user_clk                    ),//(i)
        .rst_n                         (mmcm_locked                    ),//(i)
        .cfg_rst                       (cfg_rst                        ),//(i)
        .s_axis_tdata                  (c0_m_axi_rx_tdata              ),//(i)
        .s_axis_tkeep                  (c0_m_axi_rx_tkeep              ),//(i)
        .s_axis_tvalid                 (c0_m_axi_rx_tvalid             ),//(i)
        .s_axis_tlast                  (c0_m_axi_rx_tlast              ),//(i)
        .adc_chk_suc_cnt               (adc_chk_suc_cnt                ),//(o)
        .adc_chk_err_cnt               (adc_chk_err_cnt                ),//(o)
        .enc_chk_suc_cnt               (enc_chk_suc_cnt                ),//(o)
        .enc_chk_err_cnt               (enc_chk_err_cnt                ) //(o)
    );  


    wire             ddr_cfg_rst   ;
    xpm_cdc_async_rst #(
       .DEST_SYNC_FF(4            ),    // DECIMAL; range: 2-10
       .INIT_SYNC_FF(0            ),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       .RST_ACTIVE_HIGH(1         )  // DECIMAL; 0=active low reset, 1=active high reset
    )u0_xpm_cdc_async_rst (
       .dest_arst   (ddr_cfg_rst  ), 
       .dest_clk    (ddr_clk      ),   // 1-bit input: Destination clock.
       .src_arst    (cfg_rst      )    // 1-bit input: Source asynchronous reset signal.
    );

    ddr_512b_chk_top u_ddr_512b_chk_top( 
        .clk                           (ddr_clk               ),//(i)
        .rst_n                         (ddr_rst_n             ),//(i)
        .cfg_rst                       (ddr_cfg_rst           ),//(i)
        .s_axis_tdata                  (ch0_wr_burst_data     ),//(i)
        .s_axis_tvalid                 (ch0_wr_burst_data_req ),//(i)
        .adc_chk_suc_cnt               (dw_adc_chk_suc_cnt    ),//(o)
        .adc_chk_err_cnt               (dw_adc_chk_err_cnt    ),//(o)
        .enc_chk_suc_cnt               (dw_enc_chk_suc_cnt    ),//(o)
        .enc_chk_err_cnt               (dw_enc_chk_err_cnt    ) //(o)
    );    


endmodule



















