`define     FIR_SYNTH      

module fir_process #(
    parameter                              DATA_WDTH         =      512           ,
    parameter                              COE_NUM           =      37            ,
    parameter                              COE_WDTH          =      27            ,
    parameter                              COE_NUM_HALF      =     (COE_NUM+1)/2  ,
    parameter                              XDATA_WDTH        =      16            ,
    parameter                              YDATA_WDTH        =      16            
)(       

    input                                  cfg_clk                                ,//(i)
    input                                  cfg_rst_n                              ,//(i)
    input                                  soft_rst                               ,//(i)
    input                                  fir_en                                 ,//(i)
    input                                  scan_start                             ,//(i)
    input                                  encode_flag                            ,//(i)
    output    reg                          ddr_rd0_en                             ,//(i)
    output    reg       [32-1:0]           ddr_rd0_addr                           ,//(i)
    input                                  readback0_vld                          ,//(o)
    input                                  readback0_last                         ,//(o)
    input               [32-1:0]           readback0_data                         ,//(o)
    output              [15  :0]           track_num                              ,//(o)

    input                                  sys_clk                                ,//(i)
    input                                  sys_rst_n                              ,//(i)
    input                                  fir_din_vld                            ,//(i)
    input             [DATA_WDTH-1:0]      fir_din                                ,//(i)
    input             [63         :0]      enc_din                                ,//(i)
    output                                 fir_dout_vld                           ,//(o)
    output            [DATA_WDTH-1:0]      fir_dout                               ,//(o)
    output            [63         :0]      enc_dout                               ,//(o)
    
    output            [17:0]               fir_xenc_1st                           ,//(o)
    output            [17:0]               fir_wenc_1st                           ,//(o)
    output            [31:0]               fir_jp_pos_1st                         ,//(o)
    output            [31:0]               fir_jp_num                             ,//(o)
    
    output            [31         :0]      coe0                                   ,//(o)
    output            [31         :0]      coe1                                   ,//(o)
    output            [31         :0]      coe2                                   ,//(o)
    output            [31         :0]      coe3                                   ,//(o)
    output            [31         :0]      coe4                                   ,//(o)
    output            [31         :0]      coe5                                   ,//(o)
    output            [31         :0]      coe6                                   ,//(o)
    output            [31         :0]      coe7                                   ,//(o)
    output            [31         :0]      coe8                                   ,//(o)
    output            [31         :0]      coe9                                   ,//(o)
    output            [31         :0]      coe10                                  ,//(o)
    output            [31         :0]      coe11                                  ,//(o)
    output            [31         :0]      coe12                                  ,//(o)
    output            [31         :0]      coe13                                  ,//(o)
    output            [31         :0]      coe14                                  ,//(o)
    output            [31         :0]      coe15                                  ,//(o)
    output            [31         :0]      coe16                                  ,//(o)
    output            [31         :0]      coe17                                  ,//(o)
    output            [31         :0]      coe18                                  ,//(o)
    output            [31         :0]      coe_dec                                 //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                             ADC_WD              =      16          ;
    localparam                             ADC_NUM             =      32          ;
    //--------------------------------------------------------------------------       
    // Defination of Internal Signals       
    //--------------------------------------------------------------------------       
    genvar                                 gi,gj,gk                               ;//sys_clk
    wire                                   adc_vld                                ;//sys_clk
    wire              [ADC_WD-1:0]         adc_din[ADC_NUM-1:0]                   ;//sys_clk
    wire              [ADC_WD-1:0]         mean_data[ADC_NUM-1:0]                 ;//sys_clk
    wire                                   mean_vld [ADC_NUM-1:0]                 ;//sys_clk
    wire              [ADC_WD-1:0]         dec_data[ADC_NUM-1:0]                  ;//sys_clk
    wire                                   dec_vld [ADC_NUM-1:0]                  ;//sys_clk
    wire              [ADC_WD-1:0]         fir_data[ADC_NUM-1:0]                  ;//sys_clk
    wire                                   fir_vld [ADC_NUM-1:0]                  ;//sys_clk
    wire              [ADC_WD-1:0]         fir_dec_data[ADC_NUM-1:0]              ;//sys_clk
    wire                                   fir_dec_vld [ADC_NUM-1:0]              ;//sys_clk
    wire                                   fir_rm_dly_ivld                        ;//sys_clk
    wire              [DATA_WDTH-1:0]      fir_rm_dly_idat                        ;//sys_clk
    wire              [63:0]               fir_rm_dly_ienc                        ;//sys_clk
    wire                                   fir_rm_dly_ovld                        ;//sys_clk
    wire              [DATA_WDTH-1:0]      fir_rm_dly_odat                        ;//sys_clk
    wire              [63:0]               fir_rm_dly_oenc                        ;//sys_clk
    wire      [COE_NUM_HALF*COE_WDTH-1:0]  coe_arr                                ;//sys_clk
    wire              [31:0]               fir_dec                                ;//sys_clk
    wire                                   soft_rst_sync                          ;//sys_clk
    wire                                   fir_en_sync                            ;//sys_clk

    wire                                   coe_load                               ;//cfg_clk
    wire                                   coe_vld                                ;//cfg_clk
    wire              [COE_WDTH  -1:0]     coe_din                                ;//cfg_clk
    wire                                   coe_sop                                ;//cfg_clk
    wire              [31:0]               coe_fir_dec                            ;//cfg_clk

    reg                                    scan_start_d1                          ;//cfg_clk
    wire                                   scan_start_pos                         ;//cfg_clk
    reg                                    fir_en_d1                              ;//cfg_clk
    wire                                   fir_en_pos                             ;//cfg_clk
    reg                                    soft_rst_d1                            ;//cfg_clk
    reg                                    soft_rst_d2                            ;//cfg_clk
    wire                                   soft_rst_pos                           ;//cfg_clk
    reg                                    encode_flag_d1                         ;//cfg_clk
    reg                                    encode_flag_d2                         ;//cfg_clk
    wire                                   encode_flag_pos                        ;//cfg_clk
    wire                                   track_pos                              ;//cfg_clk
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            adc_vld             =     fir_din_vld                       ;//sys_clk
    assign            fir_rm_dly_ivld     =     fir_dec_vld[0]                    ;//sys_clk

    assign            scan_start_pos      =    ~scan_start_d1 && scan_start       ;//cfg_clk
    assign            fir_en_pos          =    ~fir_en_d1     && fir_en           ;//cfg_clk
    assign            soft_rst_pos        =    ~soft_rst_d2   && soft_rst_d1      ;//cfg_clk
    assign            encode_flag_pos     =    ~encode_flag_d2&& encode_flag_d1   ;//cfg_clk

    assign            coe_load            =     scan_start_pos || encode_flag_pos || track_pos ;//cfg_clk

generate
    for(gi=0; gi<ADC_NUM;gi=gi+1) begin:PART1
        assign  adc_din[gi]       =  fir_din[16*(gi+1)-1:16*gi];//notice
        assign  fir_rm_dly_idat[16*(gi+1)-1:16*gi] = fir_dec_data[gi];//notice
    end
endgenerate



// =================================================================================================
// RTL Body
// =================================================================================================

    always@(posedge cfg_clk)begin
        scan_start_d1    <=    scan_start    ;
        fir_en_d1        <=    fir_en        ;
        soft_rst_d1      <=    soft_rst      ;
        soft_rst_d2      <=    soft_rst_d1   ;
        encode_flag_d1   <=    encode_flag   ;
        encode_flag_d2   <=    encode_flag_d1;
    end

    always@(posedge cfg_clk or negedge cfg_rst_n)begin
        if(~cfg_rst_n)begin
            ddr_rd0_en    <=  1'b0;
            ddr_rd0_addr  <= 32'd0;
        end else if(fir_en_pos || soft_rst_pos)begin
            ddr_rd0_en    <=  1'b1;
            ddr_rd0_addr  <= 32'd0;
        end else if(encode_flag_pos || track_pos)begin
            ddr_rd0_en    <=  1'b1;
            ddr_rd0_addr  <= ddr_rd0_addr + 1'b1;
        end else begin
            ddr_rd0_en    <=  1'b0;
            ddr_rd0_addr  <= ddr_rd0_addr;
        end
    end

    track_gen u_track_gen(       
        .sys_clk               (sys_clk          ),//(i)
        .sys_rst_n             (sys_rst_n        ),//(i)
        .soft_rst_sync         (soft_rst_sync    ),//(i)
        .fir_en                (fir_en_sync      ),//(i)
        .fir_din_vld           (fir_din_vld      ),//(i)
        .enc_din               (enc_din          ),//(i)
        .cfg_clk               (cfg_clk          ),//(i)
        .cfg_rst_n             (cfg_rst_n        ),//(i)
        .soft_rst              (soft_rst         ),//(i)
        .track_pos             (track_pos        ),//(o)
        .track_num             (track_num        ) //(o)
    );

    // -------------------------------------------------------------------------
    // fir_coe_inf_conv Module Inst.
    // -------------------------------------------------------------------------
    fir_coe_inf_conv #(                                           
        .COE_NUM                 (COE_NUM               ),
        .COE_WDTH                (COE_WDTH              ),
        .COE_NUM_HALF            (COE_NUM_HALF          )       
    )u_fir_coe_inf_conv( 
        .cfg_clk                 (cfg_clk               ),//(i)
        .cfg_rst_n               (cfg_rst_n             ),//(i)
        .fir_en                  (fir_en                ),//(i)
        .readback0_vld           (readback0_vld         ),//(i)
        .readback0_last          (readback0_last        ),//(i)
        .readback0_data          (readback0_data        ),//(i)
        .coe_vld                 (coe_vld               ),//(o)
        .coe_sop                 (coe_sop               ),//(o)
        .coe_din                 (coe_din               ),//(o)
        .coe_fir_dec             (coe_fir_dec           ) //(o)
    );                                                   

    // -------------------------------------------------------------------------
    // fir_coe_reload Module Inst.
    // -------------------------------------------------------------------------
    fir_coe_reload #(                                           
        .COE_NUM                 (COE_NUM               ),
        .COE_WDTH                (COE_WDTH              ),
        .COE_NUM_HALF            (COE_NUM_HALF          )       
    )u_fir_coe_reload(   
        .cfg_clk                 (cfg_clk               ),//(i)
        .cfg_rst_n               (cfg_rst_n             ),//(i)
        .coe_vld                 (coe_vld               ),//(i)
        .coe_din                 (coe_din               ),//(i)
        .coe_sop                 (coe_sop               ),//(i)
        .coe_load                (coe_load              ),//(i)
        .coe_fir_dec             (coe_fir_dec           ),//(i)
        .clk                     (sys_clk               ),//(i)
        .rst_n                   (sys_rst_n             ),//(i)
        .fir_dec                 (fir_dec               ),//(o)
        .coe_arr                 (coe_arr               ) //(o)
    );                                                   


`ifdef    FIR_SYNTH  //====================================================================================================================

