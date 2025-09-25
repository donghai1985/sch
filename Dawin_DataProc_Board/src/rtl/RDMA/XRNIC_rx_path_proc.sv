`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/27 16:16:23
// Design Name: 
// Module Name: XRNIC_rx_path_proc
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


module XRNIC_rx_path_proc#(
 parameter C_AXI_THREAD_ID_WIDTH =1,
 parameter C_AXI_ADDR_WIDTH = 32,
 parameter C_AXI_DATA_WIDTH = 512
) (
  // capsule I/F
  input 										core_clk,
  input 										core_rst,
  input  [C_AXI_THREAD_ID_WIDTH-1:0]     		capsule_ddr_m_axi_awid,                      
  input  [C_AXI_ADDR_WIDTH-1:0]          		capsule_ddr_m_axi_awaddr,                    
  input  [7:0]                           		capsule_ddr_m_axi_awlen,                     
  input  [2:0]                           		capsule_ddr_m_axi_awsize,                    
  input  [1:0]                           		capsule_ddr_m_axi_awburst,                   
  input  [3:0]                           		capsule_ddr_m_axi_awcache,                   
  input  [2:0]                           		capsule_ddr_m_axi_awprot,                    
  input                                  		capsule_ddr_m_axi_awvalid,                   
  output                                 		capsule_ddr_m_axi_awready,                   
  input  [511:0]                         		capsule_ddr_m_axi_wdata,                     
  input  [ 63:0]                         		capsule_ddr_m_axi_wstrb,                     
  input                                  		capsule_ddr_m_axi_wlast,                     
  input                                  		capsule_ddr_m_axi_wvalid,                    
  output                                 		capsule_ddr_m_axi_wready,                    
//  input                                  		capsule_ddr_m_axi_awlock,                    
  output   [C_AXI_THREAD_ID_WIDTH-1 :0]  		capsule_ddr_m_axi_bid,                       
  output   [1:0]                         		capsule_ddr_m_axi_bresp,                     
  output                                 		capsule_ddr_m_axi_bvalid,                    
  input                                  		capsule_ddr_m_axi_bready,                    

  //Data I/F
  /*input wire [C_AXI_THREAD_ID_WIDTH-1:0]     data_m_axi_awid,                      
  input wire [C_AXI_ADDR_WIDTH-1:0]          data_m_axi_awaddr,                    
  input wire [7:0]                           data_m_axi_awlen,                     
  input wire [2:0]                           data_m_axi_awsize,                    
  input wire [1:0]                           data_m_axi_awburst,                   
  input wire [3:0]                           data_m_axi_awcache,                   
  input wire [2:0]                           data_m_axi_awprot,                    
  input wire                                 data_m_axi_awvalid,                   
  output  wire                               data_m_axi_awready,                   
  input wire [511:0]                         data_m_axi_wdata,                     
  input wire [ 63:0]                         data_m_axi_wstrb,                     
  input wire                                 data_m_axi_wlast,                     
  input wire                                 data_m_axi_wvalid,                    
  output  wire                               data_m_axi_wready,                    
  input wire                                 data_m_axi_awlock,                    
  output  wire [C_AXI_THREAD_ID_WIDTH-1 :0]  data_m_axi_bid,                       
  output  wire [1:0]                         data_m_axi_bresp,                     
  output  wire                               data_m_axi_bvalid,                    
  input wire                                 data_m_axi_bready,     */               
// Door bell signals
  input                                  		rx_pkt_hndler_o_rq_db_data_valid,
  input  [31:0]                          		rx_pkt_hndler_o_rq_db_data,
  input  [9:0]                           		rx_pkt_hndler_o_rq_db_addr,
  output logic                                  rx_pkt_hndler_i_rq_db_rdy, 
  input                                  		resp_hndler_o_send_cq_db_cnt_valid,
// Payload Checks
//  output wire                                rqci_completions_written_out,
  output logic   [15:0]                        	qp_rq_cidb_hndshk,
  output logic   [31:0]                        	qp_rq_cidb_wr_addr_hndshk,
  output logic                                 	qp_rq_cidb_wr_valid_hndshk,
  input                                  		qp_rq_cidb_wr_rdy,
  
  output logic									rx_MR_tvalid=0,
  output logic	[3:0]							rx_MR_QPn=0,
  
  output logic	[63:0]							host_MR_addr0,
  output logic	[63:0]							host_MR_addr1,
  output logic	[63:0]							host_MR_len0,
  output logic	[63:0]							host_MR_len1,
  output logic	[31:0]							host_MR_rkey0,
  output logic	[31:0]							host_MR_rkey1

   );

`include "ETH_pkt_define.sv"

