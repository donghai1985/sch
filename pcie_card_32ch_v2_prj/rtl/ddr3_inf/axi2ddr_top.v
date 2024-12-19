// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : axi2ddr_inf.v
// Module         : axi2ddr_inf
// Function       : 
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2023/09/28   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================


module axi2ddr_top #(
    parameter                               FIFO_DPTH       =  1024        ,
    parameter                               AXI_DATA_WD     =  128         ,
    parameter                               AXI_ADDR_WD     =  64          ,
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               DDR3_SIM        =  0           ,
    parameter                               DGBCNT_EN       =  1           ,
    parameter                               DGBCNT_WD       =  16          ,
    parameter                               MAX_BLK_SIZE    =  32'h1000    
)(
    input                                   sys_clk_p                      ,//(i)
    input                                   sys_clk_n                      ,//(i)
    input                                   sys_rst_n                      ,//(i)
    output                                  ddr_clk                        ,//(i)
    output                                  ddr_rst_n                      ,//(i)
    //input                                   clk_ref                        ,//(i)
    input                                   axi_clk                        ,//(i)
    input                                   axi_rst_n                      ,//(i)
    input                                   cfg_rst                        ,//(i)

    input             [AXI_ADDR_WD  -1:0]   s_axi_awaddr                   ,//(i)
    input             [ 1:0]                s_axi_awburst                  ,//(i)
    input             [ 3:0]                s_axi_awcache                  ,//(i)
    input             [ 3:0]                s_axi_awid                     ,//(i)
    input             [ 7:0]                s_axi_awlen                    ,//(i)
    input                                   s_axi_awlock                   ,//(i)
    input             [ 2:0]                s_axi_awprot                   ,//(i)
    input             [ 3:0]                s_axi_awqos                    ,//(i)
    input                                   s_axi_awvalid                  ,//(i)
    output                                  s_axi_awready                  ,//(o)
    input             [ 2:0]                s_axi_awsize                   ,//(i)
    input                                   s_axi_awuser                   ,//(i)
    output                                  s_axi_bvalid                   ,//(o)
    input                                   s_axi_bready                   ,//(i)
    output            [ 1:0]                s_axi_bresp                    ,//(o)
    output            [ 3:0]                s_axi_bid                      ,//(o)

    input             [AXI_ADDR_WD  -1:0]   s_axi_araddr                   ,//(i)
    input             [ 1:0]                s_axi_arburst                  ,//(i)
    input             [ 3:0]                s_axi_arcache                  ,//(i)
    input             [ 3:0]                s_axi_arid                     ,//(i)
    input             [ 7:0]                s_axi_arlen                    ,//(i)
    input                                   s_axi_arlock                   ,//(i)
    input             [ 2:0]                s_axi_arprot                   ,//(i)
    input             [ 3:0]                s_axi_arqos                    ,//(i)
    input                                   s_axi_arvalid                  ,//(i)
    output                                  s_axi_arready                  ,//(o)
    input             [ 2:0]                s_axi_arsize                   ,//(i)
    input                                   s_axi_aruser                   ,//(i)
    input                                   s_axi_wvalid                   ,//(i)
    output                                  s_axi_wready                   ,//(o)
    input             [AXI_DATA_WD  /8-1:0] s_axi_wstrb                    ,//(i)
    input             [AXI_DATA_WD    -1:0] s_axi_wdata                    ,//(i)
    input                                   s_axi_wlast                    ,//(i)

    output            [AXI_DATA_WD  -1:0]   s_axi_rdata                    ,//(o)
    output                                  s_axi_rvalid                   ,//(o)
    input                                   s_axi_rready                   ,//(i)
    output                                  s_axi_rlast                    ,//(o)
    output            [ 1:0]                s_axi_rresp                    ,//(o)
    output            [ 3:0]                s_axi_rid                      ,//(o)

    input                                   ch1_wr_burst_req               ,//(i)
    input             [9:0]                 ch1_wr_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch1_wr_burst_addr              ,//(i)
    output                                  ch1_wr_burst_data_req          ,//(o)
    input             [DDR_DATA_WD  -1:0]   ch1_wr_burst_data              ,//(i)
    output                                  ch1_wr_burst_finish            ,//(i)

    input                                   ch2_wr_burst_req               ,//(i)
    input             [9:0]                 ch2_wr_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch2_wr_burst_addr              ,//(i)
    output                                  ch2_wr_burst_data_req          ,//(o)
    input             [DDR_DATA_WD  -1:0]   ch2_wr_burst_data              ,//(i)
    output                                  ch2_wr_burst_finish            ,//(i)

    input                                   ch3_wr_burst_req               ,//(i)
    input             [9:0]                 ch3_wr_burst_len               ,//(i)
    input             [DDR_ADDR_WD  -1:0]   ch3_wr_burst_addr              ,//(i)
    output                                  ch3_wr_burst_data_req          ,//(o)
    input             [DDR_DATA_WD  -1:0]   ch3_wr_burst_data              ,//(i)
    output                                  ch3_wr_burst_finish            ,//(i)

    output            [16: 0]               c0_ddr4_adr                    ,//(o)
    output            [1 : 0]               c0_ddr4_ba                     ,//(o)
    output            [0 : 0]               c0_ddr4_cke                    ,//(o)
    output            [0 : 0]               c0_ddr4_cs_n                   ,//(o)
    inout             [7 : 0]               c0_ddr4_dm_dbi_n               ,//(i)
    inout             [63: 0]               c0_ddr4_dq                     ,//(i)
    inout             [7 : 0]               c0_ddr4_dqs_c                  ,//(i)
    inout             [7 : 0]               c0_ddr4_dqs_t                  ,//(i)
    output            [0 : 0]               c0_ddr4_odt                    ,//(o)
    output            [1 : 0]               c0_ddr4_bg                     ,//(o)
    output                                  c0_ddr4_reset_n                ,//(o)
    output                                  c0_ddr4_act_n                  ,//(o)
    output            [0 : 0]               c0_ddr4_ck_c                   ,//(o)
    output            [0 : 0]               c0_ddr4_ck_t                   ,//(o)

    input             [7:0]                 cfg_irq_clr_cnt                ,//(i)
    output                                  rd_8m_irq_en                   ,//(o)
    input                                   rd_8m_irq_clr                  ,//(i)
    output            [DDR_ADDR_WD-1:0]     rd_blk_cnt                     ,//(o)
    output            [DDR_ADDR_WD-1:0]     rd_blk_irq_cnt                 ,//(o)
    output                                  init_calib_complete            ,//(o)
    output            [DDR_ADDR_WD  -1:0]   avail_addr                     ,//(o)
    output            [31:0]                overflow_cnt                   ,//(o)
    output            [31:0]                adc_chk_suc_cnt                ,//(o)
    output            [31:0]                adc_chk_err_cnt                ,//(o)
    output            [31:0]                enc_chk_suc_cnt                ,//(o)
    output            [31:0]                enc_chk_err_cnt                ,//(o)
    output            [31:0]                dr_adc_chk_suc_cnt             ,//(o)
    output            [31:0]                dr_adc_chk_err_cnt             ,//(o)
    output            [31:0]                dr_enc_chk_suc_cnt             ,//(o)
    output            [31:0]                dr_enc_chk_err_cnt              //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    ui_clk                            ;
    wire                                    ui_clk_sync_rst                   ;
	wire                                    ddr_cfg_rst                       ;
    // wire                                    ddr_clk                           ;
    // wire                                    ddr_rst_n                         ;
    wire                                    ch0_wr_burst_req                  ;
    wire        [9:0]                       ch0_wr_burst_len                  ;
    wire        [AXI_ADDR_WD  -1:0]         ch0_wr_burst_addr                 ;
    wire                                    ch0_wr_burst_data_req             ;
    wire        [DDR_DATA_WD  -1:0]         ch0_wr_burst_data                 ;
    wire                                    ch0_wr_burst_finish               ;
    wire                                    wr_burst_req                      ;
    wire        [9:0]                       wr_burst_len                      ;
    wire        [AXI_ADDR_WD  -1:0]         wr_burst_addr                     ;
    wire                                    wr_burst_data_req                 ;
    wire        [DDR_DATA_WD  -1:0]         wr_burst_data                     ;
    wire                                    wr_burst_finish                   ;
//    wire        [DDR_ADDR_WD  -1:0]         avail_addr                        ;
    wire                                    rd_burst_req                      ;
    wire        [9:0]                       rd_burst_len                      ;
    wire        [AXI_ADDR_WD  -1:0]         rd_burst_addr                     ;
    wire                                    rd_burst_data_valid               ;
    wire        [DDR_DATA_WD  -1:0]         rd_burst_data                     ;
    wire                                    rd_burst_finish                   ;
    wire                                    burst_finish                      ;
    wire                                    dbg_cnt_clr                       ;
    wire        [DGBCNT_WD  -1:0]           dbg_axi_arvalid                   ;
    wire                                    burst_idle                        ;
    
    
    wire        [AXI_ADDR_WD -1:0]          app_addr                          ;
    wire        [2:0]                       app_cmd                           ;
    wire                                    app_en                            ;
    wire        [511:0]                     app_wdf_data                      ;
    wire                                    app_wdf_end                       ;
    wire                                    app_wdf_wren                      ;
    wire        [511:0]                     app_rd_data                       ;
    wire                                    app_rd_data_valid                 ;
    wire                                    app_rdy                           ;
    wire                                    app_wdf_rdy                       ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign      ddr_clk      =              ui_clk                            ;


// =================================================================================================
// RTL Body
// =================================================================================================
   xpm_cdc_async_rst #(
      .DEST_SYNC_FF(4),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
   )u0_xpm_cdc_async_rst (
      .dest_arst(ddr_cfg_rst  ), 
      .dest_clk (ddr_clk      ),   // 1-bit input: Destination clock.
      .src_arst (cfg_rst      )    // 1-bit input: Source asynchronous reset signal.
   );
    

    //---------------------------------------------------------------------
    // axi2ddr_inf Inst.
    //---------------------------------------------------------------------     
    axi2ddr_inf #(                                                           
        .FIFO_DPTH                          (FIFO_DPTH                  ),
        .AXI_DATA_WD                        (AXI_DATA_WD                ),
        .AXI_ADDR_WD                        (AXI_ADDR_WD                ),
        .DDR_DATA_WD                        (DDR_DATA_WD                ),
        .DGBCNT_EN                          (DGBCNT_EN                  ),
        .DGBCNT_WD                          (DGBCNT_WD                  ),
        .MAX_BLK_SIZE                       (MAX_BLK_SIZE               )  
    )u_axi2ddr_inf(      
        .ddr_clk                            (ddr_clk                    ),//(i)
        .ddr_rst_n                          (ddr_rst_n                  ),//(i)
        .axi_clk                            (axi_clk                    ),//(i)
        .axi_rst_n                          (axi_rst_n                  ),//(i)
        .cfg_rst                            (cfg_rst                    ),//(i)
        .s_axi_awaddr                       (s_axi_awaddr               ),//(i)
        .s_axi_awburst                      (s_axi_awburst              ),//(i)
        .s_axi_awcache                      (s_axi_awcache              ),//(i)
        .s_axi_awid                         (s_axi_awid                 ),//(i)
        .s_axi_awlen                        (s_axi_awlen                ),//(i)
        .s_axi_awlock                       (s_axi_awlock               ),//(i)
        .s_axi_awprot                       (s_axi_awprot               ),//(i)
        .s_axi_awqos                        (s_axi_awqos                ),//(i)
        .s_axi_awvalid                      (s_axi_awvalid              ),//(i)
        .s_axi_awready                      (s_axi_awready              ),//(o)
        .s_axi_awsize                       (s_axi_awsize               ),//(i)
        .s_axi_awuser                       (s_axi_awuser               ),//(i)
        .s_axi_bvalid                       (s_axi_bvalid               ),//(o)
        .s_axi_bready                       (s_axi_bready               ),//(i)
        .s_axi_bresp                        (s_axi_bresp                ),//(o)
        .s_axi_bid                          (s_axi_bid                  ),//(o)
        .s_axi_wvalid                       (s_axi_wvalid               ),//(i)
        .s_axi_wready                       (s_axi_wready               ),//(o)
        .s_axi_wstrb                        (s_axi_wstrb                ),//(i)
        .s_axi_wdata                        (s_axi_wdata                ),//(i)
        .s_axi_wlast                        (s_axi_wlast                ),//(i)
         
        .s_axi_araddr                       (s_axi_araddr               ),//(i)
        .s_axi_arburst                      (s_axi_arburst              ),//(i)
        .s_axi_arcache                      (s_axi_arcache              ),//(i)
        .s_axi_arid                         (s_axi_arid                 ),//(i)
        .s_axi_arlen                        (s_axi_arlen                ),//(i)
        .s_axi_arlock                       (s_axi_arlock               ),//(i)
        .s_axi_arprot                       (s_axi_arprot               ),//(i)
        .s_axi_arqos                        (s_axi_arqos                ),//(i)
        .s_axi_arvalid                      (s_axi_arvalid              ),//(i)
        .s_axi_arready                      (s_axi_arready              ),//(o)
        .s_axi_arsize                       (s_axi_arsize               ),//(i)
        .s_axi_aruser                       (s_axi_aruser               ),//(i)
        .s_axi_rdata                        (s_axi_rdata                ),//(o)
        .s_axi_rvalid                       (s_axi_rvalid               ),//(o)
        .s_axi_rready                       (s_axi_rready               ),//(i)
        .s_axi_rlast                        (s_axi_rlast                ),//(o)
        .s_axi_rresp                        (s_axi_rresp                ),//(o)
        .s_axi_rid                          (s_axi_rid                  ),//(o)
         
        .wr_burst_req                       (ch0_wr_burst_req           ),//(o)
        .wr_burst_len                       (ch0_wr_burst_len           ),//(o)
        .wr_burst_addr                      (ch0_wr_burst_addr          ),//(o)
        .wr_burst_data_req                  (ch0_wr_burst_data_req      ),//(i)
        .wr_burst_data                      (ch0_wr_burst_data          ),//(o)
        .wr_burst_finish                    (ch0_wr_burst_finish        ),//(i)
        .avail_addr                         (avail_addr                 ),//(i)
        .rd_burst_req                       (rd_burst_req               ),//(o)
        .rd_burst_len                       (rd_burst_len               ),//(o)
        .rd_burst_addr                      (rd_burst_addr              ),//(o)
        .rd_burst_data_valid                (rd_burst_data_valid        ),//(i)
        .rd_burst_data                      (rd_burst_data              ),//(i)
        .rd_burst_finish                    (rd_burst_finish            ),//(i)
		.cfg_irq_clr_cnt                    (cfg_irq_clr_cnt[6:0]       ),//(i)
        .rd_8m_irq_en                       (rd_8m_irq_en               ),//(o)
        .rd_8m_irq_clr                      (rd_8m_irq_clr              ),//(i)
        .rd_blk_cnt                         (rd_blk_cnt                 ),//(o)
        .rd_blk_irq_cnt                     (rd_blk_irq_cnt             ),//(o)
        .adc_chk_suc_cnt                    (adc_chk_suc_cnt            ),//(o)
        .adc_chk_err_cnt                    (adc_chk_err_cnt            ),//(o)
        .enc_chk_suc_cnt                    (enc_chk_suc_cnt            ),//(o)
        .enc_chk_err_cnt                    (enc_chk_err_cnt            ),//(o)
        .dr_adc_chk_suc_cnt                 (dr_adc_chk_suc_cnt         ),//(o)
        .dr_adc_chk_err_cnt                 (dr_adc_chk_err_cnt         ),//(o)
        .dr_enc_chk_suc_cnt                 (dr_enc_chk_suc_cnt         ),//(o)
        .dr_enc_chk_err_cnt                 (dr_enc_chk_err_cnt         ) //(o)
    );                                                                  
                                                            




    ddr_wr_sch #(                                                           
        .DDR_ADDR_WD                        (DDR_ADDR_WD                ),
        .DDR_DATA_WD                        (DDR_DATA_WD                )       
    )u_ddr_wr_sch( 
        .ddr_clk                            (ddr_clk                    ),//(i)
        .ddr_rst_n                          (ddr_rst_n && (~ddr_cfg_rst)),//(i)
        .ddr_burst_idle                     (burst_idle                 ),//(i)
        .ch0_wr_burst_req                   (ch0_wr_burst_req           ),//(i)
        .ch0_wr_burst_len                   (ch0_wr_burst_len           ),//(i)
        .ch0_wr_burst_addr                  (ch0_wr_burst_addr          ),//(i)
        .ch0_wr_burst_data_req              (ch0_wr_burst_data_req      ),//(o)
        .ch0_wr_burst_data                  (ch0_wr_burst_data          ),//(i)
        .ch0_wr_burst_finish                (ch0_wr_burst_finish        ),//(o)
        .ch1_wr_burst_req                   (ch1_wr_burst_req           ),//(i)
        .ch1_wr_burst_len                   (ch1_wr_burst_len           ),//(i)
        .ch1_wr_burst_addr                  (ch1_wr_burst_addr          ),//(i)
        .ch1_wr_burst_data_req              (ch1_wr_burst_data_req      ),//(o)
        .ch1_wr_burst_data                  (ch1_wr_burst_data          ),//(i)
        .ch1_wr_burst_finish                (ch1_wr_burst_finish        ),//(o)
        .ch2_wr_burst_req                   (ch2_wr_burst_req           ),//(i)
        .ch2_wr_burst_len                   (ch2_wr_burst_len           ),//(i)
        .ch2_wr_burst_addr                  (ch2_wr_burst_addr          ),//(i)
        .ch2_wr_burst_data_req              (ch2_wr_burst_data_req      ),//(o)
        .ch2_wr_burst_data                  (ch2_wr_burst_data          ),//(i)
        .ch2_wr_burst_finish                (ch2_wr_burst_finish        ),//(o)
        .ch3_wr_burst_req                   (ch3_wr_burst_req           ),//(i)
        .ch3_wr_burst_len                   (ch3_wr_burst_len           ),//(i)
        .ch3_wr_burst_addr                  (ch3_wr_burst_addr          ),//(i)
        .ch3_wr_burst_data_req              (ch3_wr_burst_data_req      ),//(o)
        .ch3_wr_burst_data                  (ch3_wr_burst_data          ),//(i)
        .ch3_wr_burst_finish                (ch3_wr_burst_finish        ),//(o)

        .wr_burst_req                       (wr_burst_req               ),//(o)
        .wr_burst_len                       (wr_burst_len               ),//(o)
        .wr_burst_addr                      (wr_burst_addr              ),//(o)
        .wr_burst_data_req                  (wr_burst_data_req          ),//(i)
        .wr_burst_data                      (wr_burst_data              ),//(o)
        .wr_burst_finish                    (wr_burst_finish            ) //(i)
    );  
   
	//assign     wr_burst_req             =  ch1_wr_burst_req       ; //(o)
	//assign     wr_burst_len             =  ch1_wr_burst_len       ; //(o)
	//assign     wr_burst_addr            =  ch1_wr_burst_addr      ; //(o)
	//assign     ch1_wr_burst_data_req    =  wr_burst_data_req      ; //(i)
	//assign     wr_burst_data            =  ch1_wr_burst_data      ; //(o)
	//assign     ch1_wr_burst_finish      =  wr_burst_finish        ; //(i)
	



	
    //---------------------------------------------------------------------
    // mem_burst Inst.
    //---------------------------------------------------------------------  
