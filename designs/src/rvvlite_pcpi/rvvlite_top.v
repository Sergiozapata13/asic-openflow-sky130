// rvvlite_top.v - PicoRV32 + VPU (vpu_pcpi) para ASIC, memoria externa
// Derivado de top.v (TFG RVV-lite). Sin RAM, UART ni GPIO.
// Contrato del puerto ext_*: respuesta registrada; ext_mem_ready llega
// como minimo un ciclo despues de ext_mem_valid (como la BRAM original).
module rvvlite_top (
    input  wire        clk,
    input  wire        rst_n,          // reset externo, activo en bajo
    output wire        trap,
    output wire        ext_mem_valid,
    output wire        ext_mem_instr,
    output wire [31:0] ext_mem_addr,
    output wire [31:0] ext_mem_wdata,
    output wire  [3:0] ext_mem_wstrb,
    input  wire        ext_mem_ready,
    input  wire [31:0] ext_mem_rdata
);

    // Reset sincronizado - 4 FF, sin valor inicial
    reg [3:0] rst_ff;
    always @(posedge clk)
        rst_ff <= {rst_ff[2:0], rst_n};
    wire resetn = rst_ff[3];

    // Bus de memoria del core
    wire        mem_valid, mem_instr, mem_ready;
    wire [31:0] mem_addr, mem_wdata, mem_rdata;
    wire  [3:0] mem_wstrb;

    // PCPI
    wire        pcpi_valid, pcpi_wr, pcpi_wait, pcpi_ready;
    wire [31:0] pcpi_insn, pcpi_rs1, pcpi_rs2, pcpi_rd;

    // Bus LSU del VPU
    wire        lsu_mem_valid, lsu_mem_ready;
    wire [31:0] lsu_mem_addr, lsu_mem_wdata, lsu_mem_rdata;
    wire  [3:0] lsu_mem_wstrb;

    // lsu_valid_prev - igual que en top.v (HT-OE3b)
    reg lsu_valid_prev;
    always @(posedge clk)
        lsu_valid_prev <= lsu_mem_valid;

    // Arbitro: cuando lsu_mem_valid=1, el LSU controla el bus
    assign ext_mem_valid = lsu_mem_valid ? lsu_mem_valid : mem_valid;
    assign ext_mem_instr = lsu_mem_valid ? 1'b0          : mem_instr;
    assign ext_mem_addr  = lsu_mem_valid ? lsu_mem_addr  : mem_addr;
    assign ext_mem_wdata = lsu_mem_valid ? lsu_mem_wdata : mem_wdata;
    assign ext_mem_wstrb = lsu_mem_valid ? lsu_mem_wstrb : mem_wstrb;

    // Enrutamiento de la respuesta - igual que en top.v
    assign mem_ready     = lsu_mem_valid  ? 1'b0          : ext_mem_ready;
    assign mem_rdata     = lsu_mem_valid  ? 32'b0         : ext_mem_rdata;
    assign lsu_mem_ready = lsu_valid_prev ? ext_mem_ready : 1'b0;
    assign lsu_mem_rdata = lsu_valid_prev ? ext_mem_rdata : 32'b0;

    vpu_pcpi u_vpu (
        .clk           (clk),
        .resetn        (resetn),
        .pcpi_valid    (pcpi_valid),
        .pcpi_insn     (pcpi_insn),
        .pcpi_rs1      (pcpi_rs1),
        .pcpi_rs2      (pcpi_rs2),
        .pcpi_wr       (pcpi_wr),
        .pcpi_rd       (pcpi_rd),
        .pcpi_wait     (pcpi_wait),
        .pcpi_ready    (pcpi_ready),
        .lsu_mem_valid (lsu_mem_valid),
        .lsu_mem_addr  (lsu_mem_addr),
        .lsu_mem_wdata (lsu_mem_wdata),
        .lsu_mem_wstrb (lsu_mem_wstrb),
        .lsu_mem_ready (lsu_mem_ready),
        .lsu_mem_rdata (lsu_mem_rdata)
    );

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
        .ENABLE_PCPI         (1),
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
        .mem_valid    (mem_valid),
        .mem_instr    (mem_instr),
        .mem_ready    (mem_ready),
        .mem_addr     (mem_addr),
        .mem_wdata    (mem_wdata),
        .mem_wstrb    (mem_wstrb),
        .mem_rdata    (mem_rdata),
        .mem_la_read  (),
        .mem_la_write (),
        .mem_la_addr  (),
        .mem_la_wdata (),
        .mem_la_wstrb (),
        .pcpi_valid   (pcpi_valid),
        .pcpi_insn    (pcpi_insn),
        .pcpi_rs1     (pcpi_rs1),
        .pcpi_rs2     (pcpi_rs2),
        .pcpi_wr      (pcpi_wr),
        .pcpi_rd      (pcpi_rd),
        .pcpi_wait    (pcpi_wait),
        .pcpi_ready   (pcpi_ready),
        .irq          (32'b0),
        .eoi          (),
        .trace_valid  (),
        .trace_data   ()
    );

endmodule
