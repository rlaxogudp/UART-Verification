`timescale 1ns / 1ps

module counter_4(
    input clk,
    input rst,
    output [1:0] sel
    );

    reg [1:0] counter_reg;
    assign sel = counter_reg;

    always @(posedge clk , posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_reg +1;
        end
    end
endmodule
