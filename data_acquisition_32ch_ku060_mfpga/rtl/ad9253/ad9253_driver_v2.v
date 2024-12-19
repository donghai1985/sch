module ad9253_driver_v2 #(
    parameter                               IODELAY_GROUP_NAME  =    "delay1"      
)(       
    input                                  sys_clk                                ,//(i) 100m
    input                                  sys_rst                                ,//(i)
    input                                  spi_wr_data_en                         ,//(i)
    input             [23:0]               spi_wr_data                            ,//(i)
    input                                  clk_200m                               ,//(i)
//  input                                  clk                                    ,//(i)
//  input                                  clk_div                                ,//(i)
    input                                  mmcm_clk_div                           ,//(i)

    input                                  sync_in                                ,//(i)
    input                                  idelay_rdy                             ,//(i)
    output                                 adc_0_data_clk                         ,//(o)
    output            [15:0]               adc_0_a_data                           ,//(o)
    output            [15:0]               adc_0_b_data                           ,//(o)
    output            [15:0]               adc_0_c_data                           ,//(o)
    output            [15:0]               adc_0_d_data                           ,//(o)
    output            [31:0]               pat_err_cnt                            ,//(o)

    input                                  ADC_0_D0_A_P                           ,//(i)
    input                                  ADC_0_D0_A_N                           ,//(i)
    input                                  ADC_0_D1_A_P                           ,//(i)
    input                                  ADC_0_D1_A_N                           ,//(i)
    input                                  ADC_0_D0_B_P                           ,//(i)
    input                                  ADC_0_D0_B_N                           ,//(i)
    input                                  ADC_0_D1_B_P                           ,//(i)
    input                                  ADC_0_D1_B_N                           ,//(i)
    input                                  ADC_0_D0_C_P                           ,//(i)
    input                                  ADC_0_D0_C_N                           ,//(i)
    input                                  ADC_0_D1_C_P                           ,//(i)
    input                                  ADC_0_D1_C_N                           ,//(i)
    input                                  ADC_0_D0_D_P                           ,//(i)
    input                                  ADC_0_D0_D_N                           ,//(i)
    input                                  ADC_0_D1_D_P                           ,//(i)
    input                                  ADC_0_D1_D_N                           ,//(i)
    input                                  ADC_0_FCO_P                            ,//(i)
    input                                  ADC_0_FCO_N                            ,//(i)
    input                                  ADC_0_DCO_P                            ,//(i)
    input                                  ADC_0_DCO_N                            ,//(i)
    output                                 ADC_0_SPI_CLK                          ,//(o)
    inout                                  ADC_0_SPI_SDIO                         ,//(i)
    output                                 ADC_0_SPI_CSB                          ,//(o)
    output                                 ADC_0_SYNC                             ,//(o)
    output                                 ADC_0_PDWN                              //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    //localparam                             IDLE     =    4'h00                    ;

    //---------------------------------------------------------------------       
    // Defination of Internal Signals       
    //---------------------------------------------------------------------       
    genvar                                 gi                                     ;
    wire                                   clk_div                                ;
    wire                                   fifo_empty                             ; 
    wire              [63:0]               fifo_dout                              ;
    wire              [8 :0]               adc_0_sin                              ;
    wire              [8 :0]               adc_0_sin_dly                          ;
    wire              [7 :0]               adc_0_pout     [8:0]                   ;
    reg               [7 :0]               adc_0_pout_d1  [8:0]                   ;
    wire              [7 :0]               adc_0_pout_flip[8:0]                   ;
    wire              [7 :0]               adc_0_pout_slip[8:0]                   ;
    wire                                   ADC_0_D0_A                             ;
    wire                                   ADC_0_D1_A                             ;
    wire                                   ADC_0_D0_B                             ;
    wire                                   ADC_0_D1_B                             ;
    wire                                   ADC_0_D0_C                             ;
    wire                                   ADC_0_D1_C                             ;
    wire                                   ADC_0_D0_D                             ;
    wire                                   ADC_0_D1_D                             ;
    wire                                   ADC_0_FCO                              ;
    wire                                   ADC_0_DCO                              ;//adc_0_dc_clk
    reg                                    train_cpl_d1                           ;
    reg                                    train_cpl_d2                           ;
    wire                                   train_cpl_pos                          ;
    wire                                   train_cpl_neg                          ;
    reg                                    tmp_spi_wr_data_en                     ;
    reg             [23:0]                 tmp_spi_wr_data                        ;
    wire                                   adc_0_dc_dly                           ;
    wire              [7 :0]               adc_0_dc_dly_pout                      ;
    wire              [7 :0]               adc_0_allign_word                      ;
    wire                                   adc_config_ok                          ;
    wire                                   en_vtc                                 ;
    wire              [8 :0]               adc_0_delay_cnt                        ;//vio [8:0]
    wire              [8 :0]               adc_0_ctrl_cnt                         ;//    [8:0]
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire                                   adc_0_bit_slip                         ;
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire              [7 :0]               adc_0_fc_patten                        ;
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire              [7 :0]               adc_0_fc_patten_slip                   ;
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire              [15:0]               adc_0_a_slip                           ;
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire              [15:0]               adc_0_b_slip                           ;
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire              [15:0]               adc_0_c_slip                           ;
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire              [15:0]               adc_0_d_slip                           ;
    wire            [15:0]                 adc_0_a_data_if                        ;
    wire            [15:0]                 adc_0_b_data_if                        ;
    wire            [15:0]                 adc_0_c_data_if                        ;
    wire            [15:0]                 adc_0_d_data_if                        ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            adc_0_data_clk  =    clk_div                                ;
    assign            adc_0_allign_word   = adc_0_dc_dly_pout                     ;//no need bitslip
    assign            adc_0_fc_patten     = adc_0_pout[8]                         ; 
    assign            adc_0_fc_patten_slip= adc_0_pout_slip[8]                    ; 
    assign            adc_0_a_slip    =    {adc_0_pout_slip[7],adc_0_pout_slip[6]};
    assign            adc_0_b_slip    =    {adc_0_pout_slip[5],adc_0_pout_slip[4]};
    assign            adc_0_c_slip    =    {adc_0_pout_slip[3],adc_0_pout_slip[2]};
    assign            adc_0_d_slip    =    {adc_0_pout_slip[1],adc_0_pout_slip[0]};
    assign            adc_0_a_data    =    {fifo_dout[15:0]}              ;
    assign            adc_0_b_data    =    {fifo_dout[31:16]}             ;
    assign            adc_0_c_data    =    {fifo_dout[47:32]}             ;
    assign            adc_0_d_data    =    {fifo_dout[63:48]}             ;
    assign            adc_0_a_data_if  =    {adc_0_a_slip[1:0],adc_0_a_slip[15:2]}             ;
    assign            adc_0_b_data_if  =    {adc_0_a_slip[1:0],adc_0_b_slip[15:2]}             ;
    assign            adc_0_c_data_if  =    {adc_0_a_slip[1:0],adc_0_c_slip[15:2]}             ;
    assign            adc_0_d_data_if  =    {adc_0_a_slip[1:0],adc_0_d_slip[15:2]}             ;
    assign            adc_0_sin       =    {ADC_0_FCO,ADC_0_D1_A,ADC_0_D0_A,ADC_0_D1_B,ADC_0_D0_B,ADC_0_D1_C,ADC_0_D0_C,ADC_0_D1_D,ADC_0_D0_D};

// =================================================================================================
// RTL Body
// =================================================================================================

    // -------------------------------------------------------------------------
    // IBUFDS Module Inst.
    // -------------------------------------------------------------------------
    IBUFDS IBUFDS_inst0(
        .O (ADC_0_D0_A  ),// 1-bit output: Buffer output
        .I (ADC_0_D0_A_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_D0_A_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS IBUFDS_inst1(
        .O (ADC_0_D1_A  ),// 1-bit output: Buffer output
        .I (ADC_0_D1_A_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_D1_A_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS IBUFDS_inst2(
        .O (ADC_0_D0_B  ),// 1-bit output: Buffer output
        .I (ADC_0_D0_B_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_D0_B_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS IBUFDS_inst3(
        .O (ADC_0_D1_B  ),// 1-bit output: Buffer output
        .I (ADC_0_D1_B_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_D1_B_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS IBUFDS_inst4(
        .O (ADC_0_D0_C  ),// 1-bit output: Buffer output
        .I (ADC_0_D0_C_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_D0_C_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS IBUFDS_inst5(
        .O (ADC_0_D1_C  ),// 1-bit output: Buffer output
        .I (ADC_0_D1_C_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_D1_C_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS IBUFDS_inst6(
        .O (ADC_0_D0_D  ),// 1-bit output: Buffer output
        .I (ADC_0_D0_D_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_D0_D_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS IBUFDS_inst7(
        .O (ADC_0_D1_D  ),// 1-bit output: Buffer output
        .I (ADC_0_D1_D_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_D1_D_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS IBUFDS_inst8(
        .O (ADC_0_FCO  ),// 1-bit output: Buffer output
        .I (ADC_0_FCO_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_FCO_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    IBUFDS IBUFDS_inst9(
        .O (ADC_0_DCO  ),// 1-bit output: Buffer output
        .I (ADC_0_DCO_P),// 1-bit input: Diff_p buffer input (connect directly to top-level port)
        .IB(ADC_0_DCO_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    // -------------------------------------------------------------------------
    // BUFG/BUFGCE_DIV_inst Module Inst.   ADC_0_DCO
    // -------------------------------------------------------------------------
    BUFG BUFG_inst(
        .O(clk      ), // 1-bit output: Clock output.
        .I(ADC_0_DCO)  // 1-bit input: Clock input.
     );

     BUFGCE_DIV #(
        .BUFGCE_DIVIDE(4),         // 1-8
        .IS_CE_INVERTED(1'b0),     // Optional inversion for CE
        .IS_CLR_INVERTED(1'b0),    // Optional inversion for CLR
        .IS_I_INVERTED(1'b0),      // Optional inversion for I
        .SIM_DEVICE("ULTRASCALE")  // ULTRASCALE
     )
     BUFGCE_DIV_inst (
        .O  (clk_div      ),     // 1-bit output: Buffer
        .CE (1'b1         ),     // 1-bit input: Buffer enable
        .CLR(1'b0         ),     // 1-bit input: Asynchronous clear
        .I  (ADC_0_DCO    )      // 1-bit input: Buffer
     );
    // -------------------------------------------------------------------------------------------------------
    // IDELAYE3 ISERDESE3 BitSlipInLogic Module Inst.  ADC_0_FCO  ADC_0_D0_A-D ADC_0_D1_A-D  adc_0_sin
    // -------------------------------------------------------------------------------------------------------
generate for(gi=0;gi<9;gi=gi+1)begin

    (* IODELAY_GROUP = IODELAY_GROUP_NAME *)
    IDELAYE3 #(
        .CASCADE("NONE"),          // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
        .DELAY_FORMAT("COUNT"),     // Units of the DELAY_VALUE (COUNT, TIME)
        .DELAY_SRC("IDATAIN"),     // Delay input (DATAIN, IDATAIN)
        .DELAY_TYPE("VAR_LOAD"),      // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
        .DELAY_VALUE(0),           // Input delay value setting
        .IS_CLK_INVERTED(1'b0),    // Optional inversion for CLK
        .IS_RST_INVERTED(1'b0),    // Optional inversion for RST
        .REFCLK_FREQUENCY(200.0),  // IDELAYCTRL clock input frequency in MHz (200.0-800.0)
        .SIM_DEVICE("ULTRASCALE"), // Set the device version for simulation functionality (ULTRASCALE)
        .UPDATE_MODE("ASYNC")      // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
     )IDELAYE3_inst (
        .CASC_OUT(),                   // 1-bit output: Cascade delay output to ODELAY input cascade
        .CNTVALUEOUT(),                // 9-bit output: Counter value output
        .DATAOUT(adc_0_sin_dly[gi]),    // 1-bit output: Delayed data output
        .CASC_IN(1'b0),                // 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
        .CASC_RETURN(1'b0),            // 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
        .CE(1'b0),                     // 1-bit input: Active-High enable increment/decrement input
        .CLK(clk_div),            // 1-bit input: Clock input
        .CNTVALUEIN(adc_0_delay_cnt + adc_0_ctrl_cnt),  // 9-bit input: Counter value input
        .DATAIN(1'b0),                 // 1-bit input: Data input from the logic
        .EN_VTC(1'b0),                 // 1-bit input: Keep delay constant over VT
        .IDATAIN(adc_0_sin[gi]),           // 1-bit input: Data input from the IOBUF
        .INC (1'b0),                   // 1-bit input: Increment / Decrement tap delay input
        .LOAD(1'b1),                   // 1-bit input: Load DELAY_VALUE input
        .RST (~adc_config_ok)                    // 1-bit input: Asynchronous Reset to the DELAY_VALUE
    );
    
    ISERDESE3 #(
        .DATA_WIDTH(8),            // Parallel data width (4,8)
        .FIFO_ENABLE("FALSE"),     // Enables the use of the FIFO
        .FIFO_SYNC_MODE("FALSE"),  // Always set to FALSE. TRUE is reserved for later use.
        .IS_CLK_B_INVERTED(1'b0),  // Optional inversion for CLK_B
        .IS_CLK_INVERTED(1'b0),    // Optional inversion for CLK
        .IS_RST_INVERTED(1'b0),    // Optional inversion for RST
        .SIM_DEVICE("ULTRASCALE")  // Set the device version for simulation functionality (ULTRASCALE)
    )ISERDESE3_inst1(
        .FIFO_EMPTY(),             // 1-bit output: FIFO empty flag
        .INTERNAL_DIVCLK(), // 1-bit output: Internally divided down clock used when FIFO is disabled (do not connect)
        .Q     (adc_0_pout[gi]   ),        // 8-bit registered output
        .CLK   (clk              ),        // 1-bit input: High-speed clock
        .CLKDIV(clk_div          ),        // 1-bit input: Divided Clock
        .CLK_B (~clk             ),        // 1-bit input: Inversion of High-speed clock CLK
        .D     (adc_0_sin_dly[gi]),        // 1-bit input: Serial Data Input
        .FIFO_RD_CLK(1'b0        ),        // 1-bit input: FIFO read clock
        .FIFO_RD_EN (1'b0        ),        // 1-bit input: Enables reading the FIFO when asserted
        .RST   (~adc_config_ok   )         // 1-bit input: Asynchronous Reset
    );


    always@(posedge clk_div)  // improve timing.
        adc_0_pout_d1[gi] <= adc_0_pout[gi];


    assign    adc_0_pout_flip[gi]   =  bit_flip(adc_0_pout_d1[gi]);

    bitslip #(                                  
        .DATA_WD         (8                    )       
    )u_bitslip( 
        .clk             (clk_div              ),//(i)
        .rst_n           (adc_config_ok        ),//(i)
        .slip            (adc_0_bit_slip       ),//(i)
        .din             (adc_0_pout_flip[gi]  ),//(i)
        .dout            (adc_0_pout_slip[gi]  ) //(o)
    );                                         

end
endgenerate


    adc_cross_fifo u_adc_cross_fifo (
        .rst        (~adc_config_ok   ),      
        .wr_clk     (clk_div          ),      
        .rd_clk     (mmcm_clk_div     ),      
        .din        ({adc_0_d_data_if,adc_0_c_data_if,adc_0_b_data_if,adc_0_a_data_if}),      
        .wr_en      (train_cpl        ),      
        .rd_en      (~fifo_empty      ),      
        .dout       (fifo_dout        ),      
        .full       (                 ),      
        .empty      (fifo_empty       )
    );


    // -------------------------------------------------------------------------
    // ad9253_allign_ctrl  Module Inst.
    // -------------------------------------------------------------------------
    wire             err_vld;
    wire    [15:0]   err_cnt;
    assign           err_vld  =   ((adc_0_a_data_if != 16'h1555) && (adc_0_a_data_if != 16'h2aaa)) || 
                                  ((adc_0_b_data_if != 16'h1555) && (adc_0_b_data_if != 16'h2aaa)) || 
                                  ((adc_0_c_data_if != 16'h1555) && (adc_0_c_data_if != 16'h2aaa)) || 
                                  ((adc_0_d_data_if != 16'h1555) && (adc_0_d_data_if != 16'h2aaa))  ;


    cmip_app_cnt #(
        .width         (16                )
    )u0_app_cnt(                        
        .clk           (clk_div           ),//(i)
        .rst_n         (1'b1              ),//(i)
        .clr           (~adc_config_ok    ),//(i)
        .vld           (err_vld           ),//(i)
        .cnt           (err_cnt           ) //(o)
    );
/*
    vio_ad9253 u_vio_ad9253 (
        .clk           (clk_div               ),// input wire clk
        .probe_in0     (err_cnt               ),// input wire [7 : 0] probe_in0
        .probe_in1     (adc_0_fc_patten_slip  ),// input wire [7 : 0] probe_in1
        .probe_in2     (adc_0_ctrl_cnt        ),// input wire [8 : 0] probe_in2
        .probe_in3     (adc_0_fc_patten       ),// input wire [7 : 0] probe_in3
        .probe_out0    (adc_0_delay_cnt       ) // output wire [8 : 0] probe_out0
    );
*/
    ad9253_allign_ctrl u_ad9253_allign_ctrl( 
        .sys_clk       (sys_clk               ),
        .clk           (clk_div               ),//(i)
        .rst_n         (1'b0                  ),//(i)
        .cfg_rdy       (adc_config_ok         ),//(i)
        .vio_dly_cnt   (adc_0_delay_cnt       ),//(i)
        .err_cnt       (err_cnt               ),//(i)
        .fc_patten     (adc_0_fc_patten_slip  ),//(i)
        .bit_slip      (adc_0_bit_slip        ),//(o)
        .ctrl_cnt_imp  (adc_0_ctrl_cnt        ),//(o)
        .train_cpl     (train_cpl             ),//(o)
        .en_vtc        (en_vtc                ),//(o)
        .pat_err_cnt   (pat_err_cnt           )
    );                                         
    
    
    


    // -------------------------------------------------------------------------
    // ad9253_config  Module Inst.
    // -------------------------------------------------------------------------
    ad9253_config u_ad9253_config(
        .clk           (sys_clk               ),
        .rst           (sys_rst               ),
        .sync_in       (sync_in               ),
        .wr_data_en    (tmp_spi_wr_data_en    ),
        .wr_data       (tmp_spi_wr_data       ),
        .spi_csn       (ADC_0_SPI_CSB         ),
        .spi_clk       (ADC_0_SPI_CLK         ),
        .spi_data      (ADC_0_SPI_SDIO        ),
        .adc_sync      (ADC_0_SYNC            ),
        .adc_pdwn      (ADC_0_PDWN            ),
        .adc_config_ok (adc_config_ok         )
    );


    always@(posedge sys_clk or posedge sys_rst)
        if(sys_rst)begin
            train_cpl_d1 <= 1'b0;
            train_cpl_d2 <= 1'b0;
        end else begin
            train_cpl_d1 <= train_cpl;
            train_cpl_d2 <= train_cpl_d1;
        end

    assign      train_cpl_pos   =   ~train_cpl_d2 && train_cpl_d1             ;
    assign      train_cpl_neg   =   ~train_cpl_d1 && train_cpl_d2             ;

    always@(posedge sys_clk or posedge sys_rst)
        if(sys_rst)begin
             tmp_spi_wr_data_en <= 'd0;
             tmp_spi_wr_data    <= 'd0;
        end else if(train_cpl_neg)begin
             tmp_spi_wr_data_en <= 1'd1;
             tmp_spi_wr_data    <= 24'h000d04;
        end else if(train_cpl_pos)begin
             tmp_spi_wr_data_en <= 1'd1;
             tmp_spi_wr_data    <= 24'h000d00;
        end else if(spi_wr_data_en)begin
             tmp_spi_wr_data_en <= 1'd1;
             tmp_spi_wr_data    <= spi_wr_data;
        end else begin
             tmp_spi_wr_data_en <= 'd0;
             tmp_spi_wr_data    <= tmp_spi_wr_data;
        end



//------------------------------------------------------------------------//
    function automatic [7:0]  bit_flip(
        input   [7:0]     in  
    );
        bit_flip = {in[0],in[1],in[2],in[3],in[4],in[5],in[6],in[7]};
    endfunction




endmodule





















































