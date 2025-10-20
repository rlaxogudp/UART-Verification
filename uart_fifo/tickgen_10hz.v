`timescale 1ns / 1ps

module tickgen_10hz #(DIV = 1_000)(
    input clk,
    input rst,
    input enable,
    input clear,
    output reg o_tick_10hz
    );
    localparam WIDTH = $clog2(DIV);
    reg [WIDTH-1:0] r_counter;

    always @(posedge clk , posedge rst) begin
        if (rst | clear) begin
            r_counter <= 0;
            o_tick_10hz <= 0;
        end else begin
            if (enable ==1) begin
                if (r_counter == DIV-1) begin
                r_counter <= 0;
                o_tick_10hz <=1;
                end else begin
                r_counter <= r_counter +1;
                o_tick_10hz <= 0;
                end
            end else 
                r_counter <= r_counter;
        end
    end
endmodule
