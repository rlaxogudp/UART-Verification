`timescale 1ns / 1ps

module counter_datapath(
    input rst,
    input clk,
    input sw0,
    input sw1,
    input clear,
    output [13:0] counter
    );

    wire w_clk_10hz;

    counter_10000 U_COUNTER_10000(
        .clk(clk),
        .rst(rst),
        .mode(sw0),
        .clear(clear),
        .i_tick(w_clk_10hz),
        .o_tick(counter)
    );

    tickgen_10hz #(.DIV(10_000_000))
    
    U_TICK_GEN_10HZ(
        .clk(clk),
        .rst(rst),
        .enable(sw1),
        .clear(clear),
        .o_tick_10hz(w_clk_10hz)
    );
endmodule
