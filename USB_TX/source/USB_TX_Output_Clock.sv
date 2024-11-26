`timescale 1ns / 10ps

module USB_TX_Output_Clock (
    input clk, n_rst,
    output logic bit_en_TX
);

    logic [1:0] cnt3_TX;
    logic cntA_TX, cntB_TX, cntC_TX;

    OUTPCNT_SEL (
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(XXXX), .rollover_val(2'd3),
        .count_out(cnt3_TX) // , .rollover_flag(XXXX)
    );

    assign cntA_TX = (cnt3_TX == 2'b00);
    assign cntB_TX = (cnt3_TX == 2'b01);
    assign cntC_TX = (cnt3_TX == 2'b10);
    
    OUTPCNT_A (
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(cntA_TX), .rollover_val(3'd8),
        .rollover_flag(bit_en_TX)
    );

    OUTPCNT_B (
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(cntB_TX), .rollover_val(4'd9),
        .count_out(bit_en_TX) // , .rollover_flag(bit_en_TX)
    );

    OUTPCNT_C (
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable(cntC_TX), .rollover_val(3'd8),
        .rollover_flag(bit_en_TX)
    );




endmodule