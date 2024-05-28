`timescale 1ns / 1ps

`include "environment.sv"

module tb_clock ();
    environment env;
    clk_interface clk_intf ();

    prjClock dut (
        .clk      (clk_intf.clk),
        .reset    (clk_intf.reset),
        .selMode  (clk_intf.selMode),
        .minSet   (clk_intf.minSet),
        .secSet   (clk_intf.secSet),
        .sw_digit (clk_intf.sw_digit),
        .clock_MSB(clk_intf.clock_MSB),
        .clock_LSB(clk_intf.clock_LSB)
    );

    always #5 clk_intf.clk = ~clk_intf.clk;

    initial begin
        clk_intf.clk = 0;
    end

    initial begin
        env = new(clk_intf);
        env.run_test(100);
    end

endmodule


// `timescale 1ns / 1ps

// `include "environment.sv"

// module tb_clock ();
//     environment env;
//     clk_interface clk_intf ();

//     prjClock dut (
//         .clk       (clk_intf.clk),
//         .reset     (clk_intf.reset),
//         .selMode   (clk_intf.selMode),
//         .MSBSet    (clk_intf.MSBSet),
//         .LSBSet    (clk_intf.LSBSet),
//         .sw_digit  (clk_intf.sw_digit),
//         .clock_MSB (clk_intf.clock_MSB),
//         .clock_LSB (clk_intf.clock_LSB),
//         .clock_hour(clk_intf.clock_hour),
//         .clock_min (clk_intf.clock_min),
//         .clock_sec (clk_intf.clock_sec),
//         .clock_msec(clk_intf.clock_msec)
//     );

//     always #5 clk_intf.clk = ~clk_intf.clk;

//     initial begin
//         clk_intf.clk = 0;
//     end

//     initial begin
//         env = new(clk_intf);
//         env.run_test(1000);
//     end

// endmodule
