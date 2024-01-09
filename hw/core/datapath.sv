module datapath (
    input logic CLK,
    input logic reset,

    // Instruction memory interface
    output logic[31:0] imem_Addr,
    input logic[31:0] imem_RD,

    // Data memory interface
    output logic[31:0] dmem_Addr,
    input logic[31:0] dmem_RD,
    output logic dmem_WE,
    output logic[31:0] dmem_WD,
    output logic[1:0] dmem_WC,

    // Trap
    input logic systemTimerIRQ
);

logic[31:0] PCF_reg;

// Hazard Unit
logic stallF;
logic stallD;
logic flushD;
logic flushE;
logic[1:0] forwardAE;
logic[1:0] forwardBE;

// CLINT
logic trap;
logic[31:0] C_nextPC;

// regFile
logic[4:0] rf_A1;
logic[4:0] rf_A2;
logic[4:0] rf_A3;
logic[31:0] rf_WD3;
logic[31:0] rf_RD1;
logic[31:0] rf_RD2;
logic rf_WE;

// CSRFile
logic[11:0] cf_Addr;
logic[31:0] cf_WD;
logic[1:0] cf_WC;
logic[31:0] cf_RD;
logic cf_retire;

// ----------------> Fetch <---------------- //

logic[31:0] PCD_reg;
logic[31:0] PCPlus4D_reg;
logic[31:0] instrD_reg;

logic[31:0] instrF;
logic[31:0] PCPlus4F;

fetchCL fetchCL_inst(
    // Input
    .PCF             (PCF_reg),

    // Output
    .instrF          (instrF),
    .PCPlus4F        (PCPlus4F),

    // Instruction memory interface
    .imem_AddrF      (imem_Addr),
    .imem_RDF        (imem_RD)
);

always_ff @(posedge CLK, posedge reset) begin
    if (reset || flushD || trap) begin
        instrD_reg <= 0;
        PCD_reg <= 0;
        PCPlus4D_reg <= 0;
    end
    else if(~stallD) begin
        instrD_reg <= instrF;
        PCD_reg <= PCF_reg;
        PCPlus4D_reg <= PCPlus4F;
    end
end

// ----------------> Decode <---------------- //

logic resultSrcE_reg;
logic[2:0] memExtE_reg;
logic[1:0] ALUResultSrcE_reg;
logic regWriteE_reg;
logic[1:0] loadPCE_reg;
logic[1:0] memWCE_reg;
logic memWriteE_reg;
logic jumpE_reg;
logic branchE_reg;
logic[2:0] branchSrcE_reg;
logic _unsignedE_reg;
logic[2:0] ALUControlE_reg;
logic ALUSrcBE_reg;
logic targetAddressSrcE_reg;
logic CSRWriteDataSrcE_reg;
logic[1:0] CSRWriteControlE_reg;
logic readDataSrcE_reg;
logic retireE_reg;
logic privilegedInstrE_reg;

logic[4:0] RS1E_reg;
logic[4:0] RS2E_reg;
logic[4:0] RDE_reg;
logic[31:0] RD1E_reg;
logic[31:0] RD2E_reg;
logic[31:0] immExtE_reg;

logic[31:0] PCE_reg;
logic[31:0] PCPlus4E_reg;

logic resultSrcD;
logic[2:0] memExtD;
logic[1:0] ALUResultSrcD;
logic regWriteD;
logic[1:0] loadPCD;
logic[1:0] memWCD;
logic memWriteD;
logic jumpD;
logic branchD;
logic[2:0] branchSrcD;
logic _unsignedD;
logic[2:0] ALUControlD;
logic ALUSrcBD;
logic targetAddressSrcD;
logic CSRWriteDataSrcD;
logic[1:0] CSRWriteControlD;
logic readDataSrcD;
logic retireD;
logic privilegedInstrD;

logic[4:0] RS1D;
logic[4:0] RS2D;
logic[4:0] RDD;
logic[31:0] RD1D;
logic[31:0] RD2D;
logic[31:0] immExtD;

