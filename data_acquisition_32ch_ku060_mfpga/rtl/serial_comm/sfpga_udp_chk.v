module sfpga_udp_chk(
    input                                   clk_100m                       ,//(i)
    input                                   rst_100m                       ,//(i)

    input                                   sfpga_rst                      ,//(i)
    input                                   cfg_clr                        ,//(i)
                                                                                
    output                                  tap_wr_cmd                     ,//(o)
    output              [32-1:0]            tap_wr_addr                    ,//(o)
    output                                  tap_wr_vld                     ,//(o)
    output              [32-1:0]            tap_wr_data                    ,//(o)
    output              [31:0]              tap_vld_cnt                     //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    //parameter                               MAX_CNT              =    32               ;

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg                                     sfpga_rst_d1        =   0      ;
    reg                                     sfpga_rst_d2        =   0      ;
    reg                                     tap_wr_cmd_d1       =   0      ;
    reg                                     tap_wr_cmd_d2       =   0      ;
    wire                                    tap_wr_cmd_pos                 ;
    reg                  [15:0]             cnt1                           ;
    reg                  [15:0]             cnt2                           ;
    wire                 [15:0]             datah                          ;
    wire                 [15:0]             datal                          ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign        tap_wr_cmd_pos   =       ~tap_wr_cmd_d2 && tap_wr_cmd_d1 ;
    assign        datal            =        tap_wr_addr[15:0]              ;
    assign        datah            =       {tap_wr_addr[23:16],tap_wr_addr[31:24]};
    assign        tap_vld_cnt      =       {cnt2,cnt1}                     ;


// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge clk_100m)begin
        sfpga_rst_d1   <= sfpga_rst || cfg_clr     ;
        sfpga_rst_d2   <= sfpga_rst_d1             ;
        tap_wr_cmd_d1  <= tap_wr_cmd               ;
        tap_wr_cmd_d2  <= tap_wr_cmd_d1            ;
    end 
    
    always@(posedge clk_100m or posedge rst_100m)begin
        if(rst_100m)
            cnt1 <= 'd0;
        else if(sfpga_rst)
            cnt1 <= 'd0;
        else if(tap_wr_cmd_pos)
            cnt1 <= cnt1 + 1'b1;
    end

    always@(posedge clk_100m or posedge rst_100m)begin
        if(rst_100m)
            cnt2 <= 'd0;
        else if(sfpga_rst)
            cnt2 <= 'd0;
        else if(tap_wr_cmd_pos && (({cnt2[13:0],2'd0} == datah)  || ({cnt2[13:0],2'd0} == datal)))
            cnt2 <= cnt2 + 1'b1;
    end


















endmodule





