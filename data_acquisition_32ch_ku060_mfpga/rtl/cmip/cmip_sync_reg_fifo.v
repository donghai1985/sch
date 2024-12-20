module cmip_sync_reg_fifo #(


    parameter DPTH          = 8,
    parameter DATA_WDTH     = 1,
    parameter ADDR_WDTH     = 3,//$clog2(DPTH)
    parameter FWFT          = 1
    )
    (

    input                           i_clk,
    input                           i_rst_n,
    input       [ADDR_WDTH:0]       i_aful_th,
    input       [ADDR_WDTH:0]       i_amty_th,
    input                           i_wr,
    input       [DATA_WDTH-1:0]     i_din,
    input                           i_rd,
    output      [DATA_WDTH-1:0]     o_dout,
    output                          o_aful,
    output                          o_amty,
    output                          o_full,
    output                          o_empty,
    output                          o_ovfl_int,
    output                          o_unfl_int,
    output      [ADDR_WDTH:0]       o_used_cnt


    );

//----------------------------------------------------------------------------

localparam  RAM_PIPE_STAGE      = 1                 ;
localparam  PRE_REG_NUM         = RAM_PIPE_STAGE + 1;
//genvar i;
//----------------------------------------------------------------------------

reg  [DATA_WDTH-1:0]        mem [DPTH-1:0]          ;

wire [ADDR_WDTH-1:0]        waddr               ;//
wire [ADDR_WDTH-1:0]        raddr               ;//

reg [ADDR_WDTH:0]           w_addr              ;//
reg [ADDR_WDTH:0]           r_addr              ;//

reg                         fifo_aful_active    ;//
reg                         fifo_amty_active    ;//
wire                        mem_ren             ;//
wire                        mem_wen             ;//
wire [DATA_WDTH-1:0]        mem_out             ;//



wire [ADDR_WDTH:0]          fifo_aful_th        ;//
wire [ADDR_WDTH:0]          fifo_amty_th        ;//    
wire                        fifo_wr             ;//
wire [DATA_WDTH-1:0]        fifo_in             ;//
wire                        fifo_rd             ;//
wire [DATA_WDTH-1:0]        fifo_out            ;//
reg                         fifo_aful           ;//
reg                         fifo_amty           ;//
reg                         fifo_full           ;//
reg                         fifo_empty          ;//
reg                         fifo_ovfl_int       ;//
reg                         fifo_unfl_int       ;//
reg  [ADDR_WDTH:0]          fifo_used_cnt       ;//


