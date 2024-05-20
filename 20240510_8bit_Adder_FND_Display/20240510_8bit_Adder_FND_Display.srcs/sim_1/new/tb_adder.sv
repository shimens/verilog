`timescale 1ns / 1ps

class transaction;
    rand logic [7:0] a;
    rand logic [7:0] b;
endclass  //transaction

module tb_adder ();
    transaction trans;

    logic [7:0] a, b, sum;
    logic co;

    Adder_8bit dut (
        .a  (a),
        .b  (b),
        .cin(1'b0),
        .sum(sum),
        .co (co)
    );

    initial begin
        trans = new();
        repeat (10000) begin
            trans.randomize();
            a = trans.a;  // dut의 a에 입력
            b = trans.b;  // dut의 b에 입력
            #10;
            $display("%t : a(%d) + b(%d) = sum(%d)", $time, trans.a, trans.b, {co, sum});
            if ((trans.a + trans.b) == {co, sum}) $display("passed!");
            else $display("failed!");
        end
    end

endmodule
