
// `include "interface.sv"
// `include "transaction.sv"
// `include "generator.sv"
// `include "driver.sv"
// `include "monitor.sv"
// `include "scoreboard.sv"

// class environment;
//     generator              gen;
//     driver                 drv;
//     monitor                mon;
//     scoreboard             scb;

//     event                  gen_next_event;

//     mailbox #(transaction) gen2drv_mbox;
//     mailbox #(transaction) mon2scb_mbox;

//     function new(virtual clk_interface clk_intf);
//         gen2drv_mbox = new();
//         mon2scb_mbox = new();

//         gen = new(gen2drv_mbox, gen_next_event);
//         drv = new(clk_intf, gen2drv_mbox);
//         mon = new(clk_intf, mon2scb_mbox);
//         scb = new(mon2scb_mbox, gen_next_event);
//     endfunction

//     task report();
//         $display("=======================================");
//         $display("==            Final Report           ==");
//         $display("=======================================");
//         $display("Total Test : %d", scb.total_cnt);
//         $display("PASS1 Test  : %d", scb.pass1_cnt);
//         $display("PASS2 Test  : %d", scb.pass2_cnt);
//         $display("PASS3 Test  : %d", scb.pass3_cnt);
//         $display("FAIL Test  : %d", scb.fail_cnt);
//         $display("=======================================");
//         $display("==      test bench is finished!      ==");
//         $display("=======================================");
//         #10 $finish;
//     endtask

//     task pre_run();
//         drv.reset();
//     endtask

//     task run(int count);
//         fork
//             gen.run(count);  // 숫자는 count값
//             drv.run();
//             mon.run();
//             scb.run();
//         join_any
//         report();
//         #10 $finish;
//     endtask

//     task run_test(int count);
//         pre_run();
//         run(count);
//     endtask
// endclass