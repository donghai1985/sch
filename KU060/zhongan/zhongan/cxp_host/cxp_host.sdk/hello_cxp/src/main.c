/**
* @file	    main.c
* @brief    Hello-FPGA CoaXPress 2.0 Host IP reference design software
* @details  This reference design illustrates the usage and configurations of 
*           Hello-FPGA CoaXPress 2.0 Host IP needed to detect remote CoaXPress camera  
*           and initiate single data stream 
*
* @note     This reference software provides several basic configurations to manipulate 
*           remote camera connectivity and stream acquisition
*
* |-------------------------|-------------------------------|-------------------------------------------------
* |         Define          |         Description           |         Availbale values
* |---------------------------------------------------------|-------------------------------------------------
* | USE_USER_OPERATE_SPEED  | Select camera operation       | 0 - use camera default operation speed
* |                         | speed source                  | 1 - use operation speed defined by OPERATE_SPEED
* |-------------------------|-------------------------------|-------------------------------------------------
* | OPERATE_SPEED           | Select remote camera          | 0x28 - 1.25G operation speed
* |                         | operational speed in case     | 0x30 - 2.5G operation speed
* |                         | USE_USER_OPERATE_SPEED is     | 0x38 - 3.125G operation speed
* |                         | set to 1, otherwise read      | 0x40 - 5.0G operation speed
* |                         | the default connection        | 0x48 - 6.25G operation speed
* |                         | speed from the camera         | 0x50 - 10.0G operation speed
* |                         |                               | 0x58 - 12.5G operation speed
* |-------------------------|-------------------------------|-------------------------------------------------
* | DBG_EN                  | Stream decoder and            | 0 - do not print the stream decoder and connection statistics
* |                         | connection statistics         | 1 - print the stream decoder and connection statistics
* |-------------------------|-------------------------------|-------------------------------------------------
* | MAX_LINKS               | Limit number of operational   | 
* |                         | links                         |
* |-------------------------|-------------------------------|-------------------------------------------------
* *Additional available configurations can be found in main.h
*
******************************************************************************/

#include <stdio.h>
#include "xil_io.h"
#include "xparameters.h"
#include "xuartlite.h"
#include "xil_printf.h"
#include "microblaze_sleep.h"
#include "main.h"
#include "PLL_GTHE3_control.h"

// MACROs - HOST
#define WRITE_HOST_REG(Reg, Data) 	Xil_Out32(XPAR_CXP_BURSTING_AXI2AVA_0_BASEADDR + Reg, Data)
#define READ_HOST_REG(Reg)			Xil_In32(XPAR_CXP_BURSTING_AXI2AVA_0_BASEADDR + Reg)

// MACROs - DEVICE
#define WRITE_DEVICE_REG(Reg, Data) WriteRegisterIndirect(Reg, swap_uint32(Data))
#define READ_DEVICE_REG(Reg) 		swap_uint32(ReadRegisterIndirect(Reg))

// MACROs - HOST DECODERS
#define WRITE_STREAM_REG(Reg, Data)	Xil_Out32(XPAR_CXP_BURSTING_AXI2AVA_0_BASEADDR + STREAM_0_OFFSET + Reg, Data)
#define READ_STREAM_REG(Reg) 		Xil_In32(XPAR_CXP_BURSTING_AXI2AVA_0_BASEADDR + STREAM_0_OFFSET + Reg)

// Sleep function
void msleep(int val);

// Convert Little to Big endian
uint32_t swap_uint32(uint32_t val);

// Read string from device
void ReadDeviceString(uint32_t Reg, char *String, uint32_t Size);

// Return 1 if link is UP
int IsLinkUP(int link);

// Checks and brings link Up
LINK_STATE LinkCheckUP(int link);

// Resets Link
void LinkReset(int link);

// Sets Link Speed
LINK_STATE LinkSetSpeed(int link ,uint32_t speed);

uint32_t DeviceSetDefaultSpeed(int master_link, uint32_t links);

