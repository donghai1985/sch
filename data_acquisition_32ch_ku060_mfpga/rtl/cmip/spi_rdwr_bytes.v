// =================================================================================================
// Copyright 2020 - 2030 (c) Semi, Inc. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : spi_rdwr_bytes.v
// Module         : spi_rdwr_bytes
// Function       :                      
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by         Contents
// 0.1.0      2023/01/05                    Create new
//
// =================================================================================================
// End Revision
// =================================================================================================

module spi_rdwr_bytes (
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)
    input        [1:0]                      mode                           ,//(i)
    input        [7:0]                      frediv                         ,//(i)
    input        [1:0]                      cs_mode                        ,//(i)
    input        [1:0]                      byte_num                       ,//(i)
                                                                           
    input                                   trig                           ,//(i)
    output reg                              finish                         ,//(o)
    input        [31:0]                     writedata                      ,//(i) 
    output reg   [31:0]                     readdata                       ,//(o)
                                                                           
    output reg                              cs                             ,//(o)
    output                                  sck                            ,//(o)
    output                                  mosi                           ,//(o)
    input                                   miso                            //(i)
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------    

    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg           [7:0]                     wdata_8b                       ;
    wire          [7:0]                     rdata_8b                       ;
    wire                                    spi_8b_trig                    ;
    wire                                    spi_8b_finish                  ;
    reg                                     spi_8b_finish_d1               ;
    reg                                     trig_d1                        ;
    reg                                     trig_d2                        ;
    wire                                    trig_rise                      ;
    reg           [1:0]                     cnt                            ;
    reg           [31:0]                    writedata_d1                   ;
    reg           [1:0]                     byte_num_d1                    ;
    reg           [31:0]                    readdata_sh                    ;
    wire                                    finish_t1                      ;
    reg                                     finish_t2                      ;
    reg           [1:0]                     cs_mode_d1                     ;

    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign       trig_rise       =          trig_d1 && (~trig_d2)             ;
    assign       finish_t1       =  (byte_num_d1 == cnt) && spi_8b_finish     ;
    assign       spi_8b_trig     =  trig_rise || (spi_8b_finish_d1 && (~finish_t2));


// =================================================================================================
// RTL Body
// =================================================================================================
    always@(posedge clk or negedge rst_n)
        if(~rst_n) begin
            writedata_d1     <= 32'b0;
            byte_num_d1      <= 2'b0 ;
            cs_mode_d1       <= 2'b0 ;
        end else if(trig) begin
            writedata_d1     <= writedata;
            byte_num_d1      <= byte_num ;
            cs_mode_d1       <= cs_mode  ;
        end

    always@(posedge clk or negedge rst_n)
        if(~rst_n) begin
            trig_d1          <= 1'b0;
            trig_d2          <= 1'b0;
            finish           <= 1'b0;
            finish_t2        <= 1'b0;
            spi_8b_finish_d1 <= 1'b0;
        end else begin
            trig_d1          <= trig         ;
            trig_d2          <= trig_d1      ;
            finish_t2        <= finish_t1    ;
            finish           <= finish_t2    ;
            spi_8b_finish_d1 <= spi_8b_finish;
        end

    always@(posedge clk or negedge rst_n)
        if(~rst_n) begin
            cnt      <= 2'b0;
        end else if(finish_t1)begin
            cnt      <= 2'b0;
        end else if(spi_8b_finish) begin
            cnt      <= cnt + 1'b1;
        end

    always@(*)begin
        case(cnt)
            2'b00:wdata_8b = writedata_d1[7:0];
            2'b01:wdata_8b = writedata_d1[15:8];
            2'b10:wdata_8b = writedata_d1[23:16];
            2'b11:wdata_8b = writedata_d1[31:24];
        endcase
    end


    always@(posedge clk or negedge rst_n)
        if(~rst_n) begin
            readdata_sh      <= 32'b0;
        end else if(spi_8b_finish && (cnt==2'b00)) begin
            readdata_sh      <= {24'd0,rdata_8b}  ;
        end else if(spi_8b_finish && (cnt==2'b01)) begin
            readdata_sh      <= {16'd0,rdata_8b,readdata_sh[7:0]}  ;
        end else if(spi_8b_finish && (cnt==2'b10)) begin
            readdata_sh      <= {8'd0,rdata_8b,readdata_sh[15:0]}  ;
        end else if(spi_8b_finish && (cnt==2'b11)) begin
            readdata_sh      <= {rdata_8b,readdata_sh[23:0]}  ;
        end


    always@(posedge clk or negedge rst_n)
        if(~rst_n) begin
            readdata      <= 32'b0;
        end else if(finish_t2) begin
            readdata      <= readdata_sh ;
        end



    //---------------------------------------------------------------------
    // CS output.
    //---------------------------------------------------------------------  
    always@(posedge clk or negedge rst_n)
        if(!rst_n)begin
            cs <= 1'b1;
        end else if(trig_rise)begin
            case(cs_mode)
                2'b00:   cs <= 1'b0;  //"cs normal"
                2'b01:   cs <= 1'b0;  //"cs go low"
                2'b10:   cs <= 1'b0;  //"cs go high"
                default: cs <= 1'b1;
            endcase
        end else if(finish_t1)begin
            case(cs_mode)
                2'b00:   cs <= 1'b1;
                2'b01:   cs <= 1'b0;
                2'b10:   cs <= 1'b1;
                default: cs <= 1'b1;
            endcase
        end

    //---------------------------------------------------------------------
    // spi_master Module Inst.
    //---------------------------------------------------------------------     
    spi_master u_spi_master(
        .clk               (clk          ),
        .rst_n             (rst_n        ),
        .mode              (mode         ),
        .frediv            (frediv       ),
        .trig              (spi_8b_trig  ),
        .finish            (spi_8b_finish),
        .writedata         (wdata_8b     ),  
        .readdata          (rdata_8b     ), 
        .cs                (             ),
        .sck               (sck          ),
        .mosi              (mosi         ),
        .miso              (miso         )
    );








endmodule





