// =============================================================================
// fifo_env.sv — UVM Environment
// =============================================================================
// Instantiates agent, scoreboard, coverage. Wires them via TLM analysis ports.
// =============================================================================
`ifndef FIFO_ENV_SV
`define FIFO_ENV_SV

class fifo_env extends uvm_env;

    `uvm_component_utils(fifo_env)

    fifo_agent      agent;
    fifo_scoreboard scoreboard;
    fifo_coverage   coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = fifo_agent::type_id::create("agent", this);
        scoreboard = fifo_scoreboard::type_id::create("scoreboard", this);
        coverage   = fifo_coverage::type_id::create("coverage", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        // One analysis port → two subscribers (scoreboard + coverage)
        agent.ap.connect(scoreboard.analysis_export);
        agent.ap.connect(coverage.analysis_export);
    endfunction

endclass : fifo_env

`endif