// Prints the camera parameters
void DisplayCameraParams(int link);

// Initialize the camera and start acquisition
void CameraInit(int link);

void WriteRegisterIndirect(uint32_t bootstrapRegister, uint32_t data);
uint32_t ReadRegisterIndirect(uint32_t bootstrapRegister);
void ReadRegisterIndirectBurst(uint32_t bootstrapRegister, uint32_t bootstrapSize, void* pData);

XUartLite UartLite;		/* Instance of the UartLite Device */
LINK_STATE LinkState[MAX_LINKS] = {0};

int main()
{
	const uint32_t discoverySpeed[] = { DISCOVERY_SPEED_3,DISCOVERY_SPEED_2};

	int i;
	uint32_t read_value = 0;
	int bLostLink;
	int hostLinks;
	LINK_STATE linkState = LINK_STATE_DISCONNECTED;

	int cameraMasterLink = 0, cameraActiveLinks = 0;
	//uint32_t cameraDefaultSpeed = OPERATE_SPEED;


	XUartLite_Initialize(&UartLite, XPAR_UARTLITE_0_DEVICE_ID);
	xil_printf("Uartlite init %s %s\n\r", __DATE__ ,__TIME__);

	pll_config_init();

	for(int iStartupWait = 0; iStartupWait < 5; iStartupWait++)
	{
		msleep(1000);
		xil_printf("Startup wait for %d sec\r", iStartupWait);
	}

	hostLinks = READ_HOST_REG(HOST_REGS_LINKS); // Read number of links from IP
	xil_printf("Hello-FPGA CoaXPress Demo, Found %d links\n\r", hostLinks);

	read_value = READ_HOST_REG(HOST_IP_REVISION);
	xil_printf("CXP HOST IP revision is %ld.%ld\n\r",read_value>>16,read_value & 0xFFFF);

	WRITE_HOST_REG(HOST_REGS_LINK_TIMEOUT,125000000);
	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,0);

	read_value = READ_HOST_REG(HOST_CXP_VERSION);
	xil_printf("HOST_CXP_VERSION is %d\n\r",read_value);
	//debug test	
	//WRITE_HOST_REG(HOST_CXP_VERSION,1);
	while(1)
	{
		cameraActiveLinks = 0;

			////////////////////////
		//// Find connected camera on discovery speed
		while (cameraActiveLinks == 0)
		{
			//reset camera first
			for (i = 0; i < hostLinks; i++) // Reset all the links
			{
				LinkReset(i);

				/* CoaXPress Test Packet generation
				WRITE_HOST_REG(HOST_REGS_LINK_TST_MODE, 1);
				//*/
			}

			for (int i = 0; i < hostLinks; i++) // Reset all the links
										 // for (i = 0; i < Links; i++) // Reset all the links
			{
				for (int j = 0; j<2; j++)
				{
					if (LINK_STATE_DISCONNECTED == LinkState[i])
					{
						LinkState[i] = LinkSetSpeed(i, discoverySpeed[j]);
						if (LinkState[i])
						{
							cameraActiveLinks++;
						}

						if (LINK_STATE_MASTER == LinkState[i])
						{
							cameraMasterLink = i;
							//debug read device registers					
							//#define DEVICE_LINKID_REG			0x00004004
							read_value = READ_DEVICE_REG(DEVICE_LINKID_REG);
							xil_printf("DEVICE_LINKID_REG is %ld \r", read_value);		
							//#define DEVICE_HOSTLINKID_REG		0x00004008
							read_value = READ_DEVICE_REG(DEVICE_HOSTLINKID_REG);
							xil_printf("DEVICE_HOSTLINKID_REG is %ld \r", read_value);		
							//#define DEVICE_CONTROLSIZE_REG		0x0000400C
							read_value = READ_DEVICE_REG(DEVICE_CONTROLSIZE_REG);
							xil_printf("DEVICE_CONTROLSIZE_REG is %ld \r", read_value);
							//#define DEVICE_STREAMSIZE_REG		0x00004010
							read_value = READ_DEVICE_REG(DEVICE_STREAMSIZE_REG);
							xil_printf("DEVICE_STREAMSIZE_REG is %ld \r", read_value);
							//#define DEVICE_LINKCONFIG_REG		0x00004014
							read_value = READ_DEVICE_REG(DEVICE_LINKCONFIG_REG);
							xil_printf("DEVICE_LINKCONFIG_REG is %ld \r", read_value);

							//config the default configuration, but do not change the linkspeed
							//#define DEVICE_LINKCONFIG_DEF_REG	0x00004018
							int linkDefault = READ_DEVICE_REG(DEVICE_LINKCONFIG_DEF_REG);
							xil_printf("DEVICE_LINKCONFIG_DEF_REG is %ld \r", linkDefault);
							linkDefault = (hostLinks<<16) | discoverySpeed[j];
							WRITE_DEVICE_REG(DEVICE_LINKCONFIG_REG, linkDefault);
							read_value = READ_DEVICE_REG(DEVICE_LINKCONFIG_REG);
							xil_printf("DEVICE_LINKCONFIG_REG is %ld \r", read_value);
						}
						if (LinkState[i] != LINK_STATE_DISCONNECTED)
						{
							break;//break from the discovery function
						}
					}
				}
			}
		}

		xil_printf("Detected %d Links\n\r", cameraActiveLinks);

			////////////////////////
		//// Set camera to operational speed and try to re-synchronize channels

		//OPERATE_SPEED you can change it directly
		WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,0);
		WRITE_DEVICE_REG(DEVICE_LINKCONFIG_REG, (hostLinks<<16) | OPERATE_SPEED);

		uint8_t bLinksSynchronized = 0;
		do{
			bLinksSynchronized = 1;
			for (i = 0; i < hostLinks; i++) // Change found links to the required speed and check that all links are synchronized
			{
				if (LINK_STATE_DISCONNECTED != LinkState[i])
				{
					linkState = LinkSetSpeed(i, OPERATE_SPEED);
					if(LINK_STATE_DISCONNECTED == linkState)
					{
						bLinksSynchronized = 0;	// at least 1 of the links is not synchronized on operational speed
					}
				}
			}

		}while(!bLinksSynchronized);

		xil_printf("All camera camera links synchronized on default speed 0x%x\n\r", OPERATE_SPEED);

		if (LINK_STATE_DISCONNECTED != LinkState[cameraMasterLink]) // Initialize the camera on MAster link
		{
			DisplayCameraParams(cameraMasterLink);
			CameraInit(cameraMasterLink);
		}

		bLostLink = (LINK_STATE_DISCONNECTED == LinkState[cameraMasterLink]);

		// Normal Process - Poll to check if some link is down
		while (!bLostLink)
		{
			msleep(1000);
			if (STREAM_STAT_EN > 0)
			{
				read_value = READ_STREAM_REG(STREAM_RX_COUNT);
				xil_printf("STREAM_RX_COUNT = %d\n\r",read_value);
				read_value = READ_STREAM_REG(STREAM_DROP_COUNT);
				xil_printf("STREAM_DROP_COUNT = %d\n\r",read_value);
				read_value = READ_STREAM_REG(STREAM_RX_FRAMES_COUNT);
				xil_printf("STREAM_RX_FRAMES_COUNT = %d\n\r",read_value);
				read_value = READ_STREAM_REG(STREAM_WRONGID_DROP_COUNT);
				xil_printf("STREAM_WRONGID_DROP_COUNT = %d\n\r",read_value);
				read_value = READ_STREAM_REG(STREAM_DROP_FRAMES_COUNT);
				xil_printf("STREAM_DROP_FRAMES_COUNT = %d\n\r",read_value);
				read_value = READ_STREAM_REG(STREAM_STREAM_ID_STATUS);
				xil_printf("STREAM_STREAM_ID_STATUS = %d\n\r",read_value);
				read_value = READ_STREAM_REG(STREAM_CRC_COUNT);
				xil_printf("STREAM_CRC_COUNT = %d\n\r",read_value);
			}

			for (i = 0; i < hostLinks; i++)
			{
				if (LinkState[i] && !IsLinkUP(i)) // check that connected link haven't lost synchronization on current speed
				{
					xil_printf("Link %d lost synchronization\n\r", i);
					bLostLink = 1;
				}
			}

			/* CoaXPress Test Packet rx
			for (i = 0; i < hostLinks; i++)
			{
				WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT, i);
				xil_printf("CH%d:HOST_REGS_LINK_TST_RX = 0x%08x%08x\n\r", i, READ_HOST_REG(HOST_REGS_LINK_TST_RX_MSB), READ_HOST_REG(HOST_REGS_LINK_TST_RX_LSB));
				xil_printf("CH%d:HOST_REGS_LINK_TST_ERRORS = 0x%x\n\r", i, READ_HOST_REG(HOST_REGS_LINK_TST_ERRORS));
			}//*/

			xil_printf("=======================================\n\r");
		}
	}

	return 0;
}
//------------------------------------------------------

