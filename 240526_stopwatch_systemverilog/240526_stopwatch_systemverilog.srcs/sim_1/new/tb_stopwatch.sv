// `timescale 1ns / 1ps

// interface stopWatch_if();
//     logic clk;
//     logic reset;
//     logic btn_Mode;
//     logic btn1_Tick;
//     logic btn2_Tick;
//     logic sw_digit;
//     logic [6:0] stopWatch_MSB;
//     logic [6:0] stopWatch_LSB;
//     logic tick;
// endinterface // stopWatch_if

// class transaction;
//     rand logic btn_Mode;
//     rand logic btn1_Tick;
//     rand logic btn2_Tick;
//     rand logic sw_digit;
//     int stopWatch_MSB;
//     int stopWatch_LSB;
//     logic tick;

//     task display(string name);
//         $display("[%s] btn_Mode:%b, btn1_Tick:%b, btn2_Tick:%b, sw_digit:%b, stopWatch_MSB:%0d, stopWatch_LSB:%0d", name, btn_Mode, btn1_Tick, btn2_Tick, sw_digit, stopWatch_MSB, stopWatch_LSB);
//     endtask

//     constraint c_btn_Mode {btn_Mode dist {0:/0, 1:/100};}
//     // 5퍼 95퍼로 분배
//     constraint c_btn1_Tick {btn1_Tick dist {0:/50, 1:/50};}
//      // 50퍼 50퍼로 분배
//     constraint c_btn2_Tick {btn2_Tick dist {0:/99, 1:/1};}
//     // 98퍼 2퍼로 분배
//     constraint c_sw_digit {sw_digit dist {0:/50, 1:/50};}

// endclass // transaction

// class generator;
//     transaction trans;
//     mailbox #(transaction) gen2drv_mbox;
//     event gen_next_event;

//     function new(mailbox #(transaction) gen2drv_mbox, event gen_next_event);
//         this.gen2drv_mbox = gen2drv_mbox;
//         this.gen_next_event = gen_next_event;
//     endfunction // new()

//     task run(int count);
//         repeat (count) begin
//             trans = new();
//             assert (trans.randomize()) else $error("[GEN] trans.randomize() ERROR!");
//             gen2drv_mbox.put(trans);
//             trans.display("GEN");
//             @(gen_next_event); // Wait for event to generate next transaction
//         end
//     endtask // run
// endclass // generator

// class driver;
//     transaction trans;
//     mailbox #(transaction) gen2drv_mbox;
//     virtual stopWatch_if stopWatch_intf;

//     function new(virtual stopWatch_if stopWatch_intf, mailbox #(transaction) gen2drv_mbox);
//         this.stopWatch_intf = stopWatch_intf;
//         this.gen2drv_mbox = gen2drv_mbox;
//     endfunction // new()

//     task reset();
//         stopWatch_intf.btn_Mode <= 1'b0;
//         stopWatch_intf.btn1_Tick <= 1'b0;
//         stopWatch_intf.btn2_Tick <= 1'b0;
//         stopWatch_intf.sw_digit <= 1'b0;
//         repeat (5) @(posedge stopWatch_intf.clk);
//     endtask // reset

//     task run();
//         forever begin
//             gen2drv_mbox.get(trans);
//             stopWatch_intf.btn_Mode <= trans.btn_Mode;
//             stopWatch_intf.btn1_Tick <= trans.btn1_Tick;
//             stopWatch_intf.btn2_Tick <= trans.btn2_Tick;
//             stopWatch_intf.sw_digit <= trans.sw_digit;
//             trans.display("DRV");
//             @(posedge stopWatch_intf.clk);
//         end
//     endtask // run
// endclass // driver

// class monitor;
//     virtual stopWatch_if stopWatch_intf;
//     mailbox #(transaction) mon2scb_mbox;
//     transaction trans;

//     function new(virtual stopWatch_if stopWatch_intf, mailbox #(transaction) mon2scb_mbox);
//         this.stopWatch_intf = stopWatch_intf;
//         this.mon2scb_mbox = mon2scb_mbox;
//     endfunction // new()

