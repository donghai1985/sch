// =================================================================================================
// Copyright 2020 - 2030 (c) Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : ddr_wr_sch.v
// Module         : ddr_wr_sch
// Function       : 
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2024/01/30   NTEW)wang.qh     Create new
//
// =================================================================================================
// End Revision
// =================================================================================================
module mem_ctrl_inf #(
    parameter                               DQ_WD           = 32           ,
    parameter                               DDR_DATA_WD     = 512          ,
    parameter                               DDR_ADDR_WD     = 30           ,
    parameter                               DDR_SIZE        = 32'h1000     
)(
    input                                   ddr_clk                        ,//(i)
    input                                   ddr_rst_n                      ,//(i)
                                                                               
    input                                   rd_ddr_req                     ,//(i)
    input             [8-1:0]               rd_ddr_len                     ,//(i)
    input             [DDR_ADDR_WD-1:0]     rd_ddr_addr                    ,//(i)
    output                                  rd_ddr_data_valid              ,//(o)
    output            [DDR_DATA_WD-1:0]     rd_ddr_data                    ,//(o)
    output                                  rd_ddr_finish                  ,//(o)
                                                                                 
    input                                   wr_ddr_req                     ,//(i)
    input             [8-1:0]               wr_ddr_len                     ,//(i)
    input             [DDR_ADDR_WD-1:0]     wr_ddr_addr                    ,//(i)
    output                                  wr_ddr_data_req                ,//(o)
    input             [DDR_DATA_WD-1:0]     wr_ddr_data                    ,//(i)
    output                                  wr_ddr_finish                  ,//(o)
				      									     
    input                                   cfg_rst                        ,//(i)
	input                                   cfg_rd_mode                    ,//(i)
    output                                  burst_idle                     ,//(o)
    output reg        [DDR_DATA_WD-1:0]     avail_addr                     ,//(o)
    output reg        [31:0]                overflow_cnt                   ,//(o)
				      									     
    input                                   local_init_done                ,//(i)
    output            [DDR_ADDR_WD-1:0]     app_addr                       ,//(o)
    output            [2:0]                 app_cmd                        ,//(o)
    output                                  app_en                         ,//(o)
    output            [DDR_DATA_WD-1:0]     app_wdf_data                   ,//(o)
    output                                  app_wdf_end                    ,//(o)
    output            [DQ_WD      -1:0]     app_wdf_mask                   ,//(o)
    output                                  app_wdf_wren                   ,//(o)
    input             [DDR_DATA_WD-1:0]     app_rd_data                    ,//(i)
    input                                   app_rd_data_end                ,//(i)
    input                                   app_rd_data_valid              ,//(i)
    input                                   app_rdy                        ,//(i)
    input                                   app_wdf_rdy                    ,//(i)
    output                                  app_sr_req                     ,//(o)
    output                                  app_ref_req                    ,//(o)
    output                                  app_zq_req                     ,//(o)
    input                                   app_sr_active                  ,//(i)
    input                                   app_ref_ack                    ,//(i)
    input                                   app_zq_ack                      //(i)
);
    //cfg_rd_mode == 0:wait all read data finish,sta jump to idle.
	//cfg_rd_mode == 1:if all read cmd send(means read data maybe not finish),sta jump to idle.bandwidth will be faster.
    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    
    localparam        IDL            =      2'h0                           ;
    localparam        SWR            =      2'h1                           ;
    localparam        SRD            =      2'h2                           ;
	localparam        SRW            =      2'h3                           ;// Sta For Read Wait.
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg                                     local_init_done_d1             ;
    reg               [1:0]                 sta                            ;
    reg               [8-1:0]               r_wr_ddr_len                   ;
    reg               [DDR_ADDR_WD-1:0]     r_wr_ddr_addr                  ;
    reg               [8-1:0]               r_rd_ddr_len                   ;
    reg               [DDR_ADDR_WD-1:0]     r_rd_ddr_addr                  ;
	reg               [8-1:0]               cnt                            ;
	reg               [8-1:0]               rd_cnt                         ;
	wire                                    rd_ddr_cmd_cpl                 ;
	wire                                    rd_ddr_dat_cpl                 ;
	
	
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            burst_idle     =      (sta==IDL) ? 1'b1 : 1'b0       ;
    assign            app_wdf_mask   =      {DQ_WD{1'b0}}                  ;
	assign            app_en         =    (((sta==SWR) && app_wdf_rdy) || (sta==SRD)) && app_rdy;
    assign            app_cmd        =      (sta==SWR) ? 3'b000 : 3'b001   ;
	assign            app_wdf_wren   =      (sta==SWR) ? app_en : 1'b0     ;
	assign            app_wdf_end    =      app_wdf_wren                   ;
    assign            app_wdf_data   =      wr_ddr_data                    ;
    assign            wr_ddr_data_req=      app_wdf_wren                   ;
    assign            wr_ddr_finish  =     app_rdy && (sta==SWR) && (cnt==r_wr_ddr_len-1'b1);
	assign            rd_ddr_cmd_cpl =     app_rdy && (sta==SRD) && (cnt==r_rd_ddr_len-1'b1);
    assign            rd_ddr_dat_cpl =     app_rd_data_valid && (sta==SRW) && (rd_cnt==r_rd_ddr_len-1'b1);
    assign            rd_ddr_finish  =     (rd_ddr_cmd_cpl && cfg_rd_mode) || rd_ddr_dat_cpl;
    assign            app_addr       =     (sta==SWR) ? (r_wr_ddr_addr+{cnt,3'd0}):(r_rd_ddr_addr+{cnt,3'd0});

    assign            rd_ddr_data_valid  =  app_rd_data_valid              ;
    assign            rd_ddr_data        =  app_rd_data                    ;

// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge ddr_clk)begin
	    local_init_done_d1 <= local_init_done;
    end

    always@(posedge ddr_clk or negedge ddr_rst_n)begin
	    if(~ddr_rst_n)
		    sta <= IDL;
		else if(~local_init_done_d1 || cfg_rst)
		    sta <= IDL;
		else 
		    case(sta)
			IDL:if(rd_ddr_req)
			        sta <= SRD;
				else if(wr_ddr_req)
				    sta <= SWR;
			SWR:if(wr_ddr_finish)
			        sta <= IDL;
			SRD:if(rd_ddr_cmd_cpl && cfg_rd_mode)
			        sta <= IDL;
				else if(rd_ddr_cmd_cpl)
				    sta <= SRW;
		    SRW:if(rd_ddr_dat_cpl)
			        sta <= IDL;
			default:sta <= IDL;
			endcase
    end


    always@(posedge ddr_clk or negedge ddr_rst_n)begin //wr lock
	    if(~ddr_rst_n)begin
            r_wr_ddr_len  <=  9'd0;
            r_wr_ddr_addr <= {DDR_ADDR_WD{1'b0}};
		end else if((sta == IDL) && wr_ddr_req)begin
            r_wr_ddr_len  <= wr_ddr_len ;
            r_wr_ddr_addr <= wr_ddr_addr;
		end
    end

    always@(posedge ddr_clk or negedge ddr_rst_n)begin //rd lock
	    if(~ddr_rst_n)begin
            r_rd_ddr_len  <=  9'd0;
            r_rd_ddr_addr <= {DDR_ADDR_WD{1'b0}};
		end else if((sta == IDL) && rd_ddr_req)begin
            r_rd_ddr_len  <= rd_ddr_len ;
            r_rd_ddr_addr <= rd_ddr_addr;
		end
    end

    always@(posedge ddr_clk or negedge ddr_rst_n)begin//cnt
	    if(~ddr_rst_n) 
            cnt  <=  9'd0;
		else if(cfg_rst)
            cnt  <=  9'd0;
		else if(sta==IDL)
		    cnt  <=  9'd0;
		else if(app_en)
		    cnt  <=  cnt + 1'b1;
    end

    always@(posedge ddr_clk or negedge ddr_rst_n)begin//rd_cnt
	    if(~ddr_rst_n) 
            rd_cnt  <=  9'd0;
		else if(cfg_rst)
            rd_cnt  <=  9'd0;
		//else if(sta==IDL)
		else if(rd_ddr_dat_cpl)
		    rd_cnt  <=  9'd0;
		else if(app_rd_data_valid)
		    rd_cnt  <=  rd_cnt + 1'b1;
    end




    //--------------------------------------------------------------------------------//
    //localparam   DDR_SIZE  = 1024 * 1024 * 1024 / 64;//(1GB / 64bytes)
    always@(posedge ddr_clk or negedge ddr_rst_n)begin
        if(~ddr_rst_n)begin
            avail_addr <= 'd0;
        end else if(cfg_rst)begin
            avail_addr <= 'd0;
        end else if(rd_ddr_data_valid && app_en && app_wdf_wren && (app_cmd==3'b000))begin
            avail_addr <= avail_addr;//512bit
        end else if(app_en && app_wdf_wren && (app_cmd==3'b000))begin
            if(avail_addr == DDR_SIZE - 1'b1)
                avail_addr <= 'd0;
            else
                avail_addr <= avail_addr + 1'b1;//512bit
        end else if(rd_ddr_data_valid)begin
            if(avail_addr == 'd0)
                avail_addr <= 'd0;
            else
                avail_addr <= avail_addr - 1'b1;//512bit
        end
    end
    
    
    always@(posedge ddr_clk or negedge ddr_rst_n)begin
        if(~ddr_rst_n)
            overflow_cnt <= 'd0;
        else if(cfg_rst)
            overflow_cnt <= 'd0;
        else if(avail_addr >= DDR_SIZE - 3)
            overflow_cnt <= overflow_cnt + 1'b1;//512bit
    end































endmodule 
















