module spi_master(
    input                                clk              ,
    input                                rst_n            ,
                                                          
    input         [1:0]                  mode             ,
    input         [7:0]                  frediv           ,
                                                          
    input                                trig             ,
    output   reg                         finish           ,
    input         [7:0]                  writedata        ,
    output   reg  [7:0]                  readdata         ,
                                                          
    output                               cs               ,
    output                               sck              ,
    output   reg                         mosi             ,
    input                                miso             
);
/*设计说明：designed by wqh 2018-12-22
      1.主要实现了主机SPI协议
      2.mode=={CPHA,CPOL},即实现了真正意义上的SPI协议，支持四种模式
      3.为了支持多个片选，可以在本程序上修改，将cs进入译码器，从而产生多个片选
      4.为了支持SPI在一个CS周期下，完成16bit、24bit等传输，可以忽略本程序的cs
*/

    // -------------------------------------------------------------------------
    // Internal Parameter Definition
    // -------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    // Internal signal definition
    // -------------------------------------------------------------------------
    reg           [7:0]                  indatareg        ;
    reg           [7:0]                  outdatareg       ;
    reg           [7:0]                  cnt              ;
    wire                                 enable           ;
    reg           [4:0]                  state            ;
    reg                                  sck_reg          ;
    reg                                  sck_reg_d1       ;
    reg                                  sck_reg_d2       ;
    wire                                 sckh2l           ;
    wire                                 sckl2h           ;
    wire          [7:0]                  frediv_tmp       ;
    wire                                 sck_neg          ;
    wire                                 sck_pos          ;
    // -------------------------------------------------------------------------
    // Output
    // -------------------------------------------------------------------------
    assign     enable     =    (state==5'b0)?1'b0:1'b1       ;
    assign     cs         =    ~enable                       ;
    assign     sck        =   mode[0]? sck_neg : sck_pos     ;
    assign     sck_neg    =   ~sck_reg_d1 || cs              ;
    assign     sck_pos    =    sck_reg_d1 && (~cs)           ;
    assign     sckh2l     =   (~sck_reg) && sck_reg_d1       ;
    assign     sckl2h     =   (~sck_reg_d1) && sck_reg       ;
    //assign     frediv_tmp =   (frediv >= 8'd5) ? frediv : 8'd5;
    assign     frediv_tmp =   (frediv >= 8'd1) ? frediv : 8'd1;
// =================================================================================================
// RTL Body
// =================================================================================================


    // -------------------------------------------------------------------------
    // clk divide ---->  sck
    // -------------------------------------------------------------------------
/*
    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            cnt<=8'd0;
        else if(enable)
            cnt<=cnt+1'b1;
        else 
            cnt<=8'd0;
            
    
    always@(*)begin
        case(frediv)
        3'd0:sck_reg=cnt[0];
        3'd1:sck_reg=cnt[1];
        3'd2:sck_reg=cnt[2];
        3'd3:sck_reg=cnt[3];
        3'd4:sck_reg=cnt[4];
        3'd5:sck_reg=cnt[5];
        3'd6:sck_reg=cnt[6];
        3'd7:sck_reg=cnt[7];
        default:sck_reg=cnt[0];
        endcase
    end
*/
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt<=8'd0;
        else if(enable)
            if(cnt == frediv_tmp)
                cnt<=8'd0;
            else
                cnt<=cnt+1'b1;
        else
            cnt<=8'd0;
    end

    always@(*)begin
        if(cnt <= frediv_tmp/2)
            sck_reg <= 1'b0;
        else 
            sck_reg <= 1'b1;
    end

    // always@(posedge clk) begin
    //     sck <= mode[0]?(~sck_reg||cs):(sck_reg&&(~cs));
    // end


    always@(posedge clk or negedge rst_n)
        if(!rst_n)begin
            sck_reg_d1 <= 1'b0;
            sck_reg_d2 <= 1'b0;
        end else begin     
            sck_reg_d1 <= sck_reg   ;
            sck_reg_d2 <= sck_reg_d1;
        end

    
//    H2L i1(.clk(clk),.rst_n(rst_n),.signal(sck_reg),.myoutH2L(sckh2l),.myoutL2H(sckl2h));    
    // -------------------------------------------------------------------------
    // fsm.
    // -------------------------------------------------------------------------
    initial state=5'd0;
    always@(posedge clk or negedge rst_n)
        if(!rst_n)
        begin
            state<=5'd0;
            indatareg<=8'd0;
        end else begin
            state<=state;
            indatareg<=indatareg;
            case(state)
                5'd0 :if(trig)   begin state<=state+1'b1;indatareg<=writedata;end 
                5'd1 :state<=state+1'b1; 
                5'd2 :if(sckl2h) begin state<=state+1'b1;end
                5'd3 :if(sckh2l) begin state<=state+1'b1;end
                5'd4 :if(sckl2h) begin state<=state+1'b1;end
                5'd5 :if(sckh2l) begin state<=state+1'b1;end
                5'd6 :if(sckl2h) begin state<=state+1'b1;end
                5'd7 :if(sckh2l) begin state<=state+1'b1;end
                5'd8 :if(sckl2h) begin state<=state+1'b1;end
                5'd9 :if(sckh2l) begin state<=state+1'b1;end
                5'd10:if(sckl2h) begin state<=state+1'b1;end
                5'd11:if(sckh2l) begin state<=state+1'b1;end    
                5'd12:if(sckl2h) begin state<=state+1'b1;end
                5'd13:if(sckh2l) begin state<=state+1'b1;end    
                5'd14:if(sckl2h) begin state<=state+1'b1;end
                5'd15:if(sckh2l) begin state<=state+1'b1;end    
                5'd16:if(sckl2h) begin state<=state+1'b1;end
                5'd17:if(sckh2l) begin state<=state+1'b1;end    
                5'd18:begin state<=5'd0;end
                default:begin
                    state<=state;
                    indatareg<=indatareg;
                end    
            endcase
        end
    
    always@(posedge clk or negedge rst_n)//mosi
        if(!rst_n)
            mosi<=1'b0;
        else if(~mode[1])begin
            case(state)
                5'd1 :mosi<=indatareg[7];
                5'd3 :if(sckh2l)mosi<=indatareg[6];
                5'd5 :if(sckh2l)mosi<=indatareg[5];
                5'd7 :if(sckh2l)mosi<=indatareg[4];
                5'd9 :if(sckh2l)mosi<=indatareg[3];
                5'd11:if(sckh2l)mosi<=indatareg[2];
                5'd13:if(sckh2l)mosi<=indatareg[1];
                5'd15:if(sckh2l)mosi<=indatareg[0];    
                default:mosi<=mosi;    
            endcase
        end else begin
            case(state)
                5'd2 :if(sckl2h)mosi<=indatareg[7];
                5'd4 :if(sckl2h)mosi<=indatareg[6];
                5'd6 :if(sckl2h)mosi<=indatareg[5];
                5'd8 :if(sckl2h)mosi<=indatareg[4];
                5'd10:if(sckl2h)mosi<=indatareg[3];
                5'd12:if(sckl2h)mosi<=indatareg[2];
                5'd14:if(sckl2h)mosi<=indatareg[1];    
                5'd16:if(sckl2h)mosi<=indatareg[0];    
                default:    mosi<=mosi;    
            endcase        
        end
        
    always@(posedge clk or negedge rst_n)//miso
        if(!rst_n)    
            outdatareg<=8'd0;
        else if(~mode[1])begin
            outdatareg<=outdatareg;    
            case(state)
                5'd2 :if(sckl2h)outdatareg[7]<=miso;
                5'd4 :if(sckl2h)outdatareg[6]<=miso;
                5'd6 :if(sckl2h)outdatareg[5]<=miso;
                5'd8 :if(sckl2h)outdatareg[4]<=miso;
                5'd10:if(sckl2h)outdatareg[3]<=miso;
                5'd12:if(sckl2h)outdatareg[2]<=miso;
                5'd14:if(sckl2h)outdatareg[1]<=miso;
                5'd16:if(sckl2h)outdatareg[0]<=miso;
                default:outdatareg<=outdatareg;    
            endcase
        end else begin
            outdatareg<=outdatareg;    
            case(state)
                5'd3 :if(sckh2l)outdatareg[7]<=miso;
                5'd5 :if(sckh2l)outdatareg[6]<=miso;
                5'd7 :if(sckh2l)outdatareg[5]<=miso;
                5'd9 :if(sckh2l)outdatareg[4]<=miso;
                5'd11:if(sckh2l)outdatareg[3]<=miso;
                5'd13:if(sckh2l)outdatareg[2]<=miso;
                5'd15:if(sckh2l)outdatareg[1]<=miso;
                5'd17:if(sckh2l)outdatareg[0]<=miso;
                default:outdatareg<=outdatareg;    
            endcase
        end
            
    
    always@(posedge clk or negedge rst_n)//finish
        if(!rst_n)
            finish<=1'b0;
        else begin
            case(state)
            5'd18:finish<=1'b1;
            default:finish<=1'b0;
            endcase
        end
        
    always@(posedge clk or negedge rst_n)//readdata
        if(!rst_n)
            readdata<=8'd0;
        else begin
            case(state)
            5'd18:readdata<=outdatareg;
            default:readdata<=readdata;
            endcase
        end    
        


endmodule

