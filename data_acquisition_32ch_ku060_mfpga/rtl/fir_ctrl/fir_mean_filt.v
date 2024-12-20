module fir_mean_filt #(
    parameter     DATA_WD      =         16                         ,
    parameter     DEC_WD       =          6                         
)(
    input                                clk                        ,//(i)
    input                                rst_n                      ,//(i)
    input                                soft_rst                   ,//(i)
    input                                fir_en                     ,//(i)
    input         [DEC_WD   -1:0]        fir_dec                    ,//(i) 
    input                                ivld                       ,//(i) 
    input         [DATA_WD  -1:0]        idata                      ,//(i) 
    output  reg                          ovld                       ,//(o) 
    output  reg   [DATA_WD  -1:0]        odata                       //(o) 
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
//  assign         odata     =           fir_en  ?  (multi_res >> 16) : idata_d3;
//  assign         ovld      =                                          ivld_d3 ;

       
// =============================================================================
// RTL Body
// =============================================================================
    always @(posedge clk)begin
            ovld  <=                              ivld_d3 ;
            odata <= fir_en ? (multi_res >> 16) : idata_d3;
    end


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
        6'd0:      sum_sel <= sum_d1[0];
        6'd1:      sum_sel <= sum_d1[1];
        6'd2:      sum_sel <= sum_d1[2];
        6'd3:      sum_sel <= sum_d1[3];
        6'd4:      sum_sel <= sum_d1[4];
        6'd5:      sum_sel <= sum_d1[5];
        6'd6:      sum_sel <= sum_d1[6];
        6'd7:      sum_sel <= sum_d1[7];
        6'd8:      sum_sel <= sum_d1[8];
        6'd9:      sum_sel <= sum_d1[9];
        6'd10:     sum_sel <= sum_d1[10];
        6'd11:     sum_sel <= sum_d1[11];
        6'd12:     sum_sel <= sum_d1[12];
        6'd13:     sum_sel <= sum_d1[13];
        6'd14:     sum_sel <= sum_d1[14];
        6'd15:     sum_sel <= sum_d1[15];
        6'd16:     sum_sel <= sum_d1[16];
        6'd17:     sum_sel <= sum_d1[17];
        6'd18:     sum_sel <= sum_d1[18];
        6'd19:     sum_sel <= sum_d1[19];
        6'd20:     sum_sel <= sum_d1[20];
        6'd21:     sum_sel <= sum_d1[21];
        6'd22:     sum_sel <= sum_d1[22];
        6'd23:     sum_sel <= sum_d1[23];
        6'd24:     sum_sel <= sum_d1[24];
        6'd25:     sum_sel <= sum_d1[25];
        6'd26:     sum_sel <= sum_d1[26];
        6'd27:     sum_sel <= sum_d1[27];
        6'd28:     sum_sel <= sum_d1[28];
        6'd29:     sum_sel <= sum_d1[29];
        6'd30:     sum_sel <= sum_d1[30];
        6'd31:     sum_sel <= sum_d1[31];
        6'd32:     sum_sel <= sum_d1[32];
        6'd33:     sum_sel <= sum_d1[33];
        6'd34:     sum_sel <= sum_d1[34];
        6'd35:     sum_sel <= sum_d1[35];
        6'd36:     sum_sel <= sum_d1[36];
        6'd37:     sum_sel <= sum_d1[37];
        6'd38:     sum_sel <= sum_d1[38];
        6'd39:     sum_sel <= sum_d1[39];
        default:   sum_sel <= {SUM_WD{1'b0}};
        endcase
    end

    always@(*)begin
        case(fir_dec_tap_d1)
        6'd0:      multi_sel <= 16'd65535;
        6'd1:      multi_sel <= 16'd32768;
        6'd2:      multi_sel <= 16'd21845;
        6'd3:      multi_sel <= 16'd16384;
        6'd4:      multi_sel <= 16'd13107;
        6'd5:      multi_sel <= 16'd10923;
        6'd6:      multi_sel <= 16'd9362 ;
        6'd7:      multi_sel <= 16'd8192 ;
        6'd8:      multi_sel <= 16'd7282 ;
        6'd9:      multi_sel <= 16'd6554 ;
        6'd10:     multi_sel <= 16'd5958 ;
        6'd11:     multi_sel <= 16'd5461 ;
        6'd12:     multi_sel <= 16'd5041 ;
        6'd13:     multi_sel <= 16'd4681 ;
        6'd14:     multi_sel <= 16'd4369 ;
        6'd15:     multi_sel <= 16'd4096 ;
        6'd16:     multi_sel <= 16'd3855 ;
        6'd17:     multi_sel <= 16'd3641 ;
        6'd18:     multi_sel <= 16'd3449 ;
        6'd19:     multi_sel <= 16'd3277 ;
        6'd20:     multi_sel <= 16'd3121 ;
        6'd21:     multi_sel <= 16'd2979 ;
        6'd22:     multi_sel <= 16'd2849 ;
        6'd23:     multi_sel <= 16'd2731 ;
        6'd24:     multi_sel <= 16'd2621 ;
        6'd25:     multi_sel <= 16'd2521 ;
        6'd26:     multi_sel <= 16'd2427 ;
        6'd27:     multi_sel <= 16'd2341 ;
        6'd28:     multi_sel <= 16'd2260 ;
        6'd29:     multi_sel <= 16'd2185 ;
        6'd30:     multi_sel <= 16'd2114 ;
        6'd31:     multi_sel <= 16'd2048 ;
        6'd32:     multi_sel <= 16'd1986 ;
        6'd33:     multi_sel <= 16'd1928 ;
        6'd34:     multi_sel <= 16'd1872 ;
        6'd35:     multi_sel <= 16'd1820 ;
        6'd36:     multi_sel <= 16'd1771 ;
        6'd37:     multi_sel <= 16'd1725 ;
        6'd38:     multi_sel <= 16'd1680 ;
        6'd39:     multi_sel <= 16'd1638 ;
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


























