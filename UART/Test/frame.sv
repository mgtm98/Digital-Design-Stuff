`ifndef _UART_RX_FRAME_
`define _UART_RX_FRAME_

class UartRXFrame;
    rand bit [7:0] data;
    rand bit parity;

    constraint parity_bit_value{
        parity == ^data;
    };

    static function UartRXFrame buildFrame(bit [7:0] data);
        UartRXFrame frame = new();
        frame.data = data;
        return frame;
    endfunction
    
    static function bit compare(ref UartRXFrame frame1, ref UartRXFrame frame2);
        return frame1.data & frame2.data;
    endfunction

    function void print();
        $display("[Time %0t] New frame object: data=%b parity=%b", $time, this.data, this.parity);
    endfunction

endclass

typedef mailbox#(UartRXFrame) UartRXFrameMBX;

`endif