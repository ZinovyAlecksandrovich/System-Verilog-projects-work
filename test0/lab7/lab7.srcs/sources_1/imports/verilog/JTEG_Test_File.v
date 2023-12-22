`timescale 1ns / 1ps

module JTEG_Test_File(   
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,  
    output I2C_SCL_1,
    inout I2C_SDA_1,
    output PMOD_A1,
    output PMOD_A2,  
    input  [4:0] okUH,
    output [2:0] okHU,
    inout  [31:0] okUHU,
    inout  okAA
     
);

    wire  ILA_Clk, ACK_bit, FSM_Clk, TrigerEvent, Motor_CLK;    
    wire [23:0] ClkDivThreshold = 1_000;   
    wire SCL, SDA; 
    wire [7:0] State;
    wire [31:0] PC_control;
    wire [7:0] DeviceAddress;
    wire [7:0] SubRegAddress;
    wire [7:0] initializeRegisterValues;
    wire [7:0] initializeRegisterAddress;
    
    assign TrigerEvent = PC_control[0];   

    //Instantiate the module that we like to test
    I2C_Transmit I2C_Test1 (        
        .led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .I2C_SCL_1(I2C_SCL_1),
        .I2C_SDA_1(I2C_SDA_1), 
        .PMOD_A1(PMOD_A1),
        .PMOD_A2(PMOD_A2), 
        .FSM_Clk_reg(FSM_Clk),        
        .ILA_Clk_reg(ILA_Clk),
        .Motor_CLK_reg(Motor_CLK),
        .ACK_bit(ACK_bit),
        .SCL(SCL),
        .SDA(SDA),
        .State(State),
        .PC_control(PC_control),
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA),
        .DeviceAddress(DeviceAddress),
        .SubRegAddress(SubRegAddress),
        .initializeRegisterValues(initializeRegisterValues),
        .initializeRegisterAddress(initializeRegisterAddress)
        );
    
    //Instantiate the ILA module
    ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({State, SDA, SCL, ACK_bit}),                             
        .probe1({FSM_Clk, TrigerEvent})
        );                        
endmodule