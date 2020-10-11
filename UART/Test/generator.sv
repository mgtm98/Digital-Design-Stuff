`ifndef _UART_RX_GENERATOR_
`define _UART_RX_GENERATOR_

`include "frame.sv"

class UartRXFrameGenerator;

    UartRXFrameMBX driver_mb;

    function new(ref UartRXFrameMBX dr_mb);
        this.driver_mb = dr_mb;
    endfunction

    task run(int no_tests = 10);
        for(int i = 0; i < no_tests; i = i + 1)begin
            UartRXFrame frame = new();
            frame.randomize();
            frame.print();
            this.driver_mb.put(frame);
        end
    endtask

endclass

`endif