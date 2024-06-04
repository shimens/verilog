`timescale 1ns / 1ps
//General Purpose Output

module GPO(
    input clk,
    input reset,
    input sel,
    input we,
    input address,
    input [31:0] wData,
    output [31:0] rData,
    output [3:0] outPort
    ); 
    
    reg [31:0] gpoRegMap[0:1];
    //assign outPort = gpoRegMap[1][3:0];
    assign outPort = gpoRegMap[0][3:0];
    assign rData = we ? 32'bx : gpoRegMap[address]; // Master check -> do not read
    
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            gpoRegMap[0] <= 0;
            gpoRegMap[1] <= 0;
    end
    else begin
        if (sel && we)begin
            gpoRegMap[address] <=  wData;
            end
        end
    end   
    
endmodule
