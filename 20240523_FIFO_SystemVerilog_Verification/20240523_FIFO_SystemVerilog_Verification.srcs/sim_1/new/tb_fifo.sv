`timescale 1ns / 1ps

`include "environment.sv"

module tb_fifo ();
    environment env;
    fifo_interface fifo_intf();

    fifo #(
        .ADDR_WIDTH(3),
        .DATA_WIDTH(8)
    ) dut (
        .clk  (fifo_intf.clk),
        .reset(fifo_intf.reset),
        .wr_en(fifo_intf.wr_en),
        .full (fifo_intf.full),
        .wdata(fifo_intf.wdata),
        .rd_en(fifo_intf.rd_en),
        .empty(fifo_intf.empty),
        .rdata(fifo_intf.rdata)
    );

    always #5 fifo_intf.clk = ~fifo_intf.clk;

    initial begin
        fifo_intf.clk = 0;
    end

    initial begin
        env = new(fifo_intf);
        env.run_test(100);
    end
endmodule
