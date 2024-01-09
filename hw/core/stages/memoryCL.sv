module memoryCL (
    input logic[31:0] ALUResultM,
    input logic[31:0] PCTargetM,
    input logic[31:0] PCPlus4M,
    input logic[1:0] loadPCM,
    input logic[1:0] memWCM,
    input logic[31:0] writeDataM,
    input logic memWriteM,
    input logic[2:0] memExtM,
    input logic CSRWriteDataSrcM,
    input logic[31:0] immExtM,
    input logic[1:0] CSRWriteControlM,
    input logic readDataSrcM,


    output logic[31:0] loadPCResultM,
    output logic[31:0] readDataM,

    // Data memory interface
    output logic[31:0] dmem_AddrM,
    input logic[31:0] dmem_RDM,
    output logic dmem_WEM,
    output logic[31:0] dmem_WDM,
    output logic[1:0] dmem_WCM,

    // CSR file interface
    output logic[11:0] cf_AddrM,
    output logic[31:0] cf_WDM,
    output logic[1:0] cf_WCM,
    input logic[31:0] cf_RDM
);

always_comb begin
    case (loadPCM)
        2'b00: loadPCResultM = ALUResultM;
        2'b01: loadPCResultM = PCTargetM;
        2'b10: loadPCResultM = PCPlus4M;
        default: loadPCResultM = 32'bx;
    endcase
end

assign dmem_AddrM = ALUResultM;
assign dmem_WCM = memWCM;
assign dmem_WDM = writeDataM;
assign dmem_WEM = memWriteM;

logic[31:0] memReadDataExtM;

always_comb begin
    case (memExtM)
        3'b000: memReadDataExtM = {{24{dmem_RDM[7]}}, dmem_RDM[7:0]};
        3'b001: memReadDataExtM = {{16{dmem_RDM[15]}}, dmem_RDM[15:0]};
        3'b010: memReadDataExtM = dmem_RDM;
        3'b011: memReadDataExtM = {{24{1'b0}}, dmem_RDM[7:0]};
        3'b100: memReadDataExtM = {{16{1'b0}}, dmem_RDM[15:0]};
        default: memReadDataExtM = 32'bx;
    endcase
end

// CSRFile

assign cf_WDM = CSRWriteDataSrcM ? {{27{1'b0}} ,immExtM[19:15]} : ALUResultM;
assign cf_AddrM = immExtM[31:20];
assign cf_WCM = CSRWriteControlM;

assign readDataM = readDataSrcM ? cf_RDM : memReadDataExtM;
endmodule
