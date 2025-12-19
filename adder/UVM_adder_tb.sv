`include "uvm_macros.svh"
import uvm_pkg::*;

interface adder_intf ();
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;
endinterface

class adder_seq_item extends uvm_sequence_item;
    rand bit [7:0] a;
    rand bit [7:0] b;
    bit [8:0] y;

    function new(string name = "ADDER_ITEM");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(adder_seq_item)
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end
endclass

class adder_sequence extends uvm_sequence #(adder_seq_item);
    `uvm_object_utils(adder_sequence)
    function new(string name = "SEQ");
        super.new(name);
    endfunction
    adder_seq_item adder_item;

    virtual task body();
        adder_item = adder_seq_item::type_id::create("ADDER_ITEM");
        for (int i = 0; i < 100; i++) begin
            start_item(adder_item);
            adder_item.randomize();
            `uvm_info(
                "SEQ", $sformatf(
                "adder item to driver a:%d, b:%d", adder_item.a, adder_item.b),
                UVM_NONE);
            finish_item(adder_item);
        end
    endtask
endclass

class adder_monitor extends uvm_monitor;
    `uvm_component_utils(adder_monitor)  // factory 등록

    uvm_analysis_port #(adder_seq_item) send;
    function new(string name = "MON", uvm_component parent);
        super.new(name, parent);
        send = new("WRITE", this);
    endfunction

    adder_seq_item adder_item;
    virtual adder_intf adder_if;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_item = adder_seq_item::type_id::create("ADDER_ITEM", this);
        if (!uvm_config_db#(virtual adder_intf)::get(
                this, "", "adder_if", adder_if
            ))
            `uvm_fatal("MON", "adder_if not found in uvm_config_db");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            #10;
            adder_item.a = adder_if.a;
            adder_item.b = adder_if.b;
            adder_item.y = adder_if.y;
            `uvm_info("MON", $sformatf(
                      "sampled a:%d, b:%d, y:%d",
                      adder_item.a,
                      adder_item.b,
                      adder_item.y
                      ), UVM_LOW);
            send.write(adder_item);
        end
    endtask
endclass
class adder_driver extends uvm_driver #(adder_seq_item);
    `uvm_component_utils(adder_driver)  // factory 등록

    function new(string name = "DRV", uvm_component parent);
        super.new(name, parent);
    endfunction

    adder_seq_item adder_item;
    virtual adder_intf adder_if;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_item = adder_seq_item::type_id::create("ADDER_ITEM", this);
        if (!uvm_config_db#(virtual adder_intf)::get(
                this, "", "adder_if", adder_if
            ))
            `uvm_fatal("DRV", "adder_if not found in uvm_config_db");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(adder_item);
            adder_if.a <= adder_item.a;
            adder_if.b <= adder_item.b;
            `uvm_info("DRV", $sformatf(
                      "Driver DUT a:%d, b:%d", adder_item.a, adder_item.b),
                      UVM_LOW);
            #10;
            seq_item_port.item_done();
        end
    endtask
endclass


class adder_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(adder_scoreboard)  // factory 등록
    uvm_analysis_imp #(adder_seq_item, adder_scoreboard) recv;

    adder_seq_item adder_item;

    function new(string name = "SCB", uvm_component parent);
        super.new(name, parent);
        recv = new("READ", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_item = adder_seq_item::type_id::create("ADDER_ITEM", this);
    endfunction

    virtual function void write(adder_seq_item item);
        adder_item = item;
        `uvm_info("SCB", $sformatf(
                  "Received a: %d, b:%d, y:%d", item.a, item.b, item.y),
                  UVM_LOW);

        adder_item.print(uvm_default_line_printer);

        if (adder_item.y == (adder_item.a + adder_item.b))
            `uvm_info("SCB", "*** TEST PASSED ***", UVM_NONE)
        else `uvm_error("SCB", "*** TEST FAILED ***");
    endfunction
endclass


class adder_agent extends uvm_agent;
    `uvm_component_utils(adder_agent)

    function new(string name = "AGENT", uvm_component parent);
        super.new(name, parent);
    endfunction

    adder_monitor adder_mon;
    adder_driver adder_drv;
    uvm_sequencer #(adder_seq_item) adder_sqr;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_mon = adder_monitor::type_id::create("MON", this);
        adder_drv = adder_driver::type_id::create("DRV", this);
        adder_sqr =
            uvm_sequencer#(adder_seq_item)::type_id::create("SQR", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        adder_drv.seq_item_port.connect(adder_sqr.seq_item_export);
    endfunction
endclass

class adder_environment extends uvm_env;
    `uvm_component_utils(adder_environment)

    function new(string name = "ENV", uvm_component parent);
        super.new(name, parent);
    endfunction

    adder_scoreboard adder_scb;
    adder_agent adder_agt;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_scb = adder_scoreboard::type_id::create("SCB", this);
        adder_agt = adder_agent::type_id::create("AGENT", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        adder_agt.adder_mon.send.connect(adder_scb.recv);
    endfunction
endclass

class test extends uvm_test;
    `uvm_component_utils(test)

    function new(string name = "TEST", uvm_component parent);
        super.new(name, parent);
    endfunction

    adder_environment adder_env;
    adder_sequence    adder_seq;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_env = adder_environment::type_id::create("ENV", this);
        adder_seq = adder_sequence::type_id::create("SEQ", this);
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_root::get().print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        adder_seq.start(adder_env.adder_agt.adder_sqr);
        phase.drop_objection(this);
    endtask
endclass 

module tb_adder ();
    test t;
    adder_intf adder_if ();

    adder dut (
        .a(adder_if.a),
        .b(adder_if.b),
        .y(adder_if.y)
    );

    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0);

        uvm_config_db#(virtual adder_intf)::set(null, "*", "adder_if",
                                                adder_if);
        run_test("test");
    end
endmodule
