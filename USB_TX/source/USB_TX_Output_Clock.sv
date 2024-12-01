`timescale 1ns / 10ps

module USB_TX_Output_Clock (
    input clk, n_rst, packet_load_complete_TX,
    output logic bit_en_TX
);

    logic [1:0] cnt3_TX;
    logic cntA_TX, cntB_TX, cntC_TX;
    logic flagA, flagB, flagC;

    logic flagSEL, clear;
    logic [3:0] A, B, C;

    always_comb begin
        cntA_TX = 1'b0;
        cntB_TX = 1'b0;
        cntC_TX = 1'b0;
        clear = 1'b0;
        bit_en_TX = (flagA || flagB || flagC);
        if(bit_en_TX) begin
            clear = 1'b1;
        end
        if(cnt3_TX == 2'b01) begin
            cntA_TX = 1'b1;
        end
        else if(cnt3_TX == 2'b10) begin
            cntB_TX = 1'b1;
        end
        else if(cnt3_TX == 2'b11) begin
            cntC_TX = 1'b1;
        end
    

    end

    USB_TX_Counter #(.SIZE(2)) OUTPCNT_SEL (
        .clk(clk), .n_rst(n_rst), .clear(1'b0), 
        .count_enable((packet_load_complete_TX)  && ((cnt3_TX == 2'b00) || (flagA || flagB || flagC))), .rollover_val(2'd3),
        .count_out(cnt3_TX) , .rollover_flag(flagSEL)
    );
    
    USB_TX_Counter #(.SIZE(4)) OUTPCNT_A (
        .clk(clk), .n_rst(n_rst), .clear(clear), 
        .count_enable(cntA_TX), .rollover_val(4'd7),
        .rollover_flag(flagA), .count_out(A)
    );

    USB_TX_Counter #(.SIZE(4)) OUTPCNT_B (
        .clk(clk), .n_rst(n_rst), .clear(clear), 
        .count_enable(cntB_TX), .rollover_val(4'd8),
        .rollover_flag(flagB), .count_out(B)
    );

    USB_TX_Counter #(.SIZE(4)) OUTPCNT_C (
        .clk(clk), .n_rst(n_rst), .clear(clear), 
        .count_enable(cntC_TX), .rollover_val(4'd7),
        .rollover_flag(flagC), .count_out(C)
    );





endmodule
