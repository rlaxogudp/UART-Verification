// `timescale 1ns / 1ps

// module uart_fifo(
//     input rx,
//     input clk,
//     input rst,
//     output [7:0] rx_data,
//     output tx,
//     output rx_done
//     );

//     wire w_tx_start, w_tx_busy, w_rx_done, w_lp_push, w_lp_pop;
//     wire [7:0] w_rx_data, w_tx_data, w_loop_back_data;

//     uart_top U_UART(
//         .clk(clk),
//         .rst(rst),
//         .rx(rx),
//         .tx_start(~w_tx_start),
//         .tx_data(rx_data),
//         .tx(tx),
//         .tx_busy(w_tx_busy),
//         .rx_data(w_rx_data),
//         .rx_busy(),
//         .rx_done(rx_done)
//     );

//     fifo U_UART_TX_FIFO(
//         .clk(clk),
//         .rst(rst),
//         .wdata(w_loop_back_data),
//         .push(~w_lp_push),
//         .pop(~w_tx_busy),
//         .full(w_lp_pop),
//         .empty(w_tx_start),
//         .rdata(rx_data)
//     );

//     fifo U_UART_RX_FIFO(
//         .clk(clk),
//         .rst(rst),
//         .wdata(w_rx_data),
//         .push(rx_done),
//         .pop(~w_lp_pop),
//         .full(),
//         .empty(w_lp_push),
//         .rdata(w_loop_back_data)
//     );

// endmodule


   