// =============================================================================
// fifo_tb_top.sv — Testbench Top Module
// =============================================================================
// Only non-class file in the TB. Instantiates DUT + interface, generates
// clock/reset, registers virtual interface in config_db, starts UVM test.
// =============================================================================

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "fifo_seq_item.sv"
`include "fifo_if.sv"
`include "fifo_driver.sv"
`include "fifo_monitor.sv"
`include "fifo_scoreboard.sv"
`include "fifo_coverage.sv"
`include "fifo_agent.sv"
`include "fifo_env.sv"
`include "fifo_sequences.sv"
`include "fifo_test.sv"

module fifo_tb_top;

    parameter int DATA_WIDTH = 8;
    parameter int DEPTH      = 16;

    // Clock and reset
    logic clk   = 0;
    logic rst_n = 0;
    always #5 clk = ~clk;   // 100 MHz

    initial begin
        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
    end

    // Interface
    fifo_if #(.DATA_WIDTH(DATA_WIDTH)) dut_if (.clk(clk), .rst_n(rst_n));

    // DUT
    sync_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .wr_en (dut_if.wr_en),
        .din   (dut_if.din),
        .rd_en (dut_if.rd_en),
        .dout  (dut_if.dout),
        .full  (dut_if.full),
        .empty (dut_if.empty),
        .count ()
    );

    // Pass virtual interface to all UVM components via config_db
    initial
        uvm_config_db #(virtual fifo_if)::set(null, "uvm_test_top.*", "vif", dut_if);

    // Start test — +UVM_TESTNAME selects which test class
    // e.g. +UVM_TESTNAME=fifo_rand_test  or  +UVM_TESTNAME=fifo_corner_test
    initial run_test();

    // Simulation timeout guard
    initial begin
        #100_000;
        `uvm_fatal("TIMEOUT", "Simulation exceeded 100us — possible deadlock")
    end

    // Waveform dump
    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb_top);
    end

endmodule : fifo_tb_top
