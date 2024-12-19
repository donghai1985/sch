
#include "xil_types.h"
#include "xil_io.h"
#include "xparameters.h"
#include "microblaze_sleep.h"
#include "PLL_GTHE3_control.h"
#include "xgpio.h"

/* Definitions for peripheral EXT_PHY_FOR_CXP_0 */
#define EXT_PHY_CHANNEL_FOR_CXP_0_BASEADDR 0x44A00000
#define EXT_PHY_CHANNEL_FOR_CXP_0_HIGHADDR 0x44A0FFFF

#define EXT_PHY_COMMON_FOR_CXP_0_BASEADDR 0x44A10000
#define EXT_PHY_COMMON_FOR_CXP_0_HIGHADDR 0x44A1FFFF

XGpio Gpio; 			/* The Instance of the GPIO Driver */

void write_drp_common_reg(u16 drp_addr, u16 value)
{
	Xil_Out16(EXT_PHY_COMMON_FOR_CXP_0_BASEADDR + (u32)drp_addr*4 + 0x1000, value);
}

void write_drp_channel_reg(u16 drp_addr, u16 value)
{
	Xil_Out16(EXT_PHY_CHANNEL_FOR_CXP_0_BASEADDR + (u32)drp_addr*4 + 0x1000, value);
}

void set_speed_1_25G(void)
{

	/* GTHE3_COMMON */
    write_drp_common_reg(GTHE3_COMMON_QPLL0, 78);      	// [7..0] QPLL0_FBDIV =78(80)
                                                        // [15..8] QPLL0_INIT_CFG1 = 0


    // GTHE3_CHANNEL
    write_drp_channel_reg(GTHE3_CHANNEL_RXCDR_CFG2, 0b0000011100110110);
    
    write_drp_channel_reg(GTHE3_CHANNEL_63, 0x80C3); // [2..0] RXOUT_DIV. = 3(8)
                                        // [13..5] RXOOB_CFG = 0b000000110
                                        // [14] OOB_PWRUP = 0
                                        // [15] CBCC_DATA_SOURCE_SEL. = 1(DECODED)
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9D, 0x5568);  // [4..3] RXPI_CFG0 = 1
                                        // [7..5] RXPI_CFG6 = 3
                                        // [8] RXPI_CFG5 = 1
                                        // [9] RXPI_CFG4 = 0
                                        // [11..10] RXPI_CFG3 = 1
                                        // [13..12] RXPI_CFG2 = 1
                                        // [15..14] RXPI_CFG1 = 1
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_7C, 0x360);  // [2] TXFIFO_ADDR_CFG. = 0(LOW)
                                        // [5..3] TX_RXDETECT_REF = 0b100
                                        // [6] TXBUF_RESET_ON_RATE_CHANGE. = 1(TRUE)
                                        // [7] TXBUF_EN. = 0(FALSE)
                                        // [10..8] TXOUT_DIV. = 3(8)
                                        // [13] TXGEARBOX_EN. = 0(FALSE)
                                        // [14] TX_MAINCURSOR_SEL = 0
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9C, 0xAAC);  // [4..2] TXPI_CFG5 = b011
                                        // [5] TXPI_CFG4 = 1
                                        // [6] TXPI_CFG3 = 0
                                        // [8..7] TXPI_CFG2 = 1
                                        // [10..9] TXPI_CFG1 = 1
                                        // [12..11] TXPI_CFG0 = 1
    
    write_drp_channel_reg(GTHE3_CHANNEL_TX_PROGDIV_CFG, 57743); // 57743(80.0)
    
    
    write_drp_channel_reg(GTHE3_CHANNEL_AD, 0x1900);  // [2] RXPI_VREFSEL = 0
                                        // [3] RXPI_LPM = 0
                                        // [8] RATE_SW_USE_DRP = 1
                                        // [10..9] PLL_SEL_MODE_GEN12 = 0
                                        // [12..11] PLL_SEL_MODE_GEN3 = b11
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_52, 0x0002);  // [1..0] RX_DFE_AGC_CFG0 = b10
                                        // [4..2] RX_DFE_AGC_CFG1 = 0
                                        // [10] RX_EN_HI_LR = 0
    
    write_drp_channel_reg(GTHE3_CHANNEL_66, 0x3039);  // [1..0] RX_INT_DATAWIDTH = 1
                                            // [2] RX_WIDEMODE_CDR = 0
                                            // [3] RXBUF_ADDR_MODE. 1(FAST)
                                            // [4] RX_DISPERR_SEQ_MATCH. 1(TRUE)
                                            // [5] RX_CLKMUX_EN = 1
                                            // [11..6] RXBUF_THRESH_UNDFLW = 0
                                            // [12] RXBUF_RESET_ON_CB_CHANGE. 1(TRUE)
                                            // [13] RXBUF_RESET_ON_RATE_CHANGE. 1(TRUE)
                                            // [14] RXBUF_RESET_ON_COMMAALIGN. 0(FALSE)
                                            // [15] RXBUF_THRESH_OVRD. 0(FALSE)

}

