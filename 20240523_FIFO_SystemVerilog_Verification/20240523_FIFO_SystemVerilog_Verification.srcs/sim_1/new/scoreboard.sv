
`include "transaction.sv"
`include "interface.sv"

class scoreboard;
    transaction trans;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;

    int total_cnt, pass_cnt, fail_cnt, write_cnt;
    reg [7:0] scb_fifo[$:8];  // $ is queue (fifo). golden reference
    reg [7:0] scb_fifo_data;

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
        total_cnt           = 0;
        pass_cnt            = 0;
        fail_cnt            = 0;
        write_cnt           = 0;
    endfunction  //new()

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            trans.display("SCB");
            if (trans.wr_en) begin
                scb_fifo.push_back(trans.wdata);
                $display(" --> WRITE! fifo_data %d, queue size:%0d, %p",
                         trans.wdata, scb_fifo.size(), scb_fifo);
                write_cnt++;
            end else if (trans.rd_en) begin
                scb_fifo_data = scb_fifo.pop_front();
                if (scb_fifo_data == trans.rdata) begin
                    $display(
                        " --> PASS! fifo_data %d == rdata %d, que size:%0d, %p",
                        scb_fifo_data, trans.rdata, scb_fifo.size(), scb_fifo);
                    pass_cnt++;
                end else begin
                    $display(
                        " --> FAIL! fifo_data %d == rdata %d, que size:%0d, %p",
                        scb_fifo_data, trans.rdata, scb_fifo.size(), scb_fifo);
                    fail_cnt++;
                end
            end
            total_cnt++;
            ->gen_next_event;
        end
    endtask
endclass  //scoreboard
