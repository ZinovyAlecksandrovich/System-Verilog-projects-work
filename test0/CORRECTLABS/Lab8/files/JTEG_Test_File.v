`timescale 1ns / 1ps

module JTEG_Test_File(   
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,  
    output  CVM300_SPI_CLK,
    input  CVM300_SPI_OUT,
    output  CVM300_SPI_EN,
    output CVM300_SPI_IN,
    input  [4:0] okUH,
    output [2:0] okHU,
    inout  [31:0] okUHU,
    inout  okAA
     
);

    wire  ILA_Clk, SPI_CLK_REG, FSM_Clk;    
    wire [23:0] ClkDivThreshold = 1_000;   
    wire SPI_EN, SPI_IN, SPI_OUT, SPI_RES; 
    wire [7:0] State;
    wire [31:0] PC_control;
    wire [15:0] RegAddress;
    
    assign TrigerEvent = PC_control[0];   

    //Instantiate the module that we like to test
    SPI_Transmit SPI_Test1 (        
        .led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .FSM_Clk_reg(FSM_Clk),        
        .ILA_Clk_reg(ILA_Clk),
        .CVM300_SPI_CLK(CVM300_SPI_CLK),
        .CVM300_SPI_OUT(CVM300_SPI_OUT),
        .CVM300_SPI_EN(CVM300_SPI_EN),
        .CVM300_SPI_IN(CVM300_SPI_IN),
        .SPI_IN_REG(SPI_IN),
        .SPI_OUT_REG(SPI_OUT),
        .SPI_EN_REG(SPI_EN),
        .SPI_CLK_REG(SPI_CLK_REG),
        .State(State),
        .PC_control(PC_control),
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA),
        .RegAddress(RegAddress)
        );
    
    //Instantiate the ILA module
    ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({State, SPI_OUT, SPI_EN, CVM300_SPI_CLK, SPI_IN, CVM300_SPI_IN, CVM300_SPI_EN, CVM300_SPI_OUT}),                             
        .probe1({FSM_Clk,TrigerEvent})
        );                        
endmodule








