
`ifndef __TRANSACTION_SV_
`define __TRANSACTION_SV_

class transaction;
    rand bit       wr_en;
    bit            full;
    rand bit [7:0] wdata;
    rand bit       rd_en;
    bit            empty;
    bit      [7:0] rdata;

    constraint c_oper {wr_en != rd_en;}
    constraint c_wr_en {
        wr_en dist {
            1 :/ 50,
            0 :/ 50
        };
    }

    task display(string name);
        $display(
            "[%s] wr_en:%d, wdata:%d, full:%d || rd_en:%d, rdata:%d, empty:%d",
            name, wr_en, wdata, full, rd_en, rdata, empty);
    endtask
endclass  //transaction

`endif 