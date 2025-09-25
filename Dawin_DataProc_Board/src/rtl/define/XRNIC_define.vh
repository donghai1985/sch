`include "Board_define.vh"
//`define WQE_WRID				15:0
//`define WQE_Reserved_0         31:16
//`define WQE_LADDR              95:32
//`define WQE_LENGTH             127:96
//`define WQE_OPCODE          	135:128
//`define WQE_Reserved_1			159:136
//`define WQE_ROFFSET			223:160
//`define WQE_RTAG				255:224
//`define WQE_SDATA				383:256
//`define WQE_IMMDT_DATA			415:384
//`define WQE_Reserved_2			511:416


`define XRINC_OPCODE_RDMA_WRITE							8'h00
`define XRINC_OPCODE_RDMA_WRITE_WITH_IMMDT					8'h01
`define XRINC_OPCODE_RDMA_SEND								8'h02
`define XRINC_OPCODE_RDMA_SEND_WITH_IMMDT					8'h03
`define XRINC_OPCODE_RDMA_READ								8'h04
`define XRINC_OPCODE_SEND_WITH_INVALIDATE					8'h0C

`define RoCE_OPCODE_ACK									8'h11
`define RoCE_OPCODE_SEND_ONLY								8'h04
`define RoCE_OPCODE_WRITE_LAST								8'h08
`define RoCE_OPCODE_WRITE_ONLY								8'h0a
`define RoCE_OPCODE_UD_SEND_ONLY							8'h64
`define RoCE_OPCODE_CNP									8'h81
`define RoCE_OPCODE_RC										3'h0

`define RoCE_ConnectRequest								16'h0010
`define RoCE_ConnectReply									16'h0013
`define RoCE_ReadyToUse									16'h0014

`define RoCE_OPCODE_POS									8*43-1:8*42

`define XRNIC_0_DDR_DATA_START_ADDR     24'h0
`define XRNIC_1_DDR_DATA_START_ADDR     24'h1_0000

`define ETH_TYPE_ARP										16'h0806
`define ETH_TYPE_IPv4										16'h0800

`define op_write				0
`define op_read				1

`define RDMA_WRITE_WQE_SIZE								'd5120	//5*512/8 *16
`define CM_REPLY_PKT_LEN									'd318
`define CM_REPLY_PKT_CNT									'd5
`define RDMA_WRITE_MSG_WQE_SIZE							'd152
`define RDMA_WRITE_MSG_CNT									'd3


`define CM_REPLY_DDR_ADDR									33'h0000_0000
`define WRITE_START_DDR_ADDR								`CM_REPLY_DDR_ADDR+`CM_REPLY_PKT_LEN
`define WRITE_END_DDR_ADDR									`WRITE_START_DDR_ADDR+`RDMA_WRITE_MSG_WQE_SIZE

`define TDI_DDR_START_ADDR									33'h0_0000_0800
`define SIM_TDI_DDR_END_ADDR								33'h0_0004_0000
`define TDI_DDR_END_ADDR									33'h1_F000_0000
`define INFO_DDR_START_ADDR								33'h1_F000_0010
`define INFO_DDR_END_ADDR									33'h1_FFFF_0000


`define CHANNEL_0_LEN    									128		//	128*32=2304
`define CHANNEL_1_LEN     									126 
`define CHANNEL_1_START_NUM								4096
`define WR_BURST_LINE										8
`define COMPRESSED_WR_BURST_LINE							5
`define COMPRESSED_WR_BURST_TOTAL_LEN						(`CHANNEL_0_LEN+`CHANNEL_1_LEN)*`COMPRESSED_WR_BURST_LINE
`define COMPRESSED_WR_BURST_WR_CNT							`COMPRESSED_WR_BURST_TOTAL_LEN%256==0 ? `COMPRESSED_WR_BURST_TOTAL_LEN/256 : `COMPRESSED_WR_BURST_TOTAL_LEN/256+1

`define SIM_PART_LINE										16
`define SIM_TRACK_VALID_LINE								16
`define SIM_TRACK_LINE_CNT									20
`define SIM_TRACK_PER_IMC									2

`define INFO_LEN    										8		//	8*512=4096
`define INFO_BURST_LEN    									128
`define INFO_BURST_TRIGGER_CNT								`INFO_BURST_LEN/`INFO_LEN

`define INFO_PART											0

`define SIM_IMC_NUM										8'h2

//`define COMPRESSED_WR_BURST_PER_LINE						(`CHANNEL_0_LEN+`CHANNEL_1_LEN)*32*`COMPRESSED_WR_BURST_LINE/256+1