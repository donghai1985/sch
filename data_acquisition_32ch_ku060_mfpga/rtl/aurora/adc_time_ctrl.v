module adc_time_ctrl(
    input                                   clk                            ,//(i)
    input                                   rst_n                          ,//(i)

    input                                   cfg_rst                        ,//(i)
    input             [31:0]                cfg_time                       ,//(i)
    input                                   time_trig                      ,//(i)

    output                                  adc_start_pos                  ,//(o)
    output                                  adc_end_pos                     //(o)

);

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    localparam                              IDLE     =      4'h00          ;
    //---------------------------------------------------------------------
    // Defination of Internal Signals
    //---------------------------------------------------------------------
    reg               [31:0]                cnt                             ;
	reg               [7 :0]                cnt2                            ;
    wire                                    time_trig_pos                   ;
    reg                                     time_trig_d1                    ;
    reg                                     time_trig_d2                    ;
    // -------------------------------------------------------------------------
    // output
    // -------------------------------------------------------------------------
    assign            time_trig_pos  =   ~time_trig_d2 && time_trig_d1      ;
    assign            adc_start_pos  =    (cnt == cfg_time) && (cnt2 <= 20) ;
    assign            adc_end_pos    =    (cnt == 32'd1)   &&  (cnt2 <= 20) ;
// =================================================================================================
// RTL Body
// =================================================================================================
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            time_trig_d1   <= 1'b0;
            time_trig_d2   <= 1'b0;
        end else begin
            time_trig_d1   <= time_trig;
            time_trig_d2   <= time_trig_d1;
        end
    end
	
	
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
		    cnt2 <= 8'd0;
        else if(cfg_rst)
            cnt2 <= 8'd0;
		else if(cnt == 32'd0)
		    cnt2 <= 8'd0;
		else if(cnt2==8'd99)
		    cnt2 <= 8'd0;
		else 
		    cnt2 <= cnt2 + 1;
    end
			
	

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            cnt <= 32'd0;
        else if(cfg_rst)
            cnt <= 32'd0;
        else if(time_trig_pos)
            cnt <= cfg_time;
        else if((|cnt) && (cnt2==8'd99))
            cnt <= cnt - 1'b1;
    end


endmodule





