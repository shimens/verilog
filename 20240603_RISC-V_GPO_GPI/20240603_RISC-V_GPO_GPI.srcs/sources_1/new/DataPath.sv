`timescale 1ns / 1ps

`include "defines.sv"

module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] machineCode,
    input  logic        regFileWe,
    input  logic [ 3:0] aluControl,
    output logic [31:0] instrMemRAddr,
    output logic [31:0] dataMemRAddr,
    output logic [31:0] dataMemWData,
    input  logic [31:0] dataMemRData,
    input  logic        AluSrcMuxSel,
    input  logic [ 2:0] extType,
    input  logic [ 2:0] RFWriteDataSrcMuxSel,
    input  logic [ 1:0] PCMuxSel,
    input  logic        branch
);
    logic [31:0]
        w_ALUResult,
        w_RegFileRData1,
        w_RegFileRData2,
        w_PC_Data,
        w_UI_Adder,
        w_PC_Adder,
        w_J_Adder;
    logic [31:0]
        w_extendOut, w_AluSrcMuxOut, w_RFWriteDataSrcMuxOut, w_PCAdderSrcMuxOut;
    logic w_PCAdderSrcMuxSel;
    logic w_btaken;
    assign dataMemRAddr = w_ALUResult;
    assign dataMemWData = w_RegFileRData2;
    assign w_PCAdderSrcMuxSel = branch & w_btaken;

    Register U_PC (
        .clk  (clk),
        .reset(reset),
        .d    (w_PC_Data),
        .q    (instrMemRAddr)
    );

    mux_2x1 U_PCAdderSrcMux (
        .sel(w_PCAdderSrcMuxSel),
        .a  (32'd4),
        .b  (w_extendOut),
        .y  (w_PCAdderSrcMuxOut)
    );

    adder U_Adder_PC (
        .a(instrMemRAddr),
        .b(w_PCAdderSrcMuxOut),
        .y(w_PC_Adder)
    );

    RegisterFile U_RegisterFile (
        .clk   (clk),
        .we    (regFileWe),
        .RAddr1(machineCode[19:15]),
        .RAddr2(machineCode[24:20]),
        .WAddr (machineCode[11:7]),
        .WData (w_RFWriteDataSrcMuxOut),
        .RData1(w_RegFileRData1),
        .RData2(w_RegFileRData2)
    );

    mux_2x1 U_ALUSrcMux (
        .sel(AluSrcMuxSel),
        .a  (w_RegFileRData2),
        .b  (w_extendOut),
        .y  (w_AluSrcMuxOut)
    );

    alu U_ALU (
        .a         (w_RegFileRData1),
        .b         (w_AluSrcMuxOut),
        .aluControl(aluControl),
        .btaken    (w_btaken),
        .result    (w_ALUResult)
    );

    mux_5x1 U_RFWriteDataSrcMux (
        .sel(RFWriteDataSrcMuxSel),
        .a  (w_ALUResult),
        .b  (dataMemRData),
        .c  (w_extendOut),
        .d  (w_UI_Adder),
        .e  (w_J_Adder),
        .y  (w_RFWriteDataSrcMuxOut)
    );

    extend U_Extend (
        .extType(extType),
        .instr  (machineCode[31:7]),
        .immext (w_extendOut)
    );

    adder U_Adder_UI (
        .a(instrMemRAddr),
        .b(w_extendOut),
        .y(w_UI_Adder)
    );

    adder U_Adder_J (
        .a(instrMemRAddr),
        .b(32'd4),
        .y(w_J_Adder)
    );

    mux_3x1 U_PCMUX (
        .sel(PCMuxSel),
        .a  (w_PC_Adder),
        .b  (w_UI_Adder),
        .c  (w_ALUResult),
        .y  (w_PC_Data)
    );

endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RAddr1,
    input  logic [ 4:0] RAddr2,
    input  logic [ 4:0] WAddr,
    input  logic [31:0] WData,
    output logic [31:0] RData1,
    output logic [31:0] RData2
);
    logic [31:0] RegFile[0:31];

    initial begin
        RegFile[0] = 32'd0;
        RegFile[1] = 32'd1;
        RegFile[2] = 32'd2;
        RegFile[3] = 32'd3;
        RegFile[4] = 32'd4;
        RegFile[5] = 32'd5;
    end

    always_ff @(posedge clk) begin
        if (we) RegFile[WAddr] <= WData;
    end

    assign RData1 = (RAddr1 != 0) ? RegFile[RAddr1] : 0;
    assign RData2 = (RAddr2 != 0) ? RegFile[RAddr2] : 0;
endmodule

module Register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk, posedge reset) begin : blockName
        if (reset) q <= 0;
        else q <= d;
    end
