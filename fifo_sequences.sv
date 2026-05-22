// =============================================================================
// fifo_sequences.sv — UVM Sequences
// =============================================================================
`ifndef FIFO_SEQUENCES_SV
`define FIFO_SEQUENCES_SV

// Write-only: fill the FIFO
class fifo_write_seq extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_seq)
    int unsigned num_writes = 16;
    function new(string name = "fifo_write_seq"); super.new(name); endfunction

    task body();
        fifo_seq_item item;
        repeat (num_writes) begin
            item = fifo_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with { wr_en == 1; rd_en == 0; })
                `uvm_fatal("RAND", "Randomization failed")
            finish_item(item);
        end
    endtask
endclass

// Read-only: drain the FIFO
class fifo_read_seq extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_read_seq)
    int unsigned num_reads = 16;
    function new(string name = "fifo_read_seq"); super.new(name); endfunction

    task body();
        fifo_seq_item item;
        repeat (num_reads) begin
            item = fifo_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with { wr_en == 0; rd_en == 1; })
                `uvm_fatal("RAND", "Randomization failed")
            finish_item(item);
        end
    endtask
endclass

// Constrained-random: mixed reads and writes
class fifo_rand_seq extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_rand_seq)
    int unsigned num_txns = 50;
    function new(string name = "fifo_rand_seq"); super.new(name); endfunction

    task body();
        fifo_seq_item item;
        repeat (num_txns) begin
            item = fifo_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())  // uses class-level constraints
                `uvm_fatal("RAND", "Randomization failed")
            finish_item(item);
        end
    endtask
endclass

// Corner-case: fill completely, then drain completely
class fifo_corner_seq extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_corner_seq)
    function new(string name = "fifo_corner_seq"); super.new(name); endfunction

    task body();
        fifo_write_seq wr_seq = fifo_write_seq::type_id::create("wr_seq");
        fifo_read_seq  rd_seq = fifo_read_seq::type_id::create("rd_seq");
        wr_seq.num_writes = 16;
        rd_seq.num_reads  = 16;
        wr_seq.start(m_sequencer);
        rd_seq.start(m_sequencer);
    endtask
endclass

`endif
