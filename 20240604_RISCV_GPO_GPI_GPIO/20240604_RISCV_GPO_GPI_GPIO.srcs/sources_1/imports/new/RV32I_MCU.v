`timescale 1ns / 1ps

module RV32I_MCU (
    input        clk,
    input        reset,
    output [3:0] OutPortA,
    output [3:0] OutPortB,
    input  [3:0] InPortC,
    inout  [3:0] IOPortD
);

    wire       write;
    wire [4:0] w_sel;
    wire [31:0] address, writeData, readData, readDataRAM, readDataGPOA, readDataGPOB;
    wire [31:0] readDataGPIC, readDataGPIOD;
    //wire [31:0] readData1, readData2;


    RV32I U_CPUCore (
        .clk      (clk),
        .reset    (reset),
        .write    (write),
        .address  (address),
        .writeData(writeData),
        .readData (readData)
    );

    decoder_bus U_BUS_Decoder (
        .sel(address),
        .y  (w_sel)
    );

    mux_bus U_BUS_MUX (
        .sel     (address),
        .i_data_0(readDataRAM),
        .i_data_1(readDataGPOA),
        .i_data_2(readDataGPOB),
        .i_data_3(readDataGPIC),
        .i_data_4(readDataGPIOD),
        .o_data  (readData)
    );

    RAM U_DataMemory1 (
        .clk   (clk),
        .reset (reset),
        .we    (write),
        .ce    (w_sel[0]),
        .addr  (address[7:0]),
        .i_data(writeData),
        .o_data(readDataRAM)
    );

    GPO U_GPOA (
        .clk    (clk),
        .reset  (reset),
        .sel    (w_sel[1]),
        .we     (write),
        .address(address[0]),
        .wData  (writeData),
        .rData  (readDataGPOA),
        .outPort(OutPortA)
    );

    GPO U_GPOB (
        .clk    (clk),
        .reset  (reset),
        .sel    (w_sel[2]),
        .we     (write),
        .address(address[0]),
        .wData  (writeData),
        .rData  (readDataGPOB),
        .outPort(OutPortB)
    );

    GPI U_GPIC (
        .clk   (clk),
        .addr  (address[0]),
        .cs    (w_sel[3]),
        .we    (write),
        .inPort(InPortC),
        .rdata (readDataGPIC)
    );

    // GPI U_GPID (
    //     .clk   (clk),
    //     .addr  (address[0]),
    //     .cs    (w_sel[4]),
    //     .we    (write),
    //     .inPort(InPortD),
    //     .rdata (readDataGPIOD)
    // );

    GPIO U_GPIOD (
        .clk    (clk),
        .reset  (reset),
        .cs     (w_sel[4]),
        .we     (write),
        .address(address[3:0]),
        .wdata  (writeData),
        .rdata  (readDataGPIOD),
        .IOPort (IOPortD)
    );

endmodule


////////////////////////////////////////////////////////////////

//// decorder ////
module decoder_bus (
    input [31:0] sel,
    output reg [4:0] y
);

    always @(*) begin
        case (sel[31:8])
            24'h0000_00: y = 5'b00001;  // RAM
            24'h0000_21: y = 5'b00010;  // GPOA
            24'h0000_22: y = 5'b00100;  // GPOB
            24'h0000_23: y = 5'b01000;  // GPOC
            24'h0000_24: y = 5'b10000;  // GPOD
            default: y = 5'b00000;
        endcase
    end

endmodule


//// Mux ////
module mux_bus (
    input [31:0] sel,
    input [31:0] i_data_0,
    input [31:0] i_data_1,
    input [31:0] i_data_2,
    input [31:0] i_data_3,
    input [31:0] i_data_4,
    output reg [31:0] o_data
);

    always @(*) begin
        case (sel[31:8])
            24'h0000_00: o_data = i_data_0;  // RAM
            24'h0000_21: o_data = i_data_1;  // GPOA
            24'h0000_22: o_data = i_data_2;  // GPOB
            24'h0000_23: o_data = i_data_3;  // GPOC
            24'h0000_24: o_data = i_data_4;  // GPOD
            default: o_data = 32'b0;
        endcase
    end

endmodule
