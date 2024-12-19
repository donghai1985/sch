`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/21
// Design Name: songyuxin
// Module Name: mem_burst_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//      This module completes the conversion of app interfaces, and only 
//      needs to be modified when switching to different DDR interfaces.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module mem_burst_ctrl#(
    parameter                           TCQ                  = 0.1,
    parameter                           DQ_WIDTH             = 32 ,
    parameter                           MEM_DATA_BITS        = 256,
    parameter                           ADDR_WIDTH           = 30 ,
    parameter                           DDR_SIZE             = 32'h0100_0000
)(
    input                               ddr_rst_i                   ,
    input                               ddr_clk_i                   ,
    
    input                               rd_ddr_req_i                ,
    input       [8-1:0]                 rd_ddr_len_i                ,
    input       [ADDR_WIDTH - 1:0]      rd_ddr_addr_i               ,
    output                              rd_ddr_data_valid_o         ,
    output      [MEM_DATA_BITS - 1:0]   rd_ddr_data_o               ,
    output                              rd_ddr_finish_o             ,

    input                               wr_ddr_req_i                ,
    input       [8-1:0]                 wr_ddr_len_i                ,
    input       [ADDR_WIDTH - 1:0]      wr_ddr_addr_i               ,
    output                              wr_ddr_data_req_o           ,
    input       [MEM_DATA_BITS - 1:0]   wr_ddr_data_i               ,
    output                              wr_ddr_finish_o             ,
    output                              burst_idle                  ,

    output reg  [ADDR_WIDTH - 1:0]      avail_addr                  ,
    output reg  [31:0]                  overflow_cnt                ,
    // ddr interface
    input                               local_init_done_i           ,
    output      [ADDR_WIDTH-1:0]        app_addr                    ,
    output      [2:0]                   app_cmd                     ,
    output                              app_en                      ,
    output      [MEM_DATA_BITS-1:0]     app_wdf_data                ,
    output                              app_wdf_end                 ,
    output      [DQ_WIDTH-1:0]          app_wdf_mask                ,
    output                              app_wdf_wren                ,
    input       [MEM_DATA_BITS-1:0]     app_rd_data                 ,
    input                               app_rd_data_end             ,
    input                               app_rd_data_valid           ,
    input                               app_rdy                     ,
    input                               app_wdf_rdy                 ,
    output                              app_sr_req                  ,
    output                              app_ref_req                 ,
    output                              app_zq_req                  ,
    input                               app_sr_active               ,
    input                               app_ref_ack                 ,
    input                               app_zq_ack                  
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

parameter                               MEM_IDLE                = 3'd0;
parameter                               MEM_READ_WAIT           = 3'd1;
parameter                               MEM_READ                = 3'd2;
parameter                               MEM_WRITE_WAIT          = 3'd3;
parameter                               MEM_WRITE               = 3'd4;
parameter                               MEM_WRITE_END           = 3'd5;
parameter                               MEM_READ_END            = 3'd6;
parameter                               MEM_READ_END1           = 3'd7;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [2:0]                           state                   = MEM_IDLE;
reg     [2:0]                           state_next              = MEM_IDLE;    

reg     [ADDR_WIDTH-1:0]                app_addr_r              = 'd0;
reg     [2:0]                           app_cmd_r               = 'd0;
reg                                     app_en_r                = 'd0;
reg                                     app_wdf_end_r           = 'd0;
reg                                     app_wdf_wren_r          = 'd0;

reg     [8-1:0]                         wr_remain_len           = 'd0;
reg     [8-1:0]                         rd_length               = 'd0;
reg     [8-1:0]                         rd_ddr_cnt              = 'd0;
reg     [8-1:0]                         rd_data_cnt             = 'd0;
reg                                     rd_ddr_data_valid       = 'd0; 
reg     [MEM_DATA_BITS - 1:0]           rd_ddr_data             = 'd0; 
wire                                    rd_ddr_finish                ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)
        state <= #TCQ MEM_IDLE;
    else if(~local_init_done_i) 
        state <= #TCQ MEM_IDLE;
    else
        state <= #TCQ state_next;
end

always@(*)begin
    state_next = state;
    case(state)
        MEM_IDLE:
            begin
                if(rd_ddr_req_i && rd_ddr_len_i != 'd0)       //读请￿?
                    state_next = MEM_READ_WAIT; 
                else if(wr_ddr_req_i && wr_ddr_len_i != 'd0) //写请￿?
                    state_next = MEM_WRITE_WAIT;
                else
                    state_next = MEM_IDLE;
            end
        MEM_READ_WAIT:
                if(app_rdy)
                    state_next = MEM_READ;
        MEM_READ:
            begin
                if(app_rd_data_valid && (rd_data_cnt+1 == rd_length))
                    state_next = MEM_READ_END; 
                else
                    state_next = MEM_READ;
            end
        MEM_WRITE_WAIT:
                if(app_rdy)
                    state_next = MEM_WRITE;
        MEM_WRITE: 
            begin
                if(wr_remain_len == 'd1 && app_wdf_end_r)
                    state_next = MEM_WRITE_END;
                else
                    state_next = MEM_WRITE;
            end
        MEM_WRITE_END:
            state_next = MEM_IDLE;
        MEM_READ_END:
            state_next = MEM_READ_END1;
        MEM_READ_END1:
            state_next = MEM_IDLE;
        default:    state_next = MEM_IDLE;
    endcase
end

always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)
	    app_cmd_r <= #TCQ 3'b000;
    else if(state==MEM_IDLE && rd_ddr_req_i)
        app_cmd_r <= #TCQ 3'b001;
    else if(state==MEM_IDLE && wr_ddr_req_i)
        app_cmd_r <= #TCQ 3'b000;
end

always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)
	    app_en_r <= #TCQ 'd0;
    else if((state==MEM_WRITE_WAIT || state==MEM_READ_WAIT) && app_rdy)
        app_en_r <= #TCQ 'd1;
    else if(state==MEM_READ && (rd_ddr_cnt+1==rd_length) && app_rdy)
        app_en_r <= #TCQ 'd0;
    else if(state==MEM_WRITE && wr_remain_len=='d1 && app_wdf_end_r)
        app_en_r <= #TCQ 'd0;
    else if(state==MEM_IDLE)
        app_en_r <= #TCQ 'd0;
end

// generate cmd address.
always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)begin
	    app_addr_r <= 'd0;
    end else if(state==MEM_IDLE)begin
        if(rd_ddr_req_i)
            app_addr_r <= #TCQ rd_ddr_addr_i;
        else if(wr_ddr_req_i)
            app_addr_r <= #TCQ wr_ddr_addr_i;
    end
    else if(state==MEM_WRITE && app_rdy && app_wdf_rdy && app_en_r)begin
        app_addr_r <= #TCQ app_addr_r + 'd8;
    end
    else if(state==MEM_READ && app_rdy)begin
        app_addr_r <= #TCQ app_addr_r + 'd8;
    end
end


always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)
	    rd_length <= #TCQ 'd0;
    else if(state==MEM_IDLE && rd_ddr_req_i)
        rd_length <= #TCQ rd_ddr_len_i;
end

always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)
	    rd_ddr_cnt <= #TCQ 10'd0;
    else if(state == MEM_READ && app_rdy)begin
        rd_ddr_cnt <= #TCQ rd_ddr_cnt + 'd1;
    end
    else if(state==MEM_IDLE)
        rd_ddr_cnt <= #TCQ 10'd0;
end

always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)
	    rd_ddr_data_valid <= #TCQ 'd0;
    else if(state==MEM_READ)begin
        if(app_rd_data_valid)begin
            rd_ddr_data_valid <= #TCQ 'd1;
            rd_ddr_data       <= #TCQ app_rd_data;
        end
        else begin
            rd_ddr_data_valid <= #TCQ 'd0;
        end
    end
    else begin
        rd_ddr_data_valid <= #TCQ 'd0;
    end
end

always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)
	    rd_data_cnt <= #TCQ 'd0;
    else if(state==MEM_READ)begin
        if(app_rd_data_valid)begin
            rd_data_cnt <= #TCQ rd_data_cnt + 1;
        end
    end
    else begin
        rd_data_cnt <= #TCQ 'd0;
    end
end


// write enable
always @(*) begin
    if(state==MEM_WRITE && app_rdy && app_wdf_rdy)begin
        app_wdf_end_r  <= #TCQ 'd1;
        app_wdf_wren_r <= #TCQ 'd1; 
    end
    else begin
        app_wdf_end_r  <= #TCQ 'd0;
        app_wdf_wren_r <= #TCQ 'd0;
    end
end

always@(posedge ddr_clk_i)begin
    case(state)
        MEM_IDLE:
            if(wr_ddr_req_i)
                wr_remain_len <= #TCQ wr_ddr_len_i;
        MEM_WRITE:
            if(app_rdy && app_wdf_rdy)
                wr_remain_len <= #TCQ wr_remain_len - 'd1;
        default:
                wr_remain_len <= #TCQ wr_remain_len;
    endcase
end


assign app_addr             = app_addr_r;
assign app_cmd              = app_cmd_r;
assign app_en               = app_en_r;
assign app_wdf_data         = wr_ddr_data_i;
assign app_wdf_end          = app_wdf_end_r;
assign app_wdf_mask         = 'd0;           // write data mask
assign app_wdf_wren         = app_wdf_wren_r;
assign wr_ddr_data_req_o    = state==MEM_WRITE && app_en_r && app_rdy && app_wdf_rdy;
assign wr_ddr_finish_o      = state==MEM_WRITE_END;
assign rd_ddr_data_valid_o  = rd_ddr_data_valid;
assign rd_ddr_data_o        = rd_ddr_data;
assign rd_ddr_finish        = state==MEM_READ_END;
assign rd_ddr_finish_o      = state==MEM_READ_END1;
assign burst_idle           = state==MEM_IDLE;

assign app_sr_req           = 'd0;  // reserve bit
assign app_ref_req          = 'd0;  // refresh bit
assign app_zq_req           = 'd0;  // ddr calibration bit
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//localparam   DDR_SIZE  = 1024 * 1024 * 1024 / 64;//(1GB / 64bytes)

always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)begin
        avail_addr <= 'd0;
    end else if(rd_ddr_data_valid && app_en && app_wdf_wren && (app_cmd==3'b000))begin
        avail_addr <= avail_addr;//512bit
    end else if(app_en && app_wdf_wren && (app_cmd==3'b000))begin
        if(avail_addr >= DDR_SIZE - 1'b1)
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


always@(posedge ddr_clk_i or posedge ddr_rst_i)begin
    if(ddr_rst_i)
        overflow_cnt <= 'd0;
    else if(avail_addr >= DDR_SIZE - 3)
        overflow_cnt <= overflow_cnt + 1'b1;//512bit
end































endmodule 
















