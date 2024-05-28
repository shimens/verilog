`timescale 1ns / 1ps

module stopWatch (
    input        clk,
    input        reset,
    input        btn_Mode,
    input        btn1_Tick,
    input        btn2_Tick,
    input        sw_digit,
    output [6:0] stopWatch_MSB,
    output [6:0] stopWatch_LSB
);
    wire w_clk_1khz, w_clk_1hz;
    wire [6:0] w_count_ms, w_count_s, w_count_m, w_count_h;

    clkDiv #(
//        .MAX_COUNT(1_000_000)
        .MAX_COUNT(3)

    ) U_ClkDiv_100hz (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    prjStopWatch U_prjStopWatch (
        .clk      (clk),
        .reset    (reset),
        .tick     (w_clk_100hz),
        .btn_Mode (btn_Mode),
        .btn1_Tick(btn1_Tick),
        .btn2_Tick(btn2_Tick),
        .count_ms (w_count_ms),
        .count_s  (w_count_s),
        .count_m  (w_count_m),
        .count_h  (w_count_h)
    );

    mux2x1 U_muxMSB (
        .x0 (w_count_ms),
        .x1 (w_count_m),
        .sel(sw_digit),
        .y  (stopWatch_MSB)
    );

    mux2x1 U_muxLSB (
        .x0 (w_count_s),
        .x1 (w_count_h),
        .sel(sw_digit),
        .y  (stopWatch_LSB)
    );

endmodule

module prjStopWatch (
    input        clk,
    input        reset,
    input        tick,
    input        btn_Mode,
    input        btn1_Tick,  // run_stop
    input        btn2_Tick,  // clear
    output [6:0] count_ms,
    output [6:0] count_s,
    output [6:0] count_m,
    output [6:0] count_h
);
    localparam STOP = 0, START = 1, CLEAR = 2;

    reg [1:0] state, state_next;
    reg [6:0] counter_ms_reg, counter_ms_next;
    reg [6:0] counter_s_reg, counter_s_next;
    reg btn1_reg, btn1_next;
    reg btn2_reg, btn2_next;

    reg [6:0] counter_m_reg, counter_m_next;
    reg [6:0] counter_h_reg, counter_h_next;

    assign count_ms = counter_ms_reg;
    assign count_s  = counter_s_reg;

    assign count_m  = counter_m_reg;
    assign count_h  = counter_h_reg;

    // State register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state          <= STOP;
            counter_ms_reg <= 0;
            counter_s_reg  <= 0;
            btn1_reg       <= 0;
            btn2_reg       <= 0;

            counter_m_reg  <= 0;
            counter_h_reg  <= 0;

        end else begin
            state          <= state_next;
            counter_ms_reg <= counter_ms_next;
            counter_s_reg  <= counter_s_next;
            btn1_reg       <= btn1_next;
            btn2_reg       <= btn2_next;

            counter_m_reg  <= counter_m_next;
            counter_h_reg  <= counter_h_next;

        end
    end

    // Next state combinational logic
    always @(*) begin
        state_next = state;
        counter_ms_next = counter_ms_reg;
        counter_s_next = counter_s_reg;
        btn1_next = btn1_Tick;
        btn2_next = btn2_Tick;

        counter_m_next = counter_m_reg;
        counter_h_next = counter_h_reg;

        case (state)
            STOP: begin
                if (btn_Mode) begin
                    if (btn1_reg) begin
                        state_next = START;
                    end else if (btn2_reg) begin
                        state_next = CLEAR;
                    end
                end else begin
                    counter_ms_next = counter_ms_reg;
                    counter_s_next  = counter_s_reg;

                    counter_m_next  = counter_m_reg;
                    counter_h_next  = counter_h_reg;

                end
            end
            START: begin
                if (btn_Mode) begin
                    if (btn1_reg) begin
                        state_next = STOP;
                    end
                end
                if (tick) begin
                    if (counter_ms_reg == 99) begin
                        counter_ms_next = 0;
                        if (counter_s_reg == 59) begin
                            counter_s_next = 0;

                            if (counter_m_reg == 59) begin
                                counter_m_next = 0;
                                if (counter_h_reg == 24) begin
                                    counter_h_next = 0;
                                end else begin
                                    counter_h_next = counter_h_reg + 1;
                                end
                            end else begin
                                counter_m_next = counter_m_reg + 1;
                            end

                        end else begin
                            counter_s_next = counter_s_reg + 1;
                        end
                    end else begin
                        counter_ms_next = counter_ms_reg + 1;
                    end
                end
            end
            CLEAR: begin
                if (btn_Mode) begin
                    counter_ms_next = 0;
                    counter_s_next = 0;

                    counter_m_next = 0;
                    counter_h_next = 0;

                    state_next = STOP;
                end
            end
        endcase
    end
endmodule

module clkDiv #(
    parameter MAX_COUNT = 100
) (
    input  clk,
    input  reset,
    output o_clk
);
    reg [$clog2(MAX_COUNT)-1:0] counter = 0;
    reg r_tick = 0;

    assign o_clk = r_tick;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if (counter == (MAX_COUNT - 1)) begin
                counter <= 0;
                r_tick  <= 1'b1;
            end else begin
                counter <= counter + 1;
                r_tick  <= 1'b0;
            end
        end
    end
endmodule