/*	
     mem_burst_ctrl#(
        .DQ_WIDTH                    (64                        ),
        .MEM_DATA_BITS               (512                       ),
        .ADDR_WIDTH                  (DDR_ADDR_WD               ),
        .DDR_SIZE                    (MAX_BLK_SIZE              )
    )u_mem_burst(
        .ddr_rst_i                   (~ddr_rst_n || ddr_cfg_rst ),
        .ddr_clk_i                   (ddr_clk                   ),
                                                                     
        .avail_addr                  (avail_addr                ),
        .overflow_cnt                (overflow_cnt              ),
        .rd_ddr_req_i                (rd_burst_req              ),
        .rd_ddr_len_i                (rd_burst_len              ),
        .rd_ddr_addr_i               (rd_burst_addr             ),
        .rd_ddr_data_valid_o         (rd_burst_data_valid       ),
        .rd_ddr_data_o               (rd_burst_data             ),
        .rd_ddr_finish_o             (rd_burst_finish           ),
                                                                      
        .wr_ddr_req_i                (wr_burst_req              ),
        .wr_ddr_len_i                (wr_burst_len              ),
        .wr_ddr_addr_i               (wr_burst_addr             ),
        .wr_ddr_data_req_o           (wr_burst_data_req         ),
        .wr_ddr_data_i               (wr_burst_data             ),
        .wr_ddr_finish_o             (wr_burst_finish           ),
        .burst_idle                  (burst_idle                ),                                                     
        .local_init_done_i           (init_calib_complete       ),
        .app_addr                    (app_addr                  ),
        .app_cmd                     (app_cmd                   ),
        .app_en                      (app_en                    ),
        .app_wdf_data                (app_wdf_data              ),
        .app_wdf_end                 (app_wdf_end               ),
        .app_wdf_mask                (app_wdf_mask              ),
        .app_wdf_wren                (app_wdf_wren              ),
        .app_rd_data                 (app_rd_data               ),
        .app_rd_data_end             (app_rd_data_end           ),
        .app_rd_data_valid           (app_rd_data_valid         ),
        .app_rdy                     (app_rdy                   ),
        .app_wdf_rdy                 (app_wdf_rdy               ),
        .app_sr_req                  (                          ),
        .app_ref_req                 (                          ),
        .app_zq_req                  (                          ),
        .app_sr_active               (1'b0                      ),
        .app_ref_ack                 (1'b0                      ),
        .app_zq_ack                  (1'b0                      )
    );
*/     


    mem_ctrl_inf #(                                          
        .DQ_WD                       (64                    ),
        .DDR_DATA_WD                 (512                   ),
        .DDR_ADDR_WD                 (DDR_ADDR_WD           ),
        .DDR_SIZE                    (MAX_BLK_SIZE          )       
    )u_mem_ctrl_inf( 
        .ddr_clk                     (ddr_clk               ),//(i)
        .ddr_rst_n                   (ddr_rst_n             ),//(i)
        .rd_ddr_req                  (rd_burst_req          ),//(i)
        .rd_ddr_len                  (rd_burst_len          ),//(i)
        .rd_ddr_addr                 (rd_burst_addr         ),//(i)
        .rd_ddr_data_valid           (rd_burst_data_valid   ),//(o)
        .rd_ddr_data                 (rd_burst_data         ),//(o)
        .rd_ddr_finish               (rd_burst_finish       ),//(o)
        .wr_ddr_req                  (wr_burst_req          ),//(i)
        .wr_ddr_len                  (wr_burst_len          ),//(i)
        .wr_ddr_addr                 (wr_burst_addr         ),//(i)
        .wr_ddr_data_req             (wr_burst_data_req     ),//(o)
        .wr_ddr_data                 (wr_burst_data         ),//(i)
        .wr_ddr_finish               (wr_burst_finish       ),//(o)
        .cfg_rst                     (ddr_cfg_rst           ),//(i)
        //.cfg_rd_mode                 (1'b1                  ),//(i)
		.cfg_rd_mode                 (cfg_irq_clr_cnt[7]    ),//(i)
        .burst_idle                  (burst_idle            ),//(o)
        .avail_addr                  (avail_addr            ),//(o)
        .overflow_cnt                (overflow_cnt          ),//(o)
        .local_init_done             (init_calib_complete   ),//(i)
        .app_addr                    (app_addr              ),//(o)
        .app_cmd                     (app_cmd               ),//(o)
        .app_en                      (app_en                ),//(o)
        .app_wdf_data                (app_wdf_data          ),//(o)
        .app_wdf_end                 (app_wdf_end           ),//(o)
        .app_wdf_mask                (app_wdf_mask          ),//(o)
        .app_wdf_wren                (app_wdf_wren          ),//(o)
        .app_rd_data                 (app_rd_data           ),//(i)
        .app_rd_data_end             (app_rd_data_end       ),//(i)
        .app_rd_data_valid           (app_rd_data_valid     ),//(i)
        .app_rdy                     (app_rdy               ),//(i)
        .app_wdf_rdy                 (app_wdf_rdy           ),//(i)
        .app_sr_req                  (                      ),//(o)
        .app_ref_req                 (                      ),//(o)
        .app_zq_req                  (                      ),//(o)
        .app_sr_active               (1'b0                  ),//(i)
        .app_ref_ack                 (1'b0                  ),//(i)
        .app_zq_ack                  (1'b0                  ) //(i)
    );                                                                            
   



generate if(DDR3_SIM == 0)begin
/*
    ddr3_mig ddr3_mig_inst(
        // Memory interface ports
        .ddr3_addr                           (ddr3_addr                  ),  // output [13:0]	ddr3_addr
        .ddr3_ba                             (ddr3_ba                    ),  // output [2:0]		ddr3_ba
        .ddr3_cas_n                          (ddr3_cas_n                 ),  // output			ddr3_cas_n
        .ddr3_ck_n                           (ddr3_ck_n                  ),  // output [0:0]		ddr3_ck_n
        .ddr3_ck_p                           (ddr3_ck_p                  ),  // output [0:0]		ddr3_ck_p
        .ddr3_cke                            (ddr3_cke                   ),  // output [0:0]		ddr3_cke
        .ddr3_ras_n                          (ddr3_ras_n                 ),  // output			ddr3_ras_n
        .ddr3_reset_n                        (ddr3_reset_n               ),  // output			ddr3_reset_n
        .ddr3_we_n                           (ddr3_we_n                  ),  // output			ddr3_we_n
        .ddr3_dq                             (ddr3_dq                    ),  // inout [63:0]		ddr3_dq
        .ddr3_dqs_n                          (ddr3_dqs_n                 ),  // inout [7:0]		ddr3_dqs_n
        .ddr3_dqs_p                          (ddr3_dqs_p                 ),  // inout [7:0]		ddr3_dqs_p
        .init_calib_complete                 (init_calib_complete        ),  // output			init_calib_complete
        .ddr3_cs_n                           (ddr3_cs_n                  ),  // output [0:0]		ddr3_cs_n
        .ddr3_dm                             (ddr3_dm                    ),  // output [7:0]		ddr3_dm
        .ddr3_odt                            (ddr3_odt                   ),  // output [0:0]		ddr3_odt
        // Application interface ports                                                
        .app_addr                            (app_addr                   ),  // input [27:0]		app_addr
        .app_cmd                             (app_cmd                    ),  // input [2:0]		app_cmd
        .app_en                              (app_en                     ),  // input			app_en
        .app_wdf_data                        (app_wdf_data               ),  // input [511:0]	app_wdf_data
        .app_wdf_end                         (app_wdf_end                ),  // input			app_wdf_end
        .app_wdf_wren                        (app_wdf_wren               ),  // input			app_wdf_wren
        .app_rd_data                         (app_rd_data                ),  // output [511:0]	app_rd_data
        .app_rd_data_end                     (app_rd_data_end            ),  // output			app_rd_data_end
        .app_rd_data_valid                   (app_rd_data_valid          ),  // output			app_rd_data_valid
        .app_rdy                             (app_rdy                    ),  // output			app_rdy
        .app_wdf_rdy                         (app_wdf_rdy                ),  // output			app_wdf_rdy
        .app_sr_req                          (1'b0                       ),  // input			app_sr_req
        .app_ref_req                         (1'b0                       ),  // input			app_ref_req
        .app_zq_req                          (1'b0                       ),  // input			app_zq_req
        .app_sr_active                       (                           ),  // output			app_sr_active
        .app_ref_ack                         (                           ),  // output			app_ref_ack
        .app_zq_ack                          (                           ),  // output			app_zq_ack
        .ui_clk                              (ui_clk                     ),  // output			ui_clk
        .ui_clk_sync_rst                     (ui_clk_sync_rst            ),  // output			ui_clk_sync_rst
        .app_wdf_mask                        (64'd0                      ),  // input [63:0]		app_wdf_mask
        // System Clock                          
        .sys_clk_i                           (sys_clk                    ),  // input			sys_clk_p  //clk_500m
        .clk_ref_i                           (clk_ref                    ),  // input			clk_ref_i  //clk_200m
        .device_temp                         (                           ),  // output [11:0]	device_temp
        .sys_rst                             (sys_rst_n                  )   // input 			sys_rst		Active Low
    );
*/

    
    ddr4_mig u_ddr4_mig( 
        .c0_init_calib_complete              (init_calib_complete        ),//(o)
        .dbg_clk                             (                           ),//(o)
        .c0_sys_clk_p                        (sys_clk_p                  ),//(i)
        .c0_sys_clk_n                        (sys_clk_n                  ),//(i)
        .dbg_bus                             (                           ),//(o)
        .c0_ddr4_adr                         (c0_ddr4_adr                ),//(o)
        .c0_ddr4_ba                          (c0_ddr4_ba                 ),//(o)
        .c0_ddr4_cke                         (c0_ddr4_cke                ),//(o)
        .c0_ddr4_cs_n                        (c0_ddr4_cs_n               ),//(o)
        .c0_ddr4_dm_dbi_n                    (c0_ddr4_dm_dbi_n           ),//(io)
        .c0_ddr4_dq                          (c0_ddr4_dq                 ),//(io)
        .c0_ddr4_dqs_c                       (c0_ddr4_dqs_c              ),//(io)
        .c0_ddr4_dqs_t                       (c0_ddr4_dqs_t              ),//(io)
        .c0_ddr4_odt                         (c0_ddr4_odt                ),//(o)
        .c0_ddr4_bg                          (c0_ddr4_bg                 ),//(o)
        .c0_ddr4_reset_n                     (c0_ddr4_reset_n            ),//(o)
        .c0_ddr4_act_n                       (c0_ddr4_act_n              ),//(o)
        .c0_ddr4_ck_c                        (c0_ddr4_ck_c               ),//(o)
        .c0_ddr4_ck_t                        (c0_ddr4_ck_t               ),//(o)
        .c0_ddr4_ui_clk                      (ui_clk                     ),//(o)
        .c0_ddr4_ui_clk_sync_rst             (ui_clk_sync_rst            ),//(o)
        .c0_ddr4_app_en                      (app_en                     ),//(i)
        .c0_ddr4_app_hi_pri                  (1'b0                       ),//(i)
        .c0_ddr4_app_wdf_end                 (app_wdf_end                ),//(i)
        .c0_ddr4_app_wdf_wren                (app_wdf_wren               ),//(i)
        .c0_ddr4_app_rd_data_end             (app_rd_data_end            ),//(o)
        .c0_ddr4_app_rd_data_valid           (app_rd_data_valid          ),//(o)
        .c0_ddr4_app_rdy                     (app_rdy                    ),//(o)
        .c0_ddr4_app_wdf_rdy                 (app_wdf_rdy                ),//(o)
        .c0_ddr4_app_addr                    (app_addr                   ),//(i)//[27:0]
        .c0_ddr4_app_cmd                     (app_cmd                    ),//(i)
        .c0_ddr4_app_wdf_data                (app_wdf_data               ),//(i)
        .c0_ddr4_app_wdf_mask                (64'd0                      ),//(i)
        .c0_ddr4_app_rd_data                 (app_rd_data                ),//(o)
        .sys_rst                             (~sys_rst_n                 ) //(i)
    );                                                                     

    assign      ddr_rst_n    =             ~ui_clk_sync_rst                   ;

end else begin
    ddr3_ram_model u_ddr3_ram_model(
       .app_addr                             (app_addr                   ), 
       .app_cmd                              (app_cmd                    ), 
       .app_en                               (app_en                     ), 
       .app_wdf_data                         (app_wdf_data               ), 
       .app_wdf_end                          (app_wdf_end                ), 
       .app_wdf_wren                         (app_wdf_wren               ), 
       .app_rd_data                          (app_rd_data                ),   
       .app_rd_data_valid                    (app_rd_data_valid          ), 
       .app_rdy                              (app_rdy                    ), 
       .app_wdf_rdy                          (app_wdf_rdy                ), 
                                           
       .clk                                  (ui_clk                     ), 
       .rst_n                                (sys_rst_n                  ),//just for sim
       .init_calib_complete                  (init_calib_complete        ) 
    );
    
    assign      ddr_rst_n    =                axi_rst_n                   ;

end
endgenerate
    



endmodule





