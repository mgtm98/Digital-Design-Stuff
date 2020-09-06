`include "counter.v"
`include "TX.v"
`include "RX.v"

module UART_TB();

reg clk = 1;
reg [7:0] write_buffer;
reg [15:0] uart_baud_control = 8;
reg send = 0;
reg reset = 1;
wire [7:0] read_data;
wire data_line;
wire busy;

UART_TX tx(clk, write_buffer, uart_baud_control, send, reset, data_line, busy);
UART_RX rx(clk, data_line, uart_baud_control, reset, read_data);


initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0,tx);
    $dumpvars(0,rx);
    // RESETTING
    reset = 1;
    #10
    reset = 0;
    #10
    reset = 1;
    // Write Frame
    write_buffer = 8'b10101010;
    send = 1;
    #10
    send = 0;
    #790
    // Write Frame
    write_buffer = 8'b11110000;
    send = 1;
    #10
    send = 0;
    #790
    // Write Frame
    write_buffer = 8'b00001111;
    send = 1;
    #10
    send = 0;
    #790
    // Write Frame
    write_buffer = 8'b11001100;
    send = 1;
    #10
    send = 0;
    #790
    // Write Frame
    write_buffer = 8'b11101110;
    send = 1;
    #10
    send = 0;
    #790
    #800
    $finish();
end

always begin
    #5 clk = ~clk;
end

endmodule