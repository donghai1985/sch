// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : axidma_wr_fsm.v
// Module         : axidma_wr_fsm
// Function       : 
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2022/12/15   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================



module axidma_wr_fsm #(
    parameter                               LEN_WDTH    =  32              ,
    parameter                               DATA_WDTH   =  32              ,
    parameter                               ADDR_WDTH   =  32              
)(
    input                                   sys_clk                        ,//(i)
    input                                   sys_rst_n                      ,//(i)

    input             [7:0]                 cfg_wburst_len                 ,//(i)
    input                                   cfg_wsoft_rst                  ,//(i)
    input                                   cfg_wstart                     ,//(i)
    input             [ADDR_WDTH-1:0]       cfg_waddr                      ,//(i)
    input             [LEN_WDTH -1:0]       cfg_wlen                       ,//(i)
    output                                  cfg_widle                      ,//(o)
    output  reg       [LEN_WDTH -1:0]       cfg_wr_times                   ,//(o)
    input                                   cfg_wirq_en                    ,//(i)
    input                                   cfg_wirq_clr                   ,//(i)
    output  reg                             wirq                           ,//(o)

    output  reg                             wstart_vld                     ,//(i)
    input                                   wstart_rdy                     ,//(o)
    output  reg       [ADDR_WDTH-1:0]       waddr                          ,//(i)
    output  reg       [7:0]                 wburst_len                      //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------   
    localparam                              BIT       = $clog2(DATA_WDTH/8);
    localparam                              IDLE      =     4'h0           ;
    localparam                              FRST      =     4'h1           ;
    localparam                              TAP       =     4'h2           ;
    localparam                              WAIT      =     4'h4           ;
    localparam                              REQ       =     4'h8           ;

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg               [3:0]                 fsm_st                         ;
    reg               [7:0]                 cfg_wburst_len_t1              ;
    reg               [ADDR_WDTH-1:0]       cfg_waddr_t1                   ;
    reg               [ADDR_WDTH-1:0]       cfg_waddr_req                  ;
    reg               [LEN_WDTH -1:0]       cfg_wlen_t1                    ;
    reg                                     cfg_wstart_d1                  ;
    wire              [ADDR_WDTH-1:0]       span_addr                      ;
    wire                                    cfg_wstart_rising              ;
    reg               [7:0]                 wburst_len_first               ;
    reg                                     last_burst_flag                ;
    reg                                     last_2nd_burst_flag            ;
    reg                                     cfg_wsoft_rst_d1               ;
    reg                                     cfg_wsoft_rst_d2               ;
    

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign  cfg_wstart_rising    =     (~cfg_wstart_d1) && cfg_wstart     ;
    assign  span_addr            =     cfg_waddr_req - {cfg_waddr_t1[ADDR_WDTH-1:BIT],{BIT{1'b0}}} ;
    assign  cfg_widle            =     (fsm_st == IDLE)                   ;
    
    always@(*)
        case(cfg_wburst_len_t1)
        8'd3   : wburst_len_first <= 8'd3   - cfg_waddr_t1[BIT+1:BIT];
        8'd7   : wburst_len_first <= 8'd7   - cfg_waddr_t1[BIT+2:BIT];
        8'd15  : wburst_len_first <= 8'd15  - cfg_waddr_t1[BIT+3:BIT];
        8'd31  : wburst_len_first <= 8'd31  - cfg_waddr_t1[BIT+4:BIT];
        8'd63  : wburst_len_first <= 8'd63  - cfg_waddr_t1[BIT+5:BIT];
        8'd127 : wburst_len_first <= 8'd127 - cfg_waddr_t1[BIT+6:BIT];
        8'd255 : wburst_len_first <= 8'd255 - cfg_waddr_t1[BIT+7:BIT];
        default: wburst_len_first <= cfg_wburst_len_t1;
        endcase


// =================================================================================================
// RTL Body
// =================================================================================================

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            cfg_wstart_d1    <= 1'b0;
            cfg_wsoft_rst_d1 <= 1'b0;
            cfg_wsoft_rst_d2 <= 1'b0;
        end else begin
            cfg_wstart_d1    <= cfg_wstart;
            cfg_wsoft_rst_d1 <= cfg_wsoft_rst;
            cfg_wsoft_rst_d2 <= cfg_wsoft_rst_d1;
        end

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            cfg_wburst_len_t1 <= 8'd0;
            cfg_waddr_t1      <= {ADDR_WDTH{1'b0}};
            cfg_wlen_t1       <= {LEN_WDTH{1'b0}};
        end else if(cfg_wsoft_rst_d2) begin
            cfg_wburst_len_t1 <= 8'd0;
            cfg_waddr_t1      <= {ADDR_WDTH{1'b0}};
            cfg_wlen_t1       <= {LEN_WDTH{1'b0}};
        end else if(cfg_wstart_rising) begin
            cfg_wburst_len_t1 <= cfg_wburst_len ;
            cfg_waddr_t1      <= cfg_waddr      ;
            cfg_wlen_t1       <= cfg_wlen       ;
        end



    //FSM
    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            fsm_st <= IDLE;
        end else if(cfg_wsoft_rst_d2) begin
            fsm_st <= IDLE;
        end else begin
            case(fsm_st)
            IDLE:if(cfg_wstart_rising) 
                     fsm_st <= FRST;
                 else
                     fsm_st <= IDLE;
            FRST:    fsm_st <= TAP ;
            TAP :    fsm_st <= WAIT;
            WAIT:if(wstart_rdy && last_burst_flag) 
                     fsm_st <= IDLE;
                 else if(wstart_rdy)
                     fsm_st <= REQ ;
                 else 
                     fsm_st <= WAIT;
            REQ :    fsm_st <= TAP ;
            endcase
        end


    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            wstart_vld <= 1'b0;
            waddr      <= {ADDR_WDTH{1'b0}};
            wburst_len <= 8'd0;
        end else begin
            case(fsm_st)
            FRST:begin
                    wstart_vld <= 1'b1;
                    waddr      <= {cfg_waddr_t1[ADDR_WDTH-1:BIT],{BIT{1'b0}}};
                    wburst_len <= wburst_len_first;
                 end
            REQ :if(last_2nd_burst_flag)begin
                    wstart_vld <= 1'b1;
                    waddr      <= cfg_waddr_req;
                    wburst_len <= cfg_wlen_t1 - span_addr[LEN_WDTH-1:BIT] - 1'b1;
                end else begin
                    wstart_vld <= 1'b1;
                    waddr      <= cfg_waddr_req;
                    wburst_len <= cfg_wburst_len_t1;
                 end
            default:begin
                    wstart_vld <= 1'b0      ;
                    waddr      <= waddr     ;
                    wburst_len <= wburst_len;
            end
            endcase
        end



    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            cfg_wr_times  <= {LEN_WDTH{1'b0}};
            cfg_waddr_req <= {ADDR_WDTH{1'b0}};
        end else begin
            case(fsm_st)
            IDLE:begin
                cfg_wr_times  <= {LEN_WDTH{1'b0}};
                cfg_waddr_req <= {ADDR_WDTH{1'b0}};
            end
            FRST:begin
                cfg_wr_times  <=  1'b1;
                cfg_waddr_req <= {cfg_waddr_t1[ADDR_WDTH-1:BIT],{BIT{1'b0}}} + {wburst_len_first,{BIT{1'b0}}} + {1'b1,{BIT{1'b0}}};
            end
            WAIT:begin
                if(cfg_wr_times > 1'b1 && wstart_rdy)begin
                    cfg_wr_times  <= cfg_wr_times + 1'b1;
                    cfg_waddr_req <= cfg_waddr_req + {cfg_wburst_len_t1,{BIT{1'b0}}} + {1'b1,{BIT{1'b0}}};
                end else if(cfg_wr_times == 1'b1 && wstart_rdy)begin
                    cfg_wr_times  <= cfg_wr_times + 1'b1;
                    cfg_waddr_req <= cfg_waddr_req  ;
                end else begin
                    cfg_wr_times  <= cfg_wr_times   ;
                    cfg_waddr_req <= cfg_waddr_req  ;
                end
            end
            default:begin
                cfg_wr_times  <= cfg_wr_times   ;
                cfg_waddr_req <= cfg_waddr_req  ;
            end
            endcase
        end


    

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            last_burst_flag     <= 1'b0;
        end else if(fsm_st == REQ)begin
            if((span_addr[ADDR_WDTH-1:BIT] + 1'b1 + cfg_wburst_len_t1)>=cfg_wlen_t1)
                last_burst_flag     <= 1'b1;
        end else if(fsm_st == IDLE)begin
            last_burst_flag     <= 1'b0;
        end

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            last_2nd_burst_flag     <= 1'b0;
        end else if(fsm_st == REQ)begin
            if(((span_addr[ADDR_WDTH-1:BIT] + 1'b1 + cfg_wburst_len_t1) < cfg_wlen_t1) && 
               ((span_addr[ADDR_WDTH-1:BIT] + 2'd2 + {cfg_wburst_len_t1,1'b0}) >= cfg_wlen_t1 ))
                last_2nd_burst_flag     <= 1'b1;
        end else if(fsm_st == IDLE)begin
            last_2nd_burst_flag     <= 1'b0;
        end


    //---------------------------------------------------------------------
    // Interrupt Process.
    //---------------------------------------------------------------------     
    reg    cfg_wirq_en_d1;
    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            cfg_wirq_en_d1 <= 1'b0;
        end else begin
            cfg_wirq_en_d1 <= cfg_wirq_en;
        end

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            wirq <= 1'b0;
        end else if(cfg_wsoft_rst_d2 || cfg_wirq_clr) begin
            wirq <= 1'b0;
        end else if(wstart_rdy && last_burst_flag && (fsm_st==WAIT)) begin
            wirq <= cfg_wirq_en_d1;
        end





endmodule























































