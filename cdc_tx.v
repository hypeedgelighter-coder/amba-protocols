module cdc_tx #(
    parameter WIDTH = 32
)(
    input                   src_clk,
    input                   src_resetn,
    input  [WIDTH-1:0]      data_in,
    input                   valid_in,     // data_in을 보내라는 1클럭 펄스
    output reg [WIDTH-1:0]  data_hold,
    output reg              toggle
);
    always @(posedge src_clk or negedge src_resetn) begin
        if (~src_resetn) begin
            data_hold <= {WIDTH{1'b0}};
            toggle    <= 1'b0;
        end else if (valid_in) begin
            data_hold <= data_in;
            toggle    <= ~toggle;
        end
    end
endmodule