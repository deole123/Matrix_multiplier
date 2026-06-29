module radix4_datapath(

    input clk,

    input ldA,
    input ldQ,
    input ldM,

    input clrA,
    input clrQ,
    input clrff,
    input clrcnt,

    input sftA2,
    input sftQ2,

    input decr,
    input ldcnt,

    input [7:0] multiplicand,
    input [7:0] multiplier,

    output qm1,
    output eqz,

    output [15:0] product

);

wire signed [15:0] A;
wire [7:0] Q;

wire signed [15:0] M;

wire signed [15:0] operand;

wire signed [15:0] Z;

wire sign;

wire [1:0] mag_sel;

wire [2:0] count;

assign product = {A[7:0],Q};


//---------------------------------------------------
// Multiplicand Register
//---------------------------------------------------

PIPO MREG(

    .clk(clk),
    .load(ldM),

    .data_in({{8{multiplicand[7]}},multiplicand}),

    .data_out(M)

);


//---------------------------------------------------
// A Register
//---------------------------------------------------

A_register AREG(

    .clk(clk),
    .clrA(clrA),
    .ldA(ldA),
    .sftA2(sftA2),

    .Z(Z),

    .A(A)

);


//---------------------------------------------------
// Q Register
//---------------------------------------------------

Q_register QREG(

    .clk(clk),
    .clrQ(clrQ),
    .ldQ(ldQ),
    .sftQ2(sftQ2),

    .data_in({8'b0,multiplier}),

    .Ain(A[1:0]),

    .Q(Q)

);


//---------------------------------------------------
// History Register
//---------------------------------------------------

history_reg HR(

    .clk(clk),

    .clrff(clrff),

    .ld(sftQ2),

    .qm1_in(Q[1]),

    .qm1(qm1)

);


//---------------------------------------------------
// Booth Encoder
//---------------------------------------------------

booth_encoder BE(

    .Q1(Q[1]),

    .Q0(Q[0]),

    .qm1(qm1),

    .sign(sign),

    .mag_sel(mag_sel)

);


//---------------------------------------------------
// Operand Generator
//---------------------------------------------------

operand_generator OG(

    .M(M),

    .sign(sign),

    .mag_sel(mag_sel),

    .operand(operand)

);


//---------------------------------------------------
// ALU
//---------------------------------------------------

ALU ALU1(

    .A(A),

    .operand(operand),

    .Z(Z)

);


//---------------------------------------------------
// Counter
//---------------------------------------------------

counter CNT(

    .clk(clk),

    .clr(clrcnt),

    .ldcnt(ldcnt),

    .decr(decr),

    .count(count),

    .eqz(eqz)

);

endmodule