module fir_mean_filt #(
    parameter     DATA_WD      =         16                         ,
    parameter     DEC_WD       =          5                         
)(
    input                                clk                        ,//(i)
    input                                rst_n                      ,//(i)
    input                                soft_rst                   ,//(i)
    input                                fir_en                     ,//(i)
    input         [DEC_WD   -1:0]        fir_dec                    ,//(i) 
    input                                ivld                       ,//(i) 
    input         [DATA_WD  -1:0]        idata                      ,//(i) 
    output                               ovld                       ,//(o) 
    output        [DATA_WD  -1:0]        odata                       //(o) 
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam    MAX_MEAN      =        40                         ;
    localparam    SUM_WD        =        DATA_WD + $clog2(MAX_MEAN) ;

    // -------------------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------------------
    genvar                               gi,gj,gk                   ;
    integer                              i,j,k                      ;
    reg           [DATA_WD  -1:0]        dat_pipe [MAX_MEAN-1:0]    ;//ivld_d1
    reg           [SUM_WD   -1:0]        sum      [MAX_MEAN-1:0]    ;//ivld_d1
    reg           [SUM_WD   -1:0]        sum_d1   [MAX_MEAN-1:0]    ;//ivld_d2
    reg           [SUM_WD   -1:0]        sum_sel                    ;
    reg                                  ivld_d1                    ;
    reg                                  ivld_d2                    ;
    reg                                  ivld_d3                    ;
    reg           [DATA_WD  -1:0]        idata_d1                   ;
    reg           [DATA_WD  -1:0]        idata_d2                   ;
    reg           [DATA_WD  -1:0]        idata_d3                   ;
    reg           [DEC_WD   -1:0]        fir_dec_tap                ;
    reg           [DEC_WD   -1:0]        fir_dec_tap_d1             ;//ivld_d2
    reg           [15         :0]        multi_sel                  ;
(* use_dsp = "yes" *)wire          [SUM_WD+15  :0]        multi_res                  ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign         odata     =           fir_en  ?  (multi_res >> 16) : idata_d3;
    assign         ovld      =                                          ivld_d3 ;

       
// =============================================================================
// RTL Body
// =============================================================================
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ivld_d1        <= 1'b0;
            ivld_d2        <= 1'b0;
            ivld_d3        <= 1'b0;
            idata_d1       <=  'd0;
            idata_d2       <=  'd0;
            idata_d3       <=  'd0;
            fir_dec_tap_d1 <=  'd0;
        end else begin
            ivld_d1        <= ivld;
            ivld_d2        <= ivld_d1;
            ivld_d3        <= ivld_d2;
            idata_d1       <= idata;
            idata_d2       <= idata_d1;
            idata_d3       <= idata_d2;
            fir_dec_tap_d1 <= fir_dec_tap;
        end
    end 

    always @(posedge clk or negedge rst_n)
        if(!rst_n)begin
            dat_pipe[0]    <= {DATA_WD{1'b0}};
            fir_dec_tap    <= {DEC_WD {1'b0}};
        end else if(soft_rst)begin
            dat_pipe[0]    <= {DATA_WD{1'b0}};
            fir_dec_tap    <= {DEC_WD {1'b0}};
        end else if(ivld)begin
            dat_pipe[0]    <= idata          ;
            fir_dec_tap    <= fir_dec        ;
        end

generate for(gi=1;gi<MAX_MEAN;gi=gi+1)begin
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            dat_pipe[gi] <= {DATA_WD{1'b0}};
        else if(soft_rst)
            dat_pipe[gi] <= {DATA_WD{1'b0}};
        else if(ivld)
            dat_pipe[gi] <= dat_pipe[gi-1];
end
endgenerate



    always@(*)begin
        sum[0] = dat_pipe[0];
    end

    always@(posedge clk)begin
        sum_d1[0] <= sum[0];
    end

generate for(gj=1;gj<MAX_MEAN;gj=gj+1)begin
    always@(*)begin
        sum[gj] = sum[gj-1] + dat_pipe[gj];
    end

    always@(posedge clk)begin
        sum_d1[gj] <= sum[gj];
    end
end
endgenerate

    always@(*)begin
        case(fir_dec_tap_d1)
        5'd0:      sum_sel <= sum_d1[0];
        5'd1:      sum_sel <= sum_d1[1];
        5'd2:      sum_sel <= sum_d1[2];
        5'd3:      sum_sel <= sum_d1[3];
        5'd4:      sum_sel <= sum_d1[4];
        5'd5:      sum_sel <= sum_d1[5];
        5'd6:      sum_sel <= sum_d1[6];
        5'd7:      sum_sel <= sum_d1[7];
        5'd8:      sum_sel <= sum_d1[8];
        5'd9:      sum_sel <= sum_d1[9];
        5'd10:     sum_sel <= sum_d1[10];
        5'd11:     sum_sel <= sum_d1[11];
        5'd12:     sum_sel <= sum_d1[12];
        5'd13:     sum_sel <= sum_d1[13];
        5'd14:     sum_sel <= sum_d1[14];
        5'd15:     sum_sel <= sum_d1[15];
        5'd16:     sum_sel <= sum_d1[16];
        5'd17:     sum_sel <= sum_d1[17];
        5'd18:     sum_sel <= sum_d1[18];
        5'd19:     sum_sel <= sum_d1[19];
        5'd20:     sum_sel <= sum_d1[20];
        5'd21:     sum_sel <= sum_d1[21];
        5'd22:     sum_sel <= sum_d1[22];
        5'd23:     sum_sel <= sum_d1[23];
        5'd24:     sum_sel <= sum_d1[24];
        5'd25:     sum_sel <= sum_d1[25];
        5'd26:     sum_sel <= sum_d1[26];
        5'd27:     sum_sel <= sum_d1[27];
        5'd28:     sum_sel <= sum_d1[28];
        5'd29:     sum_sel <= sum_d1[29];
        5'd30:     sum_sel <= sum_d1[30];
        5'd31:     sum_sel <= sum_d1[31];
        5'd32:     sum_sel <= sum_d1[32];
        5'd33:     sum_sel <= sum_d1[33];
        5'd34:     sum_sel <= sum_d1[34];
        5'd35:     sum_sel <= sum_d1[35];
        5'd36:     sum_sel <= sum_d1[36];
        5'd37:     sum_sel <= sum_d1[37];
        5'd38:     sum_sel <= sum_d1[38];
        5'd39:     sum_sel <= sum_d1[39];
        default:   sum_sel <= {SUM_WD{1'b0}};
        endcase
    end

    always@(*)begin
        case(fir_dec_tap_d1)
        5'd0:      multi_sel <= 16'd65535;
        5'd1:      multi_sel <= 16'd32768;
        5'd2:      multi_sel <= 16'd21845;
        5'd3:      multi_sel <= 16'd16384;
        5'd4:      multi_sel <= 16'd13107;
        5'd5:      multi_sel <= 16'd10923;
        5'd6:      multi_sel <= 16'd9362 ;
        5'd7:      multi_sel <= 16'd8192 ;
        5'd8:      multi_sel <= 16'd7282 ;
        5'd9:      multi_sel <= 16'd6554 ;
        5'd10:     multi_sel <= 16'd5958 ;
        5'd11:     multi_sel <= 16'd5461 ;
        5'd12:     multi_sel <= 16'd5041 ;
        5'd13:     multi_sel <= 16'd4681 ;
        5'd14:     multi_sel <= 16'd4369 ;
        5'd15:     multi_sel <= 16'd4096 ;
        5'd16:     multi_sel <= 16'd3855 ;
        5'd17:     multi_sel <= 16'd3641 ;
        5'd18:     multi_sel <= 16'd3449 ;
        5'd19:     multi_sel <= 16'd3277 ;
        5'd20:     multi_sel <= 16'd3121 ;
        5'd21:     multi_sel <= 16'd2979 ;
        5'd22:     multi_sel <= 16'd2849 ;
        5'd23:     multi_sel <= 16'd2731 ;
        5'd24:     multi_sel <= 16'd2621 ;
        5'd25:     multi_sel <= 16'd2521 ;
        5'd26:     multi_sel <= 16'd2427 ;
        5'd27:     multi_sel <= 16'd2341 ;
        5'd28:     multi_sel <= 16'd2260 ;
        5'd29:     multi_sel <= 16'd2185 ;
        5'd30:     multi_sel <= 16'd2114 ;
        5'd31:     multi_sel <= 16'd2048 ;
        5'd32:     multi_sel <= 16'd1986 ;
        5'd33:     multi_sel <= 16'd1928 ;
        5'd34:     multi_sel <= 16'd1872 ;
        5'd35:     multi_sel <= 16'd1820 ;
        5'd36:     multi_sel <= 16'd1771 ;
        5'd37:     multi_sel <= 16'd1725 ;
        5'd38:     multi_sel <= 16'd1680 ;
        5'd39:     multi_sel <= 16'd1638 ;
        default:   multi_sel <= {SUM_WD{1'b0}};
        endcase
    end

    // -------------------------------------------------------------------------
    // myip_mac Module Inst.
    // -------------------------------------------------------------------------
    myip_mac #(
        .A_WDTH         (SUM_WD          ),
        .A_SIGNED       (0               ),
        .B_WDTH         (16              ),
        .B_SIGNED       (0               ),
        .C_WDTH         (8               ),
        .BUS_DELAY      (1               )
    )u_myip_mac(                          
        .clk            (clk             ),//(i)
        .rst_n          (rst_n           ),//(i)
        .a              (sum_sel         ),//(i)
        .b              (multi_sel       ),//(i)
        .c              (8'b0            ),//(i)
        .sum            (multi_res       ) //(o)
    );




endmodule

























