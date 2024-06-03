`timescale 1ns / 1ps

`include "defines.sv"

module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       regFileWe,
    output logic       AluSrcMuxSel,
    output logic       RFWriteDataSrcMuxSel,
    output logic       dataMemWe,
    output logic [2:0] extType,
    output logic [3:0] aluControl,
    output logic       branch
);
    logic [7:0] controls;
    assign {regFileWe,AluSrcMuxSel,RFWriteDataSrcMuxSel,dataMemWe, extType, branch} = controls;

    always_comb begin : main_decoder
        case (op)
            // controls = regFileWe_AluSrcMuxSel_RFWriteDataSrcMuxSel_dataMemWe_extType_branch
            `OP_TYPE_R:  controls = 8'b1_0_0_0_xxx_0;
            `OP_TYPE_IL: controls = 8'b1_1_1_0_000_0;
            `OP_TYPE_I:  controls = 8'b1_1_0_0_000_0;
            `OP_TYPE_S:  controls = 8'b0_1_x_1_001_0;
            `OP_TYPE_B:  controls = 8'b0_0_x_0_010_1;
            `OP_TYPE_U:  controls = 8'b0;
            `OP_TYPE_UA: controls = 8'b0;
            `OP_TYPE_J:  controls = 8'b0;
            `OP_TYPE_JI: controls = 8'b0;
            default:     controls = 8'bx;
        endcase
    end

    always_comb begin : ALU_Control_Signal
        case (op)
            `OP_TYPE_R:  aluControl = {funct7[5], funct3};
            `OP_TYPE_IL: aluControl = {1'b0, 3'b000};
            `OP_TYPE_I:  aluControl = {funct7[5], funct3};
            `OP_TYPE_S:  aluControl = {1'b0, 3'b000};
            `OP_TYPE_B:  aluControl = {1'b0, funct3};
            default:     aluControl = 4'bx;
        endcase
    end

endmodule
