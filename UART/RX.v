module UART_RX(
    input wire clk,
    input wire data_line,
    input wire [15:0] baud_rate_control,
    input wire reset,
    output reg [7:0] read_buffer
);

parameter IDEL_STATE = 3'b00;
parameter START_BIT_STATE = 3'b01;
parameter RECV_STATE = 3'b10;
parameter WAITE_STATE  = 3'b11;
parameter END_BIT_STATE  = 3'b100; 

reg [2:0] previous_state;               // (MEMORY ELEMENT) store previous state of the FSM
reg [2:0] state;                        // (MEMORY ELEMENT) store the current state of the FSM
reg [7:0] buffer;                       // (MEMORY ELEMENT) data buffer

reg [2:0] next_state;                   // (NET) next state evaluated by the FSM and to be stored in state
reg valid_data;                         // (NET) data valid flag used to put the read data from the read buffer to the output
reg half_period_counter_enable;         // (NET) enable half_period_counter
reg inc;                                // (NET) enable bit_counter
reg bit_reset;                          // (NET) reset bit_counter
reg reset_half_period_counter;          // (NET) reset half_period_counter

wire [15:0] half_perid_counter_value;   // value of the half period counter
wire half_period_counter_reset;         // reset of the half period counter
wire [15:0] half_period_counter_reset_value; // used to define the half period counter limit
wire half_period_flag;                 // used to determine that the half period counter overflowd

wire bit_res;                          // reset of the bit counter
wire [3:0] buffer_bit_count;           // value of the bit counter


Counter #(16) half_period_counter (.clk(clk),
                                   .load_value(16'h0000),
                                   .value(half_perid_counter_value),
                                   .enable(half_period_counter_enable),
                                   .reset(half_period_counter_reset),
                                   .reset_value(half_period_counter_reset_value));

Counter #(4) bit_counter           (.clk(!clk),
                                    .load_value(4'b0000),
                                    .value(buffer_bit_count),
                                    .enable(!inc),
                                    .reset(bit_res),
                                    .reset_value(4'b1000));


assign half_period_flag = half_perid_counter_value == ((baud_rate_control >> 1) - 1) ? 1 : 0;
assign half_period_counter_reset_value = (baud_rate_control >> 1) - 1;
assign half_period_counter_reset = reset_half_period_counter & reset;
assign bit_res = bit_reset & reset;

always @(posedge clk)begin
    // DEFAULT VALUES
    previous_state <= previous_state;
    state <= next_state;
    inc = 0;
    bit_reset = 1;
    valid_data = 0;
    // AT HALF THE PERIOD UPDATE THE PREVIOUS STATE
    if(half_period_flag) previous_state <= state;
end

always @(valid_data)begin
    // DEFAULT VALUES
    read_buffer <= read_buffer;
    buffer <= buffer;
    // IF DATA VALID FLAG IS HIGH, MOVE THE DATA FROM THE BUFFER TO THE READ BUFFER AND RESET THEE BUFFER
    if(valid_data)begin
        read_buffer <= buffer;
        buffer <= 8'h00;
    end 
end

always @(buffer_bit_count)begin
    buffer[buffer_bit_count - 1] <= data_line;
end 
// *************************** FSM ***********************************************************************************************
//                                     +-----+            | RELATIONS BETWEEN STATES:
//                                     |RECEV|            |-------------------------
//                                     |STATE|            | 1) IDEAL STATE: when the data line is LOW (possible to be a start bit) 
//                                     +--+--+            |    START BIT STATE: wait for the half period and the data line is HIGH
//                                        ^               |                      not low (false start bit) 
//                                        |3              | 2) wait for the half period and the data line is LOW then the start bit
//   +-----+        +-----+               v               |    condition is met and start to receive bits
//   |IDEAL|   1    |START|    2    +-----+----+          | 3) WAIT STATE: wait for half period then go to receive if the number of 
//   |     +<------>+ BIT +-------->+WAIT STATE|          |                 bit is less than 8
//   |STATE|        |STATE|         +-----+----+          |    RECV STATE: sample the bit and go to wait state
//   +--+--+        +-----+               |               | 4) wait for half period then go to end bit if the number of bit is 
//      ^                                 |4              |    equal to 8 
//      |                                 v               | 5) if data line is HIGH (constrain for end bit) then data in buffer is 
//      |                              +--+--+            |    valid
//      |               5              | END |            |-----------------------------------------------------------------------
//      +------------------------------+ BIT |            |STATES
//                                     |STATE|            |------
//                                     +-----+            |1) IDEAL STATE: no start bit occured
//                                                        |2) START BIT STATE: data line is LOW and it might be a start bit
//                                                        |3) WAIT STATE: wait for half of the baud rate period
//                                                        |4) RECV BIT STATE: receive bits from the data line in the buffer
//                                                        |5) END BIT STATE: check for the ending bit
// ********************************************************************************************************************************

always @(data_line or half_period_flag)begin
    // DEFAULT VALUES
    half_period_counter_enable = half_period_counter_enable;
    next_state = next_state;
    inc = inc;
    bit_reset = bit_reset;
    valid_data = valid_data;
    // RX FSM
    casex(state)
        IDEL_STATE: begin
            if(!data_line)begin 
                half_period_counter_enable = 0;
                next_state = START_BIT_STATE;
            end 
        end
        START_BIT_STATE: begin
            if(half_period_flag) begin
                if(!data_line)begin
                    next_state = WAITE_STATE;
                end else begin
                    next_state = IDEL_STATE;
                end 
            end 
        end
        WAITE_STATE: begin
            if(half_period_flag) begin
                casex(previous_state)
                    START_BIT_STATE: next_state = RECV_STATE; 
                    RECV_STATE: begin
                        if(buffer_bit_count == 8)begin
                            next_state = END_BIT_STATE;
                            inc = 0;
                            bit_reset = 0;
                        end else next_state = RECV_STATE;
                    end
                endcase
            end
        end
        RECV_STATE: begin
            if(half_period_flag) begin
                next_state = WAITE_STATE;
                inc = 1;
            end
        end
        END_BIT_STATE: begin
            if(half_period_flag) begin
                next_state = IDEL_STATE;
                if(data_line) valid_data = 1;
                else valid_data = 0;
            end
        end
        default: begin
            next_state = IDEL_STATE;
            inc = 0;
            bit_reset = 1;
            half_period_counter_enable = 1;
            valid_data = 0;
        end 
    endcase
end

always @(negedge reset)begin
    // Reset all MEMORY ELEMENTS
    previous_state <= IDEL_STATE;
    state <= IDEL_STATE;
    buffer <= 8'h00;
    read_buffer <= 8'h00;
    // Reset Combinational Circuit Nets
    reset_half_period_counter = 1'b1;
    inc = 0;
    bit_reset = 1;
    next_state = IDEL_STATE;
    half_period_counter_enable = 1'b1;
    valid_data = 1'b0;
end

endmodule