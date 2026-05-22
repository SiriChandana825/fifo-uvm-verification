// =============================================================================
// sync_fifo.sv — Parameterized Synchronous FIFO
// =============================================================================
// Parameters:
//   DATA_WIDTH : width of each data word      (default: 8 bits)
//   DEPTH      : number of entries in the FIFO (default: 16, must be power of 2)
//
// Ports:
//   clk        : clock (rising-edge triggered)
//   rst_n      : active-low synchronous reset
//   wr_en      : write enable — push data in
//   rd_en      : read enable  — pop data out
//   din        : data input
//   dout       : data output (registered)
//   full       : asserted when FIFO cannot accept more writes
//   empty      : asserted when FIFO has no data to read
//   count      : number of valid entries currently stored
//
// Behavior:
//   - Simultaneous wr_en + rd_en when neither full nor empty is allowed
//     (the write and read happen in the same cycle — count stays the same)
//   - Write when full  is silently ignored (no overflow)
//   - Read  when empty is silently ignored (no underflow); dout holds last value
// =============================================================================

module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16
) (
    input  logic                  clk,
    input  logic                  rst_n,

    // Write port
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] din,

    // Read port
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] dout,

    // Status flags
    output logic                  full,
    output logic                  empty,
    output logic [$clog2(DEPTH):0] count   // 0 to DEPTH inclusive
);

    // -------------------------------------------------------------------------
    // Local parameters
    // -------------------------------------------------------------------------
    localparam int PTR_WIDTH = $clog2(DEPTH);   // bits needed to address DEPTH entries

    // -------------------------------------------------------------------------
    // Internal storage
    // -------------------------------------------------------------------------
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];     // the actual FIFO memory array

    // -------------------------------------------------------------------------
    // Pointers
    //   wr_ptr : points to the next location to write INTO
    //   rd_ptr : points to the next location to read  FROM
    // Both wrap around using modulo-DEPTH arithmetic (natural for power-of-2 depth)
    // -------------------------------------------------------------------------
    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;

    // -------------------------------------------------------------------------
    // Derived control signals
    // -------------------------------------------------------------------------
    logic do_write;   // actual write this cycle
    logic do_read;    // actual read  this cycle

    assign do_write = wr_en & ~full;
    assign do_read  = rd_en & ~empty;

    // -------------------------------------------------------------------------
    // Write pointer + memory write
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end else if (do_write) begin
            mem[wr_ptr] <= din;
            wr_ptr      <= wr_ptr + 1'b1;   // wraps automatically at DEPTH (power-of-2)
        end
    end

    // -------------------------------------------------------------------------
    // Read pointer + registered output
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            rd_ptr <= '0;
            dout   <= '0;
        end else if (do_read) begin
            dout   <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    // -------------------------------------------------------------------------
    // Entry count tracking
    //   Increment on write-only, decrement on read-only,
    //   unchanged on simultaneous read+write or no operation.
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            unique case ({do_write, do_read})
                2'b10:   count <= count + 1;   // write only
                2'b01:   count <= count - 1;   // read  only
                default: count <= count;        // both or neither — no change
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Status flags (combinational — reflect current count immediately)
    // -------------------------------------------------------------------------
    assign full  = (count == DEPTH[$clog2(DEPTH):0]);
    assign empty = (count == 0);

    // -------------------------------------------------------------------------
    // Assertions — catch illegal conditions in simulation
    // (SVA — automatically disabled in synthesis)
    // -------------------------------------------------------------------------
    // synthesis translate_off

    // No overflow: writing to a full FIFO is a bug
    AP_NO_OVERFLOW: assert property (
        @(posedge clk) disable iff (!rst_n)
        (wr_en & full) |-> 0
    ) else $error("FIFO OVERFLOW: wr_en asserted while full at time %0t", $time);

    // No underflow: reading from an empty FIFO is a bug
    AP_NO_UNDERFLOW: assert property (
        @(posedge clk) disable iff (!rst_n)
        (rd_en & empty) |-> 0
    ) else $error("FIFO UNDERFLOW: rd_en asserted while empty at time %0t", $time);

    // Count must never exceed DEPTH
    AP_COUNT_RANGE: assert property (
        @(posedge clk) disable iff (!rst_n)
        count <= DEPTH
    ) else $error("FIFO COUNT out of range: count=%0d DEPTH=%0d", count, DEPTH);

    // synthesis translate_on

endmodule : sync_fifo
