`include "generator.sv"
`include "rx_if.sv"
`include "driver.sv"
`include "monitor.sv"
`include "../Design/RX/rx.v"
`include "scoreboard.sv"

`define BAUDRATE_IN_CLKS  8

module TB_RX;
	
	bit clk;
	RX_IF rx_if(clk);
	
	UartScoreboard scoreboard = new();
	UartRxDriver driver = new(rx_if, scoreboard.inputMBX, `BAUDRATE_IN_CLKS, 10);
	UartRXMonitor monitor = new(rx_if, scoreboard.outputMBX);
	UartRXFrameGenerator generator = new(driver.mbx);
	
	UART_RX rx (
		.data(rx_if.DUT.data),
		.clk(clk),
		.dataline(rx_if.DUT.dataline),
		.baudrate(rx_if.DUT.baudrate),
		.rst(rx_if.DUT.rst)
	);

	initial begin
		fork
			monitor.run();
			generator.run();
			driver.run();
			scoreboard.run();
		join
	end

	always begin
		#5
		clk = ~clk;
	end
	
endmodule