void msleep(int val)
{
	int i;
	for(i = 0; i < val; i++)
	{
		usleep(1000);
	}
}

uint32_t swap_uint32(uint32_t val)
{
	val = ((val << 8) & 0xFF00FF00) | ((val >> 8) & 0xFF00FF);
    return (val << 16) | (val >> 16);
}

void ReadDeviceString(uint32_t Reg, char *String, uint32_t Size)
{
	ReadRegisterIndirectBurst(Reg, Size, String);
}

int IsLinkUP(int link)
{
	unsigned long read_value;

	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,link);
	read_value = READ_HOST_REG(HOST_REGS_LINK_STATUS);

	if (read_value & 3)
	{
		return 1;
	}
	return 0;
}

LINK_STATE LinkCheckUP(int link)
{
	int i;
	unsigned long read_value = 0;
	msleep(400);

	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,link);

	for (i = 0; i < LINK_UP_RETRIES; i++)
	{
		read_value = READ_HOST_REG(HOST_REGS_LINK_STATUS); // Read Status
		xil_printf("Link %d check sync status= 0x%x\n\r", link, read_value);
		if((read_value & 3) == 3) // Link sync
		{
			break;
		}
		WRITE_HOST_REG(HOST_REGS_LINK_RESYNC,1); // Re-sync
		msleep(800);
	}

	if (i == LINK_UP_RETRIES)
	{
		xil_printf("No Camera detected on link %d\n\r",link);
		return LINK_STATE_DISCONNECTED;
	}

	xil_printf("Link %d Synchronized\n\r",link);

	read_value = READ_DEVICE_REG(DEVICE_STANDARD_REG);
	xil_printf("Magic read 1 0x%x\n\r",read_value);

	read_value = READ_DEVICE_REG(DEVICE_STANDARD_REG);
	xil_printf("Magic read 2 0x%x\n\r",read_value);

	read_value = READ_DEVICE_REG(DEVICE_STANDARD_REG);
	xil_printf("Magic read 3 0x%x\n\r",read_value);

	if (read_value != CXP_MAGIC_NUMBER)
	{
		xil_printf("CXP Magic number does not match on link  %d\n\r",link);
		return LINK_STATE_DISCONNECTED;
	}

	read_value = READ_DEVICE_REG(DEVICE_LINKID_REG);	
	if (read_value > 0)
	{
		xil_printf("Slave Link %ld detected on link %d\n\r",read_value,link);
		return LINK_STATE_SLAVE;
	}
	else
	{
		xil_printf("Master Link detected on link %d\n\r",link);
		return LINK_STATE_MASTER;
	}
}

