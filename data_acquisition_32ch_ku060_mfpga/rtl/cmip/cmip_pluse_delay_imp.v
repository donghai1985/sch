module cmip_pluse_delay_imp #(
    parameter                     TIMES     =    1000       ,
    parameter                     HOLD_CLK  =      10     
)(                                     
    input                         i_clk                     , 
    input                         i_rst_n                   ,
    input                         i_sig                     , 
    input                         i_clr                     ,
    output  reg                   o_pluse                   
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                    CNT_WD    =  $clog2(TIMES); 
    // -------------------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------------------
    reg                           i_sig_d1                  ;
    reg                           i_sig_d2                  ;
    reg        [CNT_WD-1:0]       cnt                       ;
    wire                          sig_pos                   ;
    reg        [HOLD_CLK-1:0]     pluse                     ;

    assign      sig_pos  =       ~i_sig_d2 && i_sig_d1      ;


// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge i_clk or negedge i_rst_n)begin
        if(!i_rst_n)begin
            i_sig_d1 <= 1'b0;
            i_sig_d2 <= 1'b0;
        end else begin
            i_sig_d1 <= i_sig   ;
            i_sig_d2 <= i_sig_d1;
        end
    end

    always@(posedge i_clk or negedge i_rst_n)begin
        if(!i_rst_n) 
            cnt <= {CNT_WD{1'b0}};
        else if(sig_pos && cnt == {CNT_WD{1'b0}})  
            cnt <= TIMES ;
        else if(i_clr && (cnt != {CNT_WD{1'b0}}))
            cnt <= TIMES ;
        else if(cnt == {CNT_WD{1'b0}})
            cnt <= {CNT_WD{1'b0}};
        else 
            cnt <= cnt - 1'b1;
    end

    always@(posedge i_clk or negedge i_rst_n)begin
        if(!i_rst_n) 
            pluse <= {HOLD_CLK{1'b0}};
        else if(cnt == 32'd1)  
            pluse <=  32'd1;
        else 
            pluse <= {pluse,1'b0};
    end

    always@(posedge i_clk or negedge i_rst_n)begin
        if(!i_rst_n) 
            o_pluse <= 1'b0;
        else 
            o_pluse <= |pluse;
    end


endmodule