endmodule

module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] aluControl,
    output logic        btaken,
    output logic [31:0] result
);
    always_comb begin
        case (aluControl)  // R-Type + I-Type
            `ADD:    result = a + b;
            `SUB:    result = a - b;
            `SLL:    result = a << b;
            `SRL:    result = a >> b;
            `SRA:    result = a >>> b;
            `SLT:    result = (a < b) ? 1 : 0;
            `SLTU:   result = (a < b) ? 1 : 0;
            `XOR:    result = a ^ b;
            `OR:     result = a | b;
            `AND:    result = a & b;
            default: result = 32'bx;
        endcase
    end

    always_comb begin : comparator
        case (aluControl[2:0])  // B-Type
            3'b000:  btaken = (a == b);  // BEQ  => funct3 000
            3'b001:  btaken = (a != b);  // BNE 
            3'b100:  btaken = (a < b);  // BLT 
            3'b101:  btaken = (a >= b);  // BGE 
            3'b110:  btaken = (a < b);  // BLTU
            3'b111:  btaken = (a >= b);  // BGEU
            default: btaken = 1'bx;
        endcase
    end
endmodule

module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module extend (
    input  logic [ 2:0] extType,
    input  logic [31:7] instr,
    output logic [31:0] immext
);
    always_comb begin
        case (extType)
            3'b000: immext = {{21{instr[31]}}, instr[30:20]};  // I-Type
            3'b001:
            immext = {{21{instr[31]}}, instr[30:25], instr[11:7]};  // S-Type
            3'b010:
            immext = {
                {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0
            };  // B-Type
            3'b011:
            immext = {instr[31], instr[30:20], instr[19:12], 12'b0};  // U-Type
            3'b100:
            immext = {
                {12{instr[31]}},
                instr[19:12],
                instr[20],
                instr[30:25],
                instr[24:21],
                1'b0
            };  // J-Type
            default: immext = 32'bx;
        endcase
    end
    assign immext = {{20{instr[31]}}, instr[31:20]};
endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    always_comb begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
            default: y = 32'bx;
        endcase
    end
endmodule

module mux_4x1 (
    input  logic [ 1:0] sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    input  logic [31:0] d,
    output logic [31:0] y
);
    always_comb begin
        case (sel)
            2'b00:   y = a;
            2'b01:   y = b;
            2'b10:   y = c;
            2'b11:   y = d;
            default: y = 32'bx;
        endcase
    end
endmodule

module mux_3x1 (
    input  logic [ 1:0] sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    output logic [31:0] y
);
    always_comb begin
        case (sel)
            2'b00:   y = a;
            2'b01:   y = b;
            2'b10:   y = c;
            2'b11:   y = 32'bx;
            default: y = 32'bx;
        endcase
    end
endmodule

module mux_5x1 (
    input  logic [ 2:0] sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    input  logic [31:0] d,
    input  logic [31:0] e,
    output logic [31:0] y
);
    always_comb begin
        case (sel)
            3'b000:  y = a;
            3'b001:  y = b;
            3'b010:  y = c;
            3'b011:  y = d;
            3'b100:  y = e;
            3'b101:  y = 32'bx;
            3'b110:  y = 32'bx;
            3'b111:  y = 32'bx;
            default: y = 32'bx;
        endcase
    end
endmodule
