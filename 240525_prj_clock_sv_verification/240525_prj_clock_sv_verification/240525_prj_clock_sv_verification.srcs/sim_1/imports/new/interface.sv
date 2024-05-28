

`ifndef __INTERFACE_SV_
`define __INTERFACE_SV_

interface clk_interface;
    logic       clk;
    logic       reset;
    logic       selMode;
    logic       minSet;
    logic       secSet;
    logic       sw_digit;
    logic [6:0] clock_MSB;
    logic [6:0] clock_LSB;
endinterface  //clk_interface

`endif


// `ifndef __INTERFACE_SV_
// `define __INTERFACE_SV_

// interface clk_interface;
//     logic       clk;
//     logic       reset;
//     logic       selMode;
//     logic       MSBSet;
//     logic       LSBSet;
//     logic       sw_digit;
//     logic [6:0] clock_MSB;
//     logic [6:0] clock_LSB;
//     logic [6:0] clock_hour;
//     logic [6:0] clock_min;
//     logic [6:0] clock_sec;
//     logic [6:0] clock_msec;
// endinterface  //clk_interface

// `endif