void LinkReset(int link)
{
	xil_printf("Reset link %d\n\r",link);
	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,link);
	WRITE_DEVICE_REG(DEVICE_LINKRESET_REG,1);// Reset Link on device
}

LINK_STATE LinkSetSpeed(int link ,uint32_t speed)
{
	LINK_STATE link_state = LINK_STATE_DISCONNECTED;
	xil_printf("*************************************\n\r");
	xil_printf("Set link %d to speed %lX\n\r",link,speed);
	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,link);

	// change all components for speed change
	pll_config_speed(link, speed);
	WRITE_HOST_REG(HOST_REGS_LINK_SPEED,speed);
	link_state = LinkCheckUP(link);
	xil_printf("* * * * * * * * * * * * * * * * * * *\n\r");
	return link_state;
}

uint32_t DeviceSetDefaultSpeed(int master_link, uint32_t links)
{
	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,master_link);

	uint32_t default_speed = 0;

#if (1 == USE_USER_OPERATE_SPEED)
	default_speed = OPERATE_SPEED;
#else
	do{
		default_speed =  READ_DEVICE_REG(DEVICE_LINKCONFIG_DEF_REG); 		// read default camera speed
		default_speed &= 0xFFFF; 											// extract only speed component
		xil_printf("Read default camera speed 0x%x from link %d\n\r", default_speed, master_link);
	}while(0xFFFF == default_speed); // while error in read of default speed
