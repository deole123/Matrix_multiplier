module radix4_controller(

    input clk,
    input start,
    input reset,

    input eqz,

    output reg ldA,
    output reg ldQ,
    output reg ldM,

    output reg clrA,
    output reg clrQ,
    output reg clrff,
    output reg clrcnt,

    output reg sftA2,
    output reg sftQ2,

    output reg ldcnt,
    output reg decr,

    output reg done

);

parameter IDLE   = 3'd0;
parameter INIT   = 3'd1;
parameter EXEC   = 3'd2;
parameter SHIFT  = 3'd3;
parameter FINISH = 3'd4;

reg [2:0] state,next_state;



always @(posedge clk or posedge reset)
begin

    if(reset)
        state <= IDLE;

    else
        state <= next_state;

end



always @(*)
begin

    case(state)

    IDLE:

        if(start)
            next_state = INIT;
        else
            next_state = IDLE;

    INIT:

            next_state = EXEC;

    EXEC:

            next_state = SHIFT;

    SHIFT:

        if(eqz)
            next_state = FINISH;
        else
            next_state = EXEC;

    FINISH:

            next_state = IDLE;

    default:

            next_state = IDLE;

    endcase

end



always @(*)
begin

ldA=0;
ldQ=0;
ldM=0;

clrA=0;
clrQ=0;
clrff=0;
clrcnt=0;

sftA2=0;
sftQ2=0;

ldcnt=0;
decr=0;

done=0;

case(state)

IDLE:
begin
end


INIT:
begin

ldM=1;
ldQ=1;

clrA=1;
clrff=1;

ldcnt=1;

end


EXEC:
begin

ldA=1;

end


SHIFT:
begin

sftA2=1;
sftQ2=1;

decr=1;

end


FINISH:
begin

done=1;

end

endcase

end

endmodule