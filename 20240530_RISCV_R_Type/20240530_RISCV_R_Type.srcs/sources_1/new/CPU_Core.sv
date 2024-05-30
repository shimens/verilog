`timescale 1ns / 1ps

module CPU_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] machineCode,
    output logic [31:0] instrMemRAddr,
    output logic        dataMemWe,
    output logic [31:0] dataMemRAddr,
    input  logic [31:0] dataMemRData
);
    logic w_regFileWe, w_AluSrcMuxSel, w_RFWriteDataSrcMuxSel;
    logic [2:0] w_aluControl;

    ControlUnit U_ControlUnit (
        .op                  (machineCode[6:0]),
        .funct3              (machineCode[14:12]),
        .funct7              (machineCode[31:25]),
        .regFileWe           (w_regFileWe),
        .AluSrcMuxSel        (w_AluSrcMuxSel),
        .RFWriteDataSrcMuxSel(w_RFWriteDataSrcMuxSel),
        .dataMemWe           (dataMemWe),
        .aluControl          (w_aluControl)
    );

    DataPath U_DataPath (
        .clk                 (clk),
        .reset               (reset),
        .machineCode         (machineCode),
        .regFileWe           (w_regFileWe),
        .aluControl          (w_aluControl),
        .instrMemRAddr       (instrMemRAddr),
        .AluSrcMuxSel        (w_AluSrcMuxSel),
        .RFWriteDataSrcMuxSel(w_RFWriteDataSrcMuxSel),
        .dataMemRAddr        (dataMemRAddr),
        .dataMemRData        (dataMemRData)
    );

endmodule
