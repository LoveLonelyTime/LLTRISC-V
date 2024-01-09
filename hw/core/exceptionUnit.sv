module exceptionUnit (
    input logic privilegedInstrE,
    input logic[31:0] immExtE,
    output logic iret,
    output logic exception,
    output logic[7:0] exceptionCode
);

always_comb begin
    if (privilegedInstrE && (immExtE[31:20] == 12'b000000000010 || immExtE[31:20] == 12'b000100000010 || immExtE[31:20] == 12'b001100000010))
        iret = 1'b1;
    else
        iret = 1'b0;
end

assign exception = 1'b0;
assign exceptionCode = 8'b0;
    
endmodule
