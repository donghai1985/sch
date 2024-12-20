module cmip_1r1w_mem_wrapper #(
    parameter DPTH          = 16384             ,
    parameter DATA_WDTH     = 2048              ,
    parameter ADDR_WDTH     = $clog2(DPTH)      ,
    parameter READ_LATENCY  = 4                   //read delay
   )
   (    
    input  wire                  i_clk          ,
//    input  wire                  i_rst_n        , //asynchronization reset synchronization release, low active
    input  wire                  i_wr           , //write enable, high active
    input  wire [ADDR_WDTH-1:0]  i_waddr        , 
    input  wire [DATA_WDTH-1:0]  i_wdata        , 
    input  wire                  i_rd           , //read enable, high active
    input  wire [ADDR_WDTH-1:0]  i_raddr        , 
    output wire [DATA_WDTH-1:0]  o_rdata          
);  
  
    localparam BUS_DELAY         = READ_LATENCY-1   ; //read delay

    reg    [DATA_WDTH-1:0]  rdata               ;
   
    reg    [DATA_WDTH-1:0]  block_mem[DPTH-1:0] ;
    wire                    rd_nc               ;
    
    assign rd_nc = i_rd;// spyglass disable W528
        
    //----------------------------------------------------------------------------
    //write and read data
    //----------------------------------------------------------------------------

    always @ ( posedge i_clk ) 
    begin
        if (i_wr == 1'b1)
        begin
            block_mem[i_waddr] <= i_wdata;
        end

        rdata <= block_mem[i_raddr];
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
