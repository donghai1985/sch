module  cmip_rr_sch #
(
    parameter FLOP_OUT  =  0,
    parameter REQ_WDTH  =  8,
    parameter IDX_WDTH  =  3
)
(
    //system clock and reset
    input wire                           i_clk     , 
    input wire                           i_rst_n   , //low valid
    
    //sch request
    input wire                           i_rdy     ,
    input wire       [REQ_WDTH-1:0]      i_req     ,
    
    //sch result
    output wire                          o_gnt_vld ,
    output wire      [REQ_WDTH-1:0]      o_gnt     ,
    output wire      [IDX_WDTH-1:0]      o_gnt_idx 
);


////mask scheduled bit 
wire     [REQ_WDTH-1:0]     mask_bit         ;
wire     [REQ_WDTH-1:0]     req_mask         ;
wire     [REQ_WDTH-1:0]     req              ;

////find first one signals
wire     [REQ_WDTH-1:0]     req_or           ;
wire     [REQ_WDTH-1:0]     req_or_not       ;

//sch result
wire                        grant_vld        ;
wire     [REQ_WDTH-1:0]     grant            ;
reg      [IDX_WDTH-1:0]     grant_idx        ;
reg      [IDX_WDTH:0]       pre_grant_idx    ;
wire     [IDX_WDTH:0]       pre_grant_index  ;

//flop out
reg                         gnt_vld          ;
reg      [REQ_WDTH-1:0]     gnt              ;
reg      [IDX_WDTH-1:0]     gnt_idx          ;


////previous scheduled index
//assign pre_grant_index = pre_grant_idx + 1'b1;
assign pre_grant_index = pre_grant_idx;
////mask secheduled
assign mask_bit = {REQ_WDTH{1'b1}} <<pre_grant_index;  
////mask req scheduled position
assign req_mask = i_req & mask_bit;
////the current request 
assign req = (req_mask=={REQ_WDTH{1'b0}}) ?  i_req : req_mask;

//// find first one
assign req_or[0]  =  1'b0;

genvar i ;
generate
    for(i=1; i<REQ_WDTH;i=i+1) begin:RDY_BLK
       assign req_or[i]  =  req[i-1] | req_or[i-1];
    end
endgenerate
 
assign  req_or_not = ~ req_or;


////sch result
assign grant     = req & req_or_not;
assign grant_vld = i_rdy & (|grant);

always @ (*) begin:GNT_INDEX
   integer j ;
   grant_idx = {IDX_WDTH{1'b0}};
   for (j=0;j<REQ_WDTH;j=j+1) begin
      if(grant[j]==1'b1) 
        grant_idx = j;// spyglass disable W415a
   end
end

always @ (posedge i_clk or negedge i_rst_n) begin
   if (i_rst_n==1'b0) begin
      pre_grant_idx <= {(IDX_WDTH+1){1'b0}};
   end
   else if (grant_vld==1'b1) begin
      pre_grant_idx <= grant_idx+1'b1;
   end
end

////final flopout type
generate
   if (FLOP_OUT==0) begin:DLY_0
      always @ (*) begin
         gnt_vld = grant_vld ;
         gnt     = grant     ;
         gnt_idx = grant_idx ;
      end
   end
else begin: DLY_1
      always @ (posedge i_clk or negedge i_rst_n) begin
         if (i_rst_n==1'b0) begin
             gnt_vld <= 1'b0;
             gnt     <= {REQ_WDTH{1'b0}} ;
             gnt_idx <= {IDX_WDTH{1'b0}} ;
         end
         else begin
             gnt_vld <= grant_vld ;
             gnt     <= grant     ;
             gnt_idx <= grant_idx ;
         end
       end
 end

endgenerate

//output sch result
assign o_gnt_vld = gnt_vld ;
assign o_gnt     = gnt     ;
assign o_gnt_idx = gnt_idx ;


endmodule
