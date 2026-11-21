`timescale 1ns/1ps

module tb_matrix_mult_4x4;

    reg clk, reset, start;

    reg signed [7:0] A00, A01, A02, A03;
    reg signed [7:0] A10, A11, A12, A13;
    reg signed [7:0] A20, A21, A22, A23;
    reg signed [7:0] A30, A31, A32, A33;

    reg signed [7:0] B00, B01, B02, B03;
    reg signed [7:0] B10, B11, B12, B13;
    reg signed [7:0] B20, B21, B22, B23;
    reg signed [7:0] B30, B31, B32, B33;

    wire signed [19:0] C00, C01, C02, C03;
    wire signed [19:0] C10, C11, C12, C13;
    wire signed [19:0] C20, C21, C22, C23;
    wire signed [19:0] C30, C31, C32, C33;

    wire done;

    integer errors;

    matrix_mult_4x4 DUT(
        .clk(clk), .reset(reset), .start(start),
        .A00(A00), .A01(A01), .A02(A02), .A03(A03),
        .A10(A10), .A11(A11), .A12(A12), .A13(A13),
        .A20(A20), .A21(A21), .A22(A22), .A23(A23),
        .A30(A30), .A31(A31), .A32(A32), .A33(A33),
        .B00(B00), .B01(B01), .B02(B02), .B03(B03),
        .B10(B10), .B11(B11), .B12(B12), .B13(B13),
        .B20(B20), .B21(B21), .B22(B22), .B23(B23),
        .B30(B30), .B31(B31), .B32(B32), .B33(B33),
        .C00(C00), .C01(C01), .C02(C02), .C03(C03),
        .C10(C10), .C11(C11), .C12(C12), .C13(C13),
        .C20(C20), .C21(C21), .C22(C22), .C23(C23),
        .C30(C30), .C31(C31), .C32(C32), .C33(C33),
        .done(done)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task check(input signed [19:0] got, input signed [19:0] exp, input [8*8-1:0] name);
        begin
            $display("  %0s = %0d (expected %0d) %s", name, got, exp,
                       (got == exp) ? "OK" : "MISMATCH");
            if(got !== exp) errors = errors + 1;
        end
    endtask

    initial begin

        $dumpfile("matrix_mult_4x4.vcd");
        $dumpvars(0, tb_matrix_mult_4x4);

        errors = 0;

        reset = 1; start = 0;

        A00=0;A01=0;A02=0;A03=0;
        A10=0;A11=0;A12=0;A13=0;
        A20=0;A21=0;A22=0;A23=0;
        A30=0;A31=0;A32=0;A33=0;
        B00=0;B01=0;B02=0;B03=0;
        B10=0;B11=0;B12=0;B13=0;
        B20=0;B21=0;B22=0;B23=0;
        B30=0;B31=0;B32=0;B33=0;

        #20;
        reset = 0;
        #10;

        // A = |  1   2   3   4 |    B = |  2   0   1  -1 |
        //     |  5   6  -7   8 |        |  1   3  -2   2 |
        //     | -9  10  11 -12 |        |  0  -1   4   1 |
        //     | 13 -14  15  16 |        | -3   2   1   0 |
        //
        // Expected C (from numpy reference):
        // | -8   11   13    6 |
        // | -8   41  -27    0 |
        // | 28   -5    3   40 |
        // |-36  -25  117  -26 |

        A00=8'sd1;  A01=8'sd2;   A02=8'sd3;  A03=8'sd4;
        A10=8'sd5;  A11=8'sd6;   A12=-8'sd7; A13=8'sd8;
        A20=-8'sd9; A21=8'sd10;  A22=8'sd11; A23=-8'sd12;
        A30=8'sd13; A31=-8'sd14; A32=8'sd15; A33=8'sd16;

        B00=8'sd2;  B01=8'sd0;  B02=8'sd1;  B03=-8'sd1;
        B10=8'sd1;  B11=8'sd3;  B12=-8'sd2; B13=8'sd2;
        B20=8'sd0;  B21=-8'sd1; B22=8'sd4;  B23=8'sd1;
        B30=-8'sd3; B31=8'sd2;  B32=8'sd1;  B33=8'sd0;

        start = 1;
        #10;
        start = 0;

        wait(done);
        #20;

        $display("--------------------------------------------------");
        $display("Test: 4x4 mixed-sign multiply");

        check(C00, -20'sd8,   "C00");
        check(C01,  20'sd11,  "C01");
        check(C02,  20'sd13,  "C02");
        check(C03,  20'sd6,   "C03");

        check(C10, -20'sd8,   "C10");
        check(C11,  20'sd41,  "C11");
        check(C12, -20'sd27,  "C12");
        check(C13,  20'sd0,   "C13");

        check(C20,  20'sd28,  "C20");
        check(C21, -20'sd5,   "C21");
        check(C22,  20'sd3,   "C22");
        check(C23,  20'sd40,  "C23");

        check(C30, -20'sd36,  "C30");
        check(C31, -20'sd25,  "C31");
        check(C32,  20'sd117, "C32");
        check(C33, -20'sd26,  "C33");

        $display("--------------------------------------------------");
        if(errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d MISMATCH(ES) FOUND", errors);
        $display("--------------------------------------------------");

        $finish;

    end

endmodule
