module fircoe_rd_burst #(
    parameter                               FIFO_DPTH       =  32          ,
    parameter                               FIFO_ADDR_WD    =  $clog2(FIFO_DPTH),
    parameter                               RD_DATA_WD      =  32          ,
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               BURST_LEN       =  8           ,
    parameter                               BASE_ADDR       =  32'h00000   ,
    parameter                               MAX_BLK_SIZE    =  32'h20000    //8MB
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
    input                                   rd_clk                         ,//(i)
    input                                   rd_rst_n                       ,//(i)
    input                                   cfg_rst                        ,//(i)

    input                                   ddr_rd0_en                     ,//(i)
    input               [32-1:0]            ddr_rd0_addr                   ,//(i)
    input                                   ddr_rd1_en                     ,//(i)
    input               [32-1:0]            ddr_rd1_addr                   ,//(i)
    output  reg                             readback0_vld                  ,//(o)
    output                                  readback0_last                 ,//(o)
    output  reg         [32-1:0]            readback0_data                 ,//(o)
    output  reg                             readback1_vld                  ,//(o)
    output                                  readback1_last                 ,//(o)
    output  reg         [32-1:0]            readback1_data                 ,//(o)

    output                                  rd_burst_req                   ,//(o)      
    output            [9:0]                 rd_burst_len                   ,//(o)  
    output            [DDR_ADDR_WD  -1:0]   rd_burst_addr                  ,//(o)    
    input                                   rd_burst_data_valid            ,//(i) 
    input             [DDR_DATA_WD  -1:0]   rd_burst_data                  ,//(o)
    input                                   rd_burst_finish                 //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam                              RATE              =  DDR_DATA_WD/RD_DATA_WD;
    localparam                              RATE_BITS         =  $clog2(RATE)      ;


    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                    dat_fifo_wr                     ;
    wire              [DDR_DATA_WD-1:0]     dat_fifo_din                    ;
    wire                                    dat_fifo_full                   ;
    wire                                    dat_fifo_rd                     ;
    wire              [RD_DATA_WD-1:0]      dat_fifo_dout                   ;
    wire                                    dat_fifo_empty                  ;
    reg                                     ddr_cfg_rst_d1                  ;   
    reg                                     ddr_cfg_rst_d2                  ;
    reg                                     rd_cfg_rst_d1                   ;   
    reg                                     rd_cfg_rst_d2                   ;  
    reg                                     dat_fifo_empty_d1               ;  
    reg                                     dat_fifo_empty_d2               ;  
    reg                                     dat_fifo_empty_d3               ;  
    wire                                    dat_fifo_empty_neg              ;
    reg               [2:0]                 sta                             ;
    wire                                    last_sync                       ;//ddr clk
    
    reg                                     addr_fifo_wr                    ;
    reg               [31:0]                addr_fifo_din                   ;
    wire                                    addr_fifo_rd                    ;
    wire              [31:0]                addr_fifo_dout                  ;
    wire                                    addr_fifo_full                  ;
    wire                                    addr_fifo_empty                 ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            dat_fifo_wr   =      rd_burst_data_valid              ;//ddr_clk
    // assign            dat_fifo_din  =      byte_adj(rd_burst_data)          ;//ddr_clk
    assign            dat_fifo_din  =      rd_burst_data                    ;//ddr_clk
    assign            dat_fifo_rd   =     ~dat_fifo_empty                   ;//rd_clk
    assign            readback0_last=      readback0_vld && dat_fifo_empty  ;//rd_clk
    assign            readback1_last=      readback1_vld && dat_fifo_empty  ;//rd_clk



    assign            rd_burst_req       =   sta == 3'd1                      ;//ddr_clk //notice
    assign            rd_burst_len       =   BURST_LEN                        ;//ddr_clk
    assign            rd_burst_addr      =   BASE_ADDR + {addr_fifo_dout[25:0],1'd0,3'd0};//ddr_clk
    assign            addr_fifo_rd       =   sta == 3'd3                      ;//ddr_clk

