// =============================================================================
// fifo_scoreboard.sv — UVM Scoreboard
// =============================================================================
// Maintains a reference model (SV queue) mirroring the DUT.
// Compares every observed output against the reference — flags mismatches.
// =============================================================================
`ifndef FIFO_SCOREBOARD_SV
`define FIFO_SCOREBOARD_SV

class fifo_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) analysis_export;

    // Reference model: SV queue mirrors the DUT FIFO
    parameter int DEPTH = 16;
    logic [7:0] ref_fifo [$];

    int unsigned checks_passed = 0;
    int unsigned checks_failed = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
    endfunction

    // Called every cycle by monitor's analysis port
    function void write(fifo_seq_item item);
        // 1. Update reference model
        if (item.wr_en && (ref_fifo.size() < DEPTH))
            ref_fifo.push_back(item.din);

        // 2. Check read data against reference
        if (item.rd_en && (ref_fifo.size() > 0)) begin
            logic [7:0] expected = ref_fifo.pop_front();
            if (item.dout !== expected) begin
                `uvm_error("SB", $sformatf(
                    "DATA MISMATCH: got=0x%02h expected=0x%02h | %s",
                    item.dout, expected, item.convert2string()))
                checks_failed++;
            end else begin
                `uvm_info("SB", $sformatf("PASS: dout=0x%02h | %s",
                    item.dout, item.convert2string()), UVM_HIGH)
                checks_passed++;
            end
        end

        // 3. Check full/empty flags
        begin
            logic ref_full  = (ref_fifo.size() == DEPTH);
            logic ref_empty = (ref_fifo.size() == 0);

            if (item.full !== ref_full) begin
                `uvm_error("SB", $sformatf(
                    "FULL FLAG MISMATCH: got=%0b expected=%0b", item.full, ref_full))
                checks_failed++;
            end
            if (item.empty !== ref_empty) begin
                `uvm_error("SB", $sformatf(
                    "EMPTY FLAG MISMATCH: got=%0b expected=%0b", item.empty, ref_empty))
                checks_failed++;
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SB", $sformatf(
            "\n========= SCOREBOARD SUMMARY =========\n  PASSED : %0d\n  FAILED : %0d\n======================================",
            checks_passed, checks_failed), UVM_NONE)
        if (checks_failed > 0)
            `uvm_error("SB", "TEST FAILED — see mismatches above")
        else
            `uvm_info("SB", "ALL CHECKS PASSED", UVM_NONE)
    endfunction

endclass : fifo_scoreboard

`endif
