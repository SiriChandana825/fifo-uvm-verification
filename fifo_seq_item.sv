// =============================================================================
// fifo_seq_item.sv — UVM Sequence Item (Transaction)
// =============================================================================
`ifndef FIFO_SEQ_ITEM_SV
`define FIFO_SEQ_ITEM_SV

class fifo_seq_item extends uvm_sequence_item;

    `uvm_object_utils_begin(fifo_seq_item)
        `uvm_field_int(din,   UVM_ALL_ON)
        `uvm_field_int(wr_en, UVM_ALL_ON)
        `uvm_field_int(rd_en, UVM_ALL_ON)
        `uvm_field_int(dout,  UVM_ALL_ON)
        `uvm_field_int(full,  UVM_ALL_ON)
        `uvm_field_int(empty, UVM_ALL_ON)
    `uvm_object_utils_end

    // Stimulus fields (randomized by sequences)
    rand logic [7:0] din;
    rand logic       wr_en;
    rand logic       rd_en;

    // Observed outputs (captured by monitor, not randomized)
    logic [7:0] dout;
    logic        full;
    logic        empty;

    // No simultaneous read+write in basic mode (override in corner-case tests)
    constraint c_no_sim_rw { !(wr_en && rd_en); }

    // At least one enable active — avoids idle cycles in default sequences
    constraint c_active { wr_en || rd_en; }

    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "wr=%0b rd=%0b din=0x%02h dout=0x%02h full=%0b empty=%0b",
            wr_en, rd_en, din, dout, full, empty);
    endfunction

endclass : fifo_seq_item

`endif
