// 00 → 0

// 01 → M

// 10 → 2M

// 11 → Reserved




module booth_encoder(

    input Q1,
    input Q0,
    input qm1,

    output reg sign,
    output reg [1:0] mag_sel

);

always @(*)
begin

    case({Q1,Q0,qm1})

        3'b000:
        begin
            sign = 0;
            mag_sel = 2'b00;
        end

        3'b001:
        begin
            sign = 0;
            mag_sel = 2'b01;
        end

        3'b010:
        begin
            sign = 0;
            mag_sel = 2'b01;
        end

        3'b011:
        begin
            sign = 0;
            mag_sel = 2'b10;
        end

        3'b100:
        begin
            sign = 1;
            mag_sel = 2'b10;
        end

        3'b101:
        begin
            sign = 1;
            mag_sel = 2'b01;
        end

        3'b110:
        begin
            sign = 1;
            mag_sel = 2'b01;
        end

        3'b111:
        begin
            sign = 0;
            mag_sel = 2'b00;
        end

    endcase

end

endmodule