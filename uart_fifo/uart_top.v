`timescale 1ns / 1ps

module uart_top (
    input        clk,
    input        rst,
    input        rx,
    output       tx,
    output [7:0] rx_data,
    output       cmd_start
);

    wire w_b_tick;
    wire w_tx_busy, w_lp_push, w_lp_pop;
    wire [7:0] w_rx_data, w_loop_back_data, a_rx_data;


    fifo U_UART_TX_FIFO (
        .clk  (clk),
        .rst  (rst),
        .wdata(w_loop_back_data),
        .push (~w_lp_push),
        .pop  (~w_tx_busy),
        .full (w_lp_pop),
        .empty(cmd_start),
        .rdata(rx_data)
    );

    fifo U_UART_RX_FIFO (
        .clk  (clk),
        .rst  (rst),
        .wdata(w_rx_data),
        .push (rx_done),
        .pop  (~w_lp_pop),
        .full (),
        .empty(w_lp_push),
        .rdata(w_loop_back_data)
    );


    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .rx(rx),
        .rx_data(w_rx_data),
        //.rx_busy(rx_busy),
        .rx_done(rx_done)
    );

    UART_TX U_UART_TX (
        .clk(clk),
        .rst(rst),
        .tx_start(~cmd_start),
        .tx_data(rx_data),
        .b_tick(w_b_tick),
        .tx_busy(w_tx_busy),
        .tx(tx)
    );

    baud_tick_gen U_BAUD_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .o_b_tick(w_b_tick)
    );

endmodule
