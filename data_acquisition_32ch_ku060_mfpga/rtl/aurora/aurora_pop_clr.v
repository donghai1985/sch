module aurora_pop_clr #(
    parameter                               DATA_WD        =    128        ,
    parameter                               MAX_CNT        =    24'd524288  //8MB/16Byte
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)

    input                                   cfg_rst                        ,//(i)
    input                                   ena_cpl                        ,//(i)
    input                                   eds_cpl                        ,//(i)
    input                                   adc_cpl                        ,//(i)
    input                                   cfg_cpl                        ,//(i)
    output                                  pop_en                         ,//(o)
    output                                  pop_end_pkt                    ,//(o)

    output   reg      [DATA_WD   -1:0]      m_axis_tdata                   ,//(o)
    output            [DATA_WD/8 -1:0]      m_axis_tkeep                   ,//(o)
    output   reg                            m_axis_tvalid                  ,//(o)
    input                                   m_axis_tready                  ,//(i)
    output   reg                            m_axis_tlast                   ,//(o)
    output            [31:0]                last_pkt_cnt                   ,//(o)
    output            [31:0]                buff_clr_cnt                    //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                              CNT8M    =     24'd524288      ;
    localparam                              CNT16M   =     24'd1048576     ;
    localparam                              CNT32M   =     24'd2097152     ;
    localparam                              IDLE     =      4'h00          ;
    localparam                              CLR      =      4'h01          ;
    localparam                              POP      =      4'h02          ;
    localparam                              TAP      =      4'h04          ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg               [3 :0]                sta                            ;
    reg               [3 :0]                sta_d1                         ;
    reg               [23:0]                cnt                            ;
    reg                                     cfg_rst_d1                     ;
    reg                                     eds_cpl_d1                     ;
    reg                                     adc_cpl_d1                     ;
    reg                                     cfg_cpl_d1                     ;
    reg                                     ena_cpl_d1                     ;
    reg                                     cfg_rst_d2                     ;
    reg                                     eds_cpl_d2                     ;
    reg                                     adc_cpl_d2                     ;
    reg                                     cfg_cpl_d2                     ;
    reg                                     ena_cpl_d2                     ;    
    wire                                    cfg_rst_pos                    ;
    wire                                    eds_cpl_pos                    ;
    wire                                    adc_cpl_pos                    ;
    wire                                    cfg_cpl_pos                    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            m_axis_tkeep   =     {(DATA_WD/8){1'b1}}             ;
    assign            cfg_rst_pos    =   ~cfg_rst_d2 && cfg_rst_d1         ;
    assign            eds_cpl_pos    =   ~eds_cpl_d2 && eds_cpl_d1         ;
    assign            adc_cpl_pos    =   ~adc_cpl_d2 && adc_cpl_d1         ;
    assign            cfg_cpl_pos    =   ~cfg_cpl_d2 && cfg_cpl_d1         ;
    assign            pop_en         =    (sta!=IDLE)                      ;
    assign            pop_end_pkt    =    (sta==POP)                       ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            cfg_rst_d1   <= 1'b0;
            eds_cpl_d1   <= 1'b0;
            adc_cpl_d1   <= 1'b0;
            cfg_cpl_d1   <= 1'b0;
            ena_cpl_d1   <= 1'b0;
            cfg_rst_d2   <= 1'b0;
            eds_cpl_d2   <= 1'b0;
            adc_cpl_d2   <= 1'b0;
            cfg_cpl_d2   <= 1'b0;
            ena_cpl_d2   <= 1'b0;
            sta_d1       <= IDLE;
        end else begin
            cfg_rst_d1   <= cfg_rst   ;
            eds_cpl_d1   <= eds_cpl   ;
            adc_cpl_d1   <= adc_cpl   ;
            cfg_cpl_d1   <= cfg_cpl   ;
            ena_cpl_d1   <= ena_cpl   ;
            cfg_rst_d2   <= cfg_rst_d1;
            eds_cpl_d2   <= eds_cpl_d1;
            adc_cpl_d2   <= adc_cpl_d1;
            cfg_cpl_d2   <= cfg_cpl_d1;
            ena_cpl_d2   <= ena_cpl_d1;
            sta_d1       <= sta       ;
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            sta <= IDLE;
        else
            case(sta)
                IDLE :  if(cfg_rst_pos)
                            sta <= CLR;
                        else if((eds_cpl_pos || adc_cpl_pos || cfg_cpl_pos) && ena_cpl_d2)
                            sta <= POP;
                CLR  :  if((cnt==24'd19) && m_axis_tvalid && m_axis_tready)
                            sta <= TAP ;
                POP  :  if((cnt==CNT32M-1) && m_axis_tvalid && m_axis_tready)
                            sta <= TAP ;
                TAP  :      sta <= IDLE  ;
                default:    sta <= IDLE  ;
            endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            cnt <= 24'd0;
        end else if(sta!=IDLE) begin
            if(m_axis_tvalid && m_axis_tready)
                cnt <= cnt + 1'b1;
        end else begin
            cnt <= 24'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            m_axis_tdata   <=  'd0;
            m_axis_tvalid  <=  'd0;
            m_axis_tlast   <=  'd0;
        end else begin
            case(sta)
            CLR:begin
                if((cnt==24'd19) && m_axis_tvalid && m_axis_tready)begin
                    m_axis_tdata   <=  'd0;
                    m_axis_tvalid  <=  'd0;
                    m_axis_tlast   <=  'd0;
                end else begin
                    m_axis_tdata   <=  128'hAABBCCDD_AA55FF00_55AA0001_00000001;
                    m_axis_tvalid  <=  1'b1;
                    m_axis_tlast   <=  1'b1;
                end
            end
            POP:begin
                if(cnt < CNT8M -2)begin
                    m_axis_tdata   <=  128'h5A5ADEAD_0000FFFF_5A5ADEAD_0000FFFF;
                    m_axis_tvalid  <=  1'b1;
                    m_axis_tlast   <=  1'b0;
                end else if((cnt == CNT32M-1) && m_axis_tvalid && m_axis_tready)begin
                    m_axis_tdata   <=  'd0;
                    m_axis_tvalid  <=  'd0;
                    m_axis_tlast   <=  'd0;
                end else if((cnt == CNT8M-2) && m_axis_tvalid && m_axis_tready) begin
                    m_axis_tdata   <=  128'h5A5ADEAD_0000FFFF_5A5ADEAD_0000FFFF;
                    m_axis_tvalid  <=  1'b1;
                    m_axis_tlast   <=  1'b1;
                end else begin
                    m_axis_tdata   <=  128'h5A5ADEAD_0000FFFF_5A5ADEAD_0000FFFF;
                    m_axis_tvalid  <=  1'b1;
                    m_axis_tlast   <=  1'b1;
                end
            end
            default:begin
                m_axis_tdata   <=  'd0;
                m_axis_tvalid  <=  'd0;
                m_axis_tlast   <=  'd0;
            end
            endcase
        end
    end

    cmip_app_cnt #(
        .width     (32                   )
    )u0_app_cnt(                           
        .clk       (clk                  ),//(i)
        .rst_n     (rst_n                ),//(i)
        .clr       (1'b0                 ),//(i)
        .vld       ((sta == TAP) && (sta_d1 == CLR)),//(i)
        .cnt       (buff_clr_cnt         ) //(o)
    );

    cmip_app_cnt #(
        .width     (32                   )
    )u1_app_cnt(                           
        .clk       (clk                  ),//(i)
        .rst_n     (rst_n                ),//(i)
        .clr       (1'b0                 ),//(i)
        .vld       ((sta == TAP) && (sta_d1 == POP)),//(i)
        .cnt       (last_pkt_cnt         ) //(o)
    );

endmodule