//     task run();
//         forever begin
//             trans = new();
//             @(posedge stopWatch_intf.clk);
//             trans.btn_Mode = stopWatch_intf.btn_Mode;
//             trans.btn1_Tick = stopWatch_intf.btn1_Tick;
//             trans.btn2_Tick = stopWatch_intf.btn2_Tick;
//             trans.sw_digit = stopWatch_intf.sw_digit;
//             trans.stopWatch_MSB = stopWatch_intf.stopWatch_MSB;
//             trans.stopWatch_LSB = stopWatch_intf.stopWatch_LSB;
//             trans.display("MON");
//             mon2scb_mbox.put(trans);
//         end
//     endtask // run
// endclass // monitor

// class scoreboard;
//     mailbox #(transaction) mon2scb_mbox;
//     transaction trans;
//     event gen_next_event;
//     int total_cnt;
//     int pass_cnt;
//     int fail_cnt;

//     // Reference model state
//     typedef enum logic [1:0] {STOP = 0, START = 1, CLEAR = 2} state_t;
//     state_t ref_state;
//     int ref_count_ms;
//     int ref_count_s;
//     int ref_count_m;
//     int ref_count_h;
//     int expected_msb, expected_lsb;

//     function new(mailbox #(transaction) mon2scb_mbox, event gen_next_event);
//         this.mon2scb_mbox = mon2scb_mbox;
//         this.gen_next_event = gen_next_event;
//         total_cnt = 0;
//         pass_cnt = 0;
//         fail_cnt = 0;
//         ref_state = STOP;
//         ref_count_ms = 0;
//         ref_count_s = 0;
//         ref_count_m = 0;
//         ref_count_h = 0;
//         expected_msb = 0;
//         expected_lsb = 0;
//     endfunction // new()

//     task run();
//         forever begin
//             mon2scb_mbox.get(trans);
//             trans.display("SCB");
//             total_cnt++;
//             // Update reference model based on transaction
//             update_reference_model(trans);
//             // Perform checks and compare with expected values
//             if (check_output(trans)) begin
//                 pass_cnt++;
//             end else begin
//                 fail_cnt++;
//                 $display("[FAIL] Output mismatch: expected MSB:%0d, LSB:%0d, got MSB:%0d, LSB:%0d", expected_msb, expected_lsb, trans.stopWatch_MSB, trans.stopWatch_LSB);
//             end
//             ->gen_next_event;
//         end
//     endtask // run

//     function void update_reference_model(transaction trans);
//         // Reference model logic to update the expected state
//         case (ref_state)
//             STOP: begin
//                 if (trans.btn_Mode) begin
//                     if (trans.btn1_Tick) begin
//                         ref_state = START;
//                     end else if (trans.btn2_Tick) begin
//                         ref_state = CLEAR;
//                     end
//                 end
//             end
//             START: begin
//                 if (trans.btn_Mode && trans.btn1_Tick) begin
//                     ref_state = STOP;
//                 end
//                 if (trans.tick) begin
//                     if (ref_count_ms == 99) begin
//                         ref_count_ms = 0;
//                         if (ref_count_s == 59) begin
//                             ref_count_s = 0;
//                             if (ref_count_m == 59) begin
//                                 ref_count_m = 0;
//                                 if (ref_count_h == 23) begin
//                                     ref_count_h = 0;
//                                 end else begin
//                                     ref_count_h = ref_count_h + 1;
//                                 end
//                             end else begin
//                                 ref_count_m = ref_count_m + 1;
//                             end
//                         end else begin
//                             ref_count_s = ref_count_s + 1;
//                         end
//                     end else begin
//                         ref_count_ms = ref_count_ms + 1;
//                     end
//                 end
//             end
//             CLEAR: begin
//                 if (trans.btn_Mode) begin
//                     ref_count_ms = 0;
//                     ref_count_s = 0;
//                     ref_count_m = 0;
//                     ref_count_h = 0;
//                     ref_state = STOP;
//                 end
//             end
//         endcase
//     endfunction

