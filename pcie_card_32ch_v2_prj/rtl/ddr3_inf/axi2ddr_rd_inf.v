// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : axi_rd_native.v
// Module         : axi_rd_native
// Function       : 
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2023/09/28   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================


module axi2ddr_rd_inf #(
    parameter                               FIFO_DPTH       =  1024        ,
    parameter                               AXI_DATA_WD     =  128         ,
    parameter                               AXI_ADDR_WD     =  64          ,
    parameter                               DDR_DATA_WD     =  512         ,
    parameter                               DDR_ADDR_WD     =  32          ,
    parameter                               DGBCNT_EN       =   1          ,
    parameter                               DGBCNT_WD       =  16          ,
    parameter                               MAX_BLK_SIZE    =  32'h1000    
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
    input                                   axi_clk                        ,//(i)
    input                                   axi_rst_n                      ,//(i)
    input                                   cfg_rst                        ,//(i)

(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input             [AXI_ADDR_WD  -1:0]   s_axi_araddr                   ,//(i)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input             [ 1:0]                s_axi_arburst                  ,//(i)
                                        input             [ 3:0]                s_axi_arcache                  ,//(i)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input             [ 3:0]                s_axi_arid                     ,//(i)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input             [ 7:0]                s_axi_arlen                    ,//(i)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input                                   s_axi_arlock                   ,//(i)
                                        input             [ 2:0]                s_axi_arprot                   ,//(i)
                                        input             [ 3:0]                s_axi_arqos                    ,//(i)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input                                   s_axi_arvalid                  ,//(i)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output                                  s_axi_arready                  ,//(o)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input             [ 2:0]                s_axi_arsize                   ,//(i)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input                                   s_axi_aruser                   ,//(i)
                                       
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output            [AXI_DATA_WD  -1:0]   s_axi_rdata                    ,//(o)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output                                  s_axi_rvalid                   ,//(o)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)input                                   s_axi_rready                   ,//(i)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output                                  s_axi_rlast                    ,//(o)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output            [ 1:0]                s_axi_rresp                    ,//(o)
(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)output            [ 3:0]                s_axi_rid                      ,//(o)
    
    input             [DDR_ADDR_WD  -1:0]   avail_addr                     ,//(i) 
    output                                  rd_burst_req                   ,//(o)      
    output            [9:0]                 rd_burst_len                   ,//(o)  
    output            [DDR_ADDR_WD  -1:0]   rd_burst_addr                  ,//(o)    
    input                                   rd_burst_data_valid            ,//(i) 
    input             [DDR_DATA_WD  -1:0]   rd_burst_data                  ,//(o)
    input                                   rd_burst_finish                ,//(i)

                                        input             [6:0]                 cfg_irq_clr_cnt                ,//(i)
                                        output    reg                           rd_8m_irq_en                   ,//(o)
                                        input                                   rd_8m_irq_clr                  ,//(i)
                                        output    reg     [DDR_ADDR_WD-1:0]     rd_blk_cnt                     ,//(o)
                                        output            [DDR_ADDR_WD-1:0]     rd_blk_irq_cnt                 ,//(o)
                                        output            [31:0]                adc_chk_suc_cnt                ,//(o)
                                        output            [31:0]                adc_chk_err_cnt                ,//(o)
                                        output            [31:0]                enc_chk_suc_cnt                ,//(o)
                                        output            [31:0]                enc_chk_err_cnt                ,//(o)
                                        output            [31:0]                dr_adc_chk_suc_cnt             ,//(o)
                                        output            [31:0]                dr_adc_chk_err_cnt             ,//(o)
                                        output            [31:0]                dr_enc_chk_suc_cnt             ,//(o)
                                        output            [31:0]                dr_enc_chk_err_cnt              //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam                              DAT_FIFO_DP       =  4096              ;
    localparam                              BURST_LEN         =  32'd64            ;
    localparam                              RATE              =  DDR_DATA_WD/AXI_DATA_WD;
    localparam                              RATE_BITS         =  $clog2(RATE)      ;
    localparam                              IRQ_SIZE          =  32'd262144;   //32'd262144;//8MB Notice: 128bit one clk
    //localparam                              IRQ_SIZE          =  32'd128           ;//32'd131072;//8MB  128//SIM
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
	wire                                    ddr_cfg_rst                     ;
	wire                                    axi_cfg_rst                     ;
    wire                                    dat_fifo_wr                     ;
    wire              [DDR_DATA_WD-1:0]     dat_fifo_din                    ;
    wire                                    dat_fifo_rd                     ;
    wire              [AXI_DATA_WD-1:0]     dat_fifo_dout                   ;
    wire                                    dat_fifo_full                   ;
    wire                                    dat_fifo_empty                  ;
    reg               [7:0]                 rd_cnt                          ;
    reg               [7:0]                 arlen_lock                      ;
    reg                                     arready_en                      ;
    wire                                    rd_8m_irq_clr_dly               ;
    reg               [DDR_ADDR_WD-1:0]     blk_irq_cnt                     ;
	reg               [31           :0]     rd_irq_cnt                      ;
    (* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)wire                                    irq_trig                        ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            dat_fifo_wr   =      rd_burst_data_valid              ;//ddr_clk
    assign            dat_fifo_din  =      byte_adj(rd_burst_data)          ;//ddr_clk
    assign            s_axi_rvalid  =     ~dat_fifo_empty && arready_en     ;//axi_clk
    assign            s_axi_arready =     ~dat_fifo_empty && (~arready_en)  ;//axi_clk
    assign            dat_fifo_rd   =      s_axi_rvalid && s_axi_rready     ;//axi_clk

    assign            rd_burst_req     =  ~dat_fifo_full && (avail_addr >= BURST_LEN);//ddr_clk //notice
    assign            rd_burst_len     =   BURST_LEN                        ;//ddr_clk
    assign            rd_burst_addr    =   {rd_blk_cnt,3'd0}                   ;//ddr_clk
    assign            s_axi_rdata      =   dat_fifo_dout                    ;//axi_clk
    assign            s_axi_rlast      =   (rd_cnt == arlen_lock)           ;//axi_clk
    assign            s_axi_rresp      =   2'b0                             ;//axi_clk
    assign            s_axi_rid        =   4'b0                             ;//axi_clk
    assign            irq_trig         =   s_axi_rlast && dat_fifo_rd && (blk_irq_cnt>=IRQ_SIZE);//8MB
    assign            rd_blk_irq_cnt   =   rd_irq_cnt                       ;


// =================================================================================================
// RTL Body
// ================================================================================================


   xpm_cdc_async_rst #(
      .DEST_SYNC_FF(4),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
   )u0_xpm_cdc_async_rst (
      .dest_arst(ddr_cfg_rst  ), 
      .dest_clk (ddr_clk      ),   // 1-bit input: Destination clock.
      .src_arst (cfg_rst      )    // 1-bit input: Source asynchronous reset signal.
   );
   
   xpm_cdc_async_rst #(
      .DEST_SYNC_FF(4),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
   )u1_xpm_cdc_async_rst (
      .dest_arst(axi_cfg_rst  ), 
      .dest_clk (axi_clk      ),   // 1-bit input: Destination clock.
      .src_arst (cfg_rst      )    // 1-bit input: Source asynchronous reset signal.
   );


    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)begin
            arlen_lock <= 8'hff;
        end else if(axi_cfg_rst)begin
            arlen_lock <= 8'hff;
        end else if(s_axi_arvalid && s_axi_arready)begin
            arlen_lock <= s_axi_arlen;
        end
    end

    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)begin
            rd_cnt     <= 8'h00;
        end else if(axi_cfg_rst)begin
            rd_cnt     <= 8'd0 ;
        end else if(s_axi_rlast && dat_fifo_rd)begin
            rd_cnt     <= 8'd0 ;
        end else if(dat_fifo_rd)begin
            rd_cnt <= rd_cnt + 1'b1;
        end
    end

    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)begin
            arready_en <= 1'b0;
        end else if(axi_cfg_rst)begin
            arready_en <= 1'b0;
        end else if(s_axi_rlast && dat_fifo_rd)begin
            arready_en <= 1'b0;
        end else if(s_axi_arvalid && s_axi_arready)begin
            arready_en <= 1'b1;
        end
    end

    //notice:1 block == 512bits
    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            rd_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(ddr_cfg_rst)
            rd_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(rd_burst_finish && (rd_blk_cnt >= MAX_BLK_SIZE - BURST_LEN))
            rd_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(rd_burst_finish)
            rd_blk_cnt <= rd_blk_cnt + BURST_LEN;
    end

    
    
    rd_dat_fifo u_rd_dat_fifo (
	    .rst          (ddr_cfg_rst                ),
        .wr_clk       (ddr_clk                    ),
        //.wr_rst       (~ddr_rst_n || cfg_rst      ),
        .rd_clk       (axi_clk                    ),
        //.rd_rst       (~axi_rst_n || cfg_rst      ),
        .din          (dat_fifo_din               ),
        .wr_en        (dat_fifo_wr                ),
        .rd_en        (dat_fifo_rd                ),
        .dout         (dat_fifo_dout              ),
        .full         (                           ),
        .prog_full    (dat_fifo_full              ),
        .empty        (dat_fifo_empty             ) 
    );


    function automatic [DDR_DATA_WD -1:0] byte_adj(
        input          [DDR_DATA_WD -1:0]     a   
    );begin:abc
        integer i;
        for(i=1;i<=RATE;i=i+1)begin
            byte_adj[i*AXI_DATA_WD -1 -:AXI_DATA_WD] = a[(RATE + 1 - i)*AXI_DATA_WD -1 -: AXI_DATA_WD];
        end
    end
    endfunction


    //---------------------interrupt-----------------------------------------------------------//
    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)
            blk_irq_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(axi_cfg_rst)
            blk_irq_cnt <= {DDR_ADDR_WD{1'b0}};
		else if(irq_trig)
            blk_irq_cnt <= blk_irq_cnt - IRQ_SIZE;
        else if(s_axi_arvalid && s_axi_arready)
            blk_irq_cnt <= blk_irq_cnt + s_axi_arlen + 1'b1;
    end


    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)
            rd_irq_cnt <= {32{1'b0}};
        else if(axi_cfg_rst)
            rd_irq_cnt <= {32{1'b0}};
        else if(irq_trig)
            rd_irq_cnt <= rd_irq_cnt + 1'b1;
    end


/*
    reg  [31:0]              irq_time_cnt;
    always@(posedge axi_clk or negedge axi_rst_n)begin //250M
        if(~axi_rst_n)
            irq_time_cnt <= 32'd0;
        //else if(irq_time_cnt >= 32'd2500000)
        else if(irq_time_cnt >= 32'd125000)
            irq_time_cnt <= 32'd0;
        else if(irq_trig)
            irq_time_cnt <= 32'd1;
        else if(|irq_time_cnt)
            irq_time_cnt <= irq_time_cnt + 1'b1;
     end
     assign  rd_8m_irq_clr_dly =  (irq_time_cnt >= 32'd125000) ? 1'b1 : 1'b0;
*/  

    reg   [7:0]    rd_8m_irq_clr_cnt;
    always@(posedge axi_clk or negedge axi_rst_n)begin //250M
	    if(~axi_rst_n)
		    rd_8m_irq_clr_cnt <= 8'b0;
		else if(rd_8m_irq_clr)
		    rd_8m_irq_clr_cnt <= rd_8m_irq_clr_cnt + 8'b1;
		else if(rd_8m_irq_clr_dly)
		    rd_8m_irq_clr_cnt <= 8'b0;
    end

    assign  rd_8m_irq_clr_dly =  (rd_8m_irq_clr_cnt >= cfg_irq_clr_cnt) ? 1'b1 : 1'b0;


    always@(posedge axi_clk or negedge axi_rst_n)begin
        if(~axi_rst_n)
            rd_8m_irq_en <= 1'b0;
		else if(axi_cfg_rst)
		    rd_8m_irq_en <= 1'b0;
        else if(irq_trig)
            rd_8m_irq_en <= 1'b1;
        else if(rd_8m_irq_clr_dly)
            rd_8m_irq_en <= 1'b0;
    end    


    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------  
    ddr_20g_chk_top u_ddr_20g_chk_top(
        .clk                            (axi_clk               ),//(i)
        .rst_n                          (axi_rst_n             ),//(i)
        .cfg_rst                        (axi_cfg_rst           ),//(i)
														       
        .s_axis_tdata                   (dat_fifo_dout         ),//(o)
        .s_axis_tvalid                  (dat_fifo_rd           ),//(o)
        .adc_chk_suc_cnt                (adc_chk_suc_cnt       ),//(o)
        .adc_chk_err_cnt                (adc_chk_err_cnt       ),//(o)
        .enc_chk_suc_cnt                (enc_chk_suc_cnt       ),//(o)
        .enc_chk_err_cnt                (enc_chk_err_cnt       ) //(o)
    );

    ddr_512b_chk_top u_ddr_512b_chk_top( 
        .clk                           (ddr_clk               ),//(i)
        .rst_n                         (ddr_rst_n             ),//(i)
        .cfg_rst                       (ddr_cfg_rst           ),//(i)
        .s_axis_tdata                  (rd_burst_data         ),//(i)
        .s_axis_tvalid                 (rd_burst_data_valid   ),//(i)
        .adc_chk_suc_cnt               (dr_adc_chk_suc_cnt    ),//(o)
        .adc_chk_err_cnt               (dr_adc_chk_err_cnt    ),//(o)
        .enc_chk_suc_cnt               (dr_enc_chk_suc_cnt    ),//(o)
        .enc_chk_err_cnt               (dr_enc_chk_err_cnt    ) //(o)
    );    






endmodule





