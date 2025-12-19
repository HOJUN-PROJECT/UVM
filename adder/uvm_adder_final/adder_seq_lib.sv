class adder_base_seq_c extends uvm_sequence#(adder_drv_pkt_c);
  `uvm_object_utils(adder_base_seq_c)

  adder_seq_item_c rnd_item;

  function new (string name = "adder_base_seq_c");
    super.new(name);
    rnd_item = new();
  endfunction

  task send_signal();
    `uvm_info(get_type_name(), $sformatf("send_signal starts.."), UVM_MEDIUM)
    `uvm_create(req);
    req.i_enable    = rnd_item.i_enable ;
    req.i_a         = rnd_item.i_a      ;
    req.i_b         = rnd_item.i_b      ;
    req.i_cin       = rnd_item.i_cin    ;
    `uvm_send(req);
    `uvm_info(get_type_name(), $sformatf("send_signal ends.."), UVM_MEDIUM)
  endtask

  task send_init(input int size=1);
    for (int i=1; i<=size; i++) begin
      rnd_item.i_enable   = 0 ;
      rnd_item.i_a        = 0 ;
      rnd_item.i_b        = 0 ;
      rnd_item.i_cin      = 0 ;
      send_signal();
    end
  endtask

endclass



class adder_rand_seq_c extends adder_base_seq_c;
  `uvm_object_utils(adder_rand_seq_c)

  function new (string name = "adder_rand_seq_c");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("adder_rand_seq_c starts.."), UVM_LOW)

    send_init(5);
    send_randomize_data(3);
    send_init(2);
    send_randomize_all(6);
    send_init(2);

    `uvm_info(get_type_name(), $sformatf("adder_rand_seq_c ends.."), UVM_LOW)
  endtask

  task send_randomize_all(input int size=1);
    for (int i=1; i<=size; i++) begin
      void'(rnd_item.randomize());
      send_signal();
    end
  endtask

  task send_randomize_data(input int size=1);
    for (int i=1; i<=size; i++) begin
      void'(rnd_item.randomize());
      rnd_item.i_enable = 1;
      rnd_item.i_cin = 0;
      send_signal();
    end
  endtask

endclass : adder_rand_seq_c



class adder_user_seq_c extends adder_base_seq_c;
  `uvm_object_utils(adder_user_seq_c)

  bit [9:0] user_a      ;
  bit [9:0] user_b      ;
  bit       user_cin    ;

  function new (string name = "adder_user_seq_c");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("adder_user_seq_c starts.."), UVM_LOW)

    send_init(5);
    send_user(3);
    send_init(2);
    send_user(6);
    send_init(2);

    `uvm_info(get_type_name(), $sformatf("adder_user_seq_c ends.."), UVM_LOW)
  endtask

  task send_user(input int size=1);
    for (int i=1; i<=size; i++) begin
      rnd_item.i_enable = 1;
      rnd_item.i_a = user_a;
      rnd_item.i_b = user_b;
      rnd_item.i_cin = user_cin;
      send_signal();
    end
  endtask

endclass : adder_user_seq_c
