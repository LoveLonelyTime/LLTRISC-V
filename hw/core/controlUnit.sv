module controlUnit (
    input logic[6:0] OP,
    input logic[2:0] funct3,
    input logic[6:0] funct7,

    // Output control logics
    output logic resultSrc,             // Choose which result to write back, 0: loadPCResult; 1: readDataExt
    output logic[2:0] memExt,           // Indicates how memory data is extended, 000: byte; 001: half; 010: word; 011: unsigned byte; 100: unsigned half
    output logic[1:0] ALUResultSrc,     // ALU, ACU or srcB, 00: ALU; 01: srcB; 10: ACU
    output logic regWrite,              // Write register
    output logic[1:0] loadPC,           // Write PC back, 00: ALUResult; 01: PCTarget; 10: PCPlus4
    output logic[1:0] memWC,            // Memory bit width control, 00: byte; 01: half; 10: word
    output logic memWrite,              // Write to memory
    output logic jump,                  // Unconditional jump
    output logic branch,                // Branch jump
    output logic[2:0] branchSrc,        // Jump condition & SLT, 000: EQ; 001: NEQ; 010: LT; 011: GT; 100: LE; 101: GE
    output logic _unsigned,             // Unsigned comparison
    output logic[2:0] ALUControl,       // ALU function selection
    output logic ALUSrcB,               // ALU Operand B selection, 0: RD2; 1: imm
    output logic[2:0] immSrc,           // Instructions on how to interpret immediate numbers
    output logic targetAddressSrc,      // Select address addition operand 1
    output logic CSRWriteDataSrc,       // Select the value to write to CSR, 0: reg; 1: imm
    output logic[1:0] CSRWriteControl,  // Choose how to write CSR, 00: Do not modify; 01: Swap; 10: Set bits; 11: Reset bits
    output logic readDataSrc,           // Source of data read in, 0: Memory; 1: CSRFile 
    output logic retire,                // Instruction retire
    output logic privilegedInstr        // Privileged instruction
);