decodeCL decodeCL_inst(
    // Input
    .instrD          (instrD_reg),

    // Output
    .resultSrcD      (resultSrcD),
    .memExtD         (memExtD),
    .ALUResultSrcD   (ALUResultSrcD),
    .regWriteD       (regWriteD),
    .loadPCD         (loadPCD),
    .memWCD          (memWCD),
    .memWriteD       (memWriteD),
    .jumpD           (jumpD),
    .branchD         (branchD),
    .branchSrcD      (branchSrcD),
    ._unsignedD      (_unsignedD),
    .ALUControlD     (ALUControlD),
    .ALUSrcBD        (ALUSrcBD),
    .targetAddressSrcD(targetAddressSrcD),
    .CSRWriteDataSrcD (CSRWriteDataSrcD),
    .CSRWriteControlD (CSRWriteControlD),
    .readDataSrcD     (readDataSrcD),
    .retireD          (retireD),
    .privilegedInstrD (privilegedInstrD),

    //
    .RS1D            (RS1D),
    .RS2D            (RS2D),
    .RDD             (RDD),
    .RD1D            (RD1D),
    .RD2D            (RD2D),
    .immExtD         (immExtD),

    // Register file interface
    .rf_A1D          (rf_A1),
    .rf_A2D          (rf_A2),
    .rf_RD1D         (rf_RD1),
    .rf_RD2D         (rf_RD2)
);

always_ff @(posedge CLK, posedge reset) begin
    if (reset || flushE || trap) begin
        resultSrcE_reg <= 0;
        memExtE_reg <= 0;
        ALUResultSrcE_reg <= 0;
        regWriteE_reg <= 0;
        loadPCE_reg <= 0;
        memWCE_reg <= 0;
        memWriteE_reg <= 0;
        jumpE_reg <= 0;
        branchE_reg <= 0;
        branchSrcE_reg <= 0;
        _unsignedE_reg <= 0;
        ALUControlE_reg <= 0;
        ALUSrcBE_reg <= 0;
        targetAddressSrcE_reg <= 0;
        CSRWriteDataSrcE_reg <= 0;
        CSRWriteControlE_reg <= 0;
        readDataSrcE_reg <= 0;
        retireE_reg <= 0;
        privilegedInstrE_reg <= 0;

        RS1E_reg <= 0;
        RS2E_reg <= 0;
        RDE_reg <= 0;
        RD1E_reg <= 0;
        RD2E_reg <= 0;
        immExtE_reg <= 0;

        PCE_reg <= 0;
        PCPlus4E_reg <= 0;
    end
    else begin
        resultSrcE_reg <= resultSrcD;
        memExtE_reg <= memExtD;
        ALUResultSrcE_reg <= ALUResultSrcD;
        regWriteE_reg <= regWriteD;
        loadPCE_reg <= loadPCD;
        memWCE_reg <= memWCD;
        memWriteE_reg <= memWriteD;
        jumpE_reg <= jumpD;
        branchE_reg <= branchD;
        branchSrcE_reg <= branchSrcD;
        _unsignedE_reg <= _unsignedD;
        ALUControlE_reg <= ALUControlD;
        ALUSrcBE_reg <= ALUSrcBD;
        targetAddressSrcE_reg <= targetAddressSrcD;
        CSRWriteDataSrcE_reg <= CSRWriteDataSrcD;
        CSRWriteControlE_reg <= CSRWriteControlD;
        readDataSrcE_reg <= readDataSrcD;
        retireE_reg <= retireD;
        privilegedInstrE_reg <= privilegedInstrD;

        RS1E_reg <= RS1D;
        RS2E_reg <= RS2D;
        RDE_reg <= RDD;
        RD1E_reg <= RD1D;
        RD2E_reg <= RD2D;
        immExtE_reg <= immExtD;

        PCE_reg <= PCD_reg;
        PCPlus4E_reg <= PCPlus4D_reg;
    end
end

// ----------------> Execute <---------------- //

logic resultSrcM_reg;
logic[2:0] memExtM_reg;
logic regWriteM_reg;
logic[1:0] loadPCM_reg;
logic[1:0] memWCM_reg;
logic memWriteM_reg;
logic[31:0] immExtM_reg;
logic CSRWriteDataSrcM_reg;
logic[1:0] CSRWriteControlM_reg;
logic readDataSrcM_reg;
logic retireM_reg;

logic[31:0] ALUResultM_reg;
logic[31:0] writeDataM_reg;
logic[31:0] PCTargetM_reg;
logic[4:0] RDM_reg;
logic[31:0] PCPlus4M_reg;

logic PCSrcE;
logic[31:0] PCTargetE;
logic[31:0] ALUResultE;
logic[31:0] writeDataE;

logic[31:0] RD1E;
logic[31:0] RD2E;

