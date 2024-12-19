
#ifndef SRC_PLL_GTHE3_CONTROL_H_
#define SRC_PLL_GTHE3_CONTROL_H_

#include "xil_types.h"

/* GTHE3_COMMON */
#define GTHE3_COMMON_QPLL0      	 0x0014 // [7..0] QPLL0_FBDIV 78-80, 98-100
                                            // [15..8] QPLL0_INIT_CFG1


/* GTHE3_CHANNEL */
#define GTHE3_CHANNEL_RXCDR_CFG2     0x0010

#define GTHE3_CHANNEL_63             0x0063 // [2..0] RXOUT_DIV. 0-1, 1-2, 2-4, 3-8, 4-16
											// [13..5] RXOOB_CFG
											// [14] OOB_PWRUP
                                            // [15] CBCC_DATA_SOURCE_SEL. 0-ENCODED, 1-DECODED
                                            
#define GTHE3_CHANNEL_9D            0x009D  // [4..3] RXPI_CFG0
                                            // [7..5] RXPI_CFG6
                                            // [8] RXPI_CFG5
                                            // [9] RXPI_CFG4
                                            // [11..10] RXPI_CFG3
                                            // [13..12] RXPI_CFG2
                                            // [15..14] RXPI_CFG1 
                                            
#define GTHE3_CHANNEL_7C            0x007C  // [2] TXFIFO_ADDR_CFG. 0-LOW, 1-HIGH
                                            // [5..3] TX_RXDETECT_REF
                                            // [6] TXBUF_RESET_ON_RATE_CHANGE. 0-FALSE, 1-TRUE
                                            // [7] TXBUF_EN. 0-FALSE, 1-TRUE
                                            // [10..8] TXOUT_DIV. 0-1, 1-2, 2-4, 3-8, 4-16
                                            // [13] TXGEARBOX_EN. 0-FALSE, 1-TRUE
                                            // [14] TX_MAINCURSOR_SEL
                                            
#define GTHE3_CHANNEL_9C            0x009C  // [4..2] TXPI_CFG5
                                            // [5] TXPI_CFG4
                                            // [6] TXPI_CFG3
                                            // [8..7] TXPI_CFG2
                                            // [10..9] TXPI_CFG1
                                            // [12..11] TXPI_CFG0

#define GTHE3_CHANNEL_TX_PROGDIV_CFG 0x003E // 32768-0.0, 57744-4.0, 49648-5.0, 57728-8.0, 57760-10.0,
                                            // 57730-16.0, 49672-16.5, 57762-20.0, 57734-32.0, 49800-33.0, 
                                            // 57766-40.0, 57742-64.0, 50056-66.0, 57743-80.0, 57775-100.0 


#define GTHE3_CHANNEL_AD            0x00AD  // [2] RXPI_VREFSEL
                                            // [3] RXPI_LPM
                                            // [8] RATE_SW_USE_DRP
                                            // [10..9] PLL_SEL_MODE_GEN12
                                            // [12..11] PLL_SEL_MODE_GEN3
                                            
#define GTHE3_CHANNEL_52            0x0052  // [1..0] RX_DFE_AGC_CFG0
                                            // [4..2] RX_DFE_AGC_CFG1
                                            // [10] RX_EN_HI_LR

#define GTHE3_CHANNEL_66            0x0066  // [1..0] RX_INT_DATAWIDTH
                                            // [2] RX_WIDEMODE_CDR
                                            // [3] RXBUF_ADDR_MODE. 0-FULL, 1-FAST
                                            // [4] RX_DISPERR_SEQ_MATCH. 0-FALSE, 1-TRUE
                                            // [5] RX_CLKMUX_EN
                                            // [11..6] RXBUF_THRESH_UNDFLW
                                            // [12] RXBUF_RESET_ON_CB_CHANGE. 0-FALSE, 1-TRUE
                                            // [13] RXBUF_RESET_ON_RATE_CHANGE. 0-FALSE, 1-TRUE
                                            // [14] RXBUF_RESET_ON_COMMAALIGN. 0-FALSE, 1-TRUE
                                            // [15] RXBUF_THRESH_OVRD. 0-FALSE, 1-TRUE
                                            
#define GTHE3_CHANNEL_00            0x0000  // [] 
                                            // [] 
                                            // [] 
                                            // []
                                            // [] 
                                            // [] 
                                            // []

void pll_config_init();
void pll_config_speed(uint32_t channel, uint32_t speed);

void pll_config_enable(uint32_t bEnable);

#endif /* SRC_PLL_GTHE3_CONTROL_H_ */
