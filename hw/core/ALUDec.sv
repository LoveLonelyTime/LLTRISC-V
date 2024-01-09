module ALUDec (
    input logic[2:0] funct3,
    input logic[6:0] funct7,
    input logic[1:0] ALUOP,
    output logic[2:0] ALUControl
);

always_comb begin
    case (ALUOP)
        2'b00: // R-Type
            case (funct3)
                3'b000: ALUControl = funct7[5] ? 3'b001 : 3'b000; // add & sub
                3'b001: ALUControl = 3'b101; // sll
                3'b010: ALUControl = 3'b001; // slt
                3'b011: ALUControl = 3'b001; // sltu
                3'b100: ALUControl = 3'b100; // xor
                3'b101: ALUControl = funct7[5] ? 3'b111 : 3'b110; // srl & sra
                3'b110: ALUControl = 3'b011; // or
                3'b111: ALUControl = 3'b010; // and
                default: ALUControl = 3'bx; // ?
            endcase
        2'b01: // arithmetic I-type
            case (funct3)
                3'b000: ALUControl = 3'b000; // addi
                3'b001: ALUControl = 3'b101; // slli
                3'b010: ALUControl = 3'b001; // slti
                3'b011: ALUControl = 3'b001; // sltiu
                3'b100: ALUControl = 3'b100; // xori
                3'b101: ALUControl = funct7[5] ? 3'b111 : 3'b110; // srli & srai
                3'b110: ALUControl = 3'b011; // ori
                3'b111: ALUControl = 3'b010; // andi
                default: ALUControl = 3'bx; // ?
            endcase
        2'b10: // Add
            ALUControl = 3'b000;
        2'b11: // Sub
            ALUControl = 3'b001;
        default: ALUControl = 3'bx; // ?
    endcase
end
    
endmodule
