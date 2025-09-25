`include "Board_define.vh"
`include "XRNIC_define.vh"
`ifndef XRNIC_REG_CONFIG_H
`define XRNIC_REG_CONFIG_H

localparam QP_NUM					=8'h4							;

localparam UDP_dst_port				=16'h12b7						;

localparam RESERVED					=1'h0							;

localparam TX_ACK_gen				=2'h0							;
localparam UDP_src_port				=16'h12b7						;

localparam ERROR_buffer_enable		=1'h0							;


localparam XON						=16'h96							;
localparam XOFF						=16'h5A							;

//0x2000C
localparam PFC_enable_RoCE			=1'h0							;
localparam PFC_enable_non_RoCE		=1'h0							;
localparam PFC_prio_RoCE			=4'h0							;
localparam PFC_prio_non_RoCE		=4'h8							;
localparam disable_prio_check		=1'h0							;

//0x20010 0x20014
localparam Local_MAC				=48'h10_7B_44_80_F4_6A+Board_DIP*10			;

//0x20018
localparam XON_non_RoCE				=16'h96							;
localparam XOFF_non_RoCE			=16'h5A							;

//0x20020 0x20024 0x20028 0x2002C
localparam IPv6_addr				=128'h0							;

//0x20060 0x20064
localparam error_buffer_base_addr	=64'h0040_0000					;

//0x20068
localparam error_buffer_num			=16'h1							;
localparam error_buffer_size		=16'h10							;

//0x2006C	RO

//0x20070
localparam local_IPv4				=32'hc0_a8_00_60+Board_DIP*10				;

//0x200A0 0x200A4
localparam retry_buffer_base_addr	=64'h0000_0000_0080_0000		;

//0x200A8
localparam retry_data_buffer_size	=16'h0100						;
localparam retry_data_buffer_num	=16'h0010						;

//0x20180
localparam in_pkt_valid_error_intr_en	=1'b0						;
localparam in_MAD_pkt_intr_en			=1'b0						;
localparam RNR_NACK_gen_intr_en			=1'b0						;
localparam WQE_cq_intr_en				=1'b0						;
localparam SQ_opcode_error_intr_en		=1'b0						;
localparam RQ_intr_en					=1'b0						;
localparam fatal_error_intr_en			=1'b1						;
localparam CNP_intr_en					=1'b0						;
localparam intr_enable_reg={CNP_intr_en,fatal_error_intr_en,RQ_intr_en,SQ_opcode_error_intr_en,WQE_cq_intr_en,RNR_NACK_gen_intr_en,1'b0,in_MAD_pkt_intr_en,in_pkt_valid_error_intr_en};


/**************************************************	QP1 reg	*********************************************************/
//0x20200+(i-1)*0x0100
localparam QP1_RQ_intr_enable			=1'h0							;
localparam QP1_CQ_intr_enable			=1'h0							;
localparam QP1_HW_handshake_disable		=1'h0							;
localparam QP1_CQE_write_enable			=1'h1							;
localparam QP1_QP_under_recovery		=1'h0							;
localparam QP1_QP_IPv4or6				=1'h0							;//IPv4->0 IPv6->1
localparam QP1_PMTU						=3'b001							;// 256->000		512->001	1024->010	2048->011	4096->100	other->reserved 
localparam QP1_RQ_buffer_size			=16'h1000						;

//0x20204+(i-1)*0x0100	not for QP1

//0x20208+(i-1)*0x0100	0x202C0+(i-1)*0x0100	
localparam QP1_Rcv_Q_buf_base_addr		=64'h0000_0000_0060_0000		;

//0x20210+(i-1)*0x0100	0x202C8+(i-1)*0x0100
localparam QP1_Send_Q_buf_base_addr		=64'h0000_0000_0000_0000		;

//0x20218+(i-1)*0x0100	0x202D0+(i-1)*0x0100
localparam QP1_CQ_base_addr				=64'h0000_0000_00b0_0000		;

//0x2023C+(i-1)*0x0100
localparam QP1_Send_Q_depth				=16'h0010						;
localparam QP1_Rcv_Q_depth				=16'h0010						;

////0x20240+(i-1)*0x0100	not for QP1

//0x20244+(i-1)*0x0100				need to be set after first communication	not for QP1

//0x20248+(i-1)*0x0100				need to be set after first communication
localparam QP1_Dest_QPID				=24'h1							;

//0x20250+(i-1)*0x0100				need to be set after first communication
//0x20254+(i-1)*0x0100
//localparam QP1_Dst_MAC				=48'h1111_1111_1111				;

//0x20260+(i-1)*0x0100				need to be set after first communication
//0x20264+(i-1)*0x0100				IPv6
//0x20268+(i-1)*0x0100
//0x2026C+(i-1)*0x0100
//localparam QP1_Dst_IPv4				=32'hc0_a8_00_10				;
//localparam QP1_Dest_IPv6				=128'h0							;

//0x2024C+(i-1)*0x0100	not for QP1
/*******************************************************************************************************************/



/**************************************************	QPn reg	*********************************************************/
//0x00000+(i-1)*0x0100
localparam QPn_PD_num					=24'haa_bbcc					;
localparam QPn_virtual_addr				=64'h0000_0000_abcd_0000		;
localparam QPn_base_addr				=64'h0000_0010_0000_0000		;
localparam QPn_R_KEY					=8'hab							;
localparam QPn_buffer_len				=48'h0000_1000					;


//0x20200+(i-1)*0x0100
localparam QPn_RQ_intr_enable			=1'h1							;
localparam QPn_CQ_intr_enable			=1'h1							;
localparam QPn_HW_handshake_disable		=1'h0							;
localparam QPn_CQE_write_enable			=1'h0							;
localparam QPn_QP_under_recovery		=1'h0							;
localparam QPn_QP_IPv4or6				=1'h0							;//IPv4->0 IPv6->1
localparam QPn_PMTU						=3'b100							;// 256->000		512->001	1024->010	2048->011	4096->100	other->reserved 
localparam QPn_RQ_buffer_size			=16'h1000						;

//0x20204+(i-1)*0x0100	not for QP1
//localparam QPn_Partition_Key			=16'h2233_4455					;		// find this part in rx_pkt_decode.sv
localparam QPn_Time_to_live				=8'd64							;
localparam QPn_Traffic_class			=6'h0							;//???

//0x20208+(i-1)*0x0100	0x202C0+(i-1)*0x0100	
localparam QPn_Rcv_Q_buf_base_addr		=64'h0000_0000_0020_0000		;

//0x20210+(i-1)*0x0100	0x202C8+(i-1)*0x0100
localparam QPn_Send_Q_buf_base_addr		=64'h40+(QP_NUM-8'd1)*8'h40	;

