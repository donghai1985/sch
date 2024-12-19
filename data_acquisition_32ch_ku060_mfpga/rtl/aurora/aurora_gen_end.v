module aurora_gen_end #(
    parameter                               DATA_WD        =    64         
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rst                        ,//(i)
    input                                   eds_finish                     ,//(i)

    output  reg       [DATA_WD   -1:0]      m_axis_tdata                   ,//(o)
    output            [DATA_WD/8 -1:0]      m_axis_tkeep                   ,//(o)
    output  reg                             m_axis_tvalid                  ,//(o)
    input                                   m_axis_tready                  ,//(i)
    output  reg                             m_axis_tlast                   ,//(o)
    output            [31          :0]      eds_end_ack_cnt                 //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    parameter                               IDLE     =      8'h0000    ;

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg               [1:0]                 sta                        ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            m_axis_tkeep   =     {(DATA_WD/8){1'b1}}            ;

// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            sta <= 2'b0;
        end else begin
            case(sta)
            2'd0:if(eds_finish) 
                sta <= 2'd1;
            2'd1:if(m_axis_tvalid && m_axis_tready) 
                sta <= 2'd2;
            2'd2:if(m_axis_tvalid && m_axis_tready) 
                sta <= 2'd0;
            default:sta <= 2'd0;
            endcase
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            m_axis_tvalid <= 1'b0           ;
            m_axis_tdata  <= {DATA_WD{1'b0}};
            m_axis_tlast  <= 1'b0           ;
        end else begin
            case(sta)
            2'd0:if(eds_finish) begin
                m_axis_tvalid <= 1'b1                   ;
                m_axis_tdata  <= 64'h0000_0000_55aa_0001;
                m_axis_tlast  <= 1'b0                   ;
            end
            2'd1:if(m_axis_tvalid && m_axis_tready) begin
                m_axis_tvalid <= 1'b1                   ;
                m_axis_tdata  <= 64'h0000_0000_0000_0001;
                m_axis_tlast  <= 1'b1                   ;
            end
            2'd2:if(m_axis_tvalid && m_axis_tready) begin
                m_axis_tvalid <= 1'b0                   ;
                m_axis_tdata  <= 64'h0000_0000_0000_0000;
                m_axis_tlast  <= 1'b0                   ;
            end
            endcase
        end
    end



    cmip_app_cnt #(
        .width     (32                             )
    )u2_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (cfg_rst                        ),//(i)
        .vld       (m_axis_tvalid && m_axis_tready && m_axis_tlast),//(i)
        .cnt       (eds_end_ack_cnt                ) //(o)
    );



endmodule





