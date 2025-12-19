module top;
  import uvm_pkg::*;
  import adder_pkg::*;

  reg nReset;
  reg SystemClock = 0;
  
  always #10 SystemClock = ~SystemClock;

  initial begin
    #10 nReset = 0;
    #30 nReset = 1;
  end

  fulladd10_en dut();

  `include "intf_insts.sv"
  
  initial begin
    uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.tb.adder_env.adder_agent*", "adder_vif", adder_intf);  
    uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.tb.vseqr*", "adder_vif", adder_intf);
    
    //run_test("adder_rand_test_c");
    run_test("adder_user_test_c");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top);
  end

endmodule
