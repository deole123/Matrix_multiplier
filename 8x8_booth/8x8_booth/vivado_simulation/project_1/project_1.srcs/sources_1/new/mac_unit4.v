// ====================================================================
// mac_unit4.v
//
// Computes: result = (a0*b0) + (a1*b1) + (a2*b2) + (a3*b3)
//
// This is a length-4 dot product MAC unit -- exactly what one output
// cell of a 4x4 matrix multiply needs:
//     C[i][j] = sum_{k=0..3} A[i][k] * B[k][j]
//
// It contains ONE instance of the radix-4 Booth multiplier
// (radix4_top) and reuses it sequentially for all four
// multiplications (same reuse strategy as the original mac_unit.v).
//
// Accumulation of the four 16-bit signed partial products is done
// with a CARRY-SAVE ADDER (CSA): each new product is folded into a
// running {sum, carry} pair using bitwise full-adder logic (no carry
// propagation across bit positions on every accumulate step). Only
// once, at the very end, is a single carry-propagate add performed
// (sum + carry) to produce the final two's-complement result. This
// avoids paying a full ripple-carry-adder delay on every one of the
// three accumulate steps, which is the whole point of using a CSA
// for MAC accumulation.
// ====================================================================

module mac_unit4(

    input clk,
    input reset,
    input start,

    input signed [7:0] a0, a1, a2, a3,
    input signed [7:0] b0, b1, b2, b3,

    output reg signed [19:0] result,   // 20 bits: safe headroom for sum of four 16-bit signed products
    output done

);

//---------------------------------------------------
// FSM state encoding
//---------------------------------------------------

localparam S_IDLE      = 3'd0;
localparam S_MUL_START = 3'd1;
localparam S_MUL_WAIT  = 3'd2;
localparam S_ACCUM     = 3'd3;
localparam S_FINAL     = 3'd4;
localparam S_DONE      = 3'd5;

reg [2:0] state, next_state;

//---------------------------------------------------
// Which of the 4 products we are currently computing (0..3)
//---------------------------------------------------

reg [1:0] idx;

//---------------------------------------------------
// Operand registers fed to the internal multiplier
//---------------------------------------------------

reg signed [7:0] mcand, mplier;

always @(*) begin
    case(idx)
        2'd0: begin mcand = a0; mplier = b0; end
        2'd1: begin mcand = a1; mplier = b1; end
        2'd2: begin mcand = a2; mplier = b2; end
        default: begin mcand = a3; mplier = b3; end
    endcase
end

//---------------------------------------------------
// Internal radix-4 Booth multiplier instance (reused 4 times)
//---------------------------------------------------

wire [15:0] mul_product;
wire        mul_done;
wire        mul_start;

radix4_top MUL (

    .clk(clk),
    .reset(reset),
    .start(mul_start),

    .multiplicand(mcand),
    .multiplier(mplier),

    .product(mul_product),
    .done(mul_done)

);

assign mul_start = (state == S_MUL_START);
assign done      = (state == S_DONE);

//---------------------------------------------------
// State register
//---------------------------------------------------

always @(posedge clk or posedge reset)
begin
    if(reset)
        state <= S_IDLE;
    else
        state <= next_state;
end

//---------------------------------------------------
// Next-state logic
//---------------------------------------------------

always @(*)
begin
    case(state)

        S_IDLE:
            next_state = start ? S_MUL_START : S_IDLE;

        S_MUL_START:
            next_state = S_MUL_WAIT;

        S_MUL_WAIT:
            next_state = mul_done ? S_ACCUM : S_MUL_WAIT;

        S_ACCUM:
            // after folding the product into {sum,carry}, either do
            // the next multiply, or finish
            next_state = (idx == 2'd3) ? S_FINAL : S_MUL_START;

        S_FINAL:
            next_state = S_DONE;

        S_DONE:
            next_state = S_IDLE;

        default:
            next_state = S_IDLE;

    endcase
end

//---------------------------------------------------
// idx counter: which product (0..3) we're on
//---------------------------------------------------

always @(posedge clk or posedge reset)
begin
    if(reset)
        idx <= 2'd0;
    else if(state == S_IDLE && start)
        idx <= 2'd0;
    else if(state == S_ACCUM && idx != 2'd3)
        idx <= idx + 2'd1;
end

//---------------------------------------------------
// Carry-save accumulator
//
// sum_acc / carry_acc together represent the running total in
// carry-save (redundant) form: true_value = sum_acc + carry_acc.
// Each accumulate step folds in one sign-extended 16-bit product
// using bitwise full-adder logic -- no carry ripple across bits.
//---------------------------------------------------

reg  signed [19:0] sum_acc, carry_acc;
wire signed [19:0] product_ext = {{4{mul_product[15]}}, mul_product};

wire [19:0] csa_sum;
wire [19:0] csa_carry;

// 3:2 carry-save compressor (bitwise full adder) over
// {sum_acc, carry_acc, product_ext}
assign csa_sum   = sum_acc ^ carry_acc ^ product_ext;
assign csa_carry = ((sum_acc & carry_acc) |
                     (sum_acc & product_ext) |
                     (carry_acc & product_ext)) << 1;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        sum_acc   <= 20'sd0;
        carry_acc <= 20'sd0;
    end
    else if(state == S_IDLE && start)
    begin
        sum_acc   <= 20'sd0;
        carry_acc <= 20'sd0;
    end
    else if(state == S_ACCUM)
    begin
        sum_acc   <= csa_sum;
        carry_acc <= csa_carry;
    end
end

//---------------------------------------------------
// Final carry-propagate add: result = sum_acc + carry_acc
// Performed once, in S_FINAL, to resolve the redundant CSA form
// into a normal two's-complement number.
//---------------------------------------------------

always @(posedge clk or posedge reset)
begin
    if(reset)
        result <= 20'sd0;
    else if(state == S_FINAL)
        result <= sum_acc + carry_acc;
end

endmodule
