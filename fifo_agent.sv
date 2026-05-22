// =============================================================================
// fifo_agent.sv — UVM Agent
// =============================================================================
// Bundles sequencer, driver, and monitor.
// ACTIVE mode: drives + monitors. PASSIVE mode: monitors only.
// =============================================================================
`ifndef FIFO_AGENT_SV
`define FIFO_AGENT_SV

class fifo_agent extends uvm_agent;

    `uvm_component_utils(fifo_agent)

    uvm_sequencer #(fifo_seq_item) sequencer;
    fifo_driver                     driver;
    fifo_monitor                    monitor;

    // Forwarded analysis port — env connects this to scoreboard + coverage
    uvm_analysis_port #(fifo_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap      = new("ap", this);
        monitor = fifo_monitor::type_id::create("monitor", this);

        if (get_is_active() == UVM_ACTIVE) begin
            sequencer = uvm_sequencer #(fifo_seq_item)::type_id::create("sequencer", this);
            driver    = fifo_driver::type_id::create("driver", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if (get_is_active() == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
        monitor.ap.connect(ap);  // forward monitor port to agent boundary
    endfunction

endclass : fifo_agent

`endif