void set_speed_2_5G(void)
{
    write_drp_common_reg(GTHE3_COMMON_QPLL0, 78);      	// [7..0] QPLL0_FBDIV =78(80)
                                                        // [15..8] QPLL0_INIT_CFG1 = 0
                                                        
    // GTHE3_CHANNEL
    write_drp_channel_reg(GTHE3_CHANNEL_RXCDR_CFG2, 0b0000011101000110);
    
    write_drp_channel_reg(GTHE3_CHANNEL_63, 0x80C2); // [2..0] RXOUT_DIV = 2(4)
                                        // [13..5] RXOOB_CFG = 0b000000110
                                        // [14] OOB_PWRUP = 0
                                        // [15] CBCC_DATA_SOURCE_SEL. = 1(DECODED)
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9D, 0x5568);  // [4..3] RXPI_CFG0 = 1
                                        // [7..5] RXPI_CFG6 = 3
                                        // [8] RXPI_CFG5 = 1
                                        // [9] RXPI_CFG4 = 0
                                        // [11..10] RXPI_CFG3 = 1
                                        // [13..12] RXPI_CFG2 = 1
                                        // [15..14] RXPI_CFG1 = 1
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_7C, 0x260);  // [2] TXFIFO_ADDR_CFG. = 0(LOW)
                                        // [5..3] TX_RXDETECT_REF = 0b100
                                        // [6] TXBUF_RESET_ON_RATE_CHANGE. = 1(TRUE)
                                        // [7] TXBUF_EN. = 0(FALSE)
                                        // [10..8] TXOUT_DIV. = 2(4)
                                        // [13] TXGEARBOX_EN. = 0(FALSE)
                                        // [14] TX_MAINCURSOR_SEL = 0
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9C, 0xAAC);  // [4..2] TXPI_CFG5 = b011
                                        // [5] TXPI_CFG4 = 1
                                        // [6] TXPI_CFG3 = 0
                                        // [8..7] TXPI_CFG2 = 1
                                        // [10..9] TXPI_CFG1 = 1
                                        // [12..11] TXPI_CFG0 = 1
    
    write_drp_channel_reg(GTHE3_CHANNEL_TX_PROGDIV_CFG, 57743); // 57743(80.0)
    
    
    write_drp_channel_reg(GTHE3_CHANNEL_AD, 0x1900);  // [2] RXPI_VREFSEL = 0
                                        // [3] RXPI_LPM = 0
                                        // [8] RATE_SW_USE_DRP = 1
                                        // [10..9] PLL_SEL_MODE_GEN12 = 0
                                        // [12..11] PLL_SEL_MODE_GEN3 = b11
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_52, 0x0002);  // [1..0] RX_DFE_AGC_CFG0 = b10
                                        // [4..2] RX_DFE_AGC_CFG1 = 0
                                        // [10] RX_EN_HI_LR = 0
    
    write_drp_channel_reg(GTHE3_CHANNEL_66, 0x3039);  // [1..0] RX_INT_DATAWIDTH = 1
                                            // [2] RX_WIDEMODE_CDR = 0
                                            // [3] RXBUF_ADDR_MODE. 1(FAST)
                                            // [4] RX_DISPERR_SEQ_MATCH. 1(TRUE)
                                            // [5] RX_CLKMUX_EN = 1
                                            // [11..6] RXBUF_THRESH_UNDFLW = 0
                                            // [12] RXBUF_RESET_ON_CB_CHANGE. 1(TRUE)
                                            // [13] RXBUF_RESET_ON_RATE_CHANGE. 1(TRUE)
                                            // [14] RXBUF_RESET_ON_COMMAALIGN. 0(FALSE)
                                            // [15] RXBUF_THRESH_OVRD. 0(FALSE)                                                    
                                                        
}

