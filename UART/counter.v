module Counter #(parameter OUTPUT_WIDTH = 4)
(   output reg [OUTPUT_WIDTH-1 : 0] value,
    input wire clk,
    input wire enable,
    input wire reset,
    input wire [OUTPUT_WIDTH-1 : 0] load_value,
    input wire [OUTPUT_WIDTH-1 : 0] reset_value
);

    always @(negedge reset) value <= load_value;

    always @(posedge clk) begin
        if(!enable)begin
            if(value + 1 > reset_value) value <= load_value;
            else value <= value + 1;
        end
    end
endmodule