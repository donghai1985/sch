module  cmip_bus_delay #
(
    parameter BUS_DELAY      =  1,
    parameter DATA_WDTH  =  8,
    parameter INIT_DATA  =  {DATA_WDTH{1'b0}}
)
(
    //system clock and reset
    input  wire                      i_clk     , 
    input  wire                      i_rst_n   , //low valid
    
    //input data
    input  wire  [DATA_WDTH-1:0]     i_din     ,
    
    //sch result
    output wire  [DATA_WDTH-1:0]     o_dout    
);


/////////////////////////////////////////////////////////
///////////////////define internal signals///////////////
/////////////////////////////////////////////////////////
wire   [DATA_WDTH-1:0]        dout   ;


/////////////////////////////////////////////////////////
/////////////////////////main code///////////////////////
/////////////////////////////////////////////////////////
generate
if (BUS_DELAY==0) begin:ZERO_PIPE
    assign dout = i_din;
end

else if (BUS_DELAY==1) begin:ONE_PIPE
reg    [DATA_WDTH*BUS_DELAY-1:0]  dout_dn;
    always @ (posedge i_clk or negedge i_rst_n) begin
      if(i_rst_n==1'b0) begin
         //dout_dn[DATA_WDTH-1:0]  <= {DATA_WDTH{1'b0}};
         dout_dn[DATA_WDTH-1:0]  <= INIT_DATA;
      end
      else begin
         dout_dn[DATA_WDTH-1:0]  <= i_din;
      end
    end
     
    assign dout = dout_dn[DATA_WDTH-1:0];
end

else begin:MORE_PIPE
reg    [DATA_WDTH*BUS_DELAY-1:0]  dout_dn;
    always @ (posedge i_clk or negedge i_rst_n) begin
      if(i_rst_n==1'b0) begin
         //dout_dn[DATA_WDTH-1:0]  <= {DATA_WDTH{1'b0}};
         dout_dn[DATA_WDTH-1:0]  <= INIT_DATA;
      end
      else begin
         dout_dn[DATA_WDTH-1:0]  <= i_din;
      end
    end

    always @ (posedge i_clk ) begin
         dout_dn[DATA_WDTH*BUS_DELAY-1:DATA_WDTH]  <= dout_dn[DATA_WDTH*(BUS_DELAY-1)-1:0];
    end

    assign dout = dout_dn[DATA_WDTH*BUS_DELAY-1-:DATA_WDTH];
end

endgenerate


//// final output signals
assign o_dout = dout;


endmodule
