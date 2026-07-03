// ====================================================================
// matrix_mult_2x2.v
//
// Computes C = A * B for two 2x2 signed 8-bit matrices, using 4
// mac_unit instances (one per output cell), each internally built on
// the radix-4 Booth multiplier.
//
//   A = | A00 A01 |      B = | B00 B01 |
//       | A10 A11 |          | B10 B11 |
//
//   C = A*B:
//   C00 = A00*B00 + A01*B10
//   C01 = A00*B01 + A01*B11
//   C10 = A10*B00 + A11*B10
//   C11 = A10*B01 + A11*B11
//
// All 4 MAC units run in parallel (each has its own multiplier
// instance) and finish at the same time, since the Booth multiplier's
// latency is fixed and does not depend on the operand values.
// ====================================================================

module matrix_mult_2x2(

    input clk,
    input reset,
    input start,

    input signed [7:0] A00, A01, A10, A11,
    input signed [7:0] B00, B01, B10, B11,

    output signed [17:0] C00, C01, C10, C11,

    output done

);

wire d00, d01, d10, d11;

//---------------------------------------------------
// MAC unit for C00 = A_row0 . B_col0
//---------------------------------------------------
mac_unit MAC00(
    .clk(clk), .reset(reset), .start(start),
    .a0(A00), .a1(A01),
    .b0(B00), .b1(B10),
    .result(C00),
    .done(d00)
);

//---------------------------------------------------
// MAC unit for C01 = A_row0 . B_col1
//---------------------------------------------------
mac_unit MAC01(
    .clk(clk), .reset(reset), .start(start),
    .a0(A00), .a1(A01),
    .b0(B01), .b1(B11),
    .result(C01),
    .done(d01)
);

//---------------------------------------------------
// MAC unit for C10 = A_row1 . B_col0
//---------------------------------------------------
mac_unit MAC10(
    .clk(clk), .reset(reset), .start(start),
    .a0(A10), .a1(A11),
    .b0(B00), .b1(B10),
    .result(C10),
    .done(d10)
);

//---------------------------------------------------
// MAC unit for C11 = A_row1 . B_col1
//---------------------------------------------------
mac_unit MAC11(
    .clk(clk), .reset(reset), .start(start),
    .a0(A10), .a1(A11),
    .b0(B01), .b1(B11),
    .result(C11),
    .done(d11)
);

//---------------------------------------------------
// Combined done: all four cells finished
//---------------------------------------------------
assign done = d00 & d01 & d10 & d11;

endmodule
