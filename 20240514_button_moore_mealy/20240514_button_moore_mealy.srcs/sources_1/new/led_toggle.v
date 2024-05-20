`timescale 1ns / 1ps

module led_toggle (
    input  clk,
    input  reset,
    input  button,
    output led
);
    wire w_button;

    button U_Btn (
        .clk(clk),
        .in (button),
        .out(w_button)
    );

    led_fsm U_FSM (
        .clk(clk),
        .reset(reset),
        .button(w_button),
        .led(led)
    );

endmodule

module led_fsm (
    input clk,
    input reset,
    input button,
    output reg led
);

    parameter LED_OFF = 1'b0, LED_ON = 1'b1;

    reg state, state_next;

    // state register, 현재상태 저장
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= LED_OFF;
        end else begin
            state <= state_next;
        end
    end

    // Next State Combinational Logic Circuit
    always @(state, button) begin
        state_next = state;
        case (state)
            LED_OFF: begin
                if (button == 1'b1) state_next = LED_ON;
                else state_next = state;
            end
            LED_ON: begin
                if (button == 1'b1) state_next = LED_OFF;
                else state_next = state;
            end
        endcase
    end

    // Output Combinational Logic Circuit
    // Moore Machine
    always @(state) begin
        led = 1'b0;
        case (state)
            LED_OFF: led = 1'b0;
            LED_ON:  led = 1'b1;
        endcase
    end

    // // Output Combinational Logic Circuit
    // // Mealy Machine
    // always @(state, button) begin
    //     led = 1'b0;
    //     case (state)
    //         LED_OFF: begin
    //             if (button == 1'b1) led = 1'b1;
    //             else led = 1'b0;
    //         end
    //         LED_ON: begin
    //             if (button == 1'b1) led = 1'b0;
    //             else led = 1'b1;
    //         end
    //     endcase
    // end
endmodule
