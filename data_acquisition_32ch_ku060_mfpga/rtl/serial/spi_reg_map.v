module spi_reg_map #(
    parameter                               TCQ        = 0.1,
    parameter                               DATA_WIDTH = 32 ,
    parameter                               ADDR_WIDTH = 16 ,
    parameter       [32*5-1:0]              pmt_mfpga_version = "PCG32_PMTM_v2.13    "
)(
    // clk & rst
    input   wire                            clk_i               ,
    input   wire                            rst_i               ,

    input   wire                            slave_wr_en_i       ,
    input   wire    [ADDR_WIDTH-1:0]        slave_addr_i        ,
    input   wire    [DATA_WIDTH-1:0]        slave_wr_data_i     ,
    input   wire                            slave_rd_en_i       ,
    output  wire                            slave_rd_vld_o      ,
    output  wire    [DATA_WIDTH-1:0]        slave_rd_data_o     ,

    input                                   adc_lock            ,//(i)
    input                                   eds_lock            ,//(i)
    input                                   fbc_lock            ,//(i)
    input           [31:0]                  i_rega0             ,//(i) 16'h0040     
    input           [31:0]                  i_rega1             ,//(i) 16'h0044     
    input           [31:0]                  i_rega2             ,//(i) 16'h0048     
    input           [31:0]                  i_rega3             ,//(i) 16'h004C     
    input           [31:0]                  i_rega4             ,//(i) 16'h0050     
    input           [31:0]                  i_rega5             ,//(i) 16'h0054     
    input           [31:0]                  i_rega6             ,//(i) 16'h0058     
    input           [31:0]                  i_rega7             ,//(i) 16'h005C     
    input           [31:0]                  i_regb0             ,//(i) 16'h0060     
    input           [31:0]                  i_regb1             ,//(i) 16'h0064     
    input           [31:0]                  i_regb2             ,//(i) 16'h0068     
    input           [31:0]                  i_regb3             ,//(i) 16'h006C     
    input           [31:0]                  i_regb4             ,//(i) 16'h0070     
    input           [31:0]                  i_regb5             ,//(i) 16'h0074     
    input           [31:0]                  i_regb6             ,//(i) 16'h0078     
    input           [31:0]                  i_regb7             ,//(i) 16'h007C     
    input           [31:0]                  i_regc0             ,//(i) 16'h0080     
    input           [31:0]                  i_regc1             ,//(i) 16'h0084     
    input           [31:0]                  i_regc2             ,//(i) 16'h0088     
    input           [31:0]                  i_regc3             ,//(i) 16'h008C     
    input           [31:0]                  i_regc4             ,//(i) 16'h0090     
    input           [31:0]                  i_regc5             ,//(i) 16'h0094     
    input           [31:0]                  i_regc6             ,//(i) 16'h0098     
    input           [31:0]                  i_regc7             ,//(i) 16'h009C     
    
    input           [31:0]                  i_reg0140           ,//(i) 16'h0140     
    input           [31:0]                  i_reg0144           ,//(i) 16'h0144     
    input           [31:0]                  i_reg0148           ,//(i) 16'h0148     
    input           [31:0]                  i_reg014C           ,//(i) 16'h014C     
    input           [31:0]                  i_reg0150           ,//(i) 16'h0150     
    input           [31:0]                  i_reg0154           ,//(i) 16'h0154     
    input           [31:0]                  i_reg0158           ,//(i) 16'h0158     
    input           [31:0]                  i_reg015C           ,//(i) 16'h015C     
    input           [31:0]                  i_reg0160           ,//(i) 16'h0160     
    input           [31:0]                  i_reg0164           ,//(i) 16'h0164     
    input           [31:0]                  i_reg0168           ,//(i) 16'h0168     
    input           [31:0]                  i_reg016C           ,//(i) 16'h016C     
    input           [31:0]                  i_reg0170           ,//(i) 16'h0170     
    input           [31:0]                  i_reg0174           ,//(i) 16'h0174     
    input           [31:0]                  i_reg0178           ,//(i) 16'h0178     
    input           [31:0]                  i_reg017C           ,//(i) 16'h017C     
    input           [31:0]                  i_reg0180           ,//(i) 16'h0180     
    input           [31:0]                  i_reg0184           ,//(i) 16'h0184     
    input           [31:0]                  i_reg0188           ,//(i) 16'h0188     
    input           [31:0]                  i_reg018C           ,//(i) 16'h018C     
    input           [31:0]                  i_reg0190           ,//(i) 16'h0190     
    input           [31:0]                  i_reg0194           ,//(i) 16'h0194     
    input           [31:0]                  i_reg0198           ,//(i) 16'h0198     
    input           [31:0]                  i_reg019C           ,//(i) 16'h019C     
    input           [31:0]                  i_reg01A0           ,//(i) 16'h01A0     
    input           [31:0]                  i_reg01A4           ,//(i) 16'h01A4     
    input           [31:0]                  i_reg01A8           ,//(i) 16'h01A8     
    input           [31:0]                  i_reg01AC           ,//(i) 16'h01AC     
    input           [31:0]                  i_reg01B0           ,//(i) 16'h01B0     
    input           [31:0]                  i_reg01B4           ,//(i) 16'h01B4     
    input           [31:0]                  i_reg01B8           ,//(i) 16'h01B8     
    input           [31:0]                  i_reg01BC           ,//(i) 16'h01BC     
    input           [31:0]                  i_reg01C0           ,//(i) 16'h01C0     
    input           [31:0]                  i_reg01C4           ,//(i) 16'h01C4     
    input           [31:0]                  i_reg01C8           ,//(i) 16'h01C8     
    input           [31:0]                  i_reg01CC           ,//(i) 16'h01CC     
    input           [31:0]                  i_reg01D0           ,//(i) 16'h01D0     
    input           [31:0]                  i_reg01D4           ,//(i) 16'h01D4     
    input           [31:0]                  i_reg01D8           ,//(i) 16'h01D8     
    input           [31:0]                  i_reg01DC           ,//(i) 16'h01DC     
    input           [31:0]                  i_reg01E0           ,//(i) 16'h01E0     
    input           [31:0]                  i_reg01E4           ,//(i) 16'h01E4     
    input           [31:0]                  i_reg01E8           ,//(i) 16'h01E8     
    input           [31:0]                  i_reg01EC           ,//(i) 16'h01EC     
    input           [31:0]                  i_reg01F0           ,//(i) 16'h01F0     
    input           [31:0]                  i_reg01F4           ,//(i) 16'h01F4     
    input           [31:0]                  i_reg01F8           ,//(i) 16'h01F8     
    input           [31:0]                  i_reg01FC           ,//(i) 16'h01FC     
    
    input           [31:0]                  i_reg0220           ,//(i) 16'h0240     
    input           [31:0]                  i_reg0224           ,//(i) 16'h0244     
    input           [31:0]                  i_reg0228           ,//(i) 16'h0248     
    input           [31:0]                  i_reg022C           ,//(i) 16'h024C     
    input           [31:0]                  i_reg0230           ,//(i) 16'h0250     
    input           [31:0]                  i_reg0234           ,//(i) 16'h0254     
    input           [31:0]                  i_reg0238           ,//(i) 16'h0258     
    input           [31:0]                  i_reg023C           ,//(i) 16'h025C     
    input           [31:0]                  i_reg0240           ,//(i) 16'h0240     
    input           [31:0]                  i_reg0244           ,//(i) 16'h0244     
    input           [31:0]                  i_reg0248           ,//(i) 16'h0248     
    input           [31:0]                  i_reg024C           ,//(i) 16'h024C     
    input           [31:0]                  i_reg0250           ,//(i) 16'h0250     
    input           [31:0]                  i_reg0254           ,//(i) 16'h0254     
    input           [31:0]                  i_reg0258           ,//(i) 16'h0258     
    input           [31:0]                  i_reg025C           ,//(i) 16'h025C     
    input           [31:0]                  i_reg0260           ,//(i) 16'h0260     
    input           [31:0]                  i_reg0264           ,//(i) 16'h0264     
    input           [31:0]                  i_reg0268           ,//(i) 16'h0268     
    input           [31:0]                  i_reg026C           ,//(i) 16'h026C     
    input           [31:0]                  i_reg0270           ,//(i) 16'h0270     
    input           [31:0]                  i_reg0274           ,//(i) 16'h0274     
    input           [31:0]                  i_reg0278           ,//(i) 16'h0278     
    input           [31:0]                  i_reg027C           ,//(i) 16'h027C     
    input           [31:0]                  i_reg0280           ,//(i) 16'h0280     
    input           [31:0]                  i_reg0284           ,//(i) 16'h0284     
    input           [31:0]                  i_reg0288           ,//(i) 16'h0288     
    input           [31:0]                  i_reg028C           ,//(i) 16'h028C     
    input           [31:0]                  i_reg0290           ,//(i) 16'h0290     
    input           [31:0]                  i_reg0294           ,//(i) 16'h0294     
    input           [31:0]                  i_reg0298           ,//(i) 16'h0298     
    input           [31:0]                  i_reg029C           ,//(i) 16'h029C     
    
    output  reg     [31:0]                  o_rega0             ,//(o) 16'h00A0     
    output  reg     [31:0]                  o_rega1             ,//(o) 16'h00A4     
    output  reg     [31:0]                  o_rega2             ,//(o) 16'h00A8     
    output  reg     [31:0]                  o_rega3             ,//(o) 16'h00AC     
    output  reg     [31:0]                  o_rega4             ,//(o) 16'h00B0     
    output  reg     [31:0]                  o_rega5             ,//(o) 16'h00B4     
    output  reg     [31:0]                  o_rega6             ,//(o) 16'h00B8     
    output  reg     [31:0]                  o_rega7             ,//(o) 16'h00BC     
    output  reg     [31:0]                  o_regb0             ,//(o) 16'h00C0     
    output  reg     [31:0]                  o_regb1             ,//(o) 16'h00C4     
    output  reg     [31:0]                  o_regb2             ,//(o) 16'h00C8     
    output  reg     [31:0]                  o_regb3             ,//(o) 16'h00CC     
    output  reg     [31:0]                  o_regb4             ,//(o) 16'h00D0     
    output  reg     [31:0]                  o_regb5             ,//(o) 16'h00D4     
    output  reg     [31:0]                  o_regb6             ,//(o) 16'h00D8     
    output  reg     [31:0]                  o_regb7             ,//(o) 16'h00DC     
    output  reg     [31:0]                  o_regc0             ,//(o) 16'h00E0     
    output  reg     [31:0]                  o_regc1             ,//(o) 16'h00E4     
    output  reg     [31:0]                  o_regc2             ,//(o) 16'h00E8     
    output  reg     [31:0]                  o_regc3             ,//(o) 16'h00EC     
    output  reg     [31:0]                  o_regc4             ,//(o) 16'h00F0     
    output  reg     [31:0]                  o_regc5             ,//(o) 16'h00F4     
    output  reg     [31:0]                  o_regc6             ,//(o) 16'h00F8     
    output  reg     [31:0]                  o_regc7             ,//(o) 16'h00FC     
    
    output  reg                             ad5674_trig         ,//(o) 16'h00CC WR
    output  reg                             hv_en               ,//(o) 16'h0020
    output  reg                             hv_pmt_trig         ,//(o) 16'h001C WR
    output  reg     [31:0]                  hv_pmt_data         ,//(o) 16'h001C

    output  wire                            debug_info
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>






//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [31:0]                      rw_test0             ;
reg     [31:0]                      rw_test1             ;

reg                                 slave_rd_vld_r  = 'd0;
reg     [DATA_WIDTH-1:0]            slave_rd_data_r = 'd0;
assign   slave_rd_vld_o      =      slave_rd_vld_r       ;
assign   slave_rd_data_o     =      slave_rd_data_r      ;

reg                                 adc_lock_d1    =   0 ;
reg                                 adc_lock_d2    =   0 ;
reg                                 adc_lock_d3    =   0 ;
reg                                 eds_lock_d1    =   0 ;
reg                                 eds_lock_d2    =   0 ;
reg                                 eds_lock_d3    =   0 ;
reg                                 fbc_lock_d1    =   0 ;
reg                                 fbc_lock_d2    =   0 ;
reg                                 fbc_lock_d3    =   0 ;


reg     [31:0]                      i_reg0320      =   0 ;//(i) 16'h0340     
reg     [31:0]                      i_reg0324      =   0 ;//(i) 16'h0344     
reg     [31:0]                      i_reg0328      =   0 ;//(i) 16'h0348     
reg     [31:0]                      i_reg032C      =   0 ;//(i) 16'h034C     
reg     [31:0]                      i_reg0330      =   0 ;//(i) 16'h0350     
reg     [31:0]                      i_reg0334      =   0 ;//(i) 16'h0354     
reg     [31:0]                      i_reg0338      =   0 ;//(i) 16'h0358     
reg     [31:0]                      i_reg033C      =   0 ;//(i) 16'h035C     
reg     [31:0]                      i_reg0340      =   0 ;//(i) 16'h0340     
reg     [31:0]                      i_reg0344      =   0 ;//(i) 16'h0344     
reg     [31:0]                      i_reg0348      =   0 ;//(i) 16'h0348     
reg     [31:0]                      i_reg034C      =   0 ;//(i) 16'h034C     
reg     [31:0]                      i_reg0350      =   0 ;//(i) 16'h0350     
reg     [31:0]                      i_reg0354      =   0 ;//(i) 16'h0354     
reg     [31:0]                      i_reg0358      =   0 ;//(i) 16'h0358     
reg     [31:0]                      i_reg035C      =   0 ;//(i) 16'h035C     
reg     [31:0]                      i_reg0360      =   0 ;//(i) 16'h0360     
reg     [31:0]                      i_reg0364      =   0 ;//(i) 16'h0364     
reg     [31:0]                      i_reg0368      =   0 ;//(i) 16'h0368     
reg     [31:0]                      i_reg036C      =   0 ;//(i) 16'h036C     
reg     [31:0]                      i_reg0370      =   0 ;//(i) 16'h0370     
reg     [31:0]                      i_reg0374      =   0 ;//(i) 16'h0374     
reg     [31:0]                      i_reg0378      =   0 ;//(i) 16'h0378     
reg     [31:0]                      i_reg037C      =   0 ;//(i) 16'h037C     
reg     [31:0]                      i_reg0380      =   0 ;//(i) 16'h0380     
reg     [31:0]                      i_reg0384      =   0 ;//(i) 16'h0384     
reg     [31:0]                      i_reg0388      =   0 ;//(i) 16'h0388     
reg     [31:0]                      i_reg038C      =   0 ;//(i) 16'h038C     
reg     [31:0]                      i_reg0390      =   0 ;//(i) 16'h0390     
reg     [31:0]                      i_reg0394      =   0 ;//(i) 16'h0394     
reg     [31:0]                      i_reg0398      =   0 ;//(i) 16'h0398     
reg     [31:0]                      i_reg039C      =   0 ;//(i) 16'h039C     
reg     [31:0]                      i_reg03A0      =   0 ;//(i) 16'h03A0     
reg     [31:0]                      i_reg03A4      =   0 ;//(i) 16'h03A4     
reg     [31:0]                      i_reg03A8      =   0 ;//(i) 16'h03A8     
reg     [31:0]                      i_reg03AC      =   0 ;//(i) 16'h03AC     
reg     [31:0]                      i_reg03B0      =   0 ;//(i) 16'h03B0     
reg     [31:0]                      i_reg03B4      =   0 ;//(i) 16'h03B4     
reg     [31:0]                      i_reg03B8      =   0 ;//(i) 16'h03B8     
reg     [31:0]                      i_reg03BC      =   0 ;//(i) 16'h03BC     

wire    [31:0]                      eds_pos_cnt          ;
wire    [31:0]                      fbc_pos_cnt          ;
wire    [31:0]                      adc_pos_cnt          ;
//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// write register
always @(posedge clk_i) begin
    if(rst_i)begin
        rw_test0        <=  32'hAAAA_5555;
        rw_test1        <=  32'hFFFF_0000;
        o_rega0         <=  32'h0        ;//pkt_gen_trig     
        o_rega1         <=  32'h0000_0000;//pkt_gen_mode     
        o_rega2         <=  32'h0000_0000;//aurora_cfg       
        o_rega3         <=  32'h0        ;
        o_rega4         <=  32'h0000_0001;//16'h00B0     
        o_rega5         <=  32'h0        ;
        o_rega6         <=  32'h0        ;
        o_rega7         <=  32'h0        ;
        o_regb0         <=  32'd0        ;//cfg_acc_en    //16'h00C0
        o_regb1         <=  32'h0100     ;//acc_zoom_coe  //16'h00C4
        o_regb2         <=  32'h0        ;
        o_regb3         <=  32'h0        ;
        o_regb4         <=  32'h0        ;
        o_regb5         <=  32'h0        ;
        o_regb6         <=  32'h0        ;
        o_regb7         <=  32'h0        ;
        o_regc0         <=  32'h0        ;
        o_regc1         <=  32'h0        ;
        o_regc2         <=  32'h0        ;
        o_regc3         <=  32'h0        ;
        o_regc4         <=  32'h0        ;
        o_regc5         <=  32'h0        ;
        o_regc6         <=  32'h0        ;
        o_regc7         <=  32'h0        ;
        
        hv_pmt_data     <=  32'h0        ;
        hv_en           <=  32'h0        ;

    end else if(slave_wr_en_i)begin
        case (slave_addr_i)
            16'h0008    :   rw_test0      <= slave_wr_data_i     ; 
            16'h000C    :   rw_test1      <= slave_wr_data_i     ;
            
            16'h001C    :   hv_pmt_data   <= slave_wr_data_i     ;
            16'h0020    :   hv_en         <= slave_wr_data_i     ;

            16'h00A0    :   o_rega0       <= slave_wr_data_i     ; 
            16'h00A4    :   o_rega1       <= slave_wr_data_i     ; 
            16'h00A8    :   o_rega2       <= slave_wr_data_i     ; 
            16'h00AC    :   o_rega3       <= slave_wr_data_i     ;
            16'h00B0    :   o_rega4       <= slave_wr_data_i     ;
            16'h00B4    :   o_rega5       <= slave_wr_data_i     ;
            16'h00B8    :   o_rega6       <= slave_wr_data_i     ;
            16'h00BC    :   o_rega7       <= slave_wr_data_i     ;
            16'h00C0    :   o_regb0       <= slave_wr_data_i     ;
            16'h00C4    :   o_regb1       <= slave_wr_data_i     ;
            16'h00C8    :   o_regb2       <= slave_wr_data_i     ;
            16'h00CC    :   o_regb3       <= slave_wr_data_i     ;
            16'h00D0    :   o_regb4       <= slave_wr_data_i     ;
            16'h00D4    :   o_regb5       <= slave_wr_data_i     ;
            16'h00D8    :   o_regb6       <= slave_wr_data_i     ;
            16'h00DC    :   o_regb7       <= slave_wr_data_i     ;
            16'h00E0    :   o_regc0       <= slave_wr_data_i     ;
            16'h00E4    :   o_regc1       <= slave_wr_data_i     ;
            16'h00E8    :   o_regc2       <= slave_wr_data_i     ;
            16'h00EC    :   o_regc3       <= slave_wr_data_i     ;
            16'h00F0    :   o_regc4       <= slave_wr_data_i     ;
            16'h00F4    :   o_regc5       <= slave_wr_data_i     ;
            16'h00F8    :   o_regc6       <= slave_wr_data_i     ;
            16'h00FC    :   o_regc7       <= slave_wr_data_i     ;
            default: /*default*/;
        endcase
    end
end



// read register
always @(posedge clk_i) begin
    if(slave_rd_en_i)begin
        case (slave_addr_i)
            16'h0000: slave_rd_data_r <= 32'h2024_1001   ;
            16'h0004: slave_rd_data_r <= 32'hA032_0002   ;
            16'h0008: slave_rd_data_r <= rw_test0        ;
            16'h000C: slave_rd_data_r <= rw_test1        ;


            16'h001C: slave_rd_data_r <= hv_pmt_data     ;
            16'h0020: slave_rd_data_r <= hv_en           ;


            16'h0040: slave_rd_data_r <= i_rega0         ;// 32'h1234_ABCD                  
            16'h0044: slave_rd_data_r <= i_rega1         ;// enc_sop_eop_clr_cnt            
            16'h0048: slave_rd_data_r <= i_rega2         ;// enc_vld_cnt                    
            16'h004C: slave_rd_data_r <= i_rega3         ;// 32'h1234_ABCD                  
            16'h0050: slave_rd_data_r <= i_rega4         ;// eds_fifo_full_cnt              
            16'h0054: slave_rd_data_r <= i_rega5         ;// eds_sop_eop_clr_cnt            
            16'h0058: slave_rd_data_r <= i_rega6         ;// eds_vld_cnt                    
            16'h005C: slave_rd_data_r <= i_rega7         ;// adc_pkt_sop_eop_cnt            
            16'h0060: slave_rd_data_r <= i_regb0         ;// adc_fifo_full_cnt              
            16'h0064: slave_rd_data_r <= i_regb1         ;// track_num                      
            16'h0068: slave_rd_data_r <= i_regb2         ;// aurora_sts                     
            16'h006C: slave_rd_data_r <= i_regb3         ;// aurora_soft_err_cnt            
            16'h0070: slave_rd_data_r <= i_regb4         ;// tx_adc_chk_suc_cnt             
            16'h0074: slave_rd_data_r <= i_regb5         ;// tx_adc_chk_err_cnt             
            16'h0078: slave_rd_data_r <= i_regb6         ;// tx_enc_chk_suc_cnt             
            16'h007C: slave_rd_data_r <= i_regb7         ;// tx_enc_chk_err_cnt             
            16'h0080: slave_rd_data_r <= i_regc0         ;// fir_xenc_1st                   
            16'h0084: slave_rd_data_r <= i_regc1         ;// fir_wenc_1st                   
            16'h0088: slave_rd_data_r <= i_regc2         ;// fir_jp_pos_1st                 
            16'h008C: slave_rd_data_r <= i_regc3         ;// fir_jp_num                     
            16'h0090: slave_rd_data_r <= i_regc4         ;// xenc_1st                       
            16'h0094: slave_rd_data_r <= i_regc5         ;// wenc_1st                       
            16'h0098: slave_rd_data_r <= i_regc6         ;// jp_pos_1st                     
            16'h009C: slave_rd_data_r <= i_regc7         ;// jp_num                         

            16'h00A0: slave_rd_data_r <= o_rega0         ;//          
            16'h00A4: slave_rd_data_r <= o_rega1         ;//                                
            16'h00A8: slave_rd_data_r <= o_rega2         ;//                                
            16'h00AC: slave_rd_data_r <= o_rega3         ;// aurora_cfg                     
            16'h00B0: slave_rd_data_r <= o_rega4         ;// adc_ctrl0                      
            16'h00B4: slave_rd_data_r <= o_rega5         ;// adc_ctrl1                      
            16'h00B8: slave_rd_data_r <= o_rega6         ;// adc_ctrl2                      
            16'h00BC: slave_rd_data_r <= o_rega7         ;//                                
            16'h00C0: slave_rd_data_r <= o_regb0         ;// cfg_acc_en                     
            16'h00C4: slave_rd_data_r <= o_regb1         ;// acc_zoom_coe                   
            16'h00C8: slave_rd_data_r <= o_regb2         ;//                                
            16'h00CC: slave_rd_data_r <= o_regb3         ;// ad5674_cfg                     
            16'h00D0: slave_rd_data_r <= o_regb4         ;// adc_rm_num                    
            16'h00D4: slave_rd_data_r <= o_regb5         ;// enc_rm_num                    
            16'h00D8: slave_rd_data_r <= o_regb6         ;// ad5592_1_adc_config_en         
            16'h00DC: slave_rd_data_r <= o_regb7         ;// ad5592_1_adc_channel           
            16'h00E0: slave_rd_data_r <= o_regc0         ;// ad5592_1_dac_config_en         
            16'h00E4: slave_rd_data_r <= o_regc1         ;// ad5592_1_dac_channel           
            16'h00E8: slave_rd_data_r <= o_regc2         ;// ad5592_1_dac_data              
            16'h00EC: slave_rd_data_r <= o_regc3         ;// {sfpga_rst,ddr_test_en}                                
            16'h00F0: slave_rd_data_r <= o_regc4         ;// {ad7680_rd_en,temp_rd_en}      
            16'h00F4: slave_rd_data_r <= o_regc5         ;// {eeprom_r_addr_en,eeprom_w_en} 
            16'h00F8: slave_rd_data_r <= o_regc6         ;// eeprom_w_addr_data             
            16'h00FC: slave_rd_data_r <= o_regc7         ;// eeprom_r_addr                  
            
            16'h0140: slave_rd_data_r <= i_reg0140       ;// temp_data_lock                 
            16'h0144: slave_rd_data_r <= i_reg0144       ;// eeprom_r_data_lock             
            16'h0148: slave_rd_data_r <= i_reg0148       ;// ad7680_dout_lock               
            16'h014C: slave_rd_data_r <= i_reg014C       ;// ad5674_dout                    
            16'h0150: slave_rd_data_r <= i_reg0150       ;// sts_suc_cnt                    
            16'h0154: slave_rd_data_r <= i_reg0154       ;// sts_err_cnt                    
            16'h0158: slave_rd_data_r <= i_reg0158       ;// sts_err_lock                   
            16'h015C: slave_rd_data_r <= i_reg015C       ;// {ddr3_init_done,hmc7044_config_
            16'h0160: slave_rd_data_r <= i_reg0160       ;// ad5674_dout1                   
            16'h0164: slave_rd_data_r <= i_reg0164       ;// ad5674_dout2                   
            16'h0168: slave_rd_data_r <= i_reg0168       ;// 32'd0                          
            16'h016C: slave_rd_data_r <= i_reg016C       ;// 32'd0                          
            16'h0170: slave_rd_data_r <= i_reg0170       ;// 32'd0                          
            16'h0174: slave_rd_data_r <= i_reg0174       ;// 32'd0                          
            16'h0178: slave_rd_data_r <= i_reg0178       ;// 32'd0                          
            16'h017C: slave_rd_data_r <= i_reg017C       ;// 32'd0                          
            16'h0180: slave_rd_data_r <= i_reg0180       ;// adc_0_pat_err_cnt              
            16'h0184: slave_rd_data_r <= i_reg0184       ;// adc_1_pat_err_cnt              
            16'h0188: slave_rd_data_r <= i_reg0188       ;// adc_2_pat_err_cnt              
            16'h018C: slave_rd_data_r <= i_reg018C       ;// adc_3_pat_err_cnt              
            16'h0190: slave_rd_data_r <= i_reg0190       ;// adc_4_pat_err_cnt              
            16'h0194: slave_rd_data_r <= i_reg0194       ;// adc_5_pat_err_cnt              
            16'h0198: slave_rd_data_r <= i_reg0198       ;// adc_6_pat_err_cnt              
            16'h019C: slave_rd_data_r <= i_reg019C       ;// adc_7_pat_err_cnt              
            
            16'h01A0: slave_rd_data_r <= i_reg01A0      ;//(i) 16'h01A0     coe0              
            16'h01A4: slave_rd_data_r <= i_reg01A4      ;//(i) 16'h01A4     coe1              
            16'h01A8: slave_rd_data_r <= i_reg01A8      ;//(i) 16'h01A8     coe2              
            16'h01AC: slave_rd_data_r <= i_reg01AC      ;//(i) 16'h01AC     coe3              
            16'h01B0: slave_rd_data_r <= i_reg01B0      ;//(i) 16'h01B0     coe4              
            16'h01B4: slave_rd_data_r <= i_reg01B4      ;//(i) 16'h01B4     coe5              
            16'h01B8: slave_rd_data_r <= i_reg01B8      ;//(i) 16'h01B8     coe6              
            16'h01BC: slave_rd_data_r <= i_reg01BC      ;//(i) 16'h01BC     coe7              
            16'h01C0: slave_rd_data_r <= i_reg01C0      ;//(i) 16'h01C0     coe8              
            16'h01C4: slave_rd_data_r <= i_reg01C4      ;//(i) 16'h01C4     coe9              
            16'h01C8: slave_rd_data_r <= i_reg01C8      ;//(i) 16'h01C8     coe10             
            16'h01CC: slave_rd_data_r <= i_reg01CC      ;//(i) 16'h01CC     coe11             
            16'h01D0: slave_rd_data_r <= i_reg01D0      ;//(i) 16'h01D0     coe12             
            16'h01D4: slave_rd_data_r <= i_reg01D4      ;//(i) 16'h01D4     coe13             
            16'h01D8: slave_rd_data_r <= i_reg01D8      ;//(i) 16'h01D8     coe14             
            16'h01DC: slave_rd_data_r <= i_reg01DC      ;//(i) 16'h01DC     coe15             
            16'h01E0: slave_rd_data_r <= i_reg01E0      ;//(i) 16'h01E0     coe16             
            16'h01E4: slave_rd_data_r <= i_reg01E4      ;//(i) 16'h01E4     coe17             
            16'h01E8: slave_rd_data_r <= i_reg01E8      ;//(i) 16'h01E8     coe18             
            16'h01EC: slave_rd_data_r <= i_reg01EC      ;//(i) 16'h01EC     coe_dec           
            16'h01F0: slave_rd_data_r <= i_reg01F0      ;//(i) 16'h01F0     32'd0             
            16'h01F4: slave_rd_data_r <= i_reg01F4      ;//(i) 16'h01F4     32'd0             
            16'h01F8: slave_rd_data_r <= i_reg01F8      ;//(i) 16'h01F8     32'd0             
            16'h01FC: slave_rd_data_r <= i_reg01FC      ;//(i) 16'h01FC     32'd0             


            16'h0220: slave_rd_data_r <= i_reg0220       ;//last_pkt_cnt          
            16'h0224: slave_rd_data_r <= i_reg0224       ;//buff_clr_cnt          
            16'h0228: slave_rd_data_r <= i_reg0228       ;//enc_sop_eop_cnt       
            16'h022C: slave_rd_data_r <= i_reg022C       ;//eds_sop_eop_cnt       
            16'h0230: slave_rd_data_r <= i_reg0230       ;//fbc_sop_eop_cnt       
            16'h0234: slave_rd_data_r <= i_reg0234       ;//32'd0                 
            16'h0238: slave_rd_data_r <= i_reg0238       ;//32'd0                 
            16'h023C: slave_rd_data_r <= i_reg023C       ;//32'd0                 
            16'h0240: slave_rd_data_r <= i_reg0240       ;//32'd0                 
            16'h0244: slave_rd_data_r <= i_reg0244       ;//32'd0                 
            16'h0248: slave_rd_data_r <= i_reg0248       ;//32'd0                 
            16'h024C: slave_rd_data_r <= i_reg024C       ;//32'd0                 
            16'h0250: slave_rd_data_r <= i_reg0250       ;//32'd0                 
            16'h0254: slave_rd_data_r <= i_reg0254       ;//32'd0                 
            16'h0258: slave_rd_data_r <= i_reg0258       ;//32'd0                 
            16'h025C: slave_rd_data_r <= i_reg025C       ;//32'd0                 
            16'h0260: slave_rd_data_r <= i_reg0260       ;//32'd0                 
            16'h0264: slave_rd_data_r <= i_reg0264       ;//32'd0                 
            16'h0268: slave_rd_data_r <= i_reg0268       ;//32'd0                 
            16'h026C: slave_rd_data_r <= i_reg026C       ;//32'd0                 
            16'h0270: slave_rd_data_r <= i_reg0270       ;//32'd0                 
            16'h0274: slave_rd_data_r <= i_reg0274       ;//32'd0                 
            16'h0278: slave_rd_data_r <= i_reg0278       ;//32'd0                 
            16'h027C: slave_rd_data_r <= i_reg027C       ;//32'd0                 
            16'h0280: slave_rd_data_r <= i_reg0280       ;//adc_0_pat_err_cnt     
            16'h0284: slave_rd_data_r <= i_reg0284       ;//adc_1_pat_err_cnt     
            16'h0288: slave_rd_data_r <= i_reg0288       ;//adc_2_pat_err_cnt     
            16'h028C: slave_rd_data_r <= i_reg028C       ;//adc_3_pat_err_cnt     
            16'h0290: slave_rd_data_r <= i_reg0290       ;//adc_4_pat_err_cnt     
            16'h0294: slave_rd_data_r <= i_reg0294       ;//adc_5_pat_err_cnt     
            16'h0298: slave_rd_data_r <= i_reg0298       ;//adc_6_pat_err_cnt     
            16'h029C: slave_rd_data_r <= i_reg029C       ;//adc_7_pat_err_cnt     


            16'h0320: slave_rd_data_r <= i_reg0320       ;
            16'h0324: slave_rd_data_r <= i_reg0324       ;
            16'h0328: slave_rd_data_r <= i_reg0328       ;
            16'h032C: slave_rd_data_r <= i_reg032C       ;
            16'h0330: slave_rd_data_r <= i_reg0330       ;
            16'h0334: slave_rd_data_r <= i_reg0334       ;
            16'h0338: slave_rd_data_r <= i_reg0338       ;
            16'h033C: slave_rd_data_r <= i_reg033C       ;
            16'h0340: slave_rd_data_r <= i_reg0340       ;
            16'h0344: slave_rd_data_r <= i_reg0344       ;
            16'h0348: slave_rd_data_r <= i_reg0348       ;
            16'h034C: slave_rd_data_r <= i_reg034C       ;
            16'h0350: slave_rd_data_r <= i_reg0350       ;
            16'h0354: slave_rd_data_r <= i_reg0354       ;
            16'h0358: slave_rd_data_r <= i_reg0358       ;
            16'h035C: slave_rd_data_r <= i_reg035C       ;
            16'h0360: slave_rd_data_r <= i_reg0360       ;
            16'h0364: slave_rd_data_r <= i_reg0364       ;
            16'h0368: slave_rd_data_r <= i_reg0368       ;
            16'h036C: slave_rd_data_r <= i_reg036C       ;
            16'h0370: slave_rd_data_r <= i_reg0370       ;
            16'h0374: slave_rd_data_r <= i_reg0374       ;
            16'h0378: slave_rd_data_r <= i_reg0378       ;
            16'h037C: slave_rd_data_r <= i_reg037C       ;
            16'h0380: slave_rd_data_r <= i_reg0380       ;
            16'h0384: slave_rd_data_r <= i_reg0384       ;
            16'h0388: slave_rd_data_r <= i_reg0388       ;
            16'h038C: slave_rd_data_r <= i_reg038C       ;
            16'h0390: slave_rd_data_r <= i_reg0390       ;
            16'h0394: slave_rd_data_r <= i_reg0394       ;
            16'h0398: slave_rd_data_r <= i_reg0398       ;
            16'h039C: slave_rd_data_r <= i_reg039C       ;

            16'h03A0: slave_rd_data_r <= 32'd0           ;
            16'h03A4: slave_rd_data_r <= 32'd0           ;
            16'h03A8: slave_rd_data_r <= 32'd0           ;
            16'h03AC: slave_rd_data_r <= 32'd0           ;
            16'h03B0: slave_rd_data_r <= 32'd0           ;
            16'h03B4: slave_rd_data_r <= 32'd0           ;
            16'h03B8: slave_rd_data_r <= 32'd0           ;
            16'h03BC: slave_rd_data_r <= 32'd0           ;


            16'h1000: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*4 +: 32];
            16'h1004: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*3 +: 32];
            16'h1008: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*2 +: 32];
            16'h100c: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*1 +: 32];
            16'h1010: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*0 +: 32];
            
            default: /*default*/;
        endcase
    end
end



assign slave_rd_vld_o           = slave_rd_vld_r    ;
assign slave_rd_data_o          = slave_rd_data_r   ;


// use valid control delay, ability to align register with fifo output.
always @(posedge clk_i) begin
    slave_rd_vld_r <= #TCQ slave_rd_en_i;
end


//-----------------------------------------------------------------------------//

always @(posedge clk_i) begin
    if(rst_i)
        ad5674_trig <= 1'b0;
    else if(slave_wr_en_i && (slave_addr_i == 16'h00CC))
        ad5674_trig <= 1'b1;
    else 
        ad5674_trig <= 1'b0;
end


always @(posedge clk_i) begin
    if(rst_i)
        hv_pmt_trig <= 1'b0;
    else if(slave_wr_en_i && (slave_addr_i == 16'h001C))
        hv_pmt_trig <= 1'b1;
    else 
        hv_pmt_trig <= 1'b0;
end





//---------reg lock logic-----------------------------------------------//
always@(posedge clk_i)begin
    adc_lock_d1          <=   adc_lock       ;
    adc_lock_d2          <=   adc_lock_d1    ;
    adc_lock_d3          <=   adc_lock_d2    ;
    
    eds_lock_d1          <=   eds_lock       ;
    eds_lock_d2          <=   eds_lock_d1    ;
    eds_lock_d3          <=   eds_lock_d2    ;

    fbc_lock_d1          <=   fbc_lock       ;
    fbc_lock_d2          <=   fbc_lock_d1    ;
    fbc_lock_d3          <=   fbc_lock_d2    ;

end


always@(posedge clk_i)begin
    if(eds_lock_d3)begin                 
        i_reg0320    <=  i_rega4      ;//(i) 16'h03A0    eds //eds_fifo_full_cnt 
        i_reg0324    <=  i_rega5      ;//(i) 16'h03A4    eds //eds_sop_eop_cnt   
        i_reg0328    <=  i_rega6      ;//(i) 16'h03A8    eds //eds_vld_cnt       
        i_reg032C    <=  32'h00ed_00ed;//(i) 16'h03AC    eds
    end 
    
    if(fbc_lock_d3)begin                 
        i_reg0330    <=  i_rega4      ;//(i) 16'h03B0    fbc  //eds_fifo_full_cnt
        i_reg0334    <=  i_rega5      ;//(i) 16'h03B4    fbc  //eds_sop_eop_cnt  
        i_reg0338    <=  i_rega6      ;//(i) 16'h03B8    fbc  //eds_vld_cnt      
        i_reg033C    <=  32'h0fbc_0fbc;//(i) 16'h03BC    fbc 
    end 

    if(adc_lock_d3)begin                 
        i_reg0340    <=  i_rega0   ;//(i) 16'h040     //pop_clr_cnt     
        i_reg0344    <=  i_rega1   ;//(i) 16'h044     //enc_sop_eop_cnt 
        i_reg0348    <=  i_rega2   ;//(i) 16'h048     //enc_vld_cnt     
        i_reg034C    <=  i_rega3   ;//(i) 16'h04C     //32'h1234_ABCD   
    end 
        
        i_reg0350    <=  eds_pos_cnt   ;//(i) 16'h050     i_rega4
        i_reg0354    <=  fbc_pos_cnt   ;//(i) 16'h054     i_rega5
        i_reg0358    <=  adc_pos_cnt   ;//(i) 16'h058     i_rega6
        
    if(adc_lock_d3)begin 
        i_reg035C    <=  i_rega7   ;//(i) 16'h05C     //adc_pkt_sop_eop_cnt     
        i_reg0360    <=  i_regb0   ;//(i) 16'h060     //adc_fifo_full_cnt       
        i_reg0364    <=  i_regb1   ;//(i) 16'h064     //track_num               
        i_reg0368    <=  i_regb2   ;//(i) 16'h068     //aurora_sts              
        i_reg036C    <=  i_regb3   ;//(i) 16'h06C     //aurora_soft_err_cnt     
        i_reg0370    <=  i_regb4   ;//(i) 16'h070     //tx_adc_chk_suc_cnt      
        i_reg0374    <=  i_regb5   ;//(i) 16'h074     //tx_adc_chk_err_cnt      
        i_reg0378    <=  i_regb6   ;//(i) 16'h078     //tx_enc_chk_suc_cnt      
        i_reg037C    <=  i_regb7   ;//(i) 16'h07C     //tx_enc_chk_err_cnt      
        i_reg0380    <=  i_regc0   ;//(i) 16'h080     //fir_xenc_1st            
        i_reg0384    <=  i_regc1   ;//(i) 16'h084     //fir_wenc_1st            
        i_reg0388    <=  i_regc2   ;//(i) 16'h088     //fir_jp_pos_1st    --->  fir_tap_vld_cnt   
        i_reg038C    <=  i_regc3   ;//(i) 16'h08C     //fir_jp_num        --->  bias_tap_vld_cnt  
        i_reg0390    <=  i_regc4   ;//(i) 16'h090     //xenc_1st                
        i_reg0394    <=  i_regc5   ;//(i) 16'h094     //wenc_1st                
        i_reg0398    <=  i_regc6   ;//(i) 16'h098     //jp_pos_1st              
        i_reg039C    <=  i_regc7   ;//(i) 16'h09C     //jp_num                  
    end
    
    
end 



    cmip_app_cnt #(
        .width     (32                             )
    )u0_app_cnt(                                     
        .clk       (clk_i                          ),//(i)
        .rst_n     (~rst_i                         ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (~eds_lock_d2  &&  eds_lock_d3  ),//(i)
        .cnt       (eds_pos_cnt                    ) //(o)
    );

    cmip_app_cnt #(
        .width     (32                             )
    )u1_app_cnt(                                     
        .clk       (clk_i                          ),//(i)
        .rst_n     (~rst_i                         ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (~fbc_lock_d2  &&  fbc_lock_d3  ),//(i)
        .cnt       (fbc_pos_cnt                    ) //(o)
    );

    cmip_app_cnt #(
        .width     (32                             )
    )u2_app_cnt(                                     
        .clk       (clk_i                          ),//(i)
        .rst_n     (~rst_i                         ),//(i)
        .clr       (1'b0                           ),//(i)
        .vld       (~adc_lock_d2  &&  adc_lock_d3  ),//(i)
        .cnt       (adc_pos_cnt                    ) //(o)
    );



endmodule





























