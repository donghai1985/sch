`timescale 1ns / 1ps       
module ddr3_ram_model #(
    parameter                              ROUTE                 =     0  ,
    parameter                              ADDR_WIDTH            =  ROUTE ? 10 : 16        
)(
    input                                  sim_ddr_clk                    ,//(i)
    output    reg                          clk                            ,//(i)
    input                                  rst_n                          ,//(i)

    input          [ADDR_WIDTH-1:0]        app_addr                       ,//(i)
    input          [2:0]                   app_cmd                        ,//(i)
    input                                  app_en                         ,//(i)
    input          [511:0]                 app_wdf_data                   ,//(i)
    input                                  app_wdf_end                    ,//(i)
    input                                  app_wdf_wren                   ,//(i)
    output         [511:0]                 app_rd_data                    ,//(o)
    output                                 app_rd_data_valid              ,//(o)
    output                                 app_rdy                        ,//(o)
    output                                 app_wdf_rdy                    ,//(o)
    output                                 init_calib_complete             //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    parameter      ADDR_WDTH           =   ADDR_WIDTH                    ;
    parameter      DPTH                =   2 ** ADDR_WDTH                ;
    parameter      DATA_WDTH           =   512                           ;
    parameter      READ_LATENCY        =   4                             ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                   i_wr                          ; 
    wire                                   i_cs                          ;
    wire           [ADDR_WDTH-1:0]         i_addr                        ; 
    wire           [DATA_WDTH-1:0]         i_wdata                       ; 
    reg            [9          :0]         cnt             =   0         ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign         i_wr          =        (app_cmd == 3'd0)              ; 
    assign         i_cs          =         app_en                        ; 
    assign         i_addr        =         app_addr                      ; 
    assign         i_wdata       =         app_wdf_data                  ; 
    assign         app_rdy       =         1'b1                          ;
    assign         app_wdf_rdy   =         1'b1                          ;

    assign    init_calib_complete=         &cnt                          ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge clk) begin
        if(&cnt)
            cnt <= cnt;
        else
            cnt <= cnt + 1'b1;
    end


    cmip_1rw_mem_wrapper #(
        .DPTH                 (DPTH               ),
        .DATA_WDTH            (DATA_WDTH          ),
        .ADDR_WDTH            (ADDR_WDTH          ),
        .READ_LATENCY         (READ_LATENCY       )
    )u_1rw_men_wrapper(                               
        .i_clk                (clk                ),  
        .i_wr                 (i_wr               ),
        .i_cs                 (i_cs               ),  
        .i_addr               (i_addr             ), 
        .i_wdata              (i_wdata            ), 
        .o_rdata              (app_rd_data        )
    );

    cmip_bus_delay #(
        .BUS_DELAY            (READ_LATENCY       ),
        .DATA_WDTH            (1                  ),
        .INIT_DATA            (0                  )
    )u_cmip_bus_delay(                              
        .i_clk                (clk                ), 
        .i_rst_n              (rst_n              ), //low valid
        .i_din                (i_cs && (~i_wr)    ),
        .o_dout               (app_rd_data_valid  )
    );


    initial begin
        clk  =  0;
    end
 
 
generate if(ROUTE == 0) begin
    always #4    clk                   = ~ clk                 ;
end else begin
    always@(*)
        clk = sim_ddr_clk;
end
endgenerate




endmodule





