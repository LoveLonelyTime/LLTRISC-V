module lltriscv (
    input logic CLK,
    input logic reset,

    // Instruction memory interface
    output logic[31:0] imem_Addr,
    input logic[31:0] imem_RD,

    // Data memory interface
    output logic[31:0] dmem_Addr,
    input logic[31:0] dmem_RD,
    input logic dmem_sel,
    output logic dmem_WE,
    output logic[31:0] dmem_WD,
    output logic[1:0] dmem_WC,

    // UART interface
    output logic txPort,
    input logic rxPort
);

logic[31:0] sel_RD;

logic systemTimerIRQ;
datapath datapath_inst(
    .CLK        (CLK),
    .reset      (reset),

    // Instruction memory interface
    .imem_Addr  (imem_Addr),
    .imem_RD    (imem_RD),

    // Data memory interface
    .dmem_Addr  (dmem_Addr),
    .dmem_RD    (sel_RD),
    .dmem_WE    (dmem_WE),
    .dmem_WD    (dmem_WD),
    .dmem_WC    (dmem_WC),

    // Trap
    .systemTimerIRQ (systemTimerIRQ)
);

// System Timer
logic sysTimer_sel;
logic[31:0] sysTimer_RD;
sysTimer sysTimer_inst(
    .CLK                (CLK),
    .reset              (reset),
    .systemTimerIRQ     (systemTimerIRQ),

    .A                  (dmem_Addr),
    .WE                 (dmem_WE),
    .WD                 (dmem_WD),
    .RD                 (sysTimer_RD),
    .sel                (sysTimer_sel)
);

// uartController
logic uartController_sel;
logic[31:0] uartController_RD;
uartController uartController_inst(
    .CLK                (CLK),
    .reset              (reset),

    .txPort             (txPort),
    .rxPort             (rxPort),
    .A                  (dmem_Addr),
    .WE                 (dmem_WE),
    .WD                 (dmem_WD),
    .RD                 (uartController_RD),
    .sel                (uartController_sel)
);

always_comb begin
    if (dmem_sel)
        sel_RD = dmem_RD;
    else if (sysTimer_sel)
        sel_RD = sysTimer_RD;
    else if (uartController_sel)
        sel_RD = uartController_RD;
    else
        sel_RD = 32'bx;
end

endmodule
