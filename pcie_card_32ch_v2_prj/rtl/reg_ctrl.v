module reg_ctrl (
    // globe signal
    input                       xrst                           ,//(i) async. reset (low active)
    input                       clk                            ,//(i) clock

    // AXI-Lite slave
    input          [ 31:0]      s_axil_awaddr                  ,//(i) valid in the lower 16 bits
    input          [  2:0]      s_axil_awprot                  ,//(i)
    input                       s_axil_awvalid                 ,//(i)
    output                      s_axil_awready                 ,//(o)
    input         [ 31:0]       s_axil_wdata                   ,//(i)
    input         [  3:0]       s_axil_wstrb                   ,//(i)
    input                       s_axil_wvalid                  ,//(i)
    output                      s_axil_wready                  ,//(o)
    output        [  1:0]       s_axil_bresp                   ,//(o)
    output                      s_axil_bvalid                  ,//(o)
    input                       s_axil_bready                  ,//(i)
    input         [ 31:0]       s_axil_araddr                  ,//(i) valid in the lower 16 bits
    input         [  2:0]       s_axil_arprot                  ,//(i)
    input                       s_axil_arvalid                 ,//(i)
    output                      s_axil_arready                 ,//(o)
    output        [ 31:0]       s_axil_rdata                   ,//(o)
    output        [  1:0]       s_axil_rresp                   ,//(o)
    output                      s_axil_rvalid                  ,//(o)
    input                       s_axil_rready                  ,//(i)


    input                       pkt_end_flag                   ,//(i)
    input                       adc_end_flag                   ,//(i)
    output  reg   [ 31:0]       dbg_cnt_arr                    ,//(o)
    // User define signal
    input         [ 31:0]       i_regc0                        ,//(i) 16'h0020     
    input         [ 31:0]       i_regc1                        ,//(i) 16'h0024     
    input         [ 31:0]       i_regc2                        ,//(i) 16'h0028     
    input         [ 31:0]       i_regc3                        ,//(i) 16'h002C     
    input         [ 31:0]       i_regc4                        ,//(i) 16'h0030     
    input         [ 31:0]       i_regc5                        ,//(i) 16'h0034     
    input         [ 31:0]       i_regc6                        ,//(i) 16'h0038     
    input         [ 31:0]       i_regc7                        ,//(i) 16'h003C     
    
    input         [ 31:0]       i_regb0                        ,//(i) 16'h0040     
    input         [ 31:0]       i_regb1                        ,//(i) 16'h0044     
    input         [ 31:0]       i_regb2                        ,//(i) 16'h0048     
    input         [ 31:0]       i_regb3                        ,//(i) 16'h004C     
    input         [ 31:0]       i_regb4                        ,//(i) 16'h0050     
    input         [ 31:0]       i_regb5                        ,//(i) 16'h0054     
    input         [ 31:0]       i_regb6                        ,//(i) 16'h0058     
    input         [ 31:0]       i_regb7                        ,//(i) 16'h005C     
    
    input         [ 31:0]       i_rega0                        ,//(i) 16'h0060     
    input         [ 31:0]       i_rega1                        ,//(i) 16'h0064     
    input         [ 31:0]       i_rega2                        ,//(i) 16'h0068     
    input         [ 31:0]       i_rega3                        ,//(i) 16'h006C     
    input         [ 31:0]       i_rega4                        ,//(i) 16'h0070     
    input         [ 31:0]       i_rega5                        ,//(i) 16'h0074     
    input         [ 31:0]       i_rega6                        ,//(i) 16'h0078     
    input         [ 31:0]       i_rega7                        ,//(i) 16'h007C    
    
    input         [ 31:0]       i_reg0                         ,//(i) 16'h0080     
    input         [ 31:0]       i_reg1                         ,//(i) 16'h0084     
    input         [ 31:0]       i_reg2                         ,//(i) 16'h0088     
    input         [ 31:0]       i_reg3                         ,//(i) 16'h008C     
    input         [ 31:0]       i_reg4                         ,//(i) 16'h0090     
    input         [ 31:0]       i_reg5                         ,//(i) 16'h0094     
    input         [ 31:0]       i_reg6                         ,//(i) 16'h0098     
    input         [ 31:0]       i_reg7                         ,//(i) 16'h009C     
    output  reg   [ 31:0]       o_reg0                         ,//(o) 16'h00A0     
    output  reg   [ 31:0]       o_reg1                         ,//(o) 16'h00A4     
    output  reg   [ 31:0]       o_reg2                         ,//(o) 16'h00A8     
    output  reg   [ 31:0]       o_reg3                         ,//(o) 16'h00AC     
    output  reg   [ 31:0]       o_reg4                         ,//(o) 16'h00B0     
    output  reg   [ 31:0]       o_reg5                         ,//(o) 16'h00B4     
    output  reg   [ 31:0]       o_reg6                         ,//(o) 16'h00B8     
    output  reg   [ 31:0]       o_reg7                         ,//(o) 16'h00BC     
    output  reg   [ 31:0]       o_regb0                        ,//(o) 16'h00C0     
    output  reg   [ 31:0]       o_regb1                        ,//(o) 16'h00C4     
    output  reg   [ 31:0]       o_regb2                        ,//(o) 16'h00C8     
    output  reg   [ 31:0]       o_regb3                        ,//(o) 16'h00CC     
    output  reg   [ 31:0]       o_regb4                        ,//(o) 16'h00D0     
    output  reg   [ 31:0]       o_regb5                        ,//(o) 16'h00D4     
    output  reg   [ 31:0]       o_regb6                        ,//(o) 16'h00D8     
    output  reg   [ 31:0]       o_regb7                         //(o) 16'h00DC     
                                                                             
);

    //---------------------------------------------------------------------
    // Defination of Parameters
    //---------------------------------------------------------------------
    // Version define
    //parameter    [31:0]            P_DATE                        = 32'h2022_1011    ;

    // Address mapping table
    parameter    [15:0]            P_RTL_VERSION                 = 16'h0000          ; // version
    parameter    [15:0]            P_RTL_VERSION0                = 16'h0004          ; // version
    parameter    [15:0]            P_RTL_VERSION1                = 16'h0008          ; // version
    parameter    [15:0]            P_RTL_VERSION2                = 16'h000C          ; // version


    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    // AXI-Lite
    reg                            r_wr_addr_flag                ;
    reg                            r_wr_data_flag                ;
    reg                            r_rd_addr_flag                ;
    reg                            r_rd_data_flag                ;

    reg                            r_s_axil_bvalid               ;
    reg        [ 1:0]              r_s_axil_bresp                ;
    wire                           s_s_axil_awready              ;
    wire                           s_s_axil_wready               ;
    wire                           s_s_axil_arready              ;
    reg                            r_s_axil_rvalid               ;
    reg        [31:0]              r_s_axil_rdata                ;
    reg        [ 1:0]              r_s_axil_rresp                ;

    reg                            r_reg_wreq                    ; // register write command
    reg        [15:0]              r_reg_wadr                    ; // register write address
    reg        [31:0]              r_reg_wdat                    ; // register write data
    reg                            r_reg_rreq                    ; // register read command
    reg        [15:0]              r_reg_radr                    ; // register read address

    // register
    reg        [31:0]              r_reg_test1                   ;
    reg        [31:0]              r_reg_test2                   ;
    reg        [31:0]              r_reg_test3                   ;
    reg        [31:0]              r_reg_test4                   ;
    reg        [31:0]              r_reg_test5                   ;
    reg        [31:0]              r_reg_test6                   ;
    reg        [31:0]              r_reg_test7                   ;
    reg        [31:0]              r_reg_test8                   ;
    reg        [31:0]              r_reg_test9                   ;
    reg        [31:0]              r_reg_test10                  ;
    reg        [31:0]              r_reg_test11                  ;
    reg        [31:0]              r_reg_test12                  ;
    reg        [31:0]              r_reg_test13                  ;
    reg        [31:0]              r_reg_test14                  ;
    reg        [31:0]              r_reg_test15                  ;
    reg        [31:0]              r_reg_test16                  ;


    // ack
    reg        [31:0]                r_reg_rdat_temp0              ; // read data temp 0
    reg                              r_reg_rdvld                   ; // read data valid
    reg        [31:0]                r_reg_rdat                    ; // read data
    reg                              r_reg_wack                    ; // write data acknowledge
    reg                              r_reg_rack                    ; // read data acknowledge


    reg         [ 31:0]       i_reg0120              =   0        ;//(i) 16'h0120     
    reg         [ 31:0]       i_reg0124              =   0        ;//(i) 16'h0124     
    reg         [ 31:0]       i_reg0128              =   0        ;//(i) 16'h0128     
    reg         [ 31:0]       i_reg012C              =   0        ;//(i) 16'h012C     
    reg         [ 31:0]       i_reg0130              =   0        ;//(i) 16'h0130     
    reg         [ 31:0]       i_reg0134              =   0        ;//(i) 16'h0134     
    reg         [ 31:0]       i_reg0138              =   0        ;//(i) 16'h0138     
    reg         [ 31:0]       i_reg013C              =   0        ;//(i) 16'h013C     
    reg         [ 31:0]       i_reg0140              =   0        ;//(i) 16'h0140     
    reg         [ 31:0]       i_reg0144              =   0        ;//(i) 16'h0144     
    reg         [ 31:0]       i_reg0148              =   0        ;//(i) 16'h0148     
    reg         [ 31:0]       i_reg014C              =   0        ;//(i) 16'h014C     
    reg         [ 31:0]       i_reg0150              =   0        ;//(i) 16'h0150     
    reg         [ 31:0]       i_reg0154              =   0        ;//(i) 16'h0154     
    reg         [ 31:0]       i_reg0158              =   0        ;//(i) 16'h0158     
    reg         [ 31:0]       i_reg015C              =   0        ;//(i) 16'h015C     
    reg         [ 31:0]       i_reg0160              =   0        ;//(i) 16'h0160     
    reg         [ 31:0]       i_reg0164              =   0        ;//(i) 16'h0164     
    reg         [ 31:0]       i_reg0168              =   0        ;//(i) 16'h0168     
    reg         [ 31:0]       i_reg016C              =   0        ;//(i) 16'h016C     
    reg         [ 31:0]       i_reg0170              =   0        ;//(i) 16'h0170     
    reg         [ 31:0]       i_reg0174              =   0        ;//(i) 16'h0174     
    reg         [ 31:0]       i_reg0178              =   0        ;//(i) 16'h0178     
    reg         [ 31:0]       i_reg017C              =   0        ;//(i) 16'h017C    
    reg         [ 31:0]       i_reg0180              =   0        ;//(i) 16'h0180     
    reg         [ 31:0]       i_reg0184              =   0        ;//(i) 16'h0184     
    reg         [ 31:0]       i_reg0188              =   0        ;//(i) 16'h0188     
    reg         [ 31:0]       i_reg018C              =   0        ;//(i) 16'h018C     
    reg         [ 31:0]       i_reg0190              =   0        ;//(i) 16'h0190     
    reg         [ 31:0]       i_reg0194              =   0        ;//(i) 16'h0194     
    reg         [ 31:0]       i_reg0198              =   0        ;//(i) 16'h0198     
    reg         [ 31:0]       i_reg019C              =   0        ;//(i) 16'h019C     



    reg                       pkt_end_flag_d1        =   0        ;
    reg                       pkt_end_flag_d2        =   0        ;
    reg                       adc_end_flag_d1        =   0        ;
    reg                       adc_end_flag_d2        =   0        ;

    reg         [  2:0]       dbg_cnt                             ;            
    //reg         [ 31:0]       dbg_cnt_arr            =   0        ;
    reg [31:0] i_reg0220 = 0 ; reg [31:0] i_reg0320 = 0 ; reg [31:0] i_reg0420 = 0 ; reg [31:0] i_reg0520 = 0 ; 
    reg [31:0] i_reg0224 = 0 ; reg [31:0] i_reg0324 = 0 ; reg [31:0] i_reg0424 = 0 ; reg [31:0] i_reg0524 = 0 ; 
    reg [31:0] i_reg0228 = 0 ; reg [31:0] i_reg0328 = 0 ; reg [31:0] i_reg0428 = 0 ; reg [31:0] i_reg0528 = 0 ; 
    reg [31:0] i_reg022C = 0 ; reg [31:0] i_reg032C = 0 ; reg [31:0] i_reg042C = 0 ; reg [31:0] i_reg052C = 0 ; 
    reg [31:0] i_reg0230 = 0 ; reg [31:0] i_reg0330 = 0 ; reg [31:0] i_reg0430 = 0 ; reg [31:0] i_reg0530 = 0 ; 
    reg [31:0] i_reg0234 = 0 ; reg [31:0] i_reg0334 = 0 ; reg [31:0] i_reg0434 = 0 ; reg [31:0] i_reg0534 = 0 ; 
    reg [31:0] i_reg0238 = 0 ; reg [31:0] i_reg0338 = 0 ; reg [31:0] i_reg0438 = 0 ; reg [31:0] i_reg0538 = 0 ; 
    reg [31:0] i_reg023C = 0 ; reg [31:0] i_reg033C = 0 ; reg [31:0] i_reg043C = 0 ; reg [31:0] i_reg053C = 0 ; 
    reg [31:0] i_reg0240 = 0 ; reg [31:0] i_reg0340 = 0 ; reg [31:0] i_reg0440 = 0 ; reg [31:0] i_reg0540 = 0 ; 
    reg [31:0] i_reg0244 = 0 ; reg [31:0] i_reg0344 = 0 ; reg [31:0] i_reg0444 = 0 ; reg [31:0] i_reg0544 = 0 ; 
    reg [31:0] i_reg0248 = 0 ; reg [31:0] i_reg0348 = 0 ; reg [31:0] i_reg0448 = 0 ; reg [31:0] i_reg0548 = 0 ; 
    reg [31:0] i_reg024C = 0 ; reg [31:0] i_reg034C = 0 ; reg [31:0] i_reg044C = 0 ; reg [31:0] i_reg054C = 0 ; 
    reg [31:0] i_reg0250 = 0 ; reg [31:0] i_reg0350 = 0 ; reg [31:0] i_reg0450 = 0 ; reg [31:0] i_reg0550 = 0 ; 
    reg [31:0] i_reg0254 = 0 ; reg [31:0] i_reg0354 = 0 ; reg [31:0] i_reg0454 = 0 ; reg [31:0] i_reg0554 = 0 ; 
    reg [31:0] i_reg0258 = 0 ; reg [31:0] i_reg0358 = 0 ; reg [31:0] i_reg0458 = 0 ; reg [31:0] i_reg0558 = 0 ; 
    reg [31:0] i_reg025C = 0 ; reg [31:0] i_reg035C = 0 ; reg [31:0] i_reg045C = 0 ; reg [31:0] i_reg055C = 0 ; 
    reg [31:0] i_reg0260 = 0 ; reg [31:0] i_reg0360 = 0 ; reg [31:0] i_reg0460 = 0 ; reg [31:0] i_reg0560 = 0 ; 
    reg [31:0] i_reg0264 = 0 ; reg [31:0] i_reg0364 = 0 ; reg [31:0] i_reg0464 = 0 ; reg [31:0] i_reg0564 = 0 ; 
    reg [31:0] i_reg0268 = 0 ; reg [31:0] i_reg0368 = 0 ; reg [31:0] i_reg0468 = 0 ; reg [31:0] i_reg0568 = 0 ; 
    reg [31:0] i_reg026C = 0 ; reg [31:0] i_reg036C = 0 ; reg [31:0] i_reg046C = 0 ; reg [31:0] i_reg056C = 0 ; 
    reg [31:0] i_reg0270 = 0 ; reg [31:0] i_reg0370 = 0 ; reg [31:0] i_reg0470 = 0 ; reg [31:0] i_reg0570 = 0 ; 
    reg [31:0] i_reg0274 = 0 ; reg [31:0] i_reg0374 = 0 ; reg [31:0] i_reg0474 = 0 ; reg [31:0] i_reg0574 = 0 ; 
    reg [31:0] i_reg0278 = 0 ; reg [31:0] i_reg0378 = 0 ; reg [31:0] i_reg0478 = 0 ; reg [31:0] i_reg0578 = 0 ; 
    reg [31:0] i_reg027C = 0 ; reg [31:0] i_reg037C = 0 ; reg [31:0] i_reg047C = 0 ; reg [31:0] i_reg057C = 0 ; 
    reg [31:0] i_reg0280 = 0 ; reg [31:0] i_reg0380 = 0 ; reg [31:0] i_reg0480 = 0 ; reg [31:0] i_reg0580 = 0 ; 
    reg [31:0] i_reg0284 = 0 ; reg [31:0] i_reg0384 = 0 ; reg [31:0] i_reg0484 = 0 ; reg [31:0] i_reg0584 = 0 ; 
    reg [31:0] i_reg0288 = 0 ; reg [31:0] i_reg0388 = 0 ; reg [31:0] i_reg0488 = 0 ; reg [31:0] i_reg0588 = 0 ; 
    reg [31:0] i_reg028C = 0 ; reg [31:0] i_reg038C = 0 ; reg [31:0] i_reg048C = 0 ; reg [31:0] i_reg058C = 0 ; 
    reg [31:0] i_reg0290 = 0 ; reg [31:0] i_reg0390 = 0 ; reg [31:0] i_reg0490 = 0 ; reg [31:0] i_reg0590 = 0 ; 
    reg [31:0] i_reg0294 = 0 ; reg [31:0] i_reg0394 = 0 ; reg [31:0] i_reg0494 = 0 ; reg [31:0] i_reg0594 = 0 ; 
    reg [31:0] i_reg0298 = 0 ; reg [31:0] i_reg0398 = 0 ; reg [31:0] i_reg0498 = 0 ; reg [31:0] i_reg0598 = 0 ; 
    reg [31:0] i_reg029C = 0 ; reg [31:0] i_reg039C = 0 ; reg [31:0] i_reg049C = 0 ; reg [31:0] i_reg059C = 0 ; 

    reg [31:0] i_reg0620 = 0 ; reg [31:0] i_reg0720 = 0 ; reg [31:0] i_reg0820 = 0 ; reg [31:0] i_reg0920 = 0 ; 
    reg [31:0] i_reg0624 = 0 ; reg [31:0] i_reg0724 = 0 ; reg [31:0] i_reg0824 = 0 ; reg [31:0] i_reg0924 = 0 ; 
    reg [31:0] i_reg0628 = 0 ; reg [31:0] i_reg0728 = 0 ; reg [31:0] i_reg0828 = 0 ; reg [31:0] i_reg0928 = 0 ; 
    reg [31:0] i_reg062C = 0 ; reg [31:0] i_reg072C = 0 ; reg [31:0] i_reg082C = 0 ; reg [31:0] i_reg092C = 0 ; 
    reg [31:0] i_reg0630 = 0 ; reg [31:0] i_reg0730 = 0 ; reg [31:0] i_reg0830 = 0 ; reg [31:0] i_reg0930 = 0 ; 
    reg [31:0] i_reg0634 = 0 ; reg [31:0] i_reg0734 = 0 ; reg [31:0] i_reg0834 = 0 ; reg [31:0] i_reg0934 = 0 ; 
    reg [31:0] i_reg0638 = 0 ; reg [31:0] i_reg0738 = 0 ; reg [31:0] i_reg0838 = 0 ; reg [31:0] i_reg0938 = 0 ; 
    reg [31:0] i_reg063C = 0 ; reg [31:0] i_reg073C = 0 ; reg [31:0] i_reg083C = 0 ; reg [31:0] i_reg093C = 0 ; 
    reg [31:0] i_reg0640 = 0 ; reg [31:0] i_reg0740 = 0 ; reg [31:0] i_reg0840 = 0 ; reg [31:0] i_reg0940 = 0 ; 
    reg [31:0] i_reg0644 = 0 ; reg [31:0] i_reg0744 = 0 ; reg [31:0] i_reg0844 = 0 ; reg [31:0] i_reg0944 = 0 ; 
    reg [31:0] i_reg0648 = 0 ; reg [31:0] i_reg0748 = 0 ; reg [31:0] i_reg0848 = 0 ; reg [31:0] i_reg0948 = 0 ; 
    reg [31:0] i_reg064C = 0 ; reg [31:0] i_reg074C = 0 ; reg [31:0] i_reg084C = 0 ; reg [31:0] i_reg094C = 0 ; 
    reg [31:0] i_reg0650 = 0 ; reg [31:0] i_reg0750 = 0 ; reg [31:0] i_reg0850 = 0 ; reg [31:0] i_reg0950 = 0 ; 
    reg [31:0] i_reg0654 = 0 ; reg [31:0] i_reg0754 = 0 ; reg [31:0] i_reg0854 = 0 ; reg [31:0] i_reg0954 = 0 ; 
    reg [31:0] i_reg0658 = 0 ; reg [31:0] i_reg0758 = 0 ; reg [31:0] i_reg0858 = 0 ; reg [31:0] i_reg0958 = 0 ; 
    reg [31:0] i_reg065C = 0 ; reg [31:0] i_reg075C = 0 ; reg [31:0] i_reg085C = 0 ; reg [31:0] i_reg095C = 0 ; 
    reg [31:0] i_reg0660 = 0 ; reg [31:0] i_reg0760 = 0 ; reg [31:0] i_reg0860 = 0 ; reg [31:0] i_reg0960 = 0 ; 
    reg [31:0] i_reg0664 = 0 ; reg [31:0] i_reg0764 = 0 ; reg [31:0] i_reg0864 = 0 ; reg [31:0] i_reg0964 = 0 ; 
    reg [31:0] i_reg0668 = 0 ; reg [31:0] i_reg0768 = 0 ; reg [31:0] i_reg0868 = 0 ; reg [31:0] i_reg0968 = 0 ; 
    reg [31:0] i_reg066C = 0 ; reg [31:0] i_reg076C = 0 ; reg [31:0] i_reg086C = 0 ; reg [31:0] i_reg096C = 0 ; 
    reg [31:0] i_reg0670 = 0 ; reg [31:0] i_reg0770 = 0 ; reg [31:0] i_reg0870 = 0 ; reg [31:0] i_reg0970 = 0 ; 
    reg [31:0] i_reg0674 = 0 ; reg [31:0] i_reg0774 = 0 ; reg [31:0] i_reg0874 = 0 ; reg [31:0] i_reg0974 = 0 ; 
    reg [31:0] i_reg0678 = 0 ; reg [31:0] i_reg0778 = 0 ; reg [31:0] i_reg0878 = 0 ; reg [31:0] i_reg0978 = 0 ; 
    reg [31:0] i_reg067C = 0 ; reg [31:0] i_reg077C = 0 ; reg [31:0] i_reg087C = 0 ; reg [31:0] i_reg097C = 0 ; 
    reg [31:0] i_reg0680 = 0 ; reg [31:0] i_reg0780 = 0 ; reg [31:0] i_reg0880 = 0 ; reg [31:0] i_reg0980 = 0 ; 
    reg [31:0] i_reg0684 = 0 ; reg [31:0] i_reg0784 = 0 ; reg [31:0] i_reg0884 = 0 ; reg [31:0] i_reg0984 = 0 ; 
    reg [31:0] i_reg0688 = 0 ; reg [31:0] i_reg0788 = 0 ; reg [31:0] i_reg0888 = 0 ; reg [31:0] i_reg0988 = 0 ; 
    reg [31:0] i_reg068C = 0 ; reg [31:0] i_reg078C = 0 ; reg [31:0] i_reg088C = 0 ; reg [31:0] i_reg098C = 0 ; 
    reg [31:0] i_reg0690 = 0 ; reg [31:0] i_reg0790 = 0 ; reg [31:0] i_reg0890 = 0 ; reg [31:0] i_reg0990 = 0 ; 
    reg [31:0] i_reg0694 = 0 ; reg [31:0] i_reg0794 = 0 ; reg [31:0] i_reg0894 = 0 ; reg [31:0] i_reg0994 = 0 ; 
    reg [31:0] i_reg0698 = 0 ; reg [31:0] i_reg0798 = 0 ; reg [31:0] i_reg0898 = 0 ; reg [31:0] i_reg0998 = 0 ; 
    reg [31:0] i_reg069C = 0 ; reg [31:0] i_reg079C = 0 ; reg [31:0] i_reg089C = 0 ; reg [31:0] i_reg099C = 0 ; 




