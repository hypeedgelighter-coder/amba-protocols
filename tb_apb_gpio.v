module tb_apb_gpio;
reg clk, reset;
reg PSEL, PENABLE, PWRITE;
reg [7:0] PADDR;
reg [31:0] PWDATA;
wire [31:0] PRDATA;
wire PREADY;

apb_gpio uut (
    .clk(clk),
    .reset(reset),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY)
);

always #5 clk = ~clk;

task apb_write;
    input [7:0]  addr;
    input [31:0] data;
    begin
        @(posedge clk);
        PSEL=1; PENABLE=0; PWRITE=1;
        PADDR=addr; PWDATA=data;
        @(posedge clk);
        PENABLE=1;
        @(posedge clk);
        PSEL=0; PENABLE=0;
    end
endtask

task apb_read;
    input [7:0] addr;
    begin
        @(posedge clk);
        PSEL=1; PENABLE=0; PWRITE=0;
        PADDR=addr;
        @(posedge clk);
        PENABLE=1;
        @(posedge clk);
        $display("PADDR=%h PRDATA=%h", addr, PRDATA);
        PSEL=0; PENABLE=0;
    end
endtask

initial begin
    clk=0; reset=1;
    PSEL=0; PENABLE=0; PWRITE=0;
    PADDR=0; PWDATA=0;
    #20 reset=0;

    apb_write(8'h00, 32'hAAAAAAAA);
    #20
    apb_read(8'h00);

    #20 $finish;
end

endmodule