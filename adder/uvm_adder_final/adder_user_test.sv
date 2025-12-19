class adder_user_test_c extends base_test_c;
  `uvm_component_utils(adder_user_test_c)

  function new (string name="adder_user_test_c", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.vseqr.run_phase", "default_sequence", adder_user::type_id::get());
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    uvm_top.print_topology();
  endfunction

endclass: adder_user_test_c



class adder_user extends base_vseq_c;
  `uvm_object_utils(adder_user)

  adder_vseq_c    adder_vseq;

  function new (string name = "adder_user");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("-----------------------------"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("----Start adder_user_test----"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("-----------------------------"), UVM_LOW)

    @(posedge p_sequencer.adder_vif.i_rstn);
    `uvm_info(get_type_name(), $sformatf("Reset ended"), UVM_LOW)

    `uvm_do_on_with(adder_vseq, p_sequencer.adder_seqr,
                    {
                      adder_user_mode   == 1    ;
                      adder_user_a      == 1023 ;
                      adder_user_b      == 1023 ;
                      adder_user_cin    == 1    ;
                    })

    repeat(4) @(posedge p_sequencer.adder_vif.i_clk);
    `uvm_info(get_type_name(), $sformatf("-------------------------------"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("-----------TEST DONE-----------"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("-------------------------------"), UVM_LOW)
  endtask

endclass: adder_user
