module uartController(
    input CLK,
    input reset,

    output logic txPort,
    input logic rxPort,

    input logic[31:0] A,
    input logic WE,
    input logic[31:0] WD,
    output logic[31:0] RD,

    output logic sel
);

logic[15:0] baudcmp_reg;
logic[7:0] send_data_reg;

// 0: send pending
logic[31:0] status_reg;

// Selection logic
assign sel = A[31:8] == 24'h2000_01;

// uartTxPort
logic wready;
uartTxPort uartTxPort_inst(
    .CLK        (CLK),
    .reset      (reset),
    .baudcmp    (baudcmp_reg),
    .data       (send_data_reg),
    .wvaild     (status_reg[0]),
    .wready     (wready),
    .txPort     (txPort)
);

// uartRxPort
logic[7:0] read_data;
logic rvaild;
uartRxPort uartRxPort_inst(
    .CLK        (CLK),
    .reset      (reset),
    .baudcmp    (baudcmp_reg),
    .data       (read_data),
    .rvaild     (rvaild),
    .rready     (~status_reg[1]),
    .rxPort     (rxPort)
);

// Write logic
always_ff @(posedge CLK, posedge reset) begin
    if (reset) begin
        baudcmp_reg <= 0;
        send_data_reg <= 0;
        status_reg <= 0;
    end
    else begin
        if (wready) status_reg[0] <= 1'b0;
        if (rvaild) status_reg[1] <= 1'b1;
        if (sel && WE)
            case (A[7:0])
                8'h00: baudcmp_reg <= WD[15:0];
                8'h04: send_data_reg <= WD[7:0];
                8'h08: status_reg <= WD;
                default: begin end
            endcase
    end
end

// Read logic
always_comb begin
    case (A[7:0])
        8'h00: RD = {{16{1'b0}}, baudcmp_reg};
        8'h04: RD = {{24{1'b0}}, send_data_reg};
        8'h08: RD = status_reg;
        8'h0C: RD = {{24{1'b0}}, read_data};
        default: RD = 32'bx;
    endcase
end

endmodule