void set_speed_3_125G()
{

	/* GTHE3_COMMON */
    write_drp_common_reg(GTHE3_COMMON_QPLL0, 98);      	// [7..0] QPLL0_FBDIV =98(100)
                                                        // [15..8] QPLL0_INIT_CFG1 = 0


    /* GTHE3_CHANNEL */
    write_drp_channel_reg(GTHE3_CHANNEL_RXCDR_CFG2, 0b0000011101000110);
    
    write_drp_channel_reg(GTHE3_CHANNEL_63, 0x80C2); // [2..0] RXOUT_DIV. = 2(4)
                                        // [13..5] RXOOB_CFG = 0b000000110
                                        // [14] OOB_PWRUP = 0
                                        // [15] CBCC_DATA_SOURCE_SEL. = 1(DECODED)
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9D, 0x5408);  // [4..3] RXPI_CFG0 = 1
                                        // [7..5] RXPI_CFG6 = 0
                                        // [8] RXPI_CFG5 = 0
                                        // [9] RXPI_CFG4 = 0
                                        // [11..10] RXPI_CFG3 = 1
                                        // [13..12] RXPI_CFG2 = 1
                                        // [15..14] RXPI_CFG1 = 1
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_7C, 0x260);  // [2] TXFIFO_ADDR_CFG. = 0(LOW)
                                        // [5..3] TX_RXDETECT_REF = 0b100
                                        // [6] TXBUF_RESET_ON_RATE_CHANGE. = 1(TRUE)
                                        // [7] TXBUF_EN. = 0(FALSE)
                                        // [10..8] TXOUT_DIV. = 2(4)
                                        // [13] TXGEARBOX_EN. = 0(FALSE)
                                        // [14] TX_MAINCURSOR_SEL = 0
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9C, 0xA80);  // [4..2] TXPI_CFG5 = 0
                                        // [5] TXPI_CFG4 = 0
                                        // [6] TXPI_CFG3 = 0
                                        // [8..7] TXPI_CFG2 = 1
                                        // [10..9] TXPI_CFG1 = 1
                                        // [12..11] TXPI_CFG0 = 1
    
    write_drp_channel_reg(GTHE3_CHANNEL_TX_PROGDIV_CFG, 57743); // 57743(80.0) 
    
    
    write_drp_channel_reg(GTHE3_CHANNEL_AD, 0x1900);  // [2] RXPI_VREFSEL = 0
                                        // [3] RXPI_LPM = 0
                                        // [8] RATE_SW_USE_DRP = 1
                                        // [10..9] PLL_SEL_MODE_GEN12 = 0
                                        // [12..11] PLL_SEL_MODE_GEN3 = b11
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_52, 0x0002);  // [1..0] RX_DFE_AGC_CFG0 = b10
                                        // [4..2] RX_DFE_AGC_CFG1 = 0
                                        // [10] RX_EN_HI_LR = 0
    
    write_drp_channel_reg(GTHE3_CHANNEL_66, 0x3039);  // [1..0] RX_INT_DATAWIDTH = 1
                                            // [2] RX_WIDEMODE_CDR = 0
                                            // [3] RXBUF_ADDR_MODE. 1(FAST)
                                            // [4] RX_DISPERR_SEQ_MATCH. 1(TRUE)
                                            // [5] RX_CLKMUX_EN = 1
                                            // [11..6] RXBUF_THRESH_UNDFLW = 0
                                            // [12] RXBUF_RESET_ON_CB_CHANGE. 1(TRUE)
                                            // [13] RXBUF_RESET_ON_RATE_CHANGE. 1(TRUE)
                                            // [14] RXBUF_RESET_ON_COMMAALIGN. 0(FALSE)
                                            // [15] RXBUF_THRESH_OVRD. 0(FALSE)
}

