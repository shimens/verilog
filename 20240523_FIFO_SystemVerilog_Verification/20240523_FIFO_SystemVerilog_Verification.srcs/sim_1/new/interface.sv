
`ifndef __INTERFACE_SV_
`define __INTERFACE_SV_

interface fifo_interface;
    logic       clk;
    logic       reset;
    logic       wr_en;
    logic       full;
    logic [7:0] wdata;
    logic       rd_en;
    logic       empty;
    logic [7:0] rdata;
endinterface  //fifo_interface

`endif 