`timescale 1ns / 1ps

module DataPath (
    input        clk,
    input        reset,
    input        RFSrcMuxSel,
    input        we,
    input  [1:0] opCode,
    input  [2:0] raddr1,
    input  [2:0] raddr2,
    input  [2:0] waddr,
    input        OutLoad,
    output [7:0] outPort
);
    logic [7:0] w_ALUResult;
    logic [7:0] w_RFSrcMuxOut;
    logic [7:0] w_rdata1, w_rdata2;

    mux_2x1 U_RFSrcMux (
        .sel(RFSrcMuxSel),
        .a  (w_ALUResult),
        .b  (8'b1),
        .y  (w_RFSrcMuxOut)
    );

    RegisterFile U_RF (
        .clk   (clk),
        .we    (we),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr (waddr),
        .wdata (w_RFSrcMuxOut),
        .rdata1(w_rdata1),
        .rdata2(w_rdata2)
    );

    // adder U_Adder (
    //     .a(w_rdata1),
    //     .b(w_rdata2),
    //     .y(w_ALUResult)
    // );

    ALU U_ALU (
        .a(w_rdata1),
        .b(w_rdata2),
        .opCode(opCode),
        .y(w_ALUResult)
    );

    // comparator U_Comp (
    //     .a (w_rdata1),
    //     .b (8'd10),
    //     .le(LE10)
    // );

    register U_OutReg (
        .clk  (clk),
        .reset(reset),
        .load (OutLoad),
        .d    (w_rdata1),
        .q    (outPort)
    );

endmodule

module RegisterFile (
    input        clk,
    input        we,
    input  [2:0] raddr1,
    input  [2:0] raddr2,
    input  [2:0] waddr,
    input  [7:0] wdata,
    output [7:0] rdata1,
    output [7:0] rdata2
);
    logic [7:0] regFile[0:7];

    always_ff @(posedge clk) begin
        if (we) regFile[waddr] <= wdata;
    end

    assign rdata1 = (raddr1 != 0) ? regFile[raddr1] : 0;
    assign rdata2 = (raddr2 != 0) ? regFile[raddr2] : 0;
endmodule

module mux_2x1 (
    input              sel,
    input        [7:0] a,
    input        [7:0] b,
    output logic [7:0] y
);
    always_comb begin : mux_2x1
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
        endcase
    end
endmodule

// module comparator (
//     input  [7:0] a,
//     input  [7:0] b,
//     output       le
// );
//     assign le = (a <= b);
// endmodule

module register (
    input              clk,
    input              reset,
    input              load,
    input        [7:0] d,
    output logic [7:0] q
);
    always_ff @(posedge clk, posedge reset) begin : register
        if (reset) begin
            q <= 0;
        end else begin
            if (load) q <= d;
        end
    end : register
endmodule

// module adder (
//     input  [7:0] a,
//     input  [7:0] b,
//     output [7:0] y
// );
//     assign y = (a + b);
// endmodule

module ALU (
    input        [7:0] a,
    input        [7:0] b,
    input        [1:0] opCode,
    output logic [7:0] y
);
    always_comb begin
        case (opCode)
            2'b00: y = (a + b);
            2'b01: y = (a - b);
            2'b10: y = (a & b);
            2'b11: y = (a | b);
        endcase
    end
endmodule
