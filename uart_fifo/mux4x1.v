`timescale 1ns / 1ps

module mux4x1(
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output [3:0] o_bcd
     );

     reg [3:0] bcd_reg;
     assign o_bcd = bcd_reg;
     always @(*) begin
        case (sel)
            2'b00: bcd_reg = digit_1; 
            2'b01: bcd_reg = digit_10; 
            2'b10: bcd_reg = digit_100; 
            2'b11: bcd_reg = digit_1000;  
        endcase
     end
endmodule
