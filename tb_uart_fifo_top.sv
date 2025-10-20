`timescale 1ns / 1ps

interface uart_interface;

    logic       clk;
    logic       rst;
    logic       rx;
    logic       tx;
    logic [7:0] rx_data;
    logic       cmd_start;
    logic [7:0] internal_rx_data;
    logic [7:0] o_rx_data;

endinterface

class transaction;
    rand bit [7:0] uart_send_data;
    bit [7:0] uart_re_data;
    bit rx;
    bit tx;

endclass



class generator;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    event gen_next_event;

    function new(mailbox#(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox   = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int run_count);
        repeat (run_count) begin
            trans = new();
            assert (trans.randomize())
            else $error("[GEN] tr.randomize() error");
            gen2drv_mbox.put(trans);
            $display("[GENERATOR]");
            $display("Rx Expect Data = %h", trans.uart_send_data);
            @gen_next_event;
        end
    endtask

endclass



class driver;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) drv2mon_mbox;
    virtual uart_interface uart_fifo_if;
    event mon_next_event;
    parameter CLOCK_PERIOD_NS = 10;
    parameter BITPERCLOCK = 10416;  // 100_000_000/9600
    parameter BIT_PERIOD = BITPERCLOCK * CLOCK_PERIOD_NS;

    function new(mailbox#(transaction) gen2drv_mbox,
                 virtual uart_interface uart_fifo_if, event mon_next_event,
                 mailbox#(transaction) drv2mon_mbox);
        this.gen2drv_mbox   = gen2drv_mbox;
        this.uart_fifo_if   = uart_fifo_if;
        this.mon_next_event = mon_next_event;
        this.drv2mon_mbox   = drv2mon_mbox;
    endfunction

    task reset();
        uart_fifo_if.clk = 0;
        uart_fifo_if.rst = 1;
        uart_fifo_if.rx  = 1;
        uart_fifo_if.tx  = 1;
        @(posedge uart_fifo_if.clk);
        uart_fifo_if.rst = 0;
        @(posedge uart_fifo_if.clk);
        $display("[DRIVER] reset");
    endtask

    task send_data(bit [7:0] uart_send_data);
        uart_fifo_if.rx = 0;
        #(BIT_PERIOD);
        for (int i = 0; i < 8; i = i + 1) begin
            uart_fifo_if.rx = trans.uart_send_data[i];
            #(BIT_PERIOD);
            //$display("time %t ", $time);
        end
        uart_fifo_if.rx = 1;
        // @(negedge uart_fifo_if.cmd_start) 
        @(negedge uart_fifo_if.cmd_start);
        uart_fifo_if.o_rx_data = uart_fifo_if.rx_data;
        #(BIT_PERIOD / 2);
    endtask

    task run();
        forever begin
            #1;
            gen2drv_mbox.get(trans);
            @(posedge uart_fifo_if.clk);
            send_data(trans.uart_send_data);
            drv2mon_mbox.put(trans);
            $display("[DRIVER]");
            // $display("Rx Receive Data = %h", trans.uart_send_data);
            // if (trans.uart_send_data == uart_fifo_if.internal_rx_data) begin
            //     $display("[PASS RX SUCCESS] UART RX data MATCHED! (Value: %h)", trans.uart_send_data);
            // end else begin
            //     $display("[FAIL] UART RX data MISMATCH!");
            //     $display("  -  EXPECTED : %h",trans.uart_send_data);
            //     $display("  -  RECEIVED : %h",uart_fifo_if.internal_rx_data);
            // end
            //trans.display2("[DRV]");
            // ->mon_next_event;
        end
    endtask
endclass


class monitor;
    transaction trans;
    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) drv2mon_mbox;
    virtual uart_interface uart_fifo_if;
    event mon_next_event;

    parameter CLOCK_PERIOD_NS = 10;
    parameter BITPERCLOCK = 10416;
    parameter BIT_PERIOD = BITPERCLOCK * CLOCK_PERIOD_NS;

    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual uart_interface uart_fifo_if, event mon_next_event,
                 mailbox#(transaction) drv2mon_mbox);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.uart_fifo_if   = uart_fifo_if;
        this.mon_next_event = mon_next_event;
        this.drv2mon_mbox   = drv2mon_mbox;
    endfunction

    task run();
        localparam bit VERBOSE_DEBUG = 1;
        forever begin
            // @(mon_next_event);
            drv2mon_mbox.get(trans);
            // driver에서 생성한 random값이 interface를 거쳐 dut로 들어감
            // dut에서 나온 값을 생성해서 넣어줬던 random값과 비교해서 맞는지 확인
            $display("Rx Receive Data = %h", trans.uart_send_data);
            if (trans.uart_send_data == uart_fifo_if.internal_rx_data) begin
                $display("[PASS RX SUCCESS] UART RX data MATCHED! (Value: %h)",
                         trans.uart_send_data);
            end else begin
                $display("[FAIL] UART RX data MISMATCH!");
                $display("  -  EXPECTED : %h", trans.uart_send_data);
                $display("  -  RECEIVED : %h", uart_fifo_if.internal_rx_data);
            end
            wait (uart_fifo_if.tx == 0);
            #(BIT_PERIOD);
            for (int i = 0; i < 8; i = i + 1) begin
                trans.uart_re_data[i] = uart_fifo_if.tx;
                #(BIT_PERIOD);
            end
            #(BIT_PERIOD);

            if (VERBOSE_DEBUG) begin
                $display("[MONITOR]");
                //monitor
                if (uart_fifo_if.internal_rx_data == uart_fifo_if.o_rx_data)begin
                    $display(
                        "[Rx FIFO - Tx FIFO SUCCESS] FIFO Rx in Data : %h = FIFO Tx out Data : %h",
                        uart_fifo_if.internal_rx_data, uart_fifo_if.o_rx_data);
                end
                $display(
                    "+--------------------------------------------------+");
                $display("| Bit Indx | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | (LSB)");
                $display(
                    "| Value    | %1b | %1b | %1b | %1b | %1b | %1b | %1b | %1b |",
                    trans.uart_re_data[7], trans.uart_re_data[6],
                    trans.uart_re_data[5], trans.uart_re_data[4],
                    trans.uart_re_data[3], trans.uart_re_data[2],
                    trans.uart_re_data[1], trans.uart_re_data[0]);
                $display("| Received Tx Data : 0x%h                     |",
                         trans.uart_re_data);
                if (uart_fifo_if.o_rx_data == trans.uart_re_data) begin
                    $display(
                        "[PASS Tx SUCCESS] UART TX data MATCHED! (Value: 0x%h)",
                        trans.uart_re_data);
                end else begin
                    $display("[FAIL] UART TX data MISMATCH!");
                    $display("  -  EXPECTED : %h", uart_fifo_if.o_rx_data);
                    $display("  -  RECEIVED : %h", trans.uart_re_data);
                end
                $display(
                    "+--------------------------------------------------+");
            end

            @(posedge uart_fifo_if.clk);
            mon2scb_mbox.put(trans);
        end
    endtask


endclass


class scoreboard;
    transaction trans;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_event;

    int success_count;
    int fail_count;

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox   = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            //trans.display("[SCB]");
            if (trans.uart_send_data == trans.uart_re_data) begin
                $display("[SCOREBOARD]");
                $display("| UART transaction verified successfully.");
                $display("| - SENT DATA     : 0x%h", trans.uart_send_data);
                $display("| - RECEIVED DATA : 0x%h", trans.uart_re_data);
                success_count = success_count + 1;
            end else begin
                $display("error!!!!!!!!!!!!!");
                fail_count = fail_count + 1;
            end
            ->gen_next_event;
        end
    endtask

    // task report();
    //     $display("=================================");
    //     $display("success_count : %d", success_count);
    //     $display("fail_count : %d", fail_count);
    //     $display("=================================");

    // endtask

    task report();
        int  total_count = success_count + fail_count;
        real pass_rate = 0.0;

        if (total_count > 0) begin
            pass_rate = (success_count * 100.0) / total_count;
        end

        $display("================================================");
        $display("             TEST SUMMARY REPORT             ");
        $display("   Total Transactions Run : %0d", total_count);
        $display("   Transactions Passed    : %0d", success_count);
        $display("   Transactions Failed    : %0d", fail_count);
        $display("   Pass Rate              : %0.2f %%", pass_rate);

        if (fail_count == 0 && total_count > 0) begin
            $display("   OVERALL STATUS         : ALL PASSED          ");
        end else if (total_count == 0) begin
            $display("   OVERALL STATUS         : NO TESTS RUN        ");
        end else begin
            $display("   OVERALL STATUS         : FAILURES DETECTED   ");
        end
        $display("================================================");
    endtask

endclass



class environment;
    transaction            trans;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) drv2mon_mbox;
    event                  gen_next_event;
    event                  mon_next_event;
    generator              gen;
    driver                 drv;
    monitor                mon;
    scoreboard             scb;

    function new(virtual uart_interface uart_fifo_if);
        gen2drv_mbox = new();
        mon2scb_mbox = new();
        drv2mon_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, uart_fifo_if, mon_next_event, drv2mon_mbox);
        mon = new(mon2scb_mbox, uart_fifo_if, mon_next_event, drv2mon_mbox);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction


    task reset();
        drv.reset();
    endtask

    task run();
        fork
            gen.run(10);
            drv.run();
            mon.run();
            scb.run();
        join_any
        #10;
        scb.report();
        $display("finished");
        $stop;
    endtask
endclass




module tb_uart ();

    uart_interface uart_interface_tb ();
    environment env;

    uart_top dut (
        .clk(uart_interface_tb.clk),
        .rst(uart_interface_tb.rst),
        .rx(uart_interface_tb.rx),
        .tx(uart_interface_tb.tx),
        .rx_data(uart_interface_tb.rx_data),
        .cmd_start(uart_interface_tb.cmd_start)
    );

    assign uart_interface_tb.internal_rx_data = dut.U_UART_RX.rx_data;

    always #5 uart_interface_tb.clk = ~uart_interface_tb.clk;

    initial begin
        env = new(uart_interface_tb);
        env.reset();
        env.run();
    end
endmodule
