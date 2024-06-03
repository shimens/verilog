`timescale 1ns / 1ps

module CPU_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] machineCode,
    output logic [31:0] instrMemRAddr,
    output logic        dataMemWe,
    output logic [31:0] dataMemRAddr,
    output logic [31:0] dataMemWData,
    input  logic [31:0] dataMemRData
);
    logic w_regFileWe, w_AluSrcMuxSel;
    logic [2:0] w_RFWriteDataSrcMuxSel;
    
    logic [3:0] w_aluControl;
    logic [2:0] w_extType;
    logic w_branch, w_JAL, w_JALR;

    ControlUnit U_ControlUnit (
        .op                  (machineCode[6:0]),
        .funct3              (machineCode[14:12]),
        .funct7              (machineCode[31:25]),
        .regFileWe           (w_regFileWe),
        .AluSrcMuxSel        (w_AluSrcMuxSel),
        .RFWriteDataSrcMuxSel(w_RFWriteDataSrcMuxSel),
        
        .dataMemWe           (dataMemWe),
        .extType             (w_extType),
        .aluControl          (w_aluControl),
        .branch              (w_branch),
        .JAL                 (w_JAL),
        .JALR                (w_JALR)
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
    
        .extType             (w_extType),
        .dataMemRAddr        (dataMemRAddr),
        .dataMemWData        (dataMemWData),
        .dataMemRData        (dataMemRData),
        .branch              (w_branch),
        .JAL                 (w_JAL),
        .JALR                (w_JALR)
    );

endmodule
