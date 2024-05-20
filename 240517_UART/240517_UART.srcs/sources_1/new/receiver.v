module transmitter (
    input        clk,
    input        reset,
    input        br_tick,
    input        rx_data,
    output [7:0] rx,
    output       rx_done
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state, state_next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg rx_reg, rx_next;
    reg rx_done_reg, rx_done_next;

    // Output Logic
    assign rx = rx_reg;
    assign rx_done = rx_done_reg;

    // State Register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state       <= IDLE;
            rx_data_reg <= 0;
            bit_cnt_reg <= 0;
            rx_reg      <= 1'b1;
            rx_done_reg <= 1'b0;
        end else begin
            // clk detect : update
            state       <= state_next;
            rx_data_reg <= rx_data_next;
            bit_cnt_reg <= bit_cnt_next;
            rx_reg      <= rx_next;
            rx_done_reg <= rx_done_next;
        end
    end

    // Next State Combinational Logic
    always @(*) begin
        state_next   = state;
        rx_done_next = rx_done_reg;
        rx_data_next = rx_data_reg;
        rx_next      = rx_reg;
        bit_cnt_next = bit_cnt_reg;
        case (state)
            IDLE: begin
                rx_next      = 1'b1;
                rx_done_next = 1'b0;
                if (rx_start) begin
                    rx_data_next = rx_data;
                    bit_cnt_next = 0;
                    state_next   = START;
                end
            end
            START: begin
                rx_next = 1'b0;
                if (br_tick) state_next = DATA;
            end
            DATA: begin
                rx_next = rx_data_reg[0];
                if (br_tick) begin
                    if (bit_cnt_reg == 7) begin
                        state_next = STOP;
                    end else begin
                        bit_cnt_next = bit_cnt_reg + 1;
                        rx_data_next = {
                            1'b0, rx_data_reg[7:1]
                        };  // Right Shift Register
                    end
                end
            end
            STOP: begin
                rx_next = 1'b1;
                if (br_tick) begin
                    state_next   = IDLE;
                    rx_done_next = 1'b1;
                end
            end
        endcase
    end

endmodule
