// =============================================================================
// fifo_monitor.sv — UVM Monitor
// =============================================================================
// Passively observes DUT every clock and broadcasts transactions via TLM.
// Never drives signals — read-only.
// =============================================================================
`ifndef FIFO_MONITOR_SV
`define FIFO_MONITOR_SV

class fifo_monitor extends uvm_monitor;

    `uvm_component_utils(fifo_monitor)

    virtual fifo_if #(.DATA_WIDTH(8)) vif;

    // Broadcasts observed transactions to scoreboard and coverage
    uvm_analysis_port #(fifo_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "fifo_monitor: virtual interface not found in config_db")
    endfunction

    task run_phase(uvm_phase phase);
        fifo_seq_item item;
        @(posedge vif.clk);
        wait(vif.rst_n === 1'b1);

        forever begin
            @(vif.monitor_cb);  // sample at every rising edge

            item = fifo_seq_item::type_id::create("mon_item");
            item.wr_en = vif.monitor_cb.wr_en;
            item.rd_en  = vif.monitor_cb.rd_en;
            item.din    = vif.monitor_cb.din;
            item.dout   = vif.monitor_cb.dout;
            item.full   = vif.monitor_cb.full;
            item.empty  = vif.monitor_cb.empty;

            `uvm_info("MON", $sformatf("Observed: %s", item.convert2string()), UVM_HIGH)
            ap.write(item);  // broadcast to scoreboard + coverage
        end
    endtask

endclass : fifo_monitor

`endif
