module CLINT (
    input logic CLK,
    input logic reset,
    output logic trap,                  // Indicates whether the pipeline has entered Trap
    input logic[31:0] savePC,           // Trap point PC
    output logic[31:0] nextPC,          // Next PC
    input logic iret,                   // Return from interrupt

    // External interrupt
    input logic externalIRQ,            // External interrupt request

    // System timer interrupt
    input logic systemTimerIRQ,         // System timer interrupt

    // Exception
    input logic exception,              // Instruction exception
    input logic[7:0] exceptionCode,     // Instruction exception code

    // Software interruption not supported

    // RW
    input logic[4:0] A,
    input logic WE,
    input logic[31:0] WD,
    output logic[31:0] RD
);

logic MIE_reg;                          // Global interrupt-enable bit
logic MEIE_reg;                         // External interrupt-enable bit
logic MTIE_reg;                         // System timer interrupt-enable bit
logic[31:0] MEPC_reg;                   // Trap point PC register
logic[29:0] TVBASE_reg;                 // Trap vectors base address
logic[31:0] mscratch_reg;               // mscratch
logic mcause_Interrupt_reg;             // Trap type, 0: exception; 1: interrupt
logic[30:0] mcause_ExceptionCode_reg;   // Trap exception code
logic[31:0] mtval_reg;                  // mtval


// Read logics
always_comb begin
    case (A)
        5'b00000: RD = {{31{1'b0}}, MIE_reg};
        5'b00001: RD = {{30{1'b0}}, MEIE_reg, MTIE_reg};
        5'b00010: RD = {{30{1'b0}}, externalIRQ, systemTimerIRQ};
        5'b00011: RD = MEPC_reg;
        5'b00100: RD = {2'b00, TVBASE_reg};
        5'b00101: RD = {mcause_Interrupt_reg, mcause_ExceptionCode_reg};
        5'b00110: RD = mtval_reg;
        5'b00111: RD = mscratch_reg;
        default: RD = 32'bx;
    endcase
end

// Write logics
always_ff @(posedge CLK, posedge reset) begin
    if (reset) begin
        MIE_reg <= 0;
        MEIE_reg <= 0;
        MTIE_reg <= 0;
        MEPC_reg <= 0;
        TVBASE_reg <= 0;
        mscratch_reg <= 0;
        mcause_Interrupt_reg <= 0;
        mcause_ExceptionCode_reg <= 0;
        mtval_reg <= 0;
    end
    else begin
        if (WE)
            case (A)
                5'b00000: MIE_reg <= WD[0];
                5'b00001: begin
                    MTIE_reg <= WD[0];
                    MEIE_reg <= WD[1];
                end
                5'b00011: MEPC_reg <= WD;
                5'b00100: TVBASE_reg <= WD[29:0];
                5'b00101: begin
                    mcause_Interrupt_reg <= WD[31];
                    mcause_ExceptionCode_reg <= WD[30:0];
                end
                5'b00110: mtval_reg <= WD;
                5'b00111: mscratch_reg <= WD;
                default: begin end
            endcase

        if (trap) begin
            if (iret) begin
                MIE_reg <= 1'b1;    // Turn on global interrupt
            end else begin
                MIE_reg <= 1'b0;    // Turn off global interrupt
                MEPC_reg <= savePC; // Save trap point
                // exception > EI > TI
                if (exception) begin
                    mcause_Interrupt_reg <= 1'b0;
                    mcause_ExceptionCode_reg <= {{23{1'b0}}, exceptionCode};
                end
                else if (externalIRQ && MEIE_reg) begin
                    mcause_Interrupt_reg <= 1'b1;
                    mcause_ExceptionCode_reg <= 31'b0000000000000000000000000001011; // Machine external interrupt
                end
                else if (systemTimerIRQ && MTIE_reg) begin
                    mcause_Interrupt_reg <= 1'b1;
                    mcause_ExceptionCode_reg <= 31'b0000000000000000000000000000111; //  Machine timer interrupt
                end
            end
        end
    end
end


// Trap logic
always_comb begin
    if (exception) begin // Directly triggered if there is an exception
        trap = 1'b1;
        nextPC = {TVBASE_reg, 2'b00};
    end
    else if (((MEIE_reg && externalIRQ) || (MTIE_reg && systemTimerIRQ)) && MIE_reg) begin // Interrupt triggered based on enable bit
        trap = 1'b1;
        nextPC = {TVBASE_reg, 2'b00};
    end
    else if (iret) begin
        trap = 1'b1;
        nextPC = MEPC_reg;
    end
    else begin // Not triggered
        trap = 1'b0;
        nextPC = MEPC_reg;
    end
end
    
endmodule
