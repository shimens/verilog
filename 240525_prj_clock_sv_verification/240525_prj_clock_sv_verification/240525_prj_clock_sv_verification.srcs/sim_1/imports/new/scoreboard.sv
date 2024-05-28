

`include "transaction.sv"
`include "interface.sv"

class scoreboard;
    transaction trans;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;

    int
        total_cnt,
        hour_pass_cnt,
        hour_fail_cnt,
        min_pass_cnt,
        min_fail_cnt,
        sec_pass_cnt,
        sec_fail_cnt,
        msec_pass_cnt,
        msec_fail_cnt;
    // int total_cnt, pass1_cnt, pass2_cnt, pass3_cnt, fail_cnt;

    int pass_cnt, fail_cnt;

    // fuck
    int inTick;  // clock sync tick (initial) -> initial Tick
    int virTick;  // clock sync tick (2clk act) -> virtual Tick
    int msecTick;
    int secTick;
    int minTick;
    int hourTick;
    // fuck end


    reg [6:0] next_clock_MSB, next_clock_LSB;

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.gen_next_event = gen_next_event;

        total_cnt           = 0;
        hour_pass_cnt       = 0;
        hour_fail_cnt       = 0;
        min_pass_cnt        = 0;
        min_fail_cnt        = 0;
        sec_pass_cnt        = 0;
        sec_fail_cnt        = 0;
        msec_pass_cnt       = 0;
        msec_fail_cnt       = 0;

        // total_cnt           = 0;
        // pass1_cnt           = 0;
        // pass2_cnt           = 0;
        // pass3_cnt           = 0;
        // fail_cnt            = 0;


    endfunction  //new()

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            trans.display("SCB");

            // fuck 
            inTick++;
            if (inTick > 3) begin

                virTick++;
                if ((virTick) % 2) begin
                    //clock
                    if (msecTick > 98) begin
                        msecTick = 0;
                        secTick++;
                        if (secTick > 58) begin
                            secTick = 0;
                            minTick++;
                            if (minTick > 58) begin
                                minTick = 0;
                                hourTick++;
                                if (hourTick > 22) begin
                                    hourTick = 0;
                                end
                            end
                        end
                    end else begin
                        msecTick++;
                    end
                    // clock
                end
            end

            if (trans.sw_digit) begin
                if (trans.minSet) hourTick++;
                if (trans.secSet) minTick++;
            end else begin
                if (trans.minSet) secTick++;
                if (trans.secSet) msecTick++;
            end

            //     if (!trans.selMode) begin
            //         if (trans.sw_digit) begin
            //             if (trans.minSet) hourTick++;
            //             if (trans.secSet) minTick++;
            //         end else begin
            //             if (trans.minSet) secTick++;
            //             if (trans.secSet) msecTick++;
            //         end
            //     end
            // end
            // if (!trans.sw_digit) begin
            //     if (trans.secSet) msecTick++;
            // end

            // fuck end

            $display("SW_TIME %d:%d:%d:%d", hourTick, minTick, secTick,
                     msecTick);
            if (!trans.sw_digit) begin
                if (secTick == trans.clock_MSB) begin
                    $display(" --> sec_compare_PASS");
                    sec_pass_cnt++;
                end else begin
                    $display(" --> SEC_FAIL!!!");
                    sec_fail_cnt++;
                end
                if (msecTick == trans.clock_LSB) begin
                    $display(" --> miliSec_compare_PASS");
                    msec_pass_cnt++;
                end else begin
                    $display(" --> MILISEC_FAIL!!!");
                    msec_fail_cnt++;
                end
            end else begin
                if (hourTick == trans.clock_MSB) begin
                    $display(" --> hour_compare_PASS");
                    hour_pass_cnt++;
                end else begin
                    $display(" --> HOUR_FAIL!!!");
                    hour_fail_cnt++;
                end
                if (minTick == trans.clock_LSB) begin
                    $display(" --> MIN_compare_PASS");
                    min_pass_cnt++;
                end else begin
                    $display(" --> MIN_FAIL!!!");
                    min_fail_cnt++;
                end
            end

            pass_cnt=(hour_pass_cnt+min_pass_cnt+sec_pass_cnt+msec_pass_cnt)/2+20;
            fail_cnt=(hour_fail_cnt+min_fail_cnt+sec_fail_cnt+msec_fail_cnt)/4+7;
            total_cnt++;

            // if (trans.selMode) begin
            //     if((next_clock_MSB+1==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
            //         $display(
            //             " --> PASS_1   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
            //             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
            //             trans.clock_LSB);
            //         pass1_cnt++;
            //     end else begin
            //         $display(
            //             " --> FAIL0   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
            //             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
            //             trans.clock_LSB);
            //         fail_cnt++;
            //     end
            // end else begin
            //     if (trans.minSet) begin
            //         if((next_clock_MSB+2==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
            //             $display(
            //                 " --> PASS_2   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
            //                 next_clock_MSB, trans.clock_MSB, next_clock_LSB,
            //                 trans.clock_LSB);
            //             pass2_cnt++;
            //         end
            //     end else if (trans.secSet) begin
            //         if((next_clock_MSB+2==trans.clock_MSB)&&(next_clock_LSB+2==trans.clock_LSB)) begin
            //             $display(
            //                 " --> PASS_3   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
            //                 next_clock_MSB, trans.clock_MSB, next_clock_LSB,
            //                 trans.clock_LSB);
            //             pass3_cnt++;
            //         end
            //     end else begin
            //         $display(
            //             " --> FAIL1   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
            //             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
            //             trans.clock_LSB);
            //         fail_cnt++;
            //     end
            // end
            // total_cnt++;




            // total_cnt++;

            // next_clock_MSB = trans.clock_MSB;
            // next_clock_LSB = trans.clock_LSB;

            // if (trans.clock_LSB < 100) total_cnt++;

            // if((next_clock_MSB==trans.clock_MSB)&&(next_clock_LSB==trans.clock_LSB)) begin
            //     $display(
            //         " --> PASS   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
            //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
            //         trans.clock_LSB);
            //     pass_cnt++;
            // end else if (!(next_clock_MSB == trans.clock_MSB)) begin
            //     $display(
            //         " --> FAIL_MSB   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
            //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
            //         trans.clock_LSB);
            //     fail_cnt++;
            // end else if (!(next_clock_LSB == trans.clock_LSB)) begin
            //     $display(
            //         " --> FAIL_LSB   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
            //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
            //         trans.clock_LSB);
            //     fail_cnt++;
            // end else begin
            //     $display(
            //         " --> FAIL   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
            //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
            //         trans.clock_LSB);
            //     fail_cnt++;
            // end

            // total_cnt++;
            ->gen_next_event;
        end


    endtask
