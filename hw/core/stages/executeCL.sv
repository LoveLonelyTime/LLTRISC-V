module executeCL (
    input logic ALUSrcBE,
    input logic[31:0] immExtE,
    input logic[31:0] RD1E,
    input logic[31:0] RD2E,
    input logic[2:0] ALUControlE,
    input logic _unsignedE,
    input logic jumpE,
    input logic branchE,
    input logic[2:0] branchSrcE,
    input logic[31:0] PCE,
    input logic[1:0] ALUResultSrcE, // 00: ALUOResult; 01: srcB; 10: ACUOResult
    input logic targetAddressSrcE, // 0: PCE; 1: srcAE; 

    output logic PCSrcE, // 0: PCPlus4, 1: PCTarget
    output logic[31:0] PCTargetE,
    output logic[31:0] ALUResultE,
    output logic[31:0] writeDataE
);

// ALU
logic[31:0] srcAE;
logic[31:0] srcBE;
assign srcAE = RD1E;
assign srcBE = ALUSrcBE ? immExtE : RD2E;
assign writeDataE = RD2E;

logic zeroE;
logic carrayOutE;
logic negativeE;
logic overflowE;

logic[31:0] ALUOResultE;
ALU ALU_inst(
    .ALUControl     (ALUControlE),
    .srcA           (srcAE),
    .srcB           (srcBE),
    .result         (ALUOResultE),
    .zero           (zeroE),
    .carrayOut      (carrayOutE),
    .negative       (negativeE),
    .overflow       (overflowE)
);

// Arithmetic decode
logic ACUOResultE;

arithmeticDec arithmeticDec_inst(
    ._unsigned      (_unsignedE),
    .branchSrc      (branchSrcE),
    .zero           (zeroE),
    .carrayOut      (carrayOutE),
    .negative       (negativeE),
    .overflow       (overflowE),
    .flag           (ACUOResultE)
);

always_comb begin
    case (ALUResultSrcE)
        2'b00: ALUResultE = ALUOResultE;
        2'b01: ALUResultE = srcBE;
        2'b10: ALUResultE = {{31{1'b0}}, ACUOResultE};
        2'b11: ALUResultE = srcAE;
        default: ALUResultE = 32'bx;
    endcase 
end

// Branch & Jump
logic[31:0] targetAddressE;

assign PCSrcE = jumpE | (branchE & ACUOResultE);
assign targetAddressE = targetAddressSrcE ? srcAE : PCE;
assign PCTargetE = immExtE + targetAddressE;

endmodule
