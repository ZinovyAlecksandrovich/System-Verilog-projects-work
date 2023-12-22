`timescale 1ns / 1ps

module SPI_Transmit(    
    output [7:0] led,
    input  sys_clkn,
    input  sys_clkp,
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output  CVM300_SPI_CLK,
    input  CVM300_SPI_OUT,
    output  CVM300_SPI_EN,
    output CVM300_SPI_IN,
    output reg SPI_IN_REG,
    output reg SPI_OUT_REG,
    output reg SPI_EN_REG,
    output reg SPI_CLK_REG,
    output reg [7:0] State,
    output wire [31:0] PC_control,
    input  wire    [4:0] okUH,
    output wire    [2:0] okHU,
    inout  wire    [31:0] okUHU,  
    inout wire okAA,
    output wire [15:0] RegAddress
    );

    wire [23:0] ClkDivThreshold = 5;  
    wire FSM_Clk, ILA_Clk;
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk)
                                      );



    localparam STATE_INIT = 8'd0;
    localparam STATE_GO = 8'd150;

    reg SEND_STOP;
    reg [7:0] tmp = 8'd1;
    reg [7:0] M = 8'd0;
    reg error_bit = 1'b1;  
    assign led[6] = error_bit;
    assign CVM300_SPI_IN = SPI_IN_REG;
    assign CVM300_SPI_EN = SPI_EN_REG;
    assign CVM300_SPI_OUT = SPI_OUT_REG;
    assign CVM300_SPI_CLK = SPI_CLK_REG;


    initial begin
        SPI_CLK_REG = 1'b0;
        State = 8'd0;
        SPI_EN_REG = 1'b0;
        SEND_STOP = 1'b0;
        SPI_IN_REG = 1'b0;
    end


    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;  
        
    end  


    always @(posedge FSM_Clk) begin


        case(State)


            STATE_INIT : begin 
                    SPI_IN_REG <= 1'b0;
                    if(PC_control[0]) begin 
                        M <= RegAddress[15:8]; 
                        State <= 8'd207;
                        SPI_CLK_REG <= 1'b0;
                    end else begin 
                        SPI_CLK_REG <= 1'b0;
                        State <= 8'd0;
                        SPI_EN_REG <= 1'b0;
                    end
            end

        
            // START SPI //
            8'd207 : begin SPI_CLK_REG <= 1'b0; SPI_EN_REG <= 1'b1; State <= 1'b1; SPI_IN_REG <= M[7];  end
            8'd1 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd2 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd3 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd4 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; SPI_IN_REG <= M[6]; end
            8'd5 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd6 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd7 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd8 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; SPI_IN_REG <= M[5]; end
            8'd9 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd10 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd11 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd12 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; SPI_IN_REG <= M[4]; end
            8'd13 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd14 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd15 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd16 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1;  SPI_IN_REG <= M[3]; end
            8'd17 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd18 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd19 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd20 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; SPI_IN_REG <= M[2]; end
            8'd21 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd22 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd23 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd24 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; SPI_IN_REG <= M[1];  end
            8'd25 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd26 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd27 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd28 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; SPI_IN_REG <= M[0]; end
            8'd29 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd30 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd31 : begin SPI_CLK_REG <= 1'b1; State <= 8'd36; end

            8'd36 : begin   
                    SPI_CLK_REG <= 1'b0;
                    if(SEND_STOP) 
                        State <= 8'd69;
                    else begin
                    if(RegAddress[15]) begin
                        M[6:0] <= RegAddress[6:0];
                        SEND_STOP <= 1'b1;
                        State <= 8'd1;
                        SPI_IN_REG <= RegAddress[7];
                    end else 
                        State <= State + 1'b1;

                    end
                    
            end

        

            //READING from SPI_OUT

            8'd37 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; SPI_IN_REG <= 1'b0; end 
            8'd38 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; tmp[7] <= SPI_OUT_REG; end
            8'd39 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd40 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end
            8'd41 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd42 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; tmp[6] <= SPI_OUT_REG; end
            8'd43 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd44 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end
            8'd45 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd46 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; tmp[5] <= SPI_OUT_REG; end
            8'd47 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd48 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end
            8'd49 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd50 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; tmp[4] <= SPI_OUT_REG; end
            8'd51 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd52 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end
            8'd53 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd54 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; tmp[3] <= SPI_OUT_REG; end
            8'd55 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd56 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end
            8'd57 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd58 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; tmp[2] <= SPI_OUT_REG; end
            8'd59 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd60 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end
            8'd61 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd62 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; tmp[1] <= SPI_OUT_REG; end
            8'd63 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd64 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end
            8'd65 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd66 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; tmp[0] <= SPI_OUT_REG; end
            8'd67 : begin SPI_CLK_REG <= 1'b1; State <= State + 1'b1; end
            8'd68 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end


            //STOP//
            8'd69 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; end 
            8'd70 : begin SPI_CLK_REG <= 1'b0; State <= State + 1'b1; SPI_EN_REG <= 1'b0;end
            8'd71 : begin SPI_CLK_REG <= 1'b0; State <= STATE_GO; end
         



            STATE_GO : begin  SPI_CLK_REG <= 1'b0; State <= 8'd0; SPI_EN_REG <= 1'b0; SEND_STOP <= 1'b0;  end




        default : begin 
            error_bit <= 0; 
        end
        endcase

    end




//    // OK Interface
   wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
   wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication
   
   //This is the OK host that allows data to be sent or recived    
   okHost hostIF (
       .okUH(okUH),
       .okHU(okHU),
       .okUHU(okUHU),
       .okClk(okClk),
       .okAA(okAA),
       .okHE(okHE),
       .okEH(okEH)
   );
     localparam  endPt_count = 7;
     wire [endPt_count*65-1:0] okEHx;  
     okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);

    okWireIn wire10 (   .okHE(okHE),
                       .ep_addr(8'h00),
                       .ep_dataout(PC_control[0]));   

    okWireIn wire11 (   .okHE(okHE),
                       .ep_addr(8'h01),
                       .ep_dataout(RegAddress[15:8]));     
    okWireIn wire12 (   .okHE(okHE),
                       .ep_addr(8'h02),
                       .ep_dataout(RegAddress[7:0]));  


    okWireOut wire20 (  .okHE(okHE),
                       .okEH(okEHx[ 0*65 +: 65 ]),
                       .ep_addr(8'h20),
                       .ep_datain(tmp));


    
    
    
    endmodule