//0x20218+(i-1)*0x0100	0x202D0+(i-1)*0x0100
localparam QPn_CQ_base_addr				=64'h0000_0000_01b0_0000		;

//0x2023C+(i-1)*0x0100
localparam QPn_Send_Q_depth				=16'd256						;
//localparam QPn_Send_Q_depth				=16'd4						;
localparam QPn_Rcv_Q_depth				=16'h0100						;

//0x20240+(i-1)*0x0100
localparam QPn_Send_Q_PSN				=24'h1111						;

//0x20244+(i-1)*0x0100				need to be set after first communication
//localparam QPn_Rcv_Q_PSN				=24'h00_cdee					;
//localparam QPn_Rcv_Q_opcode				=8'h0							;

//0x20248+(i-1)*0x0100				need to be set after first communication
//localparam QPn_Dest_QPID				=24'h3							;

//0x20250+(i-1)*0x0100				need to be set after first communication
//0x20254+(i-1)*0x0100
//localparam QPn_Dest_MAC					=48'h3333_5678_9999				;

//0x20260+(i-1)*0x0100				need to be set after first communication
//0x20264+(i-1)*0x0100				IPv6
//0x20268+(i-1)*0x0100
//0x2026C+(i-1)*0x0100
//localparam QPn_Dest_IPv4				=32'hc0_a8_00_51				;
//localparam QPn_Dest_IPv6				=128'h0							;

//0x2024C+(i-1)*0x0100
//localparam QPn_Timeout_value			=5'h0b							;	//1000*QPn_Timeout_value clk
localparam QPn_Max_retry_cnt			=3'd4							;
localparam QPn_Max_RNR_retry_cnt		=3'd4							;
localparam QPn_RNR_NACK_timeout			=5'd10							;

/*******************************************************************************************************************/


localparam XRNIC_RB_basic_config_rd_en		=1'b1	;
localparam XRNIC_RB_QP_config_rd_en			=1'b1	;
localparam XRNIC_RB_globle_config_rd_en		=1'b1	;
localparam XRNIC_QP_status_reg_rd_en		=1'b1	;

