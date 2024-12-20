module cmip_bit_sync #(
    parameter DATA_WDTH = 1
) (
    input                  i_dst_clk,
    input  [DATA_WDTH-1:0] i_din,
    output [DATA_WDTH-1:0] o_dout
);

    reg [DATA_WDTH-1:0] d1;
    reg [DATA_WDTH-1:0] d2;

    always @(posedge i_dst_clk) begin
        d1 <= i_din;
        d2 <= d1;
    end

    assign o_dout = d2;

endmodule
