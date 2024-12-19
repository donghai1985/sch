/*
 * main.h
 *
 *  Created on: Aug 3, 2020
 *      Author: anton
 */

#ifndef SRC_MAIN_H_
#define SRC_MAIN_H_

// General definitions
#define DISCOVERY_SPEED_1 			0x28		// Camera discovery speed 0x28 for 1.25G
#define DISCOVERY_SPEED_2 			0x30		// Camera discovery speed 0x30 for 2.5G
#define DISCOVERY_SPEED_3 			0x38		// Camera discovery speed 0x38 for 3.125G
#define DISCOVERY_SPEED_4 			0x40		// Camera discovery speed 0x40 for 5G
#define DISCOVERY_SPEED_5 			0x48		// Camera discovery speed 0x40 for 6.2G

#define USE_USER_OPERATE_SPEED		0			// 0 - use camera default operation speed
												// 1 - use operation speed defined by OPERATE_SPEED

#define OPERATE_SPEED 				0x38		// 0x28 => 1.25G operation speed
												// 0x30 => 2.5G operation speed
												// 0x38 => 3.125G operation speed
												// 0x40 => 5.0G operation speed
												// 0x48 => 6.25G operation speed
												// 0x50 => 10.0G operation speed
												// 0x58 => 12.5G operation speed
#define STREAM_STAT_EN				1			// Stream statistics print enable
#define MAX_LINKS					4			//
#define LINK_UP_RETRIES 			10			//
#define CXP_MAGIC_NUMBER 			0xC0A79AE5	// CoaXPress magic number

#define STREAM_FIFO_THRESHOLD 		0x2000000
#define	STREAM_SIZE_MAX				8192		// maximum stream packet size that host can receive in decoder

// Host registers
#define HOST_REGS_LINK_CH_SELECT	0x00000000
#define HOST_REGS_LINK_SPEED		0x00000004
#define HOST_REGS_LINK_STATUS		0x00000008
#define HOST_REGS_LINK_TST_ERRORS	0x0000000C
#define HOST_REGS_LINK_TST_MODE		0x00000010
#define HOST_REGS_LINK_CTRL_RST		0x00000014
#define HOST_REGS_LINK_TIMEOUT		0x00000018
#define HOST_REGS_LINK_RESYNC		0x0000001C
#define HOST_REGS_LINKS		 		0x00000020
#define HOST_REGS_LINK_COMMAND	 	0x00000028
#define HOST_REGS_LINK_TST_RX_LSB	0x0000002C
#define HOST_REGS_LINK_TST_RX_MSB	0x00000030

#define HOST_REGS_CAM_SELECT	 	0x00000040
#define HOST_REGS_ARB_SELECT	 	0x0000003C
#define HOST_ARBITER_RESET 			0x00000050
#define HOST_IP_REVISION		 	0x000000C0
#define HOST_CXP_VERSION			0x000000C4 // CoaXPress version of the select link: 1.0 = 0x1 ; 1.1 = 0x2 ; 2.0 = 0x4
#define HOST_REGS_INDIRECT_ADDRESS	0x00000024
#define HOST_REGS_INDIRECT_DATA		0x00000400
#define HOST_REGS_LINK_COMMAND		0x00000028

// Device Registers
#define DEVICE_STANDARD_REG			0x00000000
#define DEVICE_XMLURL_REG			0x00000018
#define DEVICE_VENDORNAME_REG		0x00002000
#define DEVICE_MODELNAME_REG		0x00002020
#define DEVICE_MANINFO_REG			0x00002040
#define DEVICE_VERSION_REG			0x00002070
#define DEVICE_FIRMWAREVER_REG		0x00002090
#define DEVICE_ID_REG				0x000020B0
#define DEVICE_USERID_REG			0x000020C0
#define DEVICE_ACQ_START_ADDR_REG	0x0000300C
#define DEVICE_STREAMID1_ADDR_REG	0x0000301C
#define DEVICE_LINKRESET_REG		0x00004000
#define DEVICE_LINKID_REG			0x00004004
#define DEVICE_HOSTLINKID_REG		0x00004008
#define DEVICE_CONTROLSIZE_REG		0x0000400C
#define DEVICE_STREAMSIZE_REG		0x00004010
#define DEVICE_LINKCONFIG_REG		0x00004014
#define DEVICE_LINKCONFIG_DEF_REG	0x00004018
#define DEVICE_TestPacketCountTx	0x00004028
#define DEVICE_TestPacketCountRx	0x00004030

// Decoder Registers
#define STREAM_0_OFFSET				0x00002000
#define STREAM_CONFIG_REG			0x00000000
#define STREAM_CRC_COUNT			0x00000008
#define STREAM_RX_COUNT				0x0000000C
#define STREAM_DROP_COUNT			0x00000010
#define STREAM_RX_FRAMES_COUNT		0x00000014
#define STREAM_MAP_REG				0x00000018
#define STREAM_DROP_FRAMES_COUNT	0x00000020
#define STREAM_FIFO_THRESH			0x00000024
#define STREAM_DEC_SEL				0x00000034
#define STREAM_WRONGID_DROP_COUNT	0x00000044
#define STREAM_STREAM_ID_STATUS		0x00000048


typedef enum
{
	LINK_STATE_DISCONNECTED 	= 0,
	LINK_STATE_MASTER 			= 1,
	LINK_STATE_SLAVE 			= 2
} LINK_STATE;


#endif /* SRC_MAIN_H_ */
