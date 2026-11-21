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
        .C20(C20), .C21(C21), .C22(C23), .C23(C23),
        .C30(C30), .C31(C31), .C32(C32), .C33(C33),
        .done(done)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task check(input signed [19:0] got, input signed [19:0] exp, input [8*8-1:0] name);
        begin
            if(got !== exp) begin
                $display("  MISMATCH %0s: got %0d, expected %0d", name, got, exp);
                errors = errors + 1;
            end
        end
    endtask

    task apply_and_check;
        input [8*20:1] test_name;
        // Expected matrix C
        input signed [19:0] eC00, eC01, eC02, eC03;
        input signed [19:0] eC10, eC11, eC12, eC13;
        input signed [19:0] eC20, eC21, eC22, eC23;
        input signed [19:0] eC30, eC31, eC32, eC33;
        begin
            start = 1; #10; start = 0;
            wait(done); #10;
            $display("Running %0s...", test_name);
            check(C00, eC00, "C00"); check(C01, eC01, "C01"); check(C02, eC02, "C02"); check(C03, eC03, "C03");
            check(C10, eC10, "C10"); check(C11, eC11, "C11"); check(C12, eC12, "C12"); check(C13, eC13, "C13");
            check(C20, eC20, "C20"); check(C21, eC21, "C21"); check(C22, eC22, "C22"); check(C23, eC23, "C23");
            check(C30, eC30, "C30"); check(C31, eC31, "C31"); check(C32, eC32, "C32"); check(C33, eC33, "C33");
            #20;
        end
    endtask

    initial begin
        errors = 0;
        reset = 1; start = 0; #20; reset = 0; #10;

        // TC01: All-zero matrices (Boundary)
        A00=0; A01=0; A02=0; A03=0; A10=0; A11=0; A12=0; A13=0;
        A20=0; A21=0; A22=0; A23=0; A30=0; A31=0; A32=0; A33=0;
        B00=0; B01=0; B02=0; B03=0; B10=0; B11=0; B12=0; B13=0;
        B20=0; B21=0; B22=0; B23=0; B30=0; B31=0; B32=0; B33=0;
        apply_and_check("TC01 All-Zero", 
            0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0);

        // TC02: Identity x Identity (Boundary)
        A00=1; A01=0; A02=0; A03=0; A10=0; A11=1; A12=0; A13=0;
        A20=0; A21=0; A22=1; A23=0; A30=0; A31=0; A32=0; A33=1;
        B00=1; B01=0; B02=0; B03=0; B10=0; B11=1; B12=0; B13=0;
        B20=0; B21=0; B22=1; B23=0; B30=0; B31=0; B32=0; B33=1;
        apply_and_check("TC02 Identity", 
            1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1);

        // TC11: (-128)x(-128) diagonal - Max product magnitude (Stress)[cite: 6]
        A00=-128; A01=0; A02=0; A03=0; A10=0; A11=-128; A12=0; A13=0;
        A20=0; A21=0; A22=-128; A23=0; A30=0; A31=0; A32=0; A33=-128;
        B00=-128; B01=0; B02=0; B03=0; B10=0; B11=-128; B12=0; B13=0;
        B20=0; B21=0; B22=-128; B23=0; B30=0; B31=0; B32=0; B33=-128;
        apply_and_check("TC11 Max Mag", 
            16384,0,0,0, 0,16384,0,0, 0,0,16384,0, 0,0,0,16384);

        // TC50: Worst-case CSA stress (Stress)[cite: 6]
        A00=127; A01=127; A02=127; A03=127; A10=127; A11=127; A12=127; A13=127;
        A20=127; A21=127; A22=127; A23=127; A30=127; A31=127; A32=127; A33=127;
        B00=-128; B01=-128; B02=-128; B03=-128; B10=-128; B11=-128; B12=-128; B13=-128;
        B20=-128; B21=-128; B22=-128; B23=-128; B30=-128; B31=-128; B32=-128; B33=-128;
        apply_and_check("TC50 Worst-Case CSA", 
            -65024,-65024,-65024,-65024, -65024,-65024,-65024,-65024, -65024,-65024,-65024,-65024, -65024,-65024,-65024,-65024);

        $display("--------------------------------------------------");
        if(errors == 0) $display("ALL TESTS PASSED");
        else $display("%0d MISMATCH(ES) FOUND", errors);
        $display("--------------------------------------------------");
        $finish;
    end
endmodule