always_comb begin
    case (forwardAE)
        2'b00: RD1E = RD1E_reg;
        2'b01: RD1E = loadPCResultM;
        2'b10: RD1E = resultW;
        default: RD1E = 32'bx;
    endcase

    case (forwardBE)
        2'b00: RD2E = RD2E_reg;
        2'b01: RD2E = loadPCResultM;
        2'b10: RD2E = resultW;
        default: RD2E = 32'bx;
    endcase
end

executeCL executeCL_inst(
    // Input
    .ALUSrcBE        (ALUSrcBE_reg),
    .immExtE         (immExtE_reg),
    .RD1E            (RD1E),
    .RD2E            (RD2E),
    .ALUControlE     (ALUControlE_reg),
    ._unsignedE      (_unsignedE_reg),
    .jumpE           (jumpE_reg),
    .branchE         (branchE_reg),
    .branchSrcE      (branchSrcE_reg),
    .PCE             (PCE_reg),
    .ALUResultSrcE   (ALUResultSrcE_reg),
    .targetAddressSrcE(targetAddressSrcE_reg),

    // Output
    .PCSrcE          (PCSrcE),
    .PCTargetE       (PCTargetE),
    .ALUResultE      (ALUResultE),
    .writeDataE      (writeDataE)
);

always_ff @(posedge CLK, posedge reset) begin
    if (reset || trap) begin
        resultSrcM_reg <= 0;
        memExtM_reg <= 0;
        regWriteM_reg <= 0;
        loadPCM_reg <= 0;
        memWCM_reg <= 0;
        memWriteM_reg <= 0;
        immExtM_reg <= 0;
        CSRWriteDataSrcM_reg <= 0;
        CSRWriteControlM_reg <= 0;
        readDataSrcM_reg <= 0;
        retireM_reg <= 0;

        ALUResultM_reg <= 0;
        writeDataM_reg <= 0;
        PCTargetM_reg <= 0;
        RDM_reg <= 0;
        PCPlus4M_reg <= 0;
    end
    else begin
        resultSrcM_reg <= resultSrcE_reg;
        memExtM_reg <= memExtE_reg;
        regWriteM_reg <= regWriteE_reg;
        loadPCM_reg <= loadPCE_reg;
        memWCM_reg <= memWCE_reg;
        memWriteM_reg <= memWriteE_reg;
        immExtM_reg <= immExtE_reg;
        CSRWriteDataSrcM_reg <= CSRWriteDataSrcE_reg;
        CSRWriteControlM_reg <= CSRWriteControlE_reg;
        readDataSrcM_reg <= readDataSrcE_reg;
        retireM_reg <= retireE_reg;

        ALUResultM_reg <= ALUResultE;
        writeDataM_reg <= writeDataE;
        PCTargetM_reg <= PCTargetE;
        RDM_reg <= RDE_reg;
        PCPlus4M_reg <= PCPlus4E_reg;
    end
end

// ----------------> Memory Commit <---------------- //
logic regWriteW_reg;
logic resultSrcW_reg;
logic[31:0] loadPCResultW_reg;
logic[31:0] readDataW_reg;
logic[4:0] RDW_reg;

logic[31:0] loadPCResultM;
logic[31:0] readDataM;

memoryCL memoryCL_inst(
    // Input
    .ALUResultM      (ALUResultM_reg),
    .PCTargetM       (PCTargetM_reg),
    .PCPlus4M        (PCPlus4M_reg),
    .loadPCM         (loadPCM_reg),
    .memWCM          (memWCM_reg),
    .writeDataM      (writeDataM_reg),
    .memWriteM       (memWriteM_reg),
    .memExtM         (memExtM_reg),
    .CSRWriteDataSrcM(CSRWriteDataSrcM_reg),
    .immExtM         (immExtM_reg),
    .CSRWriteControlM(CSRWriteControlM_reg),
    .readDataSrcM    (readDataSrcM_reg),

    // Output
    .loadPCResultM   (loadPCResultM),
    .readDataM       (readDataM),

    //Data memory interface
    .dmem_AddrM      (dmem_Addr),
    .dmem_RDM        (dmem_RD),
    .dmem_WEM        (dmem_WE),
    .dmem_WDM        (dmem_WD),
    .dmem_WCM        (dmem_WC),

    // CSR file interface
    .cf_AddrM        (cf_Addr),
    .cf_WDM          (cf_WD),
    .cf_WCM          (cf_WC),
    .cf_RDM          (cf_RD)
);