//-------------------------------------------------------------------------------------------------------------------------------------------------
//          fir_mean_filt             filter_dec              filter_fir_imp                   filter_dec                               rm_fir_dly                                 
// adc_vld  ------------- mean_vld    ---------- dec_vld      --------------- fir_vld          ---------- fir_dec_vld (fir_rm_dly_ivld) ----------  fir_rm_dly_ovld(fir_dout_vld) 
// adc_din  ------------- mean_data   ---------- dec_data     --------------- fir_data         ---------- fir_dec_data(fir_rm_dly_idat) ----------  fir_rm_dly_odat(fir_dout    ) 
// enc_din  ------------- enc_din_dly ---------- enc_din_dec  --------------- enc_din_dec_fir  ---------- fir_rm_dly_ienc               ----------  fir_rm_dly_oenc(enc_dout    ) 
//-------------------------------------------------------------------------------------------------------------------------------------------------


    cmip_bit_sync_imp #(                                    
        .DATA_WDTH               (1                    ),
        .BUS_DELAY               (3                    )
    )u0_cmip_bit_sync( 
        .i_dst_clk               (sys_clk              ),//(i)
        .i_din                   (soft_rst             ),//(i)
        .o_dout                  (soft_rst_sync        ) //(o)
    );                                                 

    cmip_bit_sync_imp #(                                    
        .DATA_WDTH               (1                    ),
        .BUS_DELAY               (3                    )
    )u1_cmip_bit_sync( 
        .i_dst_clk               (sys_clk              ),//(i)
        .i_din                   (fir_en               ),//(i)
        .o_dout                  (fir_en_sync          ) //(o)
    );                                                 

