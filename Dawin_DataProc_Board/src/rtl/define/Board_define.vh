`ifndef BOARD_DEFINE_H
`define BOARD_DEFINE_H


localparam Board_DIP=3'h0;
localparam IMC_BASE_IP=32'hc0_a8_00_0A;

localparam IMC_0_ETH0_IP=IMC_BASE_IP+Board_DIP*6;
localparam IMC_0_ETH1_IP=IMC_BASE_IP+Board_DIP*6+1;
localparam IMC_1_ETH0_IP=IMC_BASE_IP+Board_DIP*6+2;
localparam IMC_1_ETH1_IP=IMC_BASE_IP+Board_DIP*6+3;
localparam IMC_2_ETH0_IP=IMC_BASE_IP+Board_DIP*6+4;
localparam IMC_2_ETH1_IP=IMC_BASE_IP+Board_DIP*6+5;

localparam IMC_BASE_MAC_SIM=48'h6c_b3_11_88_10_98;
localparam IMC_0_ETH0_MAC_SIM=IMC_BASE_MAC_SIM+Board_DIP*6;
localparam IMC_0_ETH1_MAC_SIM=IMC_BASE_MAC_SIM+Board_DIP*6+1;
localparam IMC_1_ETH0_MAC_SIM=IMC_BASE_MAC_SIM+Board_DIP*6+2;
localparam IMC_1_ETH1_MAC_SIM=IMC_BASE_MAC_SIM+Board_DIP*6+3;
localparam IMC_2_ETH0_MAC_SIM=IMC_BASE_MAC_SIM+Board_DIP*6+4;
localparam IMC_2_ETH1_MAC_SIM=IMC_BASE_MAC_SIM+Board_DIP*6+5;

localparam IMC_0_init_PSN=24'h1111;
localparam IMC_1_init_PSN=24'h2222;
localparam IMC_2_init_PSN=24'h3333;

localparam IMC_0_QPn=24'h8;
localparam IMC_1_QPn=24'h23;
localparam IMC_2_QPn=24'h45;

localparam IMC_0_fpga_start_PSN=24'h1111;
localparam IMC_1_fpga_start_PSN=24'h1111;
localparam IMC_2_fpga_start_PSN=24'h1111;

`endif