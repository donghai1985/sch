module sfpga_inf_top #(
    parameter                               SIM                 =    1          
)(
    input                                   clk_100m                       ,//(i)
    input                                   rst_100m                       ,//(i)
    
    input                                   sfpga_rst                      ,//(i)
    output              [31:0]              fir_tap_vld_cnt                ,//(o)
    output    reg       [15:0]              bias_tap_vld_cnt               ,//(o)

    output              [32-1:0]            ddr_rd_addr                    ,//(o)
    output                                  ddr_rd_en                      ,//(o)
    input                                   readback_vld                   ,//(i)
    input                                   readback_last                  ,//(i)
    input               [32-1:0]            readback_data                  ,//(i)
                                                                                
    output                                  fir_tap_wr_cmd                 ,//(o)
    output              [32-1:0]            fir_tap_wr_addr                ,//(o)
    output                                  fir_tap_wr_vld                 ,//(o)
    output              [32-1:0]            fir_tap_wr_data                ,//(o)

    output                                  bias_tap_wr_cmd                ,//(o)
    output              [32-1:0]            bias_tap_wr_addr               ,//(o)
    output                                  bias_tap_wr_vld                ,//(o)
    output              [32-1:0]            bias_tap_wr_data               ,//(o)

    input                                   SLAVE_MSG_CLK                  ,//(i)
    output                                  SLAVE_MSG_TX_FSX               ,//(o)
    output                                  SLAVE_MSG_TX                   ,//(o)
    input                                   SLAVE_MSG_RX_FSX               ,//(i)
    input                                   SLAVE_MSG_RX                    //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    //parameter                               MAX_CNT              =    32               ;

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    slave_tx_ack                   ;
    wire                                    slave_tx_byte_en               ;
    wire                [ 7:0]              slave_tx_byte                  ;
    wire                                    slave_tx_byte_num_en           ;
    wire                [15:0]              slave_tx_byte_num              ;
    wire                                    slave_rx_data_vld              ;
    wire                [ 7:0]              slave_rx_data                  ;

    reg                                     ch_sel                   = 'd0 ;
    wire                                    tmp_fir_tap_wr_cmd             ;
    wire                [32-1:0]            tmp_fir_tap_wr_addr            ;
    wire                                    tmp_fir_tap_wr_vld             ;
    wire                [32-1:0]            tmp_fir_tap_wr_data            ;
    reg                                     tmp_fir_tap_wr_cmd_d1    = 'd0 ;
    reg                 [32-1:0]            tmp_fir_tap_wr_addr_d1   = 'd0 ;
    reg                                     tmp_fir_tap_wr_vld_d1    = 'd0 ;
    reg                 [32-1:0]            tmp_fir_tap_wr_data_d1   = 'd0 ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg                                     tmp_fir_tap_wr_cmd_d2    = 'd0 ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg                 [32-1:0]            tmp_fir_tap_wr_addr_d2   = 'd0 ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg                                     tmp_fir_tap_wr_vld_d2    = 'd0 ;
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)reg                 [32-1:0]            tmp_fir_tap_wr_data_d2   = 'd0 ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign        fir_tap_wr_cmd    = (ch_sel == 1'b0) ?  tmp_fir_tap_wr_cmd_d2  : 'd0;
    assign        fir_tap_wr_addr   = (ch_sel == 1'b0) ?  tmp_fir_tap_wr_addr_d2 : 'd0;
    assign        fir_tap_wr_vld    = (ch_sel == 1'b0) ?  tmp_fir_tap_wr_vld_d2  : 'd0;
    assign        fir_tap_wr_data   = (ch_sel == 1'b0) ?  tmp_fir_tap_wr_data_d2 : 'd0;

    assign        bias_tap_wr_cmd   = (ch_sel == 1'b1) ?  tmp_fir_tap_wr_cmd_d2  : 'd0;
    assign        bias_tap_wr_addr  = (ch_sel == 1'b1) ?  tmp_fir_tap_wr_addr_d2 : 'd0;
    assign        bias_tap_wr_vld   = (ch_sel == 1'b1) ?  tmp_fir_tap_wr_vld_d2  : 'd0;
    assign        bias_tap_wr_data  = (ch_sel == 1'b1) ?  tmp_fir_tap_wr_data_d2 : 'd0;

// =================================================================================================
// RTL Body
// =================================================================================================


    slave_comm slave_comm_inst(
        // clk & rst
        .clk_sys_i                      ( clk_100m                          ),
        .rst_i                          ( rst_100m                          ),
        // salve tx info
        .slave_tx_en_i                  ( slave_tx_byte_en                  ),
        .slave_tx_data_i                ( slave_tx_byte                     ),
        .slave_tx_byte_num_en_i         ( slave_tx_byte_num_en              ),
        .slave_tx_byte_num_i            ( slave_tx_byte_num                 ),
        .slave_tx_ack_o                 ( slave_tx_ack                      ),
        // slave rx info
        .rd_data_vld_o                  ( slave_rx_data_vld                 ),
        .rd_data_o                      ( slave_rx_data                     ),
        // info
        .SLAVE_MSG_CLK                  ( SLAVE_MSG_CLK                     ),
        .SLAVE_MSG_TX_FSX               ( SLAVE_MSG_TX_FSX                  ),
        .SLAVE_MSG_TX                   ( SLAVE_MSG_TX                      ),
        .SLAVE_MSG_RX_FSX               ( SLAVE_MSG_RX_FSX                  ),
        .SLAVE_MSG_RX                   ( SLAVE_MSG_RX                      )
    );
    
generate if(SIM == 0)begin
    command_map command_map_inst(
        .clk_sys_i                      ( clk_100m                          ),
        .rst_i                          ( rst_100m                          ),
        .slave_rx_data_vld_i            ( slave_rx_data_vld                 ),
        .slave_rx_data_i                ( slave_rx_data                     ),
    
        .ddr_rd_addr_o                  ( ddr_rd_addr                       ),
        .ddr_rd_en_o                    ( ddr_rd_en                         ),
        .fir_tap_wr_cmd_o               ( tmp_fir_tap_wr_cmd                    ),
        .fir_tap_wr_addr_o              ( tmp_fir_tap_wr_addr                   ),
        .fir_tap_wr_vld_o               ( tmp_fir_tap_wr_vld                    ),
        .fir_tap_wr_data_o              ( tmp_fir_tap_wr_data                   ),
    
        .acc_track_para_wr_o            (                                   ),
        .acc_track_para_addr_o          (                                   ),
        .acc_track_para_data_o          (                                   ),
    
        .debug_info                     (                                   )
    );

end else begin
    command_map_sim  u_command_map_sim(
        .clk                            (clk_100m                           ),//(i)
        .rst_n                          (~rst_100m                          ),//(i)

        .ddr_rd_addr_o                  (ddr_rd_addr                        ),//(o)
        .ddr_rd_en_o                    (ddr_rd_en                          ),//(o)
        .fir_tap_wr_cmd_o               (tmp_fir_tap_wr_cmd                     ),//(o)
        .fir_tap_wr_addr_o              (tmp_fir_tap_wr_addr                    ),//(o)
        .fir_tap_wr_vld_o               (tmp_fir_tap_wr_vld                     ),//(o)
        .fir_tap_wr_data_o              (tmp_fir_tap_wr_data                    ) //(o)
    );
    
end
endgenerate
    // mfpga to mainPC message arbitrate 
    arbitrate_bpsi arbitrate_bpsi_inst(
        .clk_i                          ( clk_100m                          ),
        .rst_i                          ( rst_100m                          ),
                                                                             
        .readback_vld_i                 ( readback_vld                      ), // laser uart
        .readback_last_i                ( readback_last                     ), // laser uart
        .readback_data_i                ( readback_data                     ), // laser uart
                                                                             
        .slave_tx_ack_i                 ( slave_tx_ack                      ),
        .slave_tx_byte_en_o             ( slave_tx_byte_en                  ),
        .slave_tx_byte_o                ( slave_tx_byte                     ),
        .slave_tx_byte_num_en_o         ( slave_tx_byte_num_en              ),
        .slave_tx_byte_num_o            ( slave_tx_byte_num                 )
    );

    always@(posedge clk_100m)begin
        tmp_fir_tap_wr_cmd_d1  <= tmp_fir_tap_wr_cmd     ;
        tmp_fir_tap_wr_addr_d1 <= tmp_fir_tap_wr_addr    ;
        tmp_fir_tap_wr_vld_d1  <= tmp_fir_tap_wr_vld     ;
        tmp_fir_tap_wr_data_d1 <= tmp_fir_tap_wr_data    ;
        tmp_fir_tap_wr_cmd_d2  <= tmp_fir_tap_wr_cmd_d1  ;
        tmp_fir_tap_wr_addr_d2 <= tmp_fir_tap_wr_addr_d1 ;
        tmp_fir_tap_wr_vld_d2  <= tmp_fir_tap_wr_vld_d1  ;
        tmp_fir_tap_wr_data_d2 <= tmp_fir_tap_wr_data_d1 ;
    end 

    always@(posedge clk_100m)begin
        if(~tmp_fir_tap_wr_cmd_d2 && tmp_fir_tap_wr_cmd_d1 && (tmp_fir_tap_wr_addr == 32'hFFFF0000))
            ch_sel <= 1'b1;
        else if(~tmp_fir_tap_wr_cmd_d2 && tmp_fir_tap_wr_cmd_d1 && (tmp_fir_tap_wr_addr != 32'hFFFF0000))
            ch_sel <= 1'b0;
    end 
    



    sfpga_udp_chk u0_sfpga_udp_chk(
        .clk_100m                  (clk_100m            ),//(i)
        .rst_100m                  (rst_100m            ),//(i)
        .sfpga_rst                 (sfpga_rst           ),//(i)
        .cfg_clr                   (1'b0                ),//(i)
        .tap_wr_cmd                (fir_tap_wr_cmd      ),//(o)
        .tap_wr_addr               (fir_tap_wr_addr     ),//(o)
        .tap_wr_vld                (fir_tap_wr_vld      ),//(o)
        .tap_wr_data               (fir_tap_wr_data     ),//(o)
        .tap_vld_cnt               (fir_tap_vld_cnt     ) //(o)
    );


    always@(posedge clk_100m or posedge rst_100m)begin
        if(rst_100m)
            bias_tap_vld_cnt <= 'd0;
        else if(sfpga_rst)
            bias_tap_vld_cnt <= 'd0;
        else if(~tmp_fir_tap_wr_cmd_d2 && tmp_fir_tap_wr_cmd_d1 && (tmp_fir_tap_wr_addr == 32'hFFFF0000))
            bias_tap_vld_cnt <= bias_tap_vld_cnt + 1'b1;
    end





endmodule





