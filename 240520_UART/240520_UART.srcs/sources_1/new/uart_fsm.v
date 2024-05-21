`timescale 1ns / 1ps

module uart_fsm (
    input  clk,
    input  reset,
    input  [7:0]data,
    output reg led1,
    output reg led2,
    output reg led3
);

    localparam STATE0 = 0, STATE1 = 1, STATE2 = 2, STATE3 = 3;

    reg [1:0] state, state_next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STATE0;
        end else begin
            state <= state_next;
        end
    end

    always @(*) begin
        state_next = state;
        case (state)
            STATE0: begin
                if (data == "1") state_next = STATE1;
                else if (data == "2") state_next = STATE2;
                else if (data == "3") state_next = STATE3;
                else state_next = state;
            end
            STATE1: begin
                if (data == "0") state_next = STATE0;
                else if (data == "2") state_next = STATE2;
                else if (data == "3") state_next = STATE3;
                else state_next = state;
            end
            STATE2: begin
                if (data == "0") state_next = STATE0;
                else if (data == "1") state_next = STATE1;
                else if (data == "3") state_next = STATE3;
                else state_next = state;
            end
            STATE3: begin
                if (data == "0") state_next = STATE0;
                else if (data == "1") state_next = STATE1;
                else if (data == "2") state_next = STATE2;
                else state_next = state;
            end
        endcase
    end

    always @(*) begin
        led1 = 1'b0;
        led2 = 1'b0;
        led3 = 1'b0;
        case (state)
            STATE0: begin
                led1 = 1'b0;
                led2 = 1'b0;
                led3 = 1'b0;
            end
            STATE1: begin
                led1 = 1'b1;
                led2 = 1'b0;
                led3 = 1'b0;
            end
            STATE2: begin
                led1 = 1'b1;
                led2 = 1'b1;
                led3 = 1'b0;
            end
            STATE3: begin
                led1 = 1'b1;
                led2 = 1'b1;
                led3 = 1'b1;
            end
        endcase
    end

endmodule