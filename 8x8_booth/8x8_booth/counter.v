module counter(

    input clk,
    input clr,

    input ldcnt,
    input decr,

    output reg [2:0] count,
    output eqz

);

always @(posedge clk)
begin

    if(clr)
        count <= 3'd0;

    else if(ldcnt)
        count <= 3'd4;

    else if(decr)
        count <= count - 1'b1;

end

assign eqz = (count == 3'd0);

endmodule