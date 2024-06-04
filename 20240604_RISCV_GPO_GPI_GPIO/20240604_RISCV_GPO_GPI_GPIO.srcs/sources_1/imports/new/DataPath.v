`timescale 1ns / 1ps

`include "RV32I_define.v"

module DataPath (
    //global signal
    input clk,
    input reset,
    //PC signal
    input pcload,
    //RegFile signal
    input RFWriteEn,
    input RFWrDataSrcMuxSel,
    //ALU signal
    input [4:0] ALUControl,
    //Control Unit signal
    output [6:0] opcode,
    output [2:0] func3,
    output [6:0] func7,
    //Mux signal
    input aluSrcMuxSel,
    //Branch siganl
    input branch,
    //BUS signal
    output [31:0] address,  // ALU result to address
    output [31:0] writeData,
    input [31:0] readData,
    //Jump Signal ((to mux sel))
    input RFWrDataJumpMuxSel,
    input jal,
    input jalr,
    input AUIPcSrcMuxSel
);

    wire [31:0] w_instMemAddr, w_pcAdd4, w_instCode, w_ALUValue, w_RFSrcData1, w_RFSrcData2, w_immValue, w_aluSrcMuxValue,w_AUIPcSrcMuxValue;
    wire [31:0] w_RFWrDataSrcMuxValue, w_shiftValue, w_BranchAdderValue, w_PCSrcMuxValue,w_RFWrDataJumpMuxValue,w_JALRMuxValue;
    wire w_PCSrcMuxSel, w_BTaken, w_branch;  // 1bit

    assign opcode = w_instCode[6:0];
    assign func3 = w_instCode[14:12];
    assign func7 = w_instCode[31:25];
    assign address = w_ALUValue;
    assign writeData = w_RFSrcData2;

    ///////////////////////////////////////////////////module instance///////////////////////////////////////////
    mux_2x1 U_JALRMux (
        .sel(jalr),
        .a(w_PCSrcMuxValue),  // 0 value
        .b(w_RFWrDataSrcMuxValue),
        .y(w_JALRMuxValue)
    );

    register U_PC (  // Program Counter
        .clk(clk),
        .reset(reset),
        .i_data(w_JALRMuxValue),
        .load(pcload),
        .o_data(w_instMemAddr)
    );

    Adder U_adder4 (
        .a(w_instMemAddr),
        .b(4),
        .y(w_pcAdd4)
    );

    ROM U_ROM (
        .addr(w_instMemAddr),
        .data(w_instCode)
    );

    mux_2x1 U_RFWrDataJumpMux (
        .sel(RFWrDataJumpMuxSel),
        .a  (w_RFWrDataSrcMuxValue),  // original value
        .b  (w_pcAdd4),
        .y  (w_RFWrDataJumpMuxValue)
    );

    RegFile U_RegFile (
        .clk(clk),
        .reset(reset),
        .srcAddr1(w_instCode[19:15]),
        .srcAddr2(w_instCode[24:20]),
        .dstAddr(w_instCode[11:7]),
        .writeEn(RFWriteEn),
        .writeData(w_RFWrDataJumpMuxValue),
        .srcData1(w_RFSrcData1),
        .srcData2(w_RFSrcData2)
    );

    ALU U_ALU (
        .ALUControl(ALUControl),
        .src1(w_AUIPcSrcMuxValue),
        .src2(w_aluSrcMuxValue),
        .btaken(w_BTaken),
        .result(w_ALUValue)
    );

    ImmGen U_ImmGen (
        .instCode(w_instCode),
        .imm(w_immValue)
    );
    mux_2x1 U_AUIPCSrcMux (
        .sel(AUIPcSrcMuxSel),
        .a  (w_RFSrcData1),
        .b  (w_instMemAddr),
        .y  (w_AUIPcSrcMuxValue)
    );
    mux_2x1 U_ALUSrcmux (
        .sel(aluSrcMuxSel),
        .a  (w_RFSrcData2),
        .b  (w_immValue),
        .y  (w_aluSrcMuxValue)
    );

    mux_2x1 U_RFWrDataSrcMux (
        .sel(RFWrDataSrcMuxSel),
        .a  (w_ALUValue),
        .b  (readData),
        .y  (w_RFWrDataSrcMuxValue)
    );

    shifter U_LeftShift_1 (
        .i_data(w_immValue),
        .o_data(w_shiftValue)
    );

    Adder U_BranchAdder (
        .a(w_instMemAddr),
        .b(w_shiftValue),
        .y(w_BranchAdderValue)
    );

    mux_2x1 U_PCSrcMux (
        .sel(w_PCSrcMuxSel),
        .a  (w_pcAdd4),
        .b  (w_BranchAdderValue),
        .y  (w_PCSrcMuxValue)
    );

    and U_Btake (w_branch, w_BTaken, branch);  // primitive
    or U_JumpOR (w_PCSrcMuxSel, w_branch, jal);

