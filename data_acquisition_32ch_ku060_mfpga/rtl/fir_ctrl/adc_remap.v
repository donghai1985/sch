module adc_remap #(
    parameter                              DATA_WD           =      512         ,
    parameter                              HEAD_WD           =      64          
)(       
    input                                  clk                                  ,//(i)
    input                                  rst_n                                ,//(i)
    input                                  cfg_rst                              ,//(i)
    input                                  remap_en                             ,//(i)
    input                                  map_ivld                             ,//(i)
    input             [DATA_WD     -1:0]   map_idat                             ,//(i)
    input             [HEAD_WD     -1:0]   enc_idat                             ,//(i)
    output  reg                            map_ovld                             ,//(o)
    output  reg       [DATA_WD     -1:0]   map_odat                             ,//(o)
    output  reg       [HEAD_WD     -1:0]   enc_odat                              //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                             map_NUM             =      32          ;
    //--------------------------------------------------------------------------       
    // Defination of Internal Signals       
    //--------------------------------------------------------------------------       
    genvar                                 gi,gj                                ;
    integer                                i                                    ;
    wire                                   remap_en_sync                        ;
    wire              [15:0]               map_data     [map_NUM-1:0]           ;
    reg                                    map_ivld_d1                          ;
    reg               [15:0]               map_data_d1  [map_NUM-1:0]           ;
    reg               [63:0]               enc_idat_d1                          ;
    wire              [511:0]              map_res                              ;


    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    
generate
    for(gi=0; gi<map_NUM;gi=gi+1) begin:PART1
        assign  map_data[gi]                 =  map_idat[16*(gi+1)-1:16*gi];//notice
        assign  map_res[16*(gi+1)-1:16*gi]   =  remap_en_sync ? map_data_d1[map_NUM -1 -gi] : map_data_d1[gi];
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
        .i_din                   (remap_en             ),//(i)
        .o_dout                  (remap_en_sync        ) //(o)
    );                                                 
    

    always@(posedge clk )begin
            map_ivld_d1    <= map_ivld      ;
            enc_idat_d1    <= enc_idat      ;
        for(i=0;i<map_NUM;i=i+1)begin
            map_data_d1[i] <= map_data[i];
        end 
    end




    always@(posedge clk)begin
            map_ovld  <= map_ivld_d1;           
            enc_odat  <= enc_idat_d1;
            map_odat  <= map_res    ;
    end
















endmodule





















































