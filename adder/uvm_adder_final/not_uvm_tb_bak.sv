`timescale 1ns/1ns


module tb_top;
  
  reg nReset;
  reg SystemClock = 0;
  
  reg enable;
  reg [9:0] a;
  reg [9:0] b;
  reg cin;
  
  always #10 SystemClock = ~SystemClock;

  initial begin
    #20 nReset = 0;
    #20 nReset = 1;
  end
  
  
  initial begin
    @(negedge nReset);
    enable	<= 'b0	;
    a		<= 'd0	;
    b		<= 'd0	;
    cin 	<= 'd0	;
    @(posedge nReset);
    repeat(2) @(posedge SystemClock);
    enable	<= 'b1	;
    a		<= 'd28	;
    b		<= 'd33	;
    cin 	<= 'd0	;
    repeat(1) @(posedge SystemClock);
    enable	<= 'b0	;
    a		<= 'd0	;
    b		<= 'd0	;
    cin 	<= 'd0	;
    repeat(4) @(posedge SystemClock);
    enable	<= 'b1	;
    a		<= 'd81	;
    b		<= 'd17	;
    cin 	<= 'd0	;
    repeat(1) @(posedge SystemClock);
    enable	<= 'b0	;
    a		<= 'd0	;
    b		<= 'd0	;
    cin 	<= 'd0	;
    repeat(4) @(posedge SystemClock);
    $finish;
  end
  
  fulladd10_en dut(
    .i_clk		(SystemClock)	,
    .i_rstn		(nReset)		,
    .i_enable	(enable)		,
    .i_a		(a)				,
    .i_b		(b)				,
    .i_cin		(cin)			,
    .o_valid	()				,
    .o_result	()				 
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule
