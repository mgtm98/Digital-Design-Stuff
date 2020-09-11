`ifndef _EDGE_DETECTOR_
`define _EDGE_DETECTOR_

module PosEdgeDetector(
    input wire clk,
    input wire signal,
    output wire detect
);

reg last_signal;
assign detect = signal & !last_signal;
always @(posedge clk) last_signal <= signal;

endmodule

module NegEdgeDetector(
    input wire clk,
    input wire signal,
    output wire detect
);

reg last_signal;
assign detect = !signal & last_signal;
always @(posedge clk) last_signal <= signal;

endmodule

`endif