#endif

	WRITE_DEVICE_REG(DEVICE_LINKCONFIG_REG, (links << 16) | default_speed);	// set default camera speed and number of links

	return default_speed;
}

void DisplayCameraParams(int link)
{
	char TempString[100];
	int i;
	unsigned long read_value = 0;

	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT, link);
	msleep(1);
	xil_printf("Camera parameters for Link %d\n\r", link);

	for(i = 0; i < 8; i++)
	{
		read_value = READ_DEVICE_REG(i*4);
		msleep(1);
		xil_printf("Device Addr %X : %lX\n\r",i*4,read_value);
	}

	for(i = 0; i < 10; i++)
	{
		read_value = READ_DEVICE_REG(0x4000+i*4);
		msleep(1);
		xil_printf("Device Addr %X : %lX\n\r",0x4000+i*4,read_value);
	}

	ReadDeviceString(DEVICE_VENDORNAME_REG,TempString,32);
	msleep(1);
	xil_printf("Device Vendor Name :  %s\n\r",TempString);
	ReadDeviceString(DEVICE_MODELNAME_REG,TempString,32);
	msleep(1);
	xil_printf("Device Model Name :  %s\n\r",TempString);
	ReadDeviceString(DEVICE_MANINFO_REG,TempString,48);
	msleep(1);
	xil_printf("Device Manufacture info :  %s\n\r",TempString);
	ReadDeviceString(DEVICE_VERSION_REG,TempString,32);
	msleep(1);
	xil_printf("Device Version :  %s\n\r",TempString);
	ReadDeviceString(DEVICE_FIRMWAREVER_REG,TempString,32);
	msleep(1);
	xil_printf("Device Firmware Version :  %s\n\r",TempString);
	ReadDeviceString(DEVICE_ID_REG,TempString,16);
	msleep(1);
	xil_printf("Device ID :  %s\n\r",TempString);
	ReadDeviceString(DEVICE_USERID_REG,TempString,16);
	msleep(1);
	xil_printf("Device User ID :  %s\n\r",TempString);
	read_value = READ_DEVICE_REG(DEVICE_XMLURL_REG);
	ReadDeviceString(read_value,TempString,48);
	msleep(1);
	xil_printf("Device XML URL at %lX : %s\n\r",read_value,TempString);
}

