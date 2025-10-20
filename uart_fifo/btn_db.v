`timescale 1ns / 1ps

module btn_db (
    input system_clk,
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    reg reg_btn, next_btn;
    reg [2:0] reg_state, next_state;

    localparam [2:0] IDLE = 0, FIRST = 1, SECOND = 2, THIRD = 3, FOURTH = 4;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            reg_btn   <= 0;
            reg_state <= 0;
        end else begin
            reg_btn   <= next_btn;
            reg_state <= next_state;
        end
    end

    always @(*) begin
        next_btn   = reg_btn;
        next_state = reg_state;
        case (reg_state)
            IDLE: begin
                if (i_btn) begin
                    next_state = FIRST;
                    next_btn   = 1'b0;
                end else begin
                    next_state = IDLE;
                    next_btn   = 1'b0;
                end
            end
            FIRST: begin
                if (i_btn) begin
                    next_state = SECOND;
                    next_btn   = 1'b0;
                end else begin
                    next_state = IDLE;
                    next_btn   = 1'b0;
                end
            end
            SECOND: begin
                if (i_btn) begin
                    next_state = THIRD;
                    next_btn   = 1'b0;
                end else begin
                    next_state = IDLE;
                    next_btn   = 1'b0;
                end
            end
            THIRD: begin
                if (i_btn) begin
                    next_state = FOURTH;
                    next_btn   = 1'b0;
                end else begin
                    next_state = IDLE;
                    next_btn   = 1'b0;
                end
            end
            FOURTH: begin
                if (i_btn) begin
                    next_state = FOURTH;
                    next_btn   = 1'b1;
                end else begin
                    next_state = IDLE;
                    next_btn   = 1'b0;
                end
            end
        endcase
    end


    //4 input AND logic
    assign debounce = &reg_btn;   
    
    //1clk delay
    reg edge_reg;
        //rising edge detector
    always @(posedge system_clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 0;    
        end else begin
            edge_reg <= debounce;
        end
    end

    //p1과 같은 동작
    assign o_btn = ~edge_reg & debounce;
endmodule
