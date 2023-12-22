 `timescale 1 ps / 1 ps


 module BTPipeExample(
     input   wire    [4:0] okUH,
     output  wire    [2:0] okHU,
     inout   wire    [31:0] okUHU,
     inout   wire    okAA,
     input [3:0] button,
     output [7:0] led,
     input sys_clkn,
     input sys_clkp,
     output CVM300_CLK_IN, 
     input CVM300_CLK_OUT,
     input[9:0] CVM300_D,
     input CVM300_Data_valid,
     output CVM300_FRAME_REQ,
     output I2C_SCL_1,
     inout I2C_SDA_1,
     output PMOD_A1,
     output PMOD_A2
     );
    
     wire okClk;            //These are FrontPanel wires needed to IO communication    
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
        
     //Depending on the number of outgoing endpoints, adjust endPt_count accordingly.
     //In this example, we have 1 output endpoints, hence endPt_count = 1.
     localparam  endPt_count = 20;
     wire [endPt_count*65-1:0] okEHx;  
     okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);    
    
     //Instantiate the ClockGenerator module, where three signals are generate:
     //High speed CLK signal, Low speed FSM_Clk signal     
     wire [23:0] ClkDivThreshold = 5;   
     wire FSM_Clk, ILA_Clk, MotorClk; 
     reg [20:0] counter = 21'd0;
  
     wire Out;
     reg Raise_REQ_FLAG;
     
     ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                       .sys_clkp(sys_clkp),                                      
                                       .ClkDivThreshold(ClkDivThreshold),
                                       .FSM_Clk(FSM_Clk),                                      
                                       .ILA_Clk(ILA_Clk),
                                       .Motor_CLK(MotorClk) );

     

     assign CVM300_CLK_IN = FSM_Clk; 
     assign Out = CVM300_CLK_OUT;

  
                                                                                  
     localparam STATE_INIT                = 8'd0;
     localparam STATE_RESET               = 8'd1;   
     localparam STATE_DELAY               = 8'd2;
     localparam STATE_RESET_FINISHED      = 8'd3;
     localparam STATE_ENABLE_WRITING      = 8'd4;
     localparam STATE_COUNT               = 8'd5;
    
  
     localparam STATE_LOWER_SPI            = 8'd8;       
     localparam STATE_FRAME               = 8'd9;
   
   
     reg [15:0] counter_delay = 16'd0;
     reg [7:0] State = STATE_INIT;
     reg [7:0] led_register = 0;
     reg [3:0] button_reg, write_enable_counter;  
     reg write_reset, read_reset, write_enable;
     wire [31:0] Reset_Counter;
     wire FIFO_read_enable, FIFO_BT_BlockSize_Full, FIFO_full, FIFO_empty, BT_Strobe;
     wire [31:0] FIFO_data_out;
     reg CVM_FRAM_REQ, CVM_SYS_REG_N;
    


     assign led[0] = ~FIFO_empty; 
     assign led[1] = ~FIFO_full;
     assign led[2] = ~FIFO_BT_BlockSize_Full;
     assign led[3] = ~FIFO_read_enable;  
     assign led[7] = ~read_reset;
     assign led[6] = ~write_reset;


     assign CVM300_FRAME_REQ = CVM_FRAM_REQ;
    

     initial begin
         write_reset <= 1'b0;
         read_reset <= 1'b0;
         write_enable <= 1'b1;    
        // CVM_SYS_REG_N <= 1'b0;
         CVM_FRAM_REQ <= 1'b0;
         //Start <= 1'b0;
         Raise_REQ_FLAG = 1'b0;
      end
       
                              
      always @(posedge FSM_Clk) begin     
          button_reg <= ~button;   // Grab the values from the button, complement and store them in register                
          if (Reset_Counter[0] == 1'b1) State <= STATE_RESET;
        
          case (State)
              STATE_INIT:   begin   
              if(counter < 21'd1) begin //300000
                 counter <= counter + 1'b1;
                   State <= STATE_INIT;  
                     end else
                begin                 
                  if (Reset_Counter[0] == 1'b1) // Write a delay before SYS_RES gets raised
                        begin State <= STATE_RESET; counter <= 21'b0; end 
                  else
                    State <= STATE_INIT;
                 
               end  
              end
            
              STATE_RESET:   begin   
                if(counter < 21'd1) begin //300000
                    counter <= counter + 1'b1;
                    State <= STATE_RESET;
                end else 
                begin
                    //Start <= 1'b1;
                   //NEED delay before signaling SPI settings, raise SPI Flag 
                  counter_delay <= 0;
                  write_reset <= 1'b1;
                  read_reset <= 1'b1;           
                  if (Reset_Counter[0] == 1'b0) State <= STATE_LOWER_SPI;    
                 end       
              end     
              
              
              STATE_LOWER_SPI: begin 
                 // Start <= 1'b0;
                  State <= STATE_RESET_FINISHED;
              end
                                              
 
             STATE_RESET_FINISHED:   begin                  //Go to another state to lower SPI FLAG 
                  write_reset <= 1'b0;                      
                  read_reset <= 1'b0;                 
                  State <= STATE_DELAY;
                  counter <= 21'd0;
              end   



      
              STATE_DELAY:   begin //fifo resets
                  if (counter_delay == 16'b0000_0000_0000_1111)  State <= STATE_ENABLE_WRITING;   // if (counter_delay == 16'b0000_1111_1111_1111)
                  else counter_delay <= counter_delay + 1;
              end

   
            
               STATE_ENABLE_WRITING:   begin  //need delay to set FRAM REQ
                   if(counter < 21'd1) begin 
                               counter <= counter + 1'b1;
                               State <= STATE_ENABLE_WRITING;
                      end else begin 
                          Raise_REQ_FLAG <= 1'b1;
                          State <= STATE_FRAME;
                      end
                    end
           
              STATE_FRAME : begin 
                  Raise_REQ_FLAG <= 1'b0;    
                  State <= STATE_INIT;
              end
            
          endcase
      end    
      
      
      reg OUT_STATE = 1'b0;
      
      
      
      
      always @(posedge FSM_Clk)begin
      
        case (OUT_STATE) 
        
        
        1'b0:   begin     if(Raise_REQ_FLAG == 1'b1)begin 
                            CVM_FRAM_REQ <= 1'b1;
                            OUT_STATE <= 1'b1;
                        end else 
                        OUT_STATE <= 1'b0;
               end
                

        1'b1: begin
                CVM_FRAM_REQ <= 1'b0;
                OUT_STATE <= 1'b0;
                
        end      
 

        endcase
    
    end
    
     wire ACK_bit, TrigerEvent;  
     wire SCL, SDA; 
     wire [7:0] I2C_State;
     wire [31:0] PC_control;
     wire [7:0] DeviceAddress, M;
     wire [7:0] SubRegAddress;
     wire [7:0] initializeRegisterValues;
     wire [7:0] initializeRegisterAddress;
     wire [15:0] tmp;
     wire EN1;
     wire [15:0] pulses;
     

     fifo_generator_0 FIFO_for_Counter_BTPipe_Interface (
         .wr_clk(~CVM300_CLK_OUT),
         .wr_rst(write_reset),
         .rd_clk(okClk),
         .rd_rst(read_reset),
         .din(CVM300_D[9:2]),
         .wr_en(CVM300_Data_valid),
         .rd_en(FIFO_read_enable),
         .dout(FIFO_data_out),
         .full(FIFO_full),
         .empty(FIFO_empty),       
         .prog_full(FIFO_BT_BlockSize_Full)        
     );
      
     okBTPipeOut CounterToPC (
         .okHE(okHE), 
         .okEH(okEHx[ 0*65 +: 65 ]),
         .ep_addr(8'ha0), 
         .ep_datain({FIFO_data_out[7:0], FIFO_data_out[15:8], FIFO_data_out[23:16], FIFO_data_out[31:24]}),
         .ep_read(FIFO_read_enable),
         .ep_blockstrobe(BT_Strobe), 
         .ep_ready(FIFO_BT_BlockSize_Full)
     );                                      
    
    
    I2C_Transmit I2C_Test1 (        
        //.led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .I2C_SCL_1(I2C_SCL_1),
        .I2C_SDA_1(I2C_SDA_1), 
        .PMOD_A1(PMOD_A1),
        .PMOD_A2(PMOD_A2),
        .FSM_Clk(FSM_Clk),        
        .ILA_Clk(ILA_Clk),
        .Motor_CLK(MotorClk),
        .ACK_bit(ACK_bit),
        .SCL(SCL),
        .SDA(SDA),
        .State(I2C_State),
        .PC_control(PC_control),
        .DeviceAddress(DeviceAddress),
        .SubRegAddress(SubRegAddress),
        .initializeRegisterValues(initializeRegisterValues),
        .initializeRegisterAddress(initializeRegisterAddress),
        .cycles(pulses),
        .value(tmp)
       // .Mreturn(M),
        //.EN1return(EN1)
        );
    
     
     
     
     
    
     okWireIn wire10 (   .okHE(okHE), 
                         .ep_addr(8'h00), 
                         .ep_dataout(Reset_Counter));

   //This is the OK host that allows data to be sent or recived    

    
     


      okWireIn wire11 (   .okHE(okHE),
                       .ep_addr(8'h01),
                       .ep_dataout(DeviceAddress));     

      okWireIn wire12 (   .okHE(okHE),
                       .ep_addr(8'h02),
                       .ep_dataout(SubRegAddress)); 
      
      okWireIn wire13 (   .okHE(okHE),
                       .ep_addr(8'h03),
                       .ep_dataout(initializeRegisterValues)); 

            
      okWireIn wire14 (   .okHE(okHE),
                       .ep_addr(8'h04),
                       .ep_dataout(initializeRegisterAddress)); 


                             
      okWireIn wire15 (   .okHE(okHE),
                       .ep_addr(8'h05),
                       .ep_dataout(pulses)); 

            
      okWireIn wire16 (   .okHE(okHE),
                       .ep_addr(8'h06),
                       .ep_dataout(PMOD_A2)); 

      okWireIn wire17 (   .okHE(okHE),
                       .ep_addr(8'h07),
                       .ep_dataout(PC_control[0]));   


     okWireOut wire20 (  .okHE(okHE),
                       .okEH(okEHx[ 1*65 +: 65 ]),
                       .ep_addr(8'h20),
                       .ep_datain(tmp));

     okWireOut wire21 (  .okHE(okHE),
                       .okEH(okEHx[ 2*65 +: 65 ]),
                       .ep_addr(8'h21),
                       .ep_datain(M));

                       //EN1

      //okWireOut wire22 (  .okHE(okHE),
       //                .okEH(okEHx[ 3*65 +: 65 ]),
        //               .ep_addr(8'h22),
        //              .ep_datain(EN1));
      


























    
     ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({CVM300_D, CVM300_Data_valid, CVM300_CLK_IN, Out, State, CVM_FRAM_REQ, FSM_Clk}),                             
        .probe1({FSM_Clk,CVM300_Data_valid })
        );        
     


endmodule



