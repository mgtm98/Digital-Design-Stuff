module UARTRXControl(
    output reg buffer_valid,
    output reg buffer_enable,
    output reg buffer_rst,
    output reg parity_enable,
    output reg parity_rst,
    output reg half_prtiod_counter_enable,
    output reg half_period_counter_rst,
    output reg bit_counter_enable,
    output reg bit_counter_rst,
    input wire clk,
    input wire rst,
    input wire dataline,
    input wire half_period_flag,
    input wire [3:0] bit_count
);
    parameter IDEL_STATE = 3'd0;
    parameter START_BIT_STATE = 3'd1;
    parameter RECV_STATE = 3'd2;
    parameter WAITE_STATE  = 3'd3;
    parameter PARITY_CHECK_STATE  = 3'd4;
    parameter END_BIT_STATE  = 3'd5; 

    reg [2:0] state;
    reg [2:0] state_delayed;
    reg [2:0] previous_state;

    reg [2:0] next_state;
    wire [2:0] previous_state_next;

    always @(negedge clk) begin
        state_delayed <= next_state;
        state <= state_delayed;
        previous_state <= previous_state_next;
    end

    assign previous_state_next = half_period_flag ? state: previous_state;

    always @(dataline or half_period_flag or bit_count or state)begin
        // Default Values of outputs
        bit_counter_rst = 0;
        parity_rst = 0;
        buffer_valid = 0;
        next_state = next_state;
        half_prtiod_counter_enable = half_prtiod_counter_enable;
        buffer_enable = 0;
        parity_enable = 0;
        bit_counter_enable = 0;
        casex(state)
            IDEL_STATE: begin
                if(!dataline)begin 
                    next_state = START_BIT_STATE;
                    half_prtiod_counter_enable = 1;
                end
            end
            START_BIT_STATE: begin
                if(half_period_flag) begin
                    if(!dataline)next_state = WAITE_STATE;
                    else next_state = IDEL_STATE;
                end 
            end
            WAITE_STATE: begin
                if(half_period_flag) begin
                    casex(previous_state)
                        START_BIT_STATE: next_state = RECV_STATE;
                        PARITY_CHECK_STATE: next_state = END_BIT_STATE;
                        RECV_STATE: begin
                            if(bit_count == 8) next_state = PARITY_CHECK_STATE;
                            else next_state = RECV_STATE;
                        end
                    endcase
                end
            end
            RECV_STATE: begin
                if(half_period_flag)begin 
                    buffer_enable = 1;
                    parity_enable = 1;
                    bit_counter_enable = 1;
                    next_state = WAITE_STATE;
                end
            end
            PARITY_CHECK_STATE: begin
                if(half_period_flag) begin
                    parity_enable = 1;
                    next_state = WAITE_STATE;
                    bit_counter_enable = 1;
                end
            end
            END_BIT_STATE: begin
                if(half_period_flag)begin
                    if(dataline) buffer_valid = 1;
                    next_state = IDEL_STATE;
                    bit_counter_rst = 1;
                    parity_rst = 1;
                end
            end
        endcase

    end

    always @(rst)begin
        if(rst)begin
            buffer_valid = 0;
            buffer_enable = 0;
            buffer_rst = 0;
            parity_rst = 0;
            half_prtiod_counter_enable = 0;
            half_period_counter_rst = 0;
            bit_counter_enable = 0;
            bit_counter_rst = 0;
            next_state = IDEL_STATE;
        end
    end

endmodule