//     function bit check_output(transaction trans);
//         // Expected values for MSB and LSB based on reference model
//         //int expected_msb, expected_lsb;
//         if (trans.sw_digit) begin
//             // If sw_digit is high, MSB should be minutes
//             expected_msb = ref_count_m;
//             // and LSB should be hours
//             expected_lsb = ref_count_h;
//         end else begin
//             // If sw_digit is low, MSB should be milliseconds
//             expected_msb = ref_count_ms;
//             // and LSB should be seconds
//             expected_lsb = ref_count_s;
//         end
//         // Compare DUT output with reference model
//         return (trans.stopWatch_MSB == expected_msb) && (trans.stopWatch_LSB == expected_lsb);
//     endfunction

//     task report();
//         $display("=============================");
//         $display("==        Final Report      ==");
//         $display("=============================");
//         $display("Total Transactions : %d", total_cnt);
//         $display("Pass Transactions  : %d", pass_cnt);
//         $display("Fail Transactions  : %d", fail_cnt);
//         $display("=============================");
//         $display("==      Testbench finished! ==");
//         $display("=============================");
//     endtask // report

// endclass // scoreboard

// class environment;
//     generator gen;
//     driver drv;
//     monitor mon;
//     scoreboard scb;
//     event gen_next_event;

//     mailbox #(transaction) gen2drv_mbox;
//     mailbox #(transaction) mon2scb_mbox;

//     function new(virtual stopWatch_if stopWatch_intf);
//         gen2drv_mbox = new();
//         mon2scb_mbox = new();
//         //gen_next_event = new();
//         gen = new(gen2drv_mbox, gen_next_event);
//         drv = new(stopWatch_intf, gen2drv_mbox);
//         mon = new(stopWatch_intf, mon2scb_mbox);
//         scb = new(mon2scb_mbox, gen_next_event);
//     endfunction // new()

//     task pre_run();
//         drv.reset();
//     endtask // pre_run

//     task run();
//         fork
//             gen.run(100);
//             drv.run();
//             mon.run();
//             scb.run();
//         join
//         scb.report();
//         #10 $finish;
//     endtask // run

//     task run_test();
//         pre_run();
//         run();
//     endtask // run_test

// endclass // environment

// module stopWatch_tb;
//     logic clk;
//     logic reset;
//     stopWatch_if stopWatch_intf();

//     environment env;

//     stopWatch dut (
//         .clk(stopWatch_intf.clk),
//         .reset(stopWatch_intf.reset),
//         .btn_Mode(stopWatch_intf.btn_Mode),
//         .btn1_Tick(stopWatch_intf.btn1_Tick),
//         .btn2_Tick(stopWatch_intf.btn2_Tick),
//         .stopWatch_MSB(stopWatch_intf.stopWatch_MSB),
//         .stopWatch_LSB(stopWatch_intf.stopWatch_LSB)
//     );

//     // Clock generation
//     always #5 clk = ~clk;

//     // Tick generation
//     logic [6:0] tick_counter;
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             tick_counter <= 0;
//             stopWatch_intf.tick <= 0;
//         end else begin
//             if (tick_counter == 99) begin
//                 tick_counter <= 0;
//                 stopWatch_intf.tick <= 1;
//             end else begin
//                 tick_counter <= tick_counter + 1;
//                 stopWatch_intf.tick <= 0;
//             end
//         end
//     end

//     initial begin
//         stopWatch_intf.clk = 0;
//         stopWatch_intf.reset = 1;
//         #20 stopWatch_intf.reset = 0;
//     end

//     initial begin
//         env = new(stopWatch_intf);
//         env.run_test();
//     end
// endmodule // stopWatch_tb











// `timescale 1ns / 1ps

// interface stopWatch_if();
//     logic clk;
//     logic reset;
//     logic btn_Mode;
//     logic btn1_Tick;
//     logic btn2_Tick;
//     logic sw_digit;
//     logic [6:0] stopWatch_MSB;
//     logic [6:0] stopWatch_LSB;
//     logic tick;
// endinterface // stopWatch_if

// class transaction;
//     rand logic btn_Mode;
//     rand logic btn1_Tick;
//     rand logic btn2_Tick;
//     rand logic sw_digit;
//     int stopWatch_MSB;
//     int stopWatch_LSB;
//     logic tick;

//     task display(string name);
//         $display("[%s] btn_Mode:%b, btn1_Tick:%b, btn2_Tick:%b, sw_digit:%b, stopWatch_MSB:%0d, stopWatch_LSB:%0d", name, btn_Mode, btn1_Tick, btn2_Tick, sw_digit, stopWatch_MSB, stopWatch_LSB);
//     endtask

