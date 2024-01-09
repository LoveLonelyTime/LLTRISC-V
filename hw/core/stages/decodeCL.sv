module decodeCL (
    input logic[31:0] instrD,
    output logic[4:0] RS1D,
    output logic[4:0] RS2D,
    output logic[4:0] RDD,
    output logic[31:0] RD1D,
    output logic[31:0] RD2D,
    output logic[31:0] immExtD,

    // Control Logics
    output logic resultSrcD,
    output logic[2:0] memExtD,
    output logic[1:0] ALUResultSrcD,
    output logic regWriteD,
    output logic[1:0] loadPCD,
    output logic[1:0] memWCD,
    output logic memWriteD,
    output logic jumpD,
    output logic branchD,
    output logic[2:0] branchSrcD,
    output logic _unsignedD,
    output logic[2:0] ALUControlD,
    output logic ALUSrcBD,
    output logic targetAddressSrcD,
    output logic CSRWriteDataSrcD,   
    output logic[1:0] CSRWriteControlD,
    output logic readDataSrcD,
    output logic retireD,
    output logic privilegedInstrD,

    // Register file interface
    output logic[4:0] rf_A1D,
    output logic[4:0] rf_A2D,
    input logic[31:0] rf_RD1D,
    input logic[31:0] rf_RD2D
);

// RSx: register source x, RD: register destination, RDx: read data from register x

assign RS1D = instrD[19:15];
assign RS2D = instrD[24:20];
assign RDD = instrD[11:7];

assign rf_A1D = instrD[19:15];
assign rf_A2D = instrD[24:20];
assign RD1D = rf_RD1D;
assign RD2D = rf_RD2D;

// Control unit

logic[2:0] immSrcD;

controlUnit controlUnit_inst(
    // Input
    .OP             (instrD[6:0]),
    .funct3         (instrD[14:12]),
    .funct7         (instrD[31:25]),

    // Output
    .resultSrc          (resultSrcD),
    .memExt             (memExtD),
    .ALUResultSrc       (ALUResultSrcD),
    .regWrite           (regWriteD),
    .loadPC             (loadPCD),
    .memWC              (memWCD),
    .memWrite           (memWriteD),
    .jump               (jumpD),
    .branch             (branchD),
    .branchSrc          (branchSrcD),
    ._unsigned          (_unsignedD),
    .ALUControl         (ALUControlD),
    .ALUSrcB            (ALUSrcBD),
    .immSrc             (immSrcD),
    .targetAddressSrc   (targetAddressSrcD),
    .CSRWriteDataSrc    (CSRWriteDataSrcD),
    .CSRWriteControl    (CSRWriteControlD),
    .readDataSrc        (readDataSrcD),
    .retire             (retireD),
    .privilegedInstr    (privilegedInstrD)
);

// Extender
extender ext(
    .src            (instrD[31:7]),
    .extControl     (immSrcD),
    .result         (immExtD)
);

endmodule
