class lb_ro_base_seq_c extends uvm_sequence#(lb_ro_drv_pkt_c);
  `uvm_object_utils(lb_ro_base_seq_c)

  lb_ro_seq_item_c rnd_item;

  function new (string name = "lb_ro_base_seq_c");
    super.new(name);
    rnd_item = new("rnd_item");
  endfunction
endclass

class lb_ro_user_seq_c extends lb_ro_base_seq_c;
  `uvm_object_utils(lb_ro_user_seq_c)

  data_mode_e              data_mode       ; 
  bit  [`RGB_WIDTH-1:0]    fix_r_data      ;
  bit  [`RGB_WIDTH-1:0]    fix_g_data      ;
  bit  [`RGB_WIDTH-1:0]    fix_b_data      ;

  function new (string name = "lb_ro_user_seq_c");
    super.new(name);
  endfunction

  virtual task body();
    int total_lines;
    int total_pixels;
    int r_cnt, g_cnt, b_cnt;
    bit in_v_active, in_h_active;
    bit active_video;
    bit [`VER_WIDTH-1:0]  cfg_vsw  = rnd_item.i_vsw;
    bit [`VER_WIDTH-1:0]  cfg_vbp  = rnd_item.i_vbp;
    bit [`VER_WIDTH-1:0]  cfg_vact = rnd_item.i_vact;
    bit [`VER_WIDTH-1:0]  cfg_vfp  = rnd_item.i_vfp;
    
    bit [`HOR_WIDTH-1:0]  cfg_hsw  = rnd_item.i_hsw;
    bit [`HOR_WIDTH-1:0]  cfg_hbp  = rnd_item.i_hbp;
    bit [`HOR_WIDTH-1:0]  cfg_hact = rnd_item.i_hact;
    bit [`HOR_WIDTH-1:0]  cfg_hfp  = rnd_item.i_hfp;

    `uvm_info(get_type_name(), "Sequence Generation Starts (using rnd_item config)...", UVM_LOW)
    total_lines  = cfg_vsw + cfg_vbp + cfg_vact + cfg_vfp;
    total_pixels = cfg_hsw + cfg_hbp + cfg_hact + cfg_hfp;
    r_cnt = 0; g_cnt = 0; b_cnt = 0;

    for (int y = 0; y < total_lines; y++) begin
      for (int x = 0; x < total_pixels; x++) begin
        req = lb_ro_drv_pkt_c::type_id::create("req");
        start_item(req);

        req.i_bypass     = rnd_item.i_bypass;
        req.i_offset_val = rnd_item.i_offset_val;
        req.i_vsw  = cfg_vsw;  req.i_vbp  = cfg_vbp;
        req.i_vact = cfg_vact; req.i_vfp  = cfg_vfp;
        req.i_hsw  = cfg_hsw;  req.i_hbp  = cfg_hbp;
        req.i_hact = cfg_hact; req.i_hfp  = cfg_hfp;

        req.i_vsync = (y < cfg_vsw) ? 1'b1 : 1'b0;
        req.i_hsync = (x < cfg_hsw) ? 1'b1 : 1'b0;
        in_v_active = (y >= (cfg_vsw + cfg_vbp)) && (y < (cfg_vsw + cfg_vbp + cfg_vact));
        in_h_active = (x >= (cfg_hsw + cfg_hbp)) && (x < (cfg_hsw + cfg_hbp + cfg_hact));
        active_video = in_v_active && in_h_active;

        req.i_de = active_video;

        if (active_video) begin
          case (data_mode)
            FIX: begin
              req.i_r_data = fix_r_data;
              req.i_g_data = fix_g_data;
              req.i_b_data = fix_b_data;
            end
            INCREASE: begin
              req.i_r_data = r_cnt;
              req.i_g_data = g_cnt;
              req.i_b_data = b_cnt;
              
              r_cnt = (r_cnt == 1023) ? 0 : r_cnt + 1;
              g_cnt = (g_cnt == 1023) ? 0 : g_cnt + 1;
              b_cnt = (b_cnt == 1023) ? 0 : b_cnt + 1;
            end
            RANDOM: begin
             void'(rnd_item.randomize() with {
                  i_r_data inside {[0:1023]};
                  i_g_data inside {[0:1023]};
                  i_b_data inside {[0:1023]};
                });
                req.i_r_data = rnd_item.i_r_data;
                req.i_g_data = rnd_item.i_g_data;
                req.i_b_data = rnd_item.i_b_data;
              end
          endcase
        end else begin
          req.i_r_data = 0; req.i_g_data = 0; req.i_b_data = 0;
        end

        finish_item(req);
      end
    end
    `uvm_info(get_type_name(), "Sequence Generation Done.", UVM_LOW)
  endtask
endclass
