`timescale 1ns / 1ps

module InstructionMemory(
    input logic [31:0] addr,
    output logic [31:0] data
    );

    logic [31:0]  rom[0:63]; // 32bit 단위로 64개를 만듬

initial begin
    $readmemh("inst.mem", rom); // instruction hexa code
end
    assign data = rom[addr[31:2]]; //뒤에 2bit를 무시하고 4단위로 가겠다 // 한 공간의 크기가 32bit인데 ,addr
    // 세번째 자리부터 읽으면 4개 단위로 읽을 수 있다.
endmodule
