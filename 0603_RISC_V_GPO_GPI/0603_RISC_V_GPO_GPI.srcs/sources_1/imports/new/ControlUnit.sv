`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       regFileWe,
    output logic       ALUSrcMuxSel,
    output logic [1:0] RFWriteDataSrcMuxSel,
    output logic       dataMemWe,
    output logic [2:0] extType,
    output logic       branch,
    output logic       JALSel,
    output logic       JALRSel,
    output logic [3:0] aluControl
);

  logic [10:0] countrols;
  assign {regFileWe, ALUSrcMuxSel, RFWriteDataSrcMuxSel, dataMemWe, extType, branch, JALSel, JALRSel} = countrols;

  always_comb begin : main_decoder
    case (op)
      //regFileWe, ALUSrcMuxSel, RFWriteDataSrcMuxSel, dataMemWe, extType, branch, JALSel, JALRSel
      `OP_TYPE_R:  countrols = 11'b1_0_00_0_xxx_0_0_0;
      `OP_TYPE_IL: countrols = 11'b1_1_01_0_000_0_0_0;
      `OP_TYPE_I: begin
        if ({funct7[5], funct3} == 4'b1101) countrols = 11'b1_1_00_0_101_0_0_0;
        else countrols = 11'b1_1_00_0_000_0_0_0;
      end
      `OP_TYPE_S:  countrols = 11'b0_1_xx_1_001_0_0_0;
      `OP_TYPE_B:  countrols = 11'b0_0_xx_0_010_1_0_0;
      `OP_TYPE_U:  countrols = 11'b1_x_10_0_011_0_0_0;
      `OP_TYPE_UA: countrols = 11'b1_x_11_0_011_0_0_0;
      `OP_TYPE_J:  countrols = 11'b1_x_11_0_100_1_1_0;
      `OP_TYPE_JI: countrols = 11'b1_x_11_0_000_1_1_1;
      default:     countrols = 11'bx;
    endcase
  end

  always_comb begin : alu_Control_signal
    case (op)
      `OP_TYPE_R: aluControl = {funct7[5], funct3};
      `OP_TYPE_IL:
      aluControl = {
        1'b0, 3'b000
      };  //funct3가 들어가면 ADD가 아닌 것이 되므로 ADD 설정
      `OP_TYPE_I: aluControl = {funct7[5], funct3};
      `OP_TYPE_S: aluControl = {1'b0, 3'b000};  // Only ADD
      `OP_TYPE_B: aluControl = {1'b0, funct3};
      default: aluControl = 4'bx;
    endcase
  end

endmodule
