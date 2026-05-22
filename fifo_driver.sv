// =============================================================================
// fifo_driver.sv — UVM Driver
// =============================================================================
// Gets seq_items from sequencer and drives them onto the DUT via clocking block.
// =============================================================================
`ifndef FIFO_DRIVER_SV
`define FIFO_DRIVER_SV

class fifo_driver extends uvm_driver #(fifo_seq_item);

    `uvm_component_utils(fifo_driver)

    virtual fifo_if #(.DATA_WIDTH(8)) vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "fifo_driver: virtual interface not found in config_db")
    endfunction

    task reset_signals();
        vif.driver_cb.wr_en <= 0;
        vif.driver_cb.rd_en  <= 0;
        vif.driver_cb.din    <= 0;
    endtask

    task run_phase(uvm_phase phase);
        fifo_seq_item item;
        reset_signals();
        @(posedge vif.clk);
        wait(vif.rst_n === 1'b1);
        @(vif.driver_cb);

        forever begin
            // 1. Get item from sequencer
            seq_item_port.get_next_item(item);

            // 2. Drive signals through clocking block (avoids race conditions)
            vif.driver_cb.wr_en <= item.wr_en;
            vif.driver_cb.rd_en  <= item.rd_en;
            vif.driver_cb.din    <= item.din;

            // 3. Wait one clock for DUT to respond
            @(vif.driver_cb);

            // 4. Capture outputs back (for debug)
            item.dout  = vif.driver_cb.dout;
            item.full  = vif.driver_cb.full;
            item.empty = vif.driver_cb.empty;

            `uvm_info("DRV", $sformatf("Drove: %s", item.convert2string()), UVM_HIGH)

            // 5. Signal done to sequencer
            seq_item_port.item_done();
        end
    endtask

endclass : fifo_driver

`endif
