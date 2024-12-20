`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/27 13:40:10
// Design Name: 
// Module Name: ad9253_config
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ad9253_config(                                                                                    
		input                   clk	         	,
		input                   rst          	,
		input					sync_in			,
		input                   wr_data_en      ,
		input      [23:0]       wr_data         ,
		output                  spi_csn      	,
		output                  spi_clk      	,
		inout                   spi_data     	,
		output					adc_sync		,
		output					adc_pdwn		,
		output	reg				adc_config_ok                                                                                
);                                                                                                      

                                                                                                                                                                                                       
//-------------------------------------------------------- 
parameter             DLY_TIME  =    32'd1000000 ;      
parameter             CFG_NUM   =    8'd19       ;                                                                       
reg		[23:0]        mem_reg0  =    24'h000018  ;  
reg		[23:0]        mem_reg1  =    24'h000803  ;   //复位
reg		[23:0]        mem_reg2  =    24'h000800  ;   //清空复位                                                                                                                         
reg		[23:0]        mem_reg3  =    24'h00053f  ;  
reg		[23:0]        mem_reg4  =    24'h000901  ; 
reg		[23:0]        mem_reg5  =    24'h000b00  ;  
reg		[23:0]        mem_reg6  =    24'h000c00  ; 
reg		[23:0]		  mem_reg7  =    24'h000d02  ;   
reg		[23:0]        mem_reg8  =    24'h001400  ;  
reg		[23:0]        mem_reg9  =    24'h001500  ;  
reg		[23:0]        mem_reg10 =    24'h001600  ;                  
reg		[23:0]        mem_reg11 =    24'h001804  ;                          
reg		[23:0]		  mem_reg12 =    24'h002130  ;
reg		[23:0]        mem_reg13 =    24'h002200  ;
reg		[23:0]        mem_reg14 =    24'h010200  ;   
reg		[23:0]        mem_reg15	=    24'h010015  ; 	 //设置采样率                 
reg		[23:0]        mem_reg16 =    24'h00ff01  ;   //设置采样率使能   
reg		[23:0]        mem_reg17 =    24'h000d04  ; 
reg		[23:0]		  mem_reg18 =    24'h001400  ;                                         

// config  ad9253 from spi interface//                                                                    
wire             		spi_busy                ;                                                    
reg        [7:0] 		cfg_cnt  = 8'd0         ;                                                    
reg              		send_spi_vld = 1'b0     ;                                                                                                       
reg        [31:0]		cfg_delay = 32'd0       ; 
reg        [1:0]       inter_cnt = 10'd0       ;

reg		   [4:0]		cfg_state				;
wire	   [23:0]		mem_reg					;
wire                    soft_rst                ;

wire			  		rd_add_en  ;
wire       [12:0]		rd_add     ;
wire					rd_data_en ;
wire       [7:0]		rd_data    ; 
reg        [7:0]		rd_data_lock    ; 
// wire                    wr_data_en ;
// wire       [23:0]       wr_data    ;

assign		adc_sync	=	sync_in;
assign		adc_pdwn	=	1'b0;

assign		mem_reg		=	adc_config_ok    	?	24'h0    	:
                            (cfg_cnt == 'd0)	?	mem_reg0	:
							(cfg_cnt == 'd1)	?	mem_reg1	:
							(cfg_cnt == 'd2)	?	mem_reg2	:
							(cfg_cnt == 'd3)	?	mem_reg3	:
							(cfg_cnt == 'd4)	?	mem_reg4	:
							(cfg_cnt == 'd5)	?	mem_reg5	:
							(cfg_cnt == 'd6)	?	mem_reg6	:
							(cfg_cnt == 'd7)	?	mem_reg7	:
							(cfg_cnt == 'd8)	?	mem_reg8	:
							(cfg_cnt == 'd9)	?	mem_reg9	:
							(cfg_cnt == 'd10)	?	mem_reg10	:
							(cfg_cnt == 'd11)	?	mem_reg11	:
							(cfg_cnt == 'd12)	?	mem_reg12	:
							(cfg_cnt == 'd13)	?	mem_reg13	:
							(cfg_cnt == 'd14)	?	mem_reg14	:
							(cfg_cnt == 'd15)	?	mem_reg15	:
							(cfg_cnt == 'd16)	?	mem_reg16	:
							(cfg_cnt == 'd17)	?	mem_reg17	:
							(cfg_cnt == 'd18)	?	mem_reg18	:	24'h0;

//----------------------------------------------                                                                                             
always@(posedge clk or posedge rst)                                                                                                  
begin                                                                                                                                    
    if(rst) begin                                                                                                                              
        cfg_delay 		<= 32'd0; 
	end else if(soft_rst)begin
	    cfg_delay 		<= 32'd0; 
    end else if(cfg_delay < DLY_TIME) begin	//delay 10ms                                                                                       
        cfg_delay <= cfg_delay + 32'd1;   
	end
    else begin
		cfg_delay <= cfg_delay;
	end
end   
 
always@(posedge clk or posedge rst)                                                                                                                                                                                                                                   
    if(rst) begin                                                                                                                              
        inter_cnt 		<= 'd0; 
	end else if(cfg_state == 'd4) begin	//delay 10ms                                                                                       
        inter_cnt <= inter_cnt + 32'd1;   
	end else begin
		inter_cnt 		<= 'd0; 
	end

                                                                                                                                             
//----------------------------------------------                                                                                             
always@(posedge clk or posedge rst)                                                                                                  
begin                                                                                                                                    
    if(rst) begin
		cfg_state	<=	'd0;
	end
	else if(cfg_delay < DLY_TIME) begin
		cfg_state	<=	'd0;
	end
	else begin
		case(cfg_state)
		5'd0: begin
			if(cfg_cnt	< CFG_NUM) begin
				cfg_state	<=	'd1;
			end
			else begin
				cfg_state	<=	'd3;
			end
		end
		5'd1: begin
			if(spi_busy) begin
				cfg_state	<=	'd2;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd2: begin
			if(~spi_busy) begin
				cfg_state	<=	'd4;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd3: begin
			cfg_state	<=	cfg_state;
		end
		5'd4: begin
		    if(&inter_cnt)
			    cfg_state	<=	'd0;
			else 
			    cfg_state	<=	cfg_state;
		end
		default: begin
			cfg_state	<=	'd0;
		end
		endcase
	end
end                                                                                                                     
                                                                                            
always@(posedge clk or posedge rst)                                                                                                  
begin                                                                                                                                    
    if(rst) begin
		send_spi_vld		<= 'd0;
		cfg_cnt 			<= 8'd0;
		adc_config_ok		<= 'd0;
	end
	else if(cfg_delay < DLY_TIME) begin
		send_spi_vld		<= 'd0;
		cfg_cnt 			<= 8'd0;
		adc_config_ok		<= 'd0;
	end
	else begin
		case(cfg_state)
		5'd0: begin
			adc_config_ok		<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			if(cfg_cnt	< CFG_NUM) begin
				send_spi_vld		<= 'd1;
			end
			else begin
				send_spi_vld		<= 'd0;
			end
		end
		5'd1: begin
			adc_config_ok		<= 'd0;
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= cfg_cnt;
		end
		5'd2: begin
			adc_config_ok		<= 'd0;
			send_spi_vld		<= 'd0;
			if(~spi_busy) begin
				cfg_cnt 		<= cfg_cnt + 'd1;
			end
			else begin
				cfg_cnt 		<= cfg_cnt;
			end
		end
		5'd3: begin	
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= 8'd0;
			adc_config_ok		<= 'd1;				
		end
		5'd4: begin	
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			adc_config_ok		<= 'd0;				
		end
		default: begin
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= 8'd0;
			adc_config_ok		<= 'd0;
		end
		endcase
	end
end                                                                                                       
                                                                                                        
//-----------------------------------------------------------    
/*
ad9253_spi_if ad9253_spi_if_inst(
	.clk(clk),
	.rst_n(~rst),
	.wr_data_en(send_spi_vld),
	.wr_data(mem_reg),
	.rd_add_en(rd_add_en),
	.rd_add(rd_add),
	.spi_csn(spi_csn),
	.spi_clk(spi_clk),	//max 25MHz
    .spi_data(spi_data),
    .spi_busy(spi_busy),
	.rd_data_en(rd_data_en),
	.rd_data(rd_data)
);     

*/

wire wr_data_en_pos;
wire rd_add_en_pos ;
reg  rd_add_en_d1,rd_add_en_d2;
reg  wr_data_en_d1,wr_data_en_d2;

always@(posedge clk or posedge rst) 
    if(rst)begin
	    rd_add_en_d1  <= 1'b0;
		rd_add_en_d2  <= 1'b0;
	    wr_data_en_d1 <= 1'b0;
		wr_data_en_d2 <= 1'b0;
	end else begin
	    rd_add_en_d1  <= rd_add_en;
		rd_add_en_d2  <= rd_add_en_d1;
	    wr_data_en_d1 <= wr_data_en;
		wr_data_en_d2 <= wr_data_en_d1; 
	end
	
assign   wr_data_en_pos =  ~wr_data_en_d2 && wr_data_en_d1;
assign   rd_add_en_pos  =  ~rd_add_en_d2  && rd_add_en_d1 ;

/*
spi_vio u_spi_vio (
    .clk       (clk         ),  // input wire clk
    .probe_in0 (rd_data_en  ),  // input wire [0 : 0] probe_in0
    .probe_in1 (rd_data_lock),  // input wire [7 : 0] probe_in1
    .probe_out0(wr_data_en  ),  // output wire [0 : 0] probe_out0
    .probe_out1(wr_data     ),  // output wire [23 : 0] probe_out1
    .probe_out2(rd_add_en   ),  // output wire [0 : 0] probe_out2
    .probe_out3(rd_add      ),  // output wire [11 : 0] probe_out3
	.probe_out4(soft_rst    )  // output wire [0 : 0] probe_out2
);
*/

always@(posedge clk or posedge rst) 
    if(rst)begin
	    rd_data_lock  <= 'b0;
	end else if(rd_data_en) begin
		rd_data_lock  <= rd_data; 
	end

ad9253_spi_if ad9253_spi_if_inst(
    .clk       (clk         ),
    .rst_n     (~rst        ),
    .wr_data_en(wr_data_en_pos || send_spi_vld ),
    .wr_data   (wr_data        +  mem_reg      ),
    .rd_add_en (rd_add_en_pos   ),
    .rd_add    (rd_add      ),
    .spi_csn   (spi_csn     ),
    .spi_clk   (spi_clk     ), //max 25MHz
    .spi_data  (spi_data    ),
    .spi_busy  (spi_busy    ),
    .rd_data_en(rd_data_en  ),
    .rd_data   (rd_data     )
);     










                                                                                                                                                    
                                                                                                      
endmodule
