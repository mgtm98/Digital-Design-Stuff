`ifndef _UART_RX_IF_
`define _UART_RX_IF_

interface RX_IF(input clk);
    logic [7:0] data;
    logic dataline;
    logic [15:0] baudrate;
    logic rst;

    modport Driver(
        input clk,
        output baudrate, rst, dataline
    );

    modport DUT(
        input clk, baudrate, rst, dataline,
        output  data
    );

    modport Monitor(
        input data
    );

endinterface

`endif