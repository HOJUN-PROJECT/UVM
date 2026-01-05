import "DPI-C" context function int unsigned addFunc(int unsigned a, int unsigned b);

`uvm_analysis_imp_decl(_in_lb_ro)
`uvm_analysis_imp_decl(_out_lb_ro)

class lb_ro_sb_c extends uvm_scoreboard;
  `uvm_component_utils(lb_ro_sb_c)

  typedef struct packed {
    bit [9:0] r;
    bit [9:0] g;
    bit [9:0] b;
  } rgb_t;

  typedef struct packed {
    rgb_t     rgb;
    bit       bypass;
    bit [9:0] offset;
  } in_rec_t;


  uvm_analysis_imp_in_lb_ro#(lb_ro_mon_pkt_c, lb_ro_sb_c)  in_lb_ro_imp_port;
  uvm_analysis_imp_out_lb_ro#(lb_ro_mon_pkt_c, lb_ro_sb_c) out_lb_ro_imp_port;

  int match_cnt;
  int mismatch_cnt;
  localparam int LATENCY = 2;

  in_rec_t in_pipe_q[$];   // size <= LATENCY
  in_rec_t in_q[$];
  rgb_t    out_q[$];

  localparam int unsigned MAX10 = 10'h3FF;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_lb_ro_imp_port  = new("in_lb_ro_imp_port", this);
    out_lb_ro_imp_port = new("out_lb_ro_imp_port", this);
  endfunction

  function automatic bit [9:0] clamp10(input int unsigned v);
    return (v > MAX10) ? MAX10[9:0] : v[9:0];
  endfunction

  function automatic rgb_t apply_offset_clamp(
    input rgb_t in_rgb,
    input bit   bypass,
    input bit [9:0] offset
  );
    rgb_t exp;
    int unsigned sum_r, sum_g, sum_b;

    if (bypass) begin
      exp = in_rgb;
    end
    else begin
      sum_r = addFunc(in_rgb.r, offset);
      sum_g = addFunc(in_rgb.g, offset);
      sum_b = addFunc(in_rgb.b, offset);
      exp.r = clamp10(sum_r);
      exp.g = clamp10(sum_g);
      exp.b = clamp10(sum_b);
    end
    return exp;
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    in_pipe_q.delete();
    in_q.delete();
    out_q.delete();

    match_cnt    = 0;
    mismatch_cnt = 0;

    fork
      compare_data();
    join_none
  endtask

  virtual task compare_data();
    in_rec_t rec;
    rgb_t out_rgb, exp_rgb;

    forever begin
      // 둘 다 쌓일 때까지 대기
      wait(in_q.size() > 0 && out_q.size() > 0);

      rec     = in_q.pop_front();
      out_rgb = out_q.pop_front();

      exp_rgb = apply_offset_clamp(rec.rgb, rec.bypass, rec.offset);

      if (out_rgb === exp_rgb) begin
        match_cnt++;
        `uvm_info(get_type_name(),
          $sformatf("[PASS] EXP{R:%0h G:%0h B:%0h} == ACT{R:%0h G:%0h B:%0h} (bypass=%0d offset=%0d)",
                    exp_rgb.r, exp_rgb.g, exp_rgb.b,
                    out_rgb.r, out_rgb.g, out_rgb.b,
                    rec.bypass, rec.offset),
          UVM_LOW)
      end
      else begin
        mismatch_cnt++;
        `uvm_error(get_type_name(),
          $sformatf("\n==================================================\n[FAIL] Data Mismatch!\n--------------------------------------------------\n[IN ] R:0x%0h G:0x%0h B:0x%0h (Offset:%0d Bypass:%0d)\n[EXP] R:0x%0h G:0x%0h B:0x%0h\n[OUT] R:0x%0h G:0x%0h B:0x%0h\n==================================================",
                    rec.rgb.r, rec.rgb.g, rec.rgb.b, rec.offset, rec.bypass,
                    exp_rgb.r, exp_rgb.g, exp_rgb.b,
                    out_rgb.r, out_rgb.g, out_rgb.b))
      end
    end
  endtask

  // =========================
  // Input monitor callback
  // =========================
  virtual function void write_in_lb_ro(lb_ro_mon_pkt_c pkt);
    // 비교는 active 픽셀만 해야 정렬이 깨지지 않습니다.
    if (pkt.i_de) begin
      in_rec_t rec;

      rec.rgb.r  = pkt.i_r_data;
      rec.rgb.g  = pkt.i_g_data;
      rec.rgb.b  = pkt.i_b_data;

      // 픽셀별 cfg 저장 (중간에 바뀌어도 안전)
      rec.bypass = pkt.i_bypass;
      rec.offset = pkt.i_offset_val;

      // LATENCY만큼 밀기
      in_pipe_q.push_back(rec);

      if (in_pipe_q.size() > LATENCY) begin
        in_q.push_back(in_pipe_q.pop_front());
      end
    end
  endfunction

  // =========================
  // Output monitor callback
  // =========================
  virtual function void write_out_lb_ro(lb_ro_mon_pkt_c pkt);
    if (pkt.o_de) begin
      rgb_t t;
      t.r = pkt.o_r_data;
      t.g = pkt.o_g_data;
      t.b = pkt.o_b_data;
      out_q.push_back(t);
    end
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
      $sformatf("MATCH: %0d, MISMATCH: %0d", match_cnt, mismatch_cnt),
      UVM_LOW)
  endfunction

endclass