`ifdef DEBUG_ILA
ila_rx_path ila_rx_path (
	.clk		(core_clk							), // input wire clk
	.probe0		(rx_pkt_hndler_o_rq_db_data_valid	), // input wire [0:0]  probe0  
	.probe1		(rx_pkt_hndler_o_rq_db_data			), // input wire [31:0]  probe1 
	.probe2		(rx_pkt_hndler_o_rq_db_addr			), // input wire [9:0]  probe2 
	.probe3		(qp_rq_cidb_hndshk					), // input wire [15:0]  probe3 
	.probe4		(qp_rq_cidb_wr_addr_hndshk			), // input wire [31:0]  probe4 
	.probe5		(qp_rq_cidb_wr_valid_hndshk			), // input wire [0:0]  probe5 
	.probe6		(data_m_axi_wdata					), // input wire [511:0]  probe6 
	.probe7		(data_m_axi_wvalid					), // input wire [0:0]  probe7
	.probe8		(rx_pkt_hndler_i_rq_db_rdy			),
	.probe9		(qp_rq_cidb_wr_rdy					),
	.probe10	(resp_hndler_o_send_cq_db_cnt_valid	)
);
`endif

// SEND Packets Checks
localparam rx_capsule_chk_st0 = 3'b000;
localparam rx_capsule_chk_st1 = 3'b001;
localparam rx_capsule_chk_st2 = 3'b010;
localparam rx_capsule_chk_st3 = 3'b011;
localparam rx_capsule_chk_st4 = 3'b100;
localparam rx_capsule_chk_st5 = 3'b101;

reg [2:0] rx_capsule_chk_st;
reg [7:0] transfer_len;
// SEND Packet Payload is set to 80 Bytes while transmitting from Exdes, and
// each packet will have incremental data.
reg [1023:0] rdma_capsule_rcvd;
reg [3:0] rcvd_payload_cnt;
reg send_payload_chk_fail;
reg send_payload_chk_pass;
reg send_payload_chk_completed;
reg [3:0] rq_db_cnt;
reg [4:0] resp_handler_db_cnt;
reg [31:0]   rx_pkt_hndler_o_rq_db_data_i;
reg [9:0]    rx_pkt_hndler_o_rq_db_addr_i; 

logic [ETH_RC_SEND_payload_len*8-1:0]		pkt_rx;
logic [ETH_RC_SEND_payload_len*8-1:0]		pkt_rx_reorder;
logic [3:0]									pkt_rx_cnt;
logic [511:0]								capsule_ddr_m_axi_wdata_reorder;
rocev2_rc_send_connect_t 					pkt_rx_rc_send;

localparam rx_db_chk_st0 = 3'b000;
localparam rx_db_chk_st1 = 3'b001;
localparam rx_db_chk_st2 = 3'b010;                                    
localparam rx_db_chk_st3 = 3'b011;

reg [2:0] rx_db_chk_st;
reg rqci_completions_written;

assign capsule_ddr_m_axi_awready=1;
assign capsule_ddr_m_axi_wready=1;

always @(posedge core_clk) begin
  if (core_rst) begin
    rx_db_chk_st <= rx_db_chk_st0;
    rq_db_cnt <= 'b0;
    qp_rq_cidb_wr_addr_hndshk <= 'b0;
    qp_rq_cidb_hndshk <= 'b0;
    qp_rq_cidb_wr_valid_hndshk <= 1'b0;
    rx_pkt_hndler_o_rq_db_data_i <= 'b0;
    rx_pkt_hndler_o_rq_db_addr_i <= 'b0;
    rx_pkt_hndler_i_rq_db_rdy    <= 1'b0;
    rx_MR_tvalid<='b0;
//    rqci_completions_written     <= 1'b0;
  end
  else begin
	case(rx_db_chk_st)
rx_db_chk_st0: begin
        if(rx_pkt_hndler_o_rq_db_data_valid) begin // wait for door bell update
          rx_db_chk_st  <= rx_db_chk_st1;

          rx_pkt_hndler_o_rq_db_data_i <= rx_pkt_hndler_o_rq_db_data;
          rx_pkt_hndler_o_rq_db_addr_i <= rx_pkt_hndler_o_rq_db_addr; 
          rx_MR_QPn<=rx_pkt_hndler_o_rq_db_addr[3:0];
          rx_pkt_hndler_i_rq_db_rdy    <= 1'b1;
        end
//        rqci_completions_written     <= 1'b0;
      end

