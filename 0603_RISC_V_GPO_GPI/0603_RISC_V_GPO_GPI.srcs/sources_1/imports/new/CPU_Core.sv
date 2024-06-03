`timescale 1ns / 1ps

module CPU_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] machineCode,
    input  logic [31:0] dataMemRData,
    output logic [31:0] dataMemWData,
    output logic [31:0] dataMemRAddr,
    output logic [31:0] instrMemRAddr,
    output logic        dataMemWe
);

  logic w_regFileWe, w_ALUSrcMuxSel;
  logic [1:0] w_RFWriteDataSrcMuxSel;
  logic [3:0] w_aluControl;
  logic [2:0] w_extType;
  logic w_branch, w_JALSel, w_JALRSel;

  ControlUnit U_ControlUnit (
      .op                  (machineCode[6:0]),
      .funct3              (machineCode[14:12]),
      .funct7              (machineCode[31:25]),
      .regFileWe           (w_regFileWe),
      .ALUSrcMuxSel        (w_ALUSrcMuxSel),
      .RFWriteDataSrcMuxSel(w_RFWriteDataSrcMuxSel),
      .dataMemWe           (dataMemWe),
      .extType             (w_extType),
      .branch              (w_branch),
      .JALSel              (w_JALSel),
      .JALRSel             (w_JALRSel),
      .aluControl          (w_aluControl)
  );


  DataPath U_DataPath (
      .clk                 (clk),
      .reset               (reset),
      .machineCode         (machineCode),
      .regFileWe           (w_regFileWe),
      .aluControl          (w_aluControl),
      .ALUSrcMuxSel        (w_ALUSrcMuxSel),
      .RFWriteDataSrcMuxSel(w_RFWriteDataSrcMuxSel),
      .extType             (w_extType),
      .branch              (w_branch),
      .JALSel              (w_JALSel),
      .JALRSel             (w_JALRSel),
      .dataMemRData        (dataMemRData),
      .dataMemWData        (dataMemWData),
      .dataMemRAddr        (dataMemRAddr),
      .instrMemRAddr       (instrMemRAddr)
  );

endmodule
