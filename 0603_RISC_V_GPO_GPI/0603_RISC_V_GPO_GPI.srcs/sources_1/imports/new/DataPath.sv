`timescale 1ns / 1ps
`include "defines.sv"

module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] machineCode,
    input  logic        regFileWe,
    input  logic [ 3:0] aluControl,
    input  logic        ALUSrcMuxSel,
    input  logic [ 1:0] RFWriteDataSrcMuxSel,
    input  logic [ 2:0] extType,
    input  logic        branch,
    input  logic        JALSel,
    input  logic        JALRSel,
    input  logic [31:0] dataMemRData,
    output logic [31:0] dataMemWData,
    output logic [31:0] dataMemRAddr,
    output logic [31:0] instrMemRAddr
);

  logic [31:0] w_ALUResult, w_RegFileRData1, w_RegFileRData2, w_PC_Data;

  //I-Type,IL-Type
  logic [31:0] w_extendOut, w_ALUSrcMuxOut, w_RFWriteDataSrcMuxOut;
  assign dataMemRAddr = w_ALUResult;
  assign dataMemWData = w_RegFileRData2;

  //B-Type
  logic w_btaken, w_PCAdderSrcMuxSel;
  logic [31:0] w_PCAdderSrcMuxOut;
  assign w_PCAdderSrcMuxSel = (branch & w_btaken) | (JALSel);

  //U-Type
  logic [31:0] w_Extend_Data, w_JAdeerSrcMuxOut, w_JPCAdeerSrcMuxOut;

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
  mux_2x1 U_JPCAdeerSrcMux (
      .sel(JALRSel),
      .a  (instrMemRAddr),
      .b  (w_RegFileRData1),
      .y  (w_JPCAdeerSrcMuxOut)
  );

  adder U_Adder_PC (
      .a(w_JPCAdeerSrcMuxOut),
      .b(w_PCAdderSrcMuxOut),
      .y(w_PC_Data)
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

  extend U_Extend (
      .extType(extType),
      .instr  (machineCode[31:7]),  //opcode 제외
      .immext (w_extendOut)
  );

  mux_2x1 U_ALUSrcMux (
      .sel(ALUSrcMuxSel),
      .a  (w_RegFileRData2),
      .b  (w_extendOut),
      .y  (w_ALUSrcMuxOut)
  );

  ALU U_ALU (
      .a         (w_RegFileRData1),
      .b         (w_ALUSrcMuxOut),
      .aluControl(aluControl),
      .btaken    (w_btaken),
      .result    (w_ALUResult)
  );

  mux_2x1 U_JAdeerSrcMux (
      .sel(JALSel),
      .a  (w_extendOut),
      .b  (32'd4),
      .y  (w_JAdeerSrcMuxOut)
  );

  adder U_Adder_Extend (
      .a(w_JAdeerSrcMuxOut),
      .b(instrMemRAddr),
      .y(w_Extend_Data)
  );

  mux_4x1 U_RFWriteDataSrcMux (
      .sel(RFWriteDataSrcMuxSel),
      .a  (w_ALUResult),
      .b  (dataMemRData),
      .c  (w_extendOut),
      .d  (w_Extend_Data),
      .y  (w_RFWriteDataSrcMuxOut)
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
    //초기값을 임의로 설정
    RegFile[0] = 32'd0;
    RegFile[1] = 32'd1;
    RegFile[2] = 32'd2;
    RegFile[3] = 32'hffffffff;
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
  always_ff @(posedge clk, posedge reset) begin
    if (reset) q <= 0;
    else q <= d;
  end

endmodule

module ALU (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] aluControl,
    output logic        btaken,
    output logic [31:0] result
);
  always_comb begin
    case (aluControl)
      `ADD: result = a + b;
      `SUB: result = a - b;
      `SLL: result = a << b;
      `SRL: result = a >> b;
      `SRA: result = a >>> b;
      `SLT: result = (a < b) ? 1 : 0;
      `SLTU: result = (a < b) ? 1 : 0;
      `XOR: result = a ^ b;
      `OR: result = a | b;
      `AND: result = a & b;
      default: result = 32'bx;
    endcase
  end

  always_comb begin : comparator_B_Type
    case (aluControl[2:0])  //Funct3 
      `BEQ: btaken = (a == b);
      `BNE: btaken = (a != b);
      `BLT: btaken = (a < b);
      `BGE: btaken = (a >= b);
      `BLTU: btaken = (a < b);
      `BGEU: btaken = (a >= b);
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
    input  logic [31:7] instr,    //opcode 제외
    output logic [31:0] immext
);
  always_comb begin
    case (extType)
      3'b000:  immext = {{21{instr[31]}}, instr[30:20]};  //I-Type
      3'b001:  immext = {{21{instr[31]}}, instr[30:25], instr[11:7]};  //S-Type
      3'b010:  immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};  //B-Type
      3'b011:  immext = {instr[31:12], 12'b0};  //U-Type
      3'b100:  immext = {{23{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};  //J-Type
      3'b101:  immext = {{27{1'b0}}, instr[24:20]};  //IS-Type
      default: immext = 32'bx;
    endcase
  end

  //최상위 bit는 sign bit이다. 확장시키고 싶을 때 sign bit를 계속 복사
  //즉, -4: 1100(4bit) -> 1111 1100(8bit), 4: 0100(4bit) ->0000 0100(8bit)
endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);

  always_comb begin
    case (sel)
      1'b0:    y = a;
      1'b1:    y = b;
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
