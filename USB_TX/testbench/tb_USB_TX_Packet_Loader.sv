`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_USB_TX_Packet_Loader ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic bit_en_TX, packet_load_complete_TX;
    logic [543:0] packet_TX;
    logic [9:0] packet_counter;
    logic copy_signal;
    logic complete_TX;
    logic DP_OUT, DM_OUT;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task load_pack(
        input logic en, load_comp, copy,
        input logic [543:0] packet,
        input logic [9:0] count
    );
        bit_en_TX = en;
        packet_load_complete_TX = load_comp;
        copy_signal = copy;
        packet_TX = packet;
        packet_counter = count;
        #(CLK_PERIOD);
    
    endtask
    

    task reset_dut;
    begin
        n_rst = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(posedge clk);
        @(posedge clk);
    end
    endtask

    USB_TX_Packet_Loader DUT (
        .clk(clk), .n_rst(n_rst),
        .bit_en_TX(bit_en_TX), .packet_load_complete_TX(packet_load_complete_TX),
        .packet_TX(packet_TX), .packet_counter(packet_counter),
        .copy_signal(copy_signal), .complete_TX(complete_TX),
        .DP_OUT(DP_OUT), .DM_OUT(DM_OUT)
    );

    initial begin
        n_rst = 1;
        bit_en_TX = 1'b0;
        packet_load_complete_TX = 1'b0;
        copy_signal = 1'b0;
        packet_TX = 543'b0;
        packet_counter = 10'b0;
        reset_dut;
        // bit_en, comp, copy_sig, packet, count
        load_pack(1'b0, 1'b0, 1'b0, 543'b0, 10'b0);
        load_pack(1'b1, 1'b1, 1'b1, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);

        // ROUND TWO OF DATA STREAMING
        load_pack(1'b1, 1'b0, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b1, 1'b0, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b1, 1'b0, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b1, 1'b0, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b0, 1'b0, 1'b0, 543'b0, 10'b0);
        load_pack(1'b1, 1'b1, 1'b1, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);

        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        load_pack(1'b0, 1'b1, 1'b0, 543'b1101, 10'b0);
        
        load_pack(1'b1, 1'b1, 1'b0, 543'b1101, 10'b0);

        
        $finish;
    end
endmodule

/* verilator coverage_on */

