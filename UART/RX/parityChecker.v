`ifndef _UART_PARITY_CHECKER
`define _UART_PARITY_CHECKER

module UARTParityChecker(
    output reg parity_out,
    input wire clk,
    input wire dataline,
    input wire rst,
    input wire valid,
    input wire enable
);

    reg parity;
    reg parity_next;
    reg parity_out_next;
    wire xor_outpt;

    assign xor_outpt = dataline ^ parity;

    always @(enable or rst or xor_outpt or parity)begin
        if(enable) parity_next = xor_outpt;
        else if(rst) parity_next = 0;
        else parity_next = parity;
    end

    always @(parity, parity_out, valid)begin
        if(valid) parity_out_next = parity;
        else parity_out_next = parity_out;
    end

    always @(posedge clk) parity_out <= parity_out_next;

    always @(posedge clk) parity <= parity_next;

endmodule
`endif