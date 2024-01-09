module adder32 (
    input logic[31:0] a,
    input logic[31:0] b,
    input logic cin,
    output logic[31:0] s,
    output logic cout
);

assign {cout, s} = {1'b0, a} + {1'b0, b} + {{32{1'b0}}, cin};
    
endmodule
