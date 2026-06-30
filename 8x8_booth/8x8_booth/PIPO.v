module PIPO (
    input clk,
    input load,
    input [15:0] data_in,
    output reg [15:0] data_out
);

    // Trigger on the rising edge of the clock
    always @(posedge clk) begin
        // If the load signal is high, capture the input data
        if (load) begin
            data_out <= data_in;
        end
    end

endmodule