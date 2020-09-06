`include "RX.v"

module UART_TB();

reg clk = 1;
reg data_line = 1;
reg [15:0] uart_baud_control = 8;
reg reset = 1;
wire [7:0] read_data;

UART_RX rx(clk, data_line, uart_baud_control, reset, read_data);

initial begin
    $dumpfile("rx.vcd");
    $dumpvars(0,rx);
    // RESETTING
    reset = 1;
    data_line = 1;
    #10
    reset = 0;
    #5
    reset = 1;
    #15
    // ***************************** FRAME 1 **************************************************
    // START BIT
    data_line = 0; #80
    // DATA
    data_line = 1; #80
    data_line = 0; #80
    data_line = 1; #80
    data_line = 0; #80
    data_line = 1; #80
    data_line = 0; #80
    data_line = 1; #80
    data_line = 0; #80
    // END BIT
    data_line = 1; #80
    // ****************************************************************************************
    // ***************************** FRAME 2 **************************************************
    // START BIT
    data_line = 0; #80
    // DATA
    data_line = 0; #80
    data_line = 0; #80
    data_line = 1; #80
    data_line = 1; #80
    data_line = 0; #80
    data_line = 0; #80
    data_line = 1; #80
    data_line = 1; #80
    // END BIT
    data_line = 1; #80
    // ****************************************************************************************
    data_line = 1; #120
    $finish();
end

always begin
    #5 clk = ~clk;
end

endmodule