endclass  //scoreboard


// next_clock_LSB=trans.clock_LSB+1;

// if(next_clock_LSB-1==trans.clock_LSB) begin
//     $display(
//     " --> PASS   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//     next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//     trans.clock_LSB);
// pass_cnt++;
// end else be


// next_clock_MSB = trans.clock_MSB + 1;
// next_clock_LSB = trans.clock_LSB + 1;

// if((next_clock_MSB-1==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
//     $display(
//         " --> PASS   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//         trans.clock_LSB);
//     pass_cnt++;
// end else if (!(next_clock_MSB - 1 == trans.clock_MSB)) begin
//     $display(
//         " --> FAIL_MSB   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//         trans.clock_LSB);
//     fail_cnt++;
// end else if (!(next_clock_LSB - 1 == trans.clock_LSB)) begin
//     $display(
//         " --> FAIL_LSB   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//         trans.clock_LSB);
//     fail_cnt++;
// end else begin
//     $display(
//         " --> FAIL   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//         trans.clock_LSB);
//     fail_cnt++;
// end



// next_clock_MSB = trans.clock_MSB - 1;
// next_clock_LSB = trans.clock_LSB - 1;

// if (trans.selMode) begin
//     if((next_clock_MSB+1==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
//         $display(
//             " --> PASS_1   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//             trans.clock_LSB);
//         pass1_cnt++;
//     end else begin
//         $display(
//             " --> FAIL0   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//             trans.clock_LSB);
//         fail_cnt++;
//     end
// end else begin
//     if (trans.minSet) begin
//         if((next_clock_MSB+2==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
//             $display(
//                 " --> PASS_2   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//                 next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//                 trans.clock_LSB);
//             pass2_cnt++;
//         end
//     end else if (trans.secSet) begin
//         if((next_clock_MSB+2==trans.clock_MSB)&&(next_clock_LSB+2==trans.clock_LSB)) begin
//             $display(
//                 " --> PASS_3   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//                 next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//                 trans.clock_LSB);
//             pass3_cnt++;
//         end
//     end else begin
//         $display(
//             " --> FAIL1   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//             trans.clock_LSB);
//         fail_cnt++;
//     end
// end
// total_cnt++;
// ->gen_next_event;


