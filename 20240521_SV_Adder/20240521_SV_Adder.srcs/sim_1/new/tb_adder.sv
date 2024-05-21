`timescale 1ns / 1ps

interface adder_intf;
    logic       clk;
    logic       reset;
    logic       valid;
    logic [3:0] a;
    logic [3:0] b;
    logic [3:0] sum;
    logic       carry;
endinterface  //adder_intf

class transaction;
    rand logic [3:0] a;
    rand logic [3:0] b;
    logic      [3:0] sum;
    logic            carry;
    // rand logic       valid;

    task display(string name);
        $display("[%s] a:%d, b:%d, carry:%d, sum:%d", name, a, b, carry, sum);
    endtask
endclass  //transaction

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event genNextEvent1;

    function new();
        tr = new();
    endfunction  //new()

    task run();
        repeat (1000) begin
            assert (tr.randomize())
            else $error("tr.randomize() error!");
            gen2drv_mbox.put(tr);
            tr.display("GEN");
            @(genNextEvent1);
        end
    endtask
endclass  //generator

class driver;
    virtual adder_intf adder_if1;
    mailbox #(transaction) gen2drv_mbox;
    transaction trans;
    // event genNextEvent2;
    event monNextEvent2;

    function new(virtual adder_intf adder_if2);
        this.adder_if1 = adder_if2;
    endfunction  //new()

    task reset();
        adder_if1.a     = 0;
        adder_if1.b     = 0;
        adder_if1.valid = 1'b0;
        adder_if1.reset = 1'b1;
        repeat (5) @(posedge adder_if1.clk);
        adder_if1.reset = 1'b0;
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(trans);  // blocking code. 값 대기
            adder_if1.a     = trans.a;
            adder_if1.b     = trans.b;
            adder_if1.valid = 1'b1;
            trans.display("DRV");
            @(posedge adder_if1.clk);
            adder_if1.valid = 1'b0;
            @(posedge adder_if1.clk);
            ->monNextEvent2;  // ->genNextEvent2;
        end
    endtask
endclass  //driver

class monitor;
    virtual adder_intf adder_if3;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;
    event monNextEvent1;

    function new(virtual adder_intf adder_if2);
        this.adder_if3 = adder_if2;
        trans          = new();
    endfunction  //new()

    task run();
        forever begin
            @(monNextEvent1);
            trans.a     = adder_if3.a;
            trans.b     = adder_if3.b;
            trans.sum   = adder_if3.sum;
            trans.carry = adder_if3.carry;
            mon2scb_mbox.put(trans);
            trans.display("MON");
        end
    endtask
endclass  //monitor

class scoreboard;
    transaction trans;
    mailbox #(transaction) mon2scb_mbox;
    event genNextEvent2;

    int total_cnt, pass_cnt, fail_cnt;

    function new();
        total_cnt = 0;
        pass_cnt  = 0;
        fail_cnt  = 0;
    endfunction  //new()

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            trans.display("SCB");
            if ((trans.a + trans.b) == {trans.carry, trans.sum}) begin      // (trans.a + trans.b) <- golden reference, reference model
                $display("  --> PASS ! %d + %d = %d", trans.a, trans.b, {
                         trans.carry, trans.sum});
                pass_cnt++;
            end else begin
                $display("  --> FAIL ! %d + %d = %d", trans.a, trans.b, {
                         trans.carry, trans.sum});
                fail_cnt++;
            end
            total_cnt++;
            ->genNextEvent2;
        end
    endtask
endclass  //scoreboard

module tb_adder ();
    adder_intf adder_interface ();  // interface 실체화
    generator gen;  // generator를 gen이라는 handler 생성
    driver drv;
    monitor mon;
    scoreboard scb;

    event genNextEvent;
    event monNextEvent;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    adder dut (
        .clk  (adder_interface.clk),
        .reset(adder_interface.reset),
        .valid(adder_interface.valid),
        .a    (adder_interface.a),
        .b    (adder_interface.b),
        .sum  (adder_interface.sum),
        .carry(adder_interface.carry)
    );

    always #5 adder_interface.clk = ~adder_interface.clk;

    initial begin
        adder_interface.clk   = 1'b0;
        adder_interface.reset = 1'b1;
    end

    initial begin
        gen2drv_mbox      = new();
        mon2scb_mbox      = new();

        gen               = new();
        drv               = new(adder_interface);
        mon               = new(adder_interface);
        scb               = new();

        gen.genNextEvent1 = genNextEvent;
        scb.genNextEvent2 = genNextEvent;
        mon.monNextEvent1 = monNextEvent;
        drv.monNextEvent2 = monNextEvent;

        gen.gen2drv_mbox  = gen2drv_mbox;
        drv.gen2drv_mbox  = gen2drv_mbox;
        mon.mon2scb_mbox  = mon2scb_mbox;
        scb.mon2scb_mbox  = mon2scb_mbox;

        drv.reset();

        fork
            drv.run();
            gen.run();  // generator 안의 run task 실행
            mon.run();
            scb.run();
        join_any

        $display("==============================");
        $display("==       Final Report       ==");
        $display("==============================");
        $display("Total Test : %d", scb.total_cnt);
        $display("Pass Count : %d", scb.pass_cnt);
        $display("Fail Count : %d", scb.fail_cnt);
        $display("==============================");
        $display("==  test bench is finished  ==");
        $display("==============================");
        #10 $finish;
    end
endmodule
