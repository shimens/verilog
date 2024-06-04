`timescale 1ns / 1ps

module RAM(
	input clk,
	input reset,
	input we, // 1->write 0->read.
	input ce, // Chip Enable
	input [7:0] addr, // Address RAM Storage about 
    input [31:0] i_data, // wData
	output [31:0] o_data  // rData
	);
	// memory space
	reg [31:0] mem [0:2**8-1];  /*same as [0:255] // [0:1023]*/
    
	assign o_data =  we ? 32'bz : mem[addr]; // high impedence state

	always @(posedge clk) begin
		if (we && ce && !reset) mem [addr] <= i_data;
	end
endmodule

 