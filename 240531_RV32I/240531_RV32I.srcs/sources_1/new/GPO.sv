`timescale 1ns / 1ps

module GPO (
    input  logic        clk,
    input  logic        reset,
    input  logic        ce,
    input  logic        we,
    input  logic [ 1:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    output logic [ 3:0] outPort
);

  //GPO Register
  logic [31:0] ODR;  //ODR 값에 따라 Output 결정

  //Output logic
  assign outPort = ODR[3:0];

  //Write logic
  always_ff @(posedge clk, posedge reset) begin : GPO
    if (reset) begin
      ODR <= 0;
    end else begin
      if (ce & we) ODR <= wdata;
    end
  end

  //Read logic
  assign rdata = ODR;

endmodule
