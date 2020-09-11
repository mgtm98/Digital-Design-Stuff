`include "counter.v"
`include "RX/rx_control.v"
`include "shiftReg.v"
`include "RX/parityChecker.v"

module UART_RX(
    output wire [7:0] data,
    input wire clk,
    input wire dataline,
    input wire [15:0] baudrate,
    input wire rst
);

    wire [15:0] half_period_counter_value;
    wire half_periof_counter_overflow_flag;
    wire half_period_counter_enable;
    wire half_period_counter_reset;

    wire [3:0] bit_counter_value;
    wire bit_counter_overflow_flag;
    wire bit_counter_enable_control;
    wire bit_counter_reset;

    wire parity_checker_rst;
    wire parity_checker_enable_control;
    wire parity_checker_value;

    wire internal_buffer_data_valid;
    wire internal_buffer_enable_control;
    wire internal_buffer_reset;

    UARTCounter #(16) half_period_counter(
        .clk(clk),
        .enable(half_period_counter_enable),
        .reset(half_period_counter_reset | rst),
        .compare_value((baudrate >> 1) - 16'b1),
        .value(half_period_counter_value),
        .compare_value_flag(half_periof_counter_overflow_flag)
    );

    UARTCounter #(4) bit_counter(
        .clk(clk),
        .enable(bit_counter_enable_control),
        .reset(bit_counter_reset | rst),
        .compare_value(4'd15),
        .value(bit_counter_value),
        .compare_value_flag(bit_counter_overflow_flag)
    );

    UARTParityChecker parity_checker(
        .clk(clk),
        .dataline(dataline),
        .rst(parity_checker_rst | rst),
        .enable(parity_checker_enable_control),
        .parity_out(parity_checker_value),
        .valid(internal_buffer_data_valid)
    );

    ShiftRegister internal_buffer(
        .clk(clk),
        .rst(internal_buffer_reset | rst),
        .enable(internal_buffer_enable_control),
        .dataline(dataline),
        .valid(internal_buffer_data_valid),
        .output_buffer(data)
    );

    UARTRXControl controller(
        .clk(clk),
        .rst(rst),
        .dataline(dataline),
        .half_period_flag(half_periof_counter_overflow_flag),
        .bit_count(bit_counter_value),
        .buffer_valid(internal_buffer_data_valid),
        .buffer_enable(internal_buffer_enable_control),
        .buffer_rst(internal_buffer_reset),
        .parity_enable(parity_checker_enable_control),
        .parity_rst(parity_checker_rst),
        .half_prtiod_counter_enable(half_period_counter_enable),
        .half_period_counter_rst(half_period_counter_reset),
        .bit_counter_enable(bit_counter_enable_control),
        .bit_counter_rst(bit_counter_reset)
    );

endmodule