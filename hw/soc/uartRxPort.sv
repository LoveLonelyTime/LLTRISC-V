module uartRxPort (
    input logic CLK,
    input logic reset,
    input logic[15:0] baudcmp,
    output logic[7:0] data,
    output logic rvaild,
    input logic rready,
    input logic rxPort
);

typedef enum logic[1:0] {S_WAIT, S_TRANS, S_END} statetype;

logic[15:0] baudcnt_reg;
logic[9:0] readData_sreg;

statetype state, nextstate;

always_comb begin
    case (state)
        S_WAIT: nextstate = rxPort ? S_WAIT : S_TRANS;
        S_TRANS: nextstate = readData_sreg[9] ? S_TRANS : S_END;
        S_END: nextstate = rready ? S_WAIT : S_END;
        default: nextstate = S_WAIT;
    endcase
end

// Baud logics
always_ff @(posedge reset, posedge CLK) begin
    if (reset) begin
        state <= S_WAIT;
    end
    else state <= nextstate;
end

always_ff @(posedge CLK) begin
    case (state)
        S_WAIT: begin
            baudcnt_reg <= 0;
            readData_sreg <= 10'b11111_11111;
        end
        S_TRANS: begin
            if (baudcnt_reg == {1'b0, baudcmp[15:1]}) begin
                readData_sreg <= {readData_sreg[8:0], rxPort};
            end
            if(baudcnt_reg == baudcmp[15:0]) baudcnt_reg <= 0;
            else baudcnt_reg <= baudcnt_reg + 1;
        end
        default: begin end
    endcase
end

assign rvaild = nextstate == S_END;
assign data = {readData_sreg[1],readData_sreg[2],readData_sreg[3],readData_sreg[4],readData_sreg[5],readData_sreg[6],readData_sreg[7],readData_sreg[8]};
    
endmodule
