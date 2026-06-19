module axi_little_slave (

    input clk,
    input resetn,

    //쓰기주소
    input [31:0] AWADDR,
    input AWVALID,
    output AWREADY,

    //쓰기데이터
    input [31:0] WDATA,
    input [3:0] WSTRB,
    input WVALID,
    output WREADY,

    //쓰기응답
    output BVALID,
    output [1:0] BRESP,
    input BREADY,

    //읽기주소
    input [31:0] ARADDR,
    input ARVALID,
    output ARREADY,

    //읽기데이터응답
    output reg [31:0] RDATA,
    output [1:0] RRESP,
    output RVALID,
    input RREADY

);

reg [31:0] reg0;
reg [31:0] reg1;
reg [31:0] reg2;

assign BRESP = 2'b00;
assign RRESP = 2'b00;

//AW 채널
reg [31:0] awaddr_reg;
assign AWREADY = 1'b1;

always @(posedge clk) begin
    if (~resetn) begin
        awaddr_reg <= 32'h00;
    end else if (AWREADY && AWVALID) begin
        awaddr_reg <= AWADDR;
    end
end

//W 채널
reg [31:0] wdata_reg;
assign WREADY = 1;

always @(posedge clk) begin
    if (~resetn) begin
        wdata_reg <= 0;
    end else if (WREADY && WVALID) begin
        if (WSTRB[0]) wdata_reg[7:0]   <= WDATA[7:0];
        if (WSTRB[1]) wdata_reg[15:8]  <= WDATA[15:8];
        if (WSTRB[2]) wdata_reg[23:16] <= WDATA[23:16];
        if (WSTRB[3]) wdata_reg[31:24] <= WDATA[31:24];
    end
end

// 쓰기 완료시 실제 저장
always @(posedge clk) begin
    if (~resetn) begin
        reg0 <= 0;
        reg1 <= 0;
        reg2 <= 0;
    end else if (bvalid_reg == 0 && AWVALID && AWREADY && WVALID && WREADY) begin
        case (awaddr_reg)
            32'h00: reg0 <= wdata_reg;
            32'h04: reg1 <= wdata_reg;
            32'h08: reg2 <= wdata_reg;
        endcase
    end
end

//B 채널
reg bvalid_reg;
assign BVALID = bvalid_reg;

always @(posedge clk) begin
    if (~resetn) begin
        bvalid_reg <= 0;
    end else if (AWVALID && AWREADY && WVALID && WREADY) begin
        bvalid_reg <= 1;
    end else if (BVALID && BREADY) begin
        bvalid_reg <= 0;
    end
end

//AR 채널
reg [31:0] araddr_reg;
assign ARREADY = 1'b1;

always @(posedge clk) begin
    if (~resetn) begin
        araddr_reg <= 0;
    end else if (ARVALID && ARREADY) begin
        araddr_reg <= ARADDR;
    end
end

//R 채널
reg rvalid_reg;
assign RVALID = rvalid_reg;

always @(posedge clk) begin
    if (~resetn) begin
        rvalid_reg <= 0;
    end else if (ARVALID && ARREADY) begin
        rvalid_reg <= 1;
    end else if (RREADY && RVALID) begin
        rvalid_reg <= 0;
    end
end

//R 데이터 전송
always @(*) begin
    RDATA = 32'h0;
    case (araddr_reg)
        32'h00: RDATA = reg0;
        32'h04: RDATA = reg1;
        32'h08: RDATA = reg2;
    endcase
end

endmodule
