module apb_gpio(
    input clk,
    input reset,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [7:0] PADDR,
    input [31:0] PWDATA,
    output reg [31:0] PRDATA,
    output PREADY
);

reg [31:0] reg0;
reg [31:0] reg1;
reg [31:0] reg2;

assign PREADY = 1;

always @(posedge clk) begin
    if (reset) begin
        reg0 <= 0;
        reg1 <= 0;
        reg2 <= 0;
    end else if (PSEL && PENABLE && PWRITE) begin
        case (PADDR)
            8'h00: reg0 <= PWDATA;
            8'h04: reg1 <= PWDATA;
            8'h08: reg2 <= PWDATA;
        endcase
    end
end

always @(*) begin
    PRDATA = 32'h0;
    if (~PWRITE && PENABLE && PSEL) begin
        case (PADDR)
            8'h00: PRDATA = reg0;
            8'h04: PRDATA = reg1;
            8'h08: PRDATA = reg2;
        endcase
    end
end

endmodule