generate 
genvar i;
    if(FWFT==1) begin: fwft_u0

        wire                            s_fifo_rd;
        wire                            fifo_out_val;
        wire                            ren;
        wire                            rd_data_val;
        wire                            s_empty;
        reg                             s_unfl_int;
        reg  [ADDR_WDTH:0]              s_fifo_count;
        wire [ADDR_WDTH:0]              fifo_used_nc;
        wire                            fifo_unfl_int_nc;
        reg  [(DATA_WDTH-1):0]          pre_rd_data[(PRE_REG_NUM-1):0];
        reg  [(PRE_REG_NUM-1):0]        pre_rd_data_val;
        reg  [(PRE_REG_NUM-1):0]        in_active;
        wire [(PRE_REG_NUM-1):0]        in_active_nd;
        reg  [(PRE_REG_NUM-1):0]        out_active;
        wire [(DATA_WDTH-1):0]          pre_rd_data_mask[(PRE_REG_NUM-1):0];
        wire [(DATA_WDTH-1):0]          pre_rd_data_out[(PRE_REG_NUM-1):0];


        assign fifo_aful_th =   i_aful_th;
        assign fifo_amty_th =   i_amty_th;
        assign fifo_wr      =   i_wr;
        assign fifo_in      =   i_din;
        //assign fifo_rd      =   i_rd;
        //assign o_dout       =   fifo_out;
        assign o_aful       =   fifo_aful;
        assign o_amty       =   fifo_amty;
        assign o_full       =   fifo_full;
        //assign o_empty      =   fifo_empty;
        assign o_ovfl_int   =   fifo_ovfl_int;
        //assign o_unfl_int   =   fifo_unfl_int;
        //assign o_used_cnt           =   fifo_used_cnt;

        assign fifo_rd              =   s_fifo_rd;
        assign o_dout               =   pre_rd_data_out[PRE_REG_NUM-1];
        assign o_empty              =   s_empty;
        assign o_unfl_int           =   s_unfl_int;
        assign o_used_cnt           =   s_fifo_count;
        assign fifo_used_nc         =   fifo_used_cnt;  //spyglass disable W528
        assign fifo_unfl_int_nc     =   fifo_unfl_int;  //spyglass disable W528
        assign ren                  = i_rd & rd_data_val;

        always @ (posedge i_clk or negedge i_rst_n)
            if (~i_rst_n) begin
                in_active <= {{(PRE_REG_NUM-1){1'b0}},1'b1};
            end
            else if(s_fifo_rd) begin
                in_active <= {in_active[(PRE_REG_NUM-2):0],in_active[PRE_REG_NUM-1]};
            end

        always @ (posedge i_clk or negedge i_rst_n)
            if(~i_rst_n) begin    
                out_active <= {{(PRE_REG_NUM-1){1'b0}},1'b1};
            end
            else if (ren) begin
                out_active <= {out_active[(PRE_REG_NUM-2):0],out_active[PRE_REG_NUM-1]};
            end
        
        //generate
            for (i=0;i<PRE_REG_NUM;i=i+1) begin: genrate_pre_rd_data
                always @(posedge i_clk)
                    if (~i_rst_n) begin
                        pre_rd_data[i] <= {(DATA_WDTH){1'b0}};
                        pre_rd_data_val[i] <= 1'b0;
                    end
                    else if (fifo_out_val&in_active_nd[i]) begin
                        pre_rd_data[i] <= fifo_out;
                        pre_rd_data_val[i] <= 1'b1;
                    end
                    else if(ren&out_active[i]) begin
                        pre_rd_data_val[i] <= 1'b0;
                    end
            end
        //endgenerate
        
        //generate
            for (i=0;i<PRE_REG_NUM;i=i+1) begin : genrate_pre_rd_data_mask
                assign pre_rd_data_mask[i] = pre_rd_data[i] &{DATA_WDTH{out_active[i]}};
            end
        //endgenerate
        
        
        //generate
            for (i=1;i<PRE_REG_NUM;i=i+1) begin : genrate_pre_rd_data_out
                assign pre_rd_data_out[i] = pre_rd_data_mask[i] | pre_rd_data_out[i-1];
            end
        //endgenerate
        
        
        always @( posedge i_clk or negedge i_rst_n)
            if(~i_rst_n) begin
                s_fifo_count <= {(ADDR_WDTH+1){1'b0}};
            end
            else if(mem_wen & (~ren)) begin
                s_fifo_count <= s_fifo_count+1'b1;//spyglass disable W484
            end
            else if((~mem_wen) & ren) begin
                s_fifo_count <= s_fifo_count-1'b1;//spyglass disable W484
            end

        assign pre_rd_data_out[0] =pre_rd_data_mask[0];
        assign rd_data_val=|(pre_rd_data_val&out_active);
        assign s_empty = ~rd_data_val;
        assign s_fifo_rd = (~fifo_empty) & (ren|((in_active & pre_rd_data_val) == {PRE_REG_NUM{1'b0}}));
        
        cmip_bus_delay
            #(
                .BUS_DELAY          (   RAM_PIPE_STAGE      ),
                .DATA_WDTH      (   PRE_REG_NUM         )
            )
        u_bus_delay_0
            (
                .i_clk          (   i_clk                 ),
                .i_rst_n        (   i_rst_n               ),
                .i_din          (   in_active             ),
                .o_dout         (   in_active_nd          )
            );
        
        cmip_bus_delay
            #(
                .BUS_DELAY          (   RAM_PIPE_STAGE      ),
                .DATA_WDTH      (   1'b1                )
            )
        u_bus_delay_1
            (
                .i_clk          (   i_clk                 ),
                .i_rst_n        (   i_rst_n               ),
                .i_din          (   s_fifo_rd             ),
                .o_dout         (   fifo_out_val          )
            );
                 
        always @( posedge i_clk or negedge i_rst_n)
            if(~i_rst_n) begin
                s_unfl_int <= 1'b0;
             end
            else begin
                s_unfl_int <= i_rd & s_empty;
            end
    end
    else begin:pass_u0
        assign fifo_aful_th =   i_aful_th;
        assign fifo_amty_th =   i_amty_th;
        assign fifo_wr      =   i_wr;
        assign fifo_in      =   i_din;
        assign fifo_rd      =   i_rd;
        assign o_dout       =   fifo_out;
        assign o_aful       =   fifo_aful;
        assign o_amty       =   fifo_amty;
        assign o_full       =   fifo_full;
        assign o_empty      =   fifo_empty;
        assign o_ovfl_int   =   fifo_ovfl_int;
        assign o_unfl_int   =   fifo_unfl_int;
        assign o_used_cnt   =   fifo_used_cnt;
    end
endgenerate
//---------------------------------------------------------------------------
//common fifo 
//---------------------------------------------------------------------------
//----------------------------------------------------------------------------
//fifo write addr
//----------------------------------------------------------------------------
assign mem_wen = fifo_wr & (~fifo_full);

always @( posedge i_clk or negedge i_rst_n)
    if(~i_rst_n) begin
        w_addr <= {(ADDR_WDTH+1){1'b0}};
    end
    else if(mem_wen) begin
        w_addr <= (w_addr == (DPTH-1)) ? {(ADDR_WDTH+1){1'b0}} : (w_addr+1'b1);//spyglass disable W484
    end

assign waddr = w_addr[ADDR_WDTH-1 : 0];


//----------------------------------------------------------------------------
//fifo read  addr
//----------------------------------------------------------------------------
assign mem_ren = fifo_rd & (~fifo_empty);

always @( posedge i_clk or negedge i_rst_n)
    if(~i_rst_n) begin
        r_addr <= {(ADDR_WDTH+1){1'b0}};
    end
    else if(mem_ren) begin
        r_addr <= (r_addr == (DPTH-1)) ? {(ADDR_WDTH+1){1'b0}} : (r_addr+1'b1);//spyglass disable W484
    end

assign raddr = r_addr[ADDR_WDTH-1 : 0];


//----------------------------------------------------------------------------
//fifo state
//----------------------------------------------------------------------------

always @( posedge i_clk or negedge i_rst_n)
    if(~i_rst_n) begin
        fifo_ovfl_int <= 1'b0;
        fifo_unfl_int <= 1'b0;
    end
    else begin
        fifo_ovfl_int <= fifo_wr & fifo_full;
        fifo_unfl_int <= fifo_rd & fifo_empty;
    end

always @( posedge i_clk or negedge i_rst_n)
    if(~i_rst_n) begin
        fifo_used_cnt <= {(ADDR_WDTH+1){1'b0}};
    end
    else if(mem_wen & (~mem_ren)) begin
        fifo_used_cnt <= fifo_used_cnt+1'b1; //spyglass disable W484
    end
    else if((~mem_wen) & mem_ren) begin
        fifo_used_cnt <= fifo_used_cnt-1'b1; //spyglass disable W484
    end

always @( posedge i_clk or negedge i_rst_n)
    if(~i_rst_n) begin
        fifo_aful <= 1'b0;
        fifo_aful_active <= 1'b0;
    end
    else if(((!fifo_aful_active) && (fifo_used_cnt>=DPTH - fifo_aful_th)) || ((fifo_used_cnt == (DPTH - fifo_aful_th-1)) && (mem_wen & (~mem_ren)))) begin
        fifo_aful <= 1'b1;
        fifo_aful_active <= 1'b1;
    end
    else if((fifo_aful_active && (fifo_used_cnt<DPTH - fifo_aful_th)) || ((fifo_used_cnt == DPTH - fifo_aful_th) && ((!mem_wen) & mem_ren))) begin
        fifo_aful <= 1'b0;
        fifo_aful_active <= 1'b0;
    end

always @( posedge i_clk or negedge i_rst_n)
    if(~i_rst_n) begin
        fifo_full <= 1'b0;
    end
    else if(fifo_full & mem_ren) begin
        fifo_full <= 1'b0;
    end
    else begin
        fifo_full <= (fifo_used_cnt == DPTH) || ((fifo_used_cnt == (DPTH-1)) && (mem_wen & (~mem_ren)));
    end

always @( posedge i_clk or negedge i_rst_n)
    if(~i_rst_n) begin
        fifo_amty <= 1'b1;
        fifo_amty_active <= 1'b1;
    end
    else if(((!fifo_amty_active) && (fifo_used_cnt<=fifo_amty_th)) || ((fifo_used_cnt == (fifo_amty_th+1)) && ((!mem_wen) & mem_ren))) begin
        fifo_amty <= 1'b1;
        fifo_amty_active <= 1'b1;
    end
    else if((fifo_amty_active && (fifo_used_cnt>fifo_amty_th)) || ((fifo_used_cnt == fifo_amty_th) && (mem_wen  & (!mem_ren)))) begin
        fifo_amty <= 1'b0;
        fifo_amty_active <= 1'b0;
    end

always @( posedge i_clk or negedge i_rst_n)
    if(~i_rst_n) begin
        fifo_empty <= 1'b1;
    end
    else if(fifo_empty & mem_wen) begin
        fifo_empty <= 1'b0;
    end
    else begin
        fifo_empty <= (fifo_used_cnt == 0) || ((fifo_used_cnt == 1) && ((!mem_wen) & mem_ren));
    end


//----------------------------------------------------------------------------
//mem write&read
//----------------------------------------------------------------------------


always @(posedge i_clk)
    if(mem_wen)
        mem[waddr] <= fifo_in;

assign mem_out = mem[raddr];

    cmip_bus_delay
        #(
            .BUS_DELAY          (   RAM_PIPE_STAGE      ),
            .DATA_WDTH      (   DATA_WDTH           )
        )
    u_bus_delay_2
        (
            .i_clk          (   i_clk                 ),
            .i_rst_n        (   i_rst_n               ),
            .i_din          (   mem_out               ),
            .o_dout         (   fifo_out              )
        );



endmodule
