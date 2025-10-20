`timescale 1ns / 1ps

module counter10000_TOP (
    input        rst,
    input        clk,
    input        btn_D,
    input        btn_R,
    input        btn_L,
    input        rx,
    output       tx,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [13:0] w_counter;
    wire w_enable, w_clear, w_mode;
    wire w_btnD, w_btnR, w_btnL;
    wire w_1khz_clk;
    wire [7:0] w_rx_data;

    wire w_o_cmd_run;
    wire w_o_cmd_clear;
    wire w_o_cmd_mode;

    assign w_btn_uart_enable = w_btnR | w_o_cmd_run;
    assign w_btn_uart_clear  = w_btnL | w_o_cmd_clear;
    assign w_btn_uart_mode   = w_btnD | w_o_cmd_mode;

    cmd_control_unit U_CMD_CU (
        .rst(rst),
        .clk(clk),
        .rx_data(w_rx_data),
        .cmd_start(~w_cmd_start),
        .o_cmd_run(w_o_cmd_run),
        .o_cmd_clear(w_o_cmd_clear),
        .o_cmd_mode(w_o_cmd_mode)
    );

    uart_top U_UART_TOP (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data(w_rx_data),
        .tx(tx),
        .cmd_start(w_cmd_start)
    );

    // uart_fifo U_UART_FIFO(
    //     .rx(rx),
    //     .clk(clk),
    //     .rst(rst),
    //     .rx_data(w_rx_data),
    //     .tx(tx),
    //     .rx_done(w_rx_done)
    // );


    counter_cu_v2 COUNTER_CU (
        .clk(clk),
        .rst(rst),
        .enable(w_btn_uart_enable),
        .clear(w_btn_uart_clear),
        .mode(w_btn_uart_mode),
        .o_clear(w_clear),
        .o_mode(w_mode),
        .o_enable(w_enable)
    );

    counter_datapath U_COUNTER_DP (
        .rst(rst),
        .clk(clk),
        .sw0(w_mode),
        .sw1(w_enable),
        .clear(w_clear),
        .counter(w_counter)
    );

    counter_top U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .counter(w_counter),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    clk_div U_1KHZ_CLK (
        .clk  (clk),
        .rst  (rst),
        .o_clk(w_1khz_clk)
    );


    btn_db DB_D (
        .i_btn(btn_D),
        .rst(rst),
        .system_clk(clk),
        .clk(w_1khz_clk),
        .o_btn(w_btnD)
    );

    btn_db DB_R (
        .i_btn(btn_R),
        .rst(rst),
        .system_clk(clk),
        .clk(w_1khz_clk),
        .o_btn(w_btnR)
    );

    btn_db DB_L (
        .i_btn(btn_L),
        .rst(rst),
        .system_clk(clk),
        .clk(w_1khz_clk),
        .o_btn(w_btnL)
    );


endmodule
