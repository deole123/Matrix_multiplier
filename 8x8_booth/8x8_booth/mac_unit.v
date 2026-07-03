// ====================================================================
// mac_unit.v
//
// Computes:  result = (a0 * b0) + (a1 * b1)
//
// This is a single "dot product of length 2" MAC unit. It contains
// ONE instance of the radix-4 Booth multiplier (radix4_top) and reuses
// it sequentially for both multiplications, accumulating the partial
// products internally.
//
// For a 2x2 matrix multiply, each output cell C[i][j] is exactly this
// kind of length-2 dot product:
//     C[i][j] = A[i][0]*B[0][j] + A[i][1]*B[1][j]
// so one mac_unit computes exactly one output cell.
// ====================================================================

module mac_unit(

    input clk,
    input reset,
    input start,

    input signed [7:0] a0,
    input signed [7:0] a1,

    input signed [7:0] b0,
    input signed [7:0] b1,

    output reg signed [17:0] result,   // 18 bits: safe headroom for sum of two 16-bit signed products
    output done

);

//---------------------------------------------------
// FSM state encoding
//---------------------------------------------------

localparam S_IDLE      = 3'd0;
localparam S_M1_START  = 3'd1;
localparam S_M1_WAIT   = 3'd2;
localparam S_M2_START  = 3'd3;
localparam S_M2_WAIT   = 3'd4;
localparam S_DONE      = 3'd5;

reg [2:0] state, next_state;

//---------------------------------------------------
// Operand registers fed to the internal multiplier
//---------------------------------------------------

reg [7:0] mcand, mplier;

//---------------------------------------------------
// Internal radix-4 Booth multiplier instance (reused twice)
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
            next_state = start ? S_M1_START : S_IDLE;

        S_M1_START:
            next_state = S_M1_WAIT;

        S_M1_WAIT:
            next_state = mul_done ? S_M2_START : S_M1_WAIT;

        S_M2_START:
            next_state = S_M2_WAIT;

        S_M2_WAIT:
            next_state = mul_done ? S_DONE : S_M2_WAIT;

        S_DONE:
            next_state = S_IDLE;

        default:
            next_state = S_IDLE;

    endcase

end

//---------------------------------------------------
// mul_start pulse (exactly one cycle, at each *_START state)
//---------------------------------------------------

assign mul_start = (state == S_M1_START) || (state == S_M2_START);

//---------------------------------------------------
// done flag (one cycle, when both multiplies + adds are finished)
//---------------------------------------------------

assign done = (state == S_DONE);

//---------------------------------------------------
// Operand latching
// mcand/mplier must stay stable across the START state AND the
// following WAIT state, since the internal multiplier needs a full
// clock cycle after 'start' to latch them (its own INIT state).
// So we register them once, when *entering* each multiply, and hold.
//---------------------------------------------------

always @(posedge clk or posedge reset)
begin

    if(reset)
    begin
        mcand  <= 8'd0;
        mplier <= 8'd0;
    end
    else
    begin
        case(state)

            S_IDLE:
                if(start)
                begin
                    mcand  <= a0;
                    mplier <= b0;
                end

            S_M1_WAIT:
                if(mul_done)
                begin
                    mcand  <= a1;
                    mplier <= b1;
                end

            default: ; // hold current values

        endcase
    end

end

//---------------------------------------------------
// Accumulator
//---------------------------------------------------

always @(posedge clk or posedge reset)
begin

    if(reset)
        result <= 18'sd0;

    else if(state == S_IDLE && start)
        result <= 18'sd0;                                   // clear for new op

    else if(state == S_M1_WAIT && mul_done)
        result <= result + $signed(mul_product);             // += a0*b0

    else if(state == S_M2_WAIT && mul_done)
        result <= result + $signed(mul_product);             // += a1*b1

end

endmodule
