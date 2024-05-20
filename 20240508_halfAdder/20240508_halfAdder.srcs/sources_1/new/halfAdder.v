`timescale 1ns / 1ps

module fullAdderfour (
input a0,
input a1,
input a2,
input a3,
input b0,
input b1,
input b2,
input b3,
input cin,
output sum0,
output sum1,
output sum2,
output sum3,
output carry
);
    wire w_carry1, w_carry2, w_carry3;
    
fullAdder u_FA1(
.a(a0),
.b(b0),
.cin(cin),
.sum(sum0),
.carry(w_carry1)
);

fullAdder u_FA2(
.a(a1),
.b(b1),
.cin(w_carry1),
.sum(sum1),
.carry(w_carry2)
);

fullAdder u_FA3(
.a(a2),
.b(b2),
.cin(w_carry2),
.sum(sum2),
.carry(w_carry3)
);

fullAdder u_FA4(
.a(a3),
.b(b3),
.cin(w_carry3),
.sum(sum3),
.carry(carry)
);

endmodule

module fullAdder (
    input a,
    input b,
    input cin,
    output sum,
    output carry
);
    wire w_sum1, w_carry1, w_carry2;

halfAdder u_HA1(
    .a(a),
    .b(b),
    .sum(w_sum1),
    .carry(w_carry1)
);

halfAdder u_HA2(
    .a(w_sum1),
    .b(cin),
    .sum(sum),
    .carry(w_carry2)
);

assign carry = w_carry1 | w_carry2;

endmodule

module halfAdder(
    input a,
    input b,
    output sum,
    output carry
);

 xor(sum,a,b);    // assign sum = a ^ b;
 and(carry,a,b);    // assign carry = a & b;
    
endmodule

