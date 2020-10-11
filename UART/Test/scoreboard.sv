`include "frame.sv"

class UartScoreboard;
    UartRXFrameMBX outputMBX = new();
    UartRXFrameMBX inputMBX = new();
    
    task run();
        forever begin
            UartRXFrame frame1;
            UartRXFrame frame2;
            outputMBX.get(frame1);
            inputMBX.get(frame2);
            if(UartRXFrame::compare(frame1, frame2)) $display("[Time %0t] Passed the testcase ", $time);
            else $display("[Time %0t] Failed the testcase ", $time);
        end
    endtask
endclass