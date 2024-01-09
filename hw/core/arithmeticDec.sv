module arithmeticDec (
    input logic _unsigned,
    input logic[2:0] branchSrc,
    input logic zero,
    input logic carrayOut,
    input logic negative,
    input logic overflow,
    output logic flag
);

logic eq;
logic neq;
logic le;
logic lt;
logic ge;
logic gt;
logic[5:0] alogics;

assign alogics = {ge, le, gt, lt, neq, eq};

assign eq = zero;
assign neq = ~eq;
assign le = _unsigned ? zero | ~carrayOut : zero | (negative ^ overflow);
assign gt = ~le;
assign lt = _unsigned ? ~carrayOut : negative ^ overflow;
assign ge = ~lt;

assign flag = alogics[branchSrc];
    
endmodule
