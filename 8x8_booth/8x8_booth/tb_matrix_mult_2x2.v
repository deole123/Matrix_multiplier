`timescale 1ns/1ps

module tb_matrix_mult_2x2;

    reg clk, reset, start;

    reg signed [7:0] A00, A01, A10, A11;
    reg signed [7:0] B00, B01, B10, B11;

    wire signed [17:0] C00, C01, C10, C11;
    wire done;

    integer errors;

    //----------------------------------------------------
    // DUT
    //----------------------------------------------------

    matrix_mult_2x2 DUT(

        .clk(clk),
        .reset(reset),
        .start(start),

        .A00(A00), .A01(A01), .A10(A10), .A11(A11),
        .B00(B00), .B01(B01), .B10(B10), .B11(B11),

        .C00(C00), .C01(C01), .C10(C10), .C11(C11),

        .done(done)

    );

    //----------------------------------------------------
    // Clock
    //----------------------------------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //----------------------------------------------------
    // Task: run one 2x2 * 2x2 multiply and check the result
    //----------------------------------------------------

    task run_case;
        input signed [7:0] a00, a01, a10, a11;
        input signed [7:0] b00, b01, b10, b11;
        input signed [17:0] exp00, exp01, exp10, exp11;
        input [127:0] name; // ASCII label for $display
        begin

            A00 = a00; A01 = a01; A10 = a10; A11 = a11;
            B00 = b00; B01 = b01; B10 = b10; B11 = b11;

            start = 1;
            #10;
            start = 0;

            wait(done);
            #20;

$display("  A = | %0d %0d |   B = | %0d %0d |", a00, a01, b00, b01);
$display("      | %0d %0d |       | %0d %0d |", a10, a11, b10, b11);

            $display("--------------------------------------------------");
            $display("Test: %0s", name);
            $display("  C00 = %0d  (expected %0d)  %s", $signed(C00), exp00, ($signed(C00)==exp00) ? "OK" : "MISMATCH");
            $display("  C01 = %0d  (expected %0d)  %s", $signed(C01), exp01, ($signed(C01)==exp01) ? "OK" : "MISMATCH");
            $display("  C10 = %0d  (expected %0d)  %s", $signed(C10), exp10, ($signed(C10)==exp10) ? "OK" : "MISMATCH");
            $display("  C11 = %0d  (expected %0d)  %s", $signed(C11), exp11, ($signed(C11)==exp11) ? "OK" : "MISMATCH");

            if($signed(C00) !== exp00) errors = errors + 1;
            if($signed(C01) !== exp01) errors = errors + 1;
            if($signed(C10) !== exp10) errors = errors + 1;
            if($signed(C11) !== exp11) errors = errors + 1;

            #20;

        end
    endtask

    //----------------------------------------------------
    // Test sequence
    //----------------------------------------------------

    initial begin

        $dumpfile("matrix_mult.vcd");
        $dumpvars(0, tb_matrix_mult_2x2);

        errors = 0;

        reset = 1; start = 0;
        A00=0; A01=0; A10=0; A11=0;
        B00=0; B01=0; B10=0; B11=0;
        #20;
        reset = 0;
        #10;

        // Test 1: all positive
        // A = |1 2|   B = |5 6|
        //     |3 4|       |7 8|
        // C = |19 22|
        //     |43 50|
        run_case(8'sd1, 8'sd2, 8'sd3, 8'sd4,
                  8'sd5, 8'sd6, 8'sd7, 8'sd8,
                  18'sd19, 18'sd22, 18'sd43, 18'sd50,
                  "positive 2x2");

        // Test 2: mixed signs
        // A = |-1  2|   B = | 5 -6|
        //     | 3 -4|       |-7  8|
        // C00 = -1*5 + 2*-7  = -19
        // C01 = -1*-6 + 2*8  =  22
        // C10 =  3*5 + -4*-7 =  43
        // C11 =  3*-6 + -4*8 = -50
        run_case(-8'sd1, 8'sd2, 8'sd3, -8'sd4,
                  8'sd5, -8'sd6, -8'sd7, 8'sd8,
                  -18'sd19, 18'sd22, 18'sd43, -18'sd50,
                  "mixed sign 2x2");

        // Test 3: identity matrix on the right
        // A = |6 -3|   B = |1 0|
        //     |9  2|       |0 1|
        // C = A
        run_case(8'sd6, -8'sd3, 8'sd9, 8'sd2,
                  8'sd1, 8'sd0, 8'sd0, 8'sd1,
                  18'sd6, -18'sd3, 18'sd9, 18'sd2,
                  "identity B");

        // Test 4: larger magnitude, both negative
        // A = |-12  20|   B = |-15   9|
        //     | 30 -25|       | 11 -18|
        // C00 = -12*-15 + 20*11   = 180+220 = 400
        // C01 = -12*9   + 20*-18  = -108-360 = -468
        // C10 =  30*-15 + -25*11  = -450-275 = -725
        // C11 =  30*9   + -25*-18 = 270+450  = 720
        run_case(-8'sd12, 8'sd20, 8'sd30, -8'sd25,
                  -8'sd15, 8'sd9, 8'sd11, -8'sd18,
                  18'sd400, -18'sd468, -18'sd725, 18'sd720,
                  "large magnitude, negatives");

        $display("--------------------------------------------------");
        if(errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d MISMATCH(ES) FOUND", errors);
        $display("--------------------------------------------------");

        $finish;

    end

endmodule
