`timescale 1ns / 1ps

module InstructionMemory (
    input  logic [31:0] addr,
    output logic [31:0] data
);
  logic [31:0] rom[0:63];
  // rom[0] -> 1byte + 1byte + 1byte + 1byte = 4 byte 

  initial begin
    $readmemh("inst.mem", rom);  //hex code instrction
  end

  assign data = rom[addr[31:2]];
  //rom[0] -> 0000 0000 , 0000 0001, 0000 0010, 0000 0011
  //rom[1] -> 0000 0100 , 0000 0101, 0000 0110, 0000 0111

endmodule
