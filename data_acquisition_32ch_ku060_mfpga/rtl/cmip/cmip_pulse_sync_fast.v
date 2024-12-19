module cmip_pulse_sync(
    input                          i_src_clk            ,//(i)
    input                          i_src_rst_n          ,//(i)
    input                          i_dst_clk            ,//(i)
    input                          i_dst_rst_n          ,//(i)
    input                          i_pulse              ,//(i)
    output                         o_pulse               //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------------------
    reg                            i_pulse_d1           ; 
    reg                            pluse_lock           ;
    reg                            dst_pluse_lock_d1    ;
    reg                            dst_pluse_lock_d2    ;

    // -------------------------------------------------------------------------
    // ouptut
    // -------------------------------------------------------------------------
    assign      o_pulse   =       dst_pluse_lock_d2 ^ dst_pluse_lock_d1;

// =================================================================================================
// RTL Body
// =================================================================================================

    always@(posedge i_src_clk or negedge i_src_rst_n) begin
        if(~i_src_rst_n)
            i_pulse_d1 <= 1'b0;
        else 
            i_pulse_d1 <= i_pulse;
    end

    always@(posedge i_src_clk or negedge i_src_rst_n) begin
        if(~i_src_rst_n)
            pluse_lock <= 1'b0;
        else if(~i_pulse_d1 && i_pulse)
            pluse_lock <= ~pluse_lock;
    end

    always@(posedge i_dst_clk or negedge i_dst_rst_n) begin
        if(~i_dst_rst_n)begin
            dst_pluse_lock_d1 <= 1'b0;
            dst_pluse_lock_d2 <= 1'b0;
        end else begin
            dst_pluse_lock_d1 <= pluse_lock;
            dst_pluse_lock_d2 <= dst_pluse_lock_d1;
        end
    end







endmodule
