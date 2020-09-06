module UART_TX(
    input wire clk,
    input wire  [7:0] write_buffer,
    input wire [15:0] baud_rate_control,
    input wire send,
    input wire reset,
    output reg data_line,
    output reg busy
);

parameter BUSY = 1'b1;
parameter IDEAL = 1'b0;

reg [9:0] buffer;
reg state;

reg next_state;
reg period_counter_enable;
reg send_bit_counter_inc;
reg send_bit_counter_reset;

wire [15:0] perid_counter_value;
wire [3:0] send_bit_counter_value;

wire full_period_flag = perid_counter_value == 0 ? 1 : 0;

Counter #(16) period_counter (.clk(clk),
                              .load_value(16'h0000),
                              .value(perid_counter_value),
                              .enable(period_counter_enable),
                              .reset(reset),
                              .reset_value(baud_rate_control - 1));

Counter #(4) send_bit_counter      (.clk(!clk),
                                    .load_value(4'b0000),
                                    .value(send_bit_counter_value),
                                    .enable(!send_bit_counter_inc),
                                    .reset(send_bit_counter_reset),
                                    .reset_value(4'd10));

always @(posedge clk)begin
    state <= next_state;
    send_bit_counter_inc = 0;
    send_bit_counter_reset = 1;
end

always @(posedge send or state or posedge full_period_flag)begin
    next_state = next_state;
    send_bit_counter_reset = send_bit_counter_reset;
    send_bit_counter_inc = send_bit_counter_inc;
    period_counter_enable = period_counter_enable;
    busy = busy;
    casex(state)
        IDEAL: begin
            data_line <= 1;
            busy = 0;
            if(send) begin
                buffer <= {1'b1, write_buffer, 1'b0};
                next_state = BUSY;
                send_bit_counter_reset = 0;
            end
        end
        BUSY: begin
            period_counter_enable = 0;
            send_bit_counter_inc = 1;
            busy = 1;
            data_line <= buffer[send_bit_counter_value];
            if(send_bit_counter_value == 10)begin 
                next_state = IDEAL;
                data_line <= 1;
            end
        end
        default: data_line <= 1;
    endcase
end

always @(negedge reset)begin
    state <= IDEAL;
    buffer <= 10'h000;
    next_state = IDEAL;
    period_counter_enable = 1;
    data_line = 1;
    // period_counter_reset = 1;
    send_bit_counter_inc = 0;
    send_bit_counter_reset = 1;

end

endmodule