void CameraInit(int link)
{
	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,link);				// select master link
	WRITE_DEVICE_REG(DEVICE_HOSTLINKID_REG,0xDF);				// Master Link ID
	WRITE_DEVICE_REG(DEVICE_STREAMSIZE_REG,STREAM_SIZE_MAX);	// Stream Data Size
	WRITE_STREAM_REG(STREAM_CONFIG_REG,0x2); 					// Reset

	uint32_t streamIdRegAddr = READ_DEVICE_REG(DEVICE_STREAMID1_ADDR_REG); // read Image1StreamID address
	uint32_t streamId = READ_DEVICE_REG(streamIdRegAddr); 		// read Image1StreamID value
	uint32_t streamLinkMask = 0;

	// fill the available link mask
	for(int i = 0; i < MAX_LINKS; i++)
	{
		if(LINK_STATE_DISCONNECTED != LinkState[i])
		{
			streamLinkMask |= (1 << i);
		}
	}

	uint32_t streamMap = (streamId << 8) | streamLinkMask;
	xil_printf("streamIdRegAddr=0x%x, streamId=%d, streamLinkMask=0x%x, streamMap=0x%x\n\r",
			streamIdRegAddr, streamId, streamLinkMask, streamMap);

	WRITE_STREAM_REG(STREAM_MAP_REG,streamMap); 				// MAP
	WRITE_STREAM_REG(STREAM_DEC_SEL,0x0);						// connect decoder 0 to arbiter (buffer) 0
	WRITE_STREAM_REG(STREAM_FIFO_THRESH,STREAM_FIFO_THRESHOLD);					// set fifo threshold to 32MB
	WRITE_HOST_REG(HOST_REGS_CAM_SELECT,0x0);					// select arbiter 0
	WRITE_HOST_REG(HOST_REGS_ARB_SELECT,0xF);					// connect arbiter 0 to link 0
	WRITE_STREAM_REG(STREAM_CONFIG_REG,0x1); 					// Enable

	uint32_t acquisitionStartRegAddr = READ_DEVICE_REG(DEVICE_ACQ_START_ADDR_REG);
	xil_printf("acquisitionStartRegAddr=0x%x\n\r", acquisitionStartRegAddr);
	WRITE_DEVICE_REG(acquisitionStartRegAddr,0x1);				// Start acquisition
}


void WriteRegisterIndirect(uint32_t bootstrapRegister, uint32_t data)
{
	int readData = 0;

	// 1- Write the link number that you are going to access into LINK_CH_SELECT register.
//	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,link);

	// 2- Write the bootstrap register address to INDIRECT_ADDRESS host register.
	WRITE_HOST_REG(HOST_REGS_INDIRECT_ADDRESS,bootstrapRegister);

	// 3- Write the data into the INDIRECT_DATA host register space.
	WRITE_HOST_REG(HOST_REGS_INDIRECT_DATA, data);

	// 4- Write the burst count value into INDIRECT_COMMAND register together with WRITE bit set.
	uint32_t reg_size = sizeof(uint32_t);
	uint32_t command_reg = (reg_size / sizeof(uint32_t)) << 16; // define amount of 32bit values to read (max 256)
	command_reg |= 0xF << 8; // byte enable mask for write
	command_reg |= 0x1; // enable write command
	WRITE_HOST_REG(HOST_REGS_LINK_COMMAND, command_reg);

	// 5 - Read the INDIRECT_COMMAND register till the transfer is in progress bit is 1 (??)
	while(READ_HOST_REG(HOST_REGS_LINK_COMMAND) & 0x04);

	// 6 - Read the LINK_STATUS register to get the completion status.
	readData = READ_HOST_REG(HOST_REGS_LINK_STATUS);
	readData = (readData >> 8) & 0xFF; // result = CoaXPress error code
}

