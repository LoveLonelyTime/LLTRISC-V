module writeBackCL (
    input logic regWriteW,
    input logic resultSrcW,
    input logic[31:0] loadPCResultW,
    input logic[31:0] readDataW,
    input logic[4:0] RDW,

    output logic[31:0] resultW,

    // Instruction memory interface
    output logic[4:0] rf_A3W,
    output logic[31:0] rf_WD3W,
    output logic rf_WEW
);

assign resultW = resultSrcW ? readDataW : loadPCResultW;
assign rf_WD3W = resultW;
assign rf_WEW = regWriteW;
assign rf_A3W = RDW;

endmodule
