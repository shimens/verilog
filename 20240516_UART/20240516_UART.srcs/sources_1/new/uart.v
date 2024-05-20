`timescale 1ns / 1ps

module uart (
    input        clk,
    input        reset,
    input        start,
    input  [7:0] tx_data,
    output       tx_done,
    output       txd
);
    wire br_tick;

    baudrate_generator U_BR_Gen (
        .clk(clk),
        .reset(reset),
        .br_tick(br_tick)
    );

    transmitter U_TxD (
        .clk(clk),
        .reset(reset),
        .br_tick(br_tick),
        .start(start),
        .data(tx_data),
        .tx_done(tx_done),
        .tx(txd)
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
        // if (counter_reg == 10 - 1) begin  // for simulation
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
    input        start,
    input  [7:0] data,
    output       tx_done,
    output       tx
);
    localparam IDLE = 0, START = 1, STOP = 10;
    localparam D0 = 2, D1 = 3, D2 = 4, D3 = 5, D4 = 6, D5 = 7, D6 = 8, D7 = 9;

    reg [3:0] state, state_next;
    reg [7:0] r_data;
    reg tx_reg, tx_next;
    reg tx_done_reg, tx_done_next;

    assign tx      = tx_reg;
    assign tx_done = tx_done_reg;

    // State Register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state       <= IDLE;
            tx_reg      <= 1'b0;
            tx_done_reg <= 1'b0;
        end else begin
            state       <= state_next;
            tx_reg      <= tx_next;
            tx_done_reg <= tx_done_next;
        end
    end

    // Next State Combinational Logic
    always @(*) begin
        state_next = state;
        case (state)
            IDLE:  if (start) state_next = START;
            START: if (br_tick) state_next = D0;
            D0:    if (br_tick) state_next = D1;
            D1:    if (br_tick) state_next = D2;
            D2:    if (br_tick) state_next = D3;
            D3:    if (br_tick) state_next = D4;
            D4:    if (br_tick) state_next = D5;
            D5:    if (br_tick) state_next = D6;
            D6:    if (br_tick) state_next = D7;
            D7:    if (br_tick) state_next = STOP;
            STOP:  if (br_tick) state_next = IDLE;
        endcase
    end

    // Output Combinational Logic
    always @(*) begin
        tx_next      = tx_reg;
        tx_done_next = 1'b0;
        case (state)
            IDLE: tx_next = 1'b1;
            START: begin
                tx_next = 1'b0;
                r_data  = data;
            end
            D0:   tx_next = r_data[0];
            D1:   tx_next = r_data[1];
            D2:   tx_next = r_data[2];
            D3:   tx_next = r_data[3];
            D4:   tx_next = r_data[4];
            D5:   tx_next = r_data[5];
            D6:   tx_next = r_data[6];
            D7:   tx_next = r_data[7];
            STOP: begin
                tx_next = 1'b1;
                if (state_next == IDLE) tx_done_next = 1'b1;
            end
        endcase
    end
endmodule
