`timescale 1ns / 1ps

module ControlUnit (
    input      clk,
    input      reset,
    input      ALt10,
    output reg ASrcMuxSel,
    output reg ALoad,
    output reg OutBufSel
);
    localparam S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;

    reg [2:0] state, state_next;

    always @(posedge clk, posedge reset) begin
        if (reset) state <= S0;
        else state <= state_next;
    end

    // Next State Logic
    always @(*) begin
        state_next = state;
        case (state)
            S0: state_next = S1;
            S1: begin
                if (ALt10) state_next = S2;
                else state_next = S0;
            end
            S2: state_next = S3;
            S3: state_next = S1;
            S4: state_next = S4;
            default: state_next = S1;
        endcase
    end

    // Output Logic
    always @(*) begin
        ASrcMuxSel = 1'b0;
        ALoad      = 1'b0;
        OutBufSel  = 1'b0;
        case (state)
            S0: begin
                ASrcMuxSel = 1'b0;
                ALoad      = 1'b1;
                OutBufSel  = 1'b0;
            end
            S1: begin
                ASrcMuxSel = 1'b1;
                ALoad      = 1'b0;
                OutBufSel  = 1'b0;
            end
            S2: begin
                ASrcMuxSel = 1'b1;
                ALoad      = 1'b0;
                OutBufSel  = 1'b1;
            end
            S3: begin
                ASrcMuxSel = 1'b1;
                ALoad      = 1'b1;
                OutBufSel  = 1'b0;
            end
            S4: begin
                ASrcMuxSel = 1'b1;
                ALoad      = 1'b0;
                OutBufSel  = 1'b0;
            end
            default: begin
                ASrcMuxSel = 1'b0;
                ALoad      = 1'b0;
                OutBufSel  = 1'b0;
            end
        endcase
    end
endmodule