localparam XRNIC_basic_reg_config_num		=10'd19	;
localparam QP1_reg_config_num				=10'd12+10'd8	;
localparam QPn_reg_config_part1_num			=10'd8	;
localparam QPn_reg_config_part2_num			=10'd18	;
localparam QPn_reg_config_num				=QPn_reg_config_part1_num+QPn_reg_config_part2_num;
localparam global_status_reg_num			=10'd19	;
localparam QP_status_reg_num				=10'd9	;
localparam QP_status_reg_addr_max			=QP_status_reg_num*20;
localparam XRNIC_base_reg_num				=XRNIC_basic_reg_config_num;//+QP1_reg_config_num;
localparam XRNIC_base_reg_addr_max			=XRNIC_base_reg_num*52;
localparam XRNIC_QPn_reg_num				=QPn_reg_config_part2_num;
localparam XRNIC_QP1_reg_addr_max			=QP1_reg_config_num*52;
localparam XRNIC_QPn_reg_p1_addr_max		=QPn_reg_config_part1_num*52;
localparam XRNIC_QPn_reg_p2_addr_max		=QPn_reg_config_part2_num*52;
localparam XRNIC_reg_rd_num					=XRNIC_basic_reg_config_num+QPn_reg_config_num+global_status_reg_num;
localparam XRNIC_reg_rd_addr_max			=XRNIC_reg_rd_num*20;

//localparam XRNIC_basic_reg_rd_num			=10'd18	& {10{XRNIC_RB_basic_config_rd_en}}							;
//localparam QP_reg_rd_num					=10'd11	& {10{XRNIC_RB_QP_config_rd_en}}							;
//localparam global_status_reg_rd_num			=10'd19	& {10{XRNIC_RB_globle_config_rd_en}}							;
//localparam QP_status_reg_rd_num				=10'd8 & {10{XRNIC_QP_status_reg_rd_en}}								;
//localparam XRNIC_reg_rd_num					=XRNIC_basic_reg_rd_num+ QP_reg_rd_num+ global_status_reg_rd_num+ QP_status_reg_rd_num;

//localparam CUR_QP_NUM=24'h000003;









//localparam [52*(XRNIC_basic_reg_config_num+QP1_reg_config_num)-1:0]XRNIC_base_init_reg=	{
//{XRNIC_basic_reg_config}},{QP1_reg_config}};


/*localparam [20*XRNIC_basic_reg_config_num-1 :0]XRNIC_basic_reg=	{
{20'h2_0000},
{20'h2_0004},
{20'h2_0008},
{20'h2_000C},
{20'h2_0010},
{20'h2_0014},
{20'h2_0018},
{20'h2_0020},
{20'h2_0024},
{20'h2_0028},
{20'h2_002C},
{20'h2_0060},
{20'h2_0064},
{20'h2_0068},
{20'h2_0070},
{20'h2_00A0},
{20'h2_00A4},
{20'h2_00A8}
};



localparam [20*QPn_reg_config_num-1 :0]	QP_reg=	{
{20'h20200},
{20'h20204},
{20'h20208},
{20'h202C0},
{20'h20210},
{20'h202C8},
{20'h20218},
{20'h202D0},
{20'h2023C},
{20'h20240},
{20'h20248},
{20'h2024C},
{20'h20260}
};*/

localparam [20*global_status_reg_num-1 :0] global_status_reg=	{
{20'h20100},			// incoming send/read resp pkt cnt
{20'h20104},			// incoming ack/mad pkt cnt
{20'h20108},			// outgoing send/read/write pkt
{20'h2010c},			// outgoing ack/mad pkt cnt
{20'h20110},			// last incoming pkt
{20'h20114},			// last outgoing pkt
{20'h20118},			// incoming invalid/duplicate pkt cnt
{20'h2011c},			// incoming NAK pkt
{20'h20120},			// outgoing RNR pkt status
{20'h20124},			// WQE proc status
{20'h2012c},			// QP manager status
{20'h20130},			// incoming all/dropped pkt cnt
{20'h20134},			// incoming NAK pkt cnt
{20'h20138},			// outgoing NAK pkt cnt
{20'h2013c},			// resp handler status
{20'h20140},			// retry cnt
{20'h20174},			// incoming CNP pkt cnt
{20'h20178},			// outgoing CNP pkt cnt
{20'h2017c}				// outgoing read resp pkt cnt
};

localparam [20*QP_status_reg_num-1 :0]	QP_status_reg=	{
{20'h20244},			// current outgoing SSN
{20'h20280},			// current outgoing SSN
{20'h20284},			// current expected incoming MSN
{20'h20288},			// QP status
{20'h2028c},			// current SQ pointer under process num
{20'h20290},			// expected resp PSN
{20'h20294},			// current Rcv Q buf addr LSB
{20'h202d8},			// current Rcv Q buf addr MSB
{20'h20298}				// cnt of WQE pushed by QP manager
};

`endif

