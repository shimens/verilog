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
    input logic [31:0] dataMemRData,
    input logic AluSrcMuxSel,
    input logic [2:0] RFWriteDataSrcMux,
    input logic [2:0] extType,
    input logic branch,
    input logic [1:0] PCScrMuxSel//
);

    logic [31:0] w_ALUResult, w_RegFileRData1, w_RegFileRData2, w_PC_data;
    logic [31:0] w_extendOut, w_AluSrcMuxOut, w_RFWriteDataSrcMuxOut, w_PCAdderSrcMuxOut, w_ImmPcResult,w_PCplus4, w_PCScrMuxOut;

    logic w_btaken, w_PCAdderSrcMuxSel;
    assign dataMemRAddr = w_ALUResult;
    assign dataMemWData = w_RegFileRData2;
    assign w_PCAdderSrcMuxSel = branch & w_btaken;

    Register U_PC (
        .clk  (clk),
        .reset(reset),
        .d    (w_PCScrMuxOut),
        .q    (instrMemRAddr)
    );

    adder U_Adder_PCplus4 (
        .a(instrMemRAddr),
        .b(32'd4),
        .y(w_PCplus4)
    );

    mux_2x1 U_PCAdderSrcMux(
    .sel(w_PCAdderSrcMuxSel),
    .a(32'd4),
    .b(w_extendOut),
    .y(w_PCAdderSrcMuxOut)
);

    adder U_Adder_PC (
        .a(instrMemRAddr),
        .b(w_PCAdderSrcMuxOut),
        .y(w_PC_data)
    );

    mux_4x1 U_PCScrMux(
    .sel(PCScrMuxSel),
    .a(w_PC_data),
    .b(w_ImmPcResult),
    .c(w_ALUResult),
    .y(w_PCScrMuxOut)
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


    mux_2x1 U_ALUSrcMux(
    .sel(AluSrcMuxSel),
    .a(w_RegFileRData2),
    .b(w_extendOut),
    .y(w_AluSrcMuxOut)
);


    alu U_ALU (  // 확장공사예정
        .a         (w_RegFileRData1),
        .b         (w_AluSrcMuxOut),
        .aluControl(aluControl),
        .result    (w_ALUResult),
        .btaken(w_btaken)
        //.result    (dataMemRAddr)
    );

    // mux_2x1 U_RFWriteDataSrcMux(
    // .sel(RFWriteDataSrcMux),
    // .a(w_ALUResult),
    // //.a(dataMemRAddr),
    // .b(dataMemRData),
    // .y(w_RFWriteDataSrcMuxOut)
    // );

mux_8x1 U_RFWriteDataSrcMux(
    .sel(RFWriteDataSrcMux),
    .a(w_ALUResult),
    .b(dataMemRData),
    .c(w_extendOut),
    .d(w_ImmPcResult),
    .e(w_PCplus4),
    .y(w_RFWriteDataSrcMuxOut)
);


    extend U_Extend (  // sign bit를 포함한 확장
    .extType(extType),
    .instr(machineCode[31:7]), // opcode 빼고 다 받겠다. (op는 구분용이고 다른건 다른데서 다 쓰니까)
    .immext(w_extendOut)  // immediate extend
);

    adder U_Adder_PCPlusImm (
        .a(w_extendOut),
        .b(instrMemRAddr),
        .y(w_ImmPcResult)
    );

endmodule  // 여기

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
        RegFile[4] = 32'd4;//4+5
        RegFile[5] = 32'd5;
    end
    always_ff @(posedge clk) begin : blockName
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

    always_ff @(posedge clk, posedge reset) begin
        if (reset) q <= 0;
        else q <= d;
    end
endmodule

module alu (  // 확장공사예정
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] aluControl,
    output logic btaken,
    output logic [31:0] result
);

    always_comb begin
        case (aluControl)
            `ADD  : result = a + b;
            `SUB  : result = a - b;
            `SLL  : result = a << b;
            `SRL  : result = a >> b;
            `SRA  : result = a >>> b;
            `SLT  : result = (a < b) ? 1 : 0;
            `SLTU : result = (a < b) ? 1 : 0;
            `XOR  : result = a ^ b;
            `OR   : result = a | b;
            `AND  : result = a & b;            
            // 3'b000: result = a + b;
            // 3'b001: result = a - b;
            // 3'b010: result = a & b;
            // 3'b011: result = a | b;
            default:
            result = 32'bx; // 값을 모른다! 주의: 0은 주면 안됨. 0도 값이기 때문
        endcase
    end

    always_comb begin : comparator
        case(aluControl[2:0])
            3'b000: btaken = (a == b); // BEQ
            3'b001: btaken = (a != b); // BNE
            3'b100: btaken = (a < b); // BLT
            3'b101: btaken = (a >= b); // BGE
            3'b110: btaken = (a < b); // BLTU
            3'b111: btaken = (a >= b); // BGEU
            default: btaken = 3'bx;
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

module extend (  // sign bit를 포함한 확장
    input logic [2:0] extType,
    input logic [31:7] instr, // opcode 빼고 다 받겠다. (op는 구분용이고 다른건 다른데서 다 쓰니까)
    output logic [31:0] immext  // immediate extend
);
    always_comb begin
        case (extType)
            3'b000: immext = {{21{instr[31]}}, instr[30:20]}; // I-Type  // 최상위 비트를 복제한 것
            3'b001: immext = {{21{instr[31]}}, instr[30:25],instr[11:7]}; // S-Type
            3'b010: immext = {{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0}; // B-Type // 상수 0은 1'b0으로 넣어야댐. 그냥 0넣으면 안된다.
            3'b011: immext = {instr[31], instr[30:20],instr[19:12],12'b0}; // U-Type
            3'b100: immext = {{11{instr[31]}}, instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0}; // J-Type
            default: immext = {{21{instr[31]}}, instr[31:20]}; // I-Type
        endcase
    end
    
    // 최상위 bit는 sign bit이다.
    // 그래서 sign bit(최상위비트)를 그대로 복제해서 확장하고 싶은 bit만큼 그대로 써준다.
    // 2의 보수 개념으로 -4 = 0100 -> 1011 -> 1100 이니까 1이 sign비트이고, 8bit로 확장하고 싶으면
    // 1111 1100 해주면 된다. (8bit로 표현한 -4)
    // 그냥 4를 16bit로 확장하면 0000 0000 0000 0100 이다.
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
    output logic [31:0] y
);

    always_comb begin
        case (sel)
            2'b00: y = a; 
            2'b01: y = b; 
            2'b10: y = c; 
            default: y = 32'bx;
        endcase
        
    end

endmodule

module mux_8x1 (
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
            3'b000: y = a; 
            3'b001: y = b; 
            3'b010: y = c; 
            3'b011: y = d; 
            3'b100: y = e; 
            default: y = 32'bx;
        endcase
        
    end

endmodule