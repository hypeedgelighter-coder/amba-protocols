module cdc_rx #(
    parameter WIDTH = 32
)(
    input                   dst_clk,
    input                   dst_resetn,
    input  [WIDTH-1:0]      data_hold,    // 송신측 data_hold (조합 와이어로 연결)
    input                   toggle,       // 송신측 toggle (비동기 입력)
    output reg [WIDTH-1:0]  data_out,
    output reg              data_out_valid,
    output                  sync_busy     // 디버그용: 동기화 진행 중 표시
);
    // CDC 동기화 플롭 - *_sync0 (1단, 메타스테이블 가능), *_sync1 (2단, 안정)
    reg toggle_sync0, toggle_sync1, toggle_sync2;

    always @(posedge dst_clk or negedge dst_resetn) begin
        if (~dst_resetn) begin
            toggle_sync0   <= 1'b0;
            toggle_sync1   <= 1'b0;
            toggle_sync2   <= 1'b0;
            data_out       <= {WIDTH{1'b0}};
            data_out_valid <= 1'b0;
        end else begin
            toggle_sync0 <= toggle;
            toggle_sync1 <= toggle_sync0;
            toggle_sync2 <= toggle_sync1;

            data_out_valid <= (toggle_sync1 != toggle_sync2);

            if (toggle_sync1 != toggle_sync2) begin
                data_out <= data_hold;
            end
        end
    end

    assign sync_busy = (toggle_sync0 != toggle_sync2);
endmodule