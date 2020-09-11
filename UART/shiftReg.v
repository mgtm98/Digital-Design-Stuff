`ifndef _UART_RX_
`define _UART_RX_

module ShiftRegister(
    output reg [7:0] output_buffer,
    input wire clk,
    input wire rst,
    input wire enable,
    input wire dataline,
    input wire valid
);

integer i;

reg [7:0] buffer;

reg [7:0] output_buffer_next;
reg [7:0] data_next;

always @(*)begin
    for(i = 0; i < 8; i = i + 1)begin
        if(enable)begin
            if(i == 7) data_next[i] = dataline;
            else data_next[i] = buffer[i + 1];
        end
        else if(rst) data_next[i] = 0;
        else data_next[i] = buffer[i];
    end
end

always @(valid or output_buffer or output_buffer_next)begin
    if(valid) output_buffer_next = buffer;
    else output_buffer_next = output_buffer; 
end

always @(negedge clk) buffer <= data_next;
always @(negedge clk) output_buffer <= output_buffer_next;

endmodule

`endif