module command_map_sim #(
    parameter                               TEST                =        0
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)

    output  reg     [32-1:0]                ddr_rd_addr_o                  ,//(o)
    output  reg                             ddr_rd_en_o                    ,//(o)
    output  reg                             fir_tap_wr_cmd_o               ,//(o)
    output  reg     [32-1:0]                fir_tap_wr_addr_o              ,//(o)
    output  reg                             fir_tap_wr_vld_o               ,//(o)
    output  reg     [32-1:0]                fir_tap_wr_data_o               //(o)

);
 
    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    // parameter                               AXI_ADDRESS_WIDTH     =      32;

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    // wire                                    up_wreq                        ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    // assign       up_rdata          =           master_rd_data                 ;
 
// =================================================================================================
// RTL Body
// =================================================================================================


initial begin
    ddr_rd_addr_o     = 'd0;
    ddr_rd_en_o       = 'd0;
    fir_tap_wr_cmd_o  = 'd0;
    fir_tap_wr_addr_o = 'd0;
    fir_tap_wr_vld_o  = 'd0;
    fir_tap_wr_data_o = 'd0;
end



task ddr_coe_rd(
    input    [31:0]     addr
);                                   
begin                                
    @(posedge clk);                  
    @(posedge clk)begin
        ddr_rd_addr_o <= addr;
        ddr_rd_en_o   <= 1'b1;
    end
    @(posedge clk)begin
        ddr_rd_addr_o <=  'd0;
        ddr_rd_en_o   <=  'd0;
    end                       
end                                               
endtask                                           


task ddr_coe_wr(
    input    [31:0]     addr
);   
    integer             i   ;       
begin                                
    @(posedge clk);                  
    @(posedge clk)begin
        fir_tap_wr_cmd_o  <= 1'b1;
        fir_tap_wr_addr_o <= addr;
    end
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

    for(i=0;i<127;i=i+1)begin
        @(posedge clk)begin
            fir_tap_wr_vld_o  <= 1'b1;
            fir_tap_wr_data_o <= 32'hABCD_0000 + {addr,4'b0} + i ;
        end
        @(posedge clk)begin
            fir_tap_wr_vld_o  <= 1'b0;
        end
        @(posedge clk);
        @(posedge clk);
    end

    fir_tap_wr_cmd_o  <= 'd0;
    fir_tap_wr_addr_o <= 'd0;
    fir_tap_wr_vld_o  <= 'd0;
    fir_tap_wr_data_o <= 'd0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);

end                                               
endtask                                           



endmodule
 
 
 
 
 