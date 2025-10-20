`timescale 1ns / 1ps

module digit_spliter (
    input  [13:0] counter,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);

    assign digit_1 = counter % 10;
    assign digit_10 = (counter / 10) % 10;
    assign digit_100 = (counter / 100) % 10;
    assign digit_1000 = (counter / 1000) % 10;
endmodule