// =================================================================================================
// RTL Body
// ================================================================================================
    always@(posedge ddr_clk)begin
        ddr_cfg_rst_d1 <= cfg_rst   ;
        ddr_cfg_rst_d2 <= ddr_cfg_rst_d1;
    end

    always@(posedge rd_clk)begin
        rd_cfg_rst_d1 <= cfg_rst   ;
        rd_cfg_rst_d2 <= rd_cfg_rst_d1;
    end

    // -------------------------------------------------------------------------
    // cmip_sync_reg_fifo  Module Inst.
    // -------------------------------------------------------------------------
    cmip_async_fifo #(                                  
        .DPTH            (32                         ),
        .DATA_WDTH       (32                         ),
        .FWFT            (1                          )       
    )u_cmip_async_fifo(      
        .i_rd_clk        (ddr_clk                     ),
        .i_wr_clk        (rd_clk                      ),
        .i_rd_rst_n      (ddr_rst_n  && (~ddr_cfg_rst_d2)),
        .i_wr_rst_n      (rd_rst_n   && (~rd_cfg_rst_d2 )),
        
        .i_aful_th       (4                          ),//(i)
        .i_amty_th       (4                          ),//(i)
        .i_wr            (addr_fifo_wr               ),//(i)
        .i_din           (addr_fifo_din              ),//(i)
        .i_rd            (addr_fifo_rd               ),//(i)
        .o_dout          (addr_fifo_dout             ),//(o)
        .o_aful          (addr_fifo_full             ),//(o)
        .o_amty          (                           ),//(o)
        .o_full          (                           ),//(o)
        .o_empty         (addr_fifo_empty            ) //(o)
    );                                               

    always@(posedge rd_clk or negedge rd_rst_n)begin
        if(~rd_rst_n)begin
            addr_fifo_wr  <=  1'b0        ;
            addr_fifo_din <=  32'b0       ;
        end else if(ddr_rd0_en)begin
            addr_fifo_wr  <=  1'b1        ;
            addr_fifo_din <= {1'b0,ddr_rd0_addr[30:0]};
        end else if(ddr_rd1_en)begin
            addr_fifo_wr  <=  1'b1        ;
            addr_fifo_din <= {1'b1,ddr_rd1_addr[30:0]};
        end else begin
            addr_fifo_wr  <=  1'b0        ;
            addr_fifo_din <= addr_fifo_din;
        end
    end


    // -------------------------------------------------------------------------
    // cmip_afifo_wd_conv_rswl  Module Inst.
    // -------------------------------------------------------------------------
    cmip_afifo_wd_conv_rswl #(
        .DPTH            (FIFO_DPTH                  ),
        .WR_DATA_WD      (DDR_DATA_WD                ),
        .RD_DATA_WD      (RD_DATA_WD                 ),
        .FWFT            (1                          )
    )u_rd_dat_fifo(             
        .i_rd_clk        (rd_clk                     ),
        .i_wr_clk        (ddr_clk                    ),
        .i_rd_rst_n      (rd_rst_n   && (~rd_cfg_rst_d2 )),
        .i_wr_rst_n      (ddr_rst_n  && (~ddr_cfg_rst_d2)),
        .i_wr            (dat_fifo_wr                ),
        .i_din           (dat_fifo_din               ),
        .i_rd            (dat_fifo_rd                ),
        .o_dout          (dat_fifo_dout              ),
        .o_full          (dat_fifo_full              ),
        .o_empty         (dat_fifo_empty             ),
        .o_wr_cnt        (                           ),
        .o_rd_cnt        (                           )
    );

    always@(posedge rd_clk or negedge rd_rst_n)begin
        if(~rd_rst_n)begin
            readback0_vld  <= 'd0;
            readback0_data <= 'd0;
        end else begin
            readback0_vld  <= ~addr_fifo_dout[31] && dat_fifo_rd;
            readback0_data <= dat_fifo_dout;
        end
    end

    always@(posedge rd_clk or negedge rd_rst_n)begin
        if(~rd_rst_n)begin
            readback1_vld  <= 'd0;
            readback1_data <= 'd0;
        end else begin
            readback1_vld  <= addr_fifo_dout[31] && dat_fifo_rd;
            readback1_data <= dat_fifo_dout;
        end
    end


    always@(posedge ddr_clk or negedge ddr_rst_n)begin
        if(~ddr_rst_n)
            sta <= 'd0;
        else case(sta)
            3'd0:if(~addr_fifo_empty) sta <= 3'd1;
            3'd1:if(rd_burst_finish ) sta <= 3'd2;
            3'd2:if(last_sync       ) sta <= 3'd3;
            3'd3:sta <= 3'd4;
            3'd4:sta <= 3'd0;
        endcase
    end

    // -------------------------------------------------------------------------
    // cmip_afifo_wd_conv_rswl  Module Inst.
    // -------------------------------------------------------------------------
    cmip_pulse_sync u_cmip_pulse_sync(
        .i_src_clk             (rd_clk                          ),   //
        .i_src_rst_n           (rd_rst_n                        ),   //
        .i_dst_clk             (ddr_clk                         ),   //
        .i_dst_rst_n           (ddr_rst_n                       ),   //
        .i_pulse               (readback0_last || readback1_last),   //
        .o_pulse               (last_sync                       )    //
    );



    function automatic [DDR_DATA_WD -1:0] byte_adj(
        input          [DDR_DATA_WD -1:0]     a   
    );begin:abc
        integer i;
        for(i=1;i<=RATE;i=i+1)begin
            byte_adj[i*RD_DATA_WD -1 -:RD_DATA_WD] = a[(RATE + 1 - i)*RD_DATA_WD -1 -: RD_DATA_WD];
        end
    end
    endfunction








endmodule





