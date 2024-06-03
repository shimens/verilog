`timescale 1ns / 1ps
`include "defines.sv"


module ControlUnit (
    input  logic [6:0] op,                  //OP code
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       regFileWe,
    output logic       AluSrcMuxSel,
    output logic [1:0] RF_WData_SrcMuxSel,  // mux sel 2bit 변경
    output logic       dataMemWe,
    output logic [3:0] ALUControl,
    output logic [2:0] extType,
    output logic       branch
);

    logic [8:0] controls;
    // logic [1:0] w_AluOP;
    assign {regFileWe, AluSrcMuxSel, RF_WData_SrcMuxSel, dataMemWe, extType, branch} = controls;

    always_comb begin : main_decoder
        case (op)
            // regFileWe, AluSrcMuxSel, RF_WData_SrcMuxSel, dataMemWe, extType, branch
            `OP_TYPE_R:
            controls = 9'b1_0_0_0_0_xxx_0; // xxx도 비트 맞게 입력해줘야함
            `OP_TYPE_IL: controls = 9'b11010_000_0;  // I type
            `OP_TYPE_I: controls = 9'b11000_000_0;  // I type
            `OP_TYPE_S: controls = 9'b01001_001_0;  // S type
            `OP_TYPE_B: controls = 9'b00000_010_1;  // B type
            `OP_TYPE_J: controls = 9'b10100011_0;  // U / LUI type
            `OP_TYPE_JI: controls = 9'b10110011_0;  // AUIPC / UI / UA type
            // `OP_TYPE_U: controls = 9'b0;
            // `OP_TYPE_UA: controls = 9'b0;
            default: controls = 9'bx;
        endcase
    end

    always_comb begin : alu_control_signal
        case (op)  // 내부 신호라서 wire 표시
            `OP_TYPE_R: ALUControl = {funct7[5], funct3};
            `OP_TYPE_IL:
            ALUControl = {
                1'b0, 3'b000
            };  // IL TYPE의 lw funct3가 010인데 SLTI와 겹쳐서 000으로 함(IL에는 더하기만 있기 때문에)
            `OP_TYPE_I: ALUControl = {funct7[5], funct3};
            `OP_TYPE_S: ALUControl = {1'b0, 3'b000};
            `OP_TYPE_B: ALUControl = {1'b0, funct3};
            `OP_TYPE_U: ALUControl = {1'b0, funct3};    //LUI / U
            `OP_TYPE_UA: ALUControl = {1'b0, funct3};    //AUIPC / UA
            // `OP_TYPE_: ALUControl = {1'b0, funct3};
            // `OP_TYPE_: ALUControl = {1'b0, funct3};
            default: ALUControl = 4'bx;


        endcase
    end
endmodule



//     case (funct3)  // R type, I type ALU
//         3'b000: begin
//             if (funct7[5] & op[5]) ALUControl = 3'b001;  // sub
//             else ALUControl = 3'b000;  // add
//         end
//         3'b010:  ALUControl = 3'b000;  // slt
//         3'b110:  ALUControl = 3'b011;  // or
//         3'b111:  ALUControl = 3'b010;  // and
//         default: ALUControl = 3'bx;
//     endcase
// end


// always_comb begin
//         case (w_AluOP)  // 내부 신호라서 wire 표시
//             2'b00: ALUControl = 3'b000;  // add
//             2'b01: ALUControl = 3'b001;  // sub
//             default: begin
//                 case (funct3)  // R type, I type ALU
//                     3'b000: begin
//                         if (funct7[5] & op[5]) ALUControl = 3'b001;  // sub
//                         else ALUControl = 3'b000;  // add
//                     end
//                     3'b010:  ALUControl = 3'b000;  // slt
//                     3'b110:  ALUControl = 3'b011;  // or
//                     3'b111:  ALUControl = 3'b010;  // and
//                     default: ALUControl = 3'bx;
//                 endcase
//             end
//         endcase
//     end
