module fetchCL (
    input logic[31:0] PCF,
    output logic[31:0] instrF,
    output logic[31:0] PCPlus4F,
    
    // Instruction memory interface
    output logic[31:0] imem_AddrF,
    input logic[31:0] imem_RDF
);

assign imem_AddrF = PCF;
assign PCPlus4F = PCF + 4;
assign instrF = imem_RDF;

endmodule