void set_speed_5_0G()
{
    /* GTHE3_COMMON */
    write_drp_common_reg(GTHE3_COMMON_QPLL0, 78);      	// [7..0] QPLL0_FBDIV =78(80)
                                                        // [15..8] QPLL0_INIT_CFG1 = 0


    // GTHE3_CHANNEL
    write_drp_channel_reg(GTHE3_CHANNEL_RXCDR_CFG2, 0b0000011101010110);
    
    write_drp_channel_reg(GTHE3_CHANNEL_63, 0x80C1); // [2..0] RXOUT_DIV. = 1(2)
                                        // [13..5] RXOOB_CFG = 0b000000110
                                        // [14] OOB_PWRUP = 0
                                        // [15] CBCC_DATA_SOURCE_SEL. = 1(DECODED)
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9D, 0x5568);  // [4..3] RXPI_CFG0 = 1
                                        // [7..5] RXPI_CFG6 = 3
                                        // [8] RXPI_CFG5 = 1
                                        // [9] RXPI_CFG4 = 0
                                        // [11..10] RXPI_CFG3 = 1
                                        // [13..12] RXPI_CFG2 = 1
                                        // [15..14] RXPI_CFG1 = 1
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_7C, 0x160);  // [2] TXFIFO_ADDR_CFG. = 0(LOW)
                                        // [5..3] TX_RXDETECT_REF = 0b100
                                        // [6] TXBUF_RESET_ON_RATE_CHANGE. = 1(TRUE)
                                        // [7] TXBUF_EN. = 0(FALSE)
                                        // [10..8] TXOUT_DIV. = 1(2)
                                        // [13] TXGEARBOX_EN. = 0(FALSE)
                                        // [14] TX_MAINCURSOR_SEL = 0
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9C, 0xAAC);  // [4..2] TXPI_CFG5 = b011
                                        // [5] TXPI_CFG4 = 1
                                        // [6] TXPI_CFG3 = 0
                                        // [8..7] TXPI_CFG2 = 1
                                        // [10..9] TXPI_CFG1 = 1
                                        // [12..11] TXPI_CFG0 = 1
    
    write_drp_channel_reg(GTHE3_CHANNEL_TX_PROGDIV_CFG, 57766); // 57766(40.0)
    
    
    write_drp_channel_reg(GTHE3_CHANNEL_AD, 0x1900);  // [2] RXPI_VREFSEL = 0
                                        // [3] RXPI_LPM = 0
                                        // [8] RATE_SW_USE_DRP = 1
                                        // [10..9] PLL_SEL_MODE_GEN12 = 0
                                        // [12..11] PLL_SEL_MODE_GEN3 = b11
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_52, 0x0002);  // [1..0] RX_DFE_AGC_CFG0 = b10
                                        // [4..2] RX_DFE_AGC_CFG1 = 0
                                        // [10] RX_EN_HI_LR = 0
    
    write_drp_channel_reg(GTHE3_CHANNEL_66, 0x3039);  // [1..0] RX_INT_DATAWIDTH = 1
                                            // [2] RX_WIDEMODE_CDR = 0
                                            // [3] RXBUF_ADDR_MODE. 1(FAST)
                                            // [4] RX_DISPERR_SEQ_MATCH. 1(TRUE)
                                            // [5] RX_CLKMUX_EN = 1
                                            // [11..6] RXBUF_THRESH_UNDFLW = 0
                                            // [12] RXBUF_RESET_ON_CB_CHANGE. 1(TRUE)
                                            // [13] RXBUF_RESET_ON_RATE_CHANGE. 1(TRUE)
                                            // [14] RXBUF_RESET_ON_COMMAALIGN. 0(FALSE)
                                            // [15] RXBUF_THRESH_OVRD. 0(FALSE)
                                                        
}

