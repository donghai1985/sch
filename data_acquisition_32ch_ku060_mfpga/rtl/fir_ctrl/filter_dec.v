module filter_dec #(
    parameter     DATA_WD      =         32                       
)(
    input                                sys_clk                  ,//(i)
    input                                sys_rst_n                ,//(i)
     
    input                                cfg_rst                  ,//(i)
    input         [5:0]                  mode                     ,//(i)
    input                                din_valid                ,//(i)
    input         [DATA_WD  -1:0]        din                      ,//(i)
    output                               dout_valid               ,//(o)
    output        [DATA_WD  -1:0]        dout                      //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    

    // -------------------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------------------
    reg                                  r_dout_valid          ;
    reg           [DATA_WD  -1:0]        r_dout                ;   
    reg           [5:0]                  r_cnt                 ;
    wire          [5:0]                  dec_num               ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign        dout_valid     =       r_dout_valid          ; 
    assign        dout           =       r_dout                ; 
    assign        dec_num        =       mode                  ; 
       
// =================================================================================================
// RTL Body
// =================================================================================================    

    always@(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            r_cnt <=  'd0 ;
        end else if(cfg_rst)begin
            r_cnt <=  'd0 ;
        end else if(din_valid) begin
            if(dec_num == r_cnt)
                r_cnt <=  'd0 ;
            else
                r_cnt <= r_cnt + 1'b1 ; 
        end else begin
            r_cnt <= r_cnt;
        end           
    end

    always@(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            r_dout_valid <= 1'b0 ;
            r_dout       <=  'd0 ;
        end else if(r_cnt==6'd0 && din_valid) begin
            r_dout_valid <= din_valid ;
            r_dout       <= din       ;        
        end else begin
            r_dout_valid <= 1'b0 ;
            r_dout       <= r_dout  ;
        end
    end    

endmodule


























