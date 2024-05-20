`timescale 1ns / 1ps

module upCounter_FSM (
    input clk,
    input reset,
    input btn1,
    input btn2,
    output reg en,
    output reg reset_counter
);
    parameter upCounter_STOP=2'b00, upCounter_RUN=2'b01, upCounter_CLEAR=2'b10;

    reg [1:0] state, state_next;

    // state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= upCounter_STOP;
        end else begin
            state <= state_next;
        end
    end

    // next state combinational logic circuit
    always @(*) begin
        state_next = state;
        case (state)
            upCounter_STOP: begin
                if (btn1 == 1'b1) state_next = upCounter_RUN;
                else if (btn2 == 1'b1) state_next = upCounter_CLEAR;
                else state_next = state;
            end
            upCounter_RUN: begin
                if (btn1 == 1'b1) state_next = upCounter_STOP;
                else state_next = state;
            end
            upCounter_CLEAR: begin
                state_next = upCounter_STOP;
            end
        endcase
    end

    // output combinational logic circuit
    always @(state) begin
        en = 1'b0;
        reset_counter = 1'b0;
        case (state)
            upCounter_STOP:  en = 1'b0;
            upCounter_RUN: begin
                en = 1'b1;
                reset_counter = 1'b0;
            end
            upCounter_CLEAR: reset_counter = 1'b1;
        endcase
    end
endmodule
