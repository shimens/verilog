`timescale 1ns / 1ps

module ControlUnit (
    input              clk,
    input              reset,
    output logic       RFSrcMuxSel,
    output logic       we,
    output logic [1:0] opCode,
    output logic [2:0] raddr1,
    output logic [2:0] raddr2,
    output logic [2:0] waddr,
    output logic       OutLoad
);
    enum logic [3:0] {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5,
        S6,
        S7,
        S8,
        S9,
        S10,
        S11,
        S12
    }
        state, state_next;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) state <= S0;
        else state <= state_next;
    end

    always_comb begin
        state_next = state;
        case (state)
            S0: state_next = S1;
            S1: state_next = S2;
            S2: state_next = S3;
            S3: state_next = S4;
            S4: state_next = S5;
            S5: state_next = S6;
            S6: state_next = S7;
            S7: state_next = S8;
            S8: state_next = S9;
            S9: state_next = S10;
            S10: state_next = S11;
            S11: state_next = S12;
            S12: state_next = S12;
            default: state_next = state;
        endcase
    end

    always_comb begin
        RFSrcMuxSel = 1'b0;
        we          = 1'b0;
        raddr1      = 3'b000;
        raddr2      = 3'b000;
        waddr       = 3'b000;
        OutLoad     = 1'b0;
        opCode      = 2'b00;
        case (state)
            S0: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b0;
                raddr1      = 3'b000;
                raddr2      = 3'b000;
                waddr       = 3'b000;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
            S1: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b1;
                raddr1      = 3'b000;
                raddr2      = 3'b000;
                waddr       = 3'b001;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
            S2: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b1;
                raddr1      = 3'b000;
                raddr2      = 3'b000;
                waddr       = 3'b010;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
            S3: begin
                RFSrcMuxSel = 1'b1;
                we          = 1'b1;
                raddr1      = 3'b000;
                raddr2      = 3'b000;
                waddr       = 3'b011;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
            S4: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b1;
                raddr1      = 3'b001;
                raddr2      = 3'b011;
                waddr       = 3'b001;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
            S5: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b1;
                raddr1      = 3'b010;
                raddr2      = 3'b011;
                waddr       = 3'b010;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
            S6: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b1;
                raddr1      = 3'b001;
                raddr2      = 3'b010;
                waddr       = 3'b011;
                OutLoad     = 1'b0;
                opCode      = 2'b01;
            end
            S7: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b1;
                raddr1      = 3'b001;
                raddr2      = 3'b011;
                waddr       = 3'b100;
                OutLoad     = 1'b0;
                opCode      = 2'b10;
            end
            S8: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b1;
                raddr1      = 3'b010;
                raddr2      = 3'b011;
                waddr       = 3'b101;
                OutLoad     = 1'b0;
                opCode      = 2'b11;
            end
            S9: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b1;
                raddr1      = 3'b001;
                raddr2      = 3'b010;
                waddr       = 3'b110;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
            S10: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b1;
                raddr1      = 3'b010;
                raddr2      = 3'b110;
                waddr       = 3'b111;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
            S11: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b0;
                raddr1      = 3'b111;
                raddr2      = 3'b000;
                waddr       = 3'b000;
                OutLoad     = 1'b1;
                opCode      = 2'b00;
            end
            S12: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b0;
                raddr1      = 3'b000;
                raddr2      = 3'b000;
                waddr       = 3'b000;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
            default: begin
                RFSrcMuxSel = 1'b0;
                we          = 1'b0;
                raddr1      = 3'b000;
                raddr2      = 3'b000;
                waddr       = 3'b000;
                OutLoad     = 1'b0;
                opCode      = 2'b00;
            end
        endcase
    end

endmodule
