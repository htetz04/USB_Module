`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_USB_TX_Output_Clock ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic packet_load_complete_TX, bit_en_TX;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task tick_clock(
        input logic tick
    );
        packet_load_complete_TX = tick;
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

    USB_TX_Output_Clock DUT (
        .clk(clk), .n_rst(n_rst), 
        .packet_load_complete_TX(packet_load_complete_TX),
        .bit_en_TX(bit_en_TX)
    );

    initial begin
        n_rst = 1;
        packet_load_complete_TX = 1'b0;

        reset_dut;
        tick_clock(1'b1);
        tick_clock(1'b1);

        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);

        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);

        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);

        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);

        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);

        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);
        tick_clock(1'b1);


        $finish;
    end
endmodule

/* verilator coverage_on */

