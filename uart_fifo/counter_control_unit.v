`timescale 1ns / 1ps

module counter_cu_v2 (
    input clk,
    input rst,
    input enable,
    input clear,
    input mode,
    output o_clear,
    output o_mode,
    output o_enable
);
    parameter IDLE = 0, CMD = 1;

    reg state_reg  ,   state_next;
    reg clear_reg  ,   clear_next;
    reg mode_reg   ,   mode_next;
    reg enable_reg ,   enable_next;

    assign o_clear  = clear_reg;
    assign o_mode   = mode_reg;
    assign o_enable = enable_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state_reg  <= IDLE;
            clear_reg  <= 1'b0;
            mode_reg   <= 1'b0;
            enable_reg <= 1'b0;
        end else begin
            state_reg  <=  state_next;
            clear_reg  <=  clear_next;
            mode_reg   <=  mode_next;
            enable_reg <=  enable_next;
        end
    end

    always @(*) begin
        state_next  = state_reg;
        clear_next  = clear_reg;
        mode_next   = mode_reg;
        enable_next = enable_reg;
        case (state_reg)
            IDLE: begin
                state_next = IDLE;
                if(clear) begin
                    clear_next  = 1'b1;
                    state_next = CMD;
                end
                if (enable) begin
                    state_next = CMD;
                    if(enable_reg == 1'b1) begin
                        enable_next = 1'b0;
                    end else begin
                        enable_next = 1'b1;
                    end
                end
                if (mode) begin
                    state_next = CMD;
                    if(mode_reg == 1'b1) begin
                        mode_next = 1'b0;
                    end else begin
                        mode_next = 1'b1;
                    end
                end
            end
            
            CMD : begin
                clear_next = 1'b0;
                state_next = IDLE;
            end
        endcase
    end
endmodule