void set_speed_6_25G()
{
	/* GTHE3_COMMON */
    write_drp_common_reg(GTHE3_COMMON_QPLL0, 98);      	// [7..0] QPLL0_FBDIV =98(100)
                                                        // [15..8] QPLL0_INIT_CFG1 = 0


    /* GTHE3_CHANNEL */
    write_drp_channel_reg(GTHE3_CHANNEL_RXCDR_CFG2, 0b0000011101010110);
    
    write_drp_channel_reg(GTHE3_CHANNEL_63, 0x80C1); // [2..0] RXOUT_DIV. = 1(2)
                                        // [13..5] RXOOB_CFG = 0b000000110
                                        // [14] OOB_PWRUP = 0
                                        // [15] CBCC_DATA_SOURCE_SEL. = 1(DECODED)
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9D, 0x5408);  // [4..3] RXPI_CFG0 = 1
                                        // [7..5] RXPI_CFG6 = 0
                                        // [8] RXPI_CFG5 = 0
                                        // [9] RXPI_CFG4 = 0
                                        // [11..10] RXPI_CFG3 = 1
                                        // [13..12] RXPI_CFG2 = 1
                                        // [15..14] RXPI_CFG1 = 1 
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_7C, 0x160);  // [2] TXFIFO_ADDR_CFG. = 0(LOW)
                                        // [5..3] TX_RXDETECT_REF = 0b100
                                        // [6] TXBUF_RESET_ON_RATE_CHANGE. = 1(TRUE)
                                        // [7] TXBUF_EN. = 0(FALSE)
                                        // [10..8] TXOUT_DIV. = 1(2)
                                        // [13] TXGEARBOX_EN. = 0(FALSE)
                                        // [14] TX_MAINCURSOR_SEL = 0
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9C, 0xA80);  // [4..2] TXPI_CFG5 = 0
                                        // [5] TXPI_CFG4 = 0
                                        // [6] TXPI_CFG3 = 0
                                        // [8..7] TXPI_CFG2 = 1
                                        // [10..9] TXPI_CFG1 = 1
                                        // [12..11] TXPI_CFG0 = 1
    
    write_drp_channel_reg(GTHE3_CHANNEL_TX_PROGDIV_CFG, 57766); // 57766(40.0)
    
    
    write_drp_channel_reg(GTHE3_CHANNEL_AD, 0x1900);  // [2] RXPI_VREFSEL = 0
                                        // [3] RXPI_LPM = 0
                                        // [8] RATE_SW_USE_DRP = 1
                                        // [10..9] PLL_SEL_MODE_GEN12 = 0
                                        // [12..11] PLL_SEL_MODE_GEN3 = b11
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_52, 0x0002);  // [1..0] RX_DFE_AGC_CFG0 = b10
                                        // [4..2] RX_DFE_AGC_CFG1 = 0
                                        // [10] RX_EN_HI_LR = 0
    
    write_drp_channel_reg(GTHE3_CHANNEL_66, 0x3039);  // [1..0] RX_INT_DATAWIDTH = 1
                                            // [2] RX_WIDEMODE_CDR = 0
                                            // [3] RXBUF_ADDR_MODE. 1(FAST)
                                            // [4] RX_DISPERR_SEQ_MATCH. 1(TRUE)
                                            // [5] RX_CLKMUX_EN = 1
                                            // [11..6] RXBUF_THRESH_UNDFLW = 0
                                            // [12] RXBUF_RESET_ON_CB_CHANGE. 1(TRUE)
                                            // [13] RXBUF_RESET_ON_RATE_CHANGE. 1(TRUE)
                                            // [14] RXBUF_RESET_ON_COMMAALIGN. 0(FALSE)
                                            // [15] RXBUF_THRESH_OVRD. 0(FALSE)
}

