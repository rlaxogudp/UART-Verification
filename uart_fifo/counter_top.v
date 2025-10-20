`timescale 1ns / 1ps

module counter_top(
    input clk,
    input rst,
    input [13:0] counter,
    output [3:0] fnd_com,
    output [7:0] fnd_data
    );

    wire [3:0] w_bcd;
    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire w_clk_1khz;
    wire [1:0] w_sel;
    

    clk_div U_CLK_DIV(
        .clk(clk),
        .rst(rst),
        .o_clk(w_clk_1khz)
    );

    counter_4 U_COUNTER_4(
        .clk(w_clk_1khz),
        .rst(rst),
        .sel(w_sel)
    );

    decoder_2x4 U_DECODER_2x4(
        .sel(w_sel),
        .fnd_com(fnd_com)
    );

    digit_spliter U_DS (
        .counter(counter),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    mux4x1 U_MUX_4x1(
        .sel(w_sel),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .o_bcd(w_bcd)
    );

    bcd_decoder U_BCD_DECODER(
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );    

endmodule
