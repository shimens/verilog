`timescale 1ns / 1ps
module controlUnit (
    input       clk,
    input       reset,
    input       btn1,
    input       btn2,
    input       btnM,
    input       rx,

    output tx,
    output btn1Tick,
    output btn2Tick,
    output selMode
);
    wire w_btn1, w_btn2, w_btnM;
    wire [7:0] w_rx_data;
    wire w_rx_empty, w_rx_en, w_rx_btn1, w_rx_btn2;

    assign btn1Tick = w_btn1 | w_rx_btn1;
    assign btn2Tick = w_btn2 | w_rx_btn2;

    button U_button1 (
        .clk(clk),
        .in (btn1),
        .out(w_btn1)
    );

    button U_button2 (
        .clk(clk),
        .in (btn2),
        .out(w_btn2)
    );

    button U_buttonM (
        .clk(clk),
        .in (btnM),
        .out(w_btnM)
    );

    uart_fifo U_uart_fifo (
        .clk  (clk),
        .reset(reset),

        .tx_en  (~w_rx_empty),
        .tx_data(w_rx_data),
        .tx_full(),

        .rx_en(w_rx_en),
        .rx_data(w_rx_data),
        .rx_empty(w_rx_empty),

        .RX(rx),
        .TX(tx)
    );



    controlFSM U_controlFSM (
        .clk(clk),
        .reset(reset),
        .btnM(w_btnM),
        .rxdata(w_rx_data),
        .rx_empty(w_rx_empty),

        .rd_en  (w_rx_en),
        .selMode(selMode),
        .rx_btn1(w_rx_btn1),
        .rx_btn2(w_rx_btn2)
    );


endmodule

module controlFSM (
    input       clk,
    input       reset,
    input       btnM,
    input [7:0] rxdata,
    input       rx_empty,

    output rd_en,
    output selMode,
    output rx_btn1,
    output rx_btn2
);

    localparam CLOCK = 0, STOPWATCH = 1;

    reg modeState_reg, modeState_next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg rx_btn1_reg, rx_btn1_next;
    reg rx_btn2_reg, rx_btn2_next;
    reg rd_en_reg, rd_en_next;

    assign rx_btn1 = rx_btn1_reg;
    assign rx_btn2 = rx_btn2_reg;
    assign selMode = modeState_reg;
    assign rd_en   = rd_en_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            modeState_reg <= CLOCK;
            rx_data_reg   <= 0;
            rx_btn1_reg   <= 0;
            rx_btn2_reg   <= 0;
            rd_en_reg     <= 0;
        end else begin
            modeState_reg <= modeState_next;
            rx_data_reg   <= rx_data_next;
            rx_btn1_reg   <= rx_btn1_next;
            rx_btn2_reg   <= rx_btn2_next;
            rd_en_reg     <= rd_en_next;
        end
    end

    always @(*) begin
        rx_btn1_next   = rx_btn1_reg;
        rx_btn2_next   = rx_btn2_reg;
        rd_en_next     = rd_en_reg;
        modeState_next = modeState_reg;
        if (btnM) begin
            modeState_next = modeState_reg;
            case (modeState_reg)
                CLOCK: modeState_next = STOPWATCH;
                STOPWATCH: modeState_next = CLOCK;
            endcase
        end else if (!rx_empty) begin
            case (rxdata)
                "1": rx_btn1_next = 1'b1;
                "2": rx_btn2_next = 1'b1;
                "m": begin
                    modeState_next = modeState_reg;
                    case (modeState_reg)
                        CLOCK: modeState_next = STOPWATCH;
                        STOPWATCH: modeState_next = CLOCK;
                    endcase
                end
            endcase
            rd_en_next = 1'b1;
        end else begin
            modeState_next = modeState_reg;
            rx_btn1_next = 1'b0;
            rx_btn2_next = 1'b0;
            rd_en_next = 1'b0;
        end
    end
endmodule
