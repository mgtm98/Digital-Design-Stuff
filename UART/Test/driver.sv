`ifndef _UART_RX_DRIVER_
`define _UART_RX_DRIVER_

`include "rx_if.sv"
`include "frame.sv"

`define START_BIT   0
`define END_BIT     1

class UartRxDriver;;
    virtual RX_IF.Driver driver_if;
    int baudrate;
    int clk_period;
    UartRXFrameMBX input_scoreboard;
    UartRXFrameMBX mbx = new();

    function new(virtual RX_IF.Driver driver_if, UartRXFrameMBX input_scoreboard, int baudrate,int clk_period);
        this.input_scoreboard = input_scoreboard;
        this.driver_if = driver_if;
        this.baudrate = baudrate;
        this.clk_period = clk_period;
    endfunction

    task run();
        this.driver_if.baudrate = this.baudrate;
        this.reset();
        while(this.mbx.num())begin
			UartRXFrame frame;
			this.mbx.get(frame);
            this.input_scoreboard.put(frame);
			$display("[Time %0t] Driver: Sending frame data:%b parity:%b", $time, frame.data, frame.parity);			
            this.send_frame(frame);            
        end
    endtask

    task reset();
        this.driver_if.rst = 0;
        this.driver_if.dataline = 1;
        #this.clk_period;
        this.driver_if.rst = 1;
        #this.clk_period;
        this.driver_if.rst = 0;
    endtask

    task send_frame(UartRXFrame frame);
        this.send_bit(`START_BIT);
        this.send_bit(frame.data[0]);
        this.send_bit(frame.data[1]);
        this.send_bit(frame.data[2]);
        this.send_bit(frame.data[3]);
        this.send_bit(frame.data[4]);
        this.send_bit(frame.data[5]);
        this.send_bit(frame.data[6]);
        this.send_bit(frame.data[7]);
		this.send_bit(frame.parity);
        this.send_bit(`END_BIT);
    endtask

    task send_bit(bit data);
        this.driver_if.dataline = data;
        #(this.baudrate*this.clk_period);
    endtask

endclass

`endif