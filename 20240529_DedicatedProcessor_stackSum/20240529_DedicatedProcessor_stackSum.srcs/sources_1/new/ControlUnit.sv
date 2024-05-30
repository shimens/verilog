`timescale 1ns / 1ps

module ControlUnit (
    input        clk,
    input        reset,
    input        ILe10,
    output logic sumSrcMuxSel,
    output logic ISrcMuxSel,
    output logic AdderSrcMuxSel,
    output logic SumLoad,
    output logic ILoad,
    output logic OutLoad
);
    enum logic [2:0] {S0, S1, S2, S3, S4, S5} state, state_next;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) state <= S0;
        else state <= state_next;
    end

    always_comb begin
        state_next = state;
        case (state)
            S0: state_next = S1;
            S1: begin
                if (ILe10) state_next = S2;
                else state_next = S5;
            end
            S2: state_next = S3;
            S3: state_next = S4;
            S4: state_next = S1;
            S5: state_next = S5;
            default: state_next = state;
        endcase
    end

    always_comb begin
        ISrcMuxSel     = 1'b0;
        sumSrcMuxSel   = 1'b0;
        ILoad          = 1'b0;
        SumLoad        = 1'b0;
        AdderSrcMuxSel = 1'b0;
        OutLoad        = 1'b0;
        case (state)
            S0: begin
                ISrcMuxSel     = 1'b0;
                sumSrcMuxSel   = 1'b0;
                ILoad          = 1'b1;
                SumLoad        = 1'b1;
                AdderSrcMuxSel = 1'b0;
                OutLoad        = 1'b0;
            end
            S1: begin
                ISrcMuxSel     = 1'b0;
                sumSrcMuxSel   = 1'b0;
                ILoad          = 1'b0;
                SumLoad        = 1'b0;
                AdderSrcMuxSel = 1'b0;
                OutLoad        = 1'b0;
            end
            S2: begin
                ISrcMuxSel     = 1'b0;
                sumSrcMuxSel   = 1'b1;
                ILoad          = 1'b0;
                SumLoad        = 1'b1;
                AdderSrcMuxSel = 1'b0;
                OutLoad        = 1'b0;
            end
            S3: begin
                ISrcMuxSel     = 1'b1;
                sumSrcMuxSel   = 1'b1;
                ILoad          = 1'b1;
                SumLoad        = 1'b0;
                AdderSrcMuxSel = 1'b1;
                OutLoad        = 1'b0;
            end
            S4: begin
                ISrcMuxSel     = 1'b1;
                sumSrcMuxSel   = 1'b1;
                ILoad          = 1'b0;
                SumLoad        = 1'b0;
                AdderSrcMuxSel = 1'b1;
                OutLoad        = 1'b1;
            end
            S5: begin
                ISrcMuxSel     = 1'b0;
                sumSrcMuxSel   = 1'b0;
                ILoad          = 1'b0;
                SumLoad        = 1'b0;
                AdderSrcMuxSel = 1'b0;
                OutLoad        = 1'b0;
            end
            default: begin
                ISrcMuxSel     = 1'b0;
                sumSrcMuxSel   = 1'b0;
                ILoad          = 1'b0;
                SumLoad        = 1'b0;
                AdderSrcMuxSel = 1'b0;
                OutLoad        = 1'b0;
            end
        endcase
    end
endmodule
