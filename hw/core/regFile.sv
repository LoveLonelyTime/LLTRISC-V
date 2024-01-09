module regFile (
    input logic[4:0] A1,
    input logic[4:0] A2,
    input logic[4:0] A3,
    input logic[31:0] WD3,
    input logic WE,
    input logic CLK,
    input logic reset,
    output logic[31:0] RD1,
    output logic[31:0] RD2
);

logic[31:0] registers [31:0];

assign RD1 = A1 == 5'b0 ? 32'b0 : registers[A1];
assign RD2 = A2 == 5'b0 ? 32'b0 : registers[A2];

always_ff @(posedge CLK,posedge reset) begin
    if (reset) begin
        for(int i = 0;i < 32;i++) registers[i] <= 0;
    end
    else if (WE) registers[A3] <= WD3;
end
    
endmodule
