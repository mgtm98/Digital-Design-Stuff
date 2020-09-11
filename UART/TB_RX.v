`include "RX/rx.v"
module TB();

reg clk;
reg rst;
reg enb;
reg dataline;
wire [7:0] buffer;

UART_RX rx(
    .data(buffer),
    .clk(clk),
    .dataline(dataline),
    .baudrate(16'd8),
    .rst(rst)
);

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, rx);
    // Initial Value of the wires
    clk = 1;
    rst = 0;
    enb = 0;
    dataline = 1;
    #10
    // Resetting the module
    rst = 1;
    #10
    rst = 0;
    // Sending Data frame
    // start bit
    dataline = 0;
    #80
    // 8bits data
    dataline = 1;
    #80
    dataline = 0;
    #80
    dataline = 1;
    #80
    dataline = 0;
    #80
    dataline = 1;
    #80
    dataline = 0;
    #80
    dataline = 1;
    #80
    dataline = 0;
    #80
    // PARITY
    dataline = 1;
    #80
    // end bit
    dataline = 1;
    #80
    // END OF FRAME
        // Sending Data frame
    // start bit
    dataline = 0;
    #80
    // 8bits data
    dataline = 1;
    #80
    dataline = 1;
    #80
    dataline = 1;
    #80
    dataline = 1;
    #80
    dataline = 0;
    #80
    dataline = 0;
    #80
    dataline = 0;
    #80
    dataline = 0;
    #80
    // PARITY
    dataline = 0;
    #80
    // end bit
    dataline = 1;
    #80
    // END OF FRAME
    #160
    $finish();
end

always begin
    #5
    clk = ~clk;
end

endmodule