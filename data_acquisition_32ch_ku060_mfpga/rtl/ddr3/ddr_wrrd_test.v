// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : ddr_wrrd_test.v
// Module         : ddr_wrrd_test
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


module ddr_wrrd_test #(
    parameter                               DDR_ADDR_WD     =  32                ,
    parameter                               DDR_DATA_WD     =  512               ,
    parameter                               BASE_ADDR       =  32'h0000          ,
    parameter                               MAX_BLK_SIZE    =  32'h1000          
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
    input                                   cfg_rst                        ,//(i)
    input                                   cfg_test_en                    ,//(i)
    input             [9:0]                 cfg_burst_len                  ,//(i)
    output   reg      [31:0]                sts_suc_cnt                    ,//(o)
    output   reg      [31:0]                sts_err_cnt                    ,//(o)
    output   reg                            sts_err_lock                   ,//(o)

/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/output                                  wr_burst_req                   ,//(o)      
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/output            [9:0]                 wr_burst_len                   ,//(o)  
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/output            [DDR_ADDR_WD  -1:0]   wr_burst_addr                  ,//(o)    
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/input                                   wr_burst_data_req              ,//(i) 
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/output            [DDR_DATA_WD  -1:0]   wr_burst_data                  ,//(o)
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/input                                   wr_burst_finish                ,//(i)
/*                                        */
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/output                                  rd_burst_req                   ,//(o)      
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/output            [9:0]                 rd_burst_len                   ,//(o)  
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/output            [DDR_ADDR_WD  -1:0]   rd_burst_addr                  ,//(o)    
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/input                                   rd_burst_data_valid            ,//(i) 
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/input             [DDR_DATA_WD  -1:0]   rd_burst_data                  ,//(o)
/*(* KEEP = "TRUE", MARK_DEBUG = "TRUE" *)*/input                                   rd_burst_finish                 //(i)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam                              IDLE              =       2'h0         ;
    localparam                              DDRWR             =       2'h1         ;
    localparam                              DDRRD             =       2'h2         ;
    localparam                              MAX_BLK_SIZE_M1   =  MAX_BLK_SIZE - 1  ;        
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg              [15:0]                 wr_cnt                         ;
    reg              [15:0]                 rd_cnt                         ;
    reg              [1 :0]                 sta                            ;
    wire                                    test_en_sync                   ;
    reg                                     test_en_sync_d1                ;
    wire                                    cfg_rst_sync                   ;
    wire                                    test_en_pos                    ;
    wire             [9 :0]                 burst_len_sync                 ;
    reg              [DDR_ADDR_WD-1:0]      wr_blk_cnt                     ;
    reg              [DDR_ADDR_WD-1:0]      rd_blk_cnt                     ;
    wire                                    chk_data_ok                    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            test_en_pos     =    ~test_en_sync_d1 && test_en_sync;
    assign            wr_burst_req    =     (sta == DDRWR)                 ;
    assign            wr_burst_len    =     burst_len_sync                 ;
    assign            wr_burst_addr   =     BASE_ADDR + {wr_blk_cnt,3'd0}  ;
    assign            wr_burst_data   =     {32{wr_cnt}}                   ;

    assign            rd_burst_req    =     (sta == DDRRD)                 ;
    assign            rd_burst_len    =     burst_len_sync                 ;
    assign            rd_burst_addr   =     BASE_ADDR + {rd_blk_cnt,3'd0}  ;
    assign            chk_data_ok     =     rd_burst_data == {32{rd_cnt}}  ;
// =================================================================================================
// RTL Body
// =================================================================================================



    cmip_bit_sync #(
        .DATA_WDTH  (1               )
    )u0_cmip_bit_sync(                 
        .i_dst_clk  (ddr_clk         ),    
        .i_din      (cfg_test_en     ),      
        .o_dout     (test_en_sync    )       
    );

    cmip_bit_sync #(
        .DATA_WDTH  (10              )
    )u1_cmip_bit_sync(                 
        .i_dst_clk  (ddr_clk         ),    
        .i_din      (cfg_burst_len   ),      
        .o_dout     (burst_len_sync  )       
    );

    cmip_bit_sync #(
        .DATA_WDTH  (1               )
    )u2_cmip_bit_sync(                 
        .i_dst_clk  (ddr_clk         ),    
        .i_din      (cfg_rst         ),      
        .o_dout     (cfg_rst_sync    )       
    );

    always@(posedge ddr_clk)begin
        test_en_sync_d1 <= test_en_sync;
    end

    // -------------------------------------------------------------------------
    // FSM logic.
    // -------------------------------------------------------------------------
    always@(posedge ddr_clk or negedge ddr_rst_n)
        if(!ddr_rst_n)begin
            sta <= IDLE;
        end else begin
            case(sta)
            IDLE :if(test_en_pos)
                      sta <= DDRWR ;
                  else
                      sta <= IDLE  ;
            DDRWR:if(wr_burst_finish)
                      sta <= DDRRD ;
                  else 
                      sta <= DDRWR ;
            DDRRD:if(rd_burst_finish && test_en_sync)
                      sta <= DDRWR ;
                  else if(rd_burst_finish && (~test_en_sync))
                      sta <= IDLE  ;
                  else 
                      sta <= DDRRD ; 
            default:  sta <= IDLE  ;
            endcase
        end


    //-------------------wr logic------------------------------------------------------//
    //notice:1 block == 512bits
    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            wr_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(cfg_rst_sync || test_en_pos)
            wr_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(wr_burst_finish && (wr_blk_cnt >= MAX_BLK_SIZE - burst_len_sync))
            wr_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(wr_burst_finish)
            wr_blk_cnt <= wr_blk_cnt + burst_len_sync;
    end

    always @(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            wr_cnt <= 16'd0;
        else if(cfg_rst_sync || test_en_pos)
            wr_cnt <= 16'd0;
        else if(wr_burst_data_req)
            wr_cnt <= wr_cnt + 1'b1;
    end

    //-------------------rd logic------------------------------------------------------//
    //notice:1 block == 512bits
    always@(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            rd_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(cfg_rst_sync || test_en_pos)
            rd_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(rd_burst_finish && (rd_blk_cnt >= MAX_BLK_SIZE - burst_len_sync))
            rd_blk_cnt <= {DDR_ADDR_WD{1'b0}};
        else if(rd_burst_finish)
            rd_blk_cnt <= rd_blk_cnt + burst_len_sync;
    end

    always @(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            rd_cnt <= 16'd0;
        else if(cfg_rst_sync || test_en_pos)
            rd_cnt <= 16'd0;
        else if(rd_burst_data_valid)
            rd_cnt <= rd_cnt + 1'b1;
    end

    //-------------------check logic------------------------------------------------------//
    always @(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)begin
            sts_suc_cnt <= 32'd0;
        end else if(cfg_rst_sync || test_en_pos)begin
            sts_suc_cnt <= 32'd0;
        end else if(rd_burst_data_valid && chk_data_ok)begin
            sts_suc_cnt <= sts_suc_cnt + 1'b1;
        end
    end

    always @(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)begin
            sts_err_cnt <= 32'd0;
        end else if(cfg_rst_sync || test_en_pos)begin
            sts_err_cnt <= 32'd0;
        end else if(rd_burst_data_valid && (~chk_data_ok))begin
            sts_err_cnt <= sts_err_cnt + 1'b1;
        end
    end

    always @(posedge ddr_clk or negedge ddr_rst_n) begin
        if(~ddr_rst_n)
            sts_err_lock <= 1'b0;
        else if(cfg_rst_sync || test_en_pos)
            sts_err_lock <= 1'b0;
        else if(sts_err_cnt == 32'd1)
            sts_err_lock <= 1'b1;
    end




endmodule





