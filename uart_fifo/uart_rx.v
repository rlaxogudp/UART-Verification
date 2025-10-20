`timescale 1ns / 1ps

module uart_rx (
    input        clk,
    input        rst,
    input        b_tick,
    input        rx,
    output [7:0] rx_data,
    //output       rx_busy,
    output       rx_done
);

    localparam [1:0] IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg [3:0] b_tick_CNT_reg, b_tick_CNT_next;
    reg [2:0] bit_CNT_reg, bit_CNT_next;
    //reg rx_busy_reg, rx_busy_next;
    reg rx_done_reg, rx_done_next;

    assign rx_data = rx_data_reg;
    //assign rx_busy = rx_busy_reg;
    assign rx_done = rx_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state_reg      <= IDLE;
            rx_data_reg    <= 0;
            b_tick_CNT_reg <= 0;
            bit_CNT_reg    <= 0;
            rx_done_reg    <= 0;
          //  rx_busy_reg    <= 0;
        end else begin
            state_reg      <= state_next;
            rx_data_reg    <= rx_data_next;
            b_tick_CNT_reg <= b_tick_CNT_next;
            bit_CNT_reg    <= bit_CNT_next;
            rx_done_reg    <= rx_done_next;
           // rx_busy_reg    <= rx_busy_next;
        end
    end

    always @(*) begin
        state_next = state_reg;
        rx_done_next = rx_done_reg;
        //rx_busy_next = rx_busy_reg;
        rx_data_next = rx_data_reg;
        b_tick_CNT_next = b_tick_CNT_reg;
        bit_CNT_next = bit_CNT_reg;
        case (state_reg)
            IDLE: begin
                rx_done_next = 0;
                if (rx == 0) begin
                    b_tick_CNT_next = 0;
                    bit_CNT_next = 0;
                    state_next = START;
                end
            end
            START: begin
                if (b_tick) begin
                    if (b_tick_CNT_reg == 7) begin
                        b_tick_CNT_next = 0;
                       // rx_busy_next = 1'b1;
                        state_next = DATA;
                    end else begin
                        b_tick_CNT_next = b_tick_CNT_reg + 1;
                    end
                end
            end
            DATA: begin
                if (b_tick) begin
                    if (b_tick_CNT_reg == 15) begin
                        b_tick_CNT_next = 0;
                        rx_data_next = {rx, rx_data_reg[7:1]};
                        if (bit_CNT_reg == 7) begin
                            state_next   = STOP;
                            bit_CNT_next = 0;
                        end else begin
                            bit_CNT_next = bit_CNT_reg + 1;
                            // Read Rx data by shift register
                        end
                    end else begin
                        b_tick_CNT_next = b_tick_CNT_reg + 1;
                    end
                end
            end
            STOP: begin
                if (b_tick) begin
                    if (b_tick_CNT_reg == 15) begin
                        b_tick_CNT_next = 0;
                        //rx_busy_next = 1'b0;
                        rx_done_next = 1'b1;
                        state_next = IDLE;
                    end else begin
                        b_tick_CNT_next = b_tick_CNT_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule
