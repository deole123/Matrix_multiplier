`timescale 1ns/1ps

module tb_radix4;

    // Inputs
    reg clk;
    reg reset;
    reg start;

    reg [7:0] multiplicand;
    reg [7:0] multiplier;

    // Outputs
    wire [15:0] product;
    wire done;

    //----------------------------------------------------
    // DUT
    //----------------------------------------------------

    radix4_top DUT(

        .clk(clk),
        .reset(reset),
        .start(start),

        .multiplicand(multiplicand),
        .multiplier(multiplier),

        .product(product),
        .done(done)

    );

    //----------------------------------------------------
    // Clock Generation
    //----------------------------------------------------

    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //----------------------------------------------------
    // Test Sequence
    //----------------------------------------------------

    initial
    begin

        $dumpfile("radix4.vcd");
        $dumpvars(0,tb_radix4);

        //-----------------------------
        // Reset
        //-----------------------------

        reset = 1;
        start = 0;

        multiplicand = 0;
        multiplier   = 0;

        #20;

        reset = 0;

        //-----------------------------
        // Test Case 1
        //-----------------------------

        multiplicand = 8'd12;
        multiplier   = 8'd5;

        start = 1;
        #10;
        start = 0;

        wait(done);

        #20;

        $display("--------------------------------");
        $display("12 x 5");
        $display("Product = %d",product);
        $display("--------------------------------");

        //-----------------------------
        // Test Case 2
        //-----------------------------

        multiplicand = 8'd15;
        multiplier   = 8'd8;

        start = 1;
        #10;
        start = 0;

        wait(done);

        #20;

        $display("--------------------------------");
        $display("15 x 8");
        $display("Product = %d",product);
        $display("--------------------------------");

        //-----------------------------
        // Test Case 3
        //-----------------------------

        multiplicand = 8'd20;
        multiplier   = 8'd20;

        start = 1;
        #10;
        start = 0;

        wait(done);

        #20;

        $display("--------------------------------");
        $display("20 x 20");
        $display("Product = %d",product);
        $display("--------------------------------");

        //-----------------------------
        // Test Case 4
        //-----------------------------

        multiplicand = -8'd8;
        multiplier   = 8'd5;

        start = 1;
        #10;
        start = 0;

        wait(done);

        #20;

        $display("--------------------------------");
        $display("-8 x 5");
        $display("Product = %d",product);
        $display("--------------------------------");

        //-----------------------------
        // Test Case 5
        //-----------------------------

        multiplicand = -8'd7;
        multiplier   = -8'd9;

        start = 1;
        #10;
        start = 0;

        wait(done);

        #20;

        $display("--------------------------------");
        $display("-7 x -9");
        $display("Product = %d",product);
        $display("--------------------------------");

        $finish;

    end

endmodule