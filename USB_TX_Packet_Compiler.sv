`timescale 1ns/10ps

module USB_TX_Packet_Compiler(
    input logic clk, n_rst, TX_Transfer_Active,
    input logic [7:0] byte,
    output logic [9:0] packet_size_TX,
    output logic [543:0] packet_TX
);

    logic [543:0] packet_TX;

    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            packet_TX <= 544'b0;
        end
        else begin
            packet_TX <= n_packet_TX;
        end
    end

    USB_TX_Counter #(.SIZE(4)) (
        .clk(clk), .n_rst(n_rst), .clear(clear), 
        .count_enable(count_enable), .rollover_val(XXXX),
        .count_out(XXXX), .rollover_flag(XXXX)
    );

    always_comb begin

    end

endmodule