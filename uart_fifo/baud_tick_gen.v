`timescale 1ns / 1ps

module baud_tick_gen (
    input  clk,
    input  rst,
    output o_b_tick
);

    // 100_000_000 / BAUD_TICK_COUNT, counter_reg 
    parameter BAUD = 9600;
    parameter BAUD_TICK_COUNT = 100_000_000 / BAUD / 16;
    reg [$clog2(BAUD_TICK_COUNT)-1:0] counter_reg;
    reg b_tick_reg;

    assign o_b_tick = b_tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            b_tick_reg  <= 0;
        end else begin
            if (counter_reg == BAUD_TICK_COUNT-1) begin
                counter_reg <= 0;
                b_tick_reg  <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                b_tick_reg  <= 1'b0;
            end
        end
    end
endmodule
