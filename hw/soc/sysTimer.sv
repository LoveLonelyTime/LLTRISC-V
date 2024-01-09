module sysTimer (
    input logic CLK,
    input logic reset,

    output logic systemTimerIRQ,

    input logic[31:0] A,
    input logic WE,
    input logic[31:0] WD,
    output logic[31:0] RD,

    output logic sel
);

logic[63:0] mtime_reg;
logic[63:0] mtimecmp_reg;

// Selection logic
assign sel = A[31:8] == 24'h2000_00;

// Read logic
always_comb begin
    case (A[7:0])
        8'h00 : RD = mtime_reg[31:0];
        8'h04 : RD = mtime_reg[63:32];
        8'h08 : RD = mtimecmp_reg[31:0];
        8'h0C : RD = mtimecmp_reg[31:0];
        default: RD = 32'bx;
    endcase
end

// Write logic
always_ff @(posedge CLK, posedge reset) begin
    if (reset) begin
        mtime_reg <= 0;
        mtimecmp_reg <= 0;
    end
    else begin
        if (sel && A[7:0] == 8'h00 && WE)
            mtime_reg[31:0] <= WD;
        else if (sel && A[7:0] == 8'h04 && WE)
            mtime_reg[63:32] <= WD;
        else
            mtime_reg <= mtime_reg + 1'b1;

        if (sel && A[7:0] == 8'h08 && WE)
            mtimecmp_reg[31:0] <= WD;
        else if (sel && A[7:0] == 8'h0C && WE)
            mtimecmp_reg[63:32] <= WD;
    end
        
end

assign systemTimerIRQ = mtime_reg > mtimecmp_reg;
    
endmodule
