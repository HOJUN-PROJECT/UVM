class adder_agent_c extends uvm_agent;
  `uvm_component_utils_begin(adder_agent_c)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_component_utils_end

  adder_sequencer_c adder_sequencer ;
  adder_driver_c    adder_driver    ;
  adder_monitor_c   adder_monitor   ;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), $sformatf("build_phase() starts.."), UVM_LOW)

    if(!uvm_config_db#(uvm_active_passive_enum)::get(this,"","is_active",is_active))
      `uvm_error(get_full_name(), "is_active not configured");

    if (is_active == UVM_ACTIVE) begin
      `uvm_info(get_type_name(), $sformatf("is_active = UVM_ACTIVE"), UVM_LOW)
      adder_sequencer = adder_sequencer_c::type_id::create("adder_sequencer", this);
      adder_driver = adder_driver_c::type_id::create("adder_driver", this);
    end
    adder_monitor = adder_monitor_c::type_id::create("adder_monitor", this);

    `uvm_info(get_type_name(), $sformatf("build_phase() ends.."), UVM_LOW)
  endfunction

  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);

    if (is_active == UVM_ACTIVE) begin
      adder_driver.seq_item_port.connect(adder_sequencer.seq_item_export);
    end
  endfunction

endclass
