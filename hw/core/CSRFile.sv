module CSRFile (
    input logic[11:0] A,        // CSR address
    input logic[31:0] WD,       // Write data
    input logic[1:0] WC,        // Write control
    input logic CLK,            // CLK
    input logic reset,          // reset
    input logic retire,         // instr retire
    output logic[31:0] RD,      // Read data

    // CLINT interface
    output logic[4:0] C_A,
    output logic C_WE,
    output logic[31:0] C_WD,
    input logic[31:0] C_RD
);

logic[63:0] mcycle;             // mcycle
logic[63:0] minstret;           // minstret

logic[31:0] result;

// CLINT Address logic
always_comb begin
    case (A)
        12'b001100000000: C_A = 5'b00000;
        12'b001100000101: C_A = 5'b00100;
        12'b001101000100: C_A = 5'b00010;
        12'b001100000100: C_A = 5'b00001;
        12'b001101000001: C_A = 5'b00011;
        12'b001101000010: C_A = 5'b00101;
        12'b001101000000: C_A = 5'b00111;
        12'b001101000011: C_A = 5'b00110;
        default: C_A = 5'bx;
    endcase
end
// C_WE
always_comb begin
    case (A)
        12'b001100000000: C_WE = 1'b1;
        12'b001100000101: C_WE = 1'b1;
        12'b001100000100: C_WE = 1'b1;
        12'b001101000001: C_WE = 1'b1;
        12'b001101000000: C_WE = 1'b1;
        12'b001101000010: C_WE = 1'b1;
        12'b001101000011: C_WE = 1'b1;
        default: C_WE = 1'b0;
    endcase
end

// Read logics
always_comb begin
    case (A)
        12'b001100000001: RD = {2'b01, 4'b0000, 26'b00000000000000000100000000};                        // misa = RV32I
        12'b111100010001: RD = {32{1'b0}};                                                              // mvendorid = non-commercial implementation
        12'b111100010010: RD = {32{1'b0}};                                                              // marchid = not implemented
        12'b111100010011: RD = {{24{1'b0}}, 8'b0001_0001};                                              // mimpid = 1.1.x
        12'b111100010100: RD = {32{1'b0}};                                                              // mhartid = 0
        12'b001100000000: RD = {{19{1'b0}}, 2'b11,{3{1'b0}}, 1'b1, {3{1'b0}}, C_RD[0], {3{1'b0}}};      // mstatus = only support MIE,MPP,MPIE
        12'b001100010000: RD = {32{1'b0}};                                                              // mstatush = only support MIE
        12'b001100000101: RD = {C_RD[29:0], 2'b00};                                                     // mtvec = mtvec_BASE, Direct
        12'b001101000100: RD = {{20{1'b0}}, C_RD[1], 3'b000, C_RD[0], {7{1'b0}}};                       // mip = only support mip_MEIP, mip_MTIP
        12'b001100000100: RD = {{20{1'b0}}, C_RD[1], 3'b000, C_RD[0], {7{1'b0}}};                       // mie = only support mie_MEIE, mie_MTIE
        12'b001101000000: RD = C_RD;                                                                    // mscratch
        12'b001101000001: RD = C_RD;                                                                    // mepc
        12'b001101000010: RD = C_RD;                                                                    // mcause
        12'b001101000011: RD = C_RD;                                                                    // mtval
        12'b111100010101: RD = {32{1'b0}};                                                              // mconfigptr = bypass
        12'b001100001010: RD = {32{1'b0}};                                                              // menvcfg = bypass
        12'b001100011010: RD = {32{1'b0}};                                                              // menvcfgh = bypass
        12'b101100000000: RD = mcycle[31:0];                                                            // mcycle
        12'b101110000000: RD = mcycle[63:32];                                                           // mcycleh
        12'b101100000010: RD = minstret[31:0];                                                          // minstret
        12'b101110000010: RD = minstret[63:32];                                                         // minstreth
        default: RD = 32'bx;                                                                            // ?
    endcase
end

// Write logics
always_comb begin
    case (WC)
        2'b00: result = RD;             // Do not modify
        2'b01: result = WD;             // Swap
        2'b10: result = RD | WD;        // Set bits
        2'b11: result = RD & ~WD;       // Reset bits
        default: result = 32'bx;        // ?
    endcase
end

always_comb begin
    case (A)
        12'b001100000000: C_WD = {{31{1'b0}}, result[3]};               // mstatus
        12'b001100000101: C_WD = {2'b00, result[31:2]};                 // mtvec
        12'b001100000100: C_WD = {{30{1'b0}}, result[11], result[7]};   // mie
        12'b001101000001: C_WD = result;                                // mepc
        12'b001101000010: C_WD = result;                                // mcause
        12'b001101000000: C_WD = result;                                // mscratch
        12'b001101000011: C_WD = result;                                // mtval
        default: C_WD = 32'bx;
    endcase
end

always_ff @(posedge CLK,posedge reset) begin
    if (reset) begin
        mcycle <= 0;
        minstret <= 0;
    end
    else begin
        if (A == 12'b101100000000 && WC != 2'b00)                                         // mcycle
            mcycle[31:0] <= result;
        else if (A == 12'b101110000000 && WC != 2'b00)                                    // mcycleh
            mcycle[63:32] <= result;
        else
            mcycle <= mcycle + 1'b1;

        if (A == 12'b101100000010 && WC != 2'b00)                                         // minstret
            minstret[31:0] <= result;
        else if (A == 12'b101110000010 && WC != 2'b00)                                    // minstreth
            minstret[63:32] <= result;
        else if (retire)
            minstret <= minstret + 1'b1;
    end
end
endmodule