//     constraint c_btn_Mode {btn_Mode dist {0:/1, 1:/99};}
//     // 5퍼 95퍼로 분배
//     constraint c_btn1_Tick {btn1_Tick dist {0:/50, 1:/50};}
//      // 50퍼 50퍼로 분배
//     constraint c_btn2_Tick {btn2_Tick dist {0:/99, 1:/1};}
//     // 98퍼 2퍼로 분배
//     constraint c_sw_digit {sw_digit dist {0:/50, 1:/50};}

// endclass // transaction

// class generator;
//     transaction trans;
//     mailbox #(transaction) gen2drv_mbox;
//     event gen_next_event;

//     function new(mailbox #(transaction) gen2drv_mbox, event gen_next_event);
//         this.gen2drv_mbox = gen2drv_mbox;
//         this.gen_next_event = gen_next_event;
//     endfunction // new()

//     task run(int count);
//         repeat (count) begin
//             trans = new();
//             assert (trans.randomize()) else $error("[GEN] trans.randomize() ERROR!");
//             gen2drv_mbox.put(trans);
//             trans.display("GEN");
//             @(gen_next_event); // Wait for event to generate next transaction
//         end
//     endtask // run
// endclass // generator

// class driver;
//     transaction trans;
//     mailbox #(transaction) gen2drv_mbox;
//     virtual stopWatch_if stopWatch_intf;

//     function new(virtual stopWatch_if stopWatch_intf, mailbox #(transaction) gen2drv_mbox);
//         this.stopWatch_intf = stopWatch_intf;
//         this.gen2drv_mbox = gen2drv_mbox;
//     endfunction // new()

//     task reset();
//         stopWatch_intf.btn_Mode <= 1'b0;
//         stopWatch_intf.btn1_Tick <= 1'b0;
//         stopWatch_intf.btn2_Tick <= 1'b0;
//         stopWatch_intf.sw_digit <= 1'b0;
//         stopWatch_intf.reset <= 1'b1;
//         repeat (5) @(posedge stopWatch_intf.clk);
//         // stopWatch_intf.reset <= 1'b0;
//     endtask // reset

//     task run();
//         forever begin
//             gen2drv_mbox.get(trans);
//             stopWatch_intf.btn_Mode <= trans.btn_Mode;
//             stopWatch_intf.btn1_Tick <= trans.btn1_Tick;
//             stopWatch_intf.btn2_Tick <= trans.btn2_Tick;
//             stopWatch_intf.sw_digit <= trans.sw_digit;
//             stopWatch_intf.tick <= trans.tick; // Ensure tick signal is correctly handled
//             trans.display("DRV");
//             @(posedge stopWatch_intf.clk);
//         end
//     endtask // run
// endclass // driver

// class monitor;
//     virtual stopWatch_if stopWatch_intf;
//     mailbox #(transaction) mon2scb_mbox;
//     transaction trans;

//     function new(virtual stopWatch_if stopWatch_intf, mailbox #(transaction) mon2scb_mbox);
//         this.stopWatch_intf = stopWatch_intf;
//         this.mon2scb_mbox = mon2scb_mbox;
//     endfunction // new()

//     task run();
//         forever begin
//             trans = new();
//             //#10;
//             @(posedge stopWatch_intf.clk);
//             trans.btn_Mode = stopWatch_intf.btn_Mode;
//             trans.btn1_Tick = stopWatch_intf.btn1_Tick;
//             trans.btn2_Tick = stopWatch_intf.btn2_Tick;
//             trans.sw_digit = stopWatch_intf.sw_digit;
//             #20;
//             trans.stopWatch_MSB = stopWatch_intf.stopWatch_MSB;
//             trans.stopWatch_LSB = stopWatch_intf.stopWatch_LSB;
//             trans.tick = stopWatch_intf.tick; // Capture the tick signal
//             trans.display("MON");
//             mon2scb_mbox.put(trans);
            
            
//         end
//     endtask // run
// endclass // monitor