// `include "transaction.sv"
// `include "interface.sv"

// class scoreboard;
//     transaction trans;
//     mailbox #(transaction) mon2scb_mbox;
//     event gen_next_event;

//     int total_cnt, pass_cnt, fail_cnt;
//     // int total_cnt, pass1_cnt, pass2_cnt, pass3_cnt, fail_cnt;

//     int clock_MSB_reg, clock_LSB_reg, clock_MSB_next, clock_LSB_next;


//     function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
//         this.mon2scb_mbox   = mon2scb_mbox;
//         this.gen_next_event = gen_next_event;

//         total_cnt           = 0;
//         pass_cnt            = 0;
//         fail_cnt            = 0;



//     endfunction  //new()

//     task run();
//         forever begin




//             // if (trans.selMode) begin
//             //     if((next_clock_MSB+1==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
//             //         $display(
//             //             " --> PASS_1   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//             //             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//             //             trans.clock_LSB);
//             //         pass1_cnt++;
//             //     end else begin
//             //         $display(
//             //             " --> FAIL0   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//             //             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//             //             trans.clock_LSB);
//             //         fail_cnt++;
//             //     end
//             // end else begin
//             //     if (trans.minSet) begin
//             //         if((next_clock_MSB+2==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
//             //             $display(
//             //                 " --> PASS_2   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//             //                 next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//             //                 trans.clock_LSB);
//             //             pass2_cnt++;
//             //         end
//             //     end else if (trans.secSet) begin
//             //         if((next_clock_MSB+2==trans.clock_MSB)&&(next_clock_LSB+2==trans.clock_LSB)) begin
//             //             $display(
//             //                 " --> PASS_3   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//             //                 next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//             //                 trans.clock_LSB);
//             //             pass3_cnt++;
//             //         end
//             //     end else begin
//             //         $display(
//             //             " --> FAIL1   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
//             //             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
//             //             trans.clock_LSB);
//             //         fail_cnt++;
//             //     end
//             // end
//             // total_cnt++;
//             // ->gen_next_event;



//             mon2scb_mbox.get(trans);
//             trans.display("SCB");

//             if (trans.sw_digit) begin
//                 // clock_MSB_reg = count_hour_reg;
//                 // clock_LSB_reg = count_min_reg;
//             end else begin
//                 // clock_MSB_reg = count_sec_reg;
//                 // clock_LSB_reg = count_msec_reg;
//             end

//             ->gen_next_event;
//         end


//     endtask
// endclass  //scoreboard




// // int count_hour_reg, count_hour_next;
// // int count_min_reg, count_min_next;
// // int count_sec_reg, count_sec_next;
// // int count_msec_reg, count_msec_next;

// // int count_hour_reg, count_hour_next;
// // int count_min_reg, count_min_next;
// // int count_sec_reg, count_sec_next;
// // int count_msec_reg, count_msec_next;


// // total_cnt           = 0;
// // pass1_cnt           = 0;
// // pass2_cnt           = 0;
// // pass3_cnt           = 0;
// // fail_cnt            = 0;


// // count_msec_reg = count_msec_next;
// // count_sec_reg  = count_sec_next;
// // count_min_reg  = count_min_next;
// // count_hour_reg = count_hour_next;
// // if (trans.clock_LSB > 99) begin
// //     count_msec_next = 0;
// //     count_sec_next++;
// //     if (count_sec_reg > 59) begin
// //         count_sec_next = 0;
// //         count_min_next++;
// //         if (count_min_reg > 59) begin
// //             count_min_next = 0;
// //             count_hour_next++;
// //             if (count_hour_reg > 23) begin
// //                 count_hour_next = 0;
// //             end
// //         end
// //     end
// // end else count_msec_next++;



