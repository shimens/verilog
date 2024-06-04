`timescale 1ns / 1ps

module RV32I(
    input clk,
    input reset,
    // BUS Signal
    output write,
    output [31:0] address,
    output [31:0] writeData,
    input [31:0] readData
    );
    
    wire [6:0] opcode, func7;
    wire [2:0] func3;
    wire pcload, RFWriteEn, aluSrcMuxSel, RFWrDataSrcMuxSel;
    wire [4:0] ALUControl;
    wire branch;
    wire RFWrDataJumpMuxSel,jal,jalr;
    wire AUIPcSrcMuxSel;
    
    ControlUnit U_CU(
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .pcload(pcload),
        .RFWriteEn(RFWriteEn),
        .RFWrDataSrcMuxSel(RFWrDataSrcMuxSel),
        .ALUControl(ALUControl),
        .aluSrcMuxSel(aluSrcMuxSel),
        .branch(branch),
        .write(write),
        .RFWrDataJumpMuxSel(RFWrDataJumpMuxSel),
        .jal(jal),
        .jalr(jalr),
        .AUIPcSrcMuxSel(AUIPcSrcMuxSel)
    );
    
    DataPath U_DP(
        .clk(clk),
        .reset(reset),
        .pcload(pcload),
        .RFWriteEn(RFWriteEn),
        .RFWrDataSrcMuxSel(RFWrDataSrcMuxSel),
        .ALUControl(ALUControl),
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .aluSrcMuxSel(aluSrcMuxSel),
        .branch(branch),
        .address(address),
        .writeData(writeData),
        .readData(readData),
        .RFWrDataJumpMuxSel(RFWrDataJumpMuxSel),
        .jal(jal),
        .jalr(jalr),
        .AUIPcSrcMuxSel(AUIPcSrcMuxSel)
        
    );
    
endmodule
