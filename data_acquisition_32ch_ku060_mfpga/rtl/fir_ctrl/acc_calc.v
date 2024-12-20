module acc_calc #(
    parameter                              DATA_WD           =      512         ,
    parameter                              HEAD_WD           =      64          
)(       
    input                                  clk                                  ,//(i)
    input                                  rst_n                                ,//(i)
    input                                  cfg_rst                              ,//(i)
    input                                  cfg_acc_en                           ,//(i)
    input             [15:0]               acc_zoom_coe                         ,//(i) 8bit integer + 8 bit decimal
    input                                  acc_ivld                             ,//(i)
    input             [DATA_WD     -1:0]   acc_idat                             ,//(i)
    input             [HEAD_WD     -1:0]   enc_idat                             ,//(i)

    output  reg                            acc_ovld                             ,//(o)
    output  reg       [DATA_WD     -1:0]   acc_odat                             ,//(o)
    output  reg       [HEAD_WD     -1:0]   enc_odat                              //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                             ADC_NUM             =      32          ;
    //--------------------------------------------------------------------------       
    // Defination of Internal Signals       
    //--------------------------------------------------------------------------       
    genvar                                 gi,gj                                ;
    integer                                i                                    ;
    wire                                   acc_en_sync                          ;
    wire              [15:0]               acc_zoom_coe_sync                    ;
    wire              [15:0]               acc_data     [ADC_NUM-1:0]           ;
    reg                                    acc_ivld_d1                          ;
    reg                                    acc_ivld_d2                          ;
    reg                                    acc_ivld_d3                          ;
    reg               [15:0]               acc_data_d1  [ADC_NUM-1:0]           ;
    reg               [15:0]               acc_data_d2  [ADC_NUM-1:0]           ;
    reg               [15:0]               acc_data_d3  [ADC_NUM-1:0]           ;
    reg               [63:0]               enc_idat_d1                          ;
    reg               [63:0]               enc_idat_d2                          ;
    reg               [63:0]               enc_idat_d3                          ;
    wire              [511:0]              acc_res                              ;
    wire              [29:0]               mac_sum      [ADC_NUM-1:0]           ;
    wire                                   acc_flag                             ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign      acc_flag           =       enc_idat_d3[63]                      ;//bit 63
    
generate
    for(gi=0; gi<ADC_NUM;gi=gi+1) begin:PART1
        assign  acc_data[gi]                 =  acc_idat[16*(gi+1)-1:16*gi];//notice
        assign  acc_res[16*(gi+1)-1:16*gi]   =  (acc_en_sync && acc_flag) ? mac_sum[gi][23:8] : acc_data_d3[gi];
    end
endgenerate



// =================================================================================================
// RTL Body
// =================================================================================================

    cmip_bit_sync_imp #(                                    
        .DATA_WDTH               (1                    ),
        .BUS_DELAY               (3                    )
    )u0_cmip_bit_sync( 
        .i_dst_clk               (clk                  ),//(i)
        .i_din                   (cfg_acc_en           ),//(i)
        .o_dout                  (acc_en_sync          ) //(o)
    );                                                 
    
    cmip_bit_sync_imp #(                                    
        .DATA_WDTH               (16                   ),
        .BUS_DELAY               (3                    )
    )u1_cmip_bit_sync( 
        .i_dst_clk               (clk                  ),//(i)
        .i_din                   (acc_zoom_coe         ),//(i)
        .o_dout                  (acc_zoom_coe_sync    ) //(o)
    );                                                 



    always@(posedge clk )begin
            acc_ivld_d1    <= acc_ivld      ;
            acc_ivld_d2    <= acc_ivld_d1   ;
            acc_ivld_d3    <= acc_ivld_d2   ;
            enc_idat_d1    <= enc_idat      ;
            enc_idat_d2    <= enc_idat_d1   ;
            enc_idat_d3    <= enc_idat_d2   ;
        for(i=0;i<ADC_NUM;i=i+1)begin
            acc_data_d1[i] <= acc_data[i];
            acc_data_d2[i] <= acc_data_d1[i];
            acc_data_d3[i] <= acc_data_d2[i];
        end 
    end

    always@(posedge clk )begin
            acc_ovld  <= acc_ivld_d3;           
            enc_odat  <= enc_idat_d3;
            acc_odat  <= acc_res    ;
    end


    // -------------------------------------------------------------------------
    // myip_mac Module Inst.
    // -------------------------------------------------------------------------
generate for(gj=0;gj<ADC_NUM;gj=gj+1)begin:gen_acc
    myip_mac #(
        .A_WDTH         (14                   ),
        .A_SIGNED       (0                    ),
        .B_WDTH         (16                   ),
        .B_SIGNED       (0                    ),
        .C_WDTH         (8                    ),
        .BUS_DELAY      (3                    )
    )u_myip_mac(                               
        .clk            (clk                  ),//(i)
        .rst_n          (rst_n                ),//(i)
        .a              (acc_data[gj]         ),//(i)
        .b              (acc_zoom_coe_sync    ),//(i)
        .c              (8'b0                 ),//(i)
        .sum            (mac_sum[gj]          ) //(o)
    );


end
endgenerate














endmodule





















































