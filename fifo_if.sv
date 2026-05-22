// =============================================================================
// fifo_if.sv — SystemVerilog Interface + Clocking Blocks
// =============================================================================
`ifndef FIFO_IF_SV
`define FIFO_IF_SV

interface fifo_if #(parameter int DATA_WIDTH = 8) (
    input logic clk,
    input logic rst_n
);

    logic                  wr_en;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] din;
    logic [DATA_WIDTH-1:0] dout;
    logic                  full;
    logic                  empty;

    // Driver clocking block — defines setup/hold relative to posedge clk
    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        output wr_en, rd_en, din;
        input  dout, full, empty;
    endclocking

    // Monitor clocking block — samples one cycle after stimulus
    clocking monitor_cb @(posedge clk);
        default input #1;
        input wr_en, rd_en, din, dout, full, empty;
    endclocking

    modport driver_mp  (clocking driver_cb,  input clk, rst_n);
    modport monitor_mp (clocking monitor_cb, input clk, rst_n);

endinterface : fifo_if

`endif
