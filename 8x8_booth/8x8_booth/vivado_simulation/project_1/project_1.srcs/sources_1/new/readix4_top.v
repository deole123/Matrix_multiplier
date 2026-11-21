module radix4_top(

    input clk,
    input reset,
    input start,

    input [7:0] multiplicand,
    input [7:0] multiplier,

    output [15:0] product,
    output done

);

//----------------------------------------------------
// Internal Signals
//----------------------------------------------------

wire ldA;
wire ldQ;
wire ldM;

wire clrA;
wire clrQ;
wire clrff;
wire clrcnt;

wire sftA2;
wire sftQ2;

wire ldcnt;
wire decr;

wire qm1;
wire eqz;


//----------------------------------------------------
// Controller
//----------------------------------------------------

radix4_controller CTRL(

    .clk(clk),
    .reset(reset),
    .start(start),

    .eqz(eqz),

    .ldA(ldA),
    .ldQ(ldQ),
    .ldM(ldM),

    .clrA(clrA),
    .clrQ(clrQ),
    .clrff(clrff),
    .clrcnt(clrcnt),

    .sftA2(sftA2),
    .sftQ2(sftQ2),

    .ldcnt(ldcnt),
    .decr(decr),

    .done(done)

);


//----------------------------------------------------
// Datapath
//----------------------------------------------------

radix4_datapath DP(

    .clk(clk),

    .ldA(ldA),
    .ldQ(ldQ),
    .ldM(ldM),

    .clrA(clrA),
    .clrQ(clrQ),
    .clrff(clrff),
    .clrcnt(clrcnt),

    .sftA2(sftA2),
    .sftQ2(sftQ2),

    .decr(decr),
    .ldcnt(ldcnt),

    .multiplicand(multiplicand),
    .multiplier(multiplier),

    .qm1(qm1),
    .eqz(eqz),

    .product(product)

);

endmodule