`ifndef _UART_COUNTER_
`define _UART_COUNTER_

module UARTCounter #(parameter OUTPUT_WIDTH = 4)
(   output reg [OUTPUT_WIDTH-1 : 0] value,
    output wire compare_value_flag,
    input wire clk,
    input wire enable,
    input wire reset,
    input wire [OUTPUT_WIDTH-1 : 0] compare_value
);

    reg [OUTPUT_WIDTH-1 : 0] next_value;
    wire reset_w;

    // COMBINATIONAL PART 
    assign compare_value_flag = value == compare_value ? 1 : 0;
    assign reset_w = reset | compare_value_flag;

    always @(value or reset_w or enable) begin
        if(reset_w) next_value = 0;
        else if(enable) next_value = value + 1;
        else next_value = value;
    end

    // SEQUINTIAL PART
    always @(posedge clk) value <= next_value;

endmodule

`endif