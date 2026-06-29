module operand_generator(

    input [15:0] M,

    input sign,
    input [1:0] mag_sel,

    output reg [15:0] operand

);

reg [15:0] temp;

always @(*)
begin

    case(mag_sel)

        2'b00:
            temp = 16'b0;

        2'b01:
            temp = M;

        2'b10:
            temp = M << 1;

        default:
            temp = 16'b0;

    endcase


    if(sign)
        operand = ~temp + 16'd1;

    else
        operand = temp;

end

endmodule