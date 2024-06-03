`timescale 1ns / 1ps

module RV32I (
    input logic clk,
    input logic reset
);
    logic [31:0] w_InstrMemData, w_InstrMemAddr;
    logic [31:0] w_Addr, w_dataMemRData, w_WData;
    logic [31:0] w_MasterRData;
    logic [ 2:0] w_slave_sel;
    logic        w_We;

    CPU_Core U_CPU_Core (
        .clk          (clk),
        .reset        (reset),
        .machineCode  (w_InstrMemData),
        .instrMemRAddr(w_InstrMemAddr),
        .dataMemWe    (w_We),
        .dataMemRAddr (w_Addr),
        .dataMemRData (w_MasterRData),
        .dataMemWData (w_WData)
    );

    BUS_Interconnector U_BUS_InterConn(
        .address     (w_Addr),
        .slave1_rdata(w_dataMemRData),
        .slave2_rdata(),
        .slave3_rdata(),
        .master_rdata(w_MasterRData),
        .slave_sel   (w_slave_sel)
);

    DataMemory U_RAM (
        .clk  (clk),
        .ce   (w_slave_sel[0]),
        .we   (w_We),
        .addr (w_Addr[7:0]),
        .wdata(w_WData),
        .rdata(w_dataMemRData)
    );

    InstructionMemory U_ROM (
        .addr(w_InstrMemAddr),
        .data(w_InstrMemData)
    );
endmodule
