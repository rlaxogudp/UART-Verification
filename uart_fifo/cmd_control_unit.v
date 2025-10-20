`timescale 1ns / 1ps

module cmd_control_unit (
    input            rst,
    input            clk,
    input      [7:0] rx_data,
    input            cmd_start,
    output reg       o_cmd_run,
    output reg       o_cmd_clear,
    output reg       o_cmd_mode
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            o_cmd_run <= 0;
            o_cmd_clear <= 0;
            o_cmd_mode <= 0;
        end else begin
            if (cmd_start) begin
                if (rx_data == "r")begin
                    o_cmd_run <= 1'b1;
                end else if (rx_data == "c") begin
                    o_cmd_clear <= 1'b1;
                end else if (rx_data == "m") begin
                    o_cmd_mode <= 1'b1;
                end 
            end else begin
                o_cmd_run <= 0;
                o_cmd_clear <= 0;
                o_cmd_mode <= 0;
            end
        end
    end
endmodule
