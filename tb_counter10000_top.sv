`timescale 1ns / 1ps

module tb_counter10000_top ();
    parameter COUNT_DELAY = 100_000_000;
    parameter BIT_PERIOD = 104166;

    reg clk, rst, btn_D, btn_R, btn_L, rx;
    wire tx;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    counter10000_TOP dut (
        .rst(rst),
        .clk(clk),
        .btn_D(btn_D),
        .btn_R(btn_R),
        .btn_L(btn_L),
        .rx(rx),
        .tx(tx),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    // 100MHz clock
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst   = 1;
        btn_R = 0;
        btn_L = 0;
        btn_D = 0;
        rx    = 1;   // idle

        #10;
        rst = 0;
        #100;
        btn_R = 1;
        #20_000_000;  
        btn_R = 0;
        #(COUNT_DELAY*2);

        btn_D = 1;
        #20_000_000;
        btn_D = 0;
        #(COUNT_DELAY*2);

        btn_L = 1;
        #20_000_000;
        btn_L = 0;
        #(COUNT_DELAY * 3);
        send_uart(8'h72);
        #(COUNT_DELAY * 1);
        send_uart(8'h72);
        #(COUNT_DELAY * 2);
        send_uart(8'h6D);
        #(COUNT_DELAY * 3);
        send_uart(8'h63);
        #(COUNT_DELAY * 1);
        $stop;
    end


    task send_uart(input [7:0] send_data);
        integer i;
        begin
            rx = 0;
            #(BIT_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(BIT_PERIOD);
            end
            rx = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

endmodule















// `timescale 1ns / 1ps

// module tb_top ();
//     parameter COUNT_DELAY = 100_000_000;
//     parameter CLOCK_PERIOD_NS = 10;  //100Mhz
//     parameter BITPERCLOCK = 10416;  // 1 / BAUD_RATE;  // 1bit per clock 1/9600
//     parameter BIT_PERIOD = BITPERCLOCK * CLOCK_PERIOD_NS; // number of clock * 10

//     reg clk, rst, Btn_R, Btn_L, Btn_U, rx;
//     wire [3:0] fnd_com;
//     wire [7:0] fnd;
//     wire tx;

//     top dut (
//         .clk(clk),
//         .rst(rst),
//         .Btn_R(Btn_R),
//         .Btn_L(Btn_L),
//         .Btn_U(Btn_U),
//         .rx(rx),
//         .fnd_com(fnd_com),
//         .fnd(fnd),
//         .tx(tx)
//     );

//     always #5 clk = ~clk;

//     initial begin
//         #0;
//         clk = 0;
//         rst = 1;
//         Btn_R = 0;
//         Btn_L = 0;
//         Btn_U = 0;
//         rx = 1;
//         #10;
//         rst = 0;
//         #10;
//         Btn_R = 1;
//         #20_000;
//         Btn_R = 0;
//         #(COUNT_DELAY * 2);
//         Btn_U = 1;
//         #20_000;
//         Btn_U = 0;
//         #(COUNT_DELAY * 2);
//         Btn_L = 1;
//         #20_000;
//         Btn_L = 0;
//         #(COUNT_DELAY);
//         send_uart(8'h52);
//         #(COUNT_DELAY * 2);
//         send_uart(8'h4C);
//         #(COUNT_DELAY * 2);
//         send_uart(8'h55);
//         #(COUNT_DELAY * 2);
//         $stop;
//     end


//     task send_uart(input [7:0] send_data);
//         integer i;
//         begin
//             rx = 0;
//             #(BIT_PERIOD);
//             for (i = 0; i < 8; i = i + 1) begin
//                 rx = send_data[i];
//                 #(BIT_PERIOD);
//             end
//             rx = 1'b1;
//             #(BIT_PERIOD);
//         end
//     endtask


// endmodule
