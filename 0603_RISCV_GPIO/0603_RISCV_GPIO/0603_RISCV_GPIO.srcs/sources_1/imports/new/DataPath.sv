`timescale 1ns / 1ps
`include "defines.sv"

module DataPath (
    input  logic        clk,
    reset,
    input  logic [31:0] machineCode,
    input  logic        regFileWe,
    input  logic [ 3:0] ALUControl,
    input  logic [31:0] dataMemRData,
    output logic [31:0] dataMemWData,
    output logic [31:0] dataMemRAddr,
    output logic [31:0] InstMemRAddr,

    input logic       AluSrcMuxSel,
    input logic [1:0] RF_WData_SrcMuxSel,
    input logic [2:0] extType,
    input logic       branch

);
    logic [31:0] w_regfileRdata1, w_regfileRdata2, w_ALUResult, w_PC_Data;
    logic [31:0]
        w_AluSrcMuxOut,
        w_ex_out,
        w_dataMemReadData,
        w_Rf_WDataSrcMuxOut,
        w_InstMemRAddr,
        w_PC_adderSrcMuxOut,
        w_add2mux_41;

    logic w_btaken;
    logic w_PC_adderSrcMUx_Sel;


    assign w_PC_adderSrcMUx_Sel = branch & w_btaken;
    assign InstMemRAddr = w_InstMemRAddr;
    assign dataMemRAddr = w_ALUResult;
    assign dataMemWData = w_regfileRdata2;

    RegisterFile u_RegisterFile (
        .clk   (clk),
        .we    (regFileWe),
        .raddr1(machineCode[19:15]),
        .raddr2(machineCode[24:20]),
        .waddr (machineCode[11:7]),
        .wdata (w_Rf_WDataSrcMuxOut),
        .Rdata1(w_regfileRdata1),
        .Rdata2(w_regfileRdata2)
    );


    Register U_PC (
        .clk  (clk),
        .reset(reset),
        .d    (w_PC_Data),
        .q    (w_InstMemRAddr)
    );

    // adder에서 PC로
    mux_2x1 U_PC_adderSrcMux (
        .sel(w_PC_adderSrcMUx_Sel),
        .a  (32'd4),
        .b  (w_ex_out),
        .y  (w_PC_adderSrcMuxOut)
    );

    // RF에서 ALU로
    mux_2x1 U_ALUsrcMUX (
        .sel(AluSrcMuxSel),
        .a  (w_regfileRdata2),
        .b  (w_ex_out),
        .y  (w_AluSrcMuxOut)
    );

    ALU u_ALU (
        .a         (w_regfileRdata1),
        .b         (w_AluSrcMuxOut),
        .ALUControl(ALUControl),
        .result    (w_ALUResult),
        .btaken    (w_btaken)

    );

    // 4x1 mux change 
    mux_4x1 u_mux_4x1 (
        .sel(RF_WData_SrcMuxSel),
        .x0 (w_ALUResult),
        .x1 (dataMemRData),
        .x2 (w_ex_out),
        .x3 (w_add2mux_41),
        .y  (w_Rf_WDataSrcMuxOut)
    );

    // mux_2x1 U_RF_WData_SrcMux (
    //     .sel(RF_WData_SrcMuxSel),
    //     .a  (w_ALUResult),
    //     .b  (dataMemRData),
    //     .y  (w_Rf_WDataSrcMuxOut)
    // );

    adder u_Adder_instr_ext_to_mux_41 (
        .a(w_InstMemRAddr),
        .b(w_ex_out),
        .y(w_add2mux_41)
    );

    adder u_PC_adder (
        .a(w_InstMemRAddr),
        .b(w_PC_adderSrcMuxOut),
        .y(w_PC_Data)
    );

    extend u_extend (  //instruction code
        .extType(extType),
        .instr  (machineCode[31:7]),
        .imm_ext(w_ex_out)
    );



endmodule


module RegisterFile (
    input  logic        clk,
    we,
    input  logic [ 4:0] raddr1,
    raddr2,
    waddr,
    input  logic [31:0] wdata,
    output logic [31:0] Rdata1,
    Rdata2
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
        if (we) begin
            RegFile[waddr] <= wdata;
        end
    end

    assign Rdata1 = (raddr1 != 0) ? RegFile[raddr1] : 0;
    assign Rdata2 = (raddr2 != 0) ? RegFile[raddr2] : 0;

endmodule

module Register (
    input  logic        clk,
    reset,
    input  logic [31:0] d,
    output logic [31:0] q
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end

endmodule


module ALU (
    input  logic [31:0] a,
    b,
    input  logic [ 3:0] ALUControl,
    output logic [31:0] result,
    output logic        btaken

);

    always_comb begin : ALU
        case (ALUControl)
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

    // type 비교
    always_comb begin : comparator
        case (ALUControl[2:0])  // 최상위 bit는 영향 x >> 하위 3bit만 보겠다
            3'b000:  btaken = (a == b);  // BEQ
            default: btaken = 1'bx;
        endcase
    end

endmodule


module adder (
    input  logic [31:0] a,
    b,
    output logic [31:0] y
);

    assign y = a + b;

endmodule


// 12bit 신호를 32bit로 확장
module extend (  //instruction code
    input  logic [ 2:0] extType,
    input  logic [31:7] instr,
    output logic [31:0] imm_ext
);
    always_comb begin
        // datasheet Instruction Set Manual p.24 참고
        case (extType)
            3'b000: imm_ext = {{21{instr[31]}}, instr[30:20]};  // I-TYPE
            3'b001:
            imm_ext = {{21{instr[31]}}, instr[30:25], instr[11:7]};  // S-TYPE
            3'b010:
            imm_ext = {
                {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0
            };  // B-TYPE
            3'b011: imm_ext = {instr[31:12], {12{1'b0}}};  // U-TYPE
            3'b100:
            imm_ext = {
                {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0
            };  // J-TYPE
            default: imm_ext = 32'bx;
        endcase
    end

    // sign bit를 포함한 확장, 0~19까지 추가로 필요함. sign bit = 최상위 bit >> instr[31]
    // ex ) 4bit >> 8bit
    //      '1'100 >> 1111 '1'100
    assign imm_ext = {{20{instr[31]}}, instr[31:20]};

endmodule

module mux_4x1 (
    input logic [ 1:0] sel,
    input logic [31:0] x0,
    input logic [31:0] x1,
    input logic [31:0] x2,
    input logic [31:0] x3,

    output logic [31:0] y
);

    always @(*) begin
        case (sel)
            2'b00:   y = x0;
            2'b01:   y = x1;
            2'b10:   y = x2;
            2'b11:   y = x3;
            default: y = 32'bx;
        endcase
    end
endmodule


module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] a,
    b,
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

