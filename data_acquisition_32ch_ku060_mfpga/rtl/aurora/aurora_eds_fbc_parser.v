module aurora_eds_fbc_parser #(
    parameter                               DATA_WD         =    64        ,
    parameter                               DOUT_WD        =    128        ,
    parameter                               FIFO_DEPTH     =    128        
)(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input                                   cfg_rst                        ,//(i)

    input             [DATA_WD   -1:0]      s_axis_tdata                   ,//(i)
    input             [DATA_WD/8 -1:0]      s_axis_tkeep                   ,//(i)
    input                                   s_axis_tvalid                  ,//(i)
    output                                  s_axis_tready                  ,//(o)
    input                                   s_axis_tlast                   ,//(i)

    output            [DOUT_WD   -1:0]      m_axis_tdata                   ,//(o)
    output            [DOUT_WD/8 -1:0]      m_axis_tkeep                   ,//(o)
    output                                  m_axis_tvalid                  ,//(o)
    input                                   m_axis_tready                  ,//(i)
    output                                  m_axis_tlast                   ,//(o)
    
    output   reg                            eds_send_en                    ,//(o)
    output                                  eds_finish                     ,//(o)
    output                                  eds_cpl                        ,//(o)
    output                                  fbc_cpl                        ,//(o)
    output            [31          :0]      eds_fifo_full_cnt              ,//(o)
    output            [31          :0]      eds_sop_eop_cnt                ,//(o)
    output            [31          :0]      fbc_sop_eop_cnt                ,//(o)
    output            [31          :0]      eds_sop_eop_clr_cnt            ,//(o)
    output            [31          :0]      eds_vld_cnt                     //(o)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                              DIN_WD            =  DATA_WD    ;
    localparam                              RATE              =  DOUT_WD/DIN_WD;
    localparam                              FIFO_ADDR_WD      =  $clog2(FIFO_DEPTH);
    //---------------------------------------------------------------------     
    // Defination of Internal Signals                                           
    //---------------------------------------------------------------------     
    reg               [DATA_WD   -1:0]      s_axis_tdata_d1                 ;
    wire                                    last_flag                       ;
    //reg                                     eds_send_en                     ;
    reg                                     eds_send_en_d1                  ;
    wire                                    eds_send_en_pos                 ;
    reg                                     eds_first_drop                  ;

    wire                                    fifo_wr                         ;
    wire              [DIN_WD     -1:0]     fifo_din                        ;
    reg                                     fifo_wr_d1                      ;
    reg               [DIN_WD     -1:0]     fifo_din_d1                     ;
    reg                                     fifo_wr_d2                      ;
    reg               [DIN_WD     -1:0]     fifo_din_d2                     ;
    wire                                    fifo_full                       ;
    wire              [DOUT_WD    -1:0]     fifo_dout                       ;
    wire                                    fifo_empty                      ;
    wire                                    fifo_rd                         ;
    wire              [FIFO_ADDR_WD :0]     fifo_rd_cnt                     ;
    reg               [4            :0]     tlast_cnt                       ;
    wire              [15           :0]     eds_sop_cnt                     ;
    wire              [15           :0]     eds_eop_cnt                     ;
    wire              [15           :0]     fbc_sop_cnt                     ;
    wire              [15           :0]     fbc_eop_cnt                     ;
    wire              [15           :0]     eds_sop_clr_cnt                 ;
    wire              [15           :0]     eds_eop_clr_cnt                 ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            last_flag      =      s_axis_tvalid && s_axis_tready && s_axis_tlast ;
    assign            fifo_wr        =      s_axis_tvalid && s_axis_tready && eds_send_en  && (~eds_first_drop);
    assign            fifo_din       =      s_axis_tdata                    ;
    assign            s_axis_tready  =      1'b1                            ;
    assign            fifo_rd        =      m_axis_tvalid && m_axis_tready  ;
    assign            eds_send_en_pos=     ~eds_send_en_d1 && eds_send_en   ;
    assign            eds_finish     =      eds_send_en_d1 && (~eds_send_en);
    assign            eds_sop_eop_cnt=     {eds_eop_cnt,eds_sop_cnt}        ;
    assign            fbc_sop_eop_cnt=     {fbc_eop_cnt,fbc_sop_cnt}        ;
    assign            eds_sop_eop_clr_cnt ={eds_eop_clr_cnt,eds_sop_clr_cnt};

    assign            m_axis_tdata   =      byte_adj(fifo_dout)             ;
    assign            m_axis_tkeep   =     {(DOUT_WD/8){1'b1}}              ;
    assign            m_axis_tvalid  =     ~fifo_empty                      ;
    assign            m_axis_tlast   =     &tlast_cnt                       ;

// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge clk) begin
        fifo_wr_d1   <=  fifo_wr   ;
        fifo_din_d1  <=  fifo_din  ;
        fifo_wr_d2   <=  fifo_wr_d1   ;
        fifo_din_d2  <=  fifo_din_d1  ;
    end


    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            s_axis_tdata_d1 <= {DATA_WD{1'b0}};
        else if(s_axis_tvalid && s_axis_tready)
            s_axis_tdata_d1 <= s_axis_tdata;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            eds_first_drop <= 1'b0;
        else if(last_flag)
            eds_first_drop <= 1'b1;
        else if(s_axis_tvalid && s_axis_tready)
            eds_first_drop <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            eds_send_en_d1 <= 1'b0;
        else  
            eds_send_en_d1 <= eds_send_en;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            eds_send_en <= 1'b0;
        end else if(last_flag)begin
            if(s_axis_tdata_d1[31:0] == 32'h55aa_0001 && (s_axis_tdata[31:0] == 32'h0000_0001 || s_axis_tdata[31:0] == 32'h0000_0002))
                eds_send_en <= 1'b1;
            else if(s_axis_tdata_d1[31:0] == 32'h55aa_0001 && (s_axis_tdata[31:0] == 32'h0000_0000 || s_axis_tdata[31:0] == 32'h0000_0003))
                eds_send_en <= 1'b0;
        end
    end


    cmip_pluse_delay #(                                    
        .TIMES         (8'd255                   ), 
        .HOLD_CLK      (10                       )  
    )u0_cmip_pluse_delay(      
        .i_clk         (clk                      ),//(i)
        .i_rst_n       (rst_n                    ),//(i)
        .i_sig         (eds_finish && (s_axis_tdata_d1[31:0] == 32'h0000_0000)),//(i)
        .o_pluse       (eds_cpl                  ) //(o)
    );                                           

    cmip_pluse_delay #(                                    
        .TIMES         (8'd255                   ), 
        .HOLD_CLK      (10                       )  
    )u1_cmip_pluse_delay(      
        .i_clk         (clk                      ),//(i)
        .i_rst_n       (rst_n                    ),//(i)
        .i_sig         (eds_finish && (s_axis_tdata_d1[31:0] == 32'h0000_0003)),//(i)
        .o_pluse       (fbc_cpl                  ) //(o)
    );                                           

    //---------------------------------------------------------------------
    // cmip_afifo_wd_conv_wsrl.
    //---------------------------------------------------------------------
    cmip_afifo_wd_conv_wsrl #(                         
        .DPTH                   (FIFO_DEPTH             ),
        .WR_DATA_WD             (DATA_WD                ),
        .RD_DATA_WD             (DOUT_WD                ),
        .FWFT                   (1                      )
    )u_cmip_afifo_wd_conv_wsrl(    
        .i_wr_clk               (clk                    ),//(i)
        .i_wr_rst_n             (~cfg_rst && rst_n      ),//(i)
        .i_wr                   (fifo_wr_d2 && (~fifo_full) && eds_send_en),//(i)
        .i_din                  (fifo_din_d2            ),//(i)
        .o_full                 (fifo_full              ),//(o)
        .o_wr_cnt               (                       ),//(o)
        .i_rd_clk               (clk                    ),//(i)
        .i_rd_rst_n             (~cfg_rst && rst_n      ),//(i)
        .i_rd                   (fifo_rd                ),//(i)
        .o_dout                 (fifo_dout              ),//(o)
        .o_empty                (fifo_empty             ),//(o)
        .o_rd_cnt               (fifo_rd_cnt            ) //(o)
    );                 

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            tlast_cnt <= 'd0;
        else if(cfg_rst)
            tlast_cnt <= 'd0;
        else if(m_axis_tvalid && m_axis_tready)
            tlast_cnt <= tlast_cnt + 1'b1;
    end


    //---------------------------------------------------------------------
    // app_cnt.
    //---------------------------------------------------------------------
    cmip_app_cnt #(
        .width     (16                             )
    )u0_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (eds_finish && (s_axis_tdata_d1[31:0] == 32'h0000_0000)),//(i)
        .cnt       (eds_eop_cnt                    ) //(o)
    );

    cmip_app_cnt #(
        .width     (16                             )
    )u1_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (eds_send_en_pos && (s_axis_tdata_d1[31:0] == 32'h0000_0001)),//(i)
        .cnt       (eds_sop_cnt                    ) //(o)
    );


    cmip_app_cnt #(
        .width     (16                             )
    )u4_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (eds_finish && (s_axis_tdata_d1[31:0] == 32'h0000_0000)),//(i)
        .cnt       (fbc_eop_cnt                    ) //(o)
    );

    cmip_app_cnt #(
        .width     (16                             )
    )u5_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (eds_send_en_pos && (s_axis_tdata_d1[31:0] == 32'h0000_0001)),//(i)
        .cnt       (fbc_sop_cnt                    ) //(o)
    );


    cmip_app_cnt #(
        .width     (16                             )
    )u7_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (cfg_rst                        ),//(i)
        .vld       (eds_finish                     ),//(i)
        .cnt       (eds_eop_clr_cnt                ) //(o)
    );

    cmip_app_cnt #(
        .width     (16                             )
    )u8_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (cfg_rst                        ),//(i)
        .vld       (eds_send_en_pos                ),//(i)
        .cnt       (eds_sop_clr_cnt                ) //(o)
    );



    cmip_app_cnt #(
        .width     (32                             )
    )u2_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (cfg_rst                        ),//(i)
        .vld       (fifo_wr_d2 && (~fifo_full) && eds_send_en),//(i)
        .cnt       (eds_vld_cnt                    ) //(o)
    );


    cmip_app_cnt #(
        .width     (32                             )
    )u3_app_cnt(                                     
        .clk       (clk                            ),//(i)
        .rst_n     (rst_n                          ),//(i)
        .clr       (cfg_rst                        ),//(i)
        .vld       (fifo_full                      ),//(i)
        .cnt       (eds_fifo_full_cnt              ) //(o)
    );
    



    function automatic [DOUT_WD -1:0] byte_adj(
        input          [DOUT_WD -1:0]     a   
    );begin:abc
        integer i;
        for(i=1;i<=RATE;i=i+1)begin
            byte_adj[i*DIN_WD  -1 -:DIN_WD ] = a[(RATE + 1 - i)*DIN_WD  -1 -: DIN_WD ];
        end
    end
    endfunction




endmodule





