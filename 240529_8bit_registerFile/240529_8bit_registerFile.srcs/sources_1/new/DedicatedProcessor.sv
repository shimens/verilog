`timescale 1ns / 1ps

module DedicatedProcessor (
    input        clk,
    input        reset,
    output [7:0] outPort
);
    logic RFSrcMuxSel, we, OutLoad;
    logic [1:0] opCode;
    logic [2:0] raddr1, raddr2, waddr;

    ControlUnit U_ControlUnit (.*);

    DataPath U_DataPath (.*);
endmodule
