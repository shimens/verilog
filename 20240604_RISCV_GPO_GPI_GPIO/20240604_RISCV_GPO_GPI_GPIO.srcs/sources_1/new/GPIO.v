`timescale 1ns / 1ps

module GPIO (
    input         clk,
    input         reset,
    input         cs,
    input         we,
    input  [ 3:0] address,
    input  [31:0] wdata,
    output [31:0] rdata,
    inout  [ 3:0] IOPort
);
    reg [31:0] MODER, IDR, ODR;
    reg [31:0] rdata_reg;
    reg [ 3:0] IOPort_reg;

    assign rdata = rdata_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            MODER <= 0;
            ODR   <= 0;
        end else begin
            if (cs & we) begin
                // MODER <= 0;
                // ODR   <= 0;
                case (address[3:2])
                    2'b00: MODER <= wdata;  // MODER 
                    2'b10: ODR <= wdata;  // ODR
                endcase
            end
        end
    end

    always @(*) begin
        case (address[3:2])
            2'b00:   rdata_reg = MODER;   // address 0x00 => 4'b0000
            2'b01:   rdata_reg = IDR;     // address 0x04 => 4'b0100
            2'b10:   rdata_reg = ODR;     // address 0x08 => 4'b1000
            default: rdata_reg = 32'bx;
        endcase
    end

    always @(*) begin
        IDR[0] = MODER[0] ? 1'bz : IOPort[0];
        IDR[1] = MODER[1] ? 1'bz : IOPort[1];
        IDR[2] = MODER[2] ? 1'bz : IOPort[2];
        IDR[3] = MODER[3] ? 1'bz : IOPort[3];
    end

    assign IOPort[0] = MODER[0] ? ODR[0] : 1'bz;
    assign IOPort[1] = MODER[1] ? ODR[1] : 1'bz;
    assign IOPort[2] = MODER[2] ? ODR[2] : 1'bz;
    assign IOPort[3] = MODER[3] ? ODR[3] : 1'bz;
endmodule
