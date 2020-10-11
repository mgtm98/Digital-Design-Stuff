`include "rx_if.sv"
`include "frame.sv"

class UartRXMonitor;
    virtual RX_IF.Monitor monitor_if;
    UartRXFrameMBX scoreboard_outputMBX;

    function new(virtual RX_IF.Monitor monitor_if, ref UartRXFrameMBX scoreboard_outputMBX);
        this.monitor_if = monitor_if;
        this.scoreboard_outputMBX = scoreboard_outputMBX;
    endfunction

    task run();
        $display("[Time %0t] Starting output monitor", $time);
        forever begin @(this.monitor_if.data);
            this.scoreboard_outputMBX.put(UartRXFrame::buildFrame(this.monitor_if.data));
        end
    endtask

endclass    