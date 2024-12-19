`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/20 13:58:40
// Design Name: 
// Module Name: lval_synncode
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
module lval_synncode_0chan 
(	
	input				clk_rxg,
	input				rst_rx,    
    input [1:0]		    ADC_depth,
    input 	            data_valid,
	input [1:0]	        chan_num,  	//0: 0~5	1: 0,2,4	2: 0,3	3: 0
 	input [11:0]		data_in,   
    output reg 	        Sync_Valid,
 	output reg [11:0]	Sync_Data
    ); 

	
	reg[11:0]    SYNC_CODE_1st		;
	reg[11:0]    SYNC_CODE_2nd		;
	reg[11:0]    SYNC_CODE_3rd		;
	reg[11:0]    SYNC_CODE_4th_SOL	;
	reg[11:0]    SYNC_CODE_4th_EOE	;
	reg[11:0]    SYNC_CODE_4th_SOO	;
	reg[11:0]    SYNC_CODE_4th_EOL	;
	reg[15:0]    LVAL_LENGTH	;
	reg[1:0]     chan_num_in       ;    
	reg[1:0]     ADC_depth_in       ;    
	always @(posedge clk_rxg)begin
		if(rst_rx)begin
			SYNC_CODE_1st			<= 12'h0FF;						
			SYNC_CODE_2nd			<= 12'h000;
			SYNC_CODE_3rd			<= 12'h000; 
			SYNC_CODE_4th_SOL		<= 12'h0AB;
			SYNC_CODE_4th_EOE		<= 12'h09D; 
			SYNC_CODE_4th_SOO		<= 12'h080;
			SYNC_CODE_4th_EOL		<= 12'h0B6;	 
		    ADC_depth_in            <= ADC_depth;
		    chan_num_in             <= chan_num;
		end                         
		else begin                  
		    ADC_depth_in            <= ADC_depth;
		    chan_num_in             <= chan_num;
		
			case(chan_num_in)  
			    3'd0:begin
				        LVAL_LENGTH  <= 16'd352; 
				    end
			    3'd1:begin
				        LVAL_LENGTH  <= 16'd704; 
				    end
			    3'd2:begin
				        LVAL_LENGTH  <= 16'd1056; 
				    end
			    3'd3:begin
				        LVAL_LENGTH  <= 16'd2112; 
				    end 
			endcase
		    case(ADC_depth_in)
			    2'd0:begin
						SYNC_CODE_1st			= 12'h0FF;						
						SYNC_CODE_2nd			= 12'h000;
						SYNC_CODE_3rd			= 12'h000; 
						SYNC_CODE_4th_SOL		= 12'h0AB;
						SYNC_CODE_4th_EOE		= 12'h09D; 
						SYNC_CODE_4th_SOO		= 12'h080;
						SYNC_CODE_4th_EOL		= 12'h0B6;	 
		            end
			    2'd1:begin
						SYNC_CODE_1st			= 12'h3FF;						
						SYNC_CODE_2nd			= 12'h000;
						SYNC_CODE_3rd			= 12'h000; 
						SYNC_CODE_4th_SOL		= 12'h2AC;
						SYNC_CODE_4th_EOE		= 12'h274; 
						SYNC_CODE_4th_SOO		= 12'h200;
						SYNC_CODE_4th_EOL		= 12'h2D8;	 
		            end
			    2'd2:begin
						SYNC_CODE_1st			= 12'hFFF;						
						SYNC_CODE_2nd			= 12'h000;
						SYNC_CODE_3rd			= 12'h000; 
						SYNC_CODE_4th_SOL		= 12'hAB0;
						SYNC_CODE_4th_EOE		= 12'h9D0; 
						SYNC_CODE_4th_SOO		= 12'h800;
						SYNC_CODE_4th_EOL		= 12'hB60;	 
		            end
			endcase
		end
	end 
	 
	reg[2:0]	FlagSyncCode;
	reg[1:0]	FlagSyncCodeID;
	reg[2:0]	PrevSyncCodes;
	reg			FlagSyncCode_SOL; 
	reg			FlagSyncCode_SOO;
	reg			data_valid_q;
	always @(posedge clk_rxg)begin
		if(rst_rx)begin 
			PrevSyncCodes		<= 3'd0;
			FlagSyncCodeID		<= 2'd0;
			FlagSyncCode_SOL    <= 1'b0;
			FlagSyncCode_SOO    <= 1'b0;  
			data_valid_q        <= 1'b0;  
		end			
		else begin
		    data_valid_q        <= data_valid;
 			if(data_valid_q == 1'b1) begin
				PrevSyncCodes[0]    <= FlagSyncCode[0];                      	
				PrevSyncCodes[1]    <= FlagSyncCode[1] & PrevSyncCodes[0]; 	
				PrevSyncCodes[2]    <= FlagSyncCode[2] & PrevSyncCodes[1]; 		
				FlagSyncCode_SOL    <= PrevSyncCodes[2] & FlagSyncCodeID[0];	
				FlagSyncCode_SOO    <= PrevSyncCodes[2] & FlagSyncCodeID[1];	 						
			end		

            if(data_valid ==1'b1)begin
                if(data_in == SYNC_CODE_1st)       FlagSyncCode[0]   <= 1'b1;
				else                               FlagSyncCode[0]   <= 1'b0;
                if(data_in == SYNC_CODE_2nd)       FlagSyncCode[1]   <= 1'b1;
				else                               FlagSyncCode[1]   <= 1'b0;
                if(data_in == SYNC_CODE_3rd)       FlagSyncCode[2]   <= 1'b1;
				else                               FlagSyncCode[2]   <= 1'b0;
                if(data_in == SYNC_CODE_4th_SOL)   FlagSyncCodeID[0] <= 1'b1;
				else                               FlagSyncCodeID[0] <= 1'b0;
                if(data_in == SYNC_CODE_4th_SOO)   FlagSyncCodeID[1] <= 1'b1;
				else                               FlagSyncCodeID[1] <= 1'b0;				
			end		 
		end			
	end			
  
	  
	reg			Fsm_Valid_Gen;	
	reg	[11:0]	data_in_q;		
	reg	[11:0]	CntPixelPerLine;	
	always @(posedge clk_rxg ) begin
		if (rst_rx) begin  
			Fsm_Valid_Gen			<= 1'b0;		 		
			Sync_Valid				<= 1'b0;
			data_in_q				<= 12'd0;
			Sync_Data				<= 12'd0;
			CntPixelPerLine			<= 12'd0;
		end
		else begin 
		    data_in_q  				<= data_in; 
		    Sync_Data  				<= data_in_q;  
			case(Fsm_Valid_Gen)
				1'b0:	begin
							if(data_valid_q == 1'b1) begin
								if((FlagSyncCode_SOL == 1'b1)||(FlagSyncCode_SOO == 1'b1)) begin
									Sync_Valid			<= 1'b1;
									Fsm_Valid_Gen		<= 1'b1;
								end
								else begin
									Sync_Valid			<= 1'b0;
									Fsm_Valid_Gen		<= 1'b0;
								end
							end
							CntPixelPerLine		<= 12'd0;
						end
				1'b1:	begin
							if(data_valid_q == 1'b1) begin
								if(CntPixelPerLine	== LVAL_LENGTH - 1'b1) begin										
									Fsm_Valid_Gen			<= 1'b0;
									Sync_Valid				<= 1'b0;
									CntPixelPerLine			<= 12'd0;
								end
								else begin
									CntPixelPerLine			<= CntPixelPerLine + 1'b1;
									Sync_Valid				<= 1'b1;
								end		 					
							end
							else begin
								Sync_Valid				<= 1'b0;
							end	 
						end
			endcase
		end
	end			 
	
endmodule
