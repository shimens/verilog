
`include "transaction.sv"
`include "interface.sv"

class driver;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    virtual fifo_interface fifo_intf;
    function new(virtual fifo_interface fifo_intf,
                 mailbox#(transaction) gen2drv_mbox);
        this.fifo_intf    = fifo_intf;
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction  //new()

    task reset();
        fifo_intf.reset <= 1'b1;
        fifo_intf.wr_en <= 1'b0;
        fifo_intf.wdata <= 0;
        fifo_intf.rd_en <= 1'b0;
        repeat (5) @(posedge fifo_intf.clk);
        fifo_intf.reset <= 1'b0;
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(trans);
            fifo_intf.wr_en <= trans.wr_en;
            fifo_intf.wdata <= trans.wdata;
            fifo_intf.rd_en <= trans.rd_en;
            trans.display("DRV");
            @(posedge fifo_intf.clk);
        end
    endtask
endclass  //driver