// =============================================================================
// RTL Body
// =============================================================================

    //---------------------------------------------------------------------
    // register output
    //---------------------------------------------------------------------




    //---------------------------------------------------------------------
    // AXI-Lite
    //---------------------------------------------------------------------
    // write
    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_wr_addr_flag    <= 1'b0 ;
        end else begin
            if ( s_axil_awvalid   == 1'b1 && r_wr_addr_flag == 1'b0 && r_s_axil_bvalid == 1'b0 ) begin
                r_wr_addr_flag    <= 1'b1 ;
            end else if ( r_wr_addr_flag == 1'b1 && r_wr_data_flag == 1'b1 ) begin
                r_wr_addr_flag    <= 1'b0 ;
            end
        end
    end

    assign s_s_axil_awready    = ( s_axil_awvalid   == 1'b1 && r_wr_addr_flag == 1'b0 && r_s_axil_bvalid == 1'b0 ) ? 1'b1 : 1'b0 ;

    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_wr_data_flag    <= 1'b0 ;
        end else begin
            if ( s_axil_wvalid == 1'b1 && r_wr_data_flag == 1'b0 && r_s_axil_bvalid == 1'b0 ) begin
                r_wr_data_flag    <= 1'b1 ;
            end else if ( r_wr_addr_flag == 1'b1 && r_wr_data_flag == 1'b1 ) begin
                r_wr_data_flag    <= 1'b0 ;
            end
        end
    end

    assign s_s_axil_wready    = ( s_axil_wvalid == 1'b1 && r_wr_data_flag == 1'b0 && r_s_axil_bvalid == 1'b0 ) ? 1'b1 : 1'b0 ;

    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_s_axil_bvalid    <= 1'b0 ;
            r_s_axil_bresp    <= 2'b0 ;
        end else begin
            if ( r_wr_addr_flag == 1'b1 && r_wr_data_flag == 1'b1 ) begin
                r_s_axil_bvalid    <= 1'b1 ;
                r_s_axil_bresp    <= 2'b00 ;
            end else if ( r_s_axil_bvalid == 1'b1 && s_axil_bready == 1'b1 ) begin
                r_s_axil_bvalid    <= 1'b0 ;
            end
        end
    end

    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_reg_wreq <= 1'b0 ;
            r_reg_wadr <= 16'b0 ;
            r_reg_wdat <= 32'b0 ;
        end else begin
            if ( r_wr_addr_flag == 1'b1 && r_wr_data_flag == 1'b1 ) begin
                r_reg_wreq <= 1'b1 ;
            end else begin
                r_reg_wreq <= 1'b0 ;
            end

            if ( s_axil_awvalid == 1'b1 && s_s_axil_awready == 1'b1 ) begin
                r_reg_wadr    <= s_axil_awaddr [15:0] ;
            end

            if ( s_axil_wvalid == 1'b1 && s_s_axil_wready == 1'b1 ) begin
                r_reg_wdat    <= s_axil_wdata ;
            end
        end
    end

    // read
    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_rd_addr_flag    <= 1'b0 ;
        end else begin
            if ( s_axil_arvalid == 1'b1 && r_rd_addr_flag == 1'b0 && r_rd_data_flag == 1'b0 ) begin
                r_rd_addr_flag    <= 1'b1 ;
            end else if ( r_rd_addr_flag == 1'b1 ) begin
                r_rd_addr_flag    <= 1'b0 ;
            end
        end
    end

    assign s_s_axil_arready = ( s_axil_arvalid == 1'b1 && r_rd_addr_flag == 1'b0 && r_rd_data_flag == 1'b0 ) ? 1'b1 : 1'b0 ;

    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_reg_rreq <= 1'b0 ;
            r_reg_radr <= 16'b0 ;
        end else begin
            if ( r_rd_addr_flag == 1'b1 ) begin
                r_reg_rreq <= 1'b1 ;
            end else begin
                r_reg_rreq <= 1'b0 ;
            end

            if ( s_axil_arvalid == 1'b1 && s_s_axil_arready == 1'b1 ) begin
                r_reg_radr    <= s_axil_araddr[15:0] ;
            end
        end
    end

    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_rd_data_flag    <= 1'b0 ;
        end else begin
            if ( r_rd_addr_flag == 1'b1 ) begin
                r_rd_data_flag    <= 1'b1 ;
            end else if ( r_s_axil_rvalid == 1'b1 && s_axil_rready == 1'b1 ) begin
                r_rd_data_flag    <= 1'b0 ;
            end
        end
    end

    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_s_axil_rvalid    <= 1'b0 ;
            r_s_axil_rdata    <= 32'b0 ;
            r_s_axil_rresp    <= 2'b0 ;
        end else begin
            if ( r_rd_data_flag == 1'b1 && r_reg_rack == 1'b1 ) begin
                r_s_axil_rvalid    <= 1'b1 ;
            end else if ( r_s_axil_rvalid == 1'b1 && s_axil_rready == 1'b1 ) begin
                r_s_axil_rvalid    <= 1'b0 ;
            end

            if ( r_reg_rack == 1'b1 ) begin
                r_s_axil_rdata    <= r_reg_rdat ;
            end
        end
    end

    // IF
    assign s_axil_awready      = s_s_axil_awready      ;
    assign s_axil_wready       = s_s_axil_wready       ;
    assign s_axil_bresp        = r_s_axil_bresp        ;
    assign s_axil_bvalid       = r_s_axil_bvalid       ;
    assign s_axil_arready      = s_s_axil_arready      ;
    assign s_axil_rdata        = r_s_axil_rdata        ;
    assign s_axil_rresp        = r_s_axil_rresp        ;
    assign s_axil_rvalid       = r_s_axil_rvalid       ;

    //---------------------------------------------------------------------
    // register write
    //---------------------------------------------------------------------
    // Test register
    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            o_reg0             <= 32'd0         ;
            o_reg1             <= 32'd0         ;
            o_reg2             <= 32'h00000002  ;//00A8 cfg_irq_clr_cnt
            o_reg3             <= 32'h0000000C  ;//00AC sfp_disable
            o_reg4             <= 32'd0         ; 
            o_reg5             <= 32'd0         ;
            o_reg6             <= 32'd0         ;
            o_reg7             <= 32'd0         ;

            o_regb0           <= 32'h100        ;//len
            o_regb1           <= 32'd3          ;//mode
            o_regb2           <= 32'h0          ;//trig
            o_regb3           <= 32'h4          ;//times 
            o_regb4           <= 32'h0000_0000  ; 
            o_regb5           <= 32'd0          ;
            o_regb6           <= 32'd0          ;//100k 64M  32'd6710886
            o_regb7           <= 32'd0          ;//50k  64M  32'd3355443

        end else begin
            if ( r_reg_wreq == 1'b1 ) begin
                case ( r_reg_wadr )
                
                    16'h00A0    :   o_reg0             <= r_reg_wdat           ;
                    16'h00A4    :   o_reg1             <= r_reg_wdat           ;
                    16'h00A8    :   o_reg2             <= r_reg_wdat           ;
                    16'h00AC    :   o_reg3             <= r_reg_wdat           ;
                    16'h00B0    :   o_reg4             <= r_reg_wdat           ;
                    16'h00B4    :   o_reg5             <= r_reg_wdat           ;
                    16'h00B8    :   o_reg6             <= r_reg_wdat           ;
                    16'h00BC    :   o_reg7             <= r_reg_wdat           ;

                    16'h00C0    :   o_regb0            <= r_reg_wdat           ;
                    16'h00C4    :   o_regb1            <= r_reg_wdat           ;
                    16'h00C8    :   o_regb2            <= r_reg_wdat           ;
                    16'h00CC    :   o_regb3            <= r_reg_wdat           ;
                    16'h00D0    :   o_regb4            <= r_reg_wdat           ;
                    16'h00D4    :   o_regb5            <= r_reg_wdat           ;
                    16'h00D8    :   o_regb6            <= r_reg_wdat           ;
                    16'h00DC    :   o_regb7            <= r_reg_wdat           ;
                endcase
            end
        end
    end



    //---------------------------------------------------------------------
    // register read
    //---------------------------------------------------------------------
    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_reg_rdat_temp0    <= {32{1'b0}} ;
        end else begin
            case ( r_reg_radr )
                
                16'h0000        : r_reg_rdat_temp0 <= {32'h2024_0723} ;
                16'h0004        : r_reg_rdat_temp0 <= {32'h88C1_0002} ;
                16'h0008        : r_reg_rdat_temp0 <= {32'h0000_AAAA} ;
                16'h000C        : r_reg_rdat_temp0 <= {32'h0000_5555} ;

                16'h0020        : r_reg_rdat_temp0 <= i_regc0         ;
                16'h0024        : r_reg_rdat_temp0 <= i_regc1         ;
                16'h0028        : r_reg_rdat_temp0 <= i_regc2         ;
                16'h002C        : r_reg_rdat_temp0 <= i_regc3         ;
                16'h0030        : r_reg_rdat_temp0 <= i_regc4         ;
                16'h0034        : r_reg_rdat_temp0 <= i_regc5         ;
                16'h0038        : r_reg_rdat_temp0 <= i_regc6         ;
                16'h003C        : r_reg_rdat_temp0 <= i_regc7         ;       

                16'h0040        : r_reg_rdat_temp0 <= i_regb0         ;
                16'h0044        : r_reg_rdat_temp0 <= i_regb1         ;
                16'h0048        : r_reg_rdat_temp0 <= i_regb2         ;
                16'h004C        : r_reg_rdat_temp0 <= i_regb3         ;
                16'h0050        : r_reg_rdat_temp0 <= i_regb4         ;
                16'h0054        : r_reg_rdat_temp0 <= i_regb5         ;
                16'h0058        : r_reg_rdat_temp0 <= i_regb6         ;
                16'h005C        : r_reg_rdat_temp0 <= i_regb7         ;
                16'h0060        : r_reg_rdat_temp0 <= i_rega0         ;
                16'h0064        : r_reg_rdat_temp0 <= i_rega1         ;
                16'h0068        : r_reg_rdat_temp0 <= i_rega2         ;
                16'h006C        : r_reg_rdat_temp0 <= i_rega3         ;
                16'h0070        : r_reg_rdat_temp0 <= i_rega4         ;
                16'h0074        : r_reg_rdat_temp0 <= i_rega5         ;
                16'h0078        : r_reg_rdat_temp0 <= i_rega6         ;
                16'h007C        : r_reg_rdat_temp0 <= i_rega7         ;
               
                16'h0080        : r_reg_rdat_temp0 <= i_reg0          ;
                16'h0084        : r_reg_rdat_temp0 <= i_reg1          ;
                16'h0088        : r_reg_rdat_temp0 <= i_reg2          ;
                16'h008C        : r_reg_rdat_temp0 <= i_reg3          ;
                16'h0090        : r_reg_rdat_temp0 <= i_reg4          ;
                16'h0094        : r_reg_rdat_temp0 <= i_reg5          ;
                16'h0098        : r_reg_rdat_temp0 <= i_reg6          ;
                16'h009C        : r_reg_rdat_temp0 <= i_reg7          ;
                
                16'h00A0        : r_reg_rdat_temp0 <= o_reg0          ;
                16'h00A4        : r_reg_rdat_temp0 <= o_reg1          ;
                16'h00A8        : r_reg_rdat_temp0 <= o_reg2          ;
                16'h00AC        : r_reg_rdat_temp0 <= o_reg3          ;
                16'h00B0        : r_reg_rdat_temp0 <= o_reg4          ;
                16'h00B4        : r_reg_rdat_temp0 <= o_reg5          ;
                16'h00B8        : r_reg_rdat_temp0 <= o_reg6          ;
                16'h00BC        : r_reg_rdat_temp0 <= o_reg7          ;

                16'h00C0        : r_reg_rdat_temp0 <= o_regb0          ;
                16'h00C4        : r_reg_rdat_temp0 <= o_regb1          ;
                16'h00C8        : r_reg_rdat_temp0 <= o_regb2          ;
                16'h00CC        : r_reg_rdat_temp0 <= o_regb3          ;
                16'h00D0        : r_reg_rdat_temp0 <= o_regb4          ;
                16'h00D4        : r_reg_rdat_temp0 <= o_regb5          ;
                16'h00D8        : r_reg_rdat_temp0 <= o_regb6          ;
                16'h00DC        : r_reg_rdat_temp0 <= o_regb7          ;

                16'h0120        : r_reg_rdat_temp0 <= i_reg0120        ;
                16'h0124        : r_reg_rdat_temp0 <= i_reg0124        ;
                16'h0128        : r_reg_rdat_temp0 <= i_reg0128        ;
                16'h012C        : r_reg_rdat_temp0 <= i_reg012C        ;
                16'h0130        : r_reg_rdat_temp0 <= i_reg0130        ;
                16'h0134        : r_reg_rdat_temp0 <= i_reg0134        ;
                16'h0138        : r_reg_rdat_temp0 <= i_reg0138        ;
                16'h013C        : r_reg_rdat_temp0 <= i_reg013C        ;       
                16'h0140        : r_reg_rdat_temp0 <= i_reg0140        ;
                16'h0144        : r_reg_rdat_temp0 <= i_reg0144        ;
                16'h0148        : r_reg_rdat_temp0 <= i_reg0148        ;
                16'h014C        : r_reg_rdat_temp0 <= i_reg014C        ;
                16'h0150        : r_reg_rdat_temp0 <= i_reg0150        ;
                16'h0154        : r_reg_rdat_temp0 <= i_reg0154        ;
                16'h0158        : r_reg_rdat_temp0 <= i_reg0158        ;
                16'h015C        : r_reg_rdat_temp0 <= i_reg015C        ;
                16'h0160        : r_reg_rdat_temp0 <= i_reg0160        ;
                16'h0164        : r_reg_rdat_temp0 <= i_reg0164        ;
                16'h0168        : r_reg_rdat_temp0 <= i_reg0168        ;
                16'h016C        : r_reg_rdat_temp0 <= i_reg016C        ;
                16'h0170        : r_reg_rdat_temp0 <= i_reg0170        ;
                16'h0174        : r_reg_rdat_temp0 <= i_reg0174        ;
                16'h0178        : r_reg_rdat_temp0 <= i_reg0178        ;
                16'h017C        : r_reg_rdat_temp0 <= i_reg017C        ;
                16'h0180        : r_reg_rdat_temp0 <= i_reg0180        ;
                16'h0184        : r_reg_rdat_temp0 <= i_reg0184        ;
                16'h0188        : r_reg_rdat_temp0 <= i_reg0188        ;
                16'h018C        : r_reg_rdat_temp0 <= i_reg018C        ;
                16'h0190        : r_reg_rdat_temp0 <= i_reg0190        ;
                16'h0194        : r_reg_rdat_temp0 <= i_reg0194        ;
                16'h0198        : r_reg_rdat_temp0 <= i_reg0198        ;
                16'h019C        : r_reg_rdat_temp0 <= i_reg019C        ;
                                                                             
                16'h0220 : r_reg_rdat_temp0 <= i_reg0220 ; 16'h0320 : r_reg_rdat_temp0 <= i_reg0320 ; 16'h0420 : r_reg_rdat_temp0 <= i_reg0420 ; 16'h0520 : r_reg_rdat_temp0 <= i_reg0520 ; 
                16'h0224 : r_reg_rdat_temp0 <= i_reg0224 ; 16'h0324 : r_reg_rdat_temp0 <= i_reg0324 ; 16'h0424 : r_reg_rdat_temp0 <= i_reg0424 ; 16'h0524 : r_reg_rdat_temp0 <= i_reg0524 ; 
                16'h0228 : r_reg_rdat_temp0 <= i_reg0228 ; 16'h0328 : r_reg_rdat_temp0 <= i_reg0328 ; 16'h0428 : r_reg_rdat_temp0 <= i_reg0428 ; 16'h0528 : r_reg_rdat_temp0 <= i_reg0528 ; 
                16'h022C : r_reg_rdat_temp0 <= i_reg022C ; 16'h032C : r_reg_rdat_temp0 <= i_reg032C ; 16'h042C : r_reg_rdat_temp0 <= i_reg042C ; 16'h052C : r_reg_rdat_temp0 <= i_reg052C ; 
                16'h0230 : r_reg_rdat_temp0 <= i_reg0230 ; 16'h0330 : r_reg_rdat_temp0 <= i_reg0330 ; 16'h0430 : r_reg_rdat_temp0 <= i_reg0430 ; 16'h0530 : r_reg_rdat_temp0 <= i_reg0530 ; 
                16'h0234 : r_reg_rdat_temp0 <= i_reg0234 ; 16'h0334 : r_reg_rdat_temp0 <= i_reg0334 ; 16'h0434 : r_reg_rdat_temp0 <= i_reg0434 ; 16'h0534 : r_reg_rdat_temp0 <= i_reg0534 ; 
                16'h0238 : r_reg_rdat_temp0 <= i_reg0238 ; 16'h0338 : r_reg_rdat_temp0 <= i_reg0338 ; 16'h0438 : r_reg_rdat_temp0 <= i_reg0438 ; 16'h0538 : r_reg_rdat_temp0 <= i_reg0538 ; 
                16'h023C : r_reg_rdat_temp0 <= i_reg023C ; 16'h033C : r_reg_rdat_temp0 <= i_reg033C ; 16'h043C : r_reg_rdat_temp0 <= i_reg043C ; 16'h053C : r_reg_rdat_temp0 <= i_reg053C ; 
                16'h0240 : r_reg_rdat_temp0 <= i_reg0240 ; 16'h0340 : r_reg_rdat_temp0 <= i_reg0340 ; 16'h0440 : r_reg_rdat_temp0 <= i_reg0440 ; 16'h0540 : r_reg_rdat_temp0 <= i_reg0540 ; 
                16'h0244 : r_reg_rdat_temp0 <= i_reg0244 ; 16'h0344 : r_reg_rdat_temp0 <= i_reg0344 ; 16'h0444 : r_reg_rdat_temp0 <= i_reg0444 ; 16'h0544 : r_reg_rdat_temp0 <= i_reg0544 ; 
                16'h0248 : r_reg_rdat_temp0 <= i_reg0248 ; 16'h0348 : r_reg_rdat_temp0 <= i_reg0348 ; 16'h0448 : r_reg_rdat_temp0 <= i_reg0448 ; 16'h0548 : r_reg_rdat_temp0 <= i_reg0548 ; 
                16'h024C : r_reg_rdat_temp0 <= i_reg024C ; 16'h034C : r_reg_rdat_temp0 <= i_reg034C ; 16'h044C : r_reg_rdat_temp0 <= i_reg044C ; 16'h054C : r_reg_rdat_temp0 <= i_reg054C ; 
                16'h0250 : r_reg_rdat_temp0 <= i_reg0250 ; 16'h0350 : r_reg_rdat_temp0 <= i_reg0350 ; 16'h0450 : r_reg_rdat_temp0 <= i_reg0450 ; 16'h0550 : r_reg_rdat_temp0 <= i_reg0550 ; 
                16'h0254 : r_reg_rdat_temp0 <= i_reg0254 ; 16'h0354 : r_reg_rdat_temp0 <= i_reg0354 ; 16'h0454 : r_reg_rdat_temp0 <= i_reg0454 ; 16'h0554 : r_reg_rdat_temp0 <= i_reg0554 ; 
                16'h0258 : r_reg_rdat_temp0 <= i_reg0258 ; 16'h0358 : r_reg_rdat_temp0 <= i_reg0358 ; 16'h0458 : r_reg_rdat_temp0 <= i_reg0458 ; 16'h0558 : r_reg_rdat_temp0 <= i_reg0558 ; 
                16'h025C : r_reg_rdat_temp0 <= i_reg025C ; 16'h035C : r_reg_rdat_temp0 <= i_reg035C ; 16'h045C : r_reg_rdat_temp0 <= i_reg045C ; 16'h055C : r_reg_rdat_temp0 <= i_reg055C ; 
                16'h0260 : r_reg_rdat_temp0 <= i_reg0260 ; 16'h0360 : r_reg_rdat_temp0 <= i_reg0360 ; 16'h0460 : r_reg_rdat_temp0 <= i_reg0460 ; 16'h0560 : r_reg_rdat_temp0 <= i_reg0560 ; 
                16'h0264 : r_reg_rdat_temp0 <= i_reg0264 ; 16'h0364 : r_reg_rdat_temp0 <= i_reg0364 ; 16'h0464 : r_reg_rdat_temp0 <= i_reg0464 ; 16'h0564 : r_reg_rdat_temp0 <= i_reg0564 ; 
                16'h0268 : r_reg_rdat_temp0 <= i_reg0268 ; 16'h0368 : r_reg_rdat_temp0 <= i_reg0368 ; 16'h0468 : r_reg_rdat_temp0 <= i_reg0468 ; 16'h0568 : r_reg_rdat_temp0 <= i_reg0568 ; 
                16'h026C : r_reg_rdat_temp0 <= i_reg026C ; 16'h036C : r_reg_rdat_temp0 <= i_reg036C ; 16'h046C : r_reg_rdat_temp0 <= i_reg046C ; 16'h056C : r_reg_rdat_temp0 <= i_reg056C ; 
                16'h0270 : r_reg_rdat_temp0 <= i_reg0270 ; 16'h0370 : r_reg_rdat_temp0 <= i_reg0370 ; 16'h0470 : r_reg_rdat_temp0 <= i_reg0470 ; 16'h0570 : r_reg_rdat_temp0 <= i_reg0570 ; 
                16'h0274 : r_reg_rdat_temp0 <= i_reg0274 ; 16'h0374 : r_reg_rdat_temp0 <= i_reg0374 ; 16'h0474 : r_reg_rdat_temp0 <= i_reg0474 ; 16'h0574 : r_reg_rdat_temp0 <= i_reg0574 ; 
                16'h0278 : r_reg_rdat_temp0 <= i_reg0278 ; 16'h0378 : r_reg_rdat_temp0 <= i_reg0378 ; 16'h0478 : r_reg_rdat_temp0 <= i_reg0478 ; 16'h0578 : r_reg_rdat_temp0 <= i_reg0578 ; 
                16'h027C : r_reg_rdat_temp0 <= i_reg027C ; 16'h037C : r_reg_rdat_temp0 <= i_reg037C ; 16'h047C : r_reg_rdat_temp0 <= i_reg047C ; 16'h057C : r_reg_rdat_temp0 <= i_reg057C ; 
                16'h0280 : r_reg_rdat_temp0 <= i_reg0280 ; 16'h0380 : r_reg_rdat_temp0 <= i_reg0380 ; 16'h0480 : r_reg_rdat_temp0 <= i_reg0480 ; 16'h0580 : r_reg_rdat_temp0 <= i_reg0580 ; 
                16'h0284 : r_reg_rdat_temp0 <= i_reg0284 ; 16'h0384 : r_reg_rdat_temp0 <= i_reg0384 ; 16'h0484 : r_reg_rdat_temp0 <= i_reg0484 ; 16'h0584 : r_reg_rdat_temp0 <= i_reg0584 ; 
                16'h0288 : r_reg_rdat_temp0 <= i_reg0288 ; 16'h0388 : r_reg_rdat_temp0 <= i_reg0388 ; 16'h0488 : r_reg_rdat_temp0 <= i_reg0488 ; 16'h0588 : r_reg_rdat_temp0 <= i_reg0588 ; 
                16'h028C : r_reg_rdat_temp0 <= i_reg028C ; 16'h038C : r_reg_rdat_temp0 <= i_reg038C ; 16'h048C : r_reg_rdat_temp0 <= i_reg048C ; 16'h058C : r_reg_rdat_temp0 <= i_reg058C ; 
                16'h0290 : r_reg_rdat_temp0 <= i_reg0290 ; 16'h0390 : r_reg_rdat_temp0 <= i_reg0390 ; 16'h0490 : r_reg_rdat_temp0 <= i_reg0490 ; 16'h0590 : r_reg_rdat_temp0 <= i_reg0590 ; 
                16'h0294 : r_reg_rdat_temp0 <= i_reg0294 ; 16'h0394 : r_reg_rdat_temp0 <= i_reg0394 ; 16'h0494 : r_reg_rdat_temp0 <= i_reg0494 ; 16'h0594 : r_reg_rdat_temp0 <= i_reg0594 ; 
                16'h0298 : r_reg_rdat_temp0 <= i_reg0298 ; 16'h0398 : r_reg_rdat_temp0 <= i_reg0398 ; 16'h0498 : r_reg_rdat_temp0 <= i_reg0498 ; 16'h0598 : r_reg_rdat_temp0 <= i_reg0598 ; 
                16'h029C : r_reg_rdat_temp0 <= i_reg029C ; 16'h039C : r_reg_rdat_temp0 <= i_reg039C ; 16'h049C : r_reg_rdat_temp0 <= i_reg049C ; 16'h059C : r_reg_rdat_temp0 <= i_reg059C ; 
                
                16'h0620 : r_reg_rdat_temp0 <= i_reg0620 ; 16'h0720 : r_reg_rdat_temp0 <= i_reg0720 ; 16'h0820 : r_reg_rdat_temp0 <= i_reg0820 ; 16'h0920 : r_reg_rdat_temp0 <= i_reg0920 ; 
                16'h0624 : r_reg_rdat_temp0 <= i_reg0624 ; 16'h0724 : r_reg_rdat_temp0 <= i_reg0724 ; 16'h0824 : r_reg_rdat_temp0 <= i_reg0824 ; 16'h0924 : r_reg_rdat_temp0 <= i_reg0924 ; 
                16'h0628 : r_reg_rdat_temp0 <= i_reg0628 ; 16'h0728 : r_reg_rdat_temp0 <= i_reg0728 ; 16'h0828 : r_reg_rdat_temp0 <= i_reg0828 ; 16'h0928 : r_reg_rdat_temp0 <= i_reg0928 ; 
                16'h062C : r_reg_rdat_temp0 <= i_reg062C ; 16'h072C : r_reg_rdat_temp0 <= i_reg072C ; 16'h082C : r_reg_rdat_temp0 <= i_reg082C ; 16'h092C : r_reg_rdat_temp0 <= i_reg092C ; 
                16'h0630 : r_reg_rdat_temp0 <= i_reg0630 ; 16'h0730 : r_reg_rdat_temp0 <= i_reg0730 ; 16'h0830 : r_reg_rdat_temp0 <= i_reg0830 ; 16'h0930 : r_reg_rdat_temp0 <= i_reg0930 ; 
                16'h0634 : r_reg_rdat_temp0 <= i_reg0634 ; 16'h0734 : r_reg_rdat_temp0 <= i_reg0734 ; 16'h0834 : r_reg_rdat_temp0 <= i_reg0834 ; 16'h0934 : r_reg_rdat_temp0 <= i_reg0934 ; 
                16'h0638 : r_reg_rdat_temp0 <= i_reg0638 ; 16'h0738 : r_reg_rdat_temp0 <= i_reg0738 ; 16'h0838 : r_reg_rdat_temp0 <= i_reg0838 ; 16'h0938 : r_reg_rdat_temp0 <= i_reg0938 ; 
                16'h063C : r_reg_rdat_temp0 <= i_reg063C ; 16'h073C : r_reg_rdat_temp0 <= i_reg073C ; 16'h083C : r_reg_rdat_temp0 <= i_reg083C ; 16'h093C : r_reg_rdat_temp0 <= i_reg093C ; 
                16'h0640 : r_reg_rdat_temp0 <= i_reg0640 ; 16'h0740 : r_reg_rdat_temp0 <= i_reg0740 ; 16'h0840 : r_reg_rdat_temp0 <= i_reg0840 ; 16'h0940 : r_reg_rdat_temp0 <= i_reg0940 ; 
                16'h0644 : r_reg_rdat_temp0 <= i_reg0644 ; 16'h0744 : r_reg_rdat_temp0 <= i_reg0744 ; 16'h0844 : r_reg_rdat_temp0 <= i_reg0844 ; 16'h0944 : r_reg_rdat_temp0 <= i_reg0944 ; 
                16'h0648 : r_reg_rdat_temp0 <= i_reg0648 ; 16'h0748 : r_reg_rdat_temp0 <= i_reg0748 ; 16'h0848 : r_reg_rdat_temp0 <= i_reg0848 ; 16'h0948 : r_reg_rdat_temp0 <= i_reg0948 ; 
                16'h064C : r_reg_rdat_temp0 <= i_reg064C ; 16'h074C : r_reg_rdat_temp0 <= i_reg074C ; 16'h084C : r_reg_rdat_temp0 <= i_reg084C ; 16'h094C : r_reg_rdat_temp0 <= i_reg094C ; 
                16'h0650 : r_reg_rdat_temp0 <= i_reg0650 ; 16'h0750 : r_reg_rdat_temp0 <= i_reg0750 ; 16'h0850 : r_reg_rdat_temp0 <= i_reg0850 ; 16'h0950 : r_reg_rdat_temp0 <= i_reg0950 ; 
                16'h0654 : r_reg_rdat_temp0 <= i_reg0654 ; 16'h0754 : r_reg_rdat_temp0 <= i_reg0754 ; 16'h0854 : r_reg_rdat_temp0 <= i_reg0854 ; 16'h0954 : r_reg_rdat_temp0 <= i_reg0954 ; 
                16'h0658 : r_reg_rdat_temp0 <= i_reg0658 ; 16'h0758 : r_reg_rdat_temp0 <= i_reg0758 ; 16'h0858 : r_reg_rdat_temp0 <= i_reg0858 ; 16'h0958 : r_reg_rdat_temp0 <= i_reg0958 ; 
                16'h065C : r_reg_rdat_temp0 <= i_reg065C ; 16'h075C : r_reg_rdat_temp0 <= i_reg075C ; 16'h085C : r_reg_rdat_temp0 <= i_reg085C ; 16'h095C : r_reg_rdat_temp0 <= i_reg095C ; 
                16'h0660 : r_reg_rdat_temp0 <= i_reg0660 ; 16'h0760 : r_reg_rdat_temp0 <= i_reg0760 ; 16'h0860 : r_reg_rdat_temp0 <= i_reg0860 ; 16'h0960 : r_reg_rdat_temp0 <= i_reg0960 ; 
                16'h0664 : r_reg_rdat_temp0 <= i_reg0664 ; 16'h0764 : r_reg_rdat_temp0 <= i_reg0764 ; 16'h0864 : r_reg_rdat_temp0 <= i_reg0864 ; 16'h0964 : r_reg_rdat_temp0 <= i_reg0964 ; 
                16'h0668 : r_reg_rdat_temp0 <= i_reg0668 ; 16'h0768 : r_reg_rdat_temp0 <= i_reg0768 ; 16'h0868 : r_reg_rdat_temp0 <= i_reg0868 ; 16'h0968 : r_reg_rdat_temp0 <= i_reg0968 ; 
                16'h066C : r_reg_rdat_temp0 <= i_reg066C ; 16'h076C : r_reg_rdat_temp0 <= i_reg076C ; 16'h086C : r_reg_rdat_temp0 <= i_reg086C ; 16'h096C : r_reg_rdat_temp0 <= i_reg096C ; 
                16'h0670 : r_reg_rdat_temp0 <= i_reg0670 ; 16'h0770 : r_reg_rdat_temp0 <= i_reg0770 ; 16'h0870 : r_reg_rdat_temp0 <= i_reg0870 ; 16'h0970 : r_reg_rdat_temp0 <= i_reg0970 ; 
                16'h0674 : r_reg_rdat_temp0 <= i_reg0674 ; 16'h0774 : r_reg_rdat_temp0 <= i_reg0774 ; 16'h0874 : r_reg_rdat_temp0 <= i_reg0874 ; 16'h0974 : r_reg_rdat_temp0 <= i_reg0974 ; 
                16'h0678 : r_reg_rdat_temp0 <= i_reg0678 ; 16'h0778 : r_reg_rdat_temp0 <= i_reg0778 ; 16'h0878 : r_reg_rdat_temp0 <= i_reg0878 ; 16'h0978 : r_reg_rdat_temp0 <= i_reg0978 ; 
                16'h067C : r_reg_rdat_temp0 <= i_reg067C ; 16'h077C : r_reg_rdat_temp0 <= i_reg077C ; 16'h087C : r_reg_rdat_temp0 <= i_reg087C ; 16'h097C : r_reg_rdat_temp0 <= i_reg097C ; 
                16'h0680 : r_reg_rdat_temp0 <= i_reg0680 ; 16'h0780 : r_reg_rdat_temp0 <= i_reg0780 ; 16'h0880 : r_reg_rdat_temp0 <= i_reg0880 ; 16'h0980 : r_reg_rdat_temp0 <= i_reg0980 ; 
                16'h0684 : r_reg_rdat_temp0 <= i_reg0684 ; 16'h0784 : r_reg_rdat_temp0 <= i_reg0784 ; 16'h0884 : r_reg_rdat_temp0 <= i_reg0884 ; 16'h0984 : r_reg_rdat_temp0 <= i_reg0984 ; 
                16'h0688 : r_reg_rdat_temp0 <= i_reg0688 ; 16'h0788 : r_reg_rdat_temp0 <= i_reg0788 ; 16'h0888 : r_reg_rdat_temp0 <= i_reg0888 ; 16'h0988 : r_reg_rdat_temp0 <= i_reg0988 ; 
                16'h068C : r_reg_rdat_temp0 <= i_reg068C ; 16'h078C : r_reg_rdat_temp0 <= i_reg078C ; 16'h088C : r_reg_rdat_temp0 <= i_reg088C ; 16'h098C : r_reg_rdat_temp0 <= i_reg098C ; 
                16'h0690 : r_reg_rdat_temp0 <= i_reg0690 ; 16'h0790 : r_reg_rdat_temp0 <= i_reg0790 ; 16'h0890 : r_reg_rdat_temp0 <= i_reg0890 ; 16'h0990 : r_reg_rdat_temp0 <= i_reg0990 ; 
                16'h0694 : r_reg_rdat_temp0 <= i_reg0694 ; 16'h0794 : r_reg_rdat_temp0 <= i_reg0794 ; 16'h0894 : r_reg_rdat_temp0 <= i_reg0894 ; 16'h0994 : r_reg_rdat_temp0 <= i_reg0994 ; 
                16'h0698 : r_reg_rdat_temp0 <= i_reg0698 ; 16'h0798 : r_reg_rdat_temp0 <= i_reg0798 ; 16'h0898 : r_reg_rdat_temp0 <= i_reg0898 ; 16'h0998 : r_reg_rdat_temp0 <= i_reg0998 ; 
                16'h069C : r_reg_rdat_temp0 <= i_reg069C ; 16'h079C : r_reg_rdat_temp0 <= i_reg079C ; 16'h089C : r_reg_rdat_temp0 <= i_reg089C ; 16'h099C : r_reg_rdat_temp0 <= i_reg099C ; 
                                                                            
                default         : r_reg_rdat_temp0 <= {32{1'b0}} ;
            endcase
        end
    end

    // read data valid
    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_reg_rdvld    <= 1'b0 ;
        end else begin
            if ( r_reg_rreq == 1'b1 ) begin
                r_reg_rdvld    <= 1'b1 ;
            end else begin
                r_reg_rdvld    <= 1'b0 ;
            end
        end
    end

    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_reg_rdat    <= 32'b0 ;
        end else begin
            if ( r_reg_rdvld == 1'b1 ) begin
                r_reg_rdat    <= r_reg_rdat_temp0 ;
            end else begin
                r_reg_rdat    <= 32'b0 ;
            end
        end
    end

    // write ack
    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_reg_wack    <= 1'b0 ;
        end else begin
            r_reg_wack    <= r_reg_wreq ;
        end
    end

    // read ack
    always @( posedge clk or negedge xrst ) begin
        if ( xrst == 1'b0 ) begin
            r_reg_rack    <= 1'b0 ;
        end else begin
            r_reg_rack    <= r_reg_rdvld ;
        end
    end
    
    


    //-------------------------------------------------------------------//
    wire                              pkt_end_flag_pos;
    wire                              adc_end_flag_pos;
    always@(posedge clk)begin
        pkt_end_flag_d1          <=   pkt_end_flag       ;
        pkt_end_flag_d2          <=   pkt_end_flag_d1    ;
        adc_end_flag_d1          <=   adc_end_flag       ;
        adc_end_flag_d2          <=   adc_end_flag_d1    ;
    end
    
    assign      pkt_end_flag_pos  =  ~pkt_end_flag_d2 && pkt_end_flag_d1;
    assign      adc_end_flag_pos  =  ~adc_end_flag_d2 && adc_end_flag_d1;
    

    always@(posedge clk)begin
        if(adc_end_flag_pos)begin                 
            i_reg0120    <=   i_regc0         ;//(i) 16'h0120     
            i_reg0124    <=   i_regc1         ;//(i) 16'h0124     
            i_reg0128    <=   i_regc2         ;//(i) 16'h0128     
            i_reg012C    <=   i_regc3         ;//(i) 16'h012C     
            i_reg0130    <=   i_regc4         ;//(i) 16'h0130     
            i_reg0134    <=   i_regc5         ;//(i) 16'h0134     
            i_reg0138    <=   i_regc6         ;//(i) 16'h0138     
            i_reg013C    <=   i_regc7         ;//(i) 16'h013C     
            i_reg0140    <=   i_regb0         ;//(i) 16'h0140     
            i_reg0144    <=   i_regb1         ;//(i) 16'h0144     
            i_reg0148    <=   i_regb2         ;//(i) 16'h0148     
            i_reg014C    <=   i_regb3         ;//(i) 16'h014C     
            i_reg0150    <=   i_regb4         ;//(i) 16'h0150     
            i_reg0154    <=   i_regb5         ;//(i) 16'h0154     
            i_reg0158    <=   i_regb6         ;//(i) 16'h0158     //enc_chk_suc_cnt
            i_reg015C    <=   i_regb7         ;//(i) 16'h015C     //enc_chk_err_cnt
            i_reg0160    <=   i_rega0         ;//(i) 16'h0160     
            i_reg0164    <=   i_rega1         ;//(i) 16'h0164     
            i_reg0168    <=   i_rega2         ;//(i) 16'h0168     
            i_reg016C    <=   i_rega3         ;//(i) 16'h016C     
            i_reg0170    <=   i_rega4         ;//(i) 16'h0170     
            i_reg0174    <=   i_rega5         ;//(i) 16'h0174     
            i_reg0178    <=   i_rega6         ;//(i) 16'h0178     
            i_reg017C    <=   i_rega7         ;//(i) 16'h017C    
            i_reg0180    <=   i_reg0          ;//(i) 16'h0180     
            i_reg0184    <=   i_reg1          ;//(i) 16'h0184     
            i_reg0188    <=   i_reg2          ;//(i) 16'h0188     
            i_reg018C    <=   i_reg3          ;//(i) 16'h018C     
            i_reg0190    <=   i_reg4          ;//(i) 16'h0190     
            i_reg0194    <=   i_reg5          ;//(i) 16'h0194     
            i_reg0198    <=   i_reg6          ;//(i) 16'h0198     
            i_reg019C    <=   i_reg7          ;//(i) 16'h019C    
        end
    end 
    
    
    //-------------------------------------------------------------------//
    always@(posedge clk or negedge xrst)begin
        if(~xrst)begin
            dbg_cnt      <= 'd0;
            dbg_cnt_arr  <= 'd0;
        end else if(o_reg0[7])begin
            dbg_cnt      <= 'd0;
            dbg_cnt_arr  <= 'd0;
        end else if(pkt_end_flag_pos)begin
            dbg_cnt      <= dbg_cnt + 1'b1;
            dbg_cnt_arr  <= {dbg_cnt_arr,{1'b0,dbg_cnt}};
        end
    end
    
    
    always@(posedge clk)begin
        if(o_reg0[7])begin
            i_reg0220 <= 'd0 ; i_reg0320 <= 'd0 ; i_reg0420 <= 'd0 ; i_reg0520 <= 'd0 ;
            i_reg0224 <= 'd0 ; i_reg0324 <= 'd0 ; i_reg0424 <= 'd0 ; i_reg0524 <= 'd0 ;
            i_reg0228 <= 'd0 ; i_reg0328 <= 'd0 ; i_reg0428 <= 'd0 ; i_reg0528 <= 'd0 ;
            i_reg022C <= 'd0 ; i_reg032C <= 'd0 ; i_reg042C <= 'd0 ; i_reg052C <= 'd0 ;
            i_reg0230 <= 'd0 ; i_reg0330 <= 'd0 ; i_reg0430 <= 'd0 ; i_reg0530 <= 'd0 ;
            i_reg0234 <= 'd0 ; i_reg0334 <= 'd0 ; i_reg0434 <= 'd0 ; i_reg0534 <= 'd0 ;
            i_reg0238 <= 'd0 ; i_reg0338 <= 'd0 ; i_reg0438 <= 'd0 ; i_reg0538 <= 'd0 ;
            i_reg023C <= 'd0 ; i_reg033C <= 'd0 ; i_reg043C <= 'd0 ; i_reg053C <= 'd0 ;
            i_reg0240 <= 'd0 ; i_reg0340 <= 'd0 ; i_reg0440 <= 'd0 ; i_reg0540 <= 'd0 ;
            i_reg0244 <= 'd0 ; i_reg0344 <= 'd0 ; i_reg0444 <= 'd0 ; i_reg0544 <= 'd0 ;
            i_reg0248 <= 'd0 ; i_reg0348 <= 'd0 ; i_reg0448 <= 'd0 ; i_reg0548 <= 'd0 ;
            i_reg024C <= 'd0 ; i_reg034C <= 'd0 ; i_reg044C <= 'd0 ; i_reg054C <= 'd0 ;
            i_reg0250 <= 'd0 ; i_reg0350 <= 'd0 ; i_reg0450 <= 'd0 ; i_reg0550 <= 'd0 ;
            i_reg0254 <= 'd0 ; i_reg0354 <= 'd0 ; i_reg0454 <= 'd0 ; i_reg0554 <= 'd0 ;
            i_reg0258 <= 'd0 ; i_reg0358 <= 'd0 ; i_reg0458 <= 'd0 ; i_reg0558 <= 'd0 ;
            i_reg025C <= 'd0 ; i_reg035C <= 'd0 ; i_reg045C <= 'd0 ; i_reg055C <= 'd0 ;
            i_reg0260 <= 'd0 ; i_reg0360 <= 'd0 ; i_reg0460 <= 'd0 ; i_reg0560 <= 'd0 ;
            i_reg0264 <= 'd0 ; i_reg0364 <= 'd0 ; i_reg0464 <= 'd0 ; i_reg0564 <= 'd0 ;
            i_reg0268 <= 'd0 ; i_reg0368 <= 'd0 ; i_reg0468 <= 'd0 ; i_reg0568 <= 'd0 ;
            i_reg026C <= 'd0 ; i_reg036C <= 'd0 ; i_reg046C <= 'd0 ; i_reg056C <= 'd0 ;
            i_reg0270 <= 'd0 ; i_reg0370 <= 'd0 ; i_reg0470 <= 'd0 ; i_reg0570 <= 'd0 ;
            i_reg0274 <= 'd0 ; i_reg0374 <= 'd0 ; i_reg0474 <= 'd0 ; i_reg0574 <= 'd0 ;
            i_reg0278 <= 'd0 ; i_reg0378 <= 'd0 ; i_reg0478 <= 'd0 ; i_reg0578 <= 'd0 ;
            i_reg027C <= 'd0 ; i_reg037C <= 'd0 ; i_reg047C <= 'd0 ; i_reg057C <= 'd0 ;
            i_reg0280 <= 'd0 ; i_reg0380 <= 'd0 ; i_reg0480 <= 'd0 ; i_reg0580 <= 'd0 ;
            i_reg0284 <= 'd0 ; i_reg0384 <= 'd0 ; i_reg0484 <= 'd0 ; i_reg0584 <= 'd0 ;
            i_reg0288 <= 'd0 ; i_reg0388 <= 'd0 ; i_reg0488 <= 'd0 ; i_reg0588 <= 'd0 ;
            i_reg028C <= 'd0 ; i_reg038C <= 'd0 ; i_reg048C <= 'd0 ; i_reg058C <= 'd0 ;
            i_reg0290 <= 'd0 ; i_reg0390 <= 'd0 ; i_reg0490 <= 'd0 ; i_reg0590 <= 'd0 ;
            i_reg0294 <= 'd0 ; i_reg0394 <= 'd0 ; i_reg0494 <= 'd0 ; i_reg0594 <= 'd0 ;
            i_reg0298 <= 'd0 ; i_reg0398 <= 'd0 ; i_reg0498 <= 'd0 ; i_reg0598 <= 'd0 ;
            i_reg029C <= 'd0 ; i_reg039C <= 'd0 ; i_reg049C <= 'd0 ; i_reg059C <= 'd0 ;

            i_reg0620 <= 'd0 ; i_reg0720 <= 'd0 ; i_reg0820 <= 'd0 ; i_reg0920 <= 'd0 ;
            i_reg0624 <= 'd0 ; i_reg0724 <= 'd0 ; i_reg0824 <= 'd0 ; i_reg0924 <= 'd0 ;
            i_reg0628 <= 'd0 ; i_reg0728 <= 'd0 ; i_reg0828 <= 'd0 ; i_reg0928 <= 'd0 ;
            i_reg062C <= 'd0 ; i_reg072C <= 'd0 ; i_reg082C <= 'd0 ; i_reg092C <= 'd0 ;
            i_reg0630 <= 'd0 ; i_reg0730 <= 'd0 ; i_reg0830 <= 'd0 ; i_reg0930 <= 'd0 ;
            i_reg0634 <= 'd0 ; i_reg0734 <= 'd0 ; i_reg0834 <= 'd0 ; i_reg0934 <= 'd0 ;
            i_reg0638 <= 'd0 ; i_reg0738 <= 'd0 ; i_reg0838 <= 'd0 ; i_reg0938 <= 'd0 ;
            i_reg063C <= 'd0 ; i_reg073C <= 'd0 ; i_reg083C <= 'd0 ; i_reg093C <= 'd0 ;
            i_reg0640 <= 'd0 ; i_reg0740 <= 'd0 ; i_reg0840 <= 'd0 ; i_reg0940 <= 'd0 ;
            i_reg0644 <= 'd0 ; i_reg0744 <= 'd0 ; i_reg0844 <= 'd0 ; i_reg0944 <= 'd0 ;
            i_reg0648 <= 'd0 ; i_reg0748 <= 'd0 ; i_reg0848 <= 'd0 ; i_reg0948 <= 'd0 ;
            i_reg064C <= 'd0 ; i_reg074C <= 'd0 ; i_reg084C <= 'd0 ; i_reg094C <= 'd0 ;
            i_reg0650 <= 'd0 ; i_reg0750 <= 'd0 ; i_reg0850 <= 'd0 ; i_reg0950 <= 'd0 ;
            i_reg0654 <= 'd0 ; i_reg0754 <= 'd0 ; i_reg0854 <= 'd0 ; i_reg0954 <= 'd0 ;
            i_reg0658 <= 'd0 ; i_reg0758 <= 'd0 ; i_reg0858 <= 'd0 ; i_reg0958 <= 'd0 ;
            i_reg065C <= 'd0 ; i_reg075C <= 'd0 ; i_reg085C <= 'd0 ; i_reg095C <= 'd0 ;
            i_reg0660 <= 'd0 ; i_reg0760 <= 'd0 ; i_reg0860 <= 'd0 ; i_reg0960 <= 'd0 ;
            i_reg0664 <= 'd0 ; i_reg0764 <= 'd0 ; i_reg0864 <= 'd0 ; i_reg0964 <= 'd0 ;
            i_reg0668 <= 'd0 ; i_reg0768 <= 'd0 ; i_reg0868 <= 'd0 ; i_reg0968 <= 'd0 ;
            i_reg066C <= 'd0 ; i_reg076C <= 'd0 ; i_reg086C <= 'd0 ; i_reg096C <= 'd0 ;
            i_reg0670 <= 'd0 ; i_reg0770 <= 'd0 ; i_reg0870 <= 'd0 ; i_reg0970 <= 'd0 ;
            i_reg0674 <= 'd0 ; i_reg0774 <= 'd0 ; i_reg0874 <= 'd0 ; i_reg0974 <= 'd0 ;
            i_reg0678 <= 'd0 ; i_reg0778 <= 'd0 ; i_reg0878 <= 'd0 ; i_reg0978 <= 'd0 ;
            i_reg067C <= 'd0 ; i_reg077C <= 'd0 ; i_reg087C <= 'd0 ; i_reg097C <= 'd0 ;
            i_reg0680 <= 'd0 ; i_reg0780 <= 'd0 ; i_reg0880 <= 'd0 ; i_reg0980 <= 'd0 ;
            i_reg0684 <= 'd0 ; i_reg0784 <= 'd0 ; i_reg0884 <= 'd0 ; i_reg0984 <= 'd0 ;
            i_reg0688 <= 'd0 ; i_reg0788 <= 'd0 ; i_reg0888 <= 'd0 ; i_reg0988 <= 'd0 ;
            i_reg068C <= 'd0 ; i_reg078C <= 'd0 ; i_reg088C <= 'd0 ; i_reg098C <= 'd0 ;
            i_reg0690 <= 'd0 ; i_reg0790 <= 'd0 ; i_reg0890 <= 'd0 ; i_reg0990 <= 'd0 ;
            i_reg0694 <= 'd0 ; i_reg0794 <= 'd0 ; i_reg0894 <= 'd0 ; i_reg0994 <= 'd0 ;
            i_reg0698 <= 'd0 ; i_reg0798 <= 'd0 ; i_reg0898 <= 'd0 ; i_reg0998 <= 'd0 ;
            i_reg069C <= 'd0 ; i_reg079C <= 'd0 ; i_reg089C <= 'd0 ; i_reg099C <= 'd0 ;
        end
    
    
        if(pkt_end_flag_pos && dbg_cnt == 3'd0)begin                 
            i_reg0220    <=   i_regc0         ;//(i) 16'h0120     
            i_reg0224    <=   i_regc1         ;//(i) 16'h0124     
            i_reg0228    <=   i_regc2         ;//(i) 16'h0128     
            i_reg022C    <=   i_regc3         ;//(i) 16'h012C     
            i_reg0230    <=   i_regc4         ;//(i) 16'h0130     
            i_reg0234    <=   i_regc5         ;//(i) 16'h0134     
            i_reg0238    <=   i_regc6         ;//(i) 16'h0138     
            i_reg023C    <=   i_regc7         ;//(i) 16'h013C     
            i_reg0240    <=   i_regb0         ;//(i) 16'h0140     
            i_reg0244    <=   i_regb1         ;//(i) 16'h0144     
            i_reg0248    <=   i_regb2         ;//(i) 16'h0148     
            i_reg024C    <=   i_regb3         ;//(i) 16'h014C     
            i_reg0250    <=   i_regb4         ;//(i) 16'h0150     
            i_reg0254    <=   i_regb5         ;//(i) 16'h0154     
            i_reg0258    <=   i_regb6         ;//(i) 16'h0158     //enc_chk_suc_cnt
            i_reg025C    <=   i_regb7         ;//(i) 16'h015C     //enc_chk_err_cnt
            i_reg0260    <=   i_rega0         ;//(i) 16'h0160     
            i_reg0264    <=   i_rega1         ;//(i) 16'h0164     
            i_reg0268    <=   i_rega2         ;//(i) 16'h0168     
            i_reg026C    <=   i_rega3         ;//(i) 16'h016C     
            i_reg0270    <=   i_rega4         ;//(i) 16'h0170     
            i_reg0274    <=   i_rega5         ;//(i) 16'h0174     
            i_reg0278    <=   i_rega6         ;//(i) 16'h0178     
            i_reg027C    <=   i_rega7         ;//(i) 16'h017C    
            i_reg0280    <=   i_reg0          ;//(i) 16'h0180     
            i_reg0284    <=   i_reg1          ;//(i) 16'h0184     
            i_reg0288    <=   i_reg2          ;//(i) 16'h0188     
            i_reg028C    <=   i_reg3          ;//(i) 16'h018C     
            i_reg0290    <=   i_reg4          ;//(i) 16'h0190     
            i_reg0294    <=   i_reg5          ;//(i) 16'h0194     
            i_reg0298    <=   i_reg6          ;//(i) 16'h0198     
            i_reg029C    <=   i_reg7          ;//(i) 16'h019C    
        end
        
        if(pkt_end_flag_pos && dbg_cnt == 3'd1)begin                 
            i_reg0320    <=   i_regc0         ;//(i) 16'h0120     
            i_reg0324    <=   i_regc1         ;//(i) 16'h0124     
            i_reg0328    <=   i_regc2         ;//(i) 16'h0128     
            i_reg032C    <=   i_regc3         ;//(i) 16'h012C     
            i_reg0330    <=   i_regc4         ;//(i) 16'h0130     
            i_reg0334    <=   i_regc5         ;//(i) 16'h0134     
            i_reg0338    <=   i_regc6         ;//(i) 16'h0138     
            i_reg033C    <=   i_regc7         ;//(i) 16'h013C     
            i_reg0340    <=   i_regb0         ;//(i) 16'h0140     
            i_reg0344    <=   i_regb1         ;//(i) 16'h0144     
            i_reg0348    <=   i_regb2         ;//(i) 16'h0148     
            i_reg034C    <=   i_regb3         ;//(i) 16'h014C     
            i_reg0350    <=   i_regb4         ;//(i) 16'h0150     
            i_reg0354    <=   i_regb5         ;//(i) 16'h0154     
            i_reg0358    <=   i_regb6         ;//(i) 16'h0158     //enc_chk_suc_cnt
            i_reg035C    <=   i_regb7         ;//(i) 16'h015C     //enc_chk_err_cnt
            i_reg0360    <=   i_rega0         ;//(i) 16'h0160     
            i_reg0364    <=   i_rega1         ;//(i) 16'h0164     
            i_reg0368    <=   i_rega2         ;//(i) 16'h0168     
            i_reg036C    <=   i_rega3         ;//(i) 16'h016C     
            i_reg0370    <=   i_rega4         ;//(i) 16'h0170     
            i_reg0374    <=   i_rega5         ;//(i) 16'h0174     
            i_reg0378    <=   i_rega6         ;//(i) 16'h0178     
            i_reg037C    <=   i_rega7         ;//(i) 16'h017C    
            i_reg0380    <=   i_reg0          ;//(i) 16'h0180     
            i_reg0384    <=   i_reg1          ;//(i) 16'h0184     
            i_reg0388    <=   i_reg2          ;//(i) 16'h0188     
            i_reg038C    <=   i_reg3          ;//(i) 16'h018C     
            i_reg0390    <=   i_reg4          ;//(i) 16'h0190     
            i_reg0394    <=   i_reg5          ;//(i) 16'h0194     
            i_reg0398    <=   i_reg6          ;//(i) 16'h0198     
            i_reg039C    <=   i_reg7          ;//(i) 16'h019C    
        end
        
        if(pkt_end_flag_pos && dbg_cnt == 3'd2)begin                 
            i_reg0420    <=   i_regc0         ;//(i) 16'h0120     
            i_reg0424    <=   i_regc1         ;//(i) 16'h0124     
            i_reg0428    <=   i_regc2         ;//(i) 16'h0128     
            i_reg042C    <=   i_regc3         ;//(i) 16'h012C     
            i_reg0430    <=   i_regc4         ;//(i) 16'h0130     
            i_reg0434    <=   i_regc5         ;//(i) 16'h0134     
            i_reg0438    <=   i_regc6         ;//(i) 16'h0138     
            i_reg043C    <=   i_regc7         ;//(i) 16'h013C     
            i_reg0440    <=   i_regb0         ;//(i) 16'h0140     
            i_reg0444    <=   i_regb1         ;//(i) 16'h0144     
            i_reg0448    <=   i_regb2         ;//(i) 16'h0148     
            i_reg044C    <=   i_regb3         ;//(i) 16'h014C     
            i_reg0450    <=   i_regb4         ;//(i) 16'h0150     
            i_reg0454    <=   i_regb5         ;//(i) 16'h0154     
            i_reg0458    <=   i_regb6         ;//(i) 16'h0158     //enc_chk_suc_cnt
            i_reg045C    <=   i_regb7         ;//(i) 16'h015C     //enc_chk_err_cnt
            i_reg0460    <=   i_rega0         ;//(i) 16'h0160     
            i_reg0464    <=   i_rega1         ;//(i) 16'h0164     
            i_reg0468    <=   i_rega2         ;//(i) 16'h0168     
            i_reg046C    <=   i_rega3         ;//(i) 16'h016C     
            i_reg0470    <=   i_rega4         ;//(i) 16'h0170     
            i_reg0474    <=   i_rega5         ;//(i) 16'h0174     
            i_reg0478    <=   i_rega6         ;//(i) 16'h0178     
            i_reg047C    <=   i_rega7         ;//(i) 16'h017C    
            i_reg0480    <=   i_reg0          ;//(i) 16'h0180     
            i_reg0484    <=   i_reg1          ;//(i) 16'h0184     
            i_reg0488    <=   i_reg2          ;//(i) 16'h0188     
            i_reg048C    <=   i_reg3          ;//(i) 16'h018C     
            i_reg0490    <=   i_reg4          ;//(i) 16'h0190     
            i_reg0494    <=   i_reg5          ;//(i) 16'h0194     
            i_reg0498    <=   i_reg6          ;//(i) 16'h0198     
            i_reg049C    <=   i_reg7          ;//(i) 16'h019C    
        end
        
        if(pkt_end_flag_pos && dbg_cnt == 3'd3)begin                 
            i_reg0520    <=   i_regc0         ;//(i) 16'h0120     
            i_reg0524    <=   i_regc1         ;//(i) 16'h0124     
            i_reg0528    <=   i_regc2         ;//(i) 16'h0128     
            i_reg052C    <=   i_regc3         ;//(i) 16'h012C     
            i_reg0530    <=   i_regc4         ;//(i) 16'h0130     
            i_reg0534    <=   i_regc5         ;//(i) 16'h0134     
            i_reg0538    <=   i_regc6         ;//(i) 16'h0138     
            i_reg053C    <=   i_regc7         ;//(i) 16'h013C     
            i_reg0540    <=   i_regb0         ;//(i) 16'h0140     
            i_reg0544    <=   i_regb1         ;//(i) 16'h0144     
            i_reg0548    <=   i_regb2         ;//(i) 16'h0148     
            i_reg054C    <=   i_regb3         ;//(i) 16'h014C     
            i_reg0550    <=   i_regb4         ;//(i) 16'h0150     
            i_reg0554    <=   i_regb5         ;//(i) 16'h0154     
            i_reg0558    <=   i_regb6         ;//(i) 16'h0158     //enc_chk_suc_cnt
            i_reg055C    <=   i_regb7         ;//(i) 16'h015C     //enc_chk_err_cnt
            i_reg0560    <=   i_rega0         ;//(i) 16'h0160     
            i_reg0564    <=   i_rega1         ;//(i) 16'h0164     
            i_reg0568    <=   i_rega2         ;//(i) 16'h0168     
            i_reg056C    <=   i_rega3         ;//(i) 16'h016C     
            i_reg0570    <=   i_rega4         ;//(i) 16'h0170     
            i_reg0574    <=   i_rega5         ;//(i) 16'h0174     
            i_reg0578    <=   i_rega6         ;//(i) 16'h0178     
            i_reg057C    <=   i_rega7         ;//(i) 16'h017C    
            i_reg0580    <=   i_reg0          ;//(i) 16'h0180     
            i_reg0584    <=   i_reg1          ;//(i) 16'h0184     
            i_reg0588    <=   i_reg2          ;//(i) 16'h0188     
            i_reg058C    <=   i_reg3          ;//(i) 16'h018C     
            i_reg0590    <=   i_reg4          ;//(i) 16'h0190     
            i_reg0594    <=   i_reg5          ;//(i) 16'h0194     
            i_reg0598    <=   i_reg6          ;//(i) 16'h0198     
            i_reg059C    <=   i_reg7          ;//(i) 16'h019C    
        end
        
        if(pkt_end_flag_pos && dbg_cnt == 3'd4)begin                 
            i_reg0620    <=   i_regc0         ;//(i) 16'h0120     
            i_reg0624    <=   i_regc1         ;//(i) 16'h0124     
            i_reg0628    <=   i_regc2         ;//(i) 16'h0128     
            i_reg062C    <=   i_regc3         ;//(i) 16'h012C     
            i_reg0630    <=   i_regc4         ;//(i) 16'h0130     
            i_reg0634    <=   i_regc5         ;//(i) 16'h0134     
            i_reg0638    <=   i_regc6         ;//(i) 16'h0138     
            i_reg063C    <=   i_regc7         ;//(i) 16'h013C     
            i_reg0640    <=   i_regb0         ;//(i) 16'h0140     
            i_reg0644    <=   i_regb1         ;//(i) 16'h0144     
            i_reg0648    <=   i_regb2         ;//(i) 16'h0148     
            i_reg064C    <=   i_regb3         ;//(i) 16'h014C     
            i_reg0650    <=   i_regb4         ;//(i) 16'h0150     
            i_reg0654    <=   i_regb5         ;//(i) 16'h0154     
            i_reg0658    <=   i_regb6         ;//(i) 16'h0158     //enc_chk_suc_cnt
            i_reg065C    <=   i_regb7         ;//(i) 16'h015C     //enc_chk_err_cnt
            i_reg0660    <=   i_rega0         ;//(i) 16'h0160     
            i_reg0664    <=   i_rega1         ;//(i) 16'h0164     
            i_reg0668    <=   i_rega2         ;//(i) 16'h0168     
            i_reg066C    <=   i_rega3         ;//(i) 16'h016C     
            i_reg0670    <=   i_rega4         ;//(i) 16'h0170     
            i_reg0674    <=   i_rega5         ;//(i) 16'h0174     
            i_reg0678    <=   i_rega6         ;//(i) 16'h0178     
            i_reg067C    <=   i_rega7         ;//(i) 16'h017C    
            i_reg0680    <=   i_reg0          ;//(i) 16'h0180     
            i_reg0684    <=   i_reg1          ;//(i) 16'h0184     
            i_reg0688    <=   i_reg2          ;//(i) 16'h0188     
            i_reg068C    <=   i_reg3          ;//(i) 16'h018C     
            i_reg0690    <=   i_reg4          ;//(i) 16'h0190     
            i_reg0694    <=   i_reg5          ;//(i) 16'h0194     
            i_reg0698    <=   i_reg6          ;//(i) 16'h0198     
            i_reg069C    <=   i_reg7          ;//(i) 16'h019C    
        end
        
        if(pkt_end_flag_pos && dbg_cnt == 3'd5)begin                 
            i_reg0720    <=   i_regc0         ;//(i) 16'h0120     
            i_reg0724    <=   i_regc1         ;//(i) 16'h0124     
            i_reg0728    <=   i_regc2         ;//(i) 16'h0128     
            i_reg072C    <=   i_regc3         ;//(i) 16'h012C     
            i_reg0730    <=   i_regc4         ;//(i) 16'h0130     
            i_reg0734    <=   i_regc5         ;//(i) 16'h0134     
            i_reg0738    <=   i_regc6         ;//(i) 16'h0138     
            i_reg073C    <=   i_regc7         ;//(i) 16'h013C     
            i_reg0740    <=   i_regb0         ;//(i) 16'h0140     
            i_reg0744    <=   i_regb1         ;//(i) 16'h0144     
            i_reg0748    <=   i_regb2         ;//(i) 16'h0148     
            i_reg074C    <=   i_regb3         ;//(i) 16'h014C     
            i_reg0750    <=   i_regb4         ;//(i) 16'h0150     
            i_reg0754    <=   i_regb5         ;//(i) 16'h0154     
            i_reg0758    <=   i_regb6         ;//(i) 16'h0158     //enc_chk_suc_cnt
            i_reg075C    <=   i_regb7         ;//(i) 16'h015C     //enc_chk_err_cnt
            i_reg0760    <=   i_rega0         ;//(i) 16'h0160     
            i_reg0764    <=   i_rega1         ;//(i) 16'h0164     
            i_reg0768    <=   i_rega2         ;//(i) 16'h0168     
            i_reg076C    <=   i_rega3         ;//(i) 16'h016C     
            i_reg0770    <=   i_rega4         ;//(i) 16'h0170     
            i_reg0774    <=   i_rega5         ;//(i) 16'h0174     
            i_reg0778    <=   i_rega6         ;//(i) 16'h0178     
            i_reg077C    <=   i_rega7         ;//(i) 16'h017C    
            i_reg0780    <=   i_reg0          ;//(i) 16'h0180     
            i_reg0784    <=   i_reg1          ;//(i) 16'h0184     
            i_reg0788    <=   i_reg2          ;//(i) 16'h0188     
            i_reg078C    <=   i_reg3          ;//(i) 16'h018C     
            i_reg0790    <=   i_reg4          ;//(i) 16'h0190     
            i_reg0794    <=   i_reg5          ;//(i) 16'h0194     
            i_reg0798    <=   i_reg6          ;//(i) 16'h0198     
            i_reg079C    <=   i_reg7          ;//(i) 16'h019C    
        end
     
        if(pkt_end_flag_pos && dbg_cnt == 3'd6)begin                 
            i_reg0820    <=   i_regc0         ;//(i) 16'h0120     
            i_reg0824    <=   i_regc1         ;//(i) 16'h0124     
            i_reg0828    <=   i_regc2         ;//(i) 16'h0128     
            i_reg082C    <=   i_regc3         ;//(i) 16'h012C     
            i_reg0830    <=   i_regc4         ;//(i) 16'h0130     
            i_reg0834    <=   i_regc5         ;//(i) 16'h0134     
            i_reg0838    <=   i_regc6         ;//(i) 16'h0138     
            i_reg083C    <=   i_regc7         ;//(i) 16'h013C     
            i_reg0840    <=   i_regb0         ;//(i) 16'h0140     
            i_reg0844    <=   i_regb1         ;//(i) 16'h0144     
            i_reg0848    <=   i_regb2         ;//(i) 16'h0148     
            i_reg084C    <=   i_regb3         ;//(i) 16'h014C     
            i_reg0850    <=   i_regb4         ;//(i) 16'h0150     
            i_reg0854    <=   i_regb5         ;//(i) 16'h0154     
            i_reg0858    <=   i_regb6         ;//(i) 16'h0158     //enc_chk_suc_cnt
            i_reg085C    <=   i_regb7         ;//(i) 16'h015C     //enc_chk_err_cnt
            i_reg0860    <=   i_rega0         ;//(i) 16'h0160     
            i_reg0864    <=   i_rega1         ;//(i) 16'h0164     
            i_reg0868    <=   i_rega2         ;//(i) 16'h0168     
            i_reg086C    <=   i_rega3         ;//(i) 16'h016C     
            i_reg0870    <=   i_rega4         ;//(i) 16'h0170     
            i_reg0874    <=   i_rega5         ;//(i) 16'h0174     
            i_reg0878    <=   i_rega6         ;//(i) 16'h0178     
            i_reg087C    <=   i_rega7         ;//(i) 16'h017C    
            i_reg0880    <=   i_reg0          ;//(i) 16'h0180     
            i_reg0884    <=   i_reg1          ;//(i) 16'h0184     
            i_reg0888    <=   i_reg2          ;//(i) 16'h0188     
            i_reg088C    <=   i_reg3          ;//(i) 16'h018C     
            i_reg0890    <=   i_reg4          ;//(i) 16'h0190     
            i_reg0894    <=   i_reg5          ;//(i) 16'h0194     
            i_reg0898    <=   i_reg6          ;//(i) 16'h0198     
            i_reg089C    <=   i_reg7          ;//(i) 16'h019C    
        end
     
        if(pkt_end_flag_pos && dbg_cnt == 3'd7)begin                 
            i_reg0920    <=   i_regc0         ;//(i) 16'h0120     
            i_reg0924    <=   i_regc1         ;//(i) 16'h0124     
            i_reg0928    <=   i_regc2         ;//(i) 16'h0128     
            i_reg092C    <=   i_regc3         ;//(i) 16'h012C     
            i_reg0930    <=   i_regc4         ;//(i) 16'h0130     
            i_reg0934    <=   i_regc5         ;//(i) 16'h0134     
            i_reg0938    <=   i_regc6         ;//(i) 16'h0138     
            i_reg093C    <=   i_regc7         ;//(i) 16'h013C     
            i_reg0940    <=   i_regb0         ;//(i) 16'h0140     
            i_reg0944    <=   i_regb1         ;//(i) 16'h0144     
            i_reg0948    <=   i_regb2         ;//(i) 16'h0148     
            i_reg094C    <=   i_regb3         ;//(i) 16'h014C     
            i_reg0950    <=   i_regb4         ;//(i) 16'h0150     
            i_reg0954    <=   i_regb5         ;//(i) 16'h0154     
            i_reg0958    <=   i_regb6         ;//(i) 16'h0158     //enc_chk_suc_cnt
            i_reg095C    <=   i_regb7         ;//(i) 16'h015C     //enc_chk_err_cnt
            i_reg0960    <=   i_rega0         ;//(i) 16'h0160     
            i_reg0964    <=   i_rega1         ;//(i) 16'h0164     
            i_reg0968    <=   i_rega2         ;//(i) 16'h0168     
            i_reg096C    <=   i_rega3         ;//(i) 16'h016C     
            i_reg0970    <=   i_rega4         ;//(i) 16'h0170     
            i_reg0974    <=   i_rega5         ;//(i) 16'h0174     
            i_reg0978    <=   i_rega6         ;//(i) 16'h0178     
            i_reg097C    <=   i_rega7         ;//(i) 16'h017C    
            i_reg0980    <=   i_reg0          ;//(i) 16'h0180     
            i_reg0984    <=   i_reg1          ;//(i) 16'h0184     
            i_reg0988    <=   i_reg2          ;//(i) 16'h0188     
            i_reg098C    <=   i_reg3          ;//(i) 16'h018C     
            i_reg0990    <=   i_reg4          ;//(i) 16'h0190     
            i_reg0994    <=   i_reg5          ;//(i) 16'h0194     
            i_reg0998    <=   i_reg6          ;//(i) 16'h0198     
            i_reg099C    <=   i_reg7          ;//(i) 16'h019C    
        end     

    end 
    
    
    
    
    

endmodule












