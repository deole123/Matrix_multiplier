// ====================================================================
// matrix_mult_4x4.v
//
// Computes C = A * B for two 4x4 signed 8-bit matrices, using 16
// mac_unit4 instances (one per output cell), each internally built
// on the radix-4 Booth multiplier and a carry-save adder (CSA) for
// accumulating its 4 partial products.
//
//   A[i][k], i,k = 0..3  (row-major)
//   B[k][j], k,j = 0..3  (row-major)
//
//   C[i][j] = sum_{k=0..3} A[i][k] * B[k][j]
//
// All 16 MAC units run in parallel (each has its own radix4_top
// multiplier instance) and finish at the same time, since the Booth
// multiplier's latency is fixed and independent of operand values.
// ====================================================================

module matrix_mult_4x4(

    input clk,
    input reset,
    input start,

    // A matrix, row-major: A[row][col]
    input signed [7:0] A00, A01, A02, A03,
    input signed [7:0] A10, A11, A12, A13,
    input signed [7:0] A20, A21, A22, A23,
    input signed [7:0] A30, A31, A32, A33,

    // B matrix, row-major: B[row][col]
    input signed [7:0] B00, B01, B02, B03,
    input signed [7:0] B10, B11, B12, B13,
    input signed [7:0] B20, B21, B22, B23,
    input signed [7:0] B30, B31, B32, B33,

    // C matrix, row-major: C[row][col]
    output signed [19:0] C00, C01, C02, C03,
    output signed [19:0] C10, C11, C12, C13,
    output signed [19:0] C20, C21, C22, C23,
    output signed [19:0] C30, C31, C32, C33,

    output done

);

wire [15:0] d; // one done bit per MAC (16 total), packed for readability

//---------------------------------------------------
// Row 0 : C0j = A_row0 . B_colj
//---------------------------------------------------
mac_unit4 MAC00(.clk(clk), .reset(reset), .start(start),
    .a0(A00), .a1(A01), .a2(A02), .a3(A03),
    .b0(B00), .b1(B10), .b2(B20), .b3(B30),
    .result(C00), .done(d[0]));

mac_unit4 MAC01(.clk(clk), .reset(reset), .start(start),
    .a0(A00), .a1(A01), .a2(A02), .a3(A03),
    .b0(B01), .b1(B11), .b2(B21), .b3(B31),
    .result(C01), .done(d[1]));

mac_unit4 MAC02(.clk(clk), .reset(reset), .start(start),
    .a0(A00), .a1(A01), .a2(A02), .a3(A03),
    .b0(B02), .b1(B12), .b2(B22), .b3(B32),
    .result(C02), .done(d[2]));

mac_unit4 MAC03(.clk(clk), .reset(reset), .start(start),
    .a0(A00), .a1(A01), .a2(A02), .a3(A03),
    .b0(B03), .b1(B13), .b2(B23), .b3(B33),
    .result(C03), .done(d[3]));

//---------------------------------------------------
// Row 1 : C1j = A_row1 . B_colj
//---------------------------------------------------
mac_unit4 MAC10(.clk(clk), .reset(reset), .start(start),
    .a0(A10), .a1(A11), .a2(A12), .a3(A13),
    .b0(B00), .b1(B10), .b2(B20), .b3(B30),
    .result(C10), .done(d[4]));

mac_unit4 MAC11(.clk(clk), .reset(reset), .start(start),
    .a0(A10), .a1(A11), .a2(A12), .a3(A13),
    .b0(B01), .b1(B11), .b2(B21), .b3(B31),
    .result(C11), .done(d[5]));

mac_unit4 MAC12(.clk(clk), .reset(reset), .start(start),
    .a0(A10), .a1(A11), .a2(A12), .a3(A13),
    .b0(B02), .b1(B12), .b2(B22), .b3(B32),
    .result(C12), .done(d[6]));

mac_unit4 MAC13(.clk(clk), .reset(reset), .start(start),
    .a0(A10), .a1(A11), .a2(A12), .a3(A13),
    .b0(B03), .b1(B13), .b2(B23), .b3(B33),
    .result(C13), .done(d[7]));

//---------------------------------------------------
// Row 2 : C2j = A_row2 . B_colj
//---------------------------------------------------
mac_unit4 MAC20(.clk(clk), .reset(reset), .start(start),
    .a0(A20), .a1(A21), .a2(A22), .a3(A23),
    .b0(B00), .b1(B10), .b2(B20), .b3(B30),
    .result(C20), .done(d[8]));

mac_unit4 MAC21(.clk(clk), .reset(reset), .start(start),
    .a0(A20), .a1(A21), .a2(A22), .a3(A23),
    .b0(B01), .b1(B11), .b2(B21), .b3(B31),
    .result(C21), .done(d[9]));

mac_unit4 MAC22(.clk(clk), .reset(reset), .start(start),
    .a0(A20), .a1(A21), .a2(A22), .a3(A23),
    .b0(B02), .b1(B12), .b2(B22), .b3(B32),
    .result(C22), .done(d[10]));

mac_unit4 MAC23(.clk(clk), .reset(reset), .start(start),
    .a0(A20), .a1(A21), .a2(A22), .a3(A23),
    .b0(B03), .b1(B13), .b2(B23), .b3(B33),
    .result(C23), .done(d[11]));

//---------------------------------------------------
// Row 3 : C3j = A_row3 . B_colj
//---------------------------------------------------
mac_unit4 MAC30(.clk(clk), .reset(reset), .start(start),
    .a0(A30), .a1(A31), .a2(A32), .a3(A33),
    .b0(B00), .b1(B10), .b2(B20), .b3(B30),
    .result(C30), .done(d[12]));

mac_unit4 MAC31(.clk(clk), .reset(reset), .start(start),
    .a0(A30), .a1(A31), .a2(A32), .a3(A33),
    .b0(B01), .b1(B11), .b2(B21), .b3(B31),
    .result(C31), .done(d[13]));

mac_unit4 MAC32(.clk(clk), .reset(reset), .start(start),
    .a0(A30), .a1(A31), .a2(A32), .a3(A33),
    .b0(B02), .b1(B12), .b2(B22), .b3(B32),
    .result(C32), .done(d[14]));

mac_unit4 MAC33(.clk(clk), .reset(reset), .start(start),
    .a0(A30), .a1(A31), .a2(A32), .a3(A33),
    .b0(B03), .b1(B13), .b2(B23), .b3(B33),
    .result(C33), .done(d[15]));

//---------------------------------------------------
// Combined done: all 16 cells finished
//---------------------------------------------------
assign done = &d;

endmodule