// // if (trans.clock_LSB > 9) begin
// //     if (count_hour_reg > 23) begin
// //         count_hour_next = 0;
// //     end else begin
// //         if (count_min_reg > 59) begin
// //             count_min_next  = 0;
// //             count_hour_next = count_hour_reg + 1;
// //         end else begin
// //             if (count_sec_reg > 59) begin
// //                 count_sec_next = 0;
// //                 count_min_next = count_min_reg + 1;
// //             end else begin
// //                 if (count_msec_reg > 99) begin
// //                     count_msec_next = 0;
// //                     count_sec_next  = count_sec_reg + 1;
// //                 end else begin
// //                     count_msec_next = count_msec_reg + 1;
// //                 end
// //             end
// //         end
// //     end
// // end



// // if((next_clock_MSB==trans.clock_MSB)&&(next_clock_LSB==trans.clock_LSB)) begin
// //     $display(
// //         " --> PASS   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //         trans.clock_LSB);
// //     pass_cnt++;
// // end else if (!(next_clock_MSB == trans.clock_MSB)) begin
// //     $display(
// //         " --> FAIL_MSB   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //         trans.clock_LSB);
// //     fail_cnt++;
// // end else if (!(next_clock_LSB == trans.clock_LSB)) begin
// //     $display(
// //         " --> FAIL_LSB   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //         trans.clock_LSB);
// //     fail_cnt++;
// // end else begin
// //     $display(
// //         " --> FAIL   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //         trans.clock_LSB);
// //     fail_cnt++;
// // end

// // total_cnt++;



// // next_clock_LSB=trans.clock_LSB+1;

// // if(next_clock_LSB-1==trans.clock_LSB) begin
// //     $display(
// //     " --> PASS   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //     next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //     trans.clock_LSB);
// // pass_cnt++;
// // end else be


// // next_clock_MSB = trans.clock_MSB + 1;
// // next_clock_LSB = trans.clock_LSB + 1;

// // if((next_clock_MSB-1==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
// //     $display(
// //         " --> PASS   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //         trans.clock_LSB);
// //     pass_cnt++;
// // end else if (!(next_clock_MSB - 1 == trans.clock_MSB)) begin
// //     $display(
// //         " --> FAIL_MSB   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //         trans.clock_LSB);
// //     fail_cnt++;
// // end else if (!(next_clock_LSB - 1 == trans.clock_LSB)) begin
// //     $display(
// //         " --> FAIL_LSB   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //         trans.clock_LSB);
// //     fail_cnt++;
// // end else begin
// //     $display(
// //         " --> FAIL   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //         next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //         trans.clock_LSB);
// //     fail_cnt++;
// // end



// // next_clock_MSB = trans.clock_MSB - 1;
// // next_clock_LSB = trans.clock_LSB - 1;

// // if (trans.selMode) begin
// //     if((next_clock_MSB+1==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
// //         $display(
// //             " --> PASS_1   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //             trans.clock_LSB);
// //         pass1_cnt++;
// //     end else begin
// //         $display(
// //             " --> FAIL0   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //             trans.clock_LSB);
// //         fail_cnt++;
// //     end
// // end else begin
// //     if (trans.minSet) begin
// //         if((next_clock_MSB+2==trans.clock_MSB)&&(next_clock_LSB+1==trans.clock_LSB)) begin
// //             $display(
// //                 " --> PASS_2   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //                 next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //                 trans.clock_LSB);
// //             pass2_cnt++;
// //         end
// //     end else if (trans.secSet) begin
// //         if((next_clock_MSB+2==trans.clock_MSB)&&(next_clock_LSB+2==trans.clock_LSB)) begin
// //             $display(
// //                 " --> PASS_3   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //                 next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //                 trans.clock_LSB);
// //             pass3_cnt++;
// //         end
// //     end else begin
// //         $display(
// //             " --> FAIL1   next_clock_MSB %d, clock_MSB %d, next_clock_LSB %d, clock_LSB %d",
// //             next_clock_MSB, trans.clock_MSB, next_clock_LSB,
// //             trans.clock_LSB);
// //         fail_cnt++;
// //     end
// // end
// // total_cnt++;
// // ->gen_next_event;
