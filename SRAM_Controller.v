`define IDLE 3'd0
`define WRITE_LOW 3'd1
`define WRITE_HIGH 3'd2
`define READ_ADDR 3'd3
`define READ_LOW 3'd4
`define READ_HIGH 3'd5
`define STALL 3'd6
`define READY 3'd7

module SRAM_Controller (
    input clk,
    input rst,
    
    input wrEn,
    input rdEn,
    input[31:0] address,
    input[31:0] writeData,

    output[31:0] readData,
    output reg ready,

    inout[15:0]     SRAM_DQ,
    output reg [17:0] SRAM_ADDR,
    output reg      SRAM_WE_N,
    output          SRAM_UB_N,
    output          SRAM_LB_N,
    output          SRAM_CE_N,
    output          SRAM_OE_N
);
    reg [2:0] ps, ns;
    reg cntEn, cntLd;
    reg [15:0] dataLow, dataHigh;
    wire [16:0] sramAddress;
    wire co;

    Counter_3b cnt3b(clk, rst, cntEn, cntLd, 3'b100, co);

    assign {SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N} = 4'b0;

    assign sramAddress = ((address-1024))>>2;

    always @(ps or wrEn or rdEn or co) begin
        ns = `IDLE;
        case(ps) 
            `IDLE :         ns = wrEn ? `WRITE_LOW : rdEn ? `READ_ADDR : `IDLE;
            `WRITE_LOW :    ns = `WRITE_HIGH;
            `WRITE_HIGH :   ns = `STALL;
            `READ_ADDR :    ns = `READ_LOW;
            `READ_LOW :     ns = `READ_HIGH;
            `READ_HIGH :    ns = `STALL;
            `STALL :        ns = co ? `IDLE : `READY;
            `READY :        ns = `IDLE;
        endcase
    end

    always @(posedge clk) begin
        if(rst)
            ps <= `IDLE;
        else
            ps <= ns;
    end

    always @(ps or wrEn or rdEn) begin
        ready = 1'b0; 
        cntEn = 1'b1;
        cntLd = 1'b0;
        SRAM_ADDR = 18'b0;
        SRAM_WE_N = 1'b1;
        case(ps) 
            `IDLE :         begin ready=~(wrEn|rdEn); cntEn=1'b0; cntLd=1'b1; end
            `WRITE_LOW :    begin SRAM_WE_N=1'b0; SRAM_ADDR={sramAddress, 1'b0}; end
            `WRITE_HIGH :   begin SRAM_WE_N=1'b0; SRAM_ADDR={sramAddress, 1'b1}; end
            `READ_ADDR :    begin SRAM_ADDR={sramAddress, 1'b0}; end 
            `READ_LOW :     begin SRAM_ADDR={sramAddress, 1'b1}; dataLow=SRAM_DQ; end
            `READ_HIGH :    begin dataHigh=SRAM_DQ; end
            `READY :        begin ready=1; end
        endcase
    end

    assign SRAM_DQ = ps==`WRITE_LOW ? writeData[15:0] : ps==`WRITE_HIGH ? writeData[31:16] : 16'bz;
    assign readData = {dataHigh, dataLow};

endmodule

