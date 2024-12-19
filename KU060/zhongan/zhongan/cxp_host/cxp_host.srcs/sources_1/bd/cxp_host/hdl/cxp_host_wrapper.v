//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
//Date        : Fri Mar 22 10:14:46 2024
//Host        : Yasing running 64-bit major release  (build 9200)
//Command     : generate_target cxp_host_wrapper.bd
//Design      : cxp_host_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module cxp_host_wrapper
   (UART_rxd,
    UART_txd,
    fmc_ref_clk_n,
    fmc_ref_clk_p,
    fmc_rx_n,
    fmc_rx_p,
    fmc_tx,
    pocxp_en_tri_o,
    power_good);
  input UART_rxd;
  output UART_txd;
  input fmc_ref_clk_n;
  input fmc_ref_clk_p;
  input [3:0]fmc_rx_n;
  input [3:0]fmc_rx_p;
  output [3:0]fmc_tx;
  output [2:0]pocxp_en_tri_o;
  output power_good;

  wire UART_rxd;
  wire UART_txd;
  wire fmc_ref_clk_n;
  wire fmc_ref_clk_p;
  wire [3:0]fmc_rx_n;
  wire [3:0]fmc_rx_p;
  wire [3:0]fmc_tx;
  wire [2:0]pocxp_en_tri_o;
  wire power_good;

  cxp_host cxp_host_i
       (.UART_rxd(UART_rxd),
        .UART_txd(UART_txd),
        .fmc_ref_clk_n(fmc_ref_clk_n),
        .fmc_ref_clk_p(fmc_ref_clk_p),
        .fmc_rx_n(fmc_rx_n),
        .fmc_rx_p(fmc_rx_p),
        .fmc_tx(fmc_tx),
        .pocxp_en_tri_o(pocxp_en_tri_o),
        .power_good(power_good));
endmodule
