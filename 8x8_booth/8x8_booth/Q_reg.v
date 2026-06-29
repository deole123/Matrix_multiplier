module Q_register(

    input clk,
    input clrQ,
    input ldQ,
    input sftQ2,

    input [15:0] data_in,

    input [1:0] Ain,

    output reg [15:0] Q

);

always @(posedge clk)
begin

    if(clrQ)
        Q <= 16'd0;

    else if(ldQ)
        Q <= data_in;

    else if(sftQ2)
        Q <= {Ain, Q[15:2]};

end

endmodule