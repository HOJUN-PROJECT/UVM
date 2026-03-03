// ----------------------------------------------------------------------
//   Copyright 2013 Verilab, Inc.
//   All Rights Reserved Worldwide

//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at

//       http://www.apache.org/licenses/LICENSE-2.0

//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
// ----------------------------------------------------------------------


module top;
   import uvm_pkg::*;
   import pipe_pkg::*;
   
   bit clk;
   bit rst_n;
   
   pipe_if ivif(.clk(clk), .rst_n(rst_n));
   pipe_if ovif(.clk(clk), .rst_n(rst_n));

   
   pipe pipe_top(.clk(clk),
                 .rst_n(rst_n),
                 .i_cf(ivif.cf),
                 .i_en(ivif.enable),
                 .i_data0(ivif.data_in0),
                 .i_data1(ivif.data_in1),
                 .o_data0(ovif.data_out0),
                 .o_data1(ovif.data_out1)
                );

   always #5 clk = ~clk;

   initial begin
       #5 rst_n = 1'b0;
      #10 rst_n = 1'b1;
   end

   assign ovif.enable = ivif.enable;

   initial begin
      uvm_config_db#(virtual pipe_if)::set(uvm_root::get( ) , "*.agent.*" , "in_intf", ivif);
      uvm_config_db#(virtual pipe_if)::set(uvm_root::get( ) , "*.monitor" , "out_intf", ovif);
     run_test("many_random_test");
   end 
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top);
  end


endmodule


// module top;
//   import uvm_pkg::*;
//   import pipe_pkg::*;

//   // 1) 초기값 명시
//   bit clk   = 1'b0;
//   bit rst_n = 1'b0;

//   // 2) 인터페이스 인스턴스
//   pipe_if ivif(.clk(clk), .rst_n(rst_n));
//   pipe_if ovif(.clk(clk), .rst_n(rst_n));

//   // 3) DUT 인스턴스
//   pipe pipe_top(
//     .clk    (clk),
//     .rst_n  (rst_n),
//     .i_cf   (ivif.cf),
//     .i_en   (ivif.enable),
//     .i_data0(ivif.data_in0),
//     .i_data1(ivif.data_in1),
//     .o_data0(ovif.data_out0),
//     .o_data1(ovif.data_out1)
//   );

//   // 4) 클록 (100MHz)
//   always #5 clk = ~clk;

//   // 5) 리셋 시퀀스: assert → deassert
//   initial begin
//     // 시작 시점: rst_n=0 (asserted)
//     $display("[%0t] TOP: reset assert", $time);
//     #30;                 // 30ns 동안 reset 유지 (필요 시 조정)
//     rst_n = 1'b1;       // deassert
//     $display("[%0t] TOP: reset deassert", $time);
//   end

//   // 6) 간단한 연결(동일 enable 전달)
//   assign ovif.enable = ivif.enable;

//   // 7) UVM에 virtual interface 주입
//   initial begin
//     // in_intf → *.agent.* 에 주입
//     uvm_config_db#(virtual pipe_if)::set(uvm_root::get(), "*.agent.*" , "in_intf", ivif);
//     // out_intf → *.monitor 에 주입
//     uvm_config_db#(virtual pipe_if)::set(uvm_root::get(), "*.monitor",  "out_intf", ovif);
//   end

//   // 8) 테스트 실행: +UVM_TESTNAME 없으면 base_test 실행
//   initial begin
//     $display("[%0t] TOP: simulation started", $time);

//     if (!$test$plusargs("UVM_TESTNAME")) begin
//       $display("[%0t] TOP: no +UVM_TESTNAME found → run_test(\"base_test\")", $time);
//       run_test("base_test");
//     end else begin
//       $display("[%0t] TOP: +UVM_TESTNAME detected → run_test() without arg", $time);
//       run_test(); // EDAP Run options에 +UVM_TESTNAME=... 로 지정
//     end
//   end

//   // 9) (선택) 파형 덤프 — EPWave 확인용
//   initial begin
//     $dumpfile("dump.vcd");
//     $dumpvars(0, top);
//   end

//   // 10) 타임아웃 가드 (임시) — 디버깅 편의
//   initial begin
//     #100_000; // 100us (필요 시 조정)
//     $display("[%0t] TOP: timeout reached. Finishing simulation.", $time);
//     $finish;
//   end

// endmodule
