class vseqr_c extends uvm_sequencer;
  `uvm_component_utils(vseqr_c)

  virtual interface adder_if adder_vif;
  adder_sequencer_c adder_seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), $sformatf("connect_phase() starts.."), UVM_LOW)

    if (!uvm_config_db#(virtual adder_if)::get(this, "", "adder_vif", adder_vif)) begin
      `uvm_fatal(get_type_name(), {"virtual interface must be set for: ", get_full_name(), ".adder_vif"})
    end

    `uvm_info(get_type_name(), $sformatf("connect_phase() ends.."), UVM_LOW)
  endfunction

endclass
