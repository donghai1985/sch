module cmip_intc #(
    parameter                     DATA_WDTH  =   32    
)(                                
    input                         i_clk                ,  
    input                         i_rst_n              , 

    input                         i_irq_polar          ,
    input                         i_irq_level          ,
    input       [DATA_WDTH-1:0]   i_clr                ,
    input       [DATA_WDTH-1:0]   i_enable             ,
    output reg  [DATA_WDTH-1:0]   o_irq_flag           ,
    input       [DATA_WDTH-1:0]   i_sig                , 
    output                        o_irq                
);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------------------
    reg                           i_sig_d1             ;
    wire                          irq_level_out        ;
    wire                          irq_rising_out       ;
    reg                           irq_level_out_d1     ;
    reg                           irq_level_out_d2     ;
    
    
    assign      irq_level_out  =  i_irq_polar ? (|o_irq_flag) : ~(|o_irq_flag) ;
    assign      irq_rising_out =  i_irq_polar ? (irq_level_out_d1 && (~irq_level_out_d2)) : ((~irq_level_out_d1) && irq_level_out_d2);
    assign      o_irq          =  i_irq_level ? irq_level_out : irq_rising_out ;

// =================================================================================================
// RTL Body
// =================================================================================================

    //-----------------irq-------------------------------------
    always@(posedge i_clk or negedge i_rst_n)           
        if(!i_rst_n) 
            o_irq_flag <= 3'd0;
        else if(|i_clr)
            o_irq_flag <= o_irq_flag & (~i_clr);
        else if(|(i_sig & i_enable))
            o_irq_flag <= (i_sig & i_enable) | o_irq_flag;

    always@(posedge i_clk or negedge i_rst_n)     
        if(!i_rst_n) begin
            irq_level_out_d1 <= 1'b0;
            irq_level_out_d2 <= 1'b0;
        end else begin
            irq_level_out_d1 <=  irq_level_out;
            irq_level_out_d2 <= irq_level_out_d1;
        end




endmodule
