class adder_vseq_c extends uvm_sequence;
  `uvm_object_utils(adder_vseq_c)

  adder_rand_seq_c  adder_rand_seq  ;
  adder_user_seq_c  adder_user_seq  ;

  rand bit          adder_user_mode ;
  rand bit [9:0]    adder_user_a    ;
  rand bit [9:0]    adder_user_b    ;
  rand bit          adder_user_cin  ;

  constraint adder_mode_set_default {
    soft adder_user_mode    == 0    ;
    soft adder_user_a       == 0    ;
    soft adder_user_b       == 0    ;
    soft adder_user_cin     == 0    ;
  }

  function new(string name = "adder_vseq_c");
    super.new(name);
    adder_rand_seq = adder_rand_seq_c::type_id::create("adder_rand_seq");
    adder_user_seq = adder_user_seq_c::type_id::create("adder_user_seq");
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), $psprintf("adder_vseq_c starts.."), UVM_LOW)

    if (adder_user_mode) begin
      adder_user_seq.user_a     = adder_user_a      ;
      adder_user_seq.user_b     = adder_user_b      ;
      adder_user_seq.user_cin   = adder_user_cin    ;
      `uvm_send(adder_user_seq)
    end
    else begin
      `uvm_send(adder_rand_seq)
    end
  endtask

endclass: adder_vseq_c