generate for(gj=0;gj<ADC_NUM;gj=gj+1)begin:gen_fir

    fir_mean_filt #(                                           
        .DATA_WD                 (ADC_WD                ),
        .DEC_WD                  (6                     )       
    )u_fir_mean_filt( 
        .clk                     (sys_clk               ),//(i)
        .rst_n                   (sys_rst_n             ),//(i)
        .soft_rst                (soft_rst_sync         ),//(i)
        .fir_en                  (fir_en_sync           ),//(i)
        .fir_dec                 (fir_dec[7:0]          ),//(i)
        .ivld                    (adc_vld               ),//(i)
        .idata                   (adc_din[gj]           ),//(i)
        .ovld                    (mean_vld[gj]          ),//(o)
        .odata                   (mean_data[gj]         ) //(o)
    );                                                   

    // -------------------------------------------------------------------------
    // First Dec Module Inst.
    // -------------------------------------------------------------------------
    filter_dec #(                                           
        .DATA_WD                 (ADC_WD                )       
    )u00_filter_dec( 
        .sys_clk                 (sys_clk               ),//(i)
        .sys_rst_n               (sys_rst_n             ),//(i)
        .cfg_rst                 (soft_rst_sync         ),//(i)
        .mode                    (fir_dec[7:0]          ),//(i)
        .din_valid               (mean_vld[0]           ),//(i)
        .din                     (mean_data[gj]         ),//(i)
        .dout_valid              (dec_vld[gj]           ),//(o)
        .dout                    (dec_data[gj]          ) //(o)
    );                                                  


    // -------------------------------------------------------------------------
    // filter_fir_imp Module Inst.
    // -------------------------------------------------------------------------
    filter_fir_imp #(                                     
        .COE_NUM                 (COE_NUM               ),
        .COE_WDTH                (COE_WDTH              ),
        .COE_NUM_HALF            (COE_NUM_HALF          ),
        //.XDATA_WDTH              (XDATA_WDTH            ),
        .XDATA_WDTH              (14                    ),
        .YDATA_WDTH              (YDATA_WDTH            ) 
    )u_filter_fir_imp(    
        .bypass                  (~fir_en_sync          ),//(i)
        .coe_arr                 (coe_arr               ),//(i)
        .clk                     (sys_clk               ),//(i)
        .rst_n                   (sys_rst_n             ),//(i)
        .xvld                    (dec_vld[0]            ),//(i)
        .xin                     (dec_data[gj]          ),//(i)
        .xin_16b                 (dec_data[gj]          ),//(i)
        .yvld                    (fir_vld[gj]           ),//(o)
        .yout                    (fir_data[gj]          ) //(o)
    );                                                     

    // -------------------------------------------------------------------------
    // Second Dec Module Inst.
    // -------------------------------------------------------------------------
    filter_dec #(                                           
        .DATA_WD                 (ADC_WD                )       
    )u01_filter_dec( 
        .sys_clk                 (sys_clk               ),//(i)
        .sys_rst_n               (sys_rst_n             ),//(i)
        .cfg_rst                 (soft_rst_sync         ),//(i)
        .mode                    (fir_dec[23:16]        ),//(i)
        .din_valid               (fir_vld[0]            ),//(i)
        .din                     (fir_data[gj]          ),//(i)
        .dout_valid              (fir_dec_vld[gj]       ),//(o)
        .dout                    (fir_dec_data[gj]      ) //(o)
    );                                                  

