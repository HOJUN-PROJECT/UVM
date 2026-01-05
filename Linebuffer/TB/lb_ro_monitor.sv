class lb_ro_monitor_c extends uvm_monitor;
  `uvm_component_utils(lb_ro_monitor_c)
  
  uvm_analysis_port#(lb_ro_mon_pkt_c) in_data_port;
  uvm_analysis_port#(lb_ro_mon_pkt_c) out_data_port;
  
  virtual interface lb_ro_if lb_ro_vif;
  lb_ro_mon_pkt_c in_pkt;
  lb_ro_mon_pkt_c out_pkt;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_data_port = new("in_data_port", this);
    out_data_port = new("out_data_port", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase (phase);
    if (!uvm_config_db#(virtual lb_ro_if) :: get(this, "", "lb_ro_vif", lb_ro_vif)) begin
      `uvm_fatal(get_type_name(), {"virtual interface must be set for: ", get_full_name(), ". lb_ro_vif"})
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      forever begin
        @(posedge lb_ro_vif.i_clk iff lb_ro_vif.i_rstn);
        in_data();
      end
      forever begin
        @(posedge lb_ro_vif.i_clk iff lb_ro_vif.i_rstn);
        out_valid_data();
      end
    join_none	
  endtask
    
  task in_data();
    if (lb_ro_vif.i_de) begin
        in_pkt = lb_ro_mon_pkt_c::type_id::create("in_pkt", this);
        
        in_pkt.i_de         = 1'b1;
     
        in_pkt.i_bypass     = lb_ro_vif.i_bypass;
        in_pkt.i_offset_val = lb_ro_vif.i_offset_val;
        in_pkt.i_hact       = lb_ro_vif.i_hact; 

        in_pkt.i_r_data = lb_ro_vif.i_r_data;
        in_pkt.i_g_data = lb_ro_vif.i_g_data;
        in_pkt.i_b_data = lb_ro_vif.i_b_data;
        
        in_data_port.write(in_pkt);
    end
  endtask : in_data

  task out_valid_data();
    if (lb_ro_vif.o_de) begin
        out_pkt = lb_ro_mon_pkt_c::type_id::create("out_pkt", this);
        out_pkt.o_de = 1'b1;
        out_pkt.o_r_data = lb_ro_vif.o_r_data;
        out_pkt.o_g_data = lb_ro_vif.o_g_data;
        out_pkt.o_b_data = lb_ro_vif.o_b_data;
        out_data_port.write(out_pkt);
    end
  endtask : out_valid_data

endclass
