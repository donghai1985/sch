module cmip_edge_sync #(
    parameter                     RISE      =      1   ,
    parameter                     PIPELINE  =      2
)(                                
    input                         i_clk                ,  
    input                         i_rst_n              ,  
    input                         i_sig                , 
    output                        o_edge                 
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------------------
    reg                           i_sig_d1             ;
    reg                           i_sig_d2             ;
    wire                          res                  ;
    assign                        o_edge  =  res       ;

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


generate if((RISE == 1) && (PIPELINE>=2))begin
    assign  res      =      (~i_sig_d2) && i_sig_d1 ;
end else if((RISE == 1) && (PIPELINE< 2))begin
    assign  res      =      (~i_sig_d1) && i_sig    ;
end else if((RISE == 0) && (PIPELINE>=2))begin
    assign  res      =      (~i_sig_d1) && i_sig_d2 ;
end else begin
    assign  res      =      (~i_sig   ) && i_sig_d1 ;
end
endgenerate







endmodule