end
endgenerate


    wire           [63:0]         enc_din_dly            ;
    wire           [63:0]         enc_din_dec            ;
    wire           [63:0]         enc_din_dec_fir        ;
    cmip_bus_delay #(                                           
        .BUS_DELAY               (3                     ),
        .DATA_WDTH               (64                    ),
        .INIT_DATA               (0                     )       
    )u2_cmip_bus_delay( 
        .i_clk                   (sys_clk               ),//(i)
        .i_rst_n                 (sys_rst_n             ),//(i)
        .i_din                   (enc_din               ),//(i)
        .o_dout                  (enc_din_dly           ) //(o)
    );                                                   


    filter_dec #(                                           
        .DATA_WD                 (64                    )       
    )u10_filter_dec( 
        .sys_clk                 (sys_clk               ),//(i)
        .sys_rst_n               (sys_rst_n             ),//(i)
        .mode                    (fir_dec[7:0]          ),//(i)
        .cfg_rst                 (soft_rst_sync         ),//(i)
        .din_valid               (mean_vld[0]           ),//(i)
        .din                     (enc_din_dly           ),//(i)
        .dout_valid              (                      ),//(o)
        .dout                    (enc_din_dec           ) //(o)
    );      

    cmip_bus_delay #(                                           
        .BUS_DELAY               (5                     ),
        .DATA_WDTH               (64                    ),
        .INIT_DATA               (0                     )  
    )u3_cmip_bus_delay( 
        .i_clk                   (sys_clk               ),//(i)
        .i_rst_n                 (sys_rst_n             ),//(i)
        .i_din                   (enc_din_dec           ),//(i)
        .o_dout                  (enc_din_dec_fir       ) //(o)
    );                                                   

    filter_dec #(                                           
        .DATA_WD                 (64                    )       
    )u11_filter_dec( 
        .sys_clk                 (sys_clk               ),//(i)
        .sys_rst_n               (sys_rst_n             ),//(i)
        .mode                    (fir_dec[23:16]        ),//(i)
        .cfg_rst                 (soft_rst_sync         ),//(i)
        .din_valid               (fir_vld[0]            ),//(i)
        .din                     (enc_din_dec_fir       ),//(i)
        .dout_valid              (                      ),//(o)
        .dout                    (fir_rm_dly_ienc       ) //(o)
    );      

    // -------------------------------------------------------------------------
    // rm_fir_dly Module Inst.
    // -------------------------------------------------------------------------
    rm_fir_dly #(                                           
        .DATA_WD                 (512                   ),
        .HEAD_WD                 (64                    ),
        .BUS_DELAY               (COE_NUM_HALF          )       
    )u_rm_fir_dly(                                          
        .clk                     (sys_clk               ),//(i)
        .rst_n                   (sys_rst_n             ),//(i)
        .cfg_rst                 (soft_rst_sync         ),//(i)
        .fir_en                  (fir_en_sync           ),//(i)
        .fir_ivld                (fir_rm_dly_ivld       ),//(i)
        .fir_idat                (fir_rm_dly_idat       ),//(i)
        .enc_idat                (fir_rm_dly_ienc       ),//(i)
        .fir_ovld                (fir_rm_dly_ovld       ),//(o)
        .fir_odat                (fir_rm_dly_odat       ),//(o)
        .enc_odat                (fir_rm_dly_oenc       ) //(o)
    );                                                        

    assign             fir_dout_vld       =       fir_rm_dly_ovld  ;
    assign             fir_dout           =       fir_rm_dly_odat  ;
    assign             enc_dout           =       fir_rm_dly_oenc  ;

