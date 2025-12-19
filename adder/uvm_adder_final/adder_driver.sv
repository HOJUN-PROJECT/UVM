class adder_driver_c extends uvm_driver#(adder_drv_pkt_c);
  `uvm_component_utils(adder_driver_c)

  virtual interface adder_if adder_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), $sformatf("build_phase() starts.."), UVM_LOW)

    if (!uvm_config_db#(virtual adder_if)::get(this, "", "adder_vif", adder_vif)) begin
      `uvm_fatal(get_type_name(), {"virtual interface must be set for: ", get_full_name(), ".adder_vif"})
    end

    `uvm_info(get_type_name(), $sformatf("build_phase() ends.."), UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    @(negedge adder_vif.i_rstn);
    reset_signals();
    forever begin
      @(posedge adder_vif.i_rstn);
      while (adder_vif.i_rstn) begin
        drive_signals();
      end
      reset_signals();
    end
  endtask

  virtual task reset_signals();
    `uvm_info(get_type_name(), $sformatf("reset_signals starts.."), UVM_MEDIUM)
    adder_vif.i_enable  = 0 ;
    adder_vif.i_a       = 0 ;
    adder_vif.i_b       = 0 ;
    adder_vif.i_cin     = 0 ;
    `uvm_info(get_type_name(), $sformatf("reset_signals ends.."), UVM_MEDIUM)
  endtask

  virtual task drive_signals();
    `uvm_info(get_type_name(), $sformatf("drive_signals starts.."), UVM_MEDIUM)
    seq_item_port.get_next_item(req);

    @(posedge adder_vif.i_clk);
    adder_vif.i_enable  = req.i_enable  ;
    adder_vif.i_a       = req.i_a       ;
    adder_vif.i_b       = req.i_b       ;
    adder_vif.i_cin     = req.i_cin     ;

    seq_item_port.item_done();
    `uvm_info(get_type_name(), $sformatf("drive_signals ends.."), UVM_MEDIUM)
  endtask

endclass