endmodule

////////////////////////////////////////////////////////module create start////////////////////////////////////////////////////////// 
module RegFile (
    input clk,
    input reset,
    input [4:0] srcAddr1,
    input [4:0] srcAddr2,
    input [4:0] dstAddr,
    input writeEn,
    input [31:0] writeData,
    output [31:0] srcData1,
    output [31:0] srcData2
);

    reg [31:0] regFiles[0:31];

    integer i;
    initial begin  //for simulation
        for (i = 0; i < 32; i = i + 1) begin
            regFiles[i] = 0;
        end
    end

    assign srcData1 = srcAddr1 ? regFiles[srcAddr1] : 32'b0;
    assign srcData2 = srcAddr2 ? regFiles[srcAddr2] : 32'b0;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                regFiles[i] = 0;
            end
        end else begin
            if (writeEn && dstAddr) begin  //Synchronous reset 
                regFiles[dstAddr] <= writeData;
            end
        end
    end

endmodule

////
module Adder (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] y
);

    assign y = a + b;

endmodule

////
module register (  //
    input clk,
    input reset,
    input [31:0] i_data,
    input load,
    output reg [31:0] o_data
);

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            o_data <= 0;
        end else begin
            if (load) o_data <= i_data;
            else o_data <= o_data;
        end
    end
endmodule

////
module ROM (
    input  [31:0] addr,
    output [31:0] data
);

    reg [31:0] mem[0:1023];

    initial begin
        $readmemh("code2.mem", mem);  // hexa data   
    end

    /*
        // R-TYPE ADD
                 // func 7bit Func7|rsc2 5bitrsc2|rsc1 5bit rs1|3bit func3|5bit rd|7bit Opcdode|   ?? ? ????????? 
        
        mem[0] = 32'b0000000_00000_00000_000_00100_0110011; // ADD X4, X0, X0
        mem[1] = 32'b0000000_00001_00100_000_00100_0110011; // ADD X4, X4, X1
        mem[2] = 32'b0000000_00111_00100_000_00100_0110011; // ADD X7  X7  X1
        mem[3] = 32'b0000000_00111_00100_000_00100_0110011; // ADD X7  X7  X1
        mem[4] = 32'b0100000_00001_00100_000_00100_0110011; // SUB X4, X4, X1
        mem[5] = 32'b0100000_00001_00100_000_00100_0110011; // SUB X4, X4, X1
        mem[6] = 32'b0000000_00001_00100_001_00100_0110011; // SLL X4, X4, X1
        mem[7] = 32'b0000000_00001_00100_001_00100_0110011; // SLL X4, X4, X1
        mem[8] = 32'b0000000_00001_00100_101_00100_0110011; // SRL X4, X4, X1
        mem[9] = 32'b0000000_00001_00100_101_00100_0110011; // SRL X4, X4, X1
        mem[10] = 32'b0100000_00001_00100_101_00100_0110011; // SRA X4, X4, X1
        mem[11] = 32'b0100000_00001_00100_101_00100_0110011; // SRA X4, X4, X1
        mem[12] = 32'b0000000_00001_00100_010_00100_0110011;// SLT X4, X4, X1
        // R-TYPE SUM
        mem[13] = 32'b0000000_00001_00100_010_00100_0110011; // SLT X4, X4, X1
        mem[14] = 32'b0000000_00001_00100_011_00100_0110011; // SLTU X4, X4, X1
        mem[15] = 32'b0000000_00001_00100_011_00100_0110011; // SLTU X4, X4, X1
        mem[16] = 32'b0000000_00001_00100_100_00100_0110011; // XOR X4, X4, X1
        mem[17] = 32'b0000000_00001_00100_100_00100_0110011; // XOR X4, X4, X1
        mem[18] = 32'b0000000_00001_00100_110_00100_0110011; // OR X4, X4, X1
        mem[19] = 32'b0000000_00001_00100_110_00100_0110011; // OR X4, X4, X1
        mem[19] = 32'b0000000_00001_00100_111_00100_0110011; // AND X4, X4, X1
        mem[20] = 32'b0000000_00001_00100_111_00100_0110011; // AND X4, X4, X1
        //mem[21] = 32'b0100000_00001_00100_000_00100_0110011;
        // I-TYPE ADDI
                  // imm _ imm _ r1 _ Func3 _ rd _ Opcdode
        mem[22] = 32'b0000000_01010_00100_000_00101_0010011; //ADDI X5, X4, 10
        mem[23] = 32'b0000000_01010_00101_000_00101_0010011; //ADDI X5, X5, 10
        mem[24] = 32'b0000000_10100_00101_010_00101_0010011; //SLTI X5, X5, 10 
        mem[25] = 32'b0000000_11110_00101_010_00101_0010011; //SLTI X5, X5, 10
        mem[26] = 32'b0000000_01010_00100_011_00101_0010011; //SLTIU  X5, X5, 10
        mem[27] = 32'b0000000_01010_00101_011_00101_0010011; //SLTIU  X5, X5, 10
        mem[28] = 32'b0000000_10100_00101_100_00101_0010011; //XORI  X5, X5, 10
        mem[29] = 32'b0000000_11110_00101_100_00101_0010011; //XORI  X5, X5, 10
        mem[30] = 32'b0000000_01010_00100_110_00101_0010011; //ORI  X5, X5, 10
        mem[31] = 32'b0000000_01010_00101_110_00101_0010011; //ORI  X5, X5, 10
        mem[32] = 32'b0000000_10100_00101_111_00101_0010011; //ANDI  X5, X5, 10
        mem[33] = 32'b0000000_11110_00101_111_00101_0010011; //ANDI  X5, X5, 10
    */
    /* //B-Type
initial begin    
        mem[0]= 32'b0000000_00011_00011_000_01010_1100011;
        mem[1] = 32'b0000000_00011_00010_000_00100_0110011;//add x5,x0,x0
end 
*/
    assign data = mem[(addr>>2)];  //1 right shift 2 divide/  2 right shift 4 divide
