// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : axidma_rr_fsm.v
// Module         : axidma_rr_fsm
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



module axidma_rd_fsm #(
    parameter                               LEN_WDTH    =  32              ,
    parameter                               DATA_WDTH   =  32              ,
    parameter                               ADDR_WDTH   =  32              
)(
    input                                   sys_clk                        ,//(i)
    input                                   sys_rst_n                      ,//(i)

    input             [7:0]                 cfg_rburst_len                 ,//(i)
    input                                   cfg_rsoft_rst                  ,//(i)
    input                                   cfg_rstart                     ,//(i)
    input             [ADDR_WDTH-1:0]       cfg_raddr                      ,//(i)
    input             [LEN_WDTH -1:0]       cfg_rlen                       ,//(i)
    output                                  cfg_ridle                      ,//(o)
    output  reg       [LEN_WDTH -1:0]       cfg_rd_times                   ,//(o)
    input                                   cfg_rirq_en                    ,//(i)
    input                                   cfg_rirq_clr                   ,//(i)
    output  reg                             rirq                           ,//(o)

    output  reg                             rstart_vld                     ,//(i)
    input                                   rstart_rdy                     ,//(o)
    output  reg       [ADDR_WDTH-1:0]       raddr                          ,//(i)
    output  reg       [7:0]                 rburst_len                      //(i)
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
    reg               [7:0]                 cfg_rburst_len_t1              ;
    reg               [ADDR_WDTH-1:0]       cfg_raddr_t1                   ;
    reg               [ADDR_WDTH-1:0]       cfg_raddr_req                  ;
    reg               [LEN_WDTH -1:0]       cfg_rlen_t1                    ;
    reg                                     cfg_rstart_d1                  ;
    wire              [ADDR_WDTH-1:0]       span_addr                      ;
    wire                                    cfg_rstart_rising              ;
    reg               [7:0]                 rburst_len_first               ;
    reg                                     last_burst_flag                ;
    reg                                     last_2nd_burst_flag            ;
    reg                                     cfg_rsoft_rst_d1               ;
    reg                                     cfg_rsoft_rst_d2               ;
    

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign  cfg_rstart_rising    =     (~cfg_rstart_d1) && cfg_rstart     ;
    assign  span_addr            =     cfg_raddr_req - {cfg_raddr_t1[ADDR_WDTH-1:BIT],{BIT{1'b0}}} ;
    assign  cfg_ridle            =     (fsm_st == IDLE)                   ;
    
    always@(*)
        case(cfg_rburst_len_t1)
        8'd3   : rburst_len_first <= 8'd3   - cfg_raddr_t1[BIT+1:BIT];
        8'd7   : rburst_len_first <= 8'd7   - cfg_raddr_t1[BIT+2:BIT];
        8'd15  : rburst_len_first <= 8'd15  - cfg_raddr_t1[BIT+3:BIT];
        8'd31  : rburst_len_first <= 8'd31  - cfg_raddr_t1[BIT+4:BIT];
        8'd63  : rburst_len_first <= 8'd63  - cfg_raddr_t1[BIT+5:BIT];
        8'd127 : rburst_len_first <= 8'd127 - cfg_raddr_t1[BIT+6:BIT];
        8'd255 : rburst_len_first <= 8'd255 - cfg_raddr_t1[BIT+7:BIT];
        default: rburst_len_first <= cfg_rburst_len_t1;
        endcase


// =================================================================================================
// RTL Body
// =================================================================================================

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            cfg_rstart_d1    <= 1'b0;
            cfg_rsoft_rst_d1 <= 1'b0;
            cfg_rsoft_rst_d2 <= 1'b0;
        end else begin
            cfg_rstart_d1    <= cfg_rstart;
            cfg_rsoft_rst_d1 <= cfg_rsoft_rst;
            cfg_rsoft_rst_d2 <= cfg_rsoft_rst_d1;
        end

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            cfg_rburst_len_t1 <= 8'd0;
            cfg_raddr_t1      <= {ADDR_WDTH{1'b0}};
            cfg_rlen_t1       <= {LEN_WDTH{1'b0}};
        end else if(cfg_rsoft_rst_d2) begin
            cfg_rburst_len_t1 <= 8'd0;
            cfg_raddr_t1      <= {ADDR_WDTH{1'b0}};
            cfg_rlen_t1       <= {LEN_WDTH{1'b0}};
        end else if(cfg_rstart_rising) begin
            cfg_rburst_len_t1 <= cfg_rburst_len ;
            cfg_raddr_t1      <= cfg_raddr      ;
            cfg_rlen_t1       <= cfg_rlen       ;
        end



    //FSM
    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            fsm_st <= IDLE;
        end else if(cfg_rsoft_rst_d2) begin
            fsm_st <= IDLE;
        end else begin
            case(fsm_st)
            IDLE:if(cfg_rstart_rising) 
                     fsm_st <= FRST;
                 else
                     fsm_st <= IDLE;
            FRST:    fsm_st <= TAP ;
            TAP :    fsm_st <= WAIT;
            WAIT:if(rstart_rdy && last_burst_flag) 
                     fsm_st <= IDLE;
                 else if(rstart_rdy)
                     fsm_st <= REQ ;
                 else 
                     fsm_st <= WAIT;
            REQ :    fsm_st <= TAP ;
            endcase
        end


    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            rstart_vld <= 1'b0;
            raddr      <= {ADDR_WDTH{1'b0}};
            rburst_len <= 8'd0;
        end else begin
            case(fsm_st)
            FRST:begin
                    rstart_vld <= 1'b1;
                    raddr      <= {cfg_raddr_t1[ADDR_WDTH-1:BIT],{BIT{1'b0}}};
                    rburst_len <= rburst_len_first;
                 end
            REQ :if(last_2nd_burst_flag)begin
                    rstart_vld <= 1'b1;
                    raddr      <= cfg_raddr_req;
                    rburst_len <= cfg_rlen_t1 - span_addr[LEN_WDTH-1:BIT] - 1'b1;
                end else begin
                    rstart_vld <= 1'b1;
                    raddr      <= cfg_raddr_req;
                    rburst_len <= cfg_rburst_len_t1;
                 end
            default:begin
                    rstart_vld <= 1'b0      ;
                    raddr      <= raddr     ;
                    rburst_len <= rburst_len;
            end
            endcase
        end



    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            cfg_rd_times  <= {LEN_WDTH{1'b0}};
            cfg_raddr_req <= {ADDR_WDTH{1'b0}};
        end else begin
            case(fsm_st)
            IDLE:begin
                cfg_rd_times  <= {LEN_WDTH{1'b0}};
                cfg_raddr_req <= {ADDR_WDTH{1'b0}};
            end
            FRST:begin
                cfg_rd_times  <=  1'b1;
                cfg_raddr_req <= {cfg_raddr_t1[ADDR_WDTH-1:BIT],{BIT{1'b0}}} + {rburst_len_first,{BIT{1'b0}}} + {1'b1,{BIT{1'b0}}};
            end
            WAIT:begin
                if(cfg_rd_times > 1'b1 && rstart_rdy)begin
                    cfg_rd_times  <= cfg_rd_times + 1'b1;
                    cfg_raddr_req <= cfg_raddr_req + {cfg_rburst_len_t1,{BIT{1'b0}}} + {1'b1,{BIT{1'b0}}};
                end else if(cfg_rd_times == 1'b1 && rstart_rdy)begin
                    cfg_rd_times  <= cfg_rd_times + 1'b1;
                    cfg_raddr_req <= cfg_raddr_req  ;
                end else begin
                    cfg_rd_times  <= cfg_rd_times   ;
                    cfg_raddr_req <= cfg_raddr_req  ;
                end
            end
            default:begin
                cfg_rd_times  <= cfg_rd_times   ;
                cfg_raddr_req <= cfg_raddr_req  ;
            end
            endcase
        end


    

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            last_burst_flag     <= 1'b0;
        end else if(fsm_st == REQ)begin
            if((span_addr[ADDR_WDTH-1:BIT] + 1'b1 + cfg_rburst_len_t1)>=cfg_rlen_t1)
                last_burst_flag     <= 1'b1;
        end else if(fsm_st == IDLE)begin
            last_burst_flag     <= 1'b0;
        end

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            last_2nd_burst_flag     <= 1'b0;
        end else if(fsm_st == REQ)begin
            if(((span_addr[ADDR_WDTH-1:BIT] + 1'b1 + cfg_rburst_len_t1) < cfg_rlen_t1) && 
               ((span_addr[ADDR_WDTH-1:BIT] + 2'd2 + {cfg_rburst_len_t1,1'b0}) >= cfg_rlen_t1 ))
                last_2nd_burst_flag     <= 1'b1;
        end else if(fsm_st == IDLE)begin
            last_2nd_burst_flag     <= 1'b0;
        end


    //---------------------------------------------------------------------
    // Interrupt Process.
    //---------------------------------------------------------------------     
    reg    cfg_rirq_en_d1;
    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            cfg_rirq_en_d1 <= 1'b0;
        end else begin
            cfg_rirq_en_d1 <= cfg_rirq_en;
        end

    always@(posedge sys_clk or negedge sys_rst_n)
        if(~sys_rst_n) begin
            rirq <= 1'b0;
        end else if(cfg_rsoft_rst_d2 || cfg_rirq_clr) begin
            rirq <= 1'b0;
        end else if(rstart_rdy && last_burst_flag && (fsm_st==WAIT)) begin
            rirq <= cfg_rirq_en_d1;
        end





endmodule























































