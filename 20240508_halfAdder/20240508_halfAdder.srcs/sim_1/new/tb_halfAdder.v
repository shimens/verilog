`timescale 1ns / 1ps

module tb_halfAdder();

reg a0;
reg a1;
reg a2;
reg a3;
reg b0;
reg b1;
reg b2;
reg b3;
reg cin;
wire sum0;
wire sum1;
wire sum2;
wire sum3;
wire carry;
    
fullAdderfour test_bench(
    
.a0(a0),
.a1(a1),
.a2(a2),
.a3(a3),
.b0(b0),
.b1(b1),
.b2(b2),
.b3(b3),
.cin(cin),
.sum0(sum0),
.sum1(sum1),
.sum2(sum2),
.sum3(sum3),
.carry(carry)
    );
   
    
    initial begin
#00 cin = 0; a0 = 1; a1 = 0; a2 = 0; a3 = 0; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 cin = 0; a0 = 0; a1 = 1; a2 = 0; a3 = 0; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 cin = 0; a0 = 1; a1 = 1; a2 = 0; a3 = 1; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 cin = 0; a0 = 0; a1 = 0; a2 = 1; a3 = 1; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 cin = 0; a0 = 1; a1 = 0; a2 = 1; a3 = 1; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 cin = 1; a0 = 1; a1 = 1; a2 = 0; a3 = 0; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 cin = 1; a0 = 0; a1 = 0; a2 = 1; a3 = 0; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 cin = 1; a0 = 1; a1 = 0; a2 = 1; a3 = 0; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 cin = 1; a0 = 0; a1 = 1; a2 = 1; a3 = 1; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 cin = 1; a0 = 1; a1 = 1; a2 = 1; a3 = 1; b0 = 1; b1 = 1; b2 = 0; b3 = 0;
#10 $finish;
    end
    
endmodule

/*
`timescale 1ns / 1ps

module tb_halfAdder();
reg a;
reg b;
    reg cin;
    wire sum;
    wire carry;
    
    fullAdder test_bench(
        .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .carry(carry)
    );
   
    
    initial begin
#00 cin = 0; a = 0; b = 0;
#10 cin = 0; a = 0; b = 1;
#10 cin = 0; a = 1; b = 0;
#10 cin = 0; a = 1; b = 1;
#10 cin = 1; a = 0; b = 0;
#10 cin = 1; a = 0; b = 1;
#10 cin = 1; a = 1; b = 0;
#10 cin = 1; a = 1; b = 1;
#10 $finish;
    end
    
endmodule

/*
halfAdder test_bench(
    .a(a),
    .b(b),
    .sum(sum),
    .carry(carry)
    );
*/


/*
module tb_halfAdder();
reg a;
reg b;
    reg cin;
    wire sum;
    wire carry;
    
    fullAdder test_bench(
        .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .carry(carry)
    );
   
    
    initial begin
#00 cin = 0; a = 0; b = 0;
#10 cin = 0; a = 0; b = 1;
#10 cin = 0; a = 1; b = 0;
#10 cin = 0; a = 1; b = 1;
#10 cin = 1; a = 0; b = 0;
#10 cin = 1; a = 0; b = 1;
#10 cin = 1; a = 1; b = 0;
#10 cin = 1; a = 1; b = 1;
#10 $finish;
    end
*/

/*
halfAdder test_bench(
    .a(a),
    .b(b),
    .sum(sum),
    .carry(carry)
    );
*/