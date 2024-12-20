module cmip_bit_sync_imp #(
    parameter DATA_WDTH = 1 ,
    parameter BUS_DELAY = 2  // >=2
)(
    input                  i_dst_clk,
    input  [DATA_WDTH-1:0] i_din,
    output [DATA_WDTH-1:0] o_dout
);
    integer             i                       ;
    reg [DATA_WDTH-1:0] din_pipe [BUS_DELAY-1:0];


    always @(posedge i_dst_clk)begin
            din_pipe[0] <= i_din;
    end

    always @(posedge i_dst_clk)begin
        for(i=1;i<BUS_DELAY;i=i+1)
            din_pipe[i] <= din_pipe[i-1];
    end

    assign o_dout = din_pipe[BUS_DELAY-1];

endmodule
