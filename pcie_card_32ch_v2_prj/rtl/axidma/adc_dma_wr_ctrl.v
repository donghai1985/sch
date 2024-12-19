
module adc_dma_wr_ctrl #(
    parameter                               LEN_WDTH       =  32           ,
    parameter                               DATA_WDTH      =  32           ,
    parameter                               ADDR_WDTH      =  32           ,
    parameter                               AXI_BASE_ADDR  =  32'h90000000 
)(
    input                                   sys_clk                        ,//(i)
    input                                   sys_rst_n                      ,//(i)

    input                                   cfg_rs                         ,//(i)
    input                                   cfg_mode                       ,//(i)
    input                                   cfg_rst                        ,//(i)
    input             [LEN_WDTH -1:0]       cfg_size                       ,//(i)
    output                                  sts_blk_num                    ,//(o)
    output            [LEN_WDTH -1:0]       sts_send_times                 ,//(o)

    output                                  cfg_wsoft_rst                  ,//(i)
    output                                  cfg_wstart                     ,//(i)
    output            [ADDR_WDTH-1:0]       cfg_waddr                      ,//(i)
    output            [LEN_WDTH -1:0]       cfg_wlen                       ,//(i)
    input                                   cfg_widle                       //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------   
    localparam                              IDLE      =     4'h0           ;
    localparam                              WR1       =     4'h1           ;
    localparam                              WR2       =     4'h2           ;
    localparam                              WAIT      =     4'h4           ;

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg               [3:0]                 sta                            ;
    wire                                    run_trig                       ;
    wire                                    cfg_widle_pos                  ;
    wire                                    sta_wr1_pos                    ;
    wire                                    sta_wr2_pos                    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            cfg_wsoft_rst     =   cfg_rst                        ;
    assign            cfg_wstart        =   sta_wr1_pos || sta_wr2_pos     ;
    assign            cfg_wlen          =   cfg_size                       ;
    assign            sts_blk_num       =   (sta == WR2)                   ;
    assign            cfg_waddr         =   sts_blk_num ? (AXI_BASE_ADDR + 32'h10000000) : AXI_BASE_ADDR;
// =================================================================================================
// RTL Body
// =================================================================================================


    // -------------------------------------------------------------------------
    // cmip_edge_sync Module Inst.
    // -------------------------------------------------------------------------
    cmip_edge_sync #(
        .RISE      (1),
        .PIPELINE  (2)
    )u0_cmip_edge_sync(                          
        .i_clk     (sys_clk       ),  
        .i_rst_n   (sys_rst_n     ),  
        .i_sig     (cfg_rs        ), 
        .o_edge    (run_trig      )  
    );

    cmip_edge_sync #(
        .RISE      (1),
        .PIPELINE  (2)
    )u1_cmip_edge_sync(                          
        .i_clk     (sys_clk       ),  
        .i_rst_n   (sys_rst_n     ),  
        .i_sig     (cfg_widle     ), 
        .o_edge    (cfg_widle_pos )  
    );

    cmip_edge_sync #(
        .RISE      (1),
        .PIPELINE  (2)
    )u2_cmip_edge_sync(                          
        .i_clk     (sys_clk       ),  
        .i_rst_n   (sys_rst_n     ),  
        .i_sig     ((sta==WR1)    ), 
        .o_edge    (sta_wr1_pos   )  
    );

    cmip_edge_sync #(
        .RISE      (1),
        .PIPELINE  (2)
    )u3_cmip_edge_sync(                          
        .i_clk     (sys_clk       ),  
        .i_rst_n   (sys_rst_n     ),  
        .i_sig     ((sta==WR2)    ), 
        .o_edge    (sta_wr2_pos   )  
    );

    //FSM
    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            sta <= IDLE;
        end else if(cfg_rst) begin
            sta <= IDLE;
        end else begin
            case(sta)
            IDLE:if(run_trig) 
                    sta <= WR1;
                 else
                    sta <= IDLE;
            WR1:if(cfg_widle_pos)   
                    sta <= WR2 ;
            WR2:if(cfg_widle_pos && cfg_mode)   
                    sta <= WR1 ;
                else if(cfg_widle_pos)
                    sta <= IDLE;
            endcase
        end



    cmip_app_cnt #(
        .WDTH         (LEN_WDTH   )
    )u_cnt(          
        .i_clk        (sys_clk                      ),//(i) 
        .i_rst_n      (sys_rst_n                    ),//(i) 
        .i_clr        (cfg_rst                      ),//(i) 
        .i_vld        (cfg_widle_pos && (sta == WR2)),//(i) 
        .o_cnt        (sts_send_times               ) //(o) 
    );





endmodule























































