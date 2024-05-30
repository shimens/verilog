`timescale 1ns / 1ps

module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       regFileWe,
    output logic       AluSrcMuxSel,
    output logic       RFWriteDataSrcMuxSel,
    output logic       dataMemWe,
    output logic [2:0] aluControl
);
    logic [5:0] controls;
    logic [1:0] w_AluOp;
    assign {regFileWe,AluSrcMuxSel,RFWriteDataSrcMuxSel,dataMemWe,w_AluOp} = controls;

    always_comb begin
        case (op)
            // regFileWe_AluSrcMuxSel_RFWriteDataSrcMuxSel_dataMemWe_AluOp
            7'b0110011: controls = 6'b1_0_0_0_10;  // R-Type
            7'b0000011: controls = 6'b1_1_1_0_00;  // IL-Type
            7'b0010011: controls = 6'b0;  // I-Type
            7'b0100011: controls = 6'b0;  // S-Type
            7'b1100011: controls = 6'b0;  // B-Type
            7'b0110111: controls = 6'b0;  // LUI-Type
            7'b0010111: controls = 6'b0;  // AUIPC-Type
            7'b1101111: controls = 6'b0;  // J-Type
            7'b1100111: controls = 6'b0;  // JI-Type
            default: controls = 6'b0;  // JI-Type
        endcase
    end

    always_comb begin
        case (w_AluOp)
            2'b00: aluControl = 3'b000;  // ADD
            2'b01: aluControl = 3'b001;  // SUB
            2'b10: begin
                case (funct3)  // R-Type, I-Type ALU
                    3'b000: begin
                        if (funct7[5] & op[5]) aluControl = 3'b001;  // SUB
                        else aluControl = 3'b000;  //ADD
                    end
                    3'b010:  aluControl = 3'b000;  // SLT
                    3'b110:  aluControl = 3'b011;  // OR
                    3'b111:  aluControl = 3'b010;  // AND
                    default: aluControl = 3'bx;
                endcase
            end
        endcase
    end

endmodule
