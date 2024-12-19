module cmip_async_mem_fifo #(
    parameter       DPTH                                                =       32                                      ,   // depth of the async fifo
    parameter       DATA_WDTH                                           =       512                                     ,   // data width
    parameter       FWFT                                                =       0                                       ,   //fwft enable
    parameter       ADDR_WDTH                                           =       5                                           // log2 DPTH
)
(
//wr_clk//
    input                                                                       i_wr_clk                                ,   //
    input                                                                       i_wr_rst_n                              ,   //
    input                   [ADDR_WDTH:0]                                       i_aful_th                               ,   // almost full water line
    input                                                                       i_wr                                    ,   //
    input                   [DATA_WDTH-1:0]                                     i_din                                   ,   //

    output  reg                                                                 o_aful                                  ,   // almost full fc
    output  reg                                                                 o_full                                  ,   //
    output  reg                                                                 o_ovfl_int                              ,   // overflow int
    output                  [ADDR_WDTH:0]                                       o_wr_cnt                                ,   // wr_clk data count
    output                  [DATA_WDTH-1:0]                                     o_mem_wdata                             ,   //
    output                                                                      o_mem_wr                                ,   //
    output                  [ADDR_WDTH-1:0]                                     o_mem_waddr                             ,   //
//rd_clk//
    input                                                                       i_rd_clk                                ,   //
    input                                                                       i_rd_rst_n                              ,   //
    input                                                                       i_rd                                    ,   //
    input                   [ADDR_WDTH:0]                                       i_amty_th                               ,   // almost empty water line
    input                   [DATA_WDTH-1:0]                                     i_mem_rdata                             ,   //

    output                                                                      o_mem_rd                                ,   //
    output                  [ADDR_WDTH-1:0]                                     o_mem_raddr                             ,   //
    output                                                                      o_amty                                  ,   // almost empty
    output                  [DATA_WDTH-1:0]                                     o_dout                                  ,   // data output 1 cycle delay
    output                                                                      o_empty                                 ,   //
    output                                                                      o_unfl_int                              ,   // under flow int
    output                  [ADDR_WDTH:0]                                       o_rd_cnt                                    // rd_clk data count
);

localparam      RAM_PIPE_STAGE                                      =       4                                       ;   //
localparam      PRE_REG_NUM                                         =       RAM_PIPE_STAGE+1                        ;   //

wire            [DATA_WDTH-1:0]                                     afifo_out                                       ;   //
reg                                                                 afifo_amty                                      ;   //
wire                                                                afifo_empty                                     ;   //
reg                                                                 afifo_unfl_int                                  ;   //
wire                                                                afifo_rd                                        ;   //
//reg             [DPTH-1:0]                              ram [DATA_WDTH-1:0]                     ;   //
//wire                                                    mem_wr                                  ;   //
//wire            [ADDR_WDTH-1:0]                         mem_waddr                               ;   //
//wire            [ADDR_WDTH-1:0]                         mem_raddr                               ;   //
//wire            [DATA_WDTH-1:0]                         mem_wdata                               ;   //
//reg             [DATA_WDTH-1:0]                         mem_rdata                               ;   //
//wire                                                    mem_rd                                  ;   //
reg             [ADDR_WDTH:0]                                       waddr_ptr                                       ;   //
reg             [ADDR_WDTH:0]                                       raddr_ptr                                       ;   //
wire            [ADDR_WDTH:0]                                       waddr_gray                                      ;   //
wire            [ADDR_WDTH:0]                                       raddr_gray                                      ;   //
wire            [ADDR_WDTH:0]                                       waddr_gray_d1                                   ;   //
wire            [ADDR_WDTH:0]                                       raddr_gray_d1                                   ;   //
wire            [ADDR_WDTH:0]                                       waddr_gray_rd                                   ;   //
wire            [ADDR_WDTH:0]                                       raddr_gray_wr                                   ;   //
wire            [ADDR_WDTH:0]                                       wr_data_cnt                                     ;   //
wire            [ADDR_WDTH:0]                                       rd_data_cnt                                     ;   //
wire            [ADDR_WDTH:0]                                       wr_gap                                          ;   //
wire            [ADDR_WDTH:0]                                       rd_gap                                          ;   //
wire            [ADDR_WDTH:0]                                       waddr_ptr_rd                                    ;   //
wire            [ADDR_WDTH:0]                                       raddr_ptr_wr                                    ;   //
wire                                                                ovf_nc                                          ;   //
wire                                                                ovf_nc1                                         ;   //
wire                                                                ovf_nc3                                         ;   //
wire            [2-1:0]                                             ovf_nc2                                         ;   //
reg                                                                 aful_active                                     ;   //
reg                                                                 amty_active                                     ;   //