void set_speed_10_0G()
{
    /* GTHE3_COMMON */
    write_drp_common_reg(GTHE3_COMMON_QPLL0, 78);      	// [7..0] QPLL0_FBDIV =78(80)
                                                        // [15..8] QPLL0_INIT_CFG1 = 0


    // GTHE3_CHANNEL
    write_drp_channel_reg(GTHE3_CHANNEL_RXCDR_CFG2, 0b0000011101100110);
    
    write_drp_channel_reg(GTHE3_CHANNEL_63, 0x80C0); // [2..0] RXOUT_DIV. = 0(1)
                                        // [13..5] RXOOB_CFG = 0b000000110
                                        // [14] OOB_PWRUP = 0
                                        // [15] CBCC_DATA_SOURCE_SEL. = 1(DECODED)
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9D, 0x5568);  // [4..3] RXPI_CFG0 = 1
                                        // [7..5] RXPI_CFG6 = 3
                                        // [8] RXPI_CFG5 = 1
                                        // [9] RXPI_CFG4 = 0
                                        // [11..10] RXPI_CFG3 = 1
                                        // [13..12] RXPI_CFG2 = 1
                                        // [15..14] RXPI_CFG1 = 1
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_7C, 0x60);  // [2] TXFIFO_ADDR_CFG. = 0(LOW)
                                        // [5..3] TX_RXDETECT_REF = 0b100
                                        // [6] TXBUF_RESET_ON_RATE_CHANGE. = 1(TRUE)
                                        // [7] TXBUF_EN. = 0(FALSE)
                                        // [10..8] TXOUT_DIV. = 0(1)
                                        // [13] TXGEARBOX_EN. = 0(FALSE)
                                        // [14] TX_MAINCURSOR_SEL = 0
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9C, 0xAAC);  // [4..2] TXPI_CFG5 = b011
                                        // [5] TXPI_CFG4 = 1
                                        // [6] TXPI_CFG3 = 0
                                        // [8..7] TXPI_CFG2 = 1
                                        // [10..9] TXPI_CFG1 = 1
                                        // [12..11] TXPI_CFG0 = 1
    
    write_drp_channel_reg(GTHE3_CHANNEL_TX_PROGDIV_CFG, 57762); // 57762(20.0)
    
    
    write_drp_channel_reg(GTHE3_CHANNEL_AD, 0x1F00);  // [2] RXPI_VREFSEL = 0
                                        // [3] RXPI_LPM = 0
                                        // [8] RATE_SW_USE_DRP = 1
                                        // [10..9] PLL_SEL_MODE_GEN12 = b11
                                        // [12..11] PLL_SEL_MODE_GEN3 = b11
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_52, 0x0002);  // [1..0] RX_DFE_AGC_CFG0 = b10
                                        // [4..2] RX_DFE_AGC_CFG1 = 0
                                        // [10] RX_EN_HI_LR = 0
    
    write_drp_channel_reg(GTHE3_CHANNEL_66, 0x303D);  // [1..0] RX_INT_DATAWIDTH = 1
                                            // [2] RX_WIDEMODE_CDR = 1
                                            // [3] RXBUF_ADDR_MODE. 1(FAST)
                                            // [4] RX_DISPERR_SEQ_MATCH. 1(TRUE)
                                            // [5] RX_CLKMUX_EN = 1
                                            // [11..6] RXBUF_THRESH_UNDFLW = 0
                                            // [12] RXBUF_RESET_ON_CB_CHANGE. 1(TRUE)
                                            // [13] RXBUF_RESET_ON_RATE_CHANGE. 1(TRUE)
                                            // [14] RXBUF_RESET_ON_COMMAALIGN. 0(FALSE)
                                            // [15] RXBUF_THRESH_OVRD. 0(FALSE)
                                                        
}

