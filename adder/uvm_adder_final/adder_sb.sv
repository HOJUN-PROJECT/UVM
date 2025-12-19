import "DPI-C" context function int unsigned addFunc(int unsigned a, int unsigned b, int unsigned c);

`uvm_analysis_imp_decl(_in_adder)
`uvm_analysis_imp_decl(_out_adder)

class adder_sb_c extends uvm_scoreboard;
  `uvm_component_utils(adder_sb_c)

  uvm_analysis_imp_in_adder#(adder_mon_pkt_c, adder_sb_c) in_adder_imp_port;// TLM implementation port
  uvm_analysis_imp_out_adder#(adder_mon_pkt_c, adder_sb_c) out_adder_imp_port;// TLM implementation port

  bit [10:0] c_result_q[$];
  bit [10:0] rtl_result_q[$];
  int match_cnt;
  int mismatch_cnt;

  function new(string name, uvm_component parent);
    super.new(name, parent);

    in_adder_imp_port = new("in_adder_imp_port", this);
    out_adder_imp_port = new("out_adder_imp_port", this);

  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    compare_data();
  endtask

  virtual task compare_data();
    bit [10:0] c_result;
    bit [10:0] rtl_result;
    forever begin
      wait(c_result_q.size() > 0 && rtl_result_q.size() > 0);
      c_result = c_result_q.pop_front();
      rtl_result = rtl_result_q.pop_front();
      if(c_result == rtl_result)begin
        match_cnt++;
        `uvm_info(get_type_name(), $sformatf("DATA MATCH C_RESULT = %0d RTL_RESULT = %0d",c_result,rtl_result), UVM_LOW)
      end
      else begin
        mismatch_cnt++;
        `uvm_error(get_type_name(), $sformatf("DATA MISMATCH C_RESULT = %0d RTL_RESULT = %0d",c_result,rtl_result))
      end
    end
  endtask

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    if (c_result_q.size() != 0 || rtl_result_q.size() != 0) begin
      `uvm_error(get_type_name(), $sformatf("Queues not drained: C=%0d RTL=%0d", c_result_q.size(), rtl_result_q.size()))
    end
    
    `uvm_info(get_type_name(), $sformatf("##########################"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("##### COMPARE RESULT #####"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("##########################"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("     MATCH COUNT = %0d    ",match_cnt), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("    MISMATCH COUNT = %0d  ",mismatch_cnt), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("##########################"), UVM_LOW)
  endfunction: report_phase

  virtual function void write_in_adder (adder_mon_pkt_c pkt);
    if(pkt.i_enable) begin
      int unsigned sum = addFunc(pkt.i_a, pkt.i_b, pkt.i_cin);
      c_result_q.push_back(sum[10:0]);
    end
  endfunction

  virtual function void write_out_adder (adder_mon_pkt_c pkt);
    rtl_result_q.push_back(pkt.o_result);
  endfunction

endclass
