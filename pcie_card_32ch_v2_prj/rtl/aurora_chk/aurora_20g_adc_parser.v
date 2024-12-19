module aurora_20g_adc_parser #(
    parameter                               DATA_WD        =    128        ,
    parameter                               HEAD_WD        =    64         
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rst                        ,//(i)

    input             [DATA_WD   -1:0]      s_axis_tdata                   ,//(o)
    input             [DATA_WD/8 -1:0]      s_axis_tkeep                   ,//(o)
    input                                   s_axis_tvalid                  ,//(o)
    input                                   s_axis_tlast                   ,//(o)

    output   reg                            head_vld                       ,//(o)
    output   reg      [HEAD_WD    -1:0]     head_data                      ,//(o)
    output   reg                            adc_vld                        ,//(o)
    output   reg      [DATA_WD    -1:0]     adc_data                        //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                              DATA_WD_HALF   =      DATA_WD / 2    ;
    localparam                              DATA0          =      4'h00          ;
    localparam                              DATA1          =      4'h01          ;
    localparam                              DATA2          =      4'h02          ;
    localparam                              DATA3          =      4'h03          ;
    localparam                              DATA4          =      4'h04          ;
    localparam                              DATA5          =      4'h05          ;
    localparam                              DATA6          =      4'h06          ;
    localparam                              DATA7          =      4'h07          ;
    localparam                              DATA8          =      4'h08          ;
    localparam                              LAST           =      4'h09          ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg               [DATA_WD    -1:0]     s_axis_tdata_d1                 ;
    reg               [3 :0]                sta                             ;
    wire                                    vld_ready                       ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            vld_ready     =    s_axis_tvalid                      ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            s_axis_tdata_d1 <= {DATA_WD{1'b0}};
        else if(s_axis_tvalid)
            s_axis_tdata_d1 <= s_axis_tdata;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            sta <= DATA0;
        else if(cfg_rst)
            sta <= DATA0;
        else
            case(sta)
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
                DATA8:  if(vld_ready)
                            sta <= DATA0;
                default:    sta <= DATA0;
            endcase
    end

    
    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            head_vld   <=          1'b0;
            head_data  <= {HEAD_WD{1'b0}};
        end else if((sta == DATA0) && s_axis_tvalid) begin
            head_vld   <=          1'b1;
            head_data  <= s_axis_tdata[DATA_WD_HALF-1:0];
        end else if((sta == DATA4) && s_axis_tvalid) begin
            head_vld   <=          1'b1;
            head_data  <= s_axis_tdata[DATA_WD-1:DATA_WD_HALF];
        end else begin
            head_vld   <=          1'b0;
            head_data  <=     head_data;
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            adc_vld   <=          1'b0;
            adc_data  <= {DATA_WD{1'b0}};
        end else if(~s_axis_tvalid) begin
            adc_vld   <=          1'b0; 
            adc_data  <=  s_axis_tdata;
        end else begin
            case(sta)
                DATA1,DATA2,DATA3,DATA4:  begin
                    adc_vld   <=          1'b1;
                    adc_data  <= {s_axis_tdata[DATA_WD_HALF-1:0],s_axis_tdata_d1[DATA_WD-1:DATA_WD_HALF]};
                end
                DATA5,DATA6,DATA7,DATA8:  begin
                    adc_vld   <=          1'b1;
                    adc_data  <=  s_axis_tdata;
                end
                default:begin
                    adc_vld   <=          1'b0;
                    adc_data  <=      adc_data;
                end
            endcase
        end
    end






endmodule





