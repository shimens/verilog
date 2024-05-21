`timescale 1ns / 1ps

interface bit_reg_interface;
    logic        clk;
    logic        reset;
    logic        valid;
    logic [15:0] in;
    logic [15:0] out;
endinterface

class transaction;
    rand logic [15:0] in;
    logic [15:0] out;

    task display(string name);
        $display("[%s] : %d", name, in);
    endtask
endclass  //transaction

class generator;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    event genNextEvent;

    function new();
        trans = new();
    endfunction

    task run();
        repeat (10) begin
            assert (trans.randomize())
            else $error("trans.randomize() error");
            gen2drv_mbox.put(trans);
            trans.display("GEN");
            @(genNextEvent);
        end
    endtask
endclass  //generator

class driver;
    virtual bit_reg_interface br_interface;
    mailbox #(transaction) gen2drv_mbox;
    transaction trans;
    event monNextEvent;

    function new(virtual bit_reg_interface br_interface);
        this.br_interface = br_interface;
    endfunction  //new()

    task reset();
        br_interface.in = 0;
        br_interface.valid = 1'b0;
        br_interface.reset = 1'b1;
        repeat (5) @(posedge br_interface.clk);
        br_interface.reset = 1'b0;
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(trans);
            br_interface.in = trans.in;
            br_interface.valid = 1'b1;
            trans.display("DRV");
            @(posedge br_interface.clk);
            br_interface.valid = 1'b0;
            @(posedge br_interface.clk);
            ->monNextEvent;
        end
    endtask
endclass  //driver

class monitor;
    virtual bit_reg_interface br_interface;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;
    event monNextEvent;

    function new(virtual bit_reg_interface br_interface);
        this.br_interface = br_interface;
        trans = new();
    endfunction  //new()

    task run();
        forever begin
            @(monNextEvent);
            trans.in  = br_interface.in;
            trans.out = br_interface.out;
            mon2scb_mbox.put(trans);
            trans.display("MON");
        end
    endtask
endclass  //monitor

class scoreboard;
    transaction trans;
    mailbox #(transaction) mon2scb_mbox;
    event genNextEvent;

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            trans.display("SCB");
            ->genNextEvent;
        end
    endtask
endclass  //scoreboard

module tb_bit_register ();
    bit_reg_interface bitreg_interface ();
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    event genNextEvent;
    event monNextEvent;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    bit_register_16 dut (
        .clk(bitreg_interface.clk),
        .reset(bitreg_interface.reset),
        .valid(bitreg_interface.valid),
        .in(bitreg_interface.in),
        .out(bitreg_interface.out)
    );

    always #5 bitreg_interface.clk = ~bitreg_interface.clk;

    initial begin
        bitreg_interface.clk   = 1'b0;
        bitreg_interface.reset = 1'b1;
    end

    initial begin
        gen2drv_mbox     = new();
        mon2scb_mbox     = new();

        gen              = new();
        drv              = new(bitreg_interface);
        mon              = new(bitreg_interface);
        scb              = new();

        gen.genNextEvent = genNextEvent;
        scb.genNextEvent = genNextEvent;
        mon.monNextEvent = monNextEvent;
        drv.monNextEvent = monNextEvent;

        gen.gen2drv_mbox = gen2drv_mbox;
        drv.gen2drv_mbox = gen2drv_mbox;
        mon.mon2scb_mbox = mon2scb_mbox;
        scb.mon2scb_mbox = mon2scb_mbox;

        drv.reset();

        fork
            drv.run();
            gen.run();
            mon.run();
            scb.run();
        join_any

        $display("==============================");
        $display("==  test bench is finished  ==");
        $display("==============================");
        #10 $finish;
    end
endmodule
