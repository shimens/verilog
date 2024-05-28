

`include "transaction.sv"
`include "interface.sv"

class driver;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    virtual clk_interface clk_intf;
    function new(virtual clk_interface clk_intf,
                 mailbox#(transaction) gen2drv_mbox);
        this.clk_intf    = clk_intf;
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction  //new()

    task reset();
        clk_intf.reset    <= 1'b1;
        clk_intf.selMode  <= 1;
        clk_intf.sw_digit <= 0;
        // clk_intf.selMode  <= 0;
        // clk_intf.sw_digit <= 0;
        clk_intf.minSet   <= 0;
        clk_intf.secSet   <= 0;
        repeat (5) @(posedge clk_intf.clk);
        clk_intf.reset <= 1'b0;
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(trans);
            clk_intf.selMode  <= 0;
            // clk_intf.sw_digit <= 0;
            // clk_intf.selMode  <= trans.selMode;
            clk_intf.sw_digit <= trans.sw_digit;
            // clk_intf.minSet   <= 0;
            // clk_intf.secSet   <= 0;
            clk_intf.minSet   <= trans.minSet;
            clk_intf.secSet   <= trans.secSet;
            trans.display("DRV");
            @(posedge clk_intf.clk);
        end
    endtask
endclass  //driver


// `include "transaction.sv"
// `include "interface.sv"

// class driver;
//     transaction trans;
//     mailbox #(transaction) gen2drv_mbox;
//     virtual clk_interface clk_intf;
//     function new(virtual clk_interface clk_intf,
//                  mailbox#(transaction) gen2drv_mbox);
//         this.clk_intf    = clk_intf;
//         this.gen2drv_mbox = gen2drv_mbox;
//     endfunction  //new()

//     task reset();
//         clk_intf.reset    <= 1'b1;
//         clk_intf.selMode  <= 1;
//         clk_intf.sw_digit <= 1;
//         // clk_intf.selMode  <= 0;
//         // clk_intf.sw_digit <= 0;
//         clk_intf.MSBSet   <= 0;
//         clk_intf.LSBSet   <= 0;
//         repeat (5) @(posedge clk_intf.clk);
//         clk_intf.reset <= 1'b0;
//     endtask

//     task run();
//         forever begin
//             gen2drv_mbox.get(trans);
//             clk_intf.selMode  <= 0;
//             clk_intf.sw_digit <= 0;
//             // clk_intf.selMode  <= trans.selMode;
//             // clk_intf.sw_digit <= trans.sw_digit;
//             clk_intf.MSBSet   <= trans.MSBSet;
//             clk_intf.LSBSet   <= trans.LSBSet;
//             trans.display("DRV");
//             @(posedge clk_intf.clk);
//         end
//     endtask
// endclass  //driver