generate
    genvar i;
    if (FWFT == 1) begin: fwft_u0
        
        wire                                                                s_fifo_rd                                       ;   //
        wire                                                                fifo_out_val                                    ;   //
        wire                                                                ren                                             ;   //
        wire                                                                rd_data_val                                     ;   //
        wire                                                                s_empty                                         ;   //
        reg                                                                 s_unfl_int                                      ;   //
        reg             [ADDR_WDTH:0]                                       s_fifo_count                                    ;   //
        wire                                                                afifo_unfl_int_nc                               ;   //
        reg             [(DATA_WDTH-1):0]                                   pre_rd_data[(PRE_REG_NUM-1):0]                  ;   //
        reg             [(PRE_REG_NUM-1):0]                                 pre_rd_data_val                                 ;   //
        reg             [(PRE_REG_NUM-1):0]                                 in_active                                       ;   //
        wire            [(PRE_REG_NUM-1):0]                                 in_active_nd                                    ;   //
        reg             [(PRE_REG_NUM-1):0]                                 out_active                                      ;   //
        wire            [(DATA_WDTH-1):0]                                   pre_rd_data_mask[(PRE_REG_NUM-1):0]             ;   //
        wire            [(DATA_WDTH-1):0]                                   pre_rd_data_out[(PRE_REG_NUM-1):0]              ;   //
        
        
        //assign fifo_rd      =   i_rd;
        //assign o_dout       =   fifo_out;
        //assign o_empty      =   fifo_empty;
        //assign o_unfl_int   =   fifo_unfl_int;
        //assign o_used_cnt           =   fifo_used_cnt;
        
        assign  afifo_rd                        =   s_fifo_rd                                                   ;   //
        assign  o_dout                          =   pre_rd_data_out[PRE_REG_NUM-1]                              ;   //
        assign  o_empty                         =   s_empty                                                     ;   //

        assign  o_unfl_int                      =   s_unfl_int                                                  ;   //
        assign  o_rd_cnt                        =   rd_data_cnt+s_fifo_count                                    ;   //
        assign  afifo_unfl_int_nc               =   afifo_unfl_int                                              ;   //spyglass disable W528
        assign  ren                             =   i_rd & rd_data_val                                          ;   //
        assign  o_amty                          =   afifo_amty                                                  ;   //
        
        always @ (posedge i_rd_clk or negedge i_rd_rst_n)
            if (~i_rd_rst_n) begin
                in_active                       <=              {{(PRE_REG_NUM-1){1'b0}},1'b1}            ;   
            end
            else if(s_fifo_rd) begin
                in_active                       <=              {in_active[(PRE_REG_NUM-2):0],in_active[PRE_REG_NUM-1]};   
            end
            
        always @ (posedge i_rd_clk or negedge i_rd_rst_n)
            if(~i_rd_rst_n) begin
                out_active                      <=              {{(PRE_REG_NUM-1){1'b0}},1'b1}            ;   
            end
            else if (ren) begin
                out_active                      <=              {out_active[(PRE_REG_NUM-2):0],out_active[PRE_REG_NUM-1]};   
            end
            
            //generate
        for (i=0;i<PRE_REG_NUM;i=i+1) begin: genrate_pre_rd_data
            always @(posedge i_rd_clk or negedge i_rd_rst_n)
                if (~i_rd_rst_n) begin
                    pre_rd_data[i]                  <=              {(DATA_WDTH){1'b0}}                     ;   
                    pre_rd_data_val[i]              <=              1'b0                                    ;   
                end
                else if (fifo_out_val&in_active_nd[i]) begin
                    pre_rd_data[i]                  <=              afifo_out                               ;   
                    pre_rd_data_val[i]              <=              1'b1                                    ;   
                end
                else if(ren&out_active[i]) begin
                    pre_rd_data_val[i]              <=              1'b0                                    ;   
                end
        end
        //endgenerate
        
        //generate
        for (i=0;i<PRE_REG_NUM;i=i+1) begin : genrate_pre_rd_data_mask
            assign  pre_rd_data_mask[i]             =   pre_rd_data[i] &{DATA_WDTH{out_active[i]}}                  ;   //
        end
        //endgenerate
        
        
        //generate
        for (i=1;i<PRE_REG_NUM;i=i+1) begin : genrate_pre_rd_data_out
            assign  pre_rd_data_out[i]              =   pre_rd_data_mask[i] | pre_rd_data_out[i-1]                  ;   //
        end
        //endgenerate
        
        
        always @( posedge i_rd_clk or negedge i_rd_rst_n)
            if(~i_rd_rst_n) begin
                s_fifo_count                    <=              {(ADDR_WDTH+1){1'b0}}                   ;   
            end
            else if(s_fifo_rd & (~ren)) begin
                s_fifo_count                    <=              s_fifo_count+1'b1                       ;   
            end
            else if((~s_fifo_rd) & ren) begin
                s_fifo_count                    <=              s_fifo_count-1'b1                       ;   
            end
            
        assign  pre_rd_data_out[0]              =   pre_rd_data_mask[0]                                         ;   //
        assign  rd_data_val                     =   |(pre_rd_data_val&out_active)                               ;   //
        assign  s_empty                         =   (~rd_data_val) || (o_rd_cnt=={(ADDR_WDTH+1){1'b0}})        ;   //
        assign  s_fifo_rd                       =   (~afifo_empty) & (ren|((in_active & pre_rd_data_val) == {PRE_REG_NUM{1'b0}}));   //
        
        cmip_bus_delay
        #(
            .BUS_DELAY                           (   RAM_PIPE_STAGE                                              ),   //
            .DATA_WDTH                       (   PRE_REG_NUM                                                 )    //
        )
        u_bus_delay_0
        (
            .i_clk                           (   i_rd_clk                                                    ),   //
            .i_rst_n                         (   i_rd_rst_n                                                  ),   //
            .i_din                           (   in_active                                                   ),   //
            .o_dout                          (   in_active_nd                                                )    //
        );
        
        cmip_bus_delay
        #(
            .BUS_DELAY                           (   RAM_PIPE_STAGE                                              ),   //
            .DATA_WDTH                       (   1'b1                                                        )    //
        )
        u_bus_delay_1
        (
            .i_clk                           (   i_rd_clk                                                    ),   //
            .i_rst_n                         (   i_rd_rst_n                                                  ),   //
            .i_din                           (   s_fifo_rd                                                   ),   //
            .o_dout                          (   fifo_out_val                                                )    //
        );
        
        always @( posedge i_rd_clk or negedge i_rd_rst_n)
            if(~i_rd_rst_n) begin
                s_unfl_int                      <=              1'b0                                    ;   
            end
            else begin
                s_unfl_int                      <=              i_rd & s_empty                          ;   
            end
    end
    else begin:pass_u0
        assign  afifo_rd                        =   i_rd                                                        ;   //
        assign  o_dout                          =   afifo_out                                                   ;   //
        assign  o_amty                          =   afifo_amty                                                  ;   //
        assign  o_empty                         =   afifo_empty                                                 ;   //
        assign  o_unfl_int                      =   afifo_unfl_int                                              ;   //
        assign  o_rd_cnt                        =   rd_data_cnt                                                 ;   //
    end
endgenerate





//generate the write address and read address//
always @(posedge i_wr_clk or negedge i_wr_rst_n)
    if(!i_wr_rst_n) begin
        waddr_ptr                       <=              {(ADDR_WDTH+1){1'b0}}                   ;   
    end
    else if (i_wr&&(waddr_ptr == DPTH-1))
        waddr_ptr                       <=              {(ADDR_WDTH+1){1'b0}}                   ;   
    else if (i_wr&&(!o_full)) begin
        waddr_ptr                       <=              waddr_ptr + 1'd1                        ;   
    end
    
always @(posedge i_rd_clk or negedge i_rd_rst_n)
    if(!i_rd_rst_n) begin
        raddr_ptr                       <=              {(ADDR_WDTH+1){1'b0}}                   ;   
    end
   else if (afifo_rd&&(raddr_ptr == DPTH-1)) begin
        raddr_ptr                       <=              {(ADDR_WDTH+1){1'b0}}                   ;   
    end
    //else if (afifo_rd&&(!afifo_empty)) begin 
    else if (afifo_rd&&((|rd_gap))) begin //edit wqh
        raddr_ptr                       <=              raddr_ptr + 1'd1                        ;   
    end
    
    //address convert to gray code
assign  waddr_gray                      =   bin2gray(waddr_ptr)                                         ;   //
assign  raddr_gray                      =   bin2gray(raddr_ptr)                                         ;   //

cmip_bus_delay #(
    .BUS_DELAY                           (   1                                                           ),   //
    .DATA_WDTH                       (   ADDR_WDTH+1                                                 )    //
)
u_cmip_bus_delay_waddr_gray_pipe(
    .i_clk                           (   i_wr_clk                                                    ),   //
    .i_rst_n                         (   i_wr_rst_n                                                  ),   //
    .i_din                           (   waddr_gray                                                  ),   //
    .o_dout                          (   waddr_gray_d1                                               )    //
);

cmip_bus_delay #(
    .BUS_DELAY                           (   1                                                           ),   //
    .DATA_WDTH                       (   ADDR_WDTH+1                                                 )    //
)
u_cmip_bus_delay_raddr_gray_pipe(
    .i_clk                           (   i_rd_clk                                                    ),   //
    .i_rst_n                         (   i_rd_rst_n                                                  ),   //
    .i_din                           (   raddr_gray                                                  ),   //
    .o_dout                          (   raddr_gray_d1                                               )    //
);



//sync the gray code of write address to rd_clk domain//
cmip_bit_sync #(
    .DATA_WDTH                       (   ADDR_WDTH+1                                                 )    //
)
u_waddr_wr_clk_to_rd_clk
(
    .i_dst_clk                       (   i_rd_clk                                                    ),   //
    .i_din                           (   waddr_gray_d1                                               ),   //
    .o_dout                          (   waddr_gray_rd                                               )    //
);

//sync the gray code of read address to wr_clk domain//
cmip_bit_sync #(
    .DATA_WDTH                       (   ADDR_WDTH+1                                                 )    //
)
u_raddr_rd_clk_to_wr_clk
(
    .i_dst_clk                       (   i_wr_clk                                                    ),   //
    .i_din                           (   raddr_gray_d1                                               ),   //
    .o_dout                          (   raddr_gray_wr                                               )    //
);

//gray code convert to address//
assign  waddr_ptr_rd                    =   gray2bin(waddr_gray_rd)                                     ;   //
assign  raddr_ptr_wr                    =   gray2bin(raddr_gray_wr)                                     ;   //

//assign waddr_ptr_rd_tmp = waddr_gray_rd;
//assign raddr_ptr_wr_tmp = raddr_gray_wr;
//
//generate
//      for(i=0;i<ADDR_WDTH;i=i+1)
//      begin: gray2bin
//              assign waddr_ptr_rd[i] = waddr_gray_rd[i] ^ waddr_ptr_rd_tmp[i+1];
//              assign raddr_ptr_wr[i] = raddr_gray_wr[i] ^ raddr_ptr_wr_tmp[i+1];
//      end
//endgenerate


wire   waddr_right;
wire   raddr_right;
assign waddr_right = (waddr_ptr >= raddr_ptr_wr)?1'b1:1'b0;
assign raddr_right = (waddr_ptr_rd >= raddr_ptr)?1'b1:1'b0;

//calculate the data_count=wr_address-rd_address in wr_clk and rd_clk//
//assign {ovf_nc ,wr_data_cnt} = waddr_right ? (waddr_ptr - raddr_ptr_wr) : (DPTH - raddr_ptr_wr + waddr_ptr);//spyglass disable W528,W164b
//assign {ovf_nc1,rd_data_cnt} = raddr_right ? (waddr_ptr_rd - raddr_ptr) : (DPTH - raddr_ptr + waddr_ptr_rd);//spyglass disable W528,W164b
assign {ovf_nc ,wr_data_cnt} = (waddr_ptr - raddr_ptr_wr) ;//spyglass disable W528,W164b
assign {ovf_nc1,rd_data_cnt} = (waddr_ptr_rd - raddr_ptr) ;//spyglass disable W528,W164b

assign {ovf_nc2 ,wr_gap} = (waddr_ptr + 1'b1) - raddr_ptr_wr;//spyglass disable W528,W164b
assign {ovf_nc3 ,rd_gap} = waddr_ptr_rd - raddr_ptr;//spyglass disable W528,W164b



//generate the almost full//
/*
always @(posedge i_wr_clk or negedge i_wr_rst_n)
    if(!i_wr_rst_n) begin
        o_aful                          <=              1'b0                                    ;   
        aful_active                     <=              1'b0                                    ;   
    end
    else if((~aful_active)&&((wr_data_cnt>=DPTH-i_aful_th)||((wr_data_cnt==DPTH-i_aful_th-1)&&i_wr))) begin
        o_aful                          <=              1'b1                                    ;   
        aful_active                     <=              1'b1                                    ;   
    end
    else if(aful_active&&(wr_data_cnt<DPTH-i_aful_th)) begin
        o_aful                          <=              1'b0                                    ;   
        aful_active                     <=              1'b0                                    ;   
    end
*/



always @(posedge i_wr_clk or negedge i_wr_rst_n)
    if(!i_wr_rst_n) begin
        o_aful                          <=              1'b0                                    ;   
        aful_active                     <=              1'b0                                    ;   
    end
    else if((~aful_active)&&((wr_data_cnt[ADDR_WDTH-1:0]>=DPTH-i_aful_th - RAM_PIPE_STAGE)||((wr_data_cnt[ADDR_WDTH-1:0]==DPTH- i_aful_th -1 - RAM_PIPE_STAGE)&&i_wr))) begin //edit by wqh
        o_aful                          <=              1'b1                                    ;   
        aful_active                     <=              1'b1                                    ;   
    end
    else if(aful_active&&(wr_data_cnt[ADDR_WDTH-1:0]< DPTH -i_aful_th- RAM_PIPE_STAGE)) begin
        o_aful                          <=              1'b0                                    ;   
        aful_active                     <=              1'b0                                    ;   
    end

    //generate the full//
always @(posedge i_wr_clk or negedge i_wr_rst_n)
    if(!i_wr_rst_n) begin
        o_full                          <=              1'b0                                    ;   
    end
    else begin
        o_full                          <=              (!(|wr_gap))||((wr_gap[ADDR_WDTH-1:0]>=DPTH-  RAM_PIPE_STAGE -1)&&i_wr)||(wr_gap[ADDR_WDTH-1:0]>=DPTH-  RAM_PIPE_STAGE)       ;   //edit wqh
    end
    
    //generate the almost empty//
always @(posedge i_rd_clk or negedge i_rd_rst_n)
    if(!i_rd_rst_n) begin
        afifo_amty                      <=              1'b0                                    ;   
        amty_active                     <=              1'b0                                    ;   
    end
    //else if ((!amty_active)&&(((rd_gap == i_amty_th+1)&&afifo_rd)||(rd_gap<=i_amty_th))) begin
    else if ((!amty_active)&&(((rd_data_cnt[ADDR_WDTH-1:0] == i_amty_th+1)&&afifo_rd)||(rd_data_cnt[ADDR_WDTH-1:0] <=i_amty_th))) begin
        afifo_amty                      <=              1'b1                                    ;   
        amty_active                     <=              1'b1                                    ;   
    end
    else if (amty_active&&(rd_data_cnt[ADDR_WDTH-1:0]  >i_amty_th)) begin
        afifo_amty                      <=              1'b0                                    ;   
        amty_active                     <=              1'b0                                    ;   
    end
 

/*
always @(posedge i_rd_clk or negedge i_rd_rst_n)
    if(!i_rd_rst_n) begin
        afifo_empty                     <=              1'b1                                    ;   
    end
    else begin
        afifo_empty                     <=              (!(|rd_gap))||((rd_gap==1)&&afifo_rd)   ;   
    end
*/
    assign   afifo_empty                =               (!(|rd_gap))                            ;   
    
    //generate the over flow and under flow int
always @(posedge i_wr_clk or negedge i_wr_rst_n)
    if(!i_wr_rst_n) begin
        o_ovfl_int                      <=              1'b0                                    ;   
    end
    else begin
        o_ovfl_int                      <=              i_wr && o_full                          ;   
    end
    
always @(posedge i_rd_clk or negedge i_rd_rst_n)
    if(!i_rd_rst_n) begin
        afifo_unfl_int                  <=              1'b0                                    ;   
    end
    else begin
        afifo_unfl_int                  <=              afifo_rd && o_empty                     ;   
    end
    
    
assign  o_wr_cnt                        =   wr_data_cnt                                                 ;   //
//assign o_rd_cnt = rd_data_cnt;

//generate the memory write and read//
assign  o_mem_wr                        =   i_wr&&(!o_full)                                             ;   //
assign  o_mem_waddr                     =   waddr_ptr[ADDR_WDTH-1:0]                                    ;   //
assign  o_mem_wdata                     =   i_din                                                       ;   //

assign  o_mem_rd                        =   afifo_rd &&(!afifo_empty)                                   ;   //
assign  o_mem_raddr                     =   raddr_ptr[ADDR_WDTH-1:0]                                    ;   //
assign  afifo_out                       =   i_mem_rdata                                                 ;   //



//binary to gray code function//
 function automatic [ADDR_WDTH:0] bin2gray;
    input                   [ADDR_WDTH:0]                                       bin_in                                  ;   //
    begin
        bin2gray                        =               bin_in^{1'b0,bin_in[ADDR_WDTH:1]}               ;   
    end
endfunction

//gray code to binary function//
function automatic [ADDR_WDTH:0] gray2bin;
    input                   [ADDR_WDTH:0]                                       gray_in                                 ;   //
    reg             [ADDR_WDTH:0]                                       gray_tmp                                        ;   //
    reg             [ADDR_WDTH:0]                                       bin                                             ;   //
    reg                                                                 tmp                                             ;   //
    integer i,j;
    
    begin
        gray_tmp                        =               gray_in                                      ;   
        for(i=0;i<=ADDR_WDTH;i=i+1)
        begin
            tmp                             =               1'b0                                    ;   
            for(j=i;j<=ADDR_WDTH;j=j+1)
            begin
                tmp                             =               gray_tmp[j]^tmp                         ;   
            end
            bin[i]                          =               tmp                                     ;   
        end
        gray2bin                        =               bin                                     ;   
        
    end
endfunction

endmodule
