`timescale 1ns / 1ps


// read ACC and MAG seperately


module I2C_Transmit(    
    //output [7:0] led,
    input  sys_clkn,
    input  sys_clkp,
    output I2C_SCL_1,   //    I2C_SCL_1
    inout  I2C_SDA_1,  //    I2C_SDA_1  
    output PMOD_A1,
    input PMOD_A2,  
    input wire FSM_Clk,    
    input wire ILA_Clk,
    input wire Motor_CLK,
    //output reg FSM_Clk_reg,    
    //output reg ILA_Clk_reg,
    //output reg Motor_CLK_reg,
    output reg ACK_bit,
    output reg SCL,
    output reg SDA,
    output reg [7:0] State,
    input wire [31:0] PC_control,
    //output wire [31:0] PC_control,
    //input  wire    [4:0] okUH,
    //output wire    [2:0] okHU,
    //inout  wire    [31:0] okUHU,  
    //inout wire okAA,
    input wire [7:0] DeviceAddress,
    input wire [7:0] SubRegAddress,
    input wire [7:0] initializeRegisterValues,
    input wire [7:0] initializeRegisterAddress,
    
    //output wire [7:0] DeviceAddress,
    //output wire [7:0] SubRegAddress,
    //output wire [7:0] initializeRegisterValues,
    //output wire [7:0] initializeRegisterAddress,
    input wire [15:0] cycles,
    output [15:0] value
  //  output wire [7:0] Mreturn
   // output wire EN1return
    );
   
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal    
    wire [23:0] ClkDivThreshold = 400;  
 //   wire FSM_Clk, ILA_Clk, Motor_CLK;
//    ClockGenerator ClockGenerator2 (  .sys_clkn(sys_clkn),
//                                      .sys_clkp(sys_clkp),                                      
//                                      .ClkDivThreshold(ClkDivThreshold),
//                                      .FSM_Clk(FSM_Clk),                                      
//                                      .ILA_Clk(ILA_Clk),
//                                      .Motor_CLK(Motor_CLK) );




  
    reg EN1 = 1'b0;
    
    wire [15:0] pulses;    
    reg [7:0] counter = 8'b0;                                    
    reg [7:0] M;
    reg [7:0] Address_ACCL;      //b0011_0010 ACC               //b1001_0000 tempature
    //reg [7:0] Address_MAGN = 8'b0011_1100;
    reg error_bit = 1'b1;  
    reg [15:0] X_Cord = 16'd0;                        // intialize the Cord valutes, to be retured to PC
    reg [15:0] Y_Cord = 16'd0;  
    reg [15:0] Z_Cord = 16'd0;

      reg [7:0] MSB_X_ADD;
      reg [7:0] MSB_X_ADD_ACC;              // ADDRESS of MSB of X_Cord in memory. the MSB is set to 1 for multiple reading
//     reg [7:0] MSB_X_ADD_MAG = 8'b1000_0011;        
   
reg [7:0] CTRL_REG1_ACC;       //Address of Acc for data rate change
//     reg [7:0] CRA_REG_M = 8'b0000_0000;       //Address of Mag for data rate change
//     reg [7:0] CRB_REG_M = 8'b0000_0001;       //Address of Mag for Gain configuration
//     reg [7:0] MR_REG_M = 8'b0000_0010;      // Address of Mag for Mode selection
    
      reg [7:0] CTRL_REG1_ACC_value;        
//     reg [7:0] CRA_REG_M_value = 8'b0001_1100;      
//     reg [7:0] CRB_REG_M_value = 8'b0010_0000;        
//     reg [7:0] MR_REG_M_value = 8'b0000_0000;      

    reg [15:0] tmp = 16'b0000_0000_0000_0000;
    reg Readflag =  1'b0;
    reg [3:0] MotorState = 1'b0;
    reg [3:0] set_param = 4'd1; //which parameter to be set during the initialization
    reg [3:0] total_param_intitial = 4'd4; // total number of parameters needs to be set  
    reg [1:0] writing_mode = 2'd1; // whether need to set parameter during the initialization
    reg [1:0] flag_write = 1'b0;
    reg [1:0] continue_reading = 1'b0; // whether continously read data or not

    localparam STATE_INIT  = 8'd220;
    localparam STATE_GO = 8'd0; 
    localparam STATE_STOP  = 8'd162;
    localparam STATE_NACK  = 8'd170;
    localparam START_AGAIN   = 8'd200;
    localparam STATE_Writing_INIT  = 8'd250;
    localparam State_writing_buffer  = 8'd251;

    //assign led[6] = error_bit;
    //assign led[7] = ACK_bit;
    assign I2C_SCL_1 = SCL;
    assign I2C_SDA_1 = SDA;
    assign PMOD_A1 = EN1;
    assign pulses = cycles;
    assign value = tmp;
    assign Mreturn = M;
    //assign EN1return = EN1; 
    initial  begin
        SCL = 1'b1;
        SDA = 1'b1;
        ACK_bit = 1'b1;  
        State = 8'd0;
        MotorState = 4'd0;
    end
   
//    always @(*) begin          
//        FSM_Clk_reg = FSM_Clk;
//        ILA_Clk_reg = ILA_Clk;  
//        Motor_CLK_reg = Motor_CLK;

//    end  


    always @(posedge Motor_CLK) begin

      case(MotorState)

            4'd0 : begin
                  if(PC_control[0] == 1'b1) begin
                        if(counter < pulses) begin
                              MotorState <= MotorState + 1'b1; EN1 <= 1'b0; end
                        else begin
                              MotorState <= 4'd0; EN1 <= 1'b0; 
                              end
                  end 
                  else begin
                        MotorState <= 4'd0; EN1 <= 1'b0;
                        counter <= 8'd0;
                  end
            end

            4'd1: begin 
                  EN1 <= 1'b1; MotorState <= MotorState + 1'b1; counter <= counter + 1'b1;
            end

            4'd2 : begin 
                  EN1 <= 1'b0; 

                  if(counter < pulses) 
                        MotorState <= 4'b1;
                  else begin
                        MotorState <= 4'd0;
                        //counter <= 4'd0;
                        end
            end
            
            
            4'd3 : begin  //stop 
                counter <= 4'd0;
                //if(PC_control2 == 1'b0)  
                //    MotorState <= 4'd0;
               
            end
            
            
            default : begin 
                MotorState <= 4'd0;
                EN1 <= 1'b0; 
                counter <= 4'd0;
            end




        endcase 


    end


                               
    always @(posedge FSM_Clk) begin    
        MSB_X_ADD_ACC <= SubRegAddress;
        Address_ACCL <= DeviceAddress;
        CTRL_REG1_ACC_value <= initializeRegisterValues;
        CTRL_REG1_ACC <= initializeRegisterAddress;                  
      
        case (State)
            /*  LOAD DEVICE ADDRESS FOR THE I2C PROTOCOL*/
            STATE_Writing_INIT : begin
                 
                        M <= Address_ACCL;
                        MSB_X_ADD <= CTRL_REG1_ACC;  // address for ACC param
                        State <= 8'b1;
                       
            end 
            
            
            STATE_GO : begin 
            if(PC_control[0] == 1'b1)
                State <= STATE_INIT;
            else
                begin SCL <= 1'b1; SDA <= 1'b1; State <= STATE_GO; end  
            end
                
            
            STATE_INIT : begin
                if(writing_mode == 1'b1)
                        State <= STATE_Writing_INIT;
                else begin  // reading mode
                        M <= Address_ACCL;
                        MSB_X_ADD <= MSB_X_ADD_ACC; 
                        if(Readflag == 1'b0) begin
                              M[0] <= 1'b0;   // read or write mode in device address
                              State <= 8'd1;
                        end
                        else begin
                              M[0] <= 1'b1; 
                              State <= 8'd1;
                        end
                end
            end
                
            ///////////////////////////////////////////
            // write device address
            //////////////////////////////////////////
            8'd1 : begin SCL <= 1'b1; SDA <= 1'b0; State <= State + 1'b1; end
            8'd2 : begin SCL <= 1'b0; State <= State + 1'b1; end      
            8'd3 : begin SCL <= 1'b0; SDA <= M[7]; State <= State + 1'b1; end
            8'd4 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd5 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd6 : begin SCL <= 1'b0; State <= State + 1'b1; end  
            // transmit bit 6
            8'd7 : begin SCL <= 1'b0; SDA <= M[6]; State <= State + 1'b1; end  
            8'd8 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd9 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd10 :begin SCL <= 1'b0; State <= State + 1'b1; end  
            // transmit bit 5
            8'd11 : begin SCL <= 1'b0; SDA <= M[5]; State <= State + 1'b1; end  
            8'd12 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd13 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd14 : begin SCL <= 1'b0; State <= State + 1'b1; end  
            // transmit bit 4
            8'd15 : begin SCL <= 1'b0; SDA <= M[4]; State <= State + 1'b1; end  
            8'd16 : begin SCL <= 1'b1; State <= State + 1'b1; end
            8'd17 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd18 : begin SCL <= 1'b0; State <= State + 1'b1; end  
            // transmit bit 3
            8'd19 : begin SCL <= 1'b0; SDA <= M[3]; State <= State + 1'b1; end  
            8'd20 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd21 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd22 : begin SCL <= 1'b0; State <= State + 1'b1; end  
            // transmit bit 2
            8'd23 : begin SCL <= 1'b0; SDA <= M[2]; State <= State + 1'b1; end  
            8'd24 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd25 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd26 : begin SCL <= 1'b0; State <= State + 1'b1; end  
            // transmit bit 1
            8'd27 : begin SCL <= 1'b0; SDA <= M[1]; State <= State + 1'b1; end  
            8'd28 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd29 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd30 : begin SCL <= 1'b0; State <= State + 1'b1; end
            // transmit bit 0
            8'd31 : begin SCL <= 1'b0; SDA <= M[0]; State <= State + 1'b1; end  
            8'd32 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd33 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd34 : begin SCL <= 1'b0; State <= State + 1'b1; end  

            // read the ACK bit from the sensor and display it on LED[7], and we do not have to set
            // SDA, we will read data from sensor via SDA
            8'd35 : begin SCL <= 1'b0; SDA <= 1'bz; State <= State + 1'b1; end  
            8'd182 : begin SCL <= 1'b0;  State <= State + 1'b1; end 
            8'd183 : begin  SCL <= 1'b0;  State <= 8'd36; end 

            8'd36 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd37 : begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1'b1; end      
            8'd38 : begin SCL <= 1'b0;
                        if(Readflag == 1'b1)  
                              State <= 8'd75; //start to read data
                        else
                              State <= State + 1'b1;
                       
                  end
           
            /////////////////////////////////////////////
            // write register Address  [writing data]
            ////////////////////////////////////////////
            8'd39 : begin SCL <= 1'b0; SDA <= MSB_X_ADD[7]; State <= State + 1'b1; end  
            8'd40 : begin SCL <= 1'b1; State <= State + 1'b1; end                                    
            8'd41 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd42 : begin SCL <= 1'b0; State <= State + 1'b1; end              
            8'd43 : begin SCL <= 1'b0; SDA <= MSB_X_ADD[6]; State <= State + 1'b1; end      
            8'd44 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd45 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd46 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd47 : begin SCL <= 1'b0; SDA <= MSB_X_ADD[5]; State <= State + 1'b1; end      
            8'd48 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd49 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd50 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd51 : begin SCL <= 1'b0; SDA <= MSB_X_ADD[4]; State <= State + 1'b1; end
            8'd52 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd53 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd54 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd55 : begin SCL <= 1'b0; SDA <= MSB_X_ADD[3]; State <= State + 1'b1; end  
            8'd56 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd57 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd58 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd59 : begin SCL <= 1'b0; SDA <= MSB_X_ADD[2]; State <= State + 1'b1; end  
            8'd60 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd61 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd62 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd63 : begin SCL <= 1'b0; SDA <= MSB_X_ADD[1]; State <= State + 1'b1; end  
            8'd64 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd65 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd66 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd67 : begin SCL <= 1'b0; SDA <= MSB_X_ADD[0]; State <= State + 1'b1; end
            8'd68 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd69 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd70 : begin SCL <= 1'b0; State <= State + 1'b1; end  


            // ACK from device
            8'd71 : begin SCL <= 1'b0; SDA <= 1'bz; State <= 8'd185; end  
            8'd72 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd73 : begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1'b1; end      
            8'd74 : begin SCL <= 1'b0;
                        if (writing_mode == 1'b1)
                               State <= State_writing_buffer;
                         else begin   //reading state
                               if (Readflag == 1'b0)  
                               State <= 8'd180; 
                               else 
                               State <= State + 1'b1; 
                              end  
                  end


            8'd185 : begin SCL <= 1'b0;  State <= State + 1'b1; end 
            8'd186 : begin  SCL <= 1'b0;  State <= 8'd72; end 
           
            ///////////////////////////////////////////////
            // Read data
            ///////////////////////////////////////////////


            //READ MSB of Cord
            8'd75 : begin SCL <= 1'b0; tmp[15] <= SDA; State <= State + 1'b1; end      
            8'd76 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd77 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd78 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd79 : begin SCL <= 1'b0; tmp[14] <= SDA; State <= State + 1'b1; end      
            8'd80 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd81 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd82 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd83 : begin SCL <= 1'b0; tmp[13] <= SDA; State <= State + 1'b1; end      
            8'd84 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd85 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd86 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd87 : begin SCL <= 1'b0; tmp[12] <= SDA; State <= State + 1'b1; end      
            8'd88 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd89 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd90 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd91 : begin SCL <= 1'b0; tmp[11] <= SDA; State <= State + 1'b1; end      
            8'd92 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd93 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd94 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd95 : begin SCL <= 1'b0; tmp[10] <= SDA; State <= State + 1'b1; end      
            8'd96 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd97 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd98 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd99 : begin SCL <= 1'b0; tmp[9] <= SDA; State <= State + 1'b1; end      
            8'd100 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd101 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd102 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd103 : begin SCL <= 1'b0; tmp[8] <= SDA; State <= State + 1'b1; end      
            8'd104 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd105 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd106: begin SCL <= 1'b0; State <= 8'd115; end


            //ACK from master
            8'd115 : begin SCL <= 1'b0; SDA <= 1'b0; State <= State + 1'b1; end  
            8'd116 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd117 : begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1'b1; end  
            8'd118 : begin SCL <= 1'b0; State <= State + 1'b1; end  
            8'd119 : begin SCL <= 1'b0; SDA <= 1'bz; State <= 8'd122; end


            //READ LSB of Cord
            8'd122 : begin SCL <= 1'b0; tmp[7] <= SDA; State <= State + 1'b1; end      
            8'd123 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd124 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd125 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd126 : begin SCL <= 1'b0; tmp[6] <= SDA; State <= State + 1'b1; end      
            8'd127 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd128 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd129 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd130 : begin SCL <= 1'b0; tmp[5] <= SDA; State <= State + 1'b1; end      
            8'd131 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd132 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd133 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd134 : begin SCL <= 1'b0; tmp[4] <= SDA; State <= State + 1'b1; end      
            8'd135 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd136 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd137 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd138 : begin SCL <= 1'b0; tmp[3] <= SDA; State <= State + 1'b1; end      
            8'd139 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd140 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd141 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd142 : begin SCL <= 1'b0; tmp[2] <= SDA; State <= State + 1'b1; end      
            8'd143 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd144 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd145 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd146 : begin SCL <= 1'b0; tmp[1] <= SDA; State <= State + 1'b1; end      
            8'd147 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd148 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd149 : begin SCL <= 1'b0; State <= State + 1'b1; end
            8'd150 : begin SCL <= 1'b0; tmp[0] <= SDA; State <= State + 1'b1; end      
            8'd151 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd152 : begin SCL <= 1'b1; State <= State + 1'b1; end    
            8'd153 : begin SCL <= 1'b0; if (continue_reading==1'b0) State <= STATE_NACK; else State <= State + 1'b1; end

           
            //ACK from master
            8'd154 : begin SCL <= 1'b0; SDA <= 1'b0; State <= State + 1'b1; end     //SDAtmp
            8'd155 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd156 : begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1'b1; end  
            8'd157 : begin SCL <= 1'b0; State <= State + 1'b1; end  
            8'd158 : begin SCL <= 1'b0;  SDA <= 1'bz; State <= 8'd75; end  // start to read data
            
            

            ///

            8'd180: begin  SCL <= 1'b0; Readflag <= 1'b1; State <= START_AGAIN; end

            ///


            /////////////////////////////////////////////
            // start again
            ////////////////////////////////////////////
            START_AGAIN : begin SCL <= 1'b0; SDA <= 1'b1; State <= State + 1'b1; end      // to start we need to lower SDA while SCL is hig
            8'd201 : begin SCL <= 1'b1; State <= State + 1'b1; end
            8'd202 : begin SCL <= 1'b1; SDA <= 1'b1; State <= STATE_INIT; end// to start we need to lower SDA while SCL is high    


            /////////////////////////////////////////////
            // NACK from master
            ////////////////////////////////////////////
            STATE_NACK : begin SCL <= 1'b0; SDA <= 1'b1; State <= State + 1'b1; end     
            8'd171 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd172 : begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1'b1; end  
            8'd173 : begin SCL <= 1'b0; Readflag=1'b0; State <= STATE_STOP;  end   // STATE_STOP;

            //////////////////////////////////
            // stop mode
            /////////////////////////////////
            STATE_STOP: begin SCL <= 1'b0; SDA <= 1'b0; State <= State + 1'b1;  end                 // stop    
            8'd163 : begin SCL <= 1'b1; State <= State + 1'b1; end  
            8'd164 : begin SCL <= 1'b1; SDA <= 1'b1; Readflag =  1'b0; writing_mode = 2'd1; flag_write = 1'b0; State <= STATE_GO; end 
            //set initalization para
        
        
            /////////////////////////////////////////////////////////////////////////
            // write data to sensor
            ////////////////////////////////////////////////////////////////////////
            State_writing_buffer: begin SCL <= 1'b0;        //state 251
                  // either it is stop or read
                  if (flag_write == 1'b1) begin // go to stop
                        writing_mode <= 1'b0;
                        State <= START_AGAIN; //STATE_INIT;
                        
                        end
                 else begin
                               // start to set param for both acc and mag
                              MSB_X_ADD <= CTRL_REG1_ACC_value;  // set MAG param
                              State <= 8'd181;           
                                
                        end
                  end


            8'd181 : begin SCL <= 1'b0; flag_write <= 1'b1; State <= 8'd39; end

            //If the FSM ends up in this state, there was an error in teh FSM code
            //LED[6] will be turned on (signal is active low) in that case.
            default : begin
                  error_bit <= 0;
            end                              
        endcase                      
    end      




      /////////////////////////////////////////////////// 
      //FSM for Motor 
      //////////////////////////////////////////////////////////////////////////////







         
                   
endmodule
