module history_reg(

    input clk,
    input clrff,
    input ld,

    input qm1_in,

    output reg qm1

);

always @(posedge clk)
begin

    if(clrff)
        qm1 <= 1'b0;

    else if(ld)
        qm1 <= qm1_in;

end

endmodule