always_comb begin

    // resultSrc
    case (OP)
        7'b0000011: resultSrc = 1'b1;   // Load I-type instructions
        7'b1110011: resultSrc = 1'b1;   // csrx instructions
        default: resultSrc = 1'b0;
    endcase

    // memExt
    case (funct3)
        3'b000: memExt = 3'b000;        // lb
        3'b001: memExt = 3'b001;        // lh
        3'b010: memExt = 3'b010;        // lw
        3'b100: memExt = 3'b011;        // lbu
        3'b101: memExt = 3'b100;        // lhu
        default: memExt = 3'bx;         // ?
    endcase


    // ALUResultSrc
    if ((OP == 7'b0010011 || OP == 7'b0110011) && (funct3 == 3'b010 || funct3 == 3'b011))
        ALUResultSrc = 2'b10;            // slt
    else if (OP == 7'b0110111)
        ALUResultSrc = 2'b01;            // lui
    else if(OP == 7'b1110011)
        ALUResultSrc = 2'b11;            // csrx
    else
        ALUResultSrc = 2'b00;

    // regWrite
    if (OP == 7'b0100011 || OP == 7'b1100011)
        regWrite = 1'b0;                // sx, bx
    else
        regWrite = 1'b1;

    // loadPC
    case (OP)
        7'b0010111: loadPC = 2'b01;     // auipc
        7'b1100111: loadPC = 2'b10;     // jalr
        7'b1101111: loadPC = 2'b10;     // jal
        default: loadPC = 2'b00;
    endcase

    // memWC
    case (funct3)
        3'b000: memWC = 2'b00;          // byte
        3'b001: memWC = 2'b01;          // half
        3'b010: memWC = 2'b10;          // word
        3'b100: memWC = 2'b00;          // unsigned byte
        3'b101: memWC = 2'b01;          // unsigned half
        default: memWC = 2'bx;         // ?
    endcase

    // memWrite
    if (OP == 7'b0100011)
        memWrite = 1'b1;                // sx
    else
        memWrite = 1'b0;

    // jump
    if(OP == 7'b1100111 || OP == 7'b1101111)
        jump = 1'b1;                    // jalr&jal
    else
        jump = 1'b0;

    // branch
    if(OP == 7'b1100011)
        branch = 1'b1;                  // bx
    else
        branch = 1'b0;

    // branchSrc
    case (funct3)
        3'b000: branchSrc = 3'b000;     // beq
        3'b001: branchSrc = 3'b001;     // bne
        3'b100: branchSrc = 3'b010;     // blt
        3'b101: branchSrc = 3'b101;     // bge
        3'b110: branchSrc = 3'b010;     // bltu
        3'b111: branchSrc = 3'b101;     // bgeu
        3'b010: branchSrc = 3'b010;     // sltx
        3'b011: branchSrc = 3'b010;     // sltxu
        default: branchSrc = 3'bx;      // ?
    endcase

    // _unsigned
    case (funct3)
        3'b011: _unsigned = 1'b1;       // sltxu
        3'b110: _unsigned = 1'b1;       // bltu
        3'b111: _unsigned = 1'b1;       // bgeu
        default: _unsigned = 1'b0;
    endcase

    // ALUControl
    case (OP)
        7'b0000011: ALUControl = 3'b000;// lx
        7'b0010011:                     // Arithmetic I-type instructions
            case (funct3)
                3'b000: ALUControl = 3'b000;                         // addi
                3'b001: ALUControl = 3'b101;                         // slli
                3'b010: ALUControl = 3'b001;                         // slti
                3'b011: ALUControl = 3'b001;                         // sltiu
                3'b100: ALUControl = 3'b100;                         // xori
                3'b101: ALUControl = funct7[5] ? 3'b111 : 3'b110;    // srli&srai
                3'b110: ALUControl = 3'b011;                         // ori
                3'b111: ALUControl = 3'b010;                         // andi
                default: ALUControl = 3'bx;                          // ?
            endcase
        7'b0010111: ALUControl = 3'b000;// auipc
        7'b0100011: ALUControl = 3'b000;// sx
        7'b0110011:
            case (funct3)
                3'b000: ALUControl = funct7[5] ? 3'b001 : 3'b000;    // add&sub
                3'b001: ALUControl = 3'b101;                         // sll
                3'b010: ALUControl = 3'b001;                         // slt
                3'b011: ALUControl = 3'b001;                         // sltu
                3'b100: ALUControl = 3'b100;                         // xor
                3'b101: ALUControl = funct7[5] ? 3'b111 : 3'b110;    // srl&sra
                3'b110: ALUControl = 3'b011;                         // or
                3'b111: ALUControl = 3'b010;                         // and
                default: ALUControl = 3'bx;                          // ?
            endcase

        7'b0110111: ALUControl = 3'b000;// lui
        7'b1100011: ALUControl = 3'b001;// bx
        7'b1100111: ALUControl = 3'b000;// jalr
        7'b1101111: ALUControl = 3'b000;// jal
        default: ALUControl = 3'bx;     // ?
    endcase

    // ALUSrcB
    if (OP == 7'b0110011 || OP == 7'b1100011)
        ALUSrcB = 1'b0; // R-type instructions and branch instructions
    else
        ALUSrcB = 1'b1;

    // immSrc
    case (OP)
        7'b0000011: immSrc = 3'b000;    // Load I-type instructions
        7'b0010011:                     // Arithmetic I-type instructions
            case (funct3)
                3'b001: immSrc = 3'b101; // uimm
                3'b101: immSrc = 3'b101; // uimm
                default: immSrc = 3'b000;// imm
            endcase
        7'b0010111: immSrc = 3'b011;    // auipc
        7'b0100011: immSrc = 3'b001;    // sx
        7'b0110111: immSrc = 3'b011;    // lui
        7'b1100011: immSrc = 3'b010;    // bx
        7'b1100111: immSrc = 3'b000;    // jalr
        7'b1101111: immSrc = 3'b100;    // jal
        7'b1110011: immSrc = 3'b110;    // csrx
        default: immSrc = 3'bx;         // ?
    endcase

    // targetAddressSrc
    case (OP)
        7'b1100111: targetAddressSrc = 1'b1; // jalr
        default: targetAddressSrc = 1'b0;
    endcase

    // CSRWriteDataSrc
    case (funct3)
        3'b001: CSRWriteDataSrc = 1'b0;     // csrrw
        3'b010: CSRWriteDataSrc = 1'b0;     // csrrs
        3'b011: CSRWriteDataSrc = 1'b0;     // csrrc
        3'b101: CSRWriteDataSrc = 1'b1;     // csrrwi
        3'b110: CSRWriteDataSrc = 1'b1;     // csrrsi
        3'b111: CSRWriteDataSrc = 1'b1;     // csrrci
        default: CSRWriteDataSrc = 1'bx;    // ?
    endcase

    // CSRWriteControl
    case (funct3)
        3'b001: CSRWriteControl = 2'b01;    // csrrw
        3'b010: CSRWriteControl = 2'b10;    // csrrs
        3'b011: CSRWriteControl = 2'b11;    // csrrc
        3'b101: CSRWriteControl = 2'b01;    // csrrwi
        3'b110: CSRWriteControl = 2'b10;    // csrrsi
        3'b111: CSRWriteControl = 2'b11;    // csrrci
        default: CSRWriteControl = 2'b00;   // ?
    endcase

    // readDataSrc
    if (OP == 7'b1110011 && funct3 != 3'b000)
        readDataSrc = 1'b1;
    else
        readDataSrc = 1'b0;

    // retire
    case (OP)
        7'b0000011: retire = 1'b1;
        7'b0010011: retire = 1'b1;
        7'b0010111: retire = 1'b1;
        7'b0100011: retire = 1'b1;
        7'b0110011: retire = 1'b1;
        7'b0110111: retire = 1'b1;
        7'b1100011: retire = 1'b1;
        7'b1100111: retire = 1'b1;
        7'b1101111: retire = 1'b1;
        7'b1110011: retire = 1'b1;
        default: retire = 1'b0;
    endcase

    // iret
    if(OP == 7'b1110011 && funct3 == 3'b000)
        privilegedInstr = 1'b1;
    else
        privilegedInstr = 1'b0;
end
endmodule
