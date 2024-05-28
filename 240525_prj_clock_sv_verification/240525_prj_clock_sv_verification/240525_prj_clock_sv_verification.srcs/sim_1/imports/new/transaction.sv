

`ifndef __TRANSACTION_SV_
`define __TRANSACTION_SV_

class transaction;
    bit            selMode;
    // bit            sw_digit;
    rand bit       sw_digit;
    // bit       minSet;
    rand bit       minSet;
    // bit       secSet;
    rand bit       secSet;
    bit      [6:0] clock_MSB;
    bit      [6:0] clock_LSB;


    // constraint c_selMode {
    //     selMode dist {
    //         1 :/ 50,
    //         0 :/ 50
    //     };
    // }

    constraint c_sw_digit {
        sw_digit dist {
            1 :/ 50,
            0 :/ 50
        };
    }

    constraint c_minSet {
        minSet dist {
            1 :/ 10,
            0 :/ 90
        };
    }

    constraint c_secSet {
        secSet dist {
            1 :/ 10,
            0 :/ 90
        };
    }

    task display(string name);
        $display(
            "[%s] selMode: %d, sw_digit: %d, minSet: %d, secSet: %d, TIME %d:%d",  //, MSB: %d, LSB: %d
            name, selMode, sw_digit, minSet, secSet, clock_MSB, clock_LSB);
    endtask

endclass  //transaction

`endif


// `ifndef __TRANSACTION_SV_
// `define __TRANSACTION_SV_

// class transaction;
//     bit            clk;
//     bit            selMode;
//     // rand bit       selMode;
//     bit            sw_digit;
//     // rand bit       sw_digit;
//     // bit       MSBSet;
//     rand bit       MSBSet;
//     // bit       LSBSet;
//     rand bit       LSBSet;
//     bit      [6:0] clock_MSB;
//     bit      [6:0] clock_LSB;
//     bit      [6:0] clock_hour;
//     bit      [6:0] clock_min;
//     bit      [6:0] clock_sec;
//     bit      [6:0] clock_msec;

//     // constraint c_selMode {
//     //     selMode dist {
//     //         1 :/ 50,
//     //         0 :/ 50
//     //     };
//     // }

//     // constraint c_sw_digit {
//     //     sw_digit dist {
//     //         1 :/ 50,
//     //         0 :/ 50
//     //     };
//     // }

//     task display(string name);
//         $display(
//             "[%s] selMode: %d, sw_digit: %d, MSBSet: %d, LSBSet: %d, TIME %d:%d",  //, MSB: %d, LSB: %d
//             name, selMode, sw_digit, MSBSet, LSBSet, clock_MSB, clock_LSB);
//     endtask

// endclass  //transaction

// `endif
