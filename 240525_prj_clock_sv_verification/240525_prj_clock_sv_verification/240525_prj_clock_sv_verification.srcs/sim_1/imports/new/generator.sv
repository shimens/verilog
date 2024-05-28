

`include "transaction.sv"

class generator;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    event gen_next_event;

    function new(mailbox#(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox   = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run(int count);
        repeat (count) begin
            trans = new();
            assert (trans.randomize())
            else $error("[GEN] trans.randomize() error!");
            gen2drv_mbox.put(trans);
            trans.display("GEN");
            @(gen_next_event);
        end
    endtask
endclass  //generator


// `include "transaction.sv"

// class generator;
//     transaction trans;
//     mailbox #(transaction) gen2drv_mbox;
//     event gen_next_event;

//     function new(mailbox#(transaction) gen2drv_mbox, event gen_next_event);
//         this.gen2drv_mbox   = gen2drv_mbox;
//         this.gen_next_event = gen_next_event;
//     endfunction  //new()

//     task run(int count);
//         repeat (count) begin
//             trans = new();
//             assert (trans.randomize())
//             else $error("[GEN] trans.randomize() error!");
//             gen2drv_mbox.put(trans);
//             trans.display("GEN");
//             @(gen_next_event);
//         end
//     endtask
// endclass  //generator