void ReadRegisterIndirectBurst(uint32_t bootstrapRegister, uint32_t bootstrapSize, void* pData)
{
	unsigned int readData = 0;

	// 1- Write the link number that you are going to access into LINK_CH_SELECT register.
	//	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,link);

	// 2- Write the bootstrap register address to INDIRECT_ADDRESS host register.
	WRITE_HOST_REG(HOST_REGS_INDIRECT_ADDRESS,bootstrapRegister);

	// 3- Write the burst count value into INDIRECT_COMMAND register together with READ bit set.
	uint32_t reg_size = bootstrapSize / sizeof(uint32_t); // register size in dwords
	uint32_t command_reg = reg_size << 16; // define amount of 32bit values to read (max 256)
	command_reg |= 0xF << 8; // byte enable mask for read
	command_reg |= 0x2; // enable read command
	WRITE_HOST_REG(HOST_REGS_LINK_COMMAND, command_reg);

	readData = READ_HOST_REG(HOST_REGS_LINK_COMMAND);

	// xil_printf("Read reg=0x%x, command_wr=0x%x, command_rd=0x%x\n\r", bootstrapRegister, command_reg, readData);


	// 4 - Read the INDIRECT_COMMAND register while the transfer is in progress bit is 1
	while(READ_HOST_REG(HOST_REGS_LINK_COMMAND) & 0x04);

	// 5 - Read the LINK_STATUS register to get the completion status.
	readData = READ_HOST_REG(HOST_REGS_LINK_STATUS);
	readData = (readData >> 8) & 0xFF; // result = CoaXPress error code

	if(readData == 0) // read was successful
	{


	// 6 - Read the data from the INDIRECT_DATA host register space

		uint32_t* pData32 = (uint32_t*)pData;
		for(uint32_t i = 0; i < reg_size; i++)
		{
			uint32_t dataRamAddress = HOST_REGS_INDIRECT_DATA + i*sizeof(uint32_t);
			*pData32 = READ_HOST_REG(dataRamAddress);
			pData32++;
		}
	}
	else
	{
		xil_printf("Read ERROR: reg=0x%x, size=%d, status=0x%x\n\r", bootstrapRegister, bootstrapSize, readData);
	}
}

uint32_t ReadRegisterIndirect(uint32_t bootstrapRegister)
{
	unsigned int readData = 0;

	// 1- Write the link number that you are going to access into LINK_CH_SELECT register.
//	WRITE_HOST_REG(HOST_REGS_LINK_CH_SELECT,link);

	// 2- Write the bootstrap register address to INDIRECT_ADDRESS host register.
	WRITE_HOST_REG(HOST_REGS_INDIRECT_ADDRESS,bootstrapRegister);

	// 3- Write the burst count value into INDIRECT_COMMAND register together with READ bit set.
	uint32_t reg_size = sizeof(uint32_t);
	uint32_t command_reg = (reg_size / sizeof(uint32_t)) << 16; // define amount of 32bit values to read (max 256)
	command_reg |= 0xF << 8; // byte enable mask for read
	command_reg |= 0x2; // enable read command
	WRITE_HOST_REG(HOST_REGS_LINK_COMMAND, command_reg);

	readData = READ_HOST_REG(HOST_REGS_LINK_COMMAND);

	// xil_printf("Read reg=0x%x, command_wr=0x%x, command_rd=0x%x\n\r", bootstrapRegister, command_reg, readData);

	// 4 - Read the INDIRECT_COMMAND register while the transfer is in progress bit is 1
	while(READ_HOST_REG(HOST_REGS_LINK_COMMAND) & 0x04);

	// 5 - Read the LINK_STATUS register to get the completion status.
	readData = READ_HOST_REG(HOST_REGS_LINK_STATUS);
	readData = (readData >> 8) & 0xFF; // result = CoaXPress error code

	// xil_printf("Read reg=0x%x, status=0x%x\n\r", bootstrapRegister,readData );

	// 6 - Read the data from the INDIRECT_DATA host register space
	if(readData == 0) // read was successful
	{
		return READ_HOST_REG(HOST_REGS_INDIRECT_DATA);
	}
	else
	{
		xil_printf("Read ERROR: reg=0x%x, status=0x%x\n\r", bootstrapRegister, readData);
		return (unsigned int)-1; // error on read
	}
}

