module tb_ahb_gpio;
reg clk, resetn;
reg [1:0] HTRANS;
reg HWRITE;
reg [31:0] HADDR, HWDATA;
wire [31:0] HRDATA;
wire HREADY;
wire HRESP;

ahb_gpio uut (
    .clk(clk),
    .resetn(resetn),
    .HTRANS(HTRANS),
    .HWRITE(HWRITE),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HRDATA(HRDATA),
    .HREADY(HREADY),
    .HRESP(HRESP)
);

always #5 clk = ~clk;

task ahb_write;
    input [31:0] addr;
    input [31:0] data;
    begin
        @(posedge clk);
        HTRANS = 2'b10;
        HADDR  = addr;
        HWRITE = 1;
        @(posedge clk);
        HWDATA = data;
        HTRANS = 2'b00;
        HWRITE = 0;
    end
endtask

task ahb_read;
    input [31:0] addr;
    begin
        @(posedge clk);
        HTRANS = 2'b10;
        HADDR  = addr;
        HWRITE = 0;
        @(posedge clk);
        HTRANS = 2'b00;
        @(posedge clk);
        $display("HADDR=%h HRDATA=%h", addr, HRDATA);
    end
endtask

initial begin
    clk=0; resetn=0;
    HTRANS=0; HWRITE=0;
    HADDR=0; HWDATA=0;
    #20 resetn=1;

    ahb_write(32'h00, 32'hAAAAAAAA);
    ahb_read(32'h00);

    #20 $finish;
end

endmodule