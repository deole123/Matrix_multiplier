module A_register(
    input clk,
    input clrA,
    input ldA,
    input sftA2,

    input [15:0] Z,

    output reg [15:0] A
);

always @(posedge clk)
begin

    if(clrA)
        A <= 16'd0;

    else if(ldA)
        A <= Z;

    else if(sftA2)
        A <= {A[15], A[15], A[15:2]};

end

endmodule