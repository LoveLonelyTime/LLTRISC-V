module hazardUnit (
    input logic[4:0] RS1D,
    input logic[4:0] RS2D,
    input logic[4:0] RS1E,
    input logic[4:0] RS2E,
    input logic PCSrcE,
    input logic resultSrcE,
    input logic[4:0] RDM,
    input logic regWriteM,
    input logic regWriteW,
    input logic[4:0] RDW,
    input logic[4:0] RDE,

    output logic stallF,
    output logic stallD,
    output logic flushD,
    output logic flushE,
    output logic[1:0] forwardAE,
    output logic[1:0] forwardBE
);

// Data forward
always_comb begin
    if (RS1E == RDM && regWriteM && RS1E != 5'b0)       // Forward from Memeory stage
        forwardAE = 2'b01;
    else if(RS1E == RDW && regWriteW && RS1E != 5'b0)   //  Forward from Writeback stage
        forwardAE = 2'b10;
    else                                                // No forwarding
        forwardAE = 2'b00;

    if (RS2E == RDM && regWriteM && RS2E != 5'b0)       // Forward from Memeory stage
        forwardBE = 2'b01;
    else if(RS2E == RDW && regWriteW && RS2E != 5'b0)   //  Forward from Writeback stage
        forwardBE = 2'b10;
    else                                                // No forwarding
        forwardBE = 2'b00;
end

// Stalls
logic lwStall;
always_comb begin
    lwStall = resultSrcE && (RS1D == RDE || RS2D == RDE);
    stallF = lwStall;
    stallD = lwStall;
    flushE = lwStall || PCSrcE; // Branch Prediction
end

// Branch Prediction
always_comb begin
    flushD = PCSrcE;
end

endmodule
