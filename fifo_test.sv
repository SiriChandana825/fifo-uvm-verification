// =============================================================================
// fifo_test.sv — UVM Test Classes
// =============================================================================
`ifndef FIFO_TEST_SV
`define FIFO_TEST_SV

// Base test — builds env, shared setup
class fifo_base_test extends uvm_test;
    `uvm_component_utils(fifo_base_test)
    fifo_env env;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();  // prints full TB hierarchy — useful for debug
    endfunction
endclass

// Random test — 100 constrained-random transactions
class fifo_rand_test extends fifo_base_test;
    `uvm_component_utils(fifo_rand_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    task run_phase(uvm_phase phase);
        fifo_rand_seq seq = fifo_rand_seq::type_id::create("seq");
        phase.raise_objection(this);
        seq.num_txns = 100;
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

// Corner-case test — fill to full, drain to empty
class fifo_corner_test extends fifo_base_test;
    `uvm_component_utils(fifo_corner_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    task run_phase(uvm_phase phase);
        fifo_corner_seq seq = fifo_corner_seq::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

`endif
