`timescale 1ns / 10ps

module USB_TX_Packet_Loader (
    input logic clk, n_rst,
    input logic bit_en_TX, packet_load_complete_TX,
    input logic [543:0] packet_TX,
    input logic [9:0] packet_counter,
    input logic copy_signal,
    output logic complete_TX,
    output logic DP_OUT, DM_OUT
);

    logic [543:0] reg_copy, n_reg_copy;
    logic bit_out;
    logic n_DP_OUT, n_DM_OUT;

    logic complete_EOP_A, n_complete_EOP_A;
    logic complete_EOP_B, n_complete_EOP_B;
    logic n_complete_TX;

    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            DP_OUT <= 1'b1;
            DM_OUT <= 1'b0;
            reg_copy <= 544'b0;
            complete_EOP_A <= 1'b0;
            complete_EOP_B <= 1'b0;
            complete_TX <= 1'b0;
        end
        else begin
            DP_OUT <= n_DP_OUT;
            DM_OUT <= n_DM_OUT;
            reg_copy <= n_reg_copy;
            complete_EOP_A <= n_complete_EOP_A;
            complete_EOP_B <= n_complete_EOP_B;
            complete_TX <= n_complete_TX;
        end
    end

    always_comb begin
        n_DP_OUT = DP_OUT;
        n_DM_OUT = DM_OUT;
        n_reg_copy = reg_copy;
        n_complete_EOP_A = complete_EOP_A;
        n_complete_EOP_B = complete_EOP_B;
        n_complete_TX = complete_TX;

        if(bit_en_TX) begin
            n_DP_OUT = reg_copy[0];
            n_DM_OUT = !(n_DP_OUT);
            n_reg_copy = {1'b0, reg_copy[543:1]};
        end

        if(!packet_load_complete_TX) begin
            n_DP_OUT = 1'b1;
            n_DM_OUT = 1'b0;
        end

        if(copy_signal) begin
            n_reg_copy = packet_TX;
            n_complete_TX = 1'b0;
            n_complete_EOP_A = 1'b0;
            n_complete_EOP_B = 1'b0;
            n_DP_OUT = 1'b1;
            n_DM_OUT = 1'b0;
            
        end

        if((reg_copy == 543'b0) && (!copy_signal) && (packet_load_complete_TX)) begin
            if(bit_en_TX) begin
                n_DP_OUT = 1'b0;
                n_DM_OUT = 1'b0;
                n_complete_EOP_A = 1'b1;
                if(complete_EOP_A) begin
                    n_complete_EOP_B = 1'b1;
                end
                if(complete_EOP_A && complete_EOP_B) begin
                    n_DP_OUT = 1'b1;
                    n_DM_OUT = 1'b0;
                    n_complete_TX = 1'b1;
                end
            end
        end
    end

endmodule

