module ahb_gpio (
    input clk,
    input resetn,
    input [1:0]HTRANS,
    input HWRITE,
    input [31:0]HADDR,
    input [31:0]HWDATA,
    output reg [31:0]HRDATA,
    output HREADY,
    output HRESP


    
);

reg [31:0] reg0;
reg [31:0] reg1;
reg [31:0] reg2;
reg [31:0] haddr_reg;
reg hwrite_reg;

assign HREADY=1;
assign HRESP=0;


always @(posedge clk) begin
    if(HTRANS==2'b10||HTRANS==2'b11)begin
        haddr_reg<=HADDR;
        hwrite_reg<=HWRITE;
    end
    
end

always @(posedge clk) begin
    if (~resetn)begin
    reg0<=0;
    reg1<=0;
    reg2<=0;
    end else if (hwrite_reg)begin
        case (haddr_reg)
            32'h0: reg0<=HWDATA;
            32'h4: reg1<=HWDATA;
            32'h8: reg2<=HWDATA;
             
        endcase
    
        
    end
end

    always @(*)begin
        HRDATA=32'h0;
        if(~hwrite_reg)begin
            case (haddr_reg)
                32'h0: HRDATA=reg0;
                32'h4: HRDATA=reg1;
                32'h8: HRDATA=reg2; 
            endcase
    end
    
end

    
endmodule