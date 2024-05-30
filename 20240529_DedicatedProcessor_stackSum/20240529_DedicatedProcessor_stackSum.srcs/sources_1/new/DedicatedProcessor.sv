`timescale 1ns / 1ps

/*
interface sig_interface;
    logic       ILe10;
    logic       sumSrcMuxSel;
    logic       ISrcMuxSel;
    logic       AdderSrcMuxSel;
    logic       SumLoad;
    logic       ILoad;
    logic       OutLoad;
    logic [7:0] outPort;
    // ↑ 방향성 X

    // ↓ 방향성 설정
    modport dp(
        input sumSrcMuxSel,
        input ISrcMuxSel,
        input AdderSrcMuxSel,
        input SumLoad,
        input ILoad,
        input OutLoad,
        output ILe10,
        output outPort
    );

    modport cu(
        input ILe10,
        output sumSrcMuxSel,
        output ISrcMuxSel,
        output AdderSrcMuxSel,
        output SumLoad,
        output ILoad,
        output OutLoad
    );
endinterface  //controlSignal_interface
*/

module DedicatedProcessor (
    input        clk,
    input        reset,
    output [7:0] outPort
);
    // sig_interface sig_intf;
    logic ILe10, sumSrcMuxSel, ISrcMuxSel, AdderSrcMuxSel, SumLoad, ILoad, OutLoad;
    // assign outPort = sig_intf.dp.outPort;

    ControlUnit U_ControlUnit (
        .*
    );

    DataPath U_DataPath (
        .*
    );
endmodule