void set_speed_12_5G(void)
{
	/* GTHE3_COMMON */
    write_drp_common_reg(GTHE3_COMMON_QPLL0, 98);      	// [7..0] QPLL0_FBDIV =98(100)
                                                        // [15..8] QPLL0_INIT_CFG1 = 0


    /* GTHE3_CHANNEL */
    write_drp_channel_reg(GTHE3_CHANNEL_RXCDR_CFG2, 0b0000011101100110);
    
    write_drp_channel_reg(GTHE3_CHANNEL_63, 0x80C0); // [2..0] RXOUT_DIV. = 0(1)
                                        // [13..5] RXOOB_CFG = 0b000000110
                                        // [14] OOB_PWRUP = 0
                                        // [15] CBCC_DATA_SOURCE_SEL. = 1(DECODED)
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9D, 0x5408);  // [4..3] RXPI_CFG0 = 1
                                        // [7..5] RXPI_CFG6 = 0
                                        // [8] RXPI_CFG5 = 0
                                        // [9] RXPI_CFG4 = 0
                                        // [11..10] RXPI_CFG3 = 1
                                        // [13..12] RXPI_CFG2 = 1
                                        // [15..14] RXPI_CFG1 = 1
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_7C, 0x60);  // [2] TXFIFO_ADDR_CFG. = 0(LOW)
                                        // [5..3] TX_RXDETECT_REF = 0b100
                                        // [6] TXBUF_RESET_ON_RATE_CHANGE. = 1(TRUE)
                                        // [7] TXBUF_EN. = 0(FALSE)
                                        // [10..8] TXOUT_DIV. = 0(1)
                                        // [13] TXGEARBOX_EN. = 0(FALSE)
                                        // [14] TX_MAINCURSOR_SEL = 0
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_9C, 0xA80);  // [4..2] TXPI_CFG5 = 0
                                        // [5] TXPI_CFG4 = 0
                                        // [6] TXPI_CFG3 = 0
                                        // [8..7] TXPI_CFG2 = 1
                                        // [10..9] TXPI_CFG1 = 1
                                        // [12..11] TXPI_CFG0 = 1
    
    write_drp_channel_reg(GTHE3_CHANNEL_TX_PROGDIV_CFG, 57762); // 57762(20.0)
    
    
    write_drp_channel_reg(GTHE3_CHANNEL_AD, 0x1F00);  // [2] RXPI_VREFSEL = 0
                                        // [3] RXPI_LPM = 0
                                        // [8] RATE_SW_USE_DRP = 1
                                        // [10..9] PLL_SEL_MODE_GEN12 = b11
                                        // [12..11] PLL_SEL_MODE_GEN3 = b11
                                        
    write_drp_channel_reg(GTHE3_CHANNEL_52, 0x0402);  // [1..0] RX_DFE_AGC_CFG0 = b10
                                        // [4..2] RX_DFE_AGC_CFG1 = 0
                                        // [10] RX_EN_HI_LR = 1
    
    write_drp_channel_reg(GTHE3_CHANNEL_66, 0x303D);  // [1..0] RX_INT_DATAWIDTH = 1
                                            // [2] RX_WIDEMODE_CDR = 1
                                            // [3] RXBUF_ADDR_MODE. 1(FAST)
                                            // [4] RX_DISPERR_SEQ_MATCH. 1(TRUE)
                                            // [5] RX_CLKMUX_EN = 1
                                            // [11..6] RXBUF_THRESH_UNDFLW = 0
                                            // [12] RXBUF_RESET_ON_CB_CHANGE. 1(TRUE)
                                            // [13] RXBUF_RESET_ON_RATE_CHANGE. 1(TRUE)
                                            // [14] RXBUF_RESET_ON_COMMAALIGN. 0(FALSE)
                                            // [15] RXBUF_THRESH_OVRD. 0(FALSE)
}

void pll_config_init()
{
	XGpio_Initialize(&Gpio, XPAR_GPIO_0_DEVICE_ID);
	XGpio_SetDataDirection(&Gpio, 1, 0x0);				// Channel 1, all port as output
}

const uint16_t pll_link_map[4] = {0, 1, 2, 3}; // indirect mapping of transceiver channels

void pll_config_speed(uint32_t channel, uint32_t speed)
{
	Xil_Out16(EXT_PHY_CHANNEL_FOR_CXP_0_BASEADDR, pll_link_map[channel]);	// Select channel PLL
	switch(speed)
	{
	case 0x28:
		set_speed_1_25G();
		break;
    case 0x30:
		set_speed_2_5G();
		break;
	case 0x38:
		set_speed_3_125G();
		break;
    case 0x40:
		set_speed_5_0G();
		break;
	case 0x48:
		set_speed_6_25G();
		break;
	case 0x50:
		set_speed_10_0G();
		break;
    case 0x58:
		set_speed_12_5G();
		break;
	default:
		xil_printf("Unsupported pll configuration speed!!!\n\r");
		return;
		break;
	}

	usleep(10);
	//RESET initial GTX PHY
	XGpio_DiscreteWrite(&Gpio, 1, 1);
	usleep(10);
	XGpio_DiscreteWrite(&Gpio, 1, 0);

	usleep(10);

}
