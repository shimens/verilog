`timescale 1ns / 1ps `timescale 1ns / 1ps

interface ram_interface;
    logic clk;
    logic wr_en;
    logic [9:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;
endinterface  //ram_interface

class transaction;
    rand bit       wr_en;
    rand bit [9:0] addr;
    rand bit [7:0] wdata;
    bit      [7:0] rdata;

    task display(string name);
        $display("[%s] wr_en: %x, addr: %x, wdata: %x, rdata: %x", name, wr_en,
                 addr, wdata, rdata);
    endtask

    // constraint c_adder {addr < 10;}  // 랜덤값에 제약주기
    constraint c_addr {addr inside {[10 : 19]};}
    constraint c_wdata1 {wdata < 100;}  // 10 < wdata < 100
    constraint c_wdata2 {
        wdata > 10;
    }  // c_어쩌고 는 이름이라 맘대로 정하면 됨
    // constraint c_wr_en {wr_en dist {0:=100, 1:=110};}    // dist 분배
    constraint c_wr_en {
        wr_en dist {
            0 :/ 60,
            1 :/ 40
        };
    }

endclass

class generator;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    event gen_next_event;  // gen을 NEXT할 수 있는 EVENT

    function new(mailbox#(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_event = gen_next_event; //여기 gen_next_event에 매개변수로 들어오는 gen_next_event를 연결시켜주겠다.
        //생성할 때 초기화한다는 이야기
    endfunction  //new()

    task run(int count);
        repeat (count) begin
            trans = new(); // repeat할때마다 객체 생성하고 transaction에 연결해주겠다.
            assert (trans.randomize())
            else $error("[GEN] trans.randomize() error!");
            gen2drv_mbox.put(
                trans);  // mail박스에 randomize된 trans값을 put하겠다.
            trans.display(
                "GEN"); //입력된 값을 trans의 display함수를 사용해서 출력하겠다
            @(gen_next_event);  // trigger 올 때 까지 대기
        end
    endtask  //run
endclass  //generator


class driver;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    virtual ram_interface ram_intf;



    function new(virtual ram_interface ram_intf,
                 mailbox#(transaction) gen2drv_mbox);
        this.ram_intf = ram_intf;  //this(이 클래스에 있는 멤버)
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction  //new()

    task reset();
        ram_intf.wr_en <= 1'b0;
        ram_intf.addr  <= 0;
        ram_intf.wdata <= 0;
        repeat (5) @(posedge ram_intf.clk);
    endtask  //reset

    task run();
        forever begin
            // @(posedge ram_intf.clk); // 다음 clk까지 기다리고
            gen2drv_mbox.get(
                trans); // mailbox에 생성된 첫번째 put은 get과 동시에 지워짐
            ram_intf.wr_en <= trans.wr_en;
            ram_intf.addr  <= trans.addr;
            ram_intf.wdata <= trans.wdata;
            // if (trans.wr_en) begin  // read
            //     ram_intf.wr_en <= trans.wr_en;
            //     ram_intf.addr  <= trans.addr;
            // end else begin
            //     ram_intf.wr_en <= trans.wr_en;
            //     ram_intf.addr  <= trans.addr;
            //     ram_intf.wdata <= trans.wdata;
            // end
            trans.display("DRV");
            @(posedge ram_intf.clk);  // 다음 clk까지 기다리고
        end
    endtask
endclass  //driver



class monitor;
    virtual ram_interface ram_intf;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;


    function new(virtual ram_interface ram_intf,
                 mailbox#(transaction) mon2scb_mbox);
        this.ram_intf = ram_intf;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction  //new()

    task run();
        forever begin
            trans       = new();
            trans.wr_en = ram_intf.wr_en;
            trans.addr  = ram_intf.addr;
            trans.wdata = ram_intf.wdata;
            trans.rdata = ram_intf.rdata;
            mon2scb_mbox.put(trans);
            trans.display("MON");
            @(posedge ram_intf.clk);
        end
    endtask
endclass  //monitor


class scoreboard;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;
    event gen_next_event;

    int total_cnt, pass_cnt, fail_cnt, write_cnt;
    logic [7:0] mem[0:2**10-1];

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;

        total_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;
        for (int i = 0; i < 2 ** 10; i++) begin
            mem[i] = 0;
        end
    endfunction  //new()

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            trans.display("SCB");
            if (trans.wr_en) begin  // read
                if (mem[trans.addr] == trans.rdata) begin
                    $display("--> READ PASS! mem[%x] == %x", trans.addr,
                             trans.rdata);
                    pass_cnt++;
                end else begin  // write
                    //mem[trans.addr] = trans.wdata; // SW적으로 만든 메모리 주소 안에 wdata 저장
                    $display("--> READ FAIL! %x != %x", trans.addr,
                             trans.rdata);
                    fail_cnt++;
                end
            end else begin
                mem[trans.addr] = trans.wdata;
                $display(" --> WRITE! mem[%x] = %x", trans.addr, trans.wdata);
                write_cnt++;
            end
            total_cnt++;
            ->gen_next_event;
        end
    endtask
endclass  //scoreboard

class environment;
    generator              gen;
    driver                 drv;
    monitor                mon;
    scoreboard             scb;

    event                  gen_next_event;



    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    function new(virtual ram_interface ram_intf);
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(ram_intf, gen2drv_mbox);
        mon = new(ram_intf, mon2scb_mbox);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction

    task report();
        $display("=======================================");
        $display("==            Final Report           ==");
        $display("=======================================");
        $display("Total Test   : %d", scb.total_cnt);
        $display("PASS Test : %d", scb.pass_cnt);
        $display("FAIL Test : %d", scb.fail_cnt);
        $display("WRITE CNT : %d", scb.write_cnt);
        $display("=======================================");
        $display("==      test bench is finished!      ==");
        $display("=======================================");
        #10 $finish;
    endtask

    task pre_run();
        drv.reset();
    endtask

    task run();
        fork
            gen.run(1000);  // 숫자는 count값
            drv.run();
            mon.run();
            scb.run();
        join_any
        report();
        #10 $finish;
    endtask

    task run_test();
        pre_run();
        run();
    endtask
endclass

module tb_ram ();

    environment env;
    ram_interface ram_intf ();

    ram dut (
        .clk  (ram_intf.clk),
        .addr (ram_intf.addr),
        .wdata(ram_intf.wdata),
        .wr_en(ram_intf.wr_en),
        .rdata(ram_intf.rdata)
    );

    always #5 ram_intf.clk = ~ram_intf.clk;

    initial begin
        ram_intf.clk = 0;
    end

    initial begin
        env = new(ram_intf);
        env.run_test();
    end

endmodule
