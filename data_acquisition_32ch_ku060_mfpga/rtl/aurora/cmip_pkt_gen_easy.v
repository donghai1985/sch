module cmip_pkt_gen_easy #(
    parameter                               DATA_WD        =    32         ,
    parameter                               CFG_WD         =    32         
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    
    input                                   cfg_rst                        ,//(i)
    input             [CFG_WD    -1:0]      cfg_len                        ,//(i)
    input             [CFG_WD    -1:0]      cfg_mode                       ,//(i)
    input                                   cfg_trig                       ,//(i)
    input             [CFG_WD    -1:0]      cfg_times                      ,//(i)
    input             [CFG_WD    -1:0]      cfg_interval                   ,//(i)
    output                                  sts_idle                       ,//(o)

    output            [DATA_WD   -1:0]      m_axis_tdata                   ,//(o)
    output            [DATA_WD/8 -1:0]      m_axis_tkeep                   ,//(o)
    output                                  m_axis_tvalid                  ,//(o)
    input                                   m_axis_tready                  ,//(i)
    output                                  m_axis_tlast                   ,//(o)
    output                                  m_axis_tuser                    //(o) // like sop
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    parameter                               IDLE     =      8'h0000    ;
    parameter                               REACH    =      8'h0001    ;
    parameter                               SEND     =      8'h0002    ;
    parameter                               WAIT     =      8'h0004    ;
    parameter                               MODE0    =        0        ;//0:forever              1:limited
    parameter                               MODE1    =        1        ;//0:data = cnt_pkt_len   1:data = cnt32
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg               [7:0]                 sta        =     8'd0          ;
    reg                                     cfg_trig_d1                    ;
    wire                                    cfg_trig_pos                   ;
    reg               [CFG_WD    -1:0]      send_times                     ;
    reg               [CFG_WD    -1:0]      cnt_pkt_len                    ;
    reg               [CFG_WD    -1:0]      cnt_time                       ;
    wire              [CFG_WD    -1:0]      cfg_len_imp                    ;
    reg               [31:0]                cnt32                          ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            cfg_len_imp    =     (cfg_len=={CFG_WD{1'b0}}) ? 32'd8 : cfg_len ;
    assign            cfg_interval_imp  =  (cfg_interval=={CFG_WD{1'b0}}) ? 32'd1 : cfg_interval ;
    assign            m_axis_tdata    =     cfg_mode[1] ? cnt32 : cnt_pkt_len;
    assign            m_axis_tkeep   =     {(DATA_WD/8){1'b1}}            ;
    assign            m_axis_tvalid  =     sta == SEND                    ;
//    assign            m_axis_tlast   =     m_axis_tvalid && m_axis_tready &&  (cnt_pkt_len == (cfg_len_imp-1'b1));
    assign            m_axis_tlast   =     m_axis_tvalid &&  (cnt_pkt_len == (cfg_len_imp-1'b1));
    assign            m_axis_tuser   =     m_axis_tvalid && m_axis_tready &&  (cnt_pkt_len == 1'b0);
    assign            sts_idle       =     (sta == IDLE)                  ;
    assign            cfg_trig_pos   =    ~cfg_trig_d1 && cfg_trig        ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            cfg_trig_d1 <= 1'b0;
        end else begin
            cfg_trig_d1 <= cfg_trig;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            sta <= IDLE;
        else if(cfg_rst)
            sta <= IDLE;
        else
            case(sta)
                IDLE :  if(cfg_trig_pos)
                            sta <= REACH;
                REACH:  if(cfg_mode[0] == 1'b0)
                            sta <=  SEND;
                        else if((cfg_mode[0] == 1'b1) && (cfg_times == send_times))
                            sta <=  IDLE;
                        else
                            sta <=  SEND;
                SEND :  if(m_axis_tlast && m_axis_tready)
                            sta <=  WAIT;
                WAIT :  if(cnt_time == (cfg_interval_imp - 1'b1))
                            sta <= REACH;
                default:    sta <= IDLE ;
            endcase
    end


    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            cnt_pkt_len <= {CFG_WD{1'b0}};
        end else if((sta==SEND) && m_axis_tvalid && m_axis_tready) begin
            cnt_pkt_len <= cnt_pkt_len + 1'b1;
        end else if((sta==SEND))begin
            cnt_pkt_len <= cnt_pkt_len;
        end else begin
            cnt_pkt_len <= {CFG_WD{1'b0}};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            cnt_time <= {CFG_WD{1'b0}};
        end else if((sta==WAIT)) begin
            cnt_time <= cnt_time + 1'b1;
        end else
            cnt_time <= {CFG_WD{1'b0}};
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            send_times <= {CFG_WD{1'b0}};
        end else if((sta==WAIT)&&(cnt_time == (cfg_interval_imp - 1'b1))) begin
            send_times <= send_times + 1'b1;
        end else if(sta == IDLE)
            send_times <= {CFG_WD{1'b0}};
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            cnt32 <= 32'b0;
        end else if(cfg_mode[1]) begin
            if(m_axis_tvalid && m_axis_tready)
                cnt32 <= cnt32 + 1'b1;
            else
                cnt32 <= cnt32;
        end else
            cnt32 <= 32'b0;
    end


endmodule





