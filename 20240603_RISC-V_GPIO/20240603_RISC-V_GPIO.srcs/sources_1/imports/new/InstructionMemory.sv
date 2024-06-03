`timescale 1ns / 1ps

module InstructionMemory (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] ROM[0:63];

    initial begin
        $readmemh("inst.mem", ROM);  // instruction hexa code
    end

    // 주소 한개(단위)가 여기선 32bit인데 일반적으로는 8bit라서 4단위로 끊어서 보겠다
    assign data = ROM[addr[31:2]];

endmodule


