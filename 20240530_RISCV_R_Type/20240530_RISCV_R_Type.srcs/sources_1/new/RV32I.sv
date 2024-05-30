`timescale 1ns / 1ps

module RV32I (
    input logic clk,
    input logic reset
);
    logic [31:0] w_InstrMemData, w_InstrMemAddr;
    logic [31:0] w_dataMemRAddr, w_dataMemRData;
    logic w_dataMemWe;

    CPU_Core U_CPU_Core (
        .clk          (clk),
        .reset        (reset),
        .machineCode  (w_InstrMemData),
        .instrMemRAddr(w_InstrMemAddr),
        .dataMemWe    (w_dataMemWe),
        .dataMemRAddr (w_dataMemRAddr),
        .dataMemRData (w_dataMemRData)
    );

    DataMemory U_RAM (
        .clk(clk),
        .we(w_dataMemWe),
        .addr(w_dataMemRAddr),
        .wdata(),
        .rdata(w_dataMemRData)
    );

    InstructionMemory U_ROM (
        .addr(w_InstrMemAddr),
        .data(w_InstrMemData)
    );
endmodule
