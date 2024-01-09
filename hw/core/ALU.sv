module ALU (
    input logic[2:0] ALUControl,
    input logic[31:0] srcA,
    input logic[31:0] srcB,
    output logic[31:0] result,
    output logic zero,
    output logic carrayOut,
    output logic negative,
    output logic overflow
);

logic cout;
logic[31:0] sum;
logic subtraction;

adder32 adder32_inst(
    .a (srcA),
    .b (subtraction ? ~srcB : srcB),
    .cin (subtraction ? 1'b1 : 1'b0),
    .s (sum),
    .cout (cout)
);

always_comb begin
    case (ALUControl)
        3'b000: result = sum;                       // addition
        3'b001: result = sum;                       // subtraction
        3'b010: result = srcA & srcB;               // and
        3'b011: result = srcA | srcB;               // or
        3'b100: result = srcA ^ srcB;               // xor
        3'b101: result = srcA << srcB;              // shift left
        3'b110: result = srcA >> srcB;              // shift right logic
        3'b111: result = ($signed(srcA)) >>> srcB;  // shift right arithmetic
        default: result = 32'bx;                    // ?
    endcase

    if (ALUControl == 3'b001)
        subtraction = 1'b1;
    else
        subtraction = 1'b0;
end

logic arithmetic;
assign arithmetic = ALUControl == 3'b000 || ALUControl == 3'b001;
assign zero = result == 32'b0;
assign negative = result[31];
assign carrayOut = arithmetic & cout;

logic aXorSum;
logic aXorB;
assign aXorSum = srcA[31] ^ sum[31];
assign aXorB = ~(srcA[31] ^ srcB[31] ^ ALUControl[0]);
assign overflow = arithmetic & aXorSum & aXorB;

endmodule
