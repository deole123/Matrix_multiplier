module shiftreg2
#(
    parameter N = 16
)
(
    output reg [N-1:0] data_out,

    input      [N-1:0] data_in,
    input              s_in,
    input              clk,

    input              ld,
    input              clr,
    input              sft2
);

always @(posedge clk)
begin

    if(clr)
        data_out <= 0;

    else if(ld)
        data_out <= data_in;

    else if(sft2)

        // Arithmetic Right Shift by 2
        data_out <= { {2{s_in}}, data_out[N-1:2] };

end

endmodule

