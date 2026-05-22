// =============================================================================
// fifo_coverage.sv — Functional Coverage Collector
// =============================================================================
`ifndef FIFO_COVERAGE_SV
`define FIFO_COVERAGE_SV

class fifo_coverage extends uvm_subscriber #(fifo_seq_item);

    `uvm_component_utils(fifo_coverage)

    fifo_seq_item item;

    covergroup fifo_cg;
        cp_wr_en: coverpoint item.wr_en {
            bins write_active = {1};
            bins write_idle   = {0};
        }
        cp_rd_en: coverpoint item.rd_en {
            bins read_active = {1};
            bins read_idle   = {0};
        }
        cp_full: coverpoint item.full {
            bins fifo_full     = {1};
            bins fifo_not_full = {0};
        }
        cp_empty: coverpoint item.empty {
            bins fifo_empty     = {1};
            bins fifo_not_empty = {0};
        }
        // Cross coverage: hit write-while-full and read-while-empty
        cx_wr_full:  cross cp_wr_en, cp_full;
        cx_rd_empty: cross cp_rd_en, cp_empty;
        // Data range coverage
        cp_din: coverpoint item.din {
            bins low_vals  = {[8'h00 : 8'h3F]};
            bins mid_vals  = {[8'h40 : 8'hBF]};
            bins high_vals = {[8'hC0 : 8'hFF]};
        }
    endgroup : fifo_cg

    function new(string name, uvm_component parent);
        super.new(name, parent);
        fifo_cg = new();
    endfunction

    function void write(fifo_seq_item t);
        item = t;
        fifo_cg.sample();
    endfunction

endclass : fifo_coverage

`endif
