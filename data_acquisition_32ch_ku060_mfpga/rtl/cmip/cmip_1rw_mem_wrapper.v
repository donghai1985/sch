module cmip_1rw_mem_wrapper #(
    parameter DPTH          = 1024              ,
    parameter DATA_WDTH     = 8                 ,
    parameter ADDR_WDTH     = $clog2(DPTH)      ,
    parameter READ_LATENCY  = 4                   //read delay
   )
   (    
    input  wire                  i_clk          ,
//    input  wire                  i_rst_n        , //asynchronization reset synchronization release, low active
    input  wire                  i_cs           , //high active
    input  wire                  i_wr           , //read and write enable, 1-wr 0-rd
    input  wire [ADDR_WDTH-1:0]  i_addr         , 
    input  wire [DATA_WDTH-1:0]  i_wdata        , 
    output wire [DATA_WDTH-1:0]  o_rdata         
);  
  
    localparam BUS_DELAY         = READ_LATENCY-1    ; //read delay

    reg    [DATA_WDTH      -1:0]  rdata          ;
   
    reg    [DATA_WDTH-1:0]  block_mem[DPTH-1:0]  ;
    
integer i, j;
initial begin
    // two nested loops for smaller number of iterations per loop
    // workaround for synthesizer complaints about large loop counts
    // for (i = 0; i < 2**ADDR_WDTH; i = i + 2**(ADDR_WDTH/2)) begin
    //     for (j = i; j < i + 2**(ADDR_WDTH/2); j = j + 1) begin
    //         //mem[j] = 0;
    //         block_mem[j] = j;
    //     end
    // end
        for (j = 0; j < 32'h10000; j = j + 1) begin
            block_mem[j] = 0;
        end
end         
    //----------------------------------------------------------------------------
    //write and read data
    //----------------------------------------------------------------------------

    always @ ( posedge i_clk ) 
    begin
        if ((i_cs == 1'b1) && (i_wr == 1'b1))
        begin
            block_mem[i_addr] <= i_wdata;
        end

        rdata <= block_mem[i_addr];
    end

    //----------------------------------------------------------------------------
    //read delay
    //----------------------------------------------------------------------------
    cmip_bus_delay # (
        .BUS_DELAY       ( BUS_DELAY          ),
        .DATA_WDTH   ( DATA_WDTH      ))
    u_bus_delay(
        .i_clk       (i_clk           ), 
        .i_rst_n     (1'b1            ), 
    
        .i_din       (rdata           ),
    
        .o_dout      (o_rdata         )    
    );
    
endmodule