rx_db_chk_st1: begin // state to update RQCI DB
//       if(rx_pkt_hndler_o_rq_db_addr_i == 10'h004)
 		qp_rq_cidb_wr_addr_hndshk <= 32'h00020234+16'h0100*(rx_MR_QPn-1);
 		qp_rq_cidb_hndshk <= rx_pkt_hndler_o_rq_db_data_i;
 		qp_rq_cidb_wr_valid_hndshk <= 1'b1;
		rx_MR_tvalid<=1;
        rx_db_chk_st <= rx_db_chk_st2;
      end
rx_db_chk_st2: begin
		rx_MR_tvalid<=0;
        if(qp_rq_cidb_wr_rdy) begin
          rx_db_chk_st <= rx_db_chk_st3;
          qp_rq_cidb_wr_valid_hndshk <= 1'b0;
          rq_db_cnt <= rq_db_cnt + 1'b1;
        end
      end
rx_db_chk_st3: begin
        /*if(rq_db_cnt == 4'h8)
          rqci_completions_written <= 1'b1;
        else
          rqci_completions_written <= 1'b0;*/
        rx_db_chk_st <= rx_db_chk_st0;
      end
      default: begin
        rq_db_cnt <= 'b0;
        qp_rq_cidb_wr_addr_hndshk <= 'b0;
        qp_rq_cidb_hndshk <= 'b0;
        qp_rq_cidb_wr_valid_hndshk <= 1'b0;
        rx_pkt_hndler_o_rq_db_data_i <= 'b0;
        rx_pkt_hndler_o_rq_db_addr_i <= 'b0;
        rx_pkt_hndler_i_rq_db_rdy    <= 1'b0;
      end
    endcase
  end
end

// host MR send pkt QPN
//always_ff@(posedge core_clk)
//	if(capsule_ddr_m_axi_awvalid)		rx_MR_QPn<=capsule_ddr_m_axi_awaddr[20+:4];
	

assign capsule_ddr_m_axi_wdata_reorder=hdr_byte_reorder(capsule_ddr_m_axi_wdata);
always_ff@(posedge core_clk or posedge core_rst)
	if(core_rst)																	pkt_rx_cnt<=0;
	else if(capsule_ddr_m_axi_wvalid && capsule_ddr_m_axi_wlast)					pkt_rx_cnt<=0;
	else if(capsule_ddr_m_axi_wvalid)												pkt_rx_cnt<=pkt_rx_cnt+1;

always_ff@(posedge core_clk or posedge core_rst)
	if(core_rst)													pkt_rx<=0;
	else if(capsule_ddr_m_axi_wvalid && (pkt_rx_cnt==0))			pkt_rx[ETH_RC_SEND_payload_len*8-1-:512]<=capsule_ddr_m_axi_wdata_reorder;
	else if(capsule_ddr_m_axi_wvalid && (pkt_rx_cnt==1))			pkt_rx[ETH_RC_SEND_payload_len*8-512-1:0]<=capsule_ddr_m_axi_wdata_reorder[511-:(ETH_RC_SEND_payload_len*8-512)];

assign pkt_rx_reorder=host_tx_data_reorder(pkt_rx);
assign pkt_rx_rc_send=pkt_rx_reorder;
		
assign host_MR_addr0	=pkt_rx_rc_send.addr0	;
assign host_MR_addr1	=pkt_rx_rc_send.addr1	;
assign host_MR_len0		=pkt_rx_rc_send.len0	;
assign host_MR_len1		=pkt_rx_rc_send.len1	;
assign host_MR_rkey0	=pkt_rx_rc_send.rkey0	;
assign host_MR_rkey1	=pkt_rx_rc_send.rkey1	;	
//	assign host_MR_tvalid 	=(capsule_ddr_m_axi_wvalid && capsule_ddr_m_axi_wlast) ? 1						:0;

/*ila_rc_send_rx ila_rc_send_rx (
	.clk		(core_clk), // input wire clk
	.probe0		(host_MR_addr0), // input wire [63:0]  probe0  
	.probe1		(host_MR_addr1), // input wire [63:0]  probe1 
	.probe2		(host_MR_len0), // input wire [63:0]  probe2 
	.probe3		(host_MR_len1), // input wire [63:0]  probe3 
	.probe4		(host_MR_rkey0), // input wire [31:0]  probe4 
	.probe5		(host_MR_rkey1), // input wire [31:0]  probe5
	.probe6		(rx_MR_tvalid),
	.probe7		(rx_MR_QPn)
);*/

		
		
		
		

endmodule
