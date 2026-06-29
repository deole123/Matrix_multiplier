module ALU(

    input signed [15:0] A,
    input signed [15:0] operand,

    output signed [15:0] Z

);

assign Z = A + operand;

endmodule