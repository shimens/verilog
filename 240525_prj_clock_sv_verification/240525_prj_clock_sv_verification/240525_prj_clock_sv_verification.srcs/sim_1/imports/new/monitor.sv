

`include "interface.sv"
`include "transaction.sv"

class monitor;
    virtual clk_interface clk_intf;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;

    function new(virtual clk_interface clk_intf,
                 mailbox#(transaction) mon2scb_mbox);
        this.clk_intf    = clk_intf;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction  //new()

    task run();
        forever begin
            trans = new();
            trans.selMode  = clk_intf.selMode;
            trans.minSet   = clk_intf.minSet;
            trans.secSet   = clk_intf.secSet;
            trans.sw_digit = clk_intf.sw_digit;
            @(posedge clk_intf.clk);
            trans.clock_MSB = clk_intf.clock_MSB;
            trans.clock_LSB = clk_intf.clock_LSB;
            #1;
            mon2scb_mbox.put(trans);
            trans.display("MON");
        end
    endtask
endclass  //monitor


// `include "interface.sv"
// `include "transaction.sv"

// class monitor;
//     virtual clk_interface clk_intf;
//     mailbox #(transaction) mon2scb_mbox;
//     transaction trans;

//     function new(virtual clk_interface clk_intf,
//                  mailbox#(transaction) mon2scb_mbox);
//         this.clk_intf    = clk_intf;
//         this.mon2scb_mbox = mon2scb_mbox;
//     endfunction  //new()

//     task run();
//         forever begin
//             trans = new();
//             #1;
//             trans.selMode  = clk_intf.selMode;
//             trans.MSBSet   = clk_intf.MSBSet;
//             trans.LSBSet   = clk_intf.LSBSet;
//             trans.sw_digit = clk_intf.sw_digit;
//             @(posedge clk_intf.clk);
//             trans.clock_MSB  = clk_intf.clock_MSB;
//             trans.clock_LSB  = clk_intf.clock_LSB;
//             trans.clock_hour = clk_intf.clock_hour;
//             trans.clock_min  = clk_intf.clock_min;
//             trans.clock_sec  = clk_intf.clock_sec;
//             trans.clock_msec = clk_intf.clock_msec;
//             mon2scb_mbox.put(trans);
//             trans.display("MON");
//         end
//     endtask
// endclass  //monitor
