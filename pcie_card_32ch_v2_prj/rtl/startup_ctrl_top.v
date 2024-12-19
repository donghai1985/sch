

module startup_ctrl_top #(
    parameter                           DATA_WIDTH  = 16    ,
    parameter                           ADDR_WIDTH  = 27    
)(

    input                       aclk                           ,//(i) 
    input                       aresetn                        ,//(i) 
    input          [ 31:0]      s_axil_awaddr                  ,//(i) 
    input          [  2:0]      s_axil_awprot                  ,//(i) 
    input                       s_axil_awvalid                 ,//(i) 
    output                      s_axil_awready                 ,//(o) 
    input         [ 31:0]       s_axil_wdata                   ,//(i) 
    input         [  3:0]       s_axil_wstrb                   ,//(i) 
    input                       s_axil_wvalid                  ,//(i) 
    output                      s_axil_wready                  ,//(o) 
    output        [  1:0]       s_axil_bresp                   ,//(o) 
    output                      s_axil_bvalid                  ,//(o) 
    input                       s_axil_bready                  ,//(i) 
    input         [ 31:0]       s_axil_araddr                  ,//(i) 
    input         [  2:0]       s_axil_arprot                  ,//(i) 
    input                       s_axil_arvalid                 ,//(i) 
    output                      s_axil_arready                 ,//(o) 
    output        [ 31:0]       s_axil_rdata                   ,//(o) 
    output        [  1:0]       s_axil_rresp                   ,//(o) 
    output                      s_axil_rvalid                  ,//(o) 
    input                       s_axil_rready                  ,//(i) 

    input                       clk_125M                       ,//(i)
    input                       clk_125M_rst                   ,//(i)
    inout         [16-1:4]      FLASH_DATA                     ,//(i)
    output        [27-1:0]      FLASH_ADDR                     ,//(o)
    output                      FLASH_WE_B                     ,//(o)
    output                      FLASH_ADV_B                    ,//(o)
    output                      FLASH_OE_B                     ,//(o)
    output                      FLASH_CE_B                     ,//(o)
    input                       FLASH_WAIT                      //(i)
);


    wire                                pcie_clk_250m                           ;
    wire                                user_resetn                             ;
    wire        [16-1:0]                flash_data_i                            ;
    wire        [16-1:0]                flash_data_o                            ;
    wire                                flash_clk                               ;

    assign       pcie_clk_250m   =      aclk                                    ;
    assign       user_resetn     =      aresetn                                 ;


    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire                startup_rst       ;
    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire                startup_finish    ;
    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire  [16-1:0]      startup_finish_cnt;
    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire                startup_pack_vld  ;
    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire  [16-1:0]      startup_pack_cnt  ;
    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/reg                 startup_vld       ;
    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire  [32-1:0]      startup_data      ;
    /*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/wire  [2-1:0]       startup_ack       ;
    wire  [16-1:0]      startup_last_pack ;
    
    wire                erase_multiboot_pcie    ;
    wire                startup_rst_pcie        ;
    wire                startup_finish_pcie     ;
    wire  [16-1:0]      startup_finish_cnt_pcie ;
    wire                startup_pack_vld_pcie   ;
    wire  [16-1:0]      startup_pack_cnt_pcie   ;
    wire                startup_vld_pcie        ;
    wire  [32-1:0]      startup_data_pcie       ;
    wire                startup_ack_pcie        ;
    wire                startup_finish_ack_pcie ;
    
    wire                handshake_fifo_full     ;
    wire                handshake_fifo_empty    ;
    wire                handshake_fifo_rd_en    ;
    
    wire                erase_multiboot   ;
    wire                erase_ack         ;
    wire  [8-1:0]       erase_status_reg  ;
    wire                erase_finish      ;
    wire                erase_finish_pcie ;
    
    wire                flash_rd_start    ;
    wire                flash_rd_valid    ;
    wire  [16-1:0]      flash_rd_data     ;
    wire                flash_rd_start_pcie;



    myip_v1_0_S00_AXI myip_v1_0_S00_AXI(    
        .S_AXI_ACLK                 ( aclk                      ),
        .S_AXI_ARESETN              ( aresetn                   ),
        .S_AXI_AWADDR               ( s_axil_awaddr             ),
        .S_AXI_AWVALID              ( s_axil_awvalid            ),
        .S_AXI_AWREADY              ( s_axil_awready            ),
        .S_AXI_WDATA                ( s_axil_wdata              ),
        .S_AXI_WSTRB                ( s_axil_wstrb              ),
        .S_AXI_WVALID               ( s_axil_wvalid             ),
        .S_AXI_WREADY               ( s_axil_wready             ),
        .S_AXI_BRESP                ( s_axil_bresp              ),
        .S_AXI_BVALID               ( s_axil_bvalid             ),
        .S_AXI_BREADY               ( s_axil_bready             ),
        .S_AXI_ARADDR               ( s_axil_araddr             ),
        .S_AXI_ARVALID              ( s_axil_arvalid            ),
        .S_AXI_ARREADY              ( s_axil_arready            ),
        .S_AXI_RDATA                ( s_axil_rdata              ),
        .S_AXI_RRESP                ( s_axil_rresp              ),
        .S_AXI_RVALID               ( s_axil_rvalid             ),
        .S_AXI_RREADY               ( s_axil_rready             ),
        // .read_reg_0x0            ( read_reg_0x0              ),
        // .read_reg_0x4            ( read_reg_0x4              ),
        // .read_reg_0x8            ( read_reg_0x8              ),
        // .read_reg_0xc            ( read_reg_0xc              ),
        // .read_reg_0x10           ( read_reg_0x10             ),
        // .read_reg_0x14           ( read_reg_0x14             ),
        // .read_reg_0x18           ( read_reg_0x18             ),
        .read_reg_0x1c              (                           ),
        // .read_reg_0x24           ( read_reg_0x24             ),
        .read_reg_0x28              (                           ),

        // startup
        .erase_multiboot_o          ( erase_multiboot_pcie      ),
        .erase_finish_i             ( erase_finish_pcie         ),
        .startup_rst_o              ( startup_rst_pcie          ),
        .startup_finish_o           ( startup_finish_pcie       ),
        .startup_pack_finish_cnt_o  ( startup_finish_cnt_pcie   ),
        .startup_pack_vld_o         ( startup_pack_vld_pcie     ),
        .startup_pack_cnt_o         ( startup_pack_cnt_pcie     ),
        .startup_vld_o              ( startup_vld_pcie          ),
        .startup_data_o             ( startup_data_pcie         ),
        .read_flash_o               ( flash_rd_start_pcie       ),
        .startup_ack_i              ( startup_ack_pcie          ),
        .startup_finish_ack_i       ( startup_finish_ack_pcie   ),
    
        .in_reg0                    (  32'h00000001             ),//(i)
        .in_reg1                    (  32'h00000003             ),//(i)
        .in_reg2                    ( 'd0                       ),//(i)
        .in_reg3                    ( 'd0                       ),//(i)
        .in_reg4                    (  32'h22222222             ),//(i)
        .up_check_irq_i             ( 'd0                       ),//(i)
        .up_check_frame_i           ( 'd0                       ),//(i)
        .aurora_pmt_soft_err_i      ( 'd0                       ),//(i)
        .aurora_timing_soft_err_i   ( 'd0                       ),//(i)
        .pmt_overflow_cnt_i         ( 'd0                       ),//(i)
        .encode_overflow_cnt_i      ( 'd0                       ),//(i)
        .in_reg5                    ( 'd0                       ) //(i)
    );


    startup_ctrl_v2 #(
        .DATA_WIDTH                 ( 16                        ),
        .ADDR_WIDTH                 ( ADDR_WIDTH                ))
    startup_ctrl_inst (
        .clk_i                      ( clk_125M                  ), // 125MHz notice
        .rst_i                      ( clk_125M_rst              ),
 
        .startup_rst_i              ( startup_rst               ),
        .startup_finish_i           ( startup_finish            ),
        .startup_finish_cnt_i       ( startup_finish_cnt        ),
        .startup_i                  ( startup_pack_vld          ),
        .startup_pack_i             ( startup_pack_cnt          ),
        .startup_vld_i              ( startup_vld               ),
        .startup_data_i             ( startup_data              ),
        .startup_ack_o              ( startup_ack               ),
        .startup_last_pack_o        ( startup_last_pack         ),
    
        .erase_multiboot_i          ( erase_multiboot           ),
        .erase_ack_o                ( erase_ack                 ),
        .erase_status_reg_o         ( erase_status_reg          ),
        .erase_finish_o             ( erase_finish              ),
    
        .flash_rd_start_i           ( flash_rd_start            ),
        .flash_rd_valid_o           ( flash_rd_valid            ),
        .flash_rd_data_o            ( flash_rd_data             ),
    
        .flash_data_i               ( flash_data_i              ),
        .flash_data_o               ( flash_data_o              ),
        .flash_addr_o               ( FLASH_ADDR                ),
        .WAIT                       ( 1'b1/*FLASH_WAIT*/        ),
        .WE_B                       ( FLASH_WE_B                ),
        .ADV_B                      ( FLASH_ADV_B               ),
        .OE_B                       ( FLASH_OE_B                ),
        .CE_B                       ( FLASH_CE_B                ),
        .CLK                        ( flash_clk                 )
    );


    STARTUPE3 #(
        .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
        .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency (ns) for simulation.
     )
     STARTUPE3_inst (
        .CFGCLK(  ),       // 1-bit output: Configuration main clock output.
        .CFGMCLK(  ),     // 1-bit output: Configuration internal oscillator clock output.
        .DI(flash_data_i[3:0]),               // 4-bit output: Allow receiving on the D input pin.
        .EOS(  ),             // 1-bit output: Active-High output signal indicating the End Of Startup.
        .PREQ(  ),           // 1-bit output: PROGRAM request to fabric output.
        .DO(flash_data_o[3:0]),               // 4-bit input: Allows control of the D pin output.
        .DTS({~FLASH_OE_B,~FLASH_OE_B,~FLASH_OE_B,~FLASH_OE_B}),             // 4-bit input: Allows tristate of the D pin.
        .FCSBO(FLASH_CE_B),         // 1-bit input: Controls the FCS_B pin for flash access.
        .FCSBTS(0),       // 1-bit input: Tristate the FCS_B pin.
        .GSR(0),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port).
        .GTS(0),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name).
        .KEYCLEARB(1), // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM).
        .PACK(1),           // 1-bit input: PROGRAM acknowledge input.
        .USRCCLKO(flash_clk),   // 1-bit input: User CCLK input.
        .USRCCLKTS(0), // 1-bit input: User CCLK 3-state enable input.
        .USRDONEO(1),   // 1-bit input: User DONE pin output control.
        .USRDONETS(1)  // 1-bit input: User DONE 3-state enable output.
     );
    
    genvar  i;
    generate
        for(i=4;i<16;i=i+1)begin : FLASH_INFO
            assign flash_data_i[i] = FLASH_DATA[i];
            assign FLASH_DATA[i]   = FLASH_OE_B ? flash_data_o[i] : 1'bz;
        end
    endgenerate


    //----------------------------------------------------------------------------------------//


    handshake_fifo handshake_fifo_inst (
        .rst                        ( ~user_resetn              ),  // input wire rst
        .wr_clk                     ( pcie_clk_250m             ),  // input wire wr_clk
        .rd_clk                     ( clk_125M                  ),  // input wire rd_clk
        .din                        ( startup_data_pcie         ),  // input wire [127 : 0] din
        .wr_en                      ( startup_vld_pcie          ),  // input wire wr_en
        .rd_en                      ( handshake_fifo_rd_en      ),  // input wire rd_en
        .dout                       ( startup_data              ),  // output wire [127 : 0] dout
        .full                       ( handshake_fifo_full       ),  // output wire full
        .empty                      ( handshake_fifo_empty      )   // output wire empty
    );
    
    assign handshake_fifo_rd_en = (~handshake_fifo_empty);
    
    always @(posedge clk_125M) begin
        startup_vld <= handshake_fifo_rd_en;
    end
    
    // handshake #(
    //     .DATA_WIDTH                 ( 32                        )
    // )handshake_startup_data_inst(
    //     // clk & rst
    //     .src_clk_i                  ( pcie_clk_250m             ),
    //     .src_rst_i                  ( ~user_resetn              ),
    //     .dest_clk_i                 ( clk_125M                  ),
    //     .dest_rst_i                 ( clk_125M_rst              ),
        
    //     .src_data_i                 ( startup_data_pcie         ),
    //     .src_vld_i                  ( startup_vld_pcie          ),
    //     .dest_data_o                ( startup_data              ),
    //     .dest_vld_o                 ( startup_vld               )
    // );
    
    handshake #(
        .DATA_WIDTH                 ( 16                        )
    )handshake_startup_pack_cnt_inst(
        // clk & rst
        .src_clk_i                  ( pcie_clk_250m             ),
        .src_rst_i                  ( ~user_resetn              ),
        .dest_clk_i                 ( clk_125M                  ),
        .dest_rst_i                 ( clk_125M_rst              ),
        
        .src_data_i                 ( startup_pack_cnt_pcie     ),
        .src_vld_i                  ( startup_pack_vld_pcie     ),
        .dest_data_o                ( startup_pack_cnt          ),
        .dest_vld_o                 ( startup_pack_vld          )
    );
    
    handshake #(
        .DATA_WIDTH                 ( 16                        )
    )handshake_startup_finish_cnt_inst(
        // clk & rst
        .src_clk_i                  ( pcie_clk_250m             ),
        .src_rst_i                  ( ~user_resetn              ),
        .dest_clk_i                 ( clk_125M                  ),
        .dest_rst_i                 ( clk_125M_rst              ),
        
        .src_data_i                 ( startup_finish_cnt_pcie   ),
        .src_vld_i                  ( startup_finish_pcie       ),
        .dest_data_o                ( startup_finish_cnt        ),
        .dest_vld_o                 ( startup_finish            )
    );
    
    xpm_cdc_single #(
        .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
     )
     xpm_cdc_single_inst (
        .dest_out(erase_finish_pcie), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                             // registered.
    
        .dest_clk(pcie_clk_250m), // 1-bit input: Clock signal for the destination clock domain.
        .src_clk(clk_125M),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(erase_finish)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
     );
    
    xpm_cdc_single #(
        .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
     )
     xpm_startup_finish_ack_inst (
        .dest_out(startup_finish_ack_pcie), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                             // registered.
    
        .dest_clk(pcie_clk_250m), // 1-bit input: Clock signal for the destination clock domain.
        .src_clk(clk_125M),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(startup_ack[1])      // 1-bit input: Input signal to be synchronized to dest_clk domain.
     );
    
     xpm_cdc_single #(
        .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .SRC_INPUT_REG(0)   // DECIMAL; 0=do not register input, 1=register input
     )
     xpm_startup_ack_inst (
        .dest_out(startup_ack_pcie), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                             // registered.
    
        .dest_clk(pcie_clk_250m), // 1-bit input: Clock signal for the destination clock domain.
        .src_clk(clk_125M),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(startup_ack[0])      // 1-bit input: Input signal to be synchronized to dest_clk domain.
     );
    
    xpm_cdc_pulse #(
        .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
        .RST_USED(0),       // DECIMAL; 0=no reset, 1=implement reset
        .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
     )
     erase_multiboot_pulse_inst (
        .dest_pulse(erase_multiboot), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
                                 // transfer is correctly initiated on src_pulse input. This output is
                                 // combinatorial unless REG_OUTPUT is set to 1.
    
        .dest_clk(clk_125M),     // 1-bit input: Destination clock.
        .dest_rst(clk_125M_rst),     // 1-bit input: optional; required when RST_USED = 1
        .src_clk(pcie_clk_250m),       // 1-bit input: Source clock.
        .src_pulse(erase_multiboot_pcie),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
                                 // destination clock domain. The minimum gap between each pulse transfer must be
                                 // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
                                 // between the falling edge of a src_pulse to the rising edge of the next
                                 // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
                                 // will generate a pulse the size of one dest_clk period in the destination
                                 // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
                                 // src_rst and/or dest_rst are asserted.
    
        .src_rst(~user_resetn)        // 1-bit input: optional; required when RST_USED = 1
     );
    
     xpm_cdc_pulse #(
        .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
        .RST_USED(0),       // DECIMAL; 0=no reset, 1=implement reset
        .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
     )
     startup_rst_pulse_inst (
        .dest_pulse(startup_rst), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
                                 // transfer is correctly initiated on src_pulse input. This output is
                                 // combinatorial unless REG_OUTPUT is set to 1.
    
        .dest_clk(clk_125M),     // 1-bit input: Destination clock.
        .dest_rst(clk_125M_rst),     // 1-bit input: optional; required when RST_USED = 1
        .src_clk(pcie_clk_250m),       // 1-bit input: Source clock.
        .src_pulse(startup_rst_pcie),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
                                 // destination clock domain. The minimum gap between each pulse transfer must be
                                 // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
                                 // between the falling edge of a src_pulse to the rising edge of the next
                                 // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
                                 // will generate a pulse the size of one dest_clk period in the destination
                                 // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
                                 // src_rst and/or dest_rst are asserted.
    
        .src_rst(~user_resetn)        // 1-bit input: optional; required when RST_USED = 1
     );
    
     xpm_cdc_pulse #(
        .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
        .RST_USED(0),       // DECIMAL; 0=no reset, 1=implement reset
        .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
     )
     flash_rd_start_pulse_inst (
        .dest_pulse(flash_rd_start), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
                                 // transfer is correctly initiated on src_pulse input. This output is
                                 // combinatorial unless REG_OUTPUT is set to 1.
    
        .dest_clk(clk_125M),     // 1-bit input: Destination clock.
        .dest_rst(clk_125M_rst),     // 1-bit input: optional; required when RST_USED = 1
        .src_clk(pcie_clk_250m),       // 1-bit input: Source clock.
        .src_pulse(flash_rd_start_pcie),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
                                 // destination clock domain. The minimum gap between each pulse transfer must be
                                 // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
                                 // between the falling edge of a src_pulse to the rising edge of the next
                                 // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
                                 // will generate a pulse the size of one dest_clk period in the destination
                                 // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
                                 // src_rst and/or dest_rst are asserted.
    
        .src_rst(~user_resetn)        // 1-bit input: optional; required when RST_USED = 1
     );




















endmodule