endmodule

/////////////////////////////////////////////////////////ALU//////////////////////////////////////////////////////////////////////
module ALU (
    input [4:0] ALUControl,
    input [31:0] src1,
    input [31:0] src2,
    output reg btaken,
    output reg [31:0] result
);

    always @(*) begin
        result = 32'b0;
        case (ALUControl)
            //R-TYPE
            `ADD:  result = src1 + src2;
            `SUB:  result = src1 - src2;
            `SLL:  result = src1 << src2;
            `SRL:  result = src1 >> src2;
            `SRA:  result = src1 >>> src2;
            `SLT:  result = (src1 < src2) ? 1 : 0;
            `SLTU: result = (src1 < src2) ? 1 : 0;
            `XOR:  result = src1 ^ src2;
            `OR:   result = src1 | src2;
            `AND:  result = src1 & src2;
            //
            `SLLI: result = src1 << src2[4:0];
            `SRLI: result = src1 >> src2[4:0];
            `SRAI: result = src1 >>> src2[4:0];


            //IL-TYPE
            `LB: result = src1[7:0] + src2[7:0];
            `LH: result = src1[15:0] + src2[15:0];
            `LBU: result = src1[7:0] + src2[7:0];
            `LHU: result = src1[15:0] + src2[15:0];
            //R-TYPE
            `SB: result = src1[7:0] + src2[7:0];
            `SH: result = src1[15:0] + src2[15:0];
            //U-TYPE
            `LUI: result = src2 << 12;
            `AUIPC: result = src1 + (src2 << 12);  // PC
            default: result = 32'b0;
        endcase
    end

    always @(*) begin
        btaken = 1'b0;
        case (ALUControl)
            `BEQ: btaken = src1 == src2;
            `BNE: btaken = src1 != src2;
            `BLT: btaken = src1 < src2;
            `BGE: btaken = src1 >= src2;
            `BLT: btaken = src1 < src2;
            `BGE: btaken = src1 >= src2;
        endcase
    end
endmodule

/////////////////////////////////////////////////////// MUX /////////////////////////////////////////////////////////////////////
module mux_2x1 (
    input sel,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] y
);

    always @(*) begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
        endcase
    end

endmodule

////
module ImmGen (
    input [31:0] instCode,
    output reg [31:0] imm
);

    always @(*) begin
        case (instCode[6:0])
            `OPCODE_TYPE_I: imm = {{20{instCode[31]}}, instCode[31:20]};
            `OPCODE_TYPE_IL: imm = {{20{instCode[31]}}, instCode[31:20]};
            `OPCODE_TYPE_S:
            imm = {
                {20{instCode[31]}}, instCode[31:25], instCode[11:7]
            };  // 32bit 
            `OPCODE_TYPE_B:
            imm = {
                {20{instCode[31]}},
                instCode[31],
                instCode[7],
                instCode[30:25],
                instCode[11:8]
            };  //MSB -> LSB
            `OPCODE_TYPE_J:
            imm = {
                {12{instCode[31]}},
                instCode[31],
                instCode[19:12],
                instCode[20],
                instCode[30:21]
            };  //imm[20] , imm[19:12] , imm[11],
            `OPCODE_TYPE_JI: imm = {{20{instCode[31]}}, instCode[31:20]};
            `OPCODE_TYPE_LUI: imm = {{12{instCode[31]}}, instCode[31:12]};
            `OPCODE_TYPE_AUIPC: imm = {{12{instCode[31]}}, instCode[31:12]};
            default: imm = 32'b0;
            //`OPCODE_TYPE_AUIPC 7'b0010111
        endcase
    end

endmodule

module shifter (
    input  [31:0] i_data,
    output [31:0] o_data
);
    assign o_data = (i_data << 1);
endmodule