// class scoreboard;
//     mailbox #(transaction) mon2scb_mbox;
//     transaction trans;
//     event gen_next_event;
//     int total_cnt;
//     int pass_cnt;
//     int fail_cnt;

//     // Reference model state
//     typedef enum logic [1:0] {STOP = 0, START = 1, CLEAR = 2} state_t;
//     state_t ref_state;
//     int ref_count_ms;
//     int ref_count_s;
//     int ref_count_m;
//     int ref_count_h;
//     int expected_msb, expected_lsb;

//     function new(mailbox #(transaction) mon2scb_mbox, event gen_next_event);
//         this.mon2scb_mbox = mon2scb_mbox;
//         this.gen_next_event = gen_next_event;
//         total_cnt = 0;
//         pass_cnt = 0;
//         fail_cnt = 0;
//         ref_state = STOP;
//         ref_count_ms = 0;
//         ref_count_s = 0;
//         ref_count_m = 0;
//         ref_count_h = 0;
//         expected_msb = 0;
//         expected_lsb = 0;
//     endfunction // new()

//     task run();
//         forever begin
//             mon2scb_mbox.get(trans);
//             trans.display("SCB");
//             total_cnt++;
//             // Update reference model based on transaction
//             update_reference_model(trans);
//             // Perform checks and compare with expected values
//             if (check_output(trans)) begin
//                 pass_cnt++;
//             end else begin
//                 fail_cnt++;
//                 $display("[FAIL] Output mismatch: expected MSB:%0d, LSB:%0d, got MSB:%0d, LSB:%0d", expected_msb, expected_lsb, trans.stopWatch_MSB, trans.stopWatch_LSB);
//             end
//             ->gen_next_event;
//         end
//     endtask // run

//     function void update_reference_model(transaction trans);
//         // Reference model logic to update the expected state
//         case (ref_state)
//             STOP: begin
//                 if (trans.btn_Mode) begin
//                     if (trans.btn1_Tick) begin
//                         ref_state = START;
//                     end else if (trans.btn2_Tick) begin
//                         ref_state = CLEAR;
//                     end
//                 end
//             end
//             START: begin
//                 if (trans.btn_Mode && trans.btn1_Tick) begin
//                     ref_state = STOP;
//                 end
//                 if (trans.tick) begin
//                     if (ref_count_ms == 99) begin
//                         ref_count_ms = 0;
//                         if (ref_count_s == 59) begin
//                             ref_count_s = 0;
//                             if (ref_count_m == 59) begin
//                                 ref_count_m = 0;
//                                 if (ref_count_h == 23) begin
//                                     ref_count_h = 0;
//                                 end else begin
//                                     ref_count_h = ref_count_h + 1;
//                                 end
//                             end else begin
//                                 ref_count_m = ref_count_m + 1;
//                             end
//                         end else begin
//                             ref_count_s = ref_count_s + 1;
//                         end
//                     end else begin
//                         ref_count_ms = ref_count_ms + 1;
//                     end
//                 end
//             end
//             CLEAR: begin
//                 if (trans.btn_Mode) begin
//                     ref_count_ms = 0;
//                     ref_count_s = 0;
//                     ref_count_m = 0;
//                     ref_count_h = 0;
//                     ref_state = STOP;
//                 end
//             end
//         endcase
//     endfunction

//     function bit check_output(transaction trans);
//         // Expected values for MSB and LSB based on reference model
//         if (trans.sw_digit) begin
//             // If sw_digit is high, MSB should be minutes
//             expected_msb = ref_count_m;
//             // and LSB should be hours
//             expected_lsb = ref_count_h;
//         end else begin
//             // If sw_digit is low, MSB should be milliseconds
//             expected_msb = ref_count_ms;
//             // and LSB should be seconds
//             expected_lsb = ref_count_s;
//         end
//         // Compare DUT output with reference model
//         return (trans.stopWatch_MSB == expected_msb) && (trans.stopWatch_LSB == expected_lsb);
//     endfunction

//     task report();
//         $display("=============================");
//         $display("==        Final Report      ==");
//         $display("=============================");
//         $display("Total Transactions : %d", total_cnt);
//         $display("Pass Transactions  : %d", pass_cnt);
//         $display("Fail Transactions  : %d", fail_cnt);
//         $display("=============================");
//         $display("==      Testbench finished! ==");
//         $display("=============================");
//     endtask // report

