module cmip_arst_sync #
(
    parameter PIPE_NUM            =  2   // ATTENTION:PIPE_NUM >= 2
)
(
    input  i_dst_clk,
    input  i_src_rst_n,
    output o_dst_rst_n
);


generate
if (PIPE_NUM==2) begin:TWO_PIPE
    reg d1;
    reg d2;
    always @(posedge i_dst_clk or negedge i_src_rst_n) begin
        if (~i_src_rst_n) begin
            d1 <= 1'b0;
            d2 <= 1'b0;
        end
        else begin
            d1 <= 1'b1;
            d2 <= d1  ;
        end
    end

    assign o_dst_rst_n = d2;
end
else begin:MORE_PIPE
    integer i;
    reg    [PIPE_NUM-1:0]  dn;
    always @ (posedge i_dst_clk or negedge i_src_rst_n) begin
      if(~i_src_rst_n) begin
          for(i=0;i<PIPE_NUM;i=i+1)
              dn[i] <= 1'b0;
      end
      else begin
          dn[0] <= 1'b1;
          for(i=1;i<PIPE_NUM;i=i+1)
              dn[i] <= dn[i-1];
      end
    end

    assign o_dst_rst_n = dn[PIPE_NUM-1];
end

endgenerate
//    assign o_dst_rst_n = d2;

endmodule




