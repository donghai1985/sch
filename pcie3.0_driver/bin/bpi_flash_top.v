module bpi_flash_top #(
    parameter                              FIFO_DATA_WD    =   32          ,
    parameter                              FLASH_ADDR_WD   =   26          ,
    parameter                              FLASH_DATA_WD   =   16           
)(
    input                                  sys_clk                         ,//(i)
    input                                  sys_rst_n                       ,//(i)
    input                                  cfg_rst                         ,//(i) 

    input                                  lock_en                         ,//(i) flash base inf
    input                                  unlock_erase_en                 ,//(i) flash base inf
    input             [FLASH_ADDR_WD-1:0]  block_num                       ,//(i) flash base inf
    input                                  cfg_en                          ,//(i) flash base inf
    input                                  rdid_en                         ,//(i) flash base inf
    input             [FLASH_ADDR_WD-1:0]  rdid_offset                     ,//(i) flash base inf
    output            [FLASH_DATA_WD-1:0]  rdid_dout                       ,//(o) flash base inf
    input                                  rdsta_en                        ,//(i) flash base inf
    output            [FLASH_DATA_WD-1:0]  status                          ,//(o) flash base inf

    input                                  cfg_wr_trig                     ,//(i) wr inf
    input             [31:0]               cfg_wr_len                      ,//(i)
    input             [31:0]               cfg_wr_addr                     ,//(i)
    output                                 sts_wr_cpl                      ,//(o)
    input                                  fifo_wr                         ,//(i)
    input             [FIFO_DATA_WD-1:0]   fifo_din                        ,//(i)
    output                                 fifo_full                       ,//(o)
                                                                                 
    input                                  cfg_rd_trig                     ,//(i) rd inf
    input             [31:0]               cfg_rd_len                      ,//(i)
    input             [31:0]               cfg_rd_addr                     ,//(i)
    output                                 sts_rd_cpl                      ,//(o)
    input                                  fifo_rd                         ,//(i)
    output            [FIFO_DATA_WD-1:0]   fifo_dout                       ,//(o)
    output                                 fifo_empty                      ,//(o)
    output            [10:0]               fifo_rd_cnt                     ,//(o)

    input             [FLASH_DATA_WD-1:0]  flash_din                       ,//(i)
    output            [FLASH_DATA_WD-1:0]  flash_dout                      ,//(o)
    output            [FLASH_ADDR_WD-1:0]  flash_addr                      ,//(o)
    output                                 flash_we                        ,//(o)
    output                                 flash_adv                       ,//(o)
    output                                 flash_oe                        ,//(o)
    output                                 flash_ce                        ,//(o)
    input                                  flash_wait                      ,//(i)
    output                                 flash_clk                        //(o)
    
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------


    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    wire                                   flash_busy                      ;
    wire                                   array_rd_en                     ;
    wire        [FLASH_ADDR_WD-1:0]        array_rd_addr                   ;
    wire        [9              :0]        array_rd_len                    ;
    wire                                   array_rd_vld                    ;
    wire        [FLASH_DATA_WD-1:0]        array_rd_dout                   ;
    wire                                   buff_wr_en                      ;
    wire        [FLASH_ADDR_WD-1:0]        buff_wr_addr                    ;
    wire        [9:0]                      buff_wr_len                     ;
    wire                                   buff_wr_vld                     ;
    wire        [FLASH_DATA_WD-1:0]        buff_wr_din                     ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------


// =================================================================================================
// RTL Body
// =================================================================================================


    // -------------------------------------------------------------------------
    // bpi_flash_fifo_rd  Module Inst.
    // -------------------------------------------------------------------------
    bpi_flash_fifo_rd #(                                                  
        .FIFO_DATA_WD                (FIFO_DATA_WD             ),
        .FLASH_ADDR_WD               (FLASH_ADDR_WD            ),
        .FLASH_DATA_WD               (FLASH_DATA_WD            )       
    )u_bpi_flash_fifo_rd( 
        .sys_clk                     (sys_clk                  ),//(i)
        .sys_rst_n                   (sys_rst_n                ),//(i)
        .cfg_rst                     (cfg_rst                  ),//(i)
        .cfg_rd_trig                 (cfg_rd_trig              ),//(i)
        .cfg_rd_len                  (cfg_rd_len               ),//(i)
        .cfg_rd_addr                 (cfg_rd_addr              ),//(i)
        .sts_rd_cpl                  (sts_rd_cpl               ),//(o)
        .fifo_rd                     (fifo_rd                  ),//(o)
        .fifo_dout                   (fifo_dout                ),//(i)
        .fifo_empty                  (fifo_empty               ),//(o)
        .fifo_rd_cnt                 (fifo_rd_cnt              ),//(o)
        .flash_busy                  (flash_busy               ),//(i)
        .array_rd_en                 (array_rd_en              ),//(o)
        .array_rd_addr               (array_rd_addr            ),//(o)
        .array_rd_len                (array_rd_len             ),//(o)
        .array_rd_vld                (array_rd_vld             ),//(i)
        .array_rd_dout               (array_rd_dout            ) //(i)
    );                                                          

    // -------------------------------------------------------------------------
    // bpi_flash_fifo_wr  Module Inst.
    // -------------------------------------------------------------------------
    bpi_flash_fifo_wr #(                                                  
        .FIFO_DATA_WD                (FIFO_DATA_WD             ),
        .FLASH_ADDR_WD               (FLASH_ADDR_WD            ),
        .FLASH_DATA_WD               (FLASH_DATA_WD            )       
    )u_bpi_flash_fifo_wr( 
        .sys_clk                     (sys_clk                  ),//(i)
        .sys_rst_n                   (sys_rst_n                ),//(i)
        .cfg_rst                     (cfg_rst                  ),//(i)
        .cfg_wr_trig                 (cfg_wr_trig              ),//(i)
        .cfg_wr_len                  (cfg_wr_len               ),//(i)
        .cfg_wr_addr                 (cfg_wr_addr              ),//(i)
        .sts_wr_cpl                  (sts_wr_cpl               ),//(o)
        .fifo_wr                     (fifo_wr                  ),//(i)
        .fifo_din                    (fifo_din                 ),//(i)
        .fifo_full                   (fifo_full                ),//(o)
        .flash_busy                  (flash_busy               ),//(i)
        .buff_wr_en                  (buff_wr_en               ),//(o)
        .buff_wr_addr                (buff_wr_addr             ),//(o)
        .buff_wr_len                 (buff_wr_len              ),//(o)
        .buff_wr_vld                 (buff_wr_vld              ),//(i)
        .buff_wr_din                 (buff_wr_din              ) //(o)
    );                                                         

    // -------------------------------------------------------------------------
    // bpi_flash_drive  Module Inst.
    // -------------------------------------------------------------------------
    bpi_flash_drive #(                                                  
        .ADDR_WD                     (FLASH_ADDR_WD            ),
        .DATA_WD                     (FLASH_DATA_WD            )       
    )u_bpi_flash_drive( 
        .sys_clk                     (sys_clk                  ),//(i)
        .sys_rst_n                   (sys_rst_n                ),//(i)
        .fre_div                     (3'd2                     ),//(i)
        .flash_busy                  (flash_busy               ),//(o)
        .rdid_en                     (rdid_en                  ),//(i)
        .rdid_offset                 (rdid_offset              ),//(i)
        .rdid_dout                   (rdid_dout                ),//(o)
        .rdsta_en                    (rdsta_en                 ),//(i)
        .status                      (status                   ),//(o)
        .rd_en                       ('d0                      ),//(i)
        .rd_addr                     ('d0                      ),//(i)
        .rd_vld                      (                         ),//(o)
        .rd_dout                     (                         ),//(o)
        .array_rd_en                 (array_rd_en              ),//(i)
        .array_rd_addr               (array_rd_addr            ),//(i)
        .array_rd_len                (array_rd_len             ),//(i)
        .array_rd_vld                (array_rd_vld             ),//(o)
        .array_rd_dout               (array_rd_dout            ),//(o)
        .buff_wr_en                  (buff_wr_en               ),//(i)
        .buff_wr_addr                (buff_wr_addr             ),//(i)
        .buff_wr_len                 (buff_wr_len              ),//(i)
        .buff_wr_vld                 (buff_wr_vld              ),//(o)
        .buff_wr_din                 (buff_wr_din              ),//(i)
        .lock_en                     (lock_en                  ),//(i)
        .unlock_en                   (unlock_en                ),//(i)
        .erase_en                    (erase_en                 ),//(i)
        .unlock_erase_en             (unlock_erase_en          ),//(i)
        .block_num                   (block_num                ),//(i)
        .wr_en                       ('d0                      ),//(i)
        .wr_addr                     ('d0                      ),//(i)
        .wr_din                      ('d0                      ),//(i)
        .cfg_en                      (cfg_en                   ),//(i)
        .cfg_data                    (cfg_data                 ),//(i) nouse

        .flash_din                   (flash_din                ),//(i)
        .flash_dout                  (flash_dout               ),//(o)
        .flash_addr                  (flash_addr               ),//(o)
        .flash_we                    (flash_we                 ),//(o)
        .flash_adv                   (flash_adv                ),//(o)
        .flash_oe                    (flash_oe                 ),//(o)
        .flash_ce                    (flash_ce                 ),//(o)
        .flash_wait                  (flash_wait               ),//(i)
        .flash_clk                   (flash_clk                ) //(o)
    );                                                        



















endmodule