// endclass // scoreboard


// class environment;
//     generator gen;
//     driver drv;
//     monitor mon;
//     scoreboard scb;
//     event gen_next_event;

//     mailbox #(transaction) gen2drv_mbox;
//     mailbox #(transaction) mon2scb_mbox;

//     function new(virtual stopWatch_if stopWatch_intf);
//         gen2drv_mbox = new();
//         mon2scb_mbox = new();
//         //gen_next_event = new();
//         gen = new(gen2drv_mbox, gen_next_event);
//         drv = new(stopWatch_intf, gen2drv_mbox);
//         mon = new(stopWatch_intf, mon2scb_mbox);
//         scb = new(mon2scb_mbox, gen_next_event);
//     endfunction // new()

//     task report();
//         scb.report();
//     endtask // report

//     task pre_run();
//         drv.reset();
//     endtask // pre_run

//     task run();
//         fork
//             gen.run(100);
//             drv.run();
//             mon.run();
//             scb.run();
//         join_any
//         report();
//         #10 $finish;
//     endtask // run

//     task run_test();
//         pre_run();
//         run();
//     endtask // run_test

// endclass // environment


// module tb_stopWatch;
    
//     stopWatch_if stopWatch_intf();
//     environment env;


//     logic clk;
//     logic reset;

// // Clock generation
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end

//     // Tick generation
//     logic [6:0] tick_counter;
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             tick_counter <= 0;
//             stopWatch_intf.tick <= 0;
//         end else begin
//             if (tick_counter == 99) begin
//                 tick_counter <= 0;
//                 stopWatch_intf.tick <= 1;
//             end else begin
//                 tick_counter <= tick_counter + 1;
//                 stopWatch_intf.tick <= 0;
//             end
//         end
//     end

//     stopWatch dut (
//         .clk(stopWatch_intf.clk),
//         .reset(stopWatch_intf.reset),
//         .btn_Mode(stopWatch_intf.btn_Mode),
//         .btn1_Tick(stopWatch_intf.btn1_Tick),
//         .btn2_Tick(stopWatch_intf.btn2_Tick),
//         .sw_digit(stopWatch_intf.sw_digit),
//         .stopWatch_MSB(stopWatch_intf.stopWatch_MSB),
//         .stopWatch_LSB(stopWatch_intf.stopWatch_LSB)
//     );

//     always #5 stopWatch_intf.clk = ~stopWatch_intf.clk;

//     initial begin
//         stopWatch_intf.clk = 0;
//         // stopWatch_intf.reset = 1;
//         // #20 stopWatch_intf.reset = 0;
//     end

//     initial begin
//         env = new(stopWatch_intf);
//         env.run_test();
//     end
// endmodule // stopWatch_tb








