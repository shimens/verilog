`timescale 1ns / 1ps

module uart (
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,
    output tx,
    output tx_done
);
wire w_br_tick;

baudrate_generator U_BR_GEN (
    .clk(clk),
    .reset(reset),
    .br_tick(w_br_tick)
);

transmitter U_TxD (
    .clk(clk),
    .reset(reset),
    .br_tick(w_br_tick),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_done(tx_done)
);

endmodule

module baudrate_generator (
    input  clk,
    input  reset,
    output br_tick
);
    reg [$clog2(100_000_000/9600)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    assign br_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg    <= 0;
        end else begin
            counter_reg <= counter_next;
            tick_reg    <= tick_next;
        end
    end

    always @(*) begin
        counter_next = counter_reg;
        //if (counter_reg == 10 - 1) begin  // for simulation
        if (counter_reg == 100_000_000 / 9600 - 1) begin
            counter_next = 0;
            tick_next    = 1'b1;
        end else begin
            counter_next = counter_reg + 1;
            tick_next    = 1'b0;
        end
    end

endmodule

module transmitter (
    input        clk,
    input        reset,
    input        br_tick,
    input        tx_start,
    input  [7:0] tx_data,
    output       tx,
    output       tx_done
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state, state_next;
    reg [7:0] tx_data_reg, tx_data_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg tx_reg, tx_next;
    reg tx_done_reg, tx_done_next;

    // Output Logic
    assign tx = tx_reg;
    assign tx_done = tx_done_reg;

    // State Register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state       <= IDLE;
            tx_data_reg <= 0;
            bit_cnt_reg <= 0;
            tx_reg      <= 1'b1;
            tx_done_reg <= 1'b0;
        end else begin
            // clk detect : update
            state       <= state_next;
            tx_data_reg <= tx_data_next;
            bit_cnt_reg <= bit_cnt_next;
            tx_reg      <= tx_next;
            tx_done_reg <= tx_done_next;
        end
    end

    // Next State Combinational Logic
    always @(*) begin
        state_next   = state;
        tx_done_next = tx_done_reg;
        tx_data_next = tx_data_reg;
        tx_next      = tx_reg;
        bit_cnt_next = bit_cnt_reg;
        case (state)
            IDLE: begin
                tx_next      = 1'b1;
                tx_done_next = 1'b0;
                if (tx_start) begin
                    tx_data_next = tx_data;
                    bit_cnt_next = 0;
                    state_next   = START;
                end
            end
            START: begin
                tx_next = 1'b0;
                if (br_tick) state_next = DATA;
            end
            DATA: begin
                tx_next = tx_data_reg[0];
                if (br_tick) begin
                    if (bit_cnt_reg == 7) begin
                        state_next = STOP;
                    end else begin
                        bit_cnt_next = bit_cnt_reg + 1;
                        tx_data_next = {1'b0, tx_data_reg[7:1]};  // Right Shift Register
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (br_tick) begin
                    state_next   = IDLE;
                    tx_done_next = 1'b1;
                end
            end
        endcase
    end

endmodule
