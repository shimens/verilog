`timescale 1ns / 1ps

module CPU_Core (
    input  logic        clk,
    reset,
    input  logic [31:0] machineCode,
    output logic [31:0] InstrMemRAddr,
    output logic        dataMemWe,
    output logic [31:0] dataMemRAddr,
    output logic [31:0] dataMemWData,
    output logic [31:0] dataMemRData
);

    logic w_regFileWe, w_AluSrcMuxSel;
    logic [ 1:0] w_RFWDataSrcMuxSel;
    logic [ 3:0] w_aluControl;
    logic [31:0] w_instrmemRAddr;
    logic [ 2:0] w_extType;
    logic        w_branch;

    assign InstMemRAddr = w_instrmemRAddr;

    ControlUnit u_ControlUnit (
        .op                (machineCode[6:0]),
        .funct3            (machineCode[14:12]),
        .funct7            (machineCode[31:25]),
        .regFileWe         (w_regFileWe),
        .AluSrcMuxSel      (w_AluSrcMuxSel),
        .RF_WData_SrcMuxSel(w_RFWDataSrcMuxSel),
        .dataMemWe         (dataMemWe),
        .ALUControl        (w_aluControl),
        .extType           (w_extType),
        .branch            (w_branch)


    );

    DataPath u_DataPath (
        .clk               (clk),
        .reset             (reset),
        .machineCode       (machineCode),
        .regFileWe         (w_regFileWe),
        .ALUControl        (w_aluControl),
        .InstMemRAddr      (w_instrmemRAddr),
        .dataMemRData      (dataMemRData),
        .dataMemRAddr      (dataMemRAddr),
        .AluSrcMuxSel      (w_AluSrcMuxSel),
        .RF_WData_SrcMuxSel(w_RFWDataSrcMuxSel),
        .extType           (w_extType),
        .dataMemWData      (dataMemWData),
        .branch            (w_branch)
    );


endmodule