`else  //==================================================================`define   FIR_SYNTH==============

    assign             fir_dout_vld       =       fir_din_vld      ;
    assign             fir_dout           =       fir_din          ;
    assign             enc_dout           =       enc_din          ;


`endif ////==================================================================`define   FIR_SYNTH END=======




    // -------------------------------------------------------------------------
    // fir_coe_vio Module Inst.
    // -------------------------------------------------------------------------
    genvar                                gz                    ;
    wire             [COE_WDTH    -1:0]   coe [COE_NUM_HALF-1:0];
    generate
        for(gz=0; gz<COE_NUM_HALF;gz=gz+1) begin
            assign  coe[gz] = coe_arr[COE_WDTH*(gz+1)-1:COE_WDTH*gz];
        end
    endgenerate

/*
    fir_coe_vio u_fir_coe_vio (
        .clk                (sys_clk                ),//input wire clk
        .probe_in0          (coe[0 ]                ),//input wire [28 : 0] probe_in0
        .probe_in1          (coe[1 ]                ),//input wire [28 : 0] probe_in1
        .probe_in2          (coe[2 ]                ),//input wire [28 : 0] probe_in2
        .probe_in3          (coe[3 ]                ),//input wire [28 : 0] probe_in3
        .probe_in4          (coe[4 ]                ),//input wire [28 : 0] probe_in4
        .probe_in5          (coe[5 ]                ),//input wire [28 : 0] probe_in5
        .probe_in6          (coe[6 ]                ),//input wire [28 : 0] probe_in6
        .probe_in7          (coe[7 ]                ),//input wire [28 : 0] probe_in7
        .probe_in8          (coe[8 ]                ),//input wire [28 : 0] probe_in8
        .probe_in9          (coe[9 ]                ),//input wire [28 : 0] probe_in9
        .probe_in10         (coe[10]                ),//input wire [0 : 0] probe_in10
        .probe_in11         (coe[11]                ),//input wire [0 : 0] probe_in11
        .probe_in12         (coe[12]                ),//input wire [0 : 0] probe_in12
        .probe_in13         (coe[13]                ),//input wire [0 : 0] probe_in13
        .probe_in14         (coe[14]                ),//input wire [0 : 0] probe_in14
        .probe_in15         (coe[15]                ),//input wire [0 : 0] probe_in15
        .probe_in16         (coe[16]                ),//input wire [28 : 0] probe_in16
        .probe_in17         (coe[17]                ),//input wire [28 : 0] probe_in17
        .probe_in18         (coe[18]                ),//input wire [28 : 0] probe_in18
        .probe_in19         (fir_dec                ) //input wire [28 : 0] probe_in25
    );
*/


    assign      coe0        =        coe[0 ]        ;
    assign      coe1        =        coe[1 ]        ;
    assign      coe2        =        coe[2 ]        ;
    assign      coe3        =        coe[3 ]        ;
    assign      coe4        =        coe[4 ]        ;
    assign      coe5        =        coe[5 ]        ;
    assign      coe6        =        coe[6 ]        ;
    assign      coe7        =        coe[7 ]        ;
    assign      coe8        =        coe[8 ]        ;
    assign      coe9        =        coe[9 ]        ;
    assign      coe10       =        coe[10]        ;
    assign      coe11       =        coe[11]        ;
    assign      coe12       =        coe[12]        ;
    assign      coe13       =        coe[13]        ;
    assign      coe14       =        coe[14]        ;
    assign      coe15       =        coe[15]        ;
    assign      coe16       =        coe[16]        ;
    assign      coe17       =        coe[17]        ;
    assign      coe18       =        coe[18]        ;
    assign      coe_dec     =        fir_dec        ;


    // -------------------------------------------------------------------------
    // xwenc_chk  Module Inst.
    // -------------------------------------------------------------------------
    xwenc_chk  u_xwenc_chk(       
        .sys_clk         (sys_clk                   ),//(i)
        .sys_rst_n       (sys_rst_n                 ),//(i)
        .cfg_rst         (soft_rst_sync             ),//(i)
        .enc_vld         (fir_dout_vld              ),//(i)
        .xenc_din        (enc_dout[33:16]           ),//(i)
        .wenc_din        (enc_dout[51:34]           ),//(i)
                                                    
        .xenc_1st        (fir_xenc_1st              ),//(o)
        .wenc_1st        (fir_wenc_1st              ),//(o)
        .jp_pos_1st      (fir_jp_pos_1st            ),//(o)
        .jp_num          (fir_jp_num                ) //(o)
    );


endmodule

