`timescale 1ns / 1ps

interface stopWatch_if();
    logic clk;
    logic reset;
    logic btn_Mode;
    logic btn1_Tick;
    logic btn2_Tick;
    logic sw_digit;
    logic [6:0] stopWatch_MSB;
    logic [6:0] stopWatch_LSB;
endinterface // stopWatch_if

class transaction;
    rand logic btn_Mode;
    rand logic btn1_Tick;
    rand logic btn2_Tick;
    rand logic sw_digit;
    int stopWatch_MSB;
    int stopWatch_LSB;
    logic clk;

    task display(string name);
        $display("[%s], btn_Mode:%b, btn1_Tick:%b, btn2_Tick:%b, sw_digit:%b, stopWatch_MSB:%0d, stopWatch_LSB:%0d", 
        name, btn_Mode, btn1_Tick, btn2_Tick, sw_digit, stopWatch_MSB, stopWatch_LSB);
    endtask

    constraint c_btn_Mode {btn_Mode dist {0:/0, 1:/100};}
    constraint c_btn1_Tick {btn1_Tick dist {0:/10, 1:/90};}
    constraint c_btn2_Tick {btn2_Tick dist {0:/99, 1:/1};}
    constraint c_sw_digit {sw_digit dist {0:/50, 1:/50};}

endclass // transaction

class generator;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    event gen_next_event;

    function new(mailbox #(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction // new()

    task run(int count);
        repeat (count) begin
            trans = new();
            assert (trans.randomize()) else $error("[GEN] trans.randomize() ERROR!");
            gen2drv_mbox.put(trans);
            trans.display("GEN");
            @(gen_next_event); // Wait for event to generate next transaction
        end
    endtask // run
endclass // generator

class driver;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    virtual stopWatch_if stopWatch_intf;

    function new(virtual stopWatch_if stopWatch_intf, mailbox #(transaction) gen2drv_mbox);
        this.stopWatch_intf = stopWatch_intf;
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction // new()

    task reset();
        stopWatch_intf.reset <= 1'b1;
        stopWatch_intf.btn_Mode <= 0;
        stopWatch_intf.btn1_Tick <= 0;
        stopWatch_intf.btn2_Tick <= 0;
        stopWatch_intf.sw_digit <= 0;
        
        repeat (5) @(posedge stopWatch_intf.clk);
        stopWatch_intf.reset <= 1'b0;
    endtask // reset

    task run();
        forever begin
            gen2drv_mbox.get(trans);
            stopWatch_intf.btn_Mode <= trans.btn_Mode;
            stopWatch_intf.sw_digit <= trans.sw_digit;
            stopWatch_intf.btn1_Tick <= trans.btn1_Tick;
            stopWatch_intf.btn2_Tick <= trans.btn2_Tick;

            //stopWatch_intf.tick <= trans.tick; // Ensure tick signal is correctly handled
            trans.display("DRV");
            @(posedge stopWatch_intf.clk);
        end
    endtask // run
endclass // driver

class monitor;
    virtual stopWatch_if stopWatch_intf;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;

    function new(virtual stopWatch_if stopWatch_intf, mailbox #(transaction) mon2scb_mbox);
        this.stopWatch_intf = stopWatch_intf;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction // new()

    task run();
        forever begin
            trans = new();
            @(posedge stopWatch_intf.clk);
            trans.btn_Mode = stopWatch_intf.btn_Mode;
            trans.btn1_Tick = stopWatch_intf.btn1_Tick;
            trans.btn2_Tick = stopWatch_intf.btn2_Tick;
            trans.sw_digit = stopWatch_intf.sw_digit;
    
            trans.stopWatch_MSB = stopWatch_intf.stopWatch_MSB;
            trans.stopWatch_LSB = stopWatch_intf.stopWatch_LSB;
            
            //trans.tick = stopWatch_intf.tick;
            mon2scb_mbox.put(trans);
            trans.display("MON");
        end
    endtask // run
endclass // monitor

class scoreboard;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;
    event gen_next_event;
    int total_cnt;
    int pass_cnt;
    int fail_cnt;

    // Reference model state
    typedef enum logic [1:0] {STOP = 0, START = 1, CLEAR = 2} state_t;
    state_t ref_state;
    bit clk_making;
    int ref_count_ms;
    int ref_count_s;
    int ref_count_m;
    int ref_count_h;
    int expected_msb, expected_lsb;

    function new(mailbox #(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
        total_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;
        ref_state = STOP;
        ref_count_ms = 0;
        ref_count_s = 0;
        ref_count_m = 0;
        ref_count_h = 0;
        expected_msb = 0;
        expected_lsb = 0;
        clk_making = 0;
    endfunction // new()

    

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            trans.display("SCB");
            total_cnt++;
            // Update reference model based on transaction
            update_reference_model(trans);
            // Perform checks and compare with expected values
            if (check_output(trans)) begin
                pass_cnt++;
                $display("[PASS] Output match: expected MSB:%0d, LSB:%0d, got MSB:%0d, LSB:%0d", expected_msb, expected_lsb, trans.stopWatch_MSB, trans.stopWatch_LSB);
            end else begin
                fail_cnt++;
                $display("[FAIL] Output mismatch: expected MSB:%0d, LSB:%0d, got MSB:%0d, LSB:%0d", expected_msb, expected_lsb, trans.stopWatch_MSB, trans.stopWatch_LSB);
            end
            ->gen_next_event;
        end
    endtask // run

    function void update_reference_model(transaction trans);
        // Reference model logic to update the expected state
        case (ref_state)
            STOP: begin
                if (trans.btn_Mode) begin
                    if (trans.btn1_Tick) begin
                        ref_state = START;
                    end else if (trans.btn2_Tick) begin
                        ref_state = CLEAR;
                    end
                end
            end
            START: begin
                if (trans.btn_Mode && trans.btn1_Tick) begin
                    ref_state = STOP;
                end

                //clk making
                if(trans.clk) begin
                    clk_making = clk_making + 1;
                    if(clk_making == 2) begin
                        clk_making = 0;
                    end
                end

                if (trans.btn1_Tick) begin
                    if (ref_count_ms == 99) begin
                        ref_count_ms = 0;
                        if (ref_count_s == 59) begin
                            ref_count_s = 0;
                            if (ref_count_m == 59) begin
                                ref_count_m = 0;
                                if (ref_count_h == 23) begin
                                    ref_count_h = 0;
                                end else begin
                                    ref_count_h = ref_count_h + 1;
                                end
                            end else begin
                                ref_count_m = ref_count_m + 1;
                            end
                        end else begin
                            ref_count_s = ref_count_s + 1;
                        end
                    end else begin
                        ref_count_ms = ref_count_ms + 1;
                    end
                end
            end
            CLEAR: begin
                if (trans.btn_Mode) begin
                    ref_count_ms = 0;
                    ref_count_s = 0;
                    ref_count_m = 0;
                    ref_count_h = 0;
                    ref_state = STOP;
                end
            end
        endcase
    endfunction

    function bit check_output(transaction trans);
        // Expected values for MSB and LSB based on reference model
        if (trans.sw_digit) begin
            // If sw_digit is high, MSB should be minutes
            expected_msb = ref_count_m;
            // and LSB should be hours
            expected_lsb = ref_count_h;
        end else begin
            // If sw_digit is low, MSB should be milliseconds
            expected_msb = ref_count_ms;
            // and LSB should be seconds
            expected_lsb = ref_count_s;
        end
        // Compare DUT output with reference model
        return (trans.stopWatch_MSB == expected_msb) && (trans.stopWatch_LSB == expected_lsb);
    endfunction

    task report();
        $display("=============================");
        $display("==        Final Report      ==");
        $display("=============================");
        $display("Total Transactions : %d", total_cnt);
        $display("Pass Transactions  : %d", pass_cnt);
        $display("Fail Transactions  : %d", fail_cnt);
        $display("=============================");
        $display("==      Testbench finished! ==");
        $display("=============================");
    endtask // report

endclass // scoreboard


class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;
    virtual stopWatch_if stopWatch_intf;

    function new(virtual stopWatch_if stopWatch_intf);
        this.stopWatch_intf = stopWatch_intf;
        gen2drv_mbox = new();
        mon2scb_mbox = new();
        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(stopWatch_intf, gen2drv_mbox);
        mon = new(stopWatch_intf, mon2scb_mbox);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction // new()

    task pre_run();
        drv.reset();
    endtask // pre_run

    task run();
        fork
            gen.run(100);
            drv.run();
            mon.run();
            scb.run();
        join_any
        scb.report();
        #10 $finish;
    endtask // run

    task run_test();
        pre_run();
        run();
    endtask // run_test

endclass // environment


module tb_stopWatch();

    stopWatch_if stopWatch_intf();
    environment env;

    stopWatch dut (
        .clk(stopWatch_intf.clk),
        .reset(stopWatch_intf.reset),
        .btn_Mode(stopWatch_intf.btn_Mode),
        .btn1_Tick(stopWatch_intf.btn1_Tick),
        .btn2_Tick(stopWatch_intf.btn2_Tick),
        .sw_digit(stopWatch_intf.sw_digit),
        .stopWatch_MSB(stopWatch_intf.stopWatch_MSB),
        .stopWatch_LSB(stopWatch_intf.stopWatch_LSB)
    );

    
// Clock generation
    initial begin
        stopWatch_intf.clk = 0;
    end
    always #5 stopWatch_intf.clk = ~stopWatch_intf.clk;

    initial begin
        env = new(stopWatch_intf);
        env.run_test();
    end

endmodule // tb_stopWatch
