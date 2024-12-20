module aurora_adc_send #(
    parameter                               DATA_WD        =    128        ,
    parameter                               ADC_CNT_WD     =    10         ,
    parameter                               HEAD_WD        =    64         ,
    parameter                               CFG_WD         =    32         
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)

    input                                   cfg_rst                        ,//(i)
    output                                  adc_fifo_rd                    ,//(o)
    input             [DATA_WD    -1:0]     adc_fifo_din                   ,//(i)
    input                                   adc_fifo_empty                 ,//(i)
    input             [ADC_CNT_WD -1:0]     adc_fifo_data_cnt              ,//(i)
    output                                  head_rd                        ,//(o)
    input             [HEAD_WD    -1:0]     head_din                       ,//(i)

    output            [DATA_WD   -1:0]      m_axis_tdata                   ,//(o)
    output            [DATA_WD/8 -1:0]      m_axis_tkeep                   ,//(o)
    output                                  m_axis_tvalid                  ,//(o)
    input                                   m_axis_tready                  ,//(i)
    output                                  m_axis_tlast                   ,//(o)
    output                                  m_axis_tuser                   ,//(o) // like sop
    output            [31:0]                pkt_sop_eop_cnt                ,//(o)
    output            [15:0]                pkt_sop_cnt                    ,//(o)
    output            [15:0]                pkt_eop_cnt                     //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                              DATA_WD_HALF   =      DATA_WD / 2    ;
    localparam                              IDLE           =      4'h00          ;
    localparam                              START1         =      4'h01          ;
    localparam                              START2         =      4'h02          ;
    localparam                              DATA0          =      4'h03          ;
    localparam                              DATA1          =      4'h04          ;
    localparam                              DATA2          =      4'h05          ;
    localparam                              DATA3          =      4'h06          ;
    localparam                              DATA4          =      4'h07          ;
    localparam                              DATA5          =      4'h08          ;
    localparam                              DATA6          =      4'h09          ;
    localparam                              DATA7          =      4'h0a          ;
    localparam                              DATA8          =      4'h0b          ;
    localparam                              LAST           =      4'h0c          ;//last sta
    localparam                              BLK_NUM        =       32            ;
    localparam                              ADC_START_FLAG =    128'hAABBCCDD_AA55FF00_55AA0001_00000002;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg               [DATA_WD    -1:0]     adc_fifo_din_d1                ;
    reg               [3 :0]                sta                            ;
    reg               [15:0]                blk_cnt                        ;
    wire                                    send_start                     ;
    wire                                    vld_ready                      ;
    reg               [DATA_WD   -1:0]      axis_tdata                     ;
    reg                                     axis_tvalid                    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            pkt_sop_eop_cnt=     {pkt_eop_cnt,pkt_sop_cnt}      ;
    assign            m_axis_tkeep   =     {(DATA_WD/8){1'b1}}            ;
    assign            m_axis_tvalid  =     axis_tvalid &&(~adc_fifo_empty);
    assign            m_axis_tdata   =     axis_tdata                     ;
    assign            m_axis_tlast   =     m_axis_tvalid && (sta==DATA8) && (blk_cnt==BLK_NUM-1'b1);
    assign            m_axis_tuser   =     m_axis_tvalid && m_axis_tready &&  (sta == DATA0) && (blk_cnt==16'd0);
    assign            vld_ready      =     m_axis_tvalid && m_axis_tready ;
    assign            adc_fifo_rd    =     vld_ready && (sta!=DATA4)  && (sta!=START1)   ;
    assign            head_rd        =     vld_ready && ((sta==DATA0) || (sta==DATA4))   ;
    assign            send_start     =     adc_fifo_data_cnt >= 10'd8     ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            adc_fifo_din_d1 <= {DATA_WD{1'b0}};
        else if(adc_fifo_rd)
            adc_fifo_din_d1 <= adc_fifo_din;
    end


    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            sta <= IDLE;
        else if(cfg_rst)
            sta <= IDLE;
        else
            case(sta)
                IDLE :  if(send_start)
                            sta <= START1;
                START1:  if(~adc_fifo_empty && vld_ready)
                            sta <= START2;
                START2:     sta <= DATA0;
                DATA0:  if(vld_ready)
                            sta <= DATA1;
                DATA1:  if(vld_ready)
                            sta <= DATA2;
                DATA2:  if(vld_ready)
                            sta <= DATA3;
                DATA3:  if(vld_ready)
                            sta <= DATA4;
                DATA4:  if(vld_ready)
                            sta <= DATA5;
                DATA5:  if(vld_ready)
                            sta <= DATA6;
                DATA6:  if(vld_ready)
                            sta <= DATA7;
                DATA7:  if(vld_ready)
                            sta <= DATA8;
                DATA8:  if(m_axis_tlast && vld_ready)
                            sta <= START2;
                        else if(vld_ready)
                            sta <=  DATA0;
                        else
                            sta <=  DATA8;
                default:    sta <= IDLE  ;
            endcase
    end


always @(*) begin
        case(sta)
            IDLE :begin
                axis_tvalid <= 1'b0;
                axis_tdata  <= {DATA_WD{1'b0}};
            end
            START1:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= ADC_START_FLAG;
            end
            START2 :begin
                axis_tvalid <= 1'b0;
                axis_tdata  <= {DATA_WD{1'b0}};
            end
            DATA0:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= {adc_fifo_din[DATA_WD_HALF-1:0],head_din};
            end
            DATA1:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= {adc_fifo_din[DATA_WD_HALF-1:0],adc_fifo_din_d1[DATA_WD-1:DATA_WD_HALF]};
            end
            DATA2:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= {adc_fifo_din[DATA_WD_HALF-1:0],adc_fifo_din_d1[DATA_WD-1:DATA_WD_HALF]};
            end
            DATA3:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= {adc_fifo_din[DATA_WD_HALF-1:0],adc_fifo_din_d1[DATA_WD-1:DATA_WD_HALF]};
            end
            DATA4:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= {head_din,adc_fifo_din_d1[DATA_WD-1:DATA_WD_HALF]};
            end
            DATA5:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= adc_fifo_din;
            end
            DATA6:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= adc_fifo_din;
            end
            DATA7:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= adc_fifo_din;
            end
            DATA8:begin
                axis_tvalid <= 1'b1;
                axis_tdata  <= adc_fifo_din;
            end
            default: begin
                axis_tvalid <= 1'b0;
                axis_tdata  <= {DATA_WD{1'b0}};
            end
        endcase
end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            blk_cnt <= 16'd0;
        else if(vld_ready && (sta==DATA8))
            blk_cnt <= blk_cnt + 1'b1;
        else if(sta==START2)
            blk_cnt <= 16'd0;
    end




    //---------------------------------------------------------------------
    // app_cnt.
    //---------------------------------------------------------------------     
    cmip_app_cnt #(
        .width     (16                           )
    )u0_app_cnt(                                   
        .clk       (clk                          ),//(i)
        .rst_n     (rst_n                        ),//(i)
        .clr       (cfg_rst                      ),//(i)
        .vld       (m_axis_tlast && vld_ready    ),//(i)
        .cnt       (pkt_eop_cnt                  ) //(o)
    );

    cmip_app_cnt #(
        .width     (16                           )
    )u1_app_cnt(                                   
        .clk       (clk                          ),//(i)
        .rst_n     (rst_n                        ),//(i)
        .clr       (cfg_rst                      ),//(i)
        .vld       (m_axis_tuser                 ),//(i)
        .cnt       (pkt_sop_cnt                  ) //(o)
    );











endmodule