always_ff @(posedge CLK, posedge reset) begin
    if (reset) begin
        regWriteW_reg <= 0;
        resultSrcW_reg <= 0;
        loadPCResultW_reg <= 0;
        readDataW_reg <= 0;
        RDW_reg <= 0;
    end
    else begin
        regWriteW_reg <= regWriteM_reg;
        resultSrcW_reg <= resultSrcM_reg;
        loadPCResultW_reg <= loadPCResultM;
        readDataW_reg <= readDataM;
        RDW_reg <= RDM_reg;
    end
end

assign cf_retire = retireM_reg;

// ----------------> WriteBack <---------------- //

logic[31:0] PCW;
logic[31:0] resultW;

writeBackCL writeBackCL_inst(
    // Input
    .regWriteW       (regWriteW_reg),
    .resultSrcW      (resultSrcW_reg),
    .loadPCResultW   (loadPCResultW_reg),
    .readDataW       (readDataW_reg),
    .RDW             (RDW_reg),
    .resultW         (resultW),

    // Instruction memory interface
    .rf_A3W          (rf_A3),
    .rf_WD3W         (rf_WD3),
    .rf_WEW          (rf_WE)
);

assign PCW = PCSrcE ? PCTargetE : PCPlus4F;

always_ff @(posedge CLK, posedge reset) begin
    if (reset)
        PCF_reg <= 32'h00010000; // Init PC
    else if (trap)
        PCF_reg <= C_nextPC; // Trap
    else if(~stallF)
        PCF_reg <= PCW;
end

// Hazard Unit

hazardUnit hazardUnit_inst(
    // Sample Input
    .RS1D            (RS1D),
    .RS2D            (RS2D),
    .RS1E            (RS1E_reg),
    .RS2E            (RS2E_reg),
    .PCSrcE          (PCSrcE),
    .resultSrcE      (resultSrcE_reg),
    .RDM             (RDM_reg),
    .regWriteM       (regWriteM_reg),
    .regWriteW       (regWriteW_reg),
    .RDW             (RDW_reg),
    .RDE             (RDE_reg),

    // Output
    .stallF          (stallF),
    .stallD          (stallD),
    .flushD          (flushD),
    .flushE          (flushE),
    .forwardAE       (forwardAE),
    .forwardBE       (forwardBE)
);

// regFile
regFile regFile_inst(
    .A1         (rf_A1),
    .A2         (rf_A2),
    .A3         (rf_A3),
    .WD3        (rf_WD3),
    .RD1        (rf_RD1),
    .RD2        (rf_RD2),
    .WE         (rf_WE),
    .reset      (reset),
    .CLK        (~CLK) // Half cycle W-R
);

logic[4:0] C_A;
logic C_WE;
logic[31:0] C_WD;
logic[31:0] C_RD;

// CSRFile
CSRFile CSRFile_inst(
    .A          (cf_Addr),
    .WD         (cf_WD),
    .WC         (cf_WC),
    .RD         (cf_RD),
    .CLK        (CLK),
    .reset      (reset),
    .retire     (cf_retire),

    .C_A        (C_A),
    .C_WE       (C_WE),
    .C_WD       (C_WD),
    .C_RD       (C_RD)
);

logic iret;
logic exception;
logic[7:0] exceptionCode;
logic[31:0] savePC;

always_comb begin
    if (retireE_reg)
        savePC = PCE_reg;
    else if(retireD)
        savePC = PCD_reg;
    else
        savePC = PCF_reg;
end

// CLINT
CLINT CLINT_inst(
    .CLK             (CLK),
    .reset           (reset),
    .trap            (trap),
    .savePC          (savePC),
    .nextPC          (C_nextPC),
    
    // External interrupt
    .externalIRQ     (1'b0),

    // System timer interrupt
    .systemTimerIRQ  (systemTimerIRQ),

    // Exception
    .exception       (exception),
    .exceptionCode   (exceptionCode),
    .iret            (iret),

    .A               (C_A),
    .WE              (C_WE),
    .WD              (C_WD),
    .RD              (C_RD)
);

// ExceptionUnti
exceptionUnit exceptionUnit_inst(
    .privilegedInstrE(privilegedInstrE_reg),
    .immExtE         (immExtE_reg),
    
    .iret            (iret),
    .exception       (exception),
    .exceptionCode   (exceptionCode)
);

endmodule
