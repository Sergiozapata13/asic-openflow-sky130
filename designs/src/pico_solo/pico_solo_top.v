// pico_solo_top.v - PicoRV32 sin VPU, referencia para medir el costo del VPU.
// Mismos parametros y puertos que rvvlite_top, con ENABLE_PCPI = 0.
module pico_solo_top (
    input  wire        clk,
    input  wire        rst_n,
    output wire        trap,
    output wire        ext_mem_valid,
    output wire        ext_mem_instr,
    output wire [31:0] ext_mem_addr,
    output wire [31:0] ext_mem_wdata,
    output wire  [3:0] ext_mem_wstrb,
    input  wire        ext_mem_ready,
    input  wire [31:0] ext_mem_rdata
);

    reg [3:0] rst_ff;
    always @(posedge clk)
        rst_ff <= {rst_ff[2:0], rst_n};
    wire resetn = rst_ff[3];

    picorv32 #(
        .ENABLE_COUNTERS     (1),
        .ENABLE_COUNTERS64   (0),
        .ENABLE_REGS_16_31   (1),
        .ENABLE_REGS_DUALPORT(1),
        .LATCHED_MEM_RDATA   (0),
        .TWO_STAGE_SHIFT     (1),
        .BARREL_SHIFTER      (0),
        .TWO_CYCLE_COMPARE   (0),
        .TWO_CYCLE_ALU       (0),
        .COMPRESSED_ISA      (0),
        .CATCH_MISALIGN      (1),
        .CATCH_ILLINSN       (1),
        .ENABLE_PCPI         (0),
        .ENABLE_MUL          (0),
        .ENABLE_FAST_MUL     (0),
        .ENABLE_DIV          (0),
        .ENABLE_IRQ          (0),
        .ENABLE_IRQ_QREGS    (0),
        .ENABLE_IRQ_TIMER    (0),
        .ENABLE_TRACE        (0),
        .REGS_INIT_ZERO      (0),
        .PROGADDR_RESET      (32'h0000_0000),
        .STACKADDR           (32'h0000_FFFC)
    ) cpu (
        .clk          (clk),
        .resetn       (resetn),
        .trap         (trap),
        .mem_valid    (ext_mem_valid),
        .mem_instr    (ext_mem_instr),
        .mem_ready    (ext_mem_ready),
        .mem_addr     (ext_mem_addr),
        .mem_wdata    (ext_mem_wdata),
        .mem_wstrb    (ext_mem_wstrb),
        .mem_rdata    (ext_mem_rdata),
        .mem_la_read  (),
        .mem_la_write (),
        .mem_la_addr  (),
        .mem_la_wdata (),
        .mem_la_wstrb (),
        .pcpi_valid   (),
        .pcpi_insn    (),
        .pcpi_rs1     (),
        .pcpi_rs2     (),
        .pcpi_wr      (1'b0),
        .pcpi_rd      (32'b0),
        .pcpi_wait    (1'b0),
        .pcpi_ready   (1'b0),
        .irq          (32'b0),
        .eoi          (),
        .trace_valid  (),
        .trace_data   ()
    );

endmodule
