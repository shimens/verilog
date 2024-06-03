`timescale 1ns / 1ps

`include "defines.sv"

module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       regFileWe,
    output logic       AluSrcMuxSel,
    output logic [2:0] RFWriteDataSrcMuxSel,
    output logic       dataMemWe,
    output logic [2:0] extType,
    output logic       branch,
    output logic       JAL,
    output logic       JALR,
    output logic [3:0] aluControl
);
    logic [11:0] controls;
    assign {regFileWe,AluSrcMuxSel,RFWriteDataSrcMuxSel,dataMemWe, extType, branch, JAL,JALR} = controls;

    always_comb begin : main_decoder
        case (op)
            // regFileWe_AluSrcMuxSel_RFWriteDataSrcMuxSel_dataMemWe_extType_branch_PCMuxSel
            `OP_TYPE_R:  controls = 12'b1_0_000_0_xxx_0_0_0;
            `OP_TYPE_IL: controls = 12'b1_1_001_0_000_0_0_0;
            `OP_TYPE_I:  controls = 12'b1_1_000_0_000_0_0_0;
            `OP_TYPE_S:  controls = 12'b0_1_xxx_1_001_0_0_0;
            `OP_TYPE_B:  controls = 12'b0_0_xxx_0_010_1_0_0;
            `OP_TYPE_U:  controls = 12'b1_x_010_0_011_0_0_0;
            `OP_TYPE_UA: controls = 12'b1_x_011_0_011_0_1_0;
            `OP_TYPE_J:  controls = 12'b1_1_100_0_100_x_1_0;
            `OP_TYPE_JI: controls = 12'b1_1_100_0_000_x_0_1;
            default:     controls = 12'bx;
        endcase
    end

    always_comb begin : ALU_Control_Signal
        case (op)
            `OP_TYPE_R:  aluControl = {funct7[5], funct3};
            `OP_TYPE_IL: aluControl = {1'b0, 3'b000};
            `OP_TYPE_I:  aluControl = {funct7[5], funct3};
            `OP_TYPE_S:  aluControl = {1'b0, 3'b000};
            `OP_TYPE_B:  aluControl = {1'b0, funct3};
            `OP_TYPE_J:  aluControl = {1'b0, 3'b000};
            `OP_TYPE_JI: aluControl = {1'b0, 3'b000};
            default:     aluControl = 4'bx;
        endcase
    end


endmodule
