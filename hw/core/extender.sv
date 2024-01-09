module extender (
    input logic[24:0] src,
    input logic[2:0] extControl,
    output logic[31:0] result
);

always_comb begin
    case (extControl)
        3'b000: result = {{20{src[24]}}, src[24:13]}; // I-Type
        3'b001: result = {{20{src[24]}}, src[24:18], src[4:0]}; // S-Type
        3'b010: result = {{19{src[24]}}, src[24], src[0], src[23:18], src[4:1], 1'b0}; // B-Type
        3'b011: result = {src[24:5],12'b0}; // U-Type
        3'b100: result = {{11{src[24]}}, src[24], src[12:5], src[13], src[23:14], 1'b0}; // J-Type
        3'b101: result = {{27{1'b0}}, src[17:13]}; // uimm I-Type
        3'b110: result = {src, {7{1'b0}}}; // Bypass-Type
        default: result = 32'bx; // ?
    endcase
end
    
endmodule
