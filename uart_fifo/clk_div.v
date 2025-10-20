`timescale 1ns / 1ps

module clk_div(
    input clk,
    input rst,
    output o_clk
);
    parameter F_COUNT = 100_000;
    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg clk_reg;

    assign o_clk = clk_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            clk_reg <= 0;
        end else begin
            if (counter_reg == F_COUNT-1) begin
                counter_reg <= 0;
                clk_reg <= 1;
            end else begin
                counter_reg <= counter_reg +1;
                clk_reg <= 0;
            end
        end
    end
endmodule
