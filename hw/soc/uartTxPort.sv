module uartTxPort (
    input logic CLK,
    input logic reset,
    input logic[15:0] baudcmp,
    input logic[7:0] data,
    input logic wvaild,
    output logic wready,
    output logic txPort
);

typedef enum logic[1:0] {S_WAIT, S_TRANS, S_END} statetype;

logic[15:0] baudcnt_reg;
logic[9:0] sendData_sreg;

statetype state, nextstate;

always_comb begin
    case (state)
        S_WAIT: nextstate = wvaild ? S_TRANS : S_WAIT;
        S_TRANS: nextstate = |sendData_sreg ? S_TRANS : S_END;
        S_END: nextstate = S_WAIT;
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
            sendData_sreg <= {1'b0, data, 1'b1};
            txPort <= 1'b1;
        end
        S_TRANS: begin
            if (baudcnt_reg == baudcmp) begin
                baudcnt_reg <= 0;
                txPort <= sendData_sreg[9];
                sendData_sreg <= {sendData_sreg[8:0], 1'b0};
            end
            else
                baudcnt_reg <= baudcnt_reg + 1;
        end
        default: begin end
    endcase
end

assign wready = state == S_END;
    
endmodule
