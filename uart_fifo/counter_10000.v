`timescale 1ns / 1ps

module counter_10000(
    input clk,
    input rst,
    input i_tick,
    input mode,
    input clear,
    output [13:0] o_tick
    );

    localparam MAX_COUNT = 10_000 -1;

    reg [13:0] c_counter, n_counter;
    assign o_tick = c_counter;

    always @(posedge clk , posedge rst) begin
        if (rst | clear) begin
            c_counter <=0;
        end else begin
            c_counter <= n_counter;
        end
    end

    always @(*) begin
        n_counter = c_counter;
        if (i_tick) begin
            if (mode == 0) begin // 'Up' 카운트 모드
                if (c_counter == MAX_COUNT) begin
                    n_counter = 0; 
                end else begin
                    n_counter = c_counter + 1;
                end
            end else begin // 'Down' 카운트 모드
                if (c_counter == 0) begin
                    n_counter = MAX_COUNT; 
                end else begin
                    n_counter = c_counter - 1;
                end
            end
        end